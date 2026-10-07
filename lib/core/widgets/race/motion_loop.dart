import 'package:flutter/material.dart';

/// Endlessly repeating gentle motion for decorative illustrations: a float, a
/// breathing scale or a slow rotation. The controller only drives [Transform]
/// widgets, so the animated subtree is never rebuilt, and the loop freezes when
/// the system asks to reduce motion.
class MotionLoop extends StatefulWidget {
  const MotionLoop({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2600),
    this.offset = Offset.zero,
    this.scale = 1,
    this.rotate = 0,
    this.reverse = true,
  });

  final Widget child;

  /// Length of one sweep. A full there-and-back cycle is twice this.
  final Duration duration;

  /// How far the child drifts from its resting place, in logical pixels.
  final Offset offset;

  /// Peak scale, e.g. `1.06` to breathe by six percent.
  final double scale;

  /// Peak rotation in turns, e.g. `0.5` for half a spin.
  final double rotate;

  /// Sweep out and then back to the start. When false the sweep restarts from
  /// the beginning instead of reversing.
  final bool reverse;

  @override
  State<MotionLoop> createState() => _MotionLoopState();
}

class _MotionLoopState extends State<MotionLoop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: widget.reverse);
    }
  }

  @override
  void didUpdateWidget(MotionLoop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller
        ..duration = widget.duration
        ..repeat(reverse: widget.reverse);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    // 0 -> 1 -> 0 across the sweep, so the child rests where it was laid out.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Transform.translate(
            offset: Offset(widget.offset.dx * (t - 0.5), widget.offset.dy * (t - 0.5)),
            child: Transform.rotate(
              angle: widget.rotate * (t - 0.5) * 2 * 3.14159265358979,
              child: Transform.scale(scale: 1 + (widget.scale - 1) * t, child: child),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
