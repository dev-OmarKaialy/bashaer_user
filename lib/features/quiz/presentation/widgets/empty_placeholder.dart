import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_card.dart';

/// Friendly empty state used by list screens (no data yet / no results).
class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Entrance(
          scale: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppLottie(asset: LottieAssets.empty, size: 190.r),
                  PositionedDirectional(
                    bottom: 8.r,
                    end: 8.r,
                    child: GradientIconBadge(
                      gradient: AppTheme.sunsetGradient,
                      icon: icon,
                      size: 48,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
