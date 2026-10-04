import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

/// Exam countdown. Owns a one-second [Timer] that only dispatches
/// [TickEvent]; the displayed value comes from the Bloc, so the timer is
/// disposed exactly once when the screen leaves.
class QuizTimer extends StatefulWidget {
  const QuizTimer({super.key});

  @override
  State<QuizTimer> createState() => _QuizTimerState();
}

class _QuizTimerState extends State<QuizTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (context.read<QuizBloc>().isClosed) return;
      context.read<QuizBloc>().add(const TickEvent());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<QuizBloc, QuizState, int>(
      selector: (state) => state.remainingSeconds,
      builder: (context, remaining) {
        final isLow = remaining <= 60;
        final gradient = isLow ? AppTheme.dangerGradient : AppTheme.grapeGradient;
        final pill = DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            boxShadow: AppTheme.glowShadow(gradient.colors.first, strength: 0.4),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_rounded, size: 16.r, color: AppTheme.onPrimaryColor),
                SizedBox(width: 4.w),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    _format(remaining),
                    style: AppTheme.numberStyle(15.sp, color: AppTheme.onPrimaryColor),
                  ),
                ),
              ],
            ),
          ),
        );
        if (!isLow || MediaQuery.disableAnimationsOf(context)) return pill;
        return pill
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 1, end: 1.08, duration: 500.ms, curve: Curves.easeInOut);
      },
    );
  }
}
