import 'package:easy_localization/easy_localization.dart';

typedef FromJson<T> = T Function(String json);

typedef ParamsMap = Map<String, String?>?;

typedef BodyMap = Map<String, dynamic>;

class AppDateFormatter {
  static const months = [
    'كانون الثاني',
    'شباط',
    'آذار',
    'نيسان',
    'أيار',
    'حزيران',
    'تموز',
    'آب',
    'أيلول',
    'تشرين الأول',
    'تشرين الثاني',
    'كانون الأول',
  ];

  static String full(DateTime date) {
    final weekday = DateFormat('E', 'ar').format(date);
    return '$weekday ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
