import 'package:equatable/equatable.dart';

import '../../../../core/utils/request_status.dart';
import '../../data/models/license_error_codes.dart';
import '../../data/models/license_session.dart';

enum LicensePhase { checking, needsLicense, active }

class LicenseState extends Equatable {
  const LicenseState({
    this.phase = LicensePhase.checking,
    this.checkStatus = RequestStatus.init,
    this.session,
    this.deviceId,
    this.errorCode,
  });

  final LicensePhase phase;
  final RequestStatus checkStatus;
  final LicenseSession? session;
  final String? deviceId;
  final String? errorCode;

  bool get isActive => phase == LicensePhase.active;

  LicenseState copyWith({
    LicensePhase? phase,
    RequestStatus? checkStatus,
    LicenseSession? session,
    String? deviceId,
    String? errorCode,
    bool clearError = false,
  }) {
    return LicenseState(
      phase: phase ?? this.phase,
      checkStatus: checkStatus ?? this.checkStatus,
      session: session ?? this.session,
      deviceId: deviceId ?? this.deviceId,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }

  @override
  List<Object?> get props => [phase, checkStatus, session, deviceId, errorCode];
}

String licenseErrorMessageKey(String? code) {
  switch (code) {
    case LicenseErrorCodes.pending:
      return 'license.errorPending';
    case LicenseErrorCodes.invalid:
      return 'license.errorInvalid';
    case LicenseErrorCodes.inactive:
      return 'license.errorInactive';
    case LicenseErrorCodes.expired:
      return 'license.errorExpired';
    case LicenseErrorCodes.offline:
      return 'license.errorOffline';
    default:
      return 'license.errorUnknown';
  }
}
