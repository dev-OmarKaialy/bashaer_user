/// The driving school's public contact channels, shown in the drawer.
///
/// Leave a field empty to hide that row: the "contact us" sheet only lists the
/// channels that are filled in, so nothing fake is ever shown to a student.
class AppContact {
  const AppContact._();

  /// Teacher name shown in the contact sheet.
  static const String teacherName = 'المهندس سمير وتي';

  /// Dialled as-is, e.g. `+963991234567`.
  static const String phone = '+963993432893';

  /// Managers phone number shown separately.
  static const String managersPhone = '+352681611211';

  /// WhatsApp number in international format, digits only, e.g. `963991234567`.
  static const String whatsapp = '963993432893';

  /// Support mailbox, e.g. `info@example.com`.
  static const String email = '';

  /// Optional page opened by "visit us", e.g. a Facebook page.
  static const String website = '';

  /// Developer name shown in "About".
  static const String developerName = 'عمر كيالي';

  /// Developer portfolio/website URL shown in "About".
  static const String developerPortfolio = 'https://linkedin.com/in/omar-kaialy';

  static bool get hasAny =>
      phone.isNotEmpty ||
      managersPhone.isNotEmpty ||
      whatsapp.isNotEmpty ||
      email.isNotEmpty ||
      website.isNotEmpty;
}
