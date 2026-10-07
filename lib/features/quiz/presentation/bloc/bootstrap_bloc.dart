import 'dart:async';
import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/utils/request_status.dart';
import '../../domain/usecases/sync_question_bank_usecase.dart';
import 'bootstrap_event.dart';
import 'bootstrap_state.dart';

/// Startup-only sync of the question bank from Firestore into Hive.
///
/// Drives a determinate progress bar: the sync reports how far it got, and the
/// bar is additionally paced by [minDisplayDuration] so an instant sync still
/// fills smoothly from 0 to 100% instead of flashing past.
@injectable
class BootstrapBloc extends Bloc<BootstrapEvent, BootstrapState> {
  BootstrapBloc({required SyncQuestionBankUsecase syncQuestionBank})
    : _syncQuestionBank = syncQuestionBank,
      super(const BootstrapState()) {
    on<SyncBankEvent>(_onSync);
  }

  final SyncQuestionBankUsecase _syncQuestionBank;

  /// Floor for how long the splash stays visible, even when sync is instant.
  static const minDisplayDuration = Duration(milliseconds: 1200);

  /// How often the bar is advanced while waiting.
  static const _tick = Duration(milliseconds: 50);

  /// Where the bar waits when the sync outruns the clock, so it never sits at
  /// 100% while work is still in flight.
  static const _pendingCeiling = 0.92;

  /// The bar animates each change over `AppTheme.animationSlow`; hold the
  /// splash that long after reaching 100% so the car visibly arrives before
  /// the screen is replaced.
  static const _barSettleDuration = Duration(milliseconds: 300);

  Future<void> _onSync(SyncBankEvent event, Emitter<BootstrapState> emit) async {
    if (state.status.isLoading) return;

    emit(state.copyWith(status: RequestStatus.loading, progress: 0));

    // Real progress reported by the repository as each stage completes.
    var reported = 0.0;
    Either<Failure, void>? outcome;
    unawaited(
      _syncQuestionBank(
        SyncQuestionBankParams(onProgress: (progress) => reported = progress),
      ).then((value) => outcome = value),
    );

    final started = DateTime.now();
    var shown = 0.0;
    while (!isClosed) {
      await Future<void>.delayed(_tick);
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      final byTime = (elapsed / minDisplayDuration.inMilliseconds).clamp(0.0, 1.0);
      final finished = outcome != null;

      // The bar follows whichever is further along — real progress or the
      // minimum-duration clock — but only reaches 100% once the sync is done
      // and the floor has passed.
      final next = finished ? byTime : math.min(math.max(reported, byTime), _pendingCeiling);
      shown = math.max(shown, next);

      if (isClosed) return;
      emit(state.copyWith(progress: shown));
      if (finished && shown >= 1) break;
    }
    if (isClosed) return;

    final failed = outcome?.isLeft() ?? true;
    if (failed) {
      emit(state.copyWith(status: RequestStatus.failed));
      return;
    }
    emit(state.copyWith(progress: 1));
    await Future<void>.delayed(_barSettleDuration);
    if (isClosed) return;
    emit(state.copyWith(status: RequestStatus.success, progress: 1));
  }
}
