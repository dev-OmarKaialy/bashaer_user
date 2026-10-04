import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../data/models/question_model.dart';
import 'quiz_network_image.dart';

/// One row in the bookmarks / mistakes lists: question title, category and a
/// shortcut to start a practice session from it.
class QuestionListTile extends StatelessWidget {
  const QuestionListTile({
    super.key,
    required this.question,
    required this.subtitle,
    required this.onTap,
    this.trailingIcon,
    this.trailingColor,
    this.countBadge,
  });

  final QuestionModel question;
  final String subtitle;
  final VoidCallback onTap;
  final IconData? trailingIcon;
  final Color? trailingColor;
  final String? countBadge;

  @override
  Widget build(BuildContext context) {
    final isTrueFalse = question.type == QuestionType.trueFalse;
    final accent = trailingColor ?? AppTheme.nitroBlue;
    return RaceCard(
      onTap: onTap,
      semanticLabel: question.title,
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          if (question.image != null && question.image!.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12.w),
              child: SizedBox(
                width: 56.r,
                height: 56.r,
                child: QuizNetworkImage(url: question.image!, fit: BoxFit.contain),
              ),
            )
          else
            GradientIconBadge(
              gradient: LinearGradient(
                colors: [accent, Color.lerp(accent, AppTheme.hotPink, 0.45)!],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              icon: trailingIcon ?? Icons.help_outline_rounded,
              size: 46,
            ),
          if (question.image == null || question.image!.isEmpty) SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (subtitle.isNotEmpty)
                      RaceTag(label: subtitle, color: AppTheme.electricViolet),
                    if (isTrueFalse)
                      RaceTag(
                        label: 'quiz.trueFalse'.tr(),
                        color: AppTheme.mintGreen,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    if (countBadge != null)
                      RaceTag(
                        label: '$countBadge ${'mistakes.times'.tr()}',
                        color: AppTheme.racingRed,
                        icon: Icons.replay_rounded,
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.arrow_forward_ios_rounded, size: 16.r, color: AppTheme.inkFaint),
        ],
      ),
    );
  }
}
