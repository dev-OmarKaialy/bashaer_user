import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/extensions/log_colors_extension.dart';
import '../../../../core/services/hive/hive_boxes.dart';
import '../models/question_model.dart';

/// Downloads question/answer images and optional question audio during bank
/// sync and serves them from disk so exams work offline after the first
/// successful sync.
abstract class QuizMediaCache {
  /// Downloads every remote URL not already on disk. Failures are logged and
  /// skipped so a single bad file does not block the whole sync.
  ///
  /// [onProgress] reports `(finished, total)` after each file — downloaded,
  /// skipped and failed alike — so callers can drive a determinate bar.
  Future<void> cacheUrls(Iterable<String> urls, {void Function(int done, int total)? onProgress});

  /// Loads the on-disk media folder and URL index without downloading.
  Future<void> warm();

  /// Absolute local file for [url] when it was cached successfully.
  File? fileFor(String url);

  /// Collects unique HTTPS image and audio URLs from a question bank.
  static Set<String> urlsFromQuestions(Iterable<QuestionModel> questions) {
    final urls = <String>{};
    for (final question in questions) {
      final image = question.image?.trim();
      if (image != null && image.startsWith('http')) urls.add(image);
      final audio = question.audio?.trim();
      if (audio != null && audio.startsWith('http')) urls.add(audio);
      for (final answer in question.answers) {
        final answerImage = answer.image?.trim();
        if (answerImage != null && answerImage.startsWith('http')) {
          urls.add(answerImage);
        }
      }
    }
    return urls;
  }
}

@LazySingleton(as: QuizMediaCache)
class QuizMediaCacheImpl implements QuizMediaCache {
  QuizMediaCacheImpl(this._hive)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          responseType: ResponseType.bytes,
          headers: const {
            'Accept': 'image/*,audio/*,*/*',
            'User-Agent': 'BashaerDriving/1.0 (Flutter; exam-prep)',
          },
        ),
      );

  final HiveService _hive;
  final Dio _dio;

  /// Cap parallel downloads so bootstrap stays responsive on weak networks.
  static const _maxConcurrent = 4;

  Directory? _mediaDir;
  Map<String, String>? _index;

  Box<dynamic> get _bank => _hive.quizBank;

  Map<String, String> get _mediaIndex {
    final cached = _index;
    if (cached != null) return cached;

    final stored = _bank.get(QuizBankKeys.mediaIndex);
    final map = <String, String>{};
    if (stored is Map) {
      stored.forEach((key, value) {
        if (key is String && value is String && key.isNotEmpty && value.isNotEmpty) {
          map[key] = value;
        }
      });
    }
    return _index = map;
  }

  Future<Directory> _ensureMediaDir() async {
    final existing = _mediaDir;
    if (existing != null) return existing;
    final root = await getApplicationSupportDirectory();
    final dir = Directory('${root.path}/quiz_media');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return _mediaDir = dir;
  }

  Future<void> _persistIndex() async {
    await _bank.put(QuizBankKeys.mediaIndex, Map<String, String>.from(_mediaIndex));
  }

  @override
  File? fileFor(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    // Already a local absolute / file URI from an older cache rewrite.
    if (trimmed.startsWith('/') || trimmed.startsWith('file:')) {
      final path = trimmed.startsWith('file:') ? Uri.parse(trimmed).toFilePath() : trimmed;
      final file = File(path);
      return file.existsSync() ? file : null;
    }

    final relative = _mediaIndex[trimmed];
    if (relative == null) return null;
    final dir = _mediaDir;
    if (dir == null) {
      // Sync path may not have run yet this process; resolve lazily.
      // fileFor is sync — only works after cacheUrls (or warm) set _mediaDir.
      return null;
    }
    final file = File('${dir.path}/$relative');
    return file.existsSync() ? file : null;
  }

  /// Ensures [_mediaDir] is set so [fileFor] can resolve after a cold start
  /// without waiting for another download.
  @override
  Future<void> warm() async {
    await _ensureMediaDir();
    _mediaIndex;
  }

  @override
  Future<void> cacheUrls(
    Iterable<String> urls, {
    void Function(int done, int total)? onProgress,
  }) async {
    final unique = urls.map((u) => u.trim()).where((u) => u.startsWith('http')).toSet().toList();
    if (unique.isEmpty) {
      await warm();
      onProgress?.call(0, 0);
      return;
    }

    final dir = await _ensureMediaDir();
    final index = _mediaIndex;
    var changed = false;
    var downloaded = 0;
    var skipped = 0;
    var failed = 0;
    var finished = 0;

    Future<void> cacheOne(String url) async {
      final fileName = _fileNameFor(url);
      final target = File('${dir.path}/$fileName');

      // Skip only when this URL already maps to the *current* naming scheme
      // and the file is present — otherwise a bad/truncated name would stick forever.
      final existingName = index[url];
      if (existingName == fileName && target.existsSync() && target.lengthSync() > 0) {
        skipped++;
        return;
      }

      try {
        final response = await _dio.get<List<int>>(url);
        final bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          failed++;
          log('Empty media body for $url'.logYellow);
          return;
        }
        await target.writeAsBytes(bytes, flush: true);
        index[url] = fileName;
        changed = true;
        downloaded++;
      } catch (e) {
        failed++;
        log('Media cache failed for $url ($e)'.logYellow);
        if (target.existsSync()) {
          try {
            await target.delete();
          } catch (_) {}
        }
      }
    }

    Future<void> cacheOneReported(String url) async {
      await cacheOne(url);
      finished++;
      onProgress?.call(finished, unique.length);
    }

    for (var i = 0; i < unique.length; i += _maxConcurrent) {
      final chunk = unique.sublist(i, (i + _maxConcurrent).clamp(0, unique.length));
      await Future.wait(chunk.map(cacheOneReported));
    }

    if (changed) await _persistIndex();
    log(
      'Quiz media cache: downloaded $downloaded, skipped $skipped, failed $failed '
              '(${unique.length} urls)'
          .logWhite,
    );
  }

  /// Stable, filesystem-safe name derived from the full remote URL.
  ///
  /// Must not truncate a shared prefix: Firestore media URLs share a long common
  /// path, so a short base64 prefix collided and every question reused one file.
  static String _fileNameFor(String url) {
    final uri = Uri.tryParse(url);
    final path = uri?.path ?? url;
    final ext = _extensionOf(path);
    final leaf = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
        : 'media';
    // Full-string digest so URLs that only differ after a long shared prefix
    // never map to the same local file.
    final bytes = utf8.encode(url);
    var h1 = 0x811c9dc5;
    var h2 = 0x811c9dc5;
    for (final b in bytes) {
      h1 = 0x1fffffff & ((h1 ^ b) * 0x01000193);
      h2 = 0x1fffffff & ((h2 ^ b) * 0x01000193 + b);
    }
    final digest = '${h1.toRadixString(16)}${h2.toRadixString(16)}';
    if (leaf.toLowerCase().endsWith(ext) || leaf.contains('.')) {
      return '${digest}_$leaf';
    }
    return '${digest}_$leaf$ext';
  }

  static String _extensionOf(String path) {
    final lower = path.toLowerCase();
    for (final ext in [
      '.png',
      '.jpg',
      '.jpeg',
      '.webp',
      '.gif',
      '.svg',
      '.mp3',
      '.m4a',
      '.wav',
      '.ogg',
      '.aac',
    ]) {
      if (lower.endsWith(ext)) return ext == '.jpeg' ? '.jpg' : ext;
    }
    return '.bin';
  }
}
