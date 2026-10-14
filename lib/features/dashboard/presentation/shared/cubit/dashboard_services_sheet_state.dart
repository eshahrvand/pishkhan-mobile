part of 'dashboard_services_sheet_cubit.dart';

@freezed
abstract class DashboardServicesSheetState with _$DashboardServicesSheetState {
  const factory DashboardServicesSheetState.initial({
    @Default('') String query,
    @Default(<DashboardCategory>{}) Set<DashboardCategory> collapsedCategories,
  }) = _DashboardServicesSheetState;
}
