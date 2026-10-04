import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';
import '../extensions/widget_extensions.dart';
import '../theme/app_theme.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    this.eleavation,
    required this.text,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textColor,
    required this.onPressed,
    this.borderRadius,
    this.shadowColor,
    this.borderColor,
    this.innerBorderColor,
    this.hasBorder = false,
    this.icon,
    this.fontFamily,
  });
  final double? eleavation;
  final String text;
  final double? width;
  final double? height;
  final double? fontSize;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onPressed;
  final BorderRadiusGeometry? borderRadius;
  final Color? shadowColor;
  final Color? borderColor;
  final Color? innerBorderColor;
  final Widget? icon;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusM),
              side: hasBorder
                  ? BorderSide(
                      width: 1.5,
                      color: borderColor ?? AppTheme.primaryColor.withOpacity(0.3),
                    )
                  : BorderSide.none,
            ),
            padding: EdgeInsets.zero,
            backgroundColor: color ?? Colors.transparent,
            elevation: eleavation ?? AppTheme.elevationM,
            fixedSize: Size(width ?? .2.sw, height ?? 48.h),
            disabledBackgroundColor: Colors.grey[300],
            shadowColor: AppTheme.primaryColor.withOpacity(0.3),
          ),
          onPressed: (onPressed != null)
              ? () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPressed!();
                }
              : null,
          child: Container(
            width: width ?? double.maxFinite,
            height: height ?? 48.h,
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusM),
              gradient: (color == null || color == AppTheme.primaryColor) && !hasBorder
                  ? const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.tertiaryColor],
                      tileMode: TileMode.mirror,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: hasBorder
                  ? innerBorderColor == null
                        ? Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                            right: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                            left: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                          )
                        : Border.all(color: innerBorderColor!)
                  : null,
            ),
            child: SizedBox(
              width: width,
              height: height ?? 48.h,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: AppTheme.spacingS)],
                    Text(
                      text,
                      maxLines: 1,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: textColor ?? AppTheme.onPrimaryColor,
                        fontFamily: fontFamily,
                        fontWeight: fontWeight ?? FontWeight.w600,
                        fontSize: fontSize ?? 16.sp,
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: AppTheme.spacingXL, vertical: AppTheme.spacingM),
              ),
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(0.98, 0.98),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        )
        .onTap(() {
          // Add subtle press animation
        });
  }
}
