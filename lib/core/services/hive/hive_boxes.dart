import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import 'hive_registrar.g.dart';

/// Names of the Hive boxes opened at startup.
class HiveBoxes {
  const HiveBoxes._();

  /// Question bank cached from Firestore on each successful load.
  static const quizBank = 'quiz_bank';

  /// Device-local study progress the statistics are derived from.
  static const quizProgress = 'quiz_progress';
}

/// Keys inside the [HiveBoxes.quizBank] box.
class QuizBankKeys {
  const QuizBankKeys._();

  static const categories = 'categories';
  static const questions = 'questions';
  static const fetchedAt = 'fetched_at';

  /// Map of remote image URL → relative filename under the app media folder.
  static const mediaIndex = 'media_index';
}

/// Keys inside the [HiveBoxes.quizProgress] box.
class QuizProgressKeys {
  const QuizProgressKeys._();

  static const bookmarks = 'bookmarks';
  static const answerLog = 'answer_log';
  static const results = 'results';
  static const migratedFromSecureStorage = 'migrated_from_secure_storage_v1';

  /// Whether Listen mode (TTS / question audio) is enabled for non-readers.
  static const listenMode = 'listen_mode';
}

/// Opens Hive and every box the app uses.
///
/// Must run before `configureDependencies()` so that [HiveService] can hand
/// out already-open boxes synchronously.
Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Future.wait([
    Hive.openBox<dynamic>(HiveBoxes.quizBank),
    Hive.openBox<dynamic>(HiveBoxes.quizProgress),
  ]);
}

/// Injectable accessor for the boxes opened by [initHive].
@lazySingleton
class HiveService {
  Box<dynamic> get quizBank => Hive.box<dynamic>(HiveBoxes.quizBank);

  Box<dynamic> get quizProgress => Hive.box<dynamic>(HiveBoxes.quizProgress);
}
