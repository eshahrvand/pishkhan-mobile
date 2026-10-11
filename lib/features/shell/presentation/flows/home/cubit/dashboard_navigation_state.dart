import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/shared/widgets/app_primary_navigation.dart';

part 'dashboard_navigation_state.freezed.dart';

@freezed
abstract class DashboardNavigationState with _$DashboardNavigationState {
  const factory DashboardNavigationState({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(AppPrimaryTab.dashboard) AppPrimaryTab selectedTab,
  }) = _DashboardNavigationState;
}
