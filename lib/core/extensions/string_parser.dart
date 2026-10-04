import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

extension DateOnlyComparison on DateTime {
  String get calculateArchiveDays {
    final daysLeft = 1 - DateTime.now().difference(this).inDays;
    return daysLeft > 0 ? 'ستتم أرشفته غداً' : 'ستتم أرشفته اليوم';
  }

  bool get isNowOrBefore {
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    final targetDate = DateTime(year, month, day);

    return targetDate.isBefore(currentDate) || targetDate.isAtSameMomentAs(currentDate);
  }
}

extension StringExtension on String? {
  bool get isNullOrEmpty {
    return !(this != null && this!.isNotEmpty);
  }
}

extension StringParser on String {
  Color toActiveProjectColor() {
    return switch (this) {
      'نشط جدا' => AppTheme.primaryColor,
      'نشط' => AppTheme.primaryColor.withAlpha(150),
      'خامد' => AppTheme.secondaryColor,
      'متوقف' => AppTheme.errorColor,
      _ => Colors.transparent,
    };
  }

  /// Converts snake_case to UpperCamelCase
  String toUpperCamelCase() {
    return split('_')
        .map(
          (word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '',
        )
        .join();
  }

  /// Converts snake_case to lowerCamelCase
  String toLowerCamelCase() {
    String upperCamel = toUpperCamelCase();
    return upperCamel.isNotEmpty ? upperCamel[0].toLowerCase() + upperCamel.substring(1) : '';
  }

  /// Converts UpperCamelCase or lowerCamelCase to snake_case
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => "${match[1]}_${match[2]}",
    ).toLowerCase();
  }

  Color toColor() {
    String hashColor = replaceAll("#", "0xff");
    return Color(int.parse(hashColor));
  }

  String parseUnicode() {
    return split("\\u").length == 1
        ? this
        : String.fromCharCodes([int.parse(split('\\u').last, radix: 16)]);
  }

  Color parseRgbString() {
    // Remove "rgb(" and ")" and split by commas
    List<String> values = replaceAll("rgb(", "").replaceAll(")", "").split(",");

    // Parse each component to int
    int r = int.parse(values[0].trim());
    int g = int.parse(values[1].trim());
    int b = int.parse(values[2].trim());

    return Color.fromARGB(255, r, g, b); // Full opacity
  }

  double toDouble() {
    return double.tryParse(this) ?? 0;
  }

  String toHoursMinutes() {
    final parts = split(':');
    if (parts.length != 2) return this;

    final totalHours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    // Normalize minutes into hours
    final extraHours = minutes ~/ 60;
    final normalizedMinutes = minutes % 60;
    final normalizedHours = totalHours + extraHours;
    final normalizedDays = normalizedHours ~/ 8;

    return "$normalizedDays يوم${normalizedMinutes == 0 ? '' : '  -  $normalizedMinutes دقيقة'}";
  }
}

extension ColorParser on Color {
  String toHex() {
    return toARGB32().toRadixString(16).replaceRange(0, 2, "#");
  }
}
