import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/shared/widgets/app_primary_navigation.dart';

class DashboardNavigationState extends Equatable {
  const DashboardNavigationState({this.selectedTab = AppPrimaryTab.dashboard});
  final AppPrimaryTab selectedTab;
  @override
  List<Object?> get props => [selectedTab];
}

class DashboardNavigationCubit extends Cubit<DashboardNavigationState> {
  DashboardNavigationCubit() : super(const DashboardNavigationState());
  void select(AppPrimaryTab tab) =>
      emit(DashboardNavigationState(selectedTab: tab));
}
