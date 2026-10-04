import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_theme.dart';
import 'race_button.dart';
import 'race_card.dart';

/// Pops in a dialog with a springy scale + fade over a tinted barrier.
Future<T?> showRaceDialog<T>({required BuildContext context, required WidgetBuilder builder}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppTheme.ink.withValues(alpha: 0.45),
    transitionDuration: AppTheme.animationNormal,
    pageBuilder: (context, _, _) => builder(context),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: AppTheme.springCurve);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Yes / no confirmation styled as a "pit stop" card.
class RaceConfirmDialog extends StatelessWidget {
  const RaceConfirmDialog({
    super.key,
    required this.title,
    required this.onConfirm,
    this.icon = Icons.sports_score_rounded,
    this.gradient = AppTheme.sunsetGradient,
    this.confirmLabel,
    this.cancelLabel,
  });

  final String title;
  final VoidCallback onConfirm;
  final IconData icon;
  final LinearGradient gradient;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Material(
            type: MaterialType.transparency,
            child: RaceCard(
              radius: AppTheme.radiusXL,
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientIconBadge(gradient: gradient, icon: icon, size: 64),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    children: [
                      Expanded(
                        child: RaceButton(
                          label: cancelLabel ?? 'common.no'.tr(),
                          variant: RaceButtonVariant.soft,
                          gradient: AppTheme.grapeGradient,
                          dense: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: RaceButton(
                          label: confirmLabel ?? 'common.yes'.tr(),
                          gradient: gradient,
                          dense: true,
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
