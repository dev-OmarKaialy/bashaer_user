import 'package:flutter/widgets.dart';

import '../services/dependencies.dart';
import '../services/sfx/app_sfx.dart';

/// Plays the car "engine start" SFX once, right after this widget's first
/// frame, and just renders [child]. Used to greet the user when the splash,
/// the license gate and the home screen mount.
class EngineStartSound extends StatefulWidget {
  const EngineStartSound({super.key, required this.child});

  final Widget child;

  @override
  State<EngineStartSound> createState() => _EngineStartSoundState();
}

class _EngineStartSoundState extends State<EngineStartSound> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      getIt<AppSfx>().playEngineStart();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
