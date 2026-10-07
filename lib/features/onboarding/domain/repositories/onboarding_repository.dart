import 'package:dartz/dartz.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../data/models/onboarding_session.dart';

abstract class OnboardingRepository {
  /// Funnel state saved on this device; a fresh install reads as "not seen".
  Future<Either<Failure, OnboardingSession>> readSession();

  /// Records that the intro was shown. Idempotent — replaying it never clears
  /// the free-trial flag.
  Future<Either<Failure, void>> markOnboardingSeen();

  /// Records that the free trial was finished.
  Future<Either<Failure, void>> markTrialCompleted();

  /// Clears intro + trial flags so the device can re-run the full funnel
  /// (onboarding then free trial) from the license gate.
  Future<Either<Failure, void>> resetFunnel();
}
