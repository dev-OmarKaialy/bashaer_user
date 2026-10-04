import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/pressable.dart';
import '../../data/models/question_model.dart';
import 'quiz_network_image.dart';
import 'spoken_highlight_text.dart';

/// A single answer choice. In practice mode an answered question reveals the
/// correct answer (green) only when the selection itself is correct — a wrong
/// pick is marked red (with a shake) but never shows which option was right,
/// so the user keeps trying. In exam mode all options stay neutral until
/// submission.
class AnswerOptionCard extends StatelessWidget {
  const AnswerOptionCard({
    super.key,
    required this.answer,
    required this.answerIndex,
    required this.selected,
    required this.showFeedback,
    required this.isCorrectAnswer,
    required this.onTap,
    this.revealCorrect = false,
    this.listening = false,
    this.highlightStart = 0,
    this.highlightEnd = 0,
  });

  final AnswerModel answer;
  final int answerIndex;
  final bool selected;
  final bool showFeedback;
  final bool isCorrectAnswer;
  final VoidCallback onTap;

  /// When true (only on a fully correct practice selection) the correct option
  /// is highlighted green after feedback.
  final bool revealCorrect;

  /// True while TTS is reading this option.
  final bool listening;
  final int highlightStart;
  final int highlightEnd;

  @override
  Widget build(BuildContext context) {
    final highlightCorrect = showFeedback && revealCorrect && isCorrectAnswer;
    final highlightWrong = showFeedback && selected && !isCorrectAnswer;
    final accent = AppTheme.accentGradientAt(answerIndex);

    final Color borderColor;
    final Color background;
    if (highlightCorrect) {
      borderColor = AppTheme.successColor;
      background = AppTheme.successBackgroundColor;
    } else if (highlightWrong) {
      borderColor = AppTheme.dangerColor;
      background = AppTheme.dangerBackgroundColor;
    } else if (listening) {
      borderColor = AppTheme.nitroBlue;
      background = AppTheme.nitroBlue.withValues(alpha: 0.08);
    } else if (selected) {
      borderColor = accent.colors.first;
      background = accent.colors.first.withValues(alpha: 0.08);
    } else {
      borderColor = AppTheme.divider;
      background = AppTheme.cardSurface;
    }

    final badgeGradient = highlightCorrect
        ? AppTheme.limeGradient
        : highlightWrong
        ? AppTheme.dangerGradient
        : listening
        ? AppTheme.oceanGradient
        : accent;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final emphasize = selected || showFeedback || listening;

    final card = AnimatedContainer(
      duration: AppTheme.animationNormal,
      curve: AppTheme.animationCurve,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusM.r),
        border: Border.all(color: borderColor, width: emphasize ? 2 : 1.4),
        boxShadow: listening
            ? AppTheme.glowShadow(AppTheme.nitroBlue, strength: 0.45)
            : selected && !showFeedback
            ? AppTheme.glowShadow(accent.colors.first, strength: 0.35)
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AppTheme.animationNormal,
            width: 38.r,
            height: 38.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: selected || highlightCorrect || listening ? badgeGradient : null,
              color: selected || highlightCorrect || listening
                  ? null
                  : accent.colors.first.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusS.r),
            ),
            child: Text(
              String.fromCharCode(0x0627 + answerIndex),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: selected || highlightCorrect || listening
                    ? AppTheme.onPrimaryColor
                    : accent.colors.first,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (answer.image != null && answer.image!.isNotEmpty) ...[
                  QuizNetworkImage(url: answer.image!, height: 72.h, fit: BoxFit.contain),
                  SizedBox(height: 8.h),
                ],
                SpokenHighlightText(
                  text: answer.text,
                  style: Theme.of(context).textTheme.bodyLarge,
                  active: listening,
                  highlightStart: highlightStart,
                  highlightEnd: highlightEnd,
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: AppTheme.animationNormal,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: AppTheme.springCurve),
              child: child,
            ),
            child: highlightCorrect
                ? Icon(
                    Icons.check_circle_rounded,
                    key: const ValueKey('correct'),
                    color: AppTheme.successColor,
                    size: 26.r,
                  )
                : highlightWrong
                ? Icon(
                    Icons.cancel_rounded,
                    key: const ValueKey('wrong'),
                    color: AppTheme.dangerColor,
                    size: 26.r,
                  )
                : listening
                ? Icon(
                    Icons.graphic_eq_rounded,
                    key: const ValueKey('listening'),
                    color: AppTheme.nitroBlue,
                    size: 24.r,
                  )
                : selected
                ? Icon(
                    Icons.radio_button_checked_rounded,
                    key: const ValueKey('selected'),
                    color: accent.colors.first,
                    size: 24.r,
                  )
                : SizedBox(key: const ValueKey('none'), width: 24.r),
          ),
        ],
      ),
    );

    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.98,
        child: reduceMotion
            ? card
            : card
                  .animate(target: highlightWrong ? 1 : 0)
                  .shakeX(hz: 5, amount: 6, duration: AppTheme.animationSlow),
      ),
    );
  }
}
