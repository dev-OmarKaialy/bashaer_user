import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/request_status.dart';
import '../../../quiz/domain/usecases/get_trial_questions_usecase.dart';
import '../../domain/usecases/complete_free_trial_usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import '../../domain/usecases/get_onboarding_session_usecase.dart';
import '../../domain/usecases/reset_funnel_usecase.dart';
import 'onboarding_state.dart';

/// Owns the first-run funnel: which step this device has to see, and the
/// questions the free trial runs on.
@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required GetOnboardingSessionUsecase getSession,
    required CompleteOnboardingUsecase completeOnboarding,
    required CompleteFreeTrialUsecase completeFreeTrial,
    required ResetFunnelUsecase resetFunnel,
    required GetTrialQuestionsUsecase getTrialQuestions,
  }) : _getSession = getSession,
       _completeOnboarding = completeOnboarding,
       _completeFreeTrial = completeFreeTrial,
       _resetFunnel = resetFunnel,
       _getTrialQuestions = getTrialQuestions,
       super(const OnboardingState());

  final GetOnboardingSessionUsecase _getSession;
  final CompleteOnboardingUsecase _completeOnboarding;
  final CompleteFreeTrialUsecase _completeFreeTrial;
  final ResetFunnelUsecase _resetFunnel;
  final GetTrialQuestionsUsecase _getTrialQuestions;

  /// Reads where this device left the funnel.
  Future<void> loadSession() async {
    if (state.status.isLoading) return;
    emit(state.copyWith(status: RequestStatus.loading));

    final result = await _getSession(NoParams());
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(status: RequestStatus.failed)),
      (session) => emit(state.copyWith(status: RequestStatus.success, session: session)),
    );
  }

  /// Loads the questions the free trial shows.
  Future<void> loadTrialQuestions() async {
    if (state.trialStatus.isLoading) return;
    emit(state.copyWith(trialStatus: RequestStatus.loading));

    final result = await _getTrialQuestions(NoParams());
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(trialStatus: RequestStatus.failed)),
      (questions) =>
          emit(state.copyWith(trialStatus: RequestStatus.success, trialQuestions: questions)),
    );
  }

  /// Records that the intro was shown, then refreshes the stored session.
  ///
  /// A failed write must not trap the student on this screen, so the funnel
  /// moves on either way and the stored session stays the source of truth.
  Future<void> startFreeTrial() async {
    // The CTA keys its busy state off this, so it shows a spinner and blocks a
    // second tap while the session write is in flight.
    emit(state.copyWith(status: RequestStatus.loading));
    await _completeOnboarding(NoParams());
    await _refreshSession();
  }

  /// Records that the free trial was finished, then refreshes the stored
  /// session. Like [startFreeTrial], it moves on even if the write failed.
  Future<void> completeFreeTrial() async {
    await _completeFreeTrial(NoParams());
    await _refreshSession();
  }

  /// Clears intro + trial flags so an unlicensed device can re-run the funnel.
  Future<void> resetFunnel() async {
    emit(state.copyWith(status: RequestStatus.loading));
    await _resetFunnel(NoParams());
    await _refreshSession();
  }

  Future<void> _refreshSession() async {
    final result = await _getSession(NoParams());
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(status: RequestStatus.failed)),
      (session) => emit(state.copyWith(status: RequestStatus.success, session: session)),
    );
  }
}
