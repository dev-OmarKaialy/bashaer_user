import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/request_status.dart';
import '../../domain/usecases/get_monthly_plan_usecase.dart';
import 'subscription_state.dart';

/// Loads the monthly plan shown on the subscribe screen.
@injectable
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this._getMonthlyPlan) : super(const SubscriptionState());

  final GetMonthlyPlanUsecase _getMonthlyPlan;

  Future<void> loadPlan() async {
    if (state.status.isLoading) return;
    emit(state.copyWith(status: RequestStatus.loading));

    final result = await _getMonthlyPlan(NoParams());
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(status: RequestStatus.failed)),
      (plan) => emit(state.copyWith(status: RequestStatus.success, plan: plan)),
    );
  }
}
