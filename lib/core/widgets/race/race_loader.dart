import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/lottie_assets.dart';
import '../../theme/app_theme.dart';
import 'app_lottie.dart';

/// Full-area loading state: a vehicle driving on a loop with an optional label.
class RaceLoader extends StatelessWidget {
  const RaceLoader({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLottie(asset: LottieAssets.driving, size: 200.r),
            if (label != null) ...[
              SizedBox(height: 8.h),
              Text(
                label!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.inkSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
