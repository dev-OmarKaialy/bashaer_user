/// Error codes the subscription repository produces when a plan cannot be read.
abstract final class SubscriptionErrorCodes {
  /// Firestore was unreachable, or the read timed out.
  static const offline = 'offline';

  /// Security rules do not expose `subscription_plans` to this client.
  static const permissionDenied = 'permissionDenied';
}
