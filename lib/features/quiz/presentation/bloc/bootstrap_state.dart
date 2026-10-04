import 'package:equatable/equatable.dart';

import '../../../../core/utils/request_status.dart';

class BootstrapState extends Equatable {
  const BootstrapState({this.status = RequestStatus.init, this.progress = 0});

  final RequestStatus status;

  /// Fill of the splash progress bar, 0–1. Only ever moves forward.
  final double progress;

  /// Whole percent for the splash readout.
  int get progressPercent => (progress * 100).round().clamp(0, 100);

  @override
  List<Object?> get props => [status, progress];

  BootstrapState copyWith({RequestStatus? status, double? progress}) {
    return BootstrapState(status: status ?? this.status, progress: progress ?? this.progress);
  }
}
