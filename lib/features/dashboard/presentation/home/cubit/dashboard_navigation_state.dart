part of 'dashboard_navigation_cubit.dart';

@freezed
abstract class DashboardNavigationState with _$DashboardNavigationState {
  const factory DashboardNavigationState.initial({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(AppPrimaryTab.dashboard) AppPrimaryTab selectedTab,
  }) = _DashboardNavigationState;
}
