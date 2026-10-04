import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Renders [text] with the active TTS word range painted in a highlight color.
class SpokenHighlightText extends StatelessWidget {
  const SpokenHighlightText({
    super.key,
    required this.text,
    required this.style,
    this.highlightStart = 0,
    this.highlightEnd = 0,
    this.active = false,
  });

  final String text;
  final TextStyle? style;
  final int highlightStart;
  final int highlightEnd;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active || highlightEnd <= highlightStart || text.isEmpty) {
      return Text(text, style: style);
    }

    final start = highlightStart.clamp(0, text.length);
    final end = highlightEnd.clamp(start, text.length);
    final base = style ?? DefaultTextStyle.of(context).style;
    final highlightStyle = base.copyWith(
      color: AppTheme.nitroBlue,
      backgroundColor: AppTheme.nitroBlue.withValues(alpha: 0.18),
      fontWeight: FontWeight.w700,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          if (start > 0) TextSpan(text: text.substring(0, start)),
          TextSpan(text: text.substring(start, end), style: highlightStyle),
          if (end < text.length) TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}
