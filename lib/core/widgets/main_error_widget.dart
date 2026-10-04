// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';

class MainErrorWidget extends StatelessWidget {
  const MainErrorWidget({super.key, this.onPressed, this.icon, this.text});
  final Function()? onPressed;
  final Widget? icon;
  final String? text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filled(
            onPressed: onPressed,
            icon: icon ?? const Icon(Icons.refresh, color: Colors.white),
          ),
          10.verticalSpace,
          Text(
            text ?? 'فشل في الحصول على البيانات',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
