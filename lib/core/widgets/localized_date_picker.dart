import 'package:flutter/material.dart';

/// Shows a date picker that switches localization between Arabic and English
/// depending on the entry mode (calendar vs input). Returns the picked date.
Future<DateTime?> showLocalizedDatePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDate,
  DatePickerMode? initialDatePickerMode,
}) {
  final locale = ValueNotifier(const Locale('ar'));

  return showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate,
    lastDate: lastDate,
    initialDatePickerMode: initialDatePickerMode ?? DatePickerMode.day,
    onDatePickerModeChange: (mode) {
      if (mode == DatePickerEntryMode.calendar || mode == DatePickerEntryMode.calendarOnly) {
        locale.value = const Locale('ar');
      } else {
        locale.value = const Locale('en', 'GB');
      }
    },
    builder: (context, child) {
      return ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (context, value, _) {
          return Localizations.override(context: context, locale: value, child: child);
        },
      );
    },
  );
}
