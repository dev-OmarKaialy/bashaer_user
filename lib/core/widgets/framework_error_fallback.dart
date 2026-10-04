import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';

class FrameworkErrorFallback extends StatelessWidget {
  const FrameworkErrorFallback({required this.details, super.key});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    if (_isInsideCollectionItem(context)) {
      return const SizedBox.shrink();
    }

    final navigator = Navigator.maybeOf(context);
    final canPop = navigator?.canPop() ?? false;
    final errorColor = Theme.of(context).colorScheme.error;

    return Material(
      color: AppTheme.backgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXXXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated error icon ──
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingXXL),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [errorColor.withOpacity(0.15), errorColor.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: errorColor.withOpacity(0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: errorColor.withOpacity(0.1),
                    ),
                    child: Icon(Icons.error_outline_rounded, size: 48.sp, color: errorColor),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXXXL),

                // ── Title ──
                Text(
                  'حدث خطأ غير متوقع',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                    fontFamily: 'Qomra',
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: AppTheme.spacingS),

                // ── Subtitle ──
                Text(
                  'نعتذر عن هذا الخطأ، يرجى المحاولة مرة أخرى',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                    fontFamily: 'Qomra',
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                // ── Debug details ──
                if (kDebugMode) ...[
                  const SizedBox(height: AppTheme.spacingXL),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: errorColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(color: errorColor.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.bug_report_outlined,
                          size: 16.sp,
                          color: errorColor.withOpacity(0.6),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Text(
                            details.toStringShort(),
                            textAlign: TextAlign.start,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: errorColor.withOpacity(0.7),
                              fontFamily: 'Qomra',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                ],

                const SizedBox(height: AppTheme.spacingXXXL),

                // ── Back button ──
                if (canPop)
                  SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => navigator?.pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingM,
                              horizontal: AppTheme.spacingXXL,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded, size: 20),
                          label: Text(
                            'العودة',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Qomra',
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isInsideCollectionItem(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ListView>() != null ||
        context.findAncestorWidgetOfExactType<GridView>() != null ||
        context.findAncestorWidgetOfExactType<CustomScrollView>() != null ||
        context.findAncestorWidgetOfExactType<SliverList>() != null ||
        context.findAncestorWidgetOfExactType<SliverGrid>() != null ||
        context.findAncestorWidgetOfExactType<ReorderableListView>() != null;
  }
}
