import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Turbo" design system: a light, colorful, car-racing inspired theme.
///
/// Palette tokens are grouped as brand accents, surfaces, ink (text) and
/// semantic states. Legacy token names (`primaryColor`, `successColor`, ...)
/// are kept and mapped onto the new palette so shared widgets stay compatible.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Brand accents
  // ---------------------------------------------------------------------------
  static const Color racingRed = Color(0xffff3d57);
  static const Color turboOrange = Color(0xffff8a1f);
  static const Color signalYellow = Color(0xffffc531);
  static const Color nitroBlue = Color(0xff2e6bff);
  static const Color electricViolet = Color(0xff7c4dff);
  static const Color mintGreen = Color(0xff12c29a);
  static const Color aqua = Color(0xff00b8d9);
  static const Color hotPink = Color(0xffff4fa3);

  // ---------------------------------------------------------------------------
  // Surfaces and ink
  // ---------------------------------------------------------------------------
  static const Color skyBackground = Color(0xfff3f6fd);
  static const Color cardSurface = Color(0xffffffff);
  static const Color mutedSurface = Color(0xffe9eefb);
  static const Color asphalt = Color(0xff262b45);
  static const Color laneWhite = Color(0xfffdfdff);
  static const Color ink = Color(0xff141b34);
  static const Color inkSoft = Color(0xff5b6385);
  static const Color inkFaint = Color(0xff9aa1bd);
  static const Color divider = Color(0xffdfe4f2);

  // ---------------------------------------------------------------------------
  // Legacy names mapped to the new palette
  // ---------------------------------------------------------------------------
  static const Color primaryColor = nitroBlue;
  static const Color tertiaryColor = electricViolet;
  static const Color secondaryColor = turboOrange;
  static const Color errorColor = racingRed;
  static const Color surfaceColor = cardSurface;
  static const Color backgroundColor = skyBackground;
  static const Color onPrimaryColor = Color(0xffffffff);
  static const Color onSecondaryColor = ink;
  static const Color onSurfaceColor = ink;
  static const Color onErrorColor = Color(0xffffffff);

  // Answer-state colors (traffic light)
  static const Color successColor = mintGreen;
  static const Color successBackgroundColor = Color(0xffe3faf3);
  static const Color dangerColor = racingRed;
  static const Color dangerBackgroundColor = Color(0xffffe8ec);
  static const Color warningColor = signalYellow;
  static const Color warningBackgroundColor = Color(0xfffff6dc);
  static const Color neutralColor = inkFaint;

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [racingRed, turboOrange],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [nitroBlue, aqua],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );
  static const LinearGradient grapeGradient = LinearGradient(
    colors: [electricViolet, nitroBlue],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );
  static const LinearGradient limeGradient = LinearGradient(
    colors: [mintGreen, aqua],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );
  static const LinearGradient goldGradient = LinearGradient(
    colors: [signalYellow, turboOrange],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );
  static const LinearGradient candyGradient = LinearGradient(
    colors: [hotPink, electricViolet],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [racingRed, hotPink],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// The hero backdrop used behind headers.
  static const LinearGradient heroGradient = LinearGradient(
    colors: [electricViolet, nitroBlue, aqua],
    stops: [0, 0.55, 1],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Rotating accent gradients for lists (categories, tiles, ...).
  static const List<LinearGradient> accentGradients = [
    oceanGradient,
    sunsetGradient,
    limeGradient,
    grapeGradient,
    goldGradient,
    candyGradient,
  ];

  static LinearGradient accentGradientAt(int index) =>
      accentGradients[index % accentGradients.length];

  /// Traffic-light color for a percentage score.
  static Color scoreColor(double percent) {
    if (percent >= 80) return mintGreen;
    if (percent >= 60) return turboOrange;
    return racingRed;
  }

  // ---------------------------------------------------------------------------
  // Typography
  // ---------------------------------------------------------------------------
  static const String fontFamily = 'Cairo';

  /// Squared "dashboard" font for numbers: gauges, timers, counters.
  static const String displayNumberFont = 'ChakraPetch';

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Border Radius
  static const double radiusS = 10.0;
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 26.0;
  static const double radiusXXL = 32.0;
  static const double radiusPill = 100.0;

  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 12.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 180);
  static const Duration animationNormal = Duration(milliseconds: 320);
  static const Duration animationSlow = Duration(milliseconds: 600);
  static const Duration animationGauge = Duration(milliseconds: 1400);
  static const Duration staggerStep = Duration(milliseconds: 70);

  // Animation curves
  static const Curve animationCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutQuart;
  static const Curve springCurve = Curves.easeOutBack;

  // Shadow styles
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: ink.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 8)),
    BoxShadow(color: ink.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get elevatedCardShadow => [
    BoxShadow(color: ink.withValues(alpha: 0.10), blurRadius: 28, offset: const Offset(0, 14)),
  ];

  /// Soft colored glow under gradient buttons and hero cards.
  static List<BoxShadow> glowShadow(Color color, {double strength = 1}) => [
    BoxShadow(
      color: color.withValues(alpha: 0.35 * strength),
      blurRadius: 20 * strength,
      offset: Offset(0, 10 * strength),
    ),
  ];

  static List<BoxShadow> get buttonShadow => glowShadow(primaryColor);

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: onPrimaryColor,
      primaryContainer: Color(0xffdfe8ff),
      onPrimaryContainer: ink,
      secondary: secondaryColor,
      onSecondary: onPrimaryColor,
      secondaryContainer: Color(0xffffead6),
      onSecondaryContainer: ink,
      tertiary: tertiaryColor,
      onTertiary: onPrimaryColor,
      error: errorColor,
      onError: onErrorColor,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      onSurfaceVariant: inkSoft,
      surfaceContainerHighest: mutedSurface,
      outline: divider,
      outlineVariant: divider,
    );

    return ThemeData(
      fontFamily: fontFamily,
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: RacePageTransitionsBuilder(),
          TargetPlatform.iOS: RacePageTransitionsBuilder(),
          TargetPlatform.linux: RacePageTransitionsBuilder(),
          TargetPlatform.macOS: RacePageTransitionsBuilder(),
          TargetPlatform.windows: RacePageTransitionsBuilder(),
          TargetPlatform.fuchsia: RacePageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
        margin: EdgeInsets.zero,
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor, width: 2.0),
        ),
        labelStyle: TextStyle(color: inkSoft, fontSize: 14.sp, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: inkFaint, fontSize: 14.sp),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: spacingXL, vertical: spacingM),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ink, minimumSize: const Size(48, 48)),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: elevationL,
        shape: CircleBorder(),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: skyBackground,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: divider,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXL)),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingS),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        tileColor: surfaceColor,
        selectedTileColor: primaryColor.withValues(alpha: 0.1),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: mutedSurface,
        circularTrackColor: mutedSurface,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(radiusS)),
        textStyle: TextStyle(fontFamily: fontFamily, fontSize: 12.sp, color: onPrimaryColor),
      ),

      dividerTheme: const DividerThemeData(color: divider, thickness: 1.0, space: 1.0),

      iconTheme: const IconThemeData(color: ink, size: 24.0),

      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w700, color: ink),
        displayMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700, color: ink),
        displaySmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: ink),
        headlineLarge: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: ink),
        headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: ink),
        headlineSmall: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: ink),
        titleLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: ink),
        titleMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: ink),
        titleSmall: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: ink),
        bodyLarge: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w400, color: ink),
        bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: ink),
        bodySmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: inkSoft),
        labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: ink),
        labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: inkSoft),
        labelSmall: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: inkSoft),
      ),
    );
  }

  /// Number style for gauges, counters and timers.
  static TextStyle numberStyle(double size, {Color color = ink}) => TextStyle(
    fontFamily: displayNumberFont,
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.1,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

/// Route transition: the new page slides in from the reading-end side with a
/// fade, while the old page slightly scales back, like a car pulling away.
class RacePageTransitionsBuilder extends PageTransitionsBuilder {
  const RacePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppTheme.slideCurve,
      reverseCurve: Curves.easeInCubic,
    );
    final secondaryCurved = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut);
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 0.94).animate(secondaryCurved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(isRtl ? -0.35 : 0.35, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      ),
    );
  }
}
