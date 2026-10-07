import 'package:equatable/equatable.dart';

/// Device-local funnel state: has this device seen the intro, and has the free
/// trial been finished. Stored per device so the funnel runs once.
class OnboardingSession extends Equatable {
  const OnboardingSession({required this.seen, required this.trialCompleted});

  /// What a device that never went through the funnel reads as.
  static const empty = OnboardingSession(seen: false, trialCompleted: false);

  final bool seen;
  final bool trialCompleted;

  OnboardingSession copyWith({bool? seen, bool? trialCompleted}) {
    return OnboardingSession(
      seen: seen ?? this.seen,
      trialCompleted: trialCompleted ?? this.trialCompleted,
    );
  }

  Map<String, dynamic> toStorageMap() => {'seen': seen, 'trialCompleted': trialCompleted};

  factory OnboardingSession.fromStorageMap(Map<String, dynamic> map) {
    return OnboardingSession(
      seen: map['seen'] == true,
      trialCompleted: map['trialCompleted'] == true,
    );
  }

  @override
  List<Object?> get props => [seen, trialCompleted];
}
