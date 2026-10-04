import 'package:bashaer_driving/core/extensions/widget_extensions.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_contact.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/services/app_info_service.dart';
import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/utils/toaster.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/pressable.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/race_confirm_dialog.dart';
import '../../../../core/widgets/race/speed_lines_background.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';

/// Side menu: refresh the bank from the server, reset device-local progress,
/// reach the school and read the app's own details.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: BlocListener<ProgressBloc, ProgressState>(
        listenWhen: (previous, current) =>
            previous.refreshStatus != current.refreshStatus ||
            previous.clearStatus != current.clearStatus,
        listener: _onProgressChanged,
        child: Column(
          children: [
            const _DrawerHeader().setHero(heroKey: 'brand'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                children: [
                  BlocSelector<ProgressBloc, ProgressState, bool>(
                    selector: (state) => state.refreshStatus.isLoading,
                    builder: (context, isRefreshing) => _DrawerTile(
                      icon: Icons.cloud_download_rounded,
                      gradient: AppTheme.oceanGradient,
                      title: 'drawer.updateData'.tr(),
                      subtitle: 'drawer.updateDataSubtitle'.tr(),
                      busy: isRefreshing,
                      onTap: () => context.read<ProgressBloc>().add(const RefreshBankEvent()),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _DrawerTile(
                    icon: Icons.bar_chart_rounded,
                    gradient: AppTheme.dangerGradient,
                    title: 'drawer.clearStatistics'.tr(),
                    subtitle: 'drawer.clearStatisticsSubtitle'.tr(),
                    onTap: () => _confirm(
                      context: context,
                      message: 'drawer.clearStatisticsConfirm'.tr(),
                      icon: Icons.delete_sweep_rounded,
                      onConfirm: () =>
                          context.read<ProgressBloc>().add(const ClearStatisticsEvent()),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _DrawerTile(
                    icon: Icons.bookmark_remove_rounded,
                    gradient: AppTheme.candyGradient,
                    title: 'drawer.clearBookmarks'.tr(),
                    subtitle: 'drawer.clearBookmarksSubtitle'.tr(),
                    onTap: () => _confirm(
                      context: context,
                      message: 'drawer.clearBookmarksConfirm'.tr(),
                      icon: Icons.bookmark_remove_rounded,
                      onConfirm: () =>
                          context.read<ProgressBloc>().add(const ClearBookmarksEvent()),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _DrawerTile(
                    icon: Icons.support_agent_rounded,
                    gradient: AppTheme.limeGradient,
                    title: 'drawer.contact'.tr(),
                    subtitle: 'drawer.contactSubtitle'.tr(),
                    onTap: () => _openContact(context),
                  ),
                  SizedBox(height: 10.h),
                  _DrawerTile(
                    icon: Icons.info_outline_rounded,
                    gradient: AppTheme.grapeGradient,
                    title: 'drawer.about'.tr(),
                    subtitle: 'drawer.aboutSubtitle'.tr(),
                    onTap: () => _openAbout(context),
                  ),
                ],
              ),
            ),
            const _VersionFooter(),
          ],
        ),
      ),
    );
  }

  static void _onProgressChanged(BuildContext context, ProgressState state) {
    // The refreshing tile shows its own spinner, so no blocking loader here:
    // closing the drawer mid-refresh would leave a global loader stuck.
    if (state.refreshStatus.isLoading || state.clearStatus.isLoading) return;

    if (state.refreshStatus.isSuccess) {
      Toaster.showToast('drawer.updateSuccess'.tr(), isError: false);
    } else if (state.refreshStatus.isFailed) {
      Toaster.showToast('drawer.updateFailed'.tr());
    } else if (state.clearStatus.isSuccess) {
      Toaster.showToast('drawer.clearDone'.tr(), isError: false);
    } else if (state.clearStatus.isFailed) {
      Toaster.showToast('drawer.clearFailed'.tr());
    }
  }

  static void _confirm({
    required BuildContext context,
    required String message,
    required IconData icon,
    required VoidCallback onConfirm,
  }) {
    showRaceDialog<void>(
      context: context,
      builder: (_) => RaceConfirmDialog(
        title: message,
        icon: icon,
        gradient: AppTheme.dangerGradient,
        onConfirm: onConfirm,
      ),
    );
  }

  static void _openContact(BuildContext context) {
    if (!AppContact.hasAny) {
      Toaster.showToast('drawer.contactUnavailable'.tr());
      return;
    }
    showRaceDialog<void>(context: context, builder: (_) => const _ContactSheet());
  }

  static void _openAbout(BuildContext context) {
    showRaceDialog<void>(context: context, builder: (_) => const _AboutSheet());
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadiusDirectional.only(
          bottomEnd: Radius.circular(AppTheme.radiusXXL.r),
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: SpeedLinesBackground()),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, topInset + 24.h, 20.w, 24.h),
            child: Row(
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: AppTheme.onPrimaryColor.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.onPrimaryColor.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(Assets.assetsIconsLauncherIcon, fit: BoxFit.cover),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'app.title'.tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.onPrimaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'app.tagline'.tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.onPrimaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
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

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return RaceCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusL.r),
          onTap: busy ? null : onTap,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 12.w, 12.h),
            child: Row(
              children: [
                GradientIconBadge(gradient: gradient, icon: icon, size: 44),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.inkSoft),
                      ),
                    ],
                  ),
                ),
                if (busy)
                  SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.chevron_right_rounded, color: AppTheme.inkFaint, size: 22.r),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: FutureBuilder<AppInfo>(
          future: getIt<AppInfoService>().load(),
          builder: (context, snapshot) {
            final info = snapshot.data;
            return Text(
              info == null ? '' : '${'drawer.version'.tr()} ${info.display}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.inkFaint,
                fontFamily: AppTheme.displayNumberFont,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ContactSheet extends StatelessWidget {
  const _ContactSheet();

  @override
  Widget build(BuildContext context) {
    const teacherName = AppContact.teacherName;
    return _SheetShell(
      icon: Icons.support_agent_rounded,
      gradient: AppTheme.limeGradient,
      title: 'drawer.contact'.tr(),
      subtitle: 'drawer.contactSubtitle'.tr(),
      children: [
        if (AppContact.phone.isNotEmpty)
          Entrance(
            index: 0,
            child: _ContactRow(
              icon: teacherName.isNotEmpty ? Icons.person_rounded : Icons.call_rounded,
              gradient: AppTheme.oceanGradient,
              actionIcon: Icons.call_rounded,
              actionLabel: 'drawer.callUs'.tr(),
              label: teacherName.isNotEmpty ? 'drawer.teacher'.tr() : 'drawer.callUs'.tr(),
              value: teacherName.isNotEmpty ? teacherName : AppContact.phone,
              secondaryValue: teacherName.isNotEmpty ? AppContact.phone : null,
              uri: Uri(scheme: 'tel', path: AppContact.phone),
              valueTextDirection: teacherName.isNotEmpty ? null : TextDirection.ltr,
            ),
          ),
        if (AppContact.managersPhone.isNotEmpty)
          Entrance(
            index: 1,
            child: _ContactRow(
              icon: Icons.groups_rounded,
              gradient: AppTheme.goldGradient,
              actionIcon: Icons.call_rounded,
              actionLabel: 'drawer.callUs'.tr(),
              label: 'drawer.managers'.tr(),
              value: AppContact.managersPhone,
              uri: Uri(scheme: 'tel', path: AppContact.managersPhone),
            ),
          ),
        if (AppContact.whatsapp.isNotEmpty)
          Entrance(
            index: 2,
            child: _ContactRow(
              icon: Icons.chat_rounded,
              gradient: AppTheme.limeGradient,
              actionIcon: Icons.chat_rounded,
              actionLabel: 'drawer.whatsapp'.tr(),
              label: 'drawer.whatsapp'.tr(),
              value: '+${AppContact.whatsapp}',
              uri: Uri.parse('https://wa.me/${AppContact.whatsapp}'),
            ),
          ),
        if (AppContact.email.isNotEmpty)
          Entrance(
            index: 3,
            child: _ContactRow(
              icon: Icons.mail_rounded,
              gradient: AppTheme.sunsetGradient,
              actionIcon: Icons.mail_rounded,
              actionLabel: 'drawer.email'.tr(),
              label: 'drawer.email'.tr(),
              value: AppContact.email,
              uri: Uri(scheme: 'mailto', path: AppContact.email),
            ),
          ),
        if (AppContact.website.isNotEmpty)
          Entrance(
            index: 4,
            child: _ContactRow(
              icon: Icons.public_rounded,
              gradient: AppTheme.grapeGradient,
              actionIcon: Icons.language_rounded,
              actionLabel: 'drawer.website'.tr(),
              label: 'drawer.website'.tr(),
              value: AppContact.website,
              uri: Uri.parse(AppContact.website),
            ),
          ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.gradient,
    required this.actionIcon,
    required this.actionLabel,
    required this.label,
    required this.value,
    required this.uri,
    this.secondaryValue,
    this.secondaryIcon = Icons.call_rounded,
    this.valueTextDirection = TextDirection.ltr,
    this.secondaryValueTextDirection = TextDirection.ltr,
  });

  final IconData icon;
  final LinearGradient gradient;
  final IconData actionIcon;
  final String actionLabel;
  final String label;
  final String value;
  final Uri uri;
  final String? secondaryValue;
  final IconData secondaryIcon;
  final TextDirection? valueTextDirection;
  final TextDirection? secondaryValueTextDirection;

  Future<void> _open(BuildContext context) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!opened) Toaster.showToast('drawer.openFailed'.tr());
  }

  @override
  Widget build(BuildContext context) {
    final accent = gradient.colors.first;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Pressable(
        onTap: () => _open(context),
        pressedScale: 0.98,
        semanticLabel: '$label $value $actionLabel',
        child: RaceCard(
          radius: AppTheme.radiusL,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          borderColor: accent.withValues(alpha: 0.24),
          glowColor: accent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GradientIconBadge(gradient: gradient, icon: icon, size: 52),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        RaceTag(label: actionLabel, color: accent, icon: actionIcon),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: valueTextDirection,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (secondaryValue != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(secondaryIcon, color: accent, size: 14.r),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              secondaryValue!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: secondaryValueTextDirection,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.open_in_new_rounded, color: accent, size: 18.r),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      icon: Icons.info_outline_rounded,
      gradient: AppTheme.grapeGradient,
      title: 'app.title'.tr(),
      children: [
        Text(
          'drawer.aboutBody'.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.inkSoft),
        ),
        if (AppContact.developerName.isNotEmpty && AppContact.developerPortfolio.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Entrance(
            index: 0,
            child: _ContactRow(
              icon: Icons.code_rounded,
              gradient: AppTheme.candyGradient,
              actionIcon: Icons.open_in_new_rounded,
              actionLabel: 'drawer.developer'.tr(),
              label: 'drawer.developer'.tr(),
              value: AppContact.developerName,
              secondaryValue: 'drawer.developerSubtitle'.tr(),
              secondaryIcon: Icons.link_rounded,
              uri: Uri.parse(AppContact.developerPortfolio),
              valueTextDirection: null,
              secondaryValueTextDirection: null,
            ),
          ),
        ],
        SizedBox(height: 16.h),
        FutureBuilder<AppInfo>(
          future: getIt<AppInfoService>().load(),
          builder: (context, snapshot) {
            final info = snapshot.data;
            if (info == null) return const SizedBox.shrink();
            return Text(
              '${'drawer.version'.tr()} ${info.display}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontFamily: AppTheme.displayNumberFont,
                color: AppTheme.primaryColor,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Shared card shell for the drawer's dialogs.
class _SheetShell extends StatelessWidget {
  const _SheetShell({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.children,
    this.subtitle,
  });

  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final List<Widget> children;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 0, 20.w, 0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: RaceCard(
              radius: AppTheme.radiusXL,
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SheetHeader(icon: icon, gradient: gradient, title: title, subtitle: subtitle),
                    SizedBox(height: 18.h),
                    ...children,
                    SizedBox(height: 8.h),
                    const _SheetCloseButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.icon,
    required this.gradient,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL.r),
        boxShadow: AppTheme.glowShadow(gradient.colors.first, strength: 0.35),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: SpeedLinesBackground()),
          const PositionedDirectional(
            end: -30,
            top: -30,
            child: _HeaderOrb(size: 112, opacity: 0.08),
          ),
          const PositionedDirectional(
            start: -36,
            bottom: -48,
            child: _HeaderOrb(size: 96, opacity: 0.06),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AnimatedSheetBadge(icon: icon, gradient: gradient),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.onPrimaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitleText != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitleText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.onPrimaryColor.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedSheetBadge extends StatelessWidget {
  const _AnimatedSheetBadge({required this.icon, required this.gradient});

  final IconData icon;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: 60.r,
      height: 60.r,
      decoration: BoxDecoration(
        color: AppTheme.onPrimaryColor.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: gradient.colors.last.withValues(alpha: 0.65), width: 1.5),
      ),
      child: Center(
        child: Icon(icon, color: AppTheme.onPrimaryColor, size: 29.r),
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return badge;
    return badge
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 0.96,
          end: 1.04,
          duration: AppTheme.animationSlow,
          curve: AppTheme.animationCurve,
        );
  }
}

class _HeaderOrb extends StatelessWidget {
  const _HeaderOrb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.onPrimaryColor.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(dimension: size.r),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.close_rounded, size: 18.r),
        label: Text('drawer.close'.tr()),
      ),
    );
  }
}
