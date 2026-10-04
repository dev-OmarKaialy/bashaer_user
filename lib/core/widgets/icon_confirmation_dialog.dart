import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../extensions/context_extensions.dart';

/// The type of confirmation, determines the icon and accent color.
enum ConfirmationType { delete, warning, info, logout, confirm }

/// A confirmation dialog with a FontAwesome icon stacked on the top border.
///
/// The icon sits inside a colored circle that overlaps the dialog's top edge,
/// visually merging with the dialog border radius.
class IconConfirmationDialog extends StatelessWidget {
  const IconConfirmationDialog({
    super.key,
    required this.title,
    required this.onConfirm,
    this.onCancel,
    this.confirmLabel,
    this.cancelLabel,
    this.type = ConfirmationType.confirm,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String? confirmLabel;
  final String? cancelLabel;
  final ConfirmationType type;

  // ── Icon + Color mapping ──────────────────────────────────────────────
  static const _iconMap = <ConfirmationType, FaIconData>{
    ConfirmationType.delete: FontAwesomeIcons.trashCan,
    ConfirmationType.warning: FontAwesomeIcons.triangleExclamation,
    ConfirmationType.info: FontAwesomeIcons.circleInfo,
    ConfirmationType.logout: FontAwesomeIcons.rightFromBracket,
    ConfirmationType.confirm: FontAwesomeIcons.circleCheck,
  };

  Color _accentColor(BuildContext context) {
    switch (type) {
      case ConfirmationType.delete:
        return Colors.red.shade900;
      case ConfirmationType.warning:
        return context.primaryColor;
      case ConfirmationType.info:
        return const Color(0xff3498DB);
      case ConfirmationType.logout:
        return Colors.red.shade900;
      case ConfirmationType.confirm:
        return context.primaryColor;
    }
  }

  String _defaultConfirmLabel() {
    switch (type) {
      case ConfirmationType.delete:
        return 'حذف';
      case ConfirmationType.logout:
        return 'خروج';
      case ConfirmationType.warning:
      case ConfirmationType.info:
      case ConfirmationType.confirm:
        return 'نعم';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(context);
    final icon = _iconMap[type]!;
    final dialogBg = context.scaffoldBackgroundColor;
    final dialogRadius = 20.r;
    final circleRadius = 36.sp;
    final borderWidth = 4.0;

    return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // ── Dialog body ────────────────────────────────────────────
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: circleRadius), // space for circle
                padding: EdgeInsets.only(
                  top: circleRadius + 12.h,
                  bottom: 20.h,
                  left: 20.w,
                  right: 20.w,
                ),
                decoration: BoxDecoration(
                  color: dialogBg,
                  borderRadius: BorderRadius.circular(dialogRadius),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    // Buttons
                    Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: _ActionButton(
                            label: cancelLabel ?? 'لا',
                            backgroundColor: context.accentColor,
                            textColor: Colors.black,

                            borderColor: Colors.grey[300]!,
                            onTap: () {
                              onCancel?.call();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Confirm
                        Expanded(
                          child: _ActionButton(
                            label: confirmLabel ?? _defaultConfirmLabel(),
                            backgroundColor: accent,
                            textColor: Colors.white,
                            onTap: () {
                              Navigator.pop(context);
                              onConfirm();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Stacked circle icon ───────────────────────────────────
              Positioned(
                top: -15,
                child: Container(
                  width: circleRadius * 2,
                  height: circleRadius * 2,
                  decoration: BoxDecoration(
                    border: Border.all(color: dialogBg, width: borderWidth),
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(icon, size: 28.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fade(duration: 250.ms)
        .scaleXY(begin: 0.85, end: 1.0, duration: 300.ms, curve: Curves.easeOutBack);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: borderColor != null ? Border.all(color: borderColor!) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience function to show the [IconConfirmationDialog] with proper animation.
Future<void> showIconConfirmationDialog(
  BuildContext context, {
  required String title,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  String? confirmLabel,
  String? cancelLabel,
  String? subtitle,
  ConfirmationType type = ConfirmationType.confirm,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => IconConfirmationDialog(
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      subtitle: subtitle,
      type: type,
    ),
  );
}
