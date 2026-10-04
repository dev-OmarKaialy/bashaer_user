import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

import '../../extensions/log_colors_extension.dart';

/// Plays the app's short SFX (answer feedback, start-lights countdown, engine
/// start) through a single player so sounds never stack on top of each other.
@lazySingleton
class AppSfx {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playTick() => _play('assets/sounds/tick.mp3');

  Future<void> playWarning() => _play('assets/sounds/warning.mp3');

  Future<void> playCountdown() => _play('assets/sounds/countdown.wav');

  Future<void> playGo() => _play('assets/sounds/go.wav');

  Future<void> playEngineStart() async {
     await _play('assets/sounds/engine_started.mp3');
     return  _play('assets/sounds/engine_start.mp3');
  
  }

  Future<void> playFireworks() => _play('assets/sounds/fireworks.mp3');

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      log('SFX stop failed: $e'.logYellow);
    }
  }

  Future<void> _play(String asset) async {
    try {
      await _player.setAsset(asset);
      await _player.seek(Duration.zero);
      await _player.play().timeout(const Duration(seconds: 5));
    } catch (e) {
      log('SFX play failed ($asset): $e'.logYellow);
    }
  }
}
