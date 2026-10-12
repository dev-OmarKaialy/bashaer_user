import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_card.dart';

/// Shown when every question of a training category is solved: the round's
/// score, then a choice between the next category (or the final results after
/// the last one) and finishing the session now. Back is blocked so a choice is
/// made.
class CategoryResultDialog extends StatelessWidget {
  const CategoryResultDialog({
    super.key,
    required this.categoryName,
    required this.categoryNumber,
    required this.categoryCount,
    required this.roundPoints,
    required this.correctAttempts,
    required this.totalAttempts,
    required this.sessionPoints,
    required this.onContinue,
    required this.onFinish,
  });

  final String categoryName;

  /// 1-based position of this category in the session.
  final int categoryNumber;
  final int categoryCount;

  /// Net points of this category: +1 per correct and −1 per wrong attempt.
  final int roundPoints;
  final int correctAttempts;
  final int totalAttempts;
  final int sessionPoints;

  /// Next category, or the session results after the last one.
  final VoidCallback onContinue;
  /// Ends the session here and shows its results.
  final VoidCallback onFinish;

  bool get _isLast => categoryNumber >= categoryCount;

  @override
  Widget build(BuildContext context) {
    final accuracy = totalAttempts == 0 ? 0 : (correctAttempts / totalAttempts * 100).round();
    final signedPoints = roundPoints > 0 ? '+$roundPoints' : '$roundPoints';
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Material(
              type: MaterialType.transparency,
              child: RaceCard(
                radius: AppTheme.radiusXL,
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLottie(asset: LottieAssets.medal, size: 96.r, repeat: false),
                      Text(
                        'training.categoryDone'.tr(),
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        categoryName,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(color: AppTheme.inkSoft),
                      ),
                      SizedBox(height: 6.h),
                      RaceTag(
                        label: 'training.categoryProgress'.tr(
                          namedArgs: {'current': '$categoryNumber', 'total': '$categoryCount'},
                        ),
                        color: AppTheme.nitroBlue,
                        icon: Icons.flag_rounded,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _Figure(
                              label: 'training.roundPoints'.tr(),
                              value: signedPoints,
                              color: roundPoints >= 0
                                  ? AppTheme.successColor
                                  : AppTheme.dangerColor,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _Figure(
                              label: 'training.correctAttempts'.tr(),
                              value: '$correctAttempts/$totalAttempts',
                              color: AppTheme.nitroBlue,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _Figure(
                              label: 'training.accuracy'.tr(),
                              value: '$accuracy%',
                              color: AppTheme.scoreColor(accuracy.toDouble()),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      RaceTag(
                        label: '${'training.sessionPoints'.tr()}: $sessionPoints',
                        color: AppTheme.turboOrange,
                        icon: Icons.star_rounded,
                      ),
                      SizedBox(height: 20.h),
                      RaceButton(
                        label: _isLast ? 'training.viewResults'.tr() : 'training.nextCategory'.tr(),
                        icon: _isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
                        gradient: AppTheme.limeGradient,
                        fullWidth: true,
                        onPressed: () {
                          Navigator.pop(context);
                          onContinue();
                        },
                      ),
                      // After the last category "View results" already ends it.
                      if (!_isLast) ...[
                        SizedBox(height: 10.h),
                        RaceButton(
                          label: 'training.finishNow'.tr(),
                          icon: Icons.sports_score_rounded,
                          variant: RaceButtonVariant.soft,
                          gradient: AppTheme.grapeGradient,
                          fullWidth: true,
                          onPressed: () {
                            Navigator.pop(context);
                            onFinish();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusM.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(value, style: AppTheme.numberStyle(18.sp, color: color)),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
