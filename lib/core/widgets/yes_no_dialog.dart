import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';

class YesNoDialog extends StatelessWidget {
  const YesNoDialog({
    super.key,
    required this.title,
    required this.onTapYes,
    this.onTapNo,
    this.yesTitle,
    this.noTitle,
  });

  final String title;
  final VoidCallback onTapYes;
  final VoidCallback? onTapNo;
  final String? yesTitle;
  final String? noTitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child:
          _DialogContent(
                title: title,
                onTapYes: onTapYes,
                onTapNo: onTapNo,
                yesTitle: yesTitle,
                noTitle: noTitle,
              )
              .animate() // Animate the dialog content
              .fade(duration: 300.ms)
              .slideY(begin: 0.2, curve: Curves.easeOut),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent({
    required this.title,
    required this.onTapYes,
    this.onTapNo,
    this.yesTitle,
    this.noTitle,
  });

  final String title;
  final VoidCallback onTapYes;
  final VoidCallback? onTapNo;
  final String? yesTitle;
  final String? noTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.8.sw,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 7,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium,
          ),
          24.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DialogButton(
                title: noTitle ?? "لا",
                backgroundColor: context.scaffoldBackgroundColor,
                borderColor: context.primaryColor,
                textColor: context.primaryColor,
                onTap: () {
                  onTapNo?.call();
                  Navigator.pop(context);
                },
              ),
              _DialogButton(
                title: yesTitle ?? 'نعم',
                backgroundColor: context.primaryColor,
                textColor: context.scaffoldBackgroundColor,
                onTap: () {
                  Navigator.pop(context);
                  onTapYes();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.title,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final String title;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
