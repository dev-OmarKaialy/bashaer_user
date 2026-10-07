import 'package:equatable/equatable.dart';

import '../../../../core/utils/request_status.dart';
import '../../data/models/onboarding_session.dart';
import '../../../quiz/data/models/question_model.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = RequestStatus.init,
    this.session,
    this.trialStatus = RequestStatus.init,
    this.trialQuestions = const [],
  });

  /// Reading the saved funnel state.
  final RequestStatus status;
  final OnboardingSession? session;

  /// Loading the free-trial questions.
  final RequestStatus trialStatus;
  final List<QuestionModel> trialQuestions;

  OnboardingState copyWith({
    RequestStatus? status,
    OnboardingSession? session,
    RequestStatus? trialStatus,
    List<QuestionModel>? trialQuestions,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      session: session ?? this.session,
      trialStatus: trialStatus ?? this.trialStatus,
      trialQuestions: trialQuestions ?? this.trialQuestions,
    );
  }

  @override
  List<Object?> get props => [status, session, trialStatus, trialQuestions];
}
