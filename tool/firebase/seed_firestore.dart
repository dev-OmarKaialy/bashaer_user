// Imports the bundled question bank into Cloud Firestore, with question images
// hosted on imgbb.
//
// Upserts rather than appends: documents are matched on their natural keys,
// which are used as the document ids (Category.slug, Question.qid), so
// re-running after editing the JSON updates the existing documents instead of
// creating duplicates. Nothing is ever deleted.
//
// Every seed file is validated before a single byte is sent: unknown category
// references, duplicate ids, answer sets that disagree with `correctAnswerIds`
// and missing media files all fail the run with a report (exit 65), so a broken
// bank can never reach the students' app half-written.
//
// Auth is a Firebase service-account key (JSON) for Firestore, plus an imgbb
// API key for image hosting. The app itself needs neither — it reads the
// question bank with public-read rules and the media over plain HTTPS.
//
// Cloud Storage is deliberately not used: the Firebase project has no bucket
// provisioned, so images live on imgbb and the documents just carry the URLs.
// Uploaded URLs are recorded in `tool/firebase/data/media_manifest.json` and
// reused on later runs, so re-seeding does not re-upload an unchanged image or
// churn the URL the students' app has already cached.
//
// Usage:
//   fvm dart run tool/firebase/seed_firestore.dart \
//     --service-account=<path to service-account key .json>
//
//   --project=<project-id>                default: project_id from the key file
//   --imgbb-key=<api key>                 default: $IMGBB_API_KEY; only needed
//                                         when an image is new or changed
//   --file=<path>                         source JSON; repeat for several files
//                                         (default: every *.json in
//                                          tool/firebase/data/)
//   --dry-run                             validate and print what would be
//                                         sent, contact nobody
//   --check                               validate only, then exit
//
// To get a service-account key: Firebase console → Project settings → Service
// accounts → Generate new private key. The account needs to write Firestore
// documents (e.g. the Firestore Admin role); security rules do not apply to
// service accounts — IAM does. Keep the key out of the repository.
import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

const _categoryCollection = 'categories';
const _questionCollection = 'questions';
const _defaultDataDir = 'tool/firebase/data';

/// Firestore caps a commit at 500 writes; questions carry answer arrays, so a
/// smaller batch keeps each request comfortably under the 10 MiB body limit.
const _writesPerCommit = 100;

const _questionTypes = {'single_choice', 'multiple_choice', 'true_false'};
const _difficulties = {'easy', 'medium', 'hard'};

/// The question bank is public to the app, so docs carry no user data.
/// License rows are written separately by the app, never by this tool.

Future<void> main(List<String> args) async {
  final options = _Options.parse(args);
  if (options == null) exitCode = 64;
  if (options == null) return;

  final _SeedBank bank;
  try {
    bank = _SeedBank.load(options.files);
  } on _SeedException catch (e) {
    stderr.writeln(e);
    exitCode = 65;
    return;
  }

  bank.printSummary();
  if (!bank.printIssues()) {
    stderr.writeln('\nNothing was sent. Fix the errors above and re-run.');
    exitCode = 65;
    return;
  }
  if (options.checkOnly) return;

  if (options.dryRun) {
    stdout.writeln('\n--dry-run: nothing sent. First category and first imaged question:');
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(bank.categoryRows.values.first));
    final imaged = bank.questionRows.values.where((r) => r['image'] != null);
    stdout.writeln(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(imaged.isNotEmpty ? imaged.first : bank.questionRows.values.first),
    );
    return;
  }

  final media = _MediaHost(manifest: _MediaManifest.load(), apiKey: options.imgbbKey);
  final client = await _FirestoreClient.create(options);
  try {
    // Resolve local image paths → public imgbb URLs (reused across runs).
    for (final row in bank.questionRows.values) {
      row['image'] = await media.resolve(row['image']);
      row['audio'] = await media.resolve(row['audio']);
      final answers = (row['answers'] as List<dynamic>? ?? const []);
      row['answers'] = [
        for (final answer in answers)
          if (answer is Map<String, dynamic>)
            {...answer, 'image': await media.resolve(answer['image'])}
          else
            answer,
      ];
    }
    media.report();

    await client.upsert(_categoryCollection, bank.categoryRows);
    await client.upsert(_questionCollection, bank.questionRows);
    await client.verify({
      _categoryCollection: bank.categoryRows.length,
      _questionCollection: bank.questionRows.length,
    });
    stdout.writeln('\nDone.');
  } on _SeedException catch (e) {
    stderr.writeln('\n$e');
    exitCode = 1;
  } finally {
    client.close();
  }
}

/// Turns local seed media into public URLs, uploading to imgbb only what the
/// manifest does not already cover.
class _MediaHost {
  _MediaHost({required _MediaManifest manifest, required String apiKey})
    : _manifest = manifest,
      _apiKey = apiKey;

  static const _endpoint = 'https://api.imgbb.com/1/upload';
  static const _imageExtensions = {'.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'};

  final _MediaManifest _manifest;
  final String _apiKey;
  final _http = http.Client();
  var _uploaded = 0;
  var _reused = 0;

  /// [raw] is either an `https://…` URL (left alone) or an absolute local path
  /// resolved at load time.
  Future<String?> resolve(Object? raw) async {
    if (raw == null) return null;
    final value = raw.toString().trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) return value;

    final file = File(value);
    if (!file.existsSync()) {
      throw _SeedException('Media file not found: ${file.path}');
    }
    final name = file.uri.pathSegments.last;
    final bytes = await file.readAsBytes();
    final digest = _MediaManifest.digest(bytes);

    final known = _manifest.urlFor(name, digest);
    if (known != null) {
      _reused++;
      return known;
    }

    final extension = name.contains('.') ? name.substring(name.lastIndexOf('.')).toLowerCase() : '';
    if (!_imageExtensions.contains(extension)) {
      // imgbb hosts images only; audio would need a different host.
      throw _SeedException(
        'imgbb cannot host "$name" ($extension). Only images are supported: '
        '${_imageExtensions.join(', ')}.',
      );
    }
    if (_apiKey.isEmpty) {
      throw _SeedException(
        '$name is new or changed and must be uploaded, but no imgbb API key was '
        'given. Pass --imgbb-key=<key> or set IMGBB_API_KEY.',
      );
    }

    final url = await _upload(name: name, bytes: bytes);
    _manifest.record(name: name, digest: digest, url: url);
    _uploaded++;
    stdout.writeln('  uploaded $name → $url');
    return url;
  }

  Future<String> _upload({required String name, required List<int> bytes}) async {
    // imgbb takes the file as base64 in a form field; no expiration = permanent.
    final response = await _http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      body: {'name': name, 'image': base64Encode(bytes)},
    );
    if (response.statusCode >= 400) {
      throw _SeedException(
        'HTTP ${response.statusCode} uploading $name to imgbb: ${_errorOf(response.body)}',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    final url = (data?['image'] as Map<String, dynamic>?)?['url'] ?? data?['url'];
    if (url is! String || url.isEmpty) {
      throw _SeedException('imgbb returned no URL for $name: ${response.body}');
    }
    return url;
  }

  /// imgbb reports failures as `{"error": {"message": "..."}}`.
  static String _errorOf(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is Map) {
        return (decoded['error'] as Map)['message']?.toString() ?? body;
      }
    } on FormatException {
      // Fall through to the raw body.
    }
    return body;
  }

  void report() {
    if (_uploaded == 0 && _reused == 0) return;
    stdout.writeln(
      '\nMedia: $_uploaded uploaded to imgbb, $_reused reused from '
      '${_MediaManifest.path}',
    );
    if (_uploaded > 0) _manifest.save();
    _http.close();
  }
}

/// Local record of which image landed on which imgbb URL, keyed by file name
/// and content digest. Committed with the seed data so every machine re-seeds
/// to the same URLs instead of uploading duplicates.
class _MediaManifest {
  _MediaManifest(this._entries);

  static const path = '$_defaultDataDir/media_manifest.json';

  final Map<String, Map<String, dynamic>> _entries;

  static _MediaManifest load() {
    final file = File(path);
    if (!file.existsSync()) return _MediaManifest({});
    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return _MediaManifest({
      for (final entry in decoded.entries) entry.key: Map<String, dynamic>.from(entry.value as Map),
    });
  }

  String? urlFor(String name, String digest) {
    final entry = _entries[name];
    if (entry == null || entry['digest'] != digest) return null;
    final url = entry['url'];
    return url is String && url.isNotEmpty ? url : null;
  }

  void record({required String name, required String digest, required String url}) {
    _entries[name] = {
      'digest': digest,
      'url': url,
      'uploadedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  void save() {
    final sorted = Map.fromEntries(
      _entries.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    File(path).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(sorted)}\n');
    stdout.writeln('  manifest updated: $path');
  }

  /// FNV-1a 64-bit over the file bytes — enough to notice an edited image
  /// without pulling in a hashing dependency.
  static String digest(List<int> bytes) {
    var hash = 0xcbf29ce484222325;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    // Dart ints are signed, so print the two 32-bit halves to keep the digest
    // unsigned and exactly 16 hex characters.
    final high = (hash >> 32) & 0xFFFFFFFF;
    final low = hash & 0xFFFFFFFF;
    return 'fnv1a64:${high.toRadixString(16).padLeft(8, '0')}'
        '${low.toRadixString(16).padLeft(8, '0')}';
  }
}

/// One loaded (and merged) question bank, ready to validate and upload.
class _SeedBank {
  _SeedBank._(this.categoryRows, this.questionRows, this._issues, this._sources);

  /// Firestore rows keyed by document id.
  final Map<String, Map<String, dynamic>> categoryRows;
  final Map<String, Map<String, dynamic>> questionRows;
  final List<_Issue> _issues;
  final Map<String, String> _sources;

  /// Reads every seed file, merges them and collects everything that looks
  /// wrong. Throws only for problems that make reading impossible at all.
  static _SeedBank load(List<String> paths) {
    final issues = <_Issue>[];
    final sources = <String, String>{};
    final categoryRows = <String, Map<String, dynamic>>{};
    final questionRows = <String, Map<String, dynamic>>{};
    final questionCounts = <String, int>{};
    final mediaBasenames = <String, String>{};

    if (paths.isEmpty) {
      throw _SeedException('No seed files found. Pass --file=<path>.');
    }

    for (final path in paths) {
      final file = File(path);
      if (!file.existsSync()) throw _SeedException('Seed file not found: $path');
      final Map<String, dynamic> seed;
      try {
        seed = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      } on FormatException catch (e) {
        throw _SeedException('$path is not valid JSON: ${e.message}');
      }
      final seedDir = file.absolute.parent.path;
      final categories = (seed['categories'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      final questions = (seed['questions'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      stdout.writeln(
        'Read ${categories.length} categories and ${questions.length} questions from $path',
      );

      for (final category in categories) {
        final slug = (category['id'] as String? ?? '').trim();
        if (slug.isEmpty) {
          issues.add(_Issue.error(path, 'a category has no id'));
          continue;
        }
        final row = {
          'slug': slug,
          'name': category['name'],
          'icon': category['icon'],
          'description': category['description'],
          'order': categoryRows.length,
          'questionCount': 0,
        };
        final previous = categoryRows[slug];
        if (previous != null) {
          // Same category declared twice: harmless when identical, a content
          // conflict otherwise (one of the two names would silently win).
          if (previous['name'] != row['name'] || previous['icon'] != row['icon']) {
            issues.add(
              _Issue.error(
                path,
                'category "$slug" is already defined in ${sources['category:$slug']} '
                'with different content',
              ),
            );
          }
          continue;
        }
        categoryRows[slug] = row;
        sources['category:$slug'] = path;
      }

      for (final question in questions) {
        final qid = (question['id'] as String? ?? '').trim();
        if (qid.isEmpty) {
          issues.add(_Issue.error(path, 'a question has no id'));
          continue;
        }
        if (questionRows.containsKey(qid)) {
          issues.add(
            _Issue.error(path, 'question id "$qid" already used in ${sources['question:$qid']}'),
          );
          continue;
        }
        final correctIds = _stringList(question['correctAnswerIds']);
        final answers = [
          for (final answer in (question['answers'] as List<dynamic>? ?? const []))
            if (answer is Map<String, dynamic>)
              {
                ...answer,
                // The app decides correctness from `correctAnswerIds`; mirror it
                // onto each answer so the documents are self-describing.
                'isCorrect': correctIds.contains(answer['id']),
                'image': _localizeMedia(
                  raw: answer['image'],
                  seedDir: seedDir,
                  path: path,
                  where: '$qid answer "${answer['id']}"',
                  issues: issues,
                  basenames: mediaBasenames,
                ),
              }
            else
              answer,
        ];

        questionRows[qid] = {
          'qid': qid,
          'categorySlug': question['categoryId'],
          'type': question['type'] ?? 'single_choice',
          'title': question['title'],
          'image': _localizeMedia(
            raw: question['image'],
            seedDir: seedDir,
            path: path,
            where: qid,
            issues: issues,
            basenames: mediaBasenames,
          ),
          'audio': _localizeMedia(
            raw: question['audio'],
            seedDir: seedDir,
            path: path,
            where: qid,
            issues: issues,
            basenames: mediaBasenames,
          ),
          'description': question['description'],
          'answers': answers,
          'correctAnswerIds': correctIds,
          'hint': question['hint'],
          'explanation': question['explanation'],
          'difficulty': question['difficulty'],
          'points': question['points'] ?? 1,
        };
        sources['question:$qid'] = path;
        final categoryId = question['categoryId'] as String? ?? '';
        questionCounts[categoryId] = (questionCounts[categoryId] ?? 0) + 1;
      }
    }

    for (final entry in categoryRows.entries) {
      entry.value['questionCount'] = questionCounts[entry.key] ?? 0;
    }

    final bank = _SeedBank._(categoryRows, questionRows, issues, sources);
    bank._validate();
    return bank;
  }

  /// Resolves a relative media path against its seed file and checks it exists.
  static String? _localizeMedia({
    required Object? raw,
    required String seedDir,
    required String path,
    required String where,
    required List<_Issue> issues,
    required Map<String, String> basenames,
  }) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) return value;

    final file = File('$seedDir/$value');
    if (!file.existsSync()) {
      issues.add(_Issue.error(path, '$where references a missing media file: $value'));
      return file.absolute.path;
    }
    final absolute = file.absolute.path;
    // The upload manifest is keyed by file name, so two different files sharing
    // a name would resolve to each other's URL.
    final name = file.uri.pathSegments.last;
    final claimed = basenames[name];
    if (claimed != null && claimed != absolute) {
      issues.add(
        _Issue.error(path, '$where uses media file name "$name", already taken by $claimed'),
      );
    }
    basenames[name] = absolute;
    return absolute;
  }

  void _validate() {
    for (final entry in categoryRows.entries) {
      final slug = entry.key;
      final row = entry.value;
      final where = 'category $slug';
      if ((row['name'] as String? ?? '').trim().isEmpty) {
        _issues.add(_Issue.error(_sources['category:$slug'] ?? '', '$where has no name'));
      }
      if (row['questionCount'] == 0) {
        _issues.add(_Issue.warning(_sources['category:$slug'] ?? '', '$where has no questions'));
      }
    }

    for (final entry in questionRows.entries) {
      final qid = entry.key;
      final row = entry.value;
      final source = _sources['question:$qid'] ?? '';
      void error(String message) => _issues.add(_Issue.error(source, '$qid: $message'));
      void warn(String message) => _issues.add(_Issue.warning(source, '$qid: $message'));

      final categorySlug = row['categorySlug'] as String? ?? '';
      if (!categoryRows.containsKey(categorySlug)) {
        error('unknown category "$categorySlug"');
      }
      if ((row['title'] as String? ?? '').trim().isEmpty) {
        error('empty title');
      }

      final type = row['type'] as String? ?? '';
      if (!_questionTypes.contains(type)) {
        error('unknown type "$type" (expected one of ${_questionTypes.join(', ')})');
      }

      final answers = (row['answers'] as List<dynamic>).whereType<Map<String, dynamic>>().toList();
      final answerIds = <String>[];
      for (final answer in answers) {
        final id = (answer['id'] as String? ?? '').trim();
        if (id.isEmpty) {
          error('an answer has no id');
          continue;
        }
        if (answerIds.contains(id)) error('duplicate answer id "$id"');
        answerIds.add(id);
        final text = (answer['text'] as String? ?? '').trim();
        if (text.isEmpty && answer['image'] == null) {
          error('answer "$id" has neither text nor image');
        }
      }
      if (answers.length < 2) error('needs at least 2 answers, has ${answers.length}');

      final correct = _stringList(row['correctAnswerIds']);
      if (correct.isEmpty) {
        error('no correct answer');
      }
      if (correct.toSet().length != correct.length) {
        error('correctAnswerIds contains duplicates');
      }
      for (final id in correct) {
        if (!answerIds.contains(id)) error('correct answer "$id" is not one of the answers');
      }
      switch (type) {
        case 'true_false':
          if (answerIds.length != 2) error('true_false must have exactly 2 answers');
          if (correct.length != 1) error('true_false must have exactly 1 correct answer');
        case 'single_choice':
          if (correct.length != 1) {
            error('single_choice must have exactly 1 correct answer, has ${correct.length}');
          }
        case 'multiple_choice':
          if (correct.length < 2) {
            warn(
              'multiple_choice with ${correct.length} correct answer(s) — should it be '
              'single_choice?',
            );
          }
      }

      final difficulty = row['difficulty'];
      if (difficulty != null && !_difficulties.contains(difficulty)) {
        error('difficulty "$difficulty" is not one of ${_difficulties.join(', ')}');
      }
      final points = row['points'];
      if (points is! int || points < 1) {
        error('points must be a whole number >= 1, got $points');
      }
    }
  }

  void printSummary() {
    stdout.writeln(
      '\nMerged ${categoryRows.length} categories and ${questionRows.length} questions:',
    );
    for (final entry in categoryRows.entries) {
      stdout.writeln(
        '  ${entry.key.padRight(16)} ${entry.value['questionCount'].toString().padLeft(3)} '
        'questions   ${entry.value['name']}',
      );
    }
    final withImage = questionRows.values.where((r) => r['image'] != null).length;
    final withAudio = questionRows.values.where((r) => r['audio'] != null).length;
    final withExplanation = questionRows.values.where((r) => r['explanation'] != null).length;
    final withHint = questionRows.values.where((r) => r['hint'] != null).length;
    final withDifficulty = questionRows.values.where((r) => r['difficulty'] != null).length;
    stdout.writeln(
      '  media: $withImage image, $withAudio audio · '
      'explanation $withExplanation, hint $withHint, difficulty $withDifficulty '
      '(of ${questionRows.length})',
    );
  }

  /// Prints the collected issues. Returns false when the bank must not be sent.
  bool printIssues() {
    final errors = _issues.where((i) => i.isError).toList();
    final warnings = _issues.where((i) => !i.isError).toList();
    for (final warning in warnings) {
      stdout.writeln('  warning  $warning');
    }
    for (final error in errors) {
      stderr.writeln('  ERROR    $error');
    }
    if (errors.isEmpty) {
      stdout.writeln(
        '\nValidation passed'
        '${warnings.isEmpty ? '' : ' with ${warnings.length} warning(s)'}.',
      );
      return true;
    }
    stderr.writeln('\nValidation failed: ${errors.length} error(s).');
    return false;
  }

  static List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return [for (final item in raw) item.toString()];
  }
}

class _Issue {
  _Issue.error(this.source, this.message) : isError = true;
  _Issue.warning(this.source, this.message) : isError = false;

  final String source;
  final String message;
  final bool isError;

  @override
  String toString() => source.isEmpty ? message : '$message   ($source)';
}

class _FirestoreClient {
  _FirestoreClient._(this._http, this._project);

  final http.Client _http;
  final String _project;

  static Future<_FirestoreClient> create(_Options options) async {
    final credentials = options.loadServiceAccount();
    // datastore = Firestore. Media lives on imgbb, so no storage scope is used.
    final client = await clientViaServiceAccount(credentials, const [
      'https://www.googleapis.com/auth/datastore',
    ]);
    return _FirestoreClient._(client, options.project);
  }

  void close() => _http.close();

  /// Resource path as Firestore names documents in a write payload — no host,
  /// no API version (`projects/…/documents/categories/cooling`).
  String get _resourceBase => 'projects/$_project/databases/(default)/documents';

  /// Same path as a request URL.
  String get _docBase => 'https://firestore.googleapis.com/v1/$_resourceBase';

  /// Creates missing documents and updates existing ones, keyed by doc id.
  ///
  /// Each commit carries an `update` write with an `updateMask`, which creates
  /// the document when it is missing and otherwise merges the listed fields —
  /// fields the seed does not own (if any are ever added by hand) survive.
  Future<void> upsert(String collection, Map<String, Map<String, dynamic>> rows) async {
    stdout.writeln('\n$collection: ${rows.length} documents');
    final entries = rows.entries.toList();
    var written = 0;

    for (var start = 0; start < entries.length; start += _writesPerCommit) {
      final end = (start + _writesPerCommit).clamp(0, entries.length);
      final batch = entries.sublist(start, end);
      final writes = [
        for (final entry in batch)
          {
            'update': {
              'name': '$_resourceBase/$collection/${entry.key}',
              'fields': _fields(entry.value),
            },
            'updateMask': {'fieldPaths': entry.value.keys.toList()},
          },
      ];
      final response = await _http.post(
        Uri.parse('$_docBase:commit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'writes': writes}),
      );
      if (response.statusCode >= 400) {
        throw _SeedException(
          'commit $collection [${start + 1}-$end] → HTTP ${response.statusCode}: ${response.body}',
        );
      }
      written += batch.length;
      stdout.writeln('  $written/${entries.length}');
    }
  }

  /// Reads the document counts back so a partial write cannot pass unnoticed.
  Future<void> verify(Map<String, int> expected) async {
    stdout.writeln('\nVerifying:');
    for (final entry in expected.entries) {
      final actual = await _count(entry.key);
      final ok = actual >= entry.value;
      stdout.writeln(
        '  ${entry.key.padRight(12)} $actual document(s) in Firestore, '
        'seeded ${entry.value}${ok ? '' : '  ← MISSING'}',
      );
      if (!ok) {
        throw _SeedException('${entry.key}: expected at least ${entry.value}, found $actual.');
      }
    }
  }

  Future<int> _count(String collection) async {
    final response = await _http.post(
      Uri.parse('$_docBase:runAggregationQuery'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'structuredAggregationQuery': {
          'structuredQuery': {
            'from': [
              {'collectionId': collection},
            ],
          },
          'aggregations': [
            {'count': {}, 'alias': 'total'},
          ],
        },
      }),
    );
    if (response.statusCode >= 400) {
      throw _SeedException('count $collection → HTTP ${response.statusCode}: ${response.body}');
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    for (final item in decoded) {
      final result = (item as Map<String, dynamic>)['result'] as Map<String, dynamic>?;
      final total = (result?['aggregateFields'] as Map<String, dynamic>?)?['total'];
      final value = (total as Map<String, dynamic>?)?['integerValue'];
      if (value != null) return int.tryParse(value.toString()) ?? 0;
    }
    return 0;
  }

  /// Encodes a Dart value into a Firestore REST `fields`-style value object.
  static Map<String, dynamic> _fields(Map<String, dynamic> document) {
    return {for (final entry in document.entries) entry.key: _fieldValue(entry.value)};
  }

  static dynamic _fieldValue(Object? value) {
    if (value == null) return {'nullValue': null};
    if (value is bool) return {'booleanValue': value};
    if (value is int) return {'integerValue': '$value'};
    if (value is num) return {'doubleValue': value};
    if (value is String) return {'stringValue': value};
    if (value is List) {
      return {
        'arrayValue': {
          'values': [for (final item in value) _fieldValue(item)],
        },
      };
    }
    if (value is Map) {
      return {
        'mapValue': {'fields': _fields(Map<String, dynamic>.from(value))},
      };
    }
    throw _SeedException('Unsupported seed value: $value (${value.runtimeType})');
  }
}

class _Options {
  _Options({
    required this.serviceAccountPath,
    required this.project,
    required this.imgbbKey,
    required this.files,
    required this.dryRun,
    required this.checkOnly,
  });

  final String serviceAccountPath;
  final String project;
  final String imgbbKey;
  final List<String> files;
  final bool dryRun;
  final bool checkOnly;

  ServiceAccountCredentials loadServiceAccount() {
    final raw = File(serviceAccountPath).readAsStringSync();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return ServiceAccountCredentials.fromJson(decoded);
  }

  static _Options? parse(List<String> args) {
    String? valueOf(String name) {
      final prefix = '--$name=';
      for (final arg in args) {
        if (arg.startsWith(prefix)) return arg.substring(prefix.length);
      }
      return null;
    }

    List<String> valuesOf(String name) {
      final prefix = '--$name=';
      return [
        for (final arg in args)
          if (arg.startsWith(prefix)) arg.substring(prefix.length),
      ];
    }

    final dryRun = args.contains('--dry-run');
    final checkOnly = args.contains('--check');
    final offline = dryRun || checkOnly;
    final serviceAccountPath = valueOf('service-account') ?? '';

    if (!offline && serviceAccountPath.isEmpty) {
      stderr.writeln(
        'Missing service-account key.\n\n'
        '  fvm dart run tool/firebase/seed_firestore.dart \\\n'
        '    --service-account=<path to service-account key .json>\n\n'
        'Add --dry-run to preview the payload, or --check to validate only, '
        'both without credentials.',
      );
      return null;
    }

    String project;
    if (offline) {
      project = valueOf('project') ?? '';
    } else {
      final raw = jsonDecode(File(serviceAccountPath).readAsStringSync()) as Map<String, dynamic>;
      project = valueOf('project') ?? (raw['project_id'] as String? ?? '');
      if (project.isEmpty) {
        stderr.writeln('Could not read project_id from the service-account key.');
        return null;
      }
    }

    var files = valuesOf('file');
    if (files.isEmpty) files = _defaultFiles();

    return _Options(
      serviceAccountPath: serviceAccountPath,
      project: project,
      // Kept out of the repository: passed per run or exported in the shell.
      imgbbKey: valueOf('imgbb-key') ?? Platform.environment['IMGBB_API_KEY'] ?? '',
      files: files,
      dryRun: dryRun,
      checkOnly: checkOnly,
    );
  }

  /// Every `*.json` directly inside `tool/firebase/data/`, in name order, so
  /// `quiz_01_…`, `quiz_02_…` are imported together without listing each one.
  static List<String> _defaultFiles() {
    final dir = Directory(_defaultDataDir);
    if (!dir.existsSync()) return const [];
    final files =
        dir
            .listSync()
            .whereType<File>()
            .map((f) => f.path)
            .where((p) => p.toLowerCase().endsWith('.json'))
            .toList()
          ..sort();
    return files;
  }
}

class _SeedException implements Exception {
  _SeedException(this.message);

  final String message;

  @override
  String toString() => message;
}
