import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/dependencies.dart';
import 'core/services/firebase/firebase_config.dart';
import 'core/services/hive/hive_boxes.dart';
import 'features/quiz/data/datasources/quiz_media_cache.dart';
import 'features/quiz/data/datasources/quiz_progress_migration.dart';

/// Entry point for the team template.
///
/// Bootstrapping order:
/// 1) initialize framework bindings
/// 2) open local storage (Hive) and connect to Firebase
/// 3) register shared/core and feature-level dependencies
/// 4) move any pre-Hive progress across, then run the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Boxes must be open before DI so datasources can read them synchronously.
  // Hive and Firebase are independent; warm them together.
  await Future.wait<void>([initHive(), initFirebase()]);

  configureDependencies();

  await getIt<QuizProgressMigration>().run();
  // Resolve the media folder + URL index so image widgets can read disk offline.
  await getIt<QuizMediaCache>().warm();

  runApp(
    SafeArea(
      top: false,
      bottom: true,
      child: EasyLocalization(
        path: 'assets/translations',
        supportedLocales: const [Locale('en'), Locale('ar')],
        saveLocale: true,
        startLocale: const Locale('ar'),
        child: const TemplateApp(),
      ),
    ),
  );
}
