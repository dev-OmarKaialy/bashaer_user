import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/extensions/log_colors_extension.dart';
import '../../../../core/services/hive/hive_boxes.dart';
import '../models/quiz_result_model.dart';

/// One-time move of study progress out of `flutter_secure_storage`, where it
/// lived before the Hive migration, into the Hive progress box.
///
/// Runs at most once per install. On any failure the flag stays unset and the
/// legacy keys are left alone, so a transient error retries next start rather
/// than losing a student's history.
@injectable
class QuizProgressMigration {
  QuizProgressMigration(this._storage, this._hive);

  final FlutterSecureStorage _storage;
  final HiveService _hive;

  static const _legacyBookmarksKey = 'quiz_bookmarks_v1';
  static const _legacyAnswerLogKey = 'quiz_answer_log_v1';
  static const _legacyResultsKey = 'quiz_results_v1';

  Future<void> run() async {
    final box = _hive.quizProgress;
    if (box.get(QuizProgressKeys.migratedFromSecureStorage) == true) return;

    try {
      final bookmarks = await _readJsonList(_legacyBookmarksKey);
      final answerLog = await _readJsonList(_legacyAnswerLogKey);
      final results = await _readJsonList(_legacyResultsKey);

      final migrated = <String, dynamic>{
        if (bookmarks != null)
          QuizProgressKeys.bookmarks: bookmarks.map((e) => e.toString()).toList(),
        if (answerLog != null)
          QuizProgressKeys.answerLog: answerLog.map(_answerLogEntryFrom).toList(),
        if (results != null) QuizProgressKeys.results: results.map(_resultFrom).toList(),
      };

      if (migrated.isNotEmpty) {
        await box.putAll(migrated);
        log('Migrated ${migrated.keys.join(', ')} from secure storage to Hive.'.logGreen);
      }

      await Future.wait([
        _storage.delete(key: _legacyBookmarksKey),
        _storage.delete(key: _legacyAnswerLogKey),
        _storage.delete(key: _legacyResultsKey),
      ]);
      await box.put(QuizProgressKeys.migratedFromSecureStorage, true);
    } catch (e) {
      log('Progress migration failed ($e); secure-storage data left in place.'.logRed);
    }
  }

  Future<List<dynamic>?> _readJsonList(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    return decoded is List ? decoded : null;
  }

  AnswerLogEntry _answerLogEntryFrom(dynamic json) =>
      AnswerLogEntry.fromJson(Map<String, dynamic>.from(json as Map));

  QuizResultModel _resultFrom(dynamic json) =>
      QuizResultModel.fromJson(Map<String, dynamic>.from(json as Map));
}
