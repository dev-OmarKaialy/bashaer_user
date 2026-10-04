import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Local cache of an approved license for offline grace.
class LicenseSession extends Equatable {
  const LicenseSession({required this.deviceId, required this.activeUntil});

  final String deviceId;
  final DateTime activeUntil;

  bool get isExpired {
    return DateTime.now().toUtc().isAfter(activeUntil);
  }

  Map<String, String> toStorageMap() => {
    'deviceId': deviceId,
    'activeUntil': activeUntil.toUtc().toIso8601String(),
  };

  factory LicenseSession.fromStorageMap(Map<String, String> map) {
    return LicenseSession(
      deviceId: map['deviceId'] ?? '',
      activeUntil: DateTime.parse(map['activeUntil']!),
    );
  }

  factory LicenseSession.fromRecord(LicenseRecord record) {
    final until = record.activeUntil;
    if (until == null) {
      throw StateError('LicenseRecord has no activeUntil');
    }
    return LicenseSession(deviceId: record.deviceId, activeUntil: until);
  }

  @override
  List<Object?> get props => [deviceId, activeUntil];
}

/// One row from the Firestore `licenses` collection.
class LicenseRecord extends Equatable {
  const LicenseRecord({
    required this.deviceId,
    required this.isActive,
    this.activeUntil,
    this.objectId,
    // Optional profile fields (doc fields exist; app wiring stays commented):
    // this.fullName,
    // this.phoneNumber,
  });

  final String? objectId;
  final String deviceId;
  final bool isActive;
  final DateTime? activeUntil;
  // final String? fullName;
  // final String? phoneNumber;

  factory LicenseRecord.fromFirestore(Map<String, dynamic> object) {
    return LicenseRecord(
      objectId: object['id']?.toString() ?? object['objectId']?.toString(),
      deviceId: object['deviceId']?.toString() ?? '',
      isActive: object['isActive'] == true,
      activeUntil: parseLicenseDate(object['activeUntil']),
      // fullName: object['fullName']?.toString(),
      // phoneNumber: object['phoneNumber']?.toString(),
    );
  }

  @override
  List<Object?> get props => [objectId, deviceId, isActive, activeUntil];
}

DateTime? parseLicenseDate(Object? raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw.toUtc();
  if (raw is Timestamp) return raw.toDate().toUtc();
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed)?.toUtc();
  }
  if (raw is Map) {
    final iso = raw['iso'];
    if (iso is String && iso.isNotEmpty) {
      return DateTime.tryParse(iso.trim())?.toUtc();
    }
  }
  return null;
}
