import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/dependencies.dart';
import '../../../../core/services/sfx/app_sfx.dart';
import '../../../../core/theme/app_theme.dart';

/// Shows race start lights (three reds, then green "GO") before an exam or
/// practice session. Resolves when the sequence ends or the user taps to skip.
/// Each red light plays a countdown beep; the green light plays the GO chime.
Future<void> showRaceStartLights(
  BuildContext context, {
  String? getReadyLabel,
  String? goLabel,
}) async {
  if (MediaQuery.disableAnimationsOf(context)) return;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppTheme.ink.withValues(alpha: 0.82),
    transitionDuration: AppTheme.animationFast,
    pageBuilder: (context, _, _) => _StartLights(getReadyLabel: getReadyLabel, goLabel: goLabel),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _StartLights extends StatefulWidget {
  const _StartLights({this.getReadyLabel, this.goLabel});

  final String? getReadyLabel;
  final String? goLabel;

  @override
  State<_StartLights> createState() => _StartLightsState();
}

class _StartLightsState extends State<_StartLights> with SingleTickerProviderStateMixin {
  static const int _redLights = 3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2300),
  );
  int _lastStage = 0;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _controller
      ..addListener(_onTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _close();
      })
      ..forward();
  }

  /// Stage 1–3: red lights on, stage 4: green.
  int get _stage => (_controller.value * 4.6).floor().clamp(0, _redLights + 1);

  void _onTick() {
    final stage = _stage;
    if (stage != _lastStage) {
      _lastStage = stage;
      final sfx = getIt<AppSfx>();
      if (stage > _redLights) {
        HapticFeedback.mediumImpact();
        unawaited(sfx.playGo());
      } else if (stage > 0) {
        HapticFeedback.lightImpact();
        unawaited(sfx.playCountdown());
      }
    }
  }

  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _close,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final stage = _stage;
              final isGo = stage > _redLights;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.asphalt,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL.r),
                      border: Border.all(color: AppTheme.inkSoft, width: 2),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 1; i <= _redLights; i++)
                              _Lamp(
                                color: isGo
                                    ? AppTheme.mintGreen
                                    : stage >= i
                                    ? AppTheme.racingRed
                                    : null,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  AnimatedScale(
                    scale: isGo ? 1.15 : 1,
                    duration: AppTheme.animationNormal,
                    curve: AppTheme.bounceCurve,
                    child: Text(
                      isGo
                          ? (widget.goLabel ?? 'exam.go'.tr())
                          : (widget.getReadyLabel ?? 'exam.getReady'.tr()),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: isGo ? AppTheme.mintGreen : AppTheme.onPrimaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'exam.tapToSkip'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onPrimaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Lamp extends StatelessWidget {
  const _Lamp({required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final lit = color != null;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: AnimatedContainer(
        duration: AppTheme.animationFast,
        width: 54.r,
        height: 54.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: lit ? color : AppTheme.ink,
          border: Border.all(color: AppTheme.inkSoft.withValues(alpha: 0.6), width: 3),
          boxShadow: lit
              ? [BoxShadow(color: color!.withValues(alpha: 0.75), blurRadius: 26, spreadRadius: 2)]
              : null,
        ),
      ),
    );
  }
}
