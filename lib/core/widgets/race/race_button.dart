import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_theme.dart';
import 'pressable.dart';

enum RaceButtonVariant { filled, soft, outline }

/// Pill-shaped gradient call-to-action with a press spring and a colored
/// glow. [shine] adds a looping light sweep, meant for one hero CTA per screen.
class RaceButton extends StatelessWidget {
  const RaceButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppTheme.oceanGradient,
    this.variant = RaceButtonVariant.filled,
    this.shine = false,
    this.dense = false,
    this.fullWidth = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LinearGradient gradient;
  final RaceButtonVariant variant;
  final bool shine;
  final bool dense;

  /// Stretch to the incoming width constraint. Use it for call-to-action rows
  /// laid out in a centred column, which otherwise shrink-wraps the pill.
  final bool fullWidth;

  /// Shows a spinner in place of [icon] and keeps the pill looking "busy"
  /// while work is in flight. Taps are blocked for as long as it is true.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final hasHandler = onPressed != null;
    final busy = loading;
    final enabled = hasHandler && !loading;
    final baseColor = gradient.colors.first;
    final isFilled = variant == RaceButtonVariant.filled;
    // Disabled text must stay readable on the pale disabled fill; a busy pill
    // keeps the same foreground as an enabled one, because it keeps its color.
    final foreground = !enabled && !busy
        ? AppTheme.inkSoft
        : isFilled
        ? AppTheme.onPrimaryColor
        : baseColor;

    // A busy pill keeps its gradient so it reads as "working", not "off".
    final decoration = BoxDecoration(
      gradient: enabled || busy ? (isFilled ? gradient : null) : null,
      color: !enabled && !busy
          ? AppTheme.mutedSurface
          : variant == RaceButtonVariant.soft
          ? baseColor.withValues(alpha: 0.12)
          : variant == RaceButtonVariant.outline
          ? AppTheme.cardSurface
          : null,
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      border: variant == RaceButtonVariant.outline && enabled
          ? Border.all(color: baseColor.withValues(alpha: 0.5), width: 1.5)
          : null,
      boxShadow: (enabled || busy) && isFilled
          ? AppTheme.glowShadow(baseColor, strength: enabled ? 0.7 : 0.35)
          : null,
    );

    // Scale the label down in tight slots (quiz footer, long Arabic CTAs) instead
    // of letting the Row paint yellow overflow stripes. Skip Flexible when the
    // incoming width is unbounded (e.g. nested in a Row without Expanded).
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: dense ? 42.h : 54.h),
      child: DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dense ? 14.w : 20.w, vertical: 8.h),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final labelText = FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: foreground,
                    fontSize: dense ? 13.sp : 16.sp,
                  ),
                ),
              );
              final leading = <Widget>[
                if (busy)
                  SizedBox(
                    width: (dense ? 18.r : 22.r),
                    height: (dense ? 18.r : 22.r),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFilled ? AppTheme.onPrimaryColor : baseColor,
                      ),
                    ),
                  )
                else if (icon != null)
                  Icon(icon, color: foreground, size: dense ? 18.r : 22.r),
                if (busy || icon != null) SizedBox(width: 8.w),
              ];
              return Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...leading,
                  if (constraints.maxWidth.isFinite) Flexible(child: labelText) else labelText,
                ],
              );
            },
          ),
        ),
      ),
    );

    if (fullWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    if (shine && enabled && isFilled && !MediaQuery.disableAnimationsOf(context)) {
      content = content
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            delay: 1800.ms,
            duration: 1200.ms,
            color: AppTheme.onPrimaryColor.withValues(alpha: 0.35),
          );
    }

    return Pressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: busy ? '$label…' : label,
      child: content,
    );
  }
}

/// Square icon button on a white "key fob" tile, with a 48px tap target.
class RaceIconButton extends StatelessWidget {
  const RaceIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AppTheme.ink,
    this.background = AppTheme.cardSurface,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onPressed,
        pressedScale: 0.9,
        semanticLabel: tooltip,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                boxShadow: AppTheme.cardShadow,
              ),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Icon(icon, size: 21, color: onPressed == null ? AppTheme.inkFaint : color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
