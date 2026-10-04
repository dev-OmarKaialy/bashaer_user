import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_theme.dart';
import 'pressable.dart';

/// White rounded surface with a soft shadow. Pass [onTap] to make it a
/// pressable card, or [gradient] for a bold colored hero card.
class RaceCard extends StatelessWidget {
  const RaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.gradient,
    this.color = AppTheme.cardSurface,
    this.radius = AppTheme.radiusL,
    this.borderColor,
    this.glowColor,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color color;
  final double radius;
  final Color? borderColor;
  final Color? glowColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius.r),
        border: borderColor == null ? null : Border.all(color: borderColor!, width: 1.5),
        boxShadow: glowColor != null
            ? AppTheme.glowShadow(glowColor!, strength: 0.8)
            : AppTheme.cardShadow,
      ),
      child: Padding(padding: padding ?? EdgeInsets.all(16.r), child: child),
    );
    if (onTap == null) return card;
    return Pressable(onTap: onTap, pressedScale: 0.97, semanticLabel: semanticLabel, child: card);
  }
}

/// Rounded gradient "badge" holding an icon, used as a card leading visual.
class GradientIconBadge extends StatelessWidget {
  const GradientIconBadge({
    super.key,
    required this.gradient,
    this.icon,
    this.child,
    this.size = 52,
    this.iconColor = AppTheme.onPrimaryColor,
  });

  final LinearGradient gradient;
  final IconData? icon;

  /// Custom icon widget (e.g. a Font Awesome icon); takes precedence over [icon].
  final Widget? child;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular((size * 0.32).r),
        boxShadow: AppTheme.glowShadow(gradient.colors.first, strength: 0.45),
      ),
      child: SizedBox(
        width: size.r,
        height: size.r,
        child: Center(
          child: child ?? Icon(icon, color: iconColor, size: (size * 0.5).r),
        ),
      ),
    );
  }
}

/// Small colored capsule label ("chip").
class RaceTag extends StatelessWidget {
  const RaceTag({super.key, required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 14.r, color: color), SizedBox(width: 4.w)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section title with a short colored "lane" marker.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.color = AppTheme.turboOrange});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
          child: SizedBox(width: 6.w, height: 22.h),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
      ],
    );
  }
}
