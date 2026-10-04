import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/error_handeler.dart';
import '../../../../core/unified_api/error/failure.dart';
import '../../domain/repositories/license_repository.dart';
import '../datasources/device_id_service.dart';
import '../datasources/license_remote_datasource.dart';
import '../datasources/license_session_store.dart';
import '../models/license_error_codes.dart';
import '../models/license_session.dart';

@Injectable(as: LicenseRepository)
class LicenseRepositoryImpl implements LicenseRepository {
  LicenseRepositoryImpl(this._remote, this._sessionStore, this._deviceIdService);

  final LicenseRemoteDatasource _remote;
  final LicenseSessionStore _sessionStore;
  final DeviceIdService _deviceIdService;

  @override
  Future<String> currentDeviceId() => _deviceIdService.getDeviceId();

  @override
  Future<Either<Failure, LicenseSession>> ensureValidSession() async {
    try {
      final deviceId = await _deviceIdService.getDeviceId();
      if (deviceId.isEmpty || deviceId.startsWith('unknown-')) {
        return const Left(ServerFailure(message: LicenseErrorCodes.invalid));
      }

      final local = await _sessionStore.read();
      if (local != null && local.deviceId.isNotEmpty && local.deviceId != deviceId) {
        await _sessionStore.clear();
      }

      var graceCandidate = await _sessionStore.read();
      if (graceCandidate != null && graceCandidate.isExpired) {
        await _sessionStore.clear();
        graceCandidate = null;
      }

      try {
        var record = await _remote.findByDeviceId(deviceId);
        record ??= await _remote.createRequest(
          deviceId: deviceId,
          // fullName: fullName,
          // phoneNumber: phoneNumber,
        );

        final evaluated = _evaluate(record);
        if (evaluated.isLeft()) {
          await _sessionStore.clear();
          return evaluated;
        }

        final session = evaluated.getOrElse(() => throw StateError('expected license session'));
        await _sessionStore.write(session);
        return Right(session);
      } on ServerFailure catch (e) {
        final isOffline =
            e.message == LicenseErrorCodes.offline ||
            e.statusCode == ResponseCode.NO_INTERNET_CONNECTION;
        if (isOffline &&
            graceCandidate != null &&
            graceCandidate.deviceId == deviceId &&
            !graceCandidate.isExpired) {
          return Right(graceCandidate);
        }
        if (!isOffline) {
          await _sessionStore.clear();
        }
        return Left(e);
      }
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ErrorHandler.handle(e).failure);
    }
  }

  Either<Failure, LicenseSession> _evaluate(LicenseRecord record) {
    if (record.deviceId.isEmpty) {
      return const Left(ServerFailure(message: LicenseErrorCodes.invalid));
    }
    if (!record.isActive) {
      // Never approved → pending request; previously approved then killed → inactive.
      if (record.activeUntil == null) {
        return const Left(ServerFailure(message: LicenseErrorCodes.pending));
      }
      return const Left(ServerFailure(message: LicenseErrorCodes.inactive));
    }
    final until = record.activeUntil;
    if (until == null) {
      return const Left(ServerFailure(message: LicenseErrorCodes.pending));
    }
    final session = LicenseSession(deviceId: record.deviceId, activeUntil: until);
    if (session.isExpired) {
      return const Left(ServerFailure(message: LicenseErrorCodes.expired));
    }
    return Right(session);
  }
}
