import 'package:equatable/equatable.dart';

/// One row from the Firestore `subscription_plans` collection: what the school
/// offers for the price it set.
class SubscriptionPlan extends Equatable {
  const SubscriptionPlan({
    required this.id,
    required this.price,
    required this.currency,
    this.title,
    this.features = const [],
  });

  /// The plan the subscribe screen shows.
  static const String monthlyId = 'monthly';

  final String id;

  /// Price in whole currency units, e.g. `5` for 5 USD.
  final double price;

  /// ISO code the price is in, e.g. `USD`.
  final String currency;

  /// Optional plan name from Firestore; the screen has its own title.
  final String? title;

  /// Optional bullet list from Firestore. Empty means "use the built-in list".
  final List<String> features;

  /// `5 USD`, or null when the school published no usable price.
  String? get priceLabel {
    if (price <= 0 || currency.isEmpty) return null;
    final amount = price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return '$amount $currency';
  }

  Map<String, dynamic> toStorageMap() => {
    'id': id,
    'price': price,
    'currency': currency,
    'title': title,
    'features': features,
  };

  factory SubscriptionPlan.fromStorageMap(Map<String, dynamic> map) {
    return SubscriptionPlan(
      id: map['id']?.toString() ?? '',
      // A corrupt price reads as 0, which [priceLabel] renders as "unavailable".
      price: _priceOf(map['price']) ?? 0,
      currency: map['currency']?.toString() ?? '',
      title: map['title']?.toString(),
      features: _featuresOf(map['features']),
    );
  }

  /// Builds a plan from a `subscription_plans/{planId}` document, or returns
  /// null when it carries no price the app can show.
  static SubscriptionPlan? fromFirestore(
    Map<String, dynamic> object, {
    required String fallbackId,
  }) {
    final price = _priceOf(object['price']);
    final currency = object['currency']?.toString().trim() ?? '';
    if (price == null || price <= 0 || currency.isEmpty) return null;
    return SubscriptionPlan(
      id: object['planId']?.toString() ?? object['id']?.toString() ?? fallbackId,
      price: price,
      currency: currency,
      title: object['title']?.toString(),
      features: _featuresOf(object['features']),
    );
  }

  static double? _priceOf(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.trim());
    return null;
  }

  static List<String> _featuresOf(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
  }

  @override
  List<Object?> get props => [id, price, currency, title, features];
}
