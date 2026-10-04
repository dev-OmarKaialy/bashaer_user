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
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LinearGradient gradient;
  final RaceButtonVariant variant;
  final bool shine;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final baseColor = gradient.colors.first;
    final isFilled = variant == RaceButtonVariant.filled;
    final foreground = !enabled
        ? AppTheme.inkFaint
        : isFilled
        ? AppTheme.onPrimaryColor
        : baseColor;

    final decoration = BoxDecoration(
      gradient: enabled && isFilled ? gradient : null,
      color: !enabled
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
      boxShadow: enabled && isFilled ? AppTheme.glowShadow(baseColor, strength: 0.7) : null,
    );

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: dense ? 42.h : 54.h),
      child: DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dense ? 14.w : 20.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: dense ? 18.r : 22.r),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: foreground,
                    fontSize: dense ? 13.sp : 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (shine && enabled && isFilled && !MediaQuery.disableAnimationsOf(context)) {
      content = content
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            delay: 1800.ms,
            duration: 1200.ms,
            color: AppTheme.onPrimaryColor.withValues(alpha: 0.35),
          );
    }

    return Pressable(onTap: onPressed, semanticLabel: label, child: content);
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
