import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'race_button.dart';

/// Light, transparent top bar: a back "key fob" button, a bold title with an
/// optional colored subtitle chip, and trailing actions.
class RaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RaceAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.backTooltip,
    this.showBack = true,
  });

  final String title;
  final List<Widget> actions;
  final Widget? leading;
  final String? backTooltip;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      titleSpacing: 4,
      leading:
          leading ??
          (showBack && canPop
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: RaceIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: backTooltip ?? MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                )
              : null),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      actions: [
        ...actions,
        SizedBox(width: 8.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
