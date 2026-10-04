import 'package:bashaer_driving/core/extensions/widget_extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/app_contact.dart';
import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/widgets/race/animated_count.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/speed_gauge.dart';
import '../../../../core/widgets/race/speed_lines_background.dart';
import '../../data/datasources/listen_mode_settings.dart';
import '../../data/models/question_model.dart';
import '../../data/models/stats_model.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';
import '../bloc/quiz_event.dart';
import '../widgets/app_drawer.dart';
import '../widgets/exam_start_lights.dart';
import 'bookmarks_screen.dart';
import 'categories_screen.dart';
import 'mistakes_screen.dart';
import 'quiz_screen.dart';
import 'statistics_screen.dart';

/// Root "dashboard": hero cluster with the accuracy speedometer, the two
/// driving modes, and the garage of progress shortcuts.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProgressBloc>().add(const LoadProgressEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(foregroundColor: Colors.white, backgroundColor: Colors.transparent),
        drawer: const AppDrawer(),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _HomeHero(),
            const _LoadErrorBanner(),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Entrance(
                    index: 1,
                    child: SectionHeader(
                      title: 'home.practiceTitle'.tr(),
                      color: AppTheme.racingRed,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  const Entrance(index: 2, child: _PracticeModeCard()),
                  // SizedBox(height: 14.h),
                  // const Entrance(index: 3, child: _ExamModeCard()),
                  SizedBox(height: 28.h),
                  Entrance(
                    index: 4,
                    child: SectionHeader(title: 'home.trackTitle'.tr(), color: AppTheme.nitroBlue),
                  ),
                  SizedBox(height: 14.h),
                  const Entrance(index: 5, child: _GarageRow()),
                  SizedBox(height: 14.h),
                  const Entrance(index: 6, child: _ListenModeCard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _open(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusXXL.r)),
        boxShadow: AppTheme.glowShadow(AppTheme.nitroBlue, strength: 0.8),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: SpeedLinesBackground()),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, topInset + 16.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Entrance(child: const _BrandRow().setHero(heroKey: 'brand')),
                SizedBox(height: 20.h),
                Entrance(
                  index: 1,
                  scale: true,
                  child: BlocSelector<ProgressBloc, ProgressState, StatsModel?>(
                    selector: (state) => state.stats,
                    builder: (context, stats) => _DashboardCluster(stats: stats),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusM.r),
            boxShadow: AppTheme.elevatedCardShadow,
          ),
          child: Padding(
            padding: EdgeInsets.all(4.r),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusS.r),
              child: Image.asset(
                'assets/icons/launcher_icon.png',
                width: 48.r,
                height: 48.r,
                cacheWidth: 144,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (AppContact.teacherName.isNotEmpty) const _TeacherBadge(),
              Text(
                'app.title'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: AppTheme.onPrimaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The instructor behind the app, shown at the top of the hero so a student
/// knows who to ask without opening the drawer. Hidden when unset.
class _TeacherBadge extends StatelessWidget {
  const _TeacherBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Icon(
            Icons.person_rounded,
            size: 15.r,
            color: AppTheme.onPrimaryColor.withValues(alpha: 0.85),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              '${'home.teacher'.tr()}: ${AppContact.teacherName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.onPrimaryColor.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the side menu. Lives in the hero, since home has no app bar.
class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: Scaffold.of(context).openDrawer,
      tooltip: 'drawer.menu'.tr(),
      iconSize: 28.r,
      color: AppTheme.onPrimaryColor,
      icon: const Icon(Icons.menu_rounded),
    );
  }
}

/// The instrument cluster: big accuracy speedometer flanked by three dials.
class _DashboardCluster extends StatelessWidget {
  const _DashboardCluster({this.stats});

  final StatsModel? stats;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.onPrimaryColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL.r),
        border: Border.all(color: AppTheme.onPrimaryColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Column(
          children: [
            SpeedGauge(
              value: s?.accuracy ?? 0,
              label: 'home.accuracy'.tr(),
              size: 200,
              onDark: true,
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: _ClusterDial(
                    icon: FontAwesomeIcons.flagCheckered,
                    value: s?.examsTaken ?? 0,
                    label: 'home.exams'.tr(),
                  ),
                ),
                const _ClusterDivider(),
                Expanded(
                  child: _ClusterDial(
                    icon: FontAwesomeIcons.carBurst,
                    value: s?.mistakeCount ?? 0,
                    label: 'home.mistakes'.tr(),
                  ),
                ),
                const _ClusterDivider(),
                Expanded(
                  child: _ClusterDial(
                    icon: FontAwesomeIcons.solidBookmark,
                    value: s?.bookmarkedCount ?? 0,
                    label: 'home.bookmarks'.tr(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClusterDivider extends StatelessWidget {
  const _ClusterDivider();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.onPrimaryColor.withValues(alpha: 0.25),
      child: SizedBox(width: 1, height: 40.h),
    );
  }
}

class _ClusterDial extends StatelessWidget {
  const _ClusterDial({required this.icon, required this.value, required this.label});

  final FaIconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FaIcon(icon, size: 16.r, color: AppTheme.signalYellow),
        SizedBox(height: 4.h),
        AnimatedCount(
          value: value,
          style: AppTheme.numberStyle(20.sp, color: AppTheme.onPrimaryColor),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.onPrimaryColor.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

class _LoadErrorBanner extends StatelessWidget {
  const _LoadErrorBanner();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProgressBloc, ProgressState, bool>(
      selector: (state) => state.status.isFailed,
      builder: (context, failed) {
        if (!failed) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          child: Entrance(
            child: RaceCard(
              color: AppTheme.dangerBackgroundColor,
              borderColor: AppTheme.dangerColor.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Icon(Icons.car_crash_rounded, color: AppTheme.dangerColor, size: 30.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'home.error'.tr(),
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: AppTheme.dangerColor),
                    ),
                  ),
                  RaceButton(
                    label: 'home.retry'.tr(),
                    icon: Icons.refresh_rounded,
                    gradient: AppTheme.dangerGradient,
                    dense: true,
                    onPressed: () => context.read<ProgressBloc>().add(const LoadProgressEvent()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PracticeModeCard extends StatelessWidget {
  const _PracticeModeCard();

  @override
  Widget build(BuildContext context) {
    return _ModeCard(
      gradient: AppTheme.oceanGradient,
      icon: FontAwesomeIcons.road,
      tag: 'home.practiceTag'.tr(),
      title: 'home.practice'.tr(),
      subtitle: 'home.practiceSubtitle'.tr(),
      actionIcon: Icons.play_arrow_rounded,
      onTap: () => _open(context, const CategoriesScreen()),
    );
  }
}

class _ExamModeCard extends StatelessWidget {
  const _ExamModeCard();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProgressBloc, ProgressState, List<QuestionModel>>(
      selector: (state) => state.questions,
      builder: (context, questions) {
        return _ModeCard(
          gradient: AppTheme.sunsetGradient,
          icon: FontAwesomeIcons.flagCheckered,
          tag: 'home.examTag'.tr(),
          title: 'home.exam'.tr(),
          subtitle: 'home.examSubtitle'.tr(),
          actionIcon: Icons.sports_score_rounded,
          onTap: questions.isEmpty
              ? null
              : () async {
                  final title = 'exam.title'.tr();
                  await showRaceStartLights(context);
                  if (!context.mounted) return;
                  _open(
                    context,
                    QuizScreen(
                      questions: questions,
                      mode: QuizMode.exam,
                      examTimeSeconds: 60 * 60,
                      title: title,
                    ),
                  );
                },
        );
      },
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.gradient,
    required this.icon,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.actionIcon,
    required this.onTap,
  });

  final LinearGradient gradient;
  final FaIconData icon;
  final String tag;
  final String title;
  final String subtitle;
  final IconData actionIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return RaceCard(
      onTap: onTap,
      semanticLabel: title,
      gradient: enabled
          ? gradient
          : const LinearGradient(colors: [AppTheme.inkFaint, AppTheme.inkSoft]),
      glowColor: enabled ? gradient.colors.first : null,
      radius: AppTheme.radiusXL,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -18.r,
            bottom: -22.r,
            child: FaIcon(
              icon,
              size: 120.r,
              color: AppTheme.onPrimaryColor.withValues(alpha: 0.14),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.r),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppTheme.onPrimaryColor.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                          child: Text(
                            tag,
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(color: AppTheme.onPrimaryColor),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(color: AppTheme.onPrimaryColor),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onPrimaryColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.elevatedCardShadow,
                  ),
                  child: SizedBox(
                    width: 56.r,
                    height: 56.r,
                    child: Icon(
                      enabled ? actionIcon : Icons.hourglass_top_rounded,
                      color: enabled ? gradient.colors.first : AppTheme.inkFaint,
                      size: 30.r,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GarageRow extends StatelessWidget {
  const _GarageRow();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BlocSelector<ProgressBloc, ProgressState, int>(
              selector: (state) => state.bookmarkedIds.length,
              builder: (context, count) => _GarageTile(
                gradient: AppTheme.goldGradient,
                icon: FontAwesomeIcons.solidBookmark,
                title: 'home.bookmarks'.tr(),
                value: '$count',
                onTap: () => _open(context, const BookmarksScreen()),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: BlocSelector<ProgressBloc, ProgressState, int>(
              selector: (state) => state.stats?.mistakeCount ?? 0,
              builder: (context, count) => _GarageTile(
                gradient: AppTheme.dangerGradient,
                icon: FontAwesomeIcons.rotateLeft,
                title: 'home.mistakes'.tr(),
                value: '$count',
                onTap: () => _open(context, const MistakesScreen()),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _GarageTile(
              gradient: AppTheme.grapeGradient,
              icon: FontAwesomeIcons.chartLine,
              title: 'home.statistics'.tr(),
              value: null,
              caption: 'home.statisticsSub'.tr(),
              onTap: () => _open(context, const StatisticsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _GarageTile extends StatelessWidget {
  const _GarageTile({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.caption,
  });

  final LinearGradient gradient;
  final FaIconData icon;
  final String title;
  final String? value;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RaceCard(
      onTap: onTap,
      semanticLabel: title,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      child: Column(
        children: [
          GradientIconBadge(
            gradient: gradient,
            size: 46,
            child: FaIcon(icon, size: 20.r, color: AppTheme.onPrimaryColor),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: 2.h),
          if (value != null)
            Text(value!, style: AppTheme.numberStyle(18.sp, color: gradient.colors.first))
          else
            Text(
              caption ?? '',
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
        ],
      ),
    );
  }
}

class _ListenModeCard extends StatelessWidget {
  const _ListenModeCard();

  @override
  Widget build(BuildContext context) {
    final settings = getIt<ListenModeSettings>();
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final enabled = settings.enabled;
        return RaceCard(
          onTap: settings.toggle,
          semanticLabel: 'home.listenMode'.tr(),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          borderColor: enabled
              ? AppTheme.nitroBlue.withValues(alpha: 0.35)
              : AppTheme.inkFaint.withValues(alpha: 0.25),
          child: Row(
            children: [
              GradientIconBadge(
                gradient: enabled ? AppTheme.oceanGradient : AppTheme.grapeGradient,
                size: 46,
                child: Icon(Icons.headphones_rounded, size: 22.r, color: AppTheme.onPrimaryColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('home.listenMode'.tr(), style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 2.h),
                    Text(
                      'home.listenModeSubtitle'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Switch.adaptive(
                value: enabled,
                activeTrackColor: AppTheme.nitroBlue.withValues(alpha: 0.45),
                activeThumbColor: AppTheme.nitroBlue,
                onChanged: settings.setEnabled,
              ),
            ],
          ),
        );
      },
    );
  }
}
