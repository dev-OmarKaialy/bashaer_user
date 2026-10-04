import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/services/dependencies.dart';
import 'core/theme/app_theme.dart';
import 'features/quiz/presentation/bloc/progress_bloc.dart';
import 'features/quiz/presentation/pages/bootstrap_screen.dart';

/// Root widget for the Al-Bashaer driving-school exam prep app.
///
/// [ProgressBloc] is the app-wide singleton holding progress (bookmarks,
/// mistakes, results, statistics); it is provided above [MaterialApp] so every
/// route can read it. [BootstrapScreen] syncs the question bank before home.
class TemplateApp extends StatelessWidget {
  /// Creates the root app widget.
  const TemplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider<ProgressBloc>.value(
          value: getIt<ProgressBloc>(),
          child: MaterialApp(
            locale: context.locale,
            builder: BotToastInit(),
            navigatorObservers: [BotToastNavigatorObserver()],
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            debugShowCheckedModeBanner: false,
            title: 'البشائر لتعليم القيادة',
            theme: AppTheme.lightTheme,
            home: const BootstrapScreen(),
          ),
        );
      },
    );
  }
}
