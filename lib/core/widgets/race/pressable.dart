import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

/// Tap wrapper that gives any widget a springy "press in" scale, a light
/// haptic tick and button semantics. Only the [AnimatedScale] rebuilds.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.96,
    this.haptic = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  final ValueNotifier<bool> _pressed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _pressed.value = true : null,
        onTapUp: enabled ? (_) => _pressed.value = false : null,
        onTapCancel: enabled ? () => _pressed.value = false : null,
        onTap: enabled ? _handleTap : null,
        child: ValueListenableBuilder<bool>(
          valueListenable: _pressed,
          builder: (context, pressed, child) => AnimatedScale(
            scale: pressed ? widget.pressedScale : 1,
            duration: AppTheme.animationFast,
            curve: pressed ? Curves.easeOut : AppTheme.springCurve,
            child: child,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
