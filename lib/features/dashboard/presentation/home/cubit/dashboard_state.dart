part of 'dashboard_cubit.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState.initial({
    @Default(<String>[]) List<String> activeFavorites,
    @Default(<DashboardService>[]) List<DashboardService> favoriteServices,
    @Default(<DashboardService>[]) List<DashboardService> fixedServices,
    @Default(true) bool canAddFavorite,
    @Default(false) bool isFavoritesLimitReached,
    @Default(RequestStatus.initial) RequestStatus status,
    DashboardHomeData? data,
    List<String>? draft,
    Failure? failure,
  }) = _DashboardState;
}
