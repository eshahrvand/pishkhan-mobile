import 'dashboard_navigation_state.dart';
export 'dashboard_navigation_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/shared/widgets/app_primary_navigation.dart';

class DashboardNavigationCubit extends Cubit<DashboardNavigationState> {
  DashboardNavigationCubit() : super(const DashboardNavigationState());
  void select(AppPrimaryTab tab) => emit(state.copyWith(selectedTab: tab));
}
