import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/request_status.dart';
import '../../domain/repositories/license_repository.dart';
import '../../domain/usecases/ensure_license_session_usecase.dart';
import 'license_state.dart';

@injectable
class LicenseCubit extends Cubit<LicenseState> {
  LicenseCubit({
    required EnsureLicenseSessionUsecase ensureSession,
    required LicenseRepository repository,
  }) : _ensureSession = ensureSession,
       _repository = repository,
       super(const LicenseState());

  final EnsureLicenseSessionUsecase _ensureSession;
  final LicenseRepository _repository;

  Future<void> checkSession() async {
    if (state.checkStatus.isLoading) return;
    emit(
      state.copyWith(
        phase: LicensePhase.checking,
        checkStatus: RequestStatus.loading,
        clearError: true,
      ),
    );

    final deviceId = await _repository.currentDeviceId();
    if (isClosed) return;

    final result = await _ensureSession(NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          phase: LicensePhase.needsLicense,
          checkStatus: RequestStatus.failed,
          deviceId: deviceId,
          errorCode: failure.message,
        ),
      ),
      (session) => emit(
        state.copyWith(
          phase: LicensePhase.active,
          checkStatus: RequestStatus.success,
          session: session,
          deviceId: session.deviceId,
          clearError: true,
        ),
      ),
    );
  }
}
