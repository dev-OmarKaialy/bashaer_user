import 'package:dartz/dartz.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../data/models/license_session.dart';

abstract class LicenseRepository {
  /// Cold-start check: online validate by device id, or offline grace from local session.
  Future<Either<Failure, LicenseSession>> ensureValidSession();

  Future<String> currentDeviceId();
}
