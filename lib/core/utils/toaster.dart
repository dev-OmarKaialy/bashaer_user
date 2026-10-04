import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';

class Toaster {
  Toaster._();
  static void showToast(String text, {bool isError = true}) {
    BotToast.showCustomText(
      align: Alignment.topCenter,
      animationDuration: Durations.long1,

      animationReverseDuration: Durations.long1,
      wrapToastAnimation: (controller, cancelFunc, widget) =>
          SizeTransition(sizeFactor: controller, child: widget),
      toastBuilder: (cancelFunc) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.warning_amber_rounded : Icons.done,
                  color: isError ? const Color(0xffbf2c26) : const Color(0xff002d30),
                  size: 30.sp,
                ).animate().fade(delay: Durations.short4).fadeOut(delay: Durations.extralong4 * 2),
                const SizedBox(width: 10),
                Expanded(
                  child:
                      Text(
                            text,
                            maxLines: 5,
                            style: TextStyle(
                              color: isError ? const Color(0xffbf2c26) : const Color(0xff002d30),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                          .animate()
                          .fade(delay: Durations.short4)
                          .fadeOut(delay: Durations.extralong4 * 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showLoading() {
    BotToast.showCustomLoading(
      animationDuration: Durations.long2,
      animationReverseDuration: Durations.long2,
      toastBuilder: (cancelFunc) {
        return Card(
          color: Colors.white,
          child: Container(
            width: 60.w,
            height: 60.w,
            padding: EdgeInsets.all(10.sp),
            child: const CustomLoadingWidget(),
          ),
        );
      },
    );
  }

  static void closeLoading() {
    BotToast.closeAllLoading();
  }

  static void showNotification({
    required Widget title,
    Widget Function(void Function())? leading,
    Widget Function(void Function())? subtitle,
    Color? backgroundColor,
  }) {
    BotToast.showNotification(
      title: (s) => title,
      subtitle: subtitle,
      leading: leading,

      backgroundColor: backgroundColor,
    );
  }

  static void showSuccess({String? text}) {
    BotToast.showCustomNotification(
      toastBuilder: (s) {
        return Builder(
          builder: (context) {
            return Card(
              color: context.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: context.primaryColor, size: 80),
                    20.verticalSpace,
                    Text(text ?? 'Saved Successfully'),
                  ],
                ),
              ),
            );
          },
        );
      },

      align: Alignment.center,
      crossPage: true,
    );
  }
}

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator.adaptive();
  }
}
