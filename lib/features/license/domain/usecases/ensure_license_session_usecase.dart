import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/unified_api/error/failure.dart';
import '../../data/models/license_session.dart';
import '../repositories/license_repository.dart';

@lazySingleton
class EnsureLicenseSessionUsecase implements UseCase<LicenseSession, NoParams> {
  const EnsureLicenseSessionUsecase(this._repository);

  final LicenseRepository _repository;

  @override
  Future<Either<Failure, LicenseSession>> call(NoParams params) {
    return _repository.ensureValidSession();
  }
}
