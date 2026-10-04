/// Error codes used by the license repository / UI mapping.
abstract final class LicenseErrorCodes {
  /// No usable access yet — request exists or was just created; admin must approve.
  static const pending = 'pending';

  /// Row missing unexpectedly after create, or malformed device id.
  static const invalid = 'invalid';

  /// Admin turned `isActive` off after a prior approval.
  static const inactive = 'inactive';

  static const expired = 'expired';
  static const offline = 'offline';
  static const unknown = 'unknown';
}
