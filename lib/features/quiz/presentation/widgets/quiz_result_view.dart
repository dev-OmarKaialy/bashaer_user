import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/animated_count.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../../../../core/widgets/race/checkered_flag.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/speed_gauge.dart';
import '../../data/datasources/listen_mode_settings.dart';
import '../../data/datasources/quiz_narrator.dart';
import '../../data/models/question_model.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import 'quiz_network_image.dart';

/// The finish line after submitting a practice or an exam session: score
/// gauge, pass/fail verdict with celebration, and a review of every question.
class QuizResultView extends StatelessWidget {
  const QuizResultView({super.key, this.onFinished, this.finishLabel, this.finishIcon});

  /// When set, the second action calls this instead of popping back to the
  /// first route — used by the free trial to continue into the subscribe
  /// screen.
  final VoidCallback? onFinished;

  /// Label for that second action. Defaults to the localized "home" wording.
  final String? finishLabel;

  final IconData? finishIcon;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(
      buildWhen: (prev, curr) =>
          prev.outcome != curr.outcome ||
          prev.questions != curr.questions ||
          prev.mode != curr.mode,
      builder: (context, state) {
        final outcome = state.outcome;
        if (outcome == null) return const SizedBox.shrink();

        final total = state.totalQuestions;
        final score = total == 0 ? 0.0 : (outcome.correct / total) * 100;
        final passed = total == 0 || outcome.correct >= (total * 0.6).ceil();

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              sliver: SliverList.list(
                children: [
                  Entrance(
                    scale: true,
                    child: _ResultHero(score: score, passed: passed, isExam: state.isExam),
                  ),
                  SizedBox(height: 18.h),
                  Entrance(index: 1, child: _SummaryTiles(outcome: outcome)),
                  SizedBox(height: 26.h),
                  SectionHeader(
                    title: state.isExam ? 'result.reviewExam'.tr() : 'result.reviewPractice'.tr(),
                    color: AppTheme.nitroBlue,
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList.builder(
                itemCount: state.questions.length,
                itemBuilder: (context, i) => Entrance(
                  index: i,
                  child: _ReviewTile(index: i),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: RaceButton(
                        label: 'result.retry'.tr(),
                        icon: Icons.replay_rounded,
                        gradient: AppTheme.sunsetGradient,
                        onPressed: () => context.read<QuizBloc>().add(const RestartQuizEvent()),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: RaceButton(
                        label: finishLabel ?? 'result.home'.tr(),
                        icon: finishIcon ?? Icons.home_rounded,
                        variant: RaceButtonVariant.outline,
                        gradient: AppTheme.grapeGradient,
                        onPressed:
                            onFinished ??
                            () => Navigator.of(context).popUntil((route) => route.isFirst),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.score, required this.passed, required this.isExam});

  final double score;
  final bool passed;
  final bool isExam;

  @override
  Widget build(BuildContext context) {
    final gradient = !isExam
        ? AppTheme.heroGradient
        : passed
        ? AppTheme.limeGradient
        : AppTheme.dangerGradient;
    final headline = isExam
        ? (passed ? 'result.passed'.tr() : 'result.failed'.tr())
        : 'result.practiceDone'.tr();
    final message = passed ? 'result.passedMessage'.tr() : 'result.failedMessage'.tr();
    final lottie = isExam ? (passed ? LottieAssets.trophy : LottieAssets.fail) : LottieAssets.medal;

    return Stack(
      children: [
        RaceCard(
          gradient: gradient,
          glowColor: gradient.colors.first,
          radius: AppTheme.radiusXXL,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL.r)),
                child: CheckeredStrip(
                  squareSize: 10.r,
                  color: AppTheme.onPrimaryColor,
                  opacity: 0.35,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppLottie(asset: lottie, size: 110.r, repeat: false),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headline,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge?.copyWith(color: AppTheme.onPrimaryColor),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                message,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.onPrimaryColor.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    SpeedGauge(value: score, label: 'result.score'.tr(), size: 190, onDark: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (passed)
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusXXL.r),
                child: const AppLottie(
                  asset: LottieAssets.confetti,
                  repeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryTiles extends StatelessWidget {
  const _SummaryTiles({required this.outcome});

  final QuizOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'result.answered'.tr(), value: outcome.answered, gradient: AppTheme.oceanGradient),
      (label: 'result.correct'.tr(), value: outcome.correct, gradient: AppTheme.limeGradient),
      (label: 'result.wrong'.tr(), value: outcome.wrong, gradient: AppTheme.dangerGradient),
      (label: 'result.unanswered'.tr(), value: outcome.unanswered, gradient: AppTheme.goldGradient),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          Expanded(
            child: RaceCard(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: items[i].gradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: SizedBox(width: 26.w, height: 5.h),
                  ),
                  SizedBox(height: 8.h),
                  AnimatedCount(
                    value: items[i].value,
                    style: AppTheme.numberStyle(22.sp, color: items[i].gradient.colors.first),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    items[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<QuizBloc, QuizState, QuestionModel>(
      selector: (state) => state.questions[index],
      builder: (context, question) {
        return BlocSelector<QuizBloc, QuizState, Set<String>>(
          selector: (state) => state.selectionsOf(question.id),
          builder: (context, selected) {
            final isCorrect = question.isSelectionCorrect(selected);
            final isUnanswered = selected.isEmpty;
            final statusColor = isCorrect
                ? AppTheme.successColor
                : isUnanswered
                ? AppTheme.neutralColor
                : AppTheme.dangerColor;

            final correctText = question.answers
                .where((a) => question.correctAnswerIds.contains(a.id))
                .map((a) => a.text)
                .join(' — ');

            final userText = selected
                .map((id) => question.answers.where((a) => a.id == id).map((a) => a.text).join())
                .join(' — ');

            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: RaceCard(
                onTap: getIt<ListenModeSettings>().enabled
                    ? () => getIt<QuizNarrator>().speakQuestion(question)
                    : null,
                semanticLabel: getIt<ListenModeSettings>().enabled
                    ? 'result.tapToHear'.tr()
                    : question.title,
                padding: EdgeInsets.zero,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadiusDirectional.horizontal(
                            start: Radius.circular(AppTheme.radiusL.r),
                          ),
                        ),
                        child: SizedBox(width: 6.w),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(14.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}',
                                    style: AppTheme.numberStyle(16.sp, color: statusColor),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (question.image != null &&
                                            question.image!.isNotEmpty) ...[
                                          QuizNetworkImage(
                                            url: question.image!,
                                            height: 72.h,
                                            fit: BoxFit.contain,
                                          ),
                                          SizedBox(height: 8.h),
                                        ],
                                        Text(
                                          question.title,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle_rounded
                                        : isUnanswered
                                        ? Icons.remove_circle_outline_rounded
                                        : Icons.cancel_rounded,
                                    size: 22.r,
                                    color: statusColor,
                                  ),
                                  if (getIt<ListenModeSettings>().enabled) ...[
                                    SizedBox(width: 6.w),
                                    Icon(
                                      Icons.volume_up_rounded,
                                      size: 20.r,
                                      color: AppTheme.nitroBlue,
                                    ),
                                  ],
                                ],
                              ),
                              if (!isCorrect) ...[
                                SizedBox(height: 10.h),
                                if (userText.isNotEmpty)
                                  _AnswerLine(
                                    label: 'result.yourAnswer'.tr(),
                                    text: userText,
                                    color: AppTheme.dangerColor,
                                    icon: Icons.close_rounded,
                                  ),
                                _AnswerLine(
                                  label: 'result.correctAnswer'.tr(),
                                  text: correctText,
                                  color: AppTheme.successColor,
                                  icon: Icons.check_rounded,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.text,
    required this.color,
    required this.icon,
  });

  final String label;
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusS.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16.r, color: color),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '$label: $text',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
