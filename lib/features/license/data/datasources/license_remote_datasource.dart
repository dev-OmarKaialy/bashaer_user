import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/extensions/log_colors_extension.dart';
import '../../../../core/unified_api/error/error_handeler.dart';
import '../../../../core/unified_api/error/failure.dart';
import '../models/license_error_codes.dart';
import '../models/license_session.dart';

/// Reads / creates rows on the Firestore `licenses` collection.
///
/// Each document's id **is** the `deviceId` (natural key), which makes lookups
/// a direct `doc(deviceId).get()` and gives Firestore uniqueness for free.
abstract class LicenseRemoteDatasource {
  Future<LicenseRecord?> findByDeviceId(String deviceId);

  /// Creates a pending access request (`isActive: false`) for this device.
  ///
  /// Only creates the row when it does not exist yet; otherwise returns the
  /// existing one (an approved license must never be overwritten).
  Future<LicenseRecord> createRequest({required String deviceId});
}

@Injectable(as: LicenseRemoteDatasource)
class LicenseRemoteDatasourceImpl implements LicenseRemoteDatasource {
  LicenseRemoteDatasourceImpl();

  static const _licensesCollection = 'licenses';

  @override
  Future<LicenseRecord?> findByDeviceId(String deviceId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_licensesCollection)
          .doc(deviceId)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return LicenseRecord.fromFirestore(doc.data()!);
    } on FirebaseException catch (e) {
      log('License find failed: ${e.message}'.logYellow);
      throw _offlineFailure(e);
    }
  }

  @override
  Future<LicenseRecord> createRequest({required String deviceId}) async {
    final document = FirebaseFirestore.instance.collection(_licensesCollection).doc(deviceId);

    try {
      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(document);
        if (snapshot.exists && snapshot.data() != null) {
          return LicenseRecord.fromFirestore(snapshot.data()!);
        }

        final request = <String, dynamic>{
          'deviceId': deviceId,
          'isActive': false,
          'createdAt': FieldValue.serverTimestamp(),
          // Optional profile fields — enable when the UI collects them:
          // if (fullName != null && fullName.trim().isNotEmpty) 'fullName': fullName.trim(),
          // if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          //   'phoneNumber': phoneNumber.trim(),
        };
        transaction.set(document, request);
        return LicenseRecord.fromFirestore(request);
      });
    } on FirebaseException catch (e) {
      log('License create failed: ${e.message}'.logYellow);
      throw _offlineFailure(e);
    }
  }

  ServerFailure _offlineFailure(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return const ServerFailure(
        message: LicenseErrorCodes.offline,
        statusCode: ResponseCode.DEFAULT,
      );
    }
    return const ServerFailure(
      message: LicenseErrorCodes.offline,
      statusCode: ResponseCode.NO_INTERNET_CONNECTION,
    );
  }
}
