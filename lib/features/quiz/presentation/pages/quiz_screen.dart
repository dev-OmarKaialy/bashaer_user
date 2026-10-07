import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/services/dependencies.dart';
import '../../../../core/services/sfx/app_sfx.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_app_bar.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/race_confirm_dialog.dart';
import '../../../../core/widgets/race/race_loader.dart';
import '../../../../core/widgets/race/road_progress_bar.dart';
import '../../data/datasources/listen_mode_settings.dart';
import '../../data/datasources/quiz_narrator.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../widgets/answer_option_card.dart';
import '../widgets/listen_speak_button.dart';
import '../widgets/questions_grid_sheet.dart';
import '../widgets/quiz_network_image.dart';
import '../widgets/quiz_result_view.dart';
import '../widgets/quiz_timer.dart';
import '../widgets/spoken_highlight_text.dart';

/// Runs a quiz session: loads the given questions into a fresh [QuizBloc] and
/// switches between the answering flow and the result view.
class QuizScreen extends StatelessWidget {
  const QuizScreen({
    super.key,
    required this.questions,
    required this.mode,
    this.examTimeSeconds,
    this.title,
    this.allowExit = true,
    this.onFinished,
    this.finishLabel,
    this.finishIcon,
  });

  final List<QuestionModel> questions;
  final QuizMode mode;
  final int? examTimeSeconds;
  final String? title;

  /// When false the app bar drops the close button, so a session the student
  /// has to finish (the free trial) cannot be abandoned half way.
  final bool allowExit;

  /// Called when the result view's second action is tapped, instead of popping
  /// back to the first route. Null keeps the default behaviour.
  final VoidCallback? onFinished;

  /// Label and icon for that action, for flows that continue somewhere else.
  final String? finishLabel;
  final IconData? finishIcon;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgressBloc>.value(
      value: getIt<ProgressBloc>(),
      child: BlocProvider<QuizBloc>(
        create: (context) {
          final bloc = getIt<QuizBloc>();
          bloc.add(
            LoadQuizEvent(
              questions: questions,
              mode: mode,
              examTimeSeconds: examTimeSeconds,
              title: title,
            ),
          );
          return bloc;
        },
        child: QuizScreenBody(
          examTimeSeconds: examTimeSeconds ?? 0,
          title: title,
          allowExit: allowExit,
          onFinished: onFinished,
          finishLabel: finishLabel,
          finishIcon: finishIcon,
        ),
      ),
    );
  }
}

class QuizScreenBody extends StatefulWidget {
  const QuizScreenBody({
    super.key,
    required this.examTimeSeconds,
    this.title,
    this.allowExit = true,
    this.onFinished,
    this.finishLabel,
    this.finishIcon,
  });

  final int examTimeSeconds;
  final String? title;
  final bool allowExit;
  final VoidCallback? onFinished;
  final String? finishLabel;
  final IconData? finishIcon;

  @override
  State<QuizScreenBody> createState() => _QuizScreenBodyState();
}

class _QuizScreenBodyState extends State<QuizScreenBody> {
  @override
  void dispose() {
    getIt<QuizNarrator>().stop();
    getIt<AppSfx>().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listenWhen: (previous, current) =>
          previous.phase != QuizPhase.results && current.phase == QuizPhase.results,
      listener: (context, state) {
        getIt<QuizNarrator>().stop();
        getIt<AppSfx>().playFireworks();
        if (!state.isExam) return;
        final outcome = state.outcome;
        if (outcome == null) return;
        final timeUsed = state.remainingSeconds == 0
            ? widget.examTimeSeconds
            : widget.examTimeSeconds - state.remainingSeconds;
        final total = state.totalQuestions;
        final result = QuizResultModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          examTitle: state.examTitle ?? widget.title ?? 'exam.title'.tr(),
          dateTime: DateTime.now().millisecondsSinceEpoch,
          totalQuestions: total,
          answered: outcome.answered,
          correct: outcome.correct,
          wrong: outcome.wrong,
          unanswered: outcome.unanswered,
          totalTimeSeconds: widget.examTimeSeconds,
          timeUsedSeconds: timeUsed,
          passingScore: (total * 0.6).ceil(),
          passed: outcome.correct >= (total * 0.6).ceil(),
        );
        context.read<ProgressBloc>().add(SaveResultProgressEvent(result: result));
      },
      child: BlocListener<QuizBloc, QuizState>(
        listenWhen: (previous, current) {
          if (previous.phase != QuizPhase.answering) return false;
          if (current.phase != QuizPhase.answering) return false;
          return current.selectionSerial != previous.selectionSerial;
        },
        listener: (context, state) async {
          final question = state.currentQuestion;
          if (question == null || !state.isPractice) return;
          final correct = state.isCorrect(question.id);
          final sfx = getIt<AppSfx>();
          final sounds = <Future<void>>[correct ? sfx.playTick() : sfx.playWarning()];
          if (getIt<ListenModeSettings>().enabled) {
            sounds.add(getIt<QuizNarrator>().speakFeedback(correct: correct));
          }
          try {
            await Future.wait(sounds);
          } catch (_) {}
          // When answered correctly: let the sounds finish, wait one second,
          // then auto-advance — unless the user already moved on or the
          // question has left the answering flow.
          if (!correct) return;
          await Future<void>.delayed(const Duration(seconds: 1));
          if (!context.mounted) return;
          final bloc = context.read<QuizBloc>();
          final current = bloc.state;
          if (current.phase != QuizPhase.answering) return;
          if (current.currentQuestion?.id != question.id) return;
          if (!current.isCorrect(question.id)) return;
          if (current.currentIndex >= current.totalQuestions - 1) return;
          bloc.add(const NextQuestionEvent());
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 8),
            child: BlocBuilder<QuizBloc, QuizState>(
              buildWhen: (prev, curr) =>
                  prev.mode != curr.mode ||
                  prev.examTitle != curr.examTitle ||
                  prev.phase != curr.phase,
              builder: (context, state) => RaceAppBar(
                showBack: widget.allowExit,
                title: state.isExam
                    ? (state.examTitle ?? 'exam.title'.tr())
                    : (widget.title ?? 'quiz.practice'.tr()),
                leading: widget.allowExit
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: RaceIconButton(
                          icon: Icons.close_rounded,
                          tooltip: 'quiz.close'.tr(),
                          onPressed: () => Navigator.pop(context),
                        ),
                      )
                    : null,
                actions: [
                  if (state.isExam) ...[const QuizTimer(), SizedBox(width: 4.w)],
                  if (state.phase == QuizPhase.answering) ...[
                    RaceIconButton(
                      icon: Icons.grid_view_rounded,
                      tooltip: 'quiz.grid'.tr(),
                      onPressed: () => const QuestionsGridSheet().open(context),
                    ),
                    const BookmarkToggleButton(),
                  ],
                ],
              ),
            ),
          ),
          body: BlocBuilder<QuizBloc, QuizState>(
            buildWhen: (prev, curr) => prev.phase != curr.phase,
            builder: (context, state) => AnimatedSwitcher(
              duration: AppTheme.animationNormal,
              child: switch (state.phase) {
                QuizPhase.loading => const RaceLoader(key: ValueKey('loading')),
                QuizPhase.results => QuizResultView(
                  key: const ValueKey('results'),
                  onFinished: widget.onFinished,
                  finishLabel: widget.finishLabel,
                  finishIcon: widget.finishIcon,
                ),
                QuizPhase.answering => const _AnsweringLayout(key: ValueKey('answering')),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Persisted bookmark toggle for the current question.
class BookmarkToggleButton extends StatelessWidget {
  const BookmarkToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<QuizBloc, QuizState, String?>(
      selector: (state) => state.currentQuestion?.id,
      builder: (context, questionId) {
        return BlocSelector<ProgressBloc, ProgressState, Set<String>>(
          selector: (state) => state.bookmarkedIds,
          builder: (context, bookmarkedIds) {
            final isSaved = questionId != null && bookmarkedIds.contains(questionId);
            return RaceIconButton(
              icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
              color: isSaved ? AppTheme.turboOrange : AppTheme.ink,
              background: isSaved ? AppTheme.warningBackgroundColor : AppTheme.cardSurface,
              tooltip: isSaved ? 'quiz.removeBookmark'.tr() : 'quiz.addBookmark'.tr(),
              onPressed: questionId == null
                  ? null
                  : () => context.read<ProgressBloc>().add(
                      ToggleBookmarkFromProgress(questionId: questionId),
                    ),
            );
          },
        );
      },
    );
  }
}

class _AnsweringLayout extends StatefulWidget {
  const _AnsweringLayout({super.key});

  @override
  State<_AnsweringLayout> createState() => _AnsweringLayoutState();
}

class _AnsweringLayoutState extends State<_AnsweringLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  void _speakCurrent() {
    if (!mounted) return;
    if (!getIt<ListenModeSettings>().enabled) return;
    final question = context.read<QuizBloc>().state.currentQuestion;
    if (question == null) return;
    getIt<QuizNarrator>().speakQuestion(question);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listenWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
      listener: (context, state) {
        if (!getIt<ListenModeSettings>().enabled) return;
        final question = state.currentQuestion;
        if (question == null) return;
        getIt<QuizNarrator>().speakQuestion(question);
      },
      child: Column(
        children: [
          const _SessionProgress(),
          SizedBox(height: 12.h),
          Expanded(
            child: BlocBuilder<QuizBloc, QuizState>(
              buildWhen: (prev, curr) =>
                  prev.currentIndex != curr.currentIndex ||
                  prev.selectedAnswers != curr.selectedAnswers,
              builder: (context, state) {
                final question = state.currentQuestion;
                if (question == null) return const SizedBox.shrink();
                return _SwipeNavigator(
                  child: AnimatedSwitcher(
                    duration: AppTheme.animationNormal,
                    switchInCurve: AppTheme.slideCurve,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: SingleChildScrollView(
                      key: ValueKey(question.id),
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _QuestionCard(),
                          if (state.isPractice) const _PracticeFeedback(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const _BottomActions(),
        ],
      ),
    );
  }
}

/// Horizontal swipe to move between questions, following reading direction.
class _SwipeNavigator extends StatelessWidget {
  const _SwipeNavigator({required this.child});

  final Widget child;

  static const double _minVelocity = 350;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < _minVelocity) return;
        final bloc = context.read<QuizBloc>();
        final state = bloc.state;
        final forward = isRtl ? velocity > 0 : velocity < 0;
        final nextUnlocked = state.currentIndex < state.maxUnlockedIndex;
        if (forward && nextUnlocked) {
          bloc.add(const NextQuestionEvent());
        } else if (!forward && state.currentIndex > 0) {
          bloc.add(const PreviousQuestionEvent());
        }
      },
      child: child,
    );
  }
}

class _SessionProgress extends StatelessWidget {
  const _SessionProgress();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
      child: BlocBuilder<QuizBloc, QuizState>(
        buildWhen: (prev, curr) =>
            prev.currentIndex != curr.currentIndex ||
            prev.questions != curr.questions ||
            prev.selectedAnswers != curr.selectedAnswers,
        builder: (context, state) {
          final total = state.totalQuestions;
          final progress = total == 0 ? 0.0 : (state.currentIndex + 1) / total;
          final answered = state.selectedAnswers.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'quiz.question'.tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: AppTheme.inkSoft),
                  ),
                  SizedBox(width: 6.w),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${state.currentIndex + 1}',
                            style: AppTheme.numberStyle(20.sp, color: AppTheme.nitroBlue),
                          ),
                          TextSpan(
                            text: ' / $total',
                            style: AppTheme.numberStyle(14.sp, color: AppTheme.inkFaint),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  RaceTag(
                    label: '${'quiz.answered'.tr()} $answered/$total',
                    color: AppTheme.mintGreen,
                    icon: Icons.check_circle_rounded,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              RoadProgressBar(progress: progress),
            ],
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(
      buildWhen: (prev, curr) =>
          prev.currentIndex != curr.currentIndex || prev.questions != curr.questions,
      builder: (context, state) {
        final question = state.currentQuestion!;
        final narrator = getIt<QuizNarrator>();
        return ListenableBuilder(
          listenable: narrator,
          builder: (context, _) {
            final promptActive =
                narrator.isSpeaking &&
                narrator.questionId == question.id &&
                narrator.focus == NarrationFocus.prompt;
            return RaceCard(
              radius: AppTheme.radiusXL,
              padding: EdgeInsets.all(16.r),
              borderColor: promptActive ? AppTheme.nitroBlue : null,
              glowColor: promptActive ? AppTheme.nitroBlue : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      RaceTag(
                        label: question.type == QuestionType.trueFalse
                            ? 'quiz.trueFalse'.tr()
                            : question.type == QuestionType.multipleChoice
                            ? 'quiz.multipleChoice'.tr()
                            : 'quiz.singleChoice'.tr(),
                        color: AppTheme.electricViolet,
                        icon: question.type == QuestionType.multipleChoice
                            ? Icons.checklist_rounded
                            : Icons.radio_button_checked_rounded,
                      ),
                      const Spacer(),
                      ListenSpeakButton(question: question),
                      if (question.points > 1) ...[
                        SizedBox(width: 8.w),
                        RaceTag(
                          label: '${question.points} ${'quiz.points'.tr()}',
                          color: AppTheme.turboOrange,
                          icon: Icons.star_rounded,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 14.h),
                  if (question.image != null && question.image!.isNotEmpty) ...[
                    QuizNetworkImage(
                      url: question.image!,
                      height: 200.h,
                      semanticLabel: question.title,
                    ),
                    SizedBox(height: 14.h),
                  ],
                  AnimatedContainer(
                    duration: AppTheme.animationNormal,
                    curve: AppTheme.animationCurve,
                    padding: EdgeInsets.all(promptActive ? 10.r : 0),
                    decoration: promptActive
                        ? BoxDecoration(
                            color: AppTheme.nitroBlue.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM.r),
                            border: Border.all(color: AppTheme.nitroBlue.withValues(alpha: 0.45)),
                          )
                        : const BoxDecoration(),
                    child: promptActive
                        ? SpokenHighlightText(
                            text: narrator.displayText,
                            style: Theme.of(context).textTheme.headlineSmall,
                            active: true,
                            highlightStart: narrator.highlightStart,
                            highlightEnd: narrator.highlightEnd,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                question.title,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (question.description != null) ...[
                                SizedBox(height: 8.h),
                                Text(
                                  question.description!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.inkSoft),
                                ),
                              ],
                            ],
                          ),
                  ),
                  SizedBox(height: 18.h),
                  for (var i = 0; i < question.answers.length; i++) ...[
                    Entrance(
                      index: i,
                      offsetY: 0.2,
                      child: _AnswerOptionEntry(question: question, index: i),
                    ),
                    if (i < question.answers.length - 1) SizedBox(height: 10.h),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AnswerOptionEntry extends StatelessWidget {
  const _AnswerOptionEntry({required this.question, required this.index});

  final QuestionModel question;
  final int index;

  @override
  Widget build(BuildContext context) {
    final narrator = getIt<QuizNarrator>();
    return ListenableBuilder(
      listenable: narrator,
      builder: (context, _) {
        return BlocBuilder<QuizBloc, QuizState>(
          buildWhen: (prev, curr) => prev.selectedAnswers != curr.selectedAnswers,
          builder: (context, state) {
            final answer = question.answers[index];
            final selected = state.selectionsOf(question.id).contains(answer.id);
            final showFeedback =
                state.isPractice && question.isAnswered(state.selectionsOf(question.id));
            final isCorrectAnswer = question.correctAnswerIds.contains(answer.id);
            final listening =
                narrator.isSpeaking &&
                narrator.questionId == question.id &&
                narrator.focus == NarrationFocus.answer &&
                narrator.answerIndex == index;
            return AnswerOptionCard(
              answer: answer,
              answerIndex: index,
              selected: selected,
              showFeedback: showFeedback,
              isCorrectAnswer: isCorrectAnswer,
              revealCorrect: state.isCorrect(question.id),
              listening: listening,
              highlightStart: listening ? narrator.highlightStart : 0,
              highlightEnd: listening ? narrator.highlightEnd : 0,
              onTap: () => context.read<QuizBloc>().add(
                SelectAnswerEvent(questionId: question.id, answerId: answer.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _PracticeFeedback extends StatelessWidget {
  const _PracticeFeedback();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(
      buildWhen: (prev, curr) =>
          prev.correctnessByQuestion != curr.correctnessByQuestion ||
          prev.selectedAnswers != curr.selectedAnswers,
      builder: (context, state) {
        final question = state.currentQuestion;
        if (question == null) return const SizedBox.shrink();
        if (!question.isAnswered(state.selectionsOf(question.id))) return const SizedBox.shrink();

        final isCorrect = state.isCorrect(question.id);
        final color = isCorrect ? AppTheme.successColor : AppTheme.dangerColor;
        final bg = isCorrect ? AppTheme.successBackgroundColor : AppTheme.dangerBackgroundColor;

        return Padding(
          padding: EdgeInsets.only(top: 14.h),
          child: Entrance(
            key: ValueKey('${question.id}-$isCorrect'),
            scale: true,
            child: RaceCard(
              color: bg,
              borderColor: color.withValues(alpha: 0.35),
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AppLottie(
                        asset: isCorrect ? LottieAssets.correct : LottieAssets.wrong,
                        size: 52.r,
                        repeat: false,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          isCorrect ? 'quiz.correct'.tr() : 'quiz.wrong'.tr(),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color),
                        ),
                      ),
                    ],
                  ),
                  if (isCorrect && question.explanation != null) ...[
                    SizedBox(height: 6.h),
                    Text(question.explanation!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL.r)),
        boxShadow: AppTheme.elevatedCardShadow,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        child: BlocBuilder<QuizBloc, QuizState>(
          buildWhen: (prev, curr) =>
              prev.currentIndex != curr.currentIndex ||
              prev.questions != curr.questions ||
              prev.mode != curr.mode ||
              prev.selectedAnswers != curr.selectedAnswers ||
              prev.correctnessByQuestion != curr.correctnessByQuestion,
          builder: (context, state) {
            final atFirst = state.currentIndex == 0;
            final atLast = state.currentIndex == state.totalQuestions - 1;
            final nextLocked = state.currentIndex >= state.maxUnlockedIndex;

            return Row(
              children: [
                Expanded(
                  child: RaceButton(
                    label: 'quiz.previous'.tr(),
                    icon: Icons.arrow_back_rounded,
                    variant: RaceButtonVariant.soft,
                    gradient: AppTheme.grapeGradient,
                    dense: true,
                    onPressed: atFirst
                        ? null
                        : () => context.read<QuizBloc>().add(const PreviousQuestionEvent()),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: state.isExam
                      ? RaceButton(
                          label: 'quiz.submit'.tr(),
                          icon: Icons.sports_score_rounded,
                          gradient: AppTheme.sunsetGradient,
                          dense: true,
                          onPressed: () {
                            final unanswered = state.totalQuestions - state.selectedAnswers.length;
                            showRaceDialog<void>(
                              context: context,
                              builder: (_) => RaceConfirmDialog(
                                title: unanswered > 0
                                    ? 'exam.confirmUnanswered'.tr(
                                        namedArgs: {'count': '$unanswered'},
                                      )
                                    : 'exam.confirmSubmit'.tr(),
                                onConfirm: () =>
                                    context.read<QuizBloc>().add(const SubmitQuizEvent()),
                              ),
                            );
                          },
                        )
                      : RaceButton(
                          label: 'quiz.finish'.tr(),
                          icon: Icons.outlined_flag_rounded,
                          gradient: AppTheme.limeGradient,
                          dense: true,
                          onPressed: state.selectedAnswers.isEmpty
                              ? null
                              : () {
                                  showRaceDialog<void>(
                                    context: context,
                                    builder: (_) => RaceConfirmDialog(
                                      title: 'practice.confirmFinish'.tr(),
                                      gradient: AppTheme.limeGradient,
                                      onConfirm: () =>
                                          context.read<QuizBloc>().add(const SubmitQuizEvent()),
                                    ),
                                  );
                                },
                        ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: RaceButton(
                    label: 'quiz.next'.tr(),
                    icon: Icons.arrow_forward_rounded,
                    variant: RaceButtonVariant.soft,
                    gradient: AppTheme.oceanGradient,
                    dense: true,
                    onPressed: atLast || nextLocked
                        ? null
                        : () => context.read<QuizBloc>().add(const NextQuestionEvent()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
