import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';

part 'dashboard_navigation_state.dart';
part 'dashboard_navigation_cubit.freezed.dart';

class DashboardNavigationCubit extends Cubit<DashboardNavigationState> {
  DashboardNavigationCubit({
    DashboardNavigationState initialState =
        const DashboardNavigationState.initial(),
  }) : super(initialState);
  void select(AppPrimaryTab tab) => emit(state.copyWith(selectedTab: tab));
}
