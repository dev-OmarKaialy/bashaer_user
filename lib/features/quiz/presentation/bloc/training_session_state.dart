import 'package:equatable/equatable.dart';

import '../../../../core/utils/request_status.dart';
import '../../data/models/training_session_model.dart';

class TrainingSessionState extends Equatable {
  const TrainingSessionState({
    this.loadStatus = RequestStatus.init,
    this.startStatus = RequestStatus.init,
    this.session,
    this.finishedSession,
    this.history = const [],
    this.streak = 0,
  });

  final RequestStatus loadStatus;
  final RequestStatus startStatus;

  /// The unfinished session, or null when none is running.
  final TrainingSessionModel? session;

  /// The session that most recently ended, for the results screen.
  final TrainingSessionModel? finishedSession;

  /// Ended sessions, newest first.
  final List<TrainingSessionModel> history;

  /// Correct answers in a row, carried from one category to the next. Kept in
  /// memory only, since sessions are not resumed.
  final int streak;

  bool get hasActiveSession => session != null;

  @override
  List<Object?> get props => [loadStatus, startStatus, session, finishedSession, history, streak];

  TrainingSessionState copyWith({
    RequestStatus? loadStatus,
    RequestStatus? startStatus,
    TrainingSessionModel? session,
    bool clearSession = false,
    TrainingSessionModel? finishedSession,
    List<TrainingSessionModel>? history,
    int? streak,
  }) {
    return TrainingSessionState(
      loadStatus: loadStatus ?? this.loadStatus,
      startStatus: startStatus ?? this.startStatus,
      session: clearSession ? null : (session ?? this.session),
      finishedSession: finishedSession ?? this.finishedSession,
      history: history ?? this.history,
      streak: streak ?? this.streak,
    );
  }
}
