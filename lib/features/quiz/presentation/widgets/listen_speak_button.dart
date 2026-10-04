import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/pressable.dart';
import '../../data/datasources/quiz_narrator.dart';
import '../../data/models/question_model.dart';

/// Large speaker control used on quiz cards (replay / stop).
class ListenSpeakButton extends StatelessWidget {
  const ListenSpeakButton({super.key, required this.question});

  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    final narrator = getIt<QuizNarrator>();
    return ListenableBuilder(
      listenable: narrator,
      builder: (context, _) {
        final speaking = narrator.isSpeaking;
        final label = speaking ? 'quiz.stopSpeak'.tr() : 'quiz.speak'.tr();
        return Tooltip(
          message: label,
          child: Pressable(
            onTap: () {
              if (speaking) {
                narrator.stop();
              } else {
                narrator.speakQuestion(question);
              }
            },
            semanticLabel: label,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: speaking ? AppTheme.nitroBlue.withValues(alpha: 0.18) : AppTheme.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: speaking ? AppTheme.nitroBlue : AppTheme.inkFaint.withValues(alpha: 0.35),
                ),
                boxShadow: AppTheme.elevatedCardShadow,
              ),
              child: SizedBox(
                width: 48.r,
                height: 48.r,
                child: Icon(
                  speaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                  color: speaking ? AppTheme.nitroBlue : AppTheme.inkSoft,
                  size: 26.r,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
