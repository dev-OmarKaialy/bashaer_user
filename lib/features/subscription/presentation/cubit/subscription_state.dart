import 'package:equatable/equatable.dart';

import '../../../../core/utils/request_status.dart';
import '../../data/models/subscription_plan.dart';

class SubscriptionState extends Equatable {
  const SubscriptionState({this.status = RequestStatus.init, this.plan});

  final RequestStatus status;

  /// Null until the school publishes a plan with a usable price.
  final SubscriptionPlan? plan;

  SubscriptionState copyWith({RequestStatus? status, SubscriptionPlan? plan}) {
    return SubscriptionState(status: status ?? this.status, plan: plan ?? this.plan);
  }

  @override
  List<Object?> get props => [status, plan];
}
