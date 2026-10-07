import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/error_handeler.dart';
import '../../../../core/unified_api/error/failure.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_session_store.dart';
import '../models/onboarding_session.dart';

@Injectable(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._store);

  final OnboardingSessionStore _store;

  /// [OnboardingSessionStore.read] never throws: an unreadable row is a device
  /// that has not seen the funnel yet.
  @override
  Future<Either<Failure, OnboardingSession>> readSession() async {
    return Right(await _store.read());
  }

  @override
  Future<Either<Failure, void>> markOnboardingSeen() {
    return _mark((session) => session.copyWith(seen: true));
  }

  @override
  Future<Either<Failure, void>> markTrialCompleted() {
    return _mark((session) => session.copyWith(trialCompleted: true));
  }

  @override
  Future<Either<Failure, void>> resetFunnel() async {
    try {
      await _store.write(OnboardingSession.empty);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e).failure);
    }
  }

  /// Reads the stored session, flips the one flag it owns and writes it back.
  Future<Either<Failure, void>> _mark(OnboardingSession Function(OnboardingSession) update) async {
    try {
      final current = await _store.read();
      final next = update(current);
      if (next == current) return const Right(null);
      await _store.write(next);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e).failure);
    }
  }
}
