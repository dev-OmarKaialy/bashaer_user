import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Bundled Lottie animation with performance defaults: cached drawing
/// commands for loops, a repaint boundary, and a static frame when the user
/// asked the system to reduce motion.
class AppLottie extends StatelessWidget {
  const AppLottie({
    super.key,
    required this.asset,
    this.size,
    this.repeat = true,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  final String asset;

  /// Square size; null fills the incoming constraints.
  final double? size;
  final bool repeat;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animation = Lottie.asset(
      asset,
      width: size,
      height: size,
      fit: fit,
      repeat: repeat,
      animate: !reduceMotion,
      renderCache: repeat ? RenderCache.drawingCommands : null,
      errorBuilder: (context, error, stackTrace) => SizedBox(width: size, height: size),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: animation);
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(child: animation),
    );
  }
}
