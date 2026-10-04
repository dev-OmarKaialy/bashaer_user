import 'package:equatable/equatable.dart';

sealed class BootstrapEvent extends Equatable {
  const BootstrapEvent();

  @override
  List<Object?> get props => [];
}

final class SyncBankEvent extends BootstrapEvent {
  const SyncBankEvent();
}
