import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/hive/hive_boxes.dart';

/// Persists the app-wide Listen mode preference (speak questions aloud).
@lazySingleton
class ListenModeSettings extends ChangeNotifier {
  ListenModeSettings(this._hive);

  final HiveService _hive;

  bool get enabled {
    final stored = _hive.quizProgress.get(QuizProgressKeys.listenMode);
    return stored == true;
  }

  Future<void> setEnabled(bool value) async {
    await _hive.quizProgress.put(QuizProgressKeys.listenMode, value);
    notifyListeners();
  }

  Future<void> toggle() => setEnabled(!enabled);
}
