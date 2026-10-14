import '../../shared/dashboard_services.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/dashboard_home_data.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/repositories/dashboard_repositories.dart';
import '../../../domain/usecases/home.dart';

part 'dashboard_state.dart';
part 'dashboard_cubit.freezed.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    DashboardState initialState = const DashboardState.initial(),
    required DashboardHomeRepository repository,
  }) : _loadHome = LoadDashboardHome(repository),
       super(initialState) {
    final favorites =
        initialState.draft ?? initialState.data?.favorites ?? const <String>[];
    final services = getServices(favorites);
    emit(
      state.copyWith(
        activeFavorites: favorites,
        favoriteServices: services,
        fixedServices: getServices(
          initialState.data?.fixedServiceIds ?? const [],
        ),
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }
  static const maxFavorites = 8;
  LoadDashboardHome _loadHome;
  int _request = 0;

  Future<void> load() async {
    final token = ++_request;
    emit(
      state.copyWith(
        status: RequestStatus.loading,
        data: null,
        draft: null,
        failure: null,
        activeFavorites: const [],
        favoriteServices: const [],
        fixedServices: const [],
        canAddFavorite: true,
        isFavoritesLimitReached: false,
      ),
    );
    final result = await _loadHome();
    if (isClosed || token != _request) return;
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: RequestStatus.failure, failure: failure));
      case Success(:final data):
        final home = data?.withFavorites(
          data.favorites.toSet().take(maxFavorites),
        );
        final favorites = home?.favorites ?? const <String>[];
        final services = getServices(favorites);
        emit(
          state.copyWith(
            status: RequestStatus.success,
            data: home,
            activeFavorites: favorites,
            favoriteServices: services,
            fixedServices: getServices(home?.fixedServiceIds ?? const []),
            canAddFavorite: services.length < maxFavorites,
            isFavoritesLimitReached: favorites.length == maxFavorites,
          ),
        );
    }
  }

  Future<void> changeRepository(DashboardHomeRepository repository) {
    _loadHome = LoadDashboardHome(repository);
    return load();
  }

  void edit({Iterable<String> suggestions = const []}) {
    if (state.status != RequestStatus.success || state.data == null) return;
    final favorites = state.data!.favorites.isEmpty
        ? suggestions.toSet().take(maxFavorites).toList()
        : state.data!.favorites;
    final services = getServices(favorites);
    emit(
      state.copyWith(
        draft: favorites,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void add(String id) {
    if (state.status != RequestStatus.success ||
        state.data == null ||
        state.draft == null ||
        state.draft!.length >= maxFavorites ||
        state.draft!.contains(id)) {
      return;
    }
    final favorites = [...state.draft!, id];
    final services = getServices(favorites);
    emit(
      state.copyWith(
        draft: favorites,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void remove(String id) {
    if (state.status != RequestStatus.success ||
        state.data == null ||
        state.draft == null) {
      return;
    }
    final favorites = state.draft!.where((item) => item != id).toList();
    final services = getServices(favorites);
    emit(
      state.copyWith(
        draft: favorites,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void confirm() {
    if (state.status != RequestStatus.success || state.data == null) return;
    final favorites = state.draft ?? state.data!.favorites;
    final services = getServices(favorites);
    emit(
      state.copyWith(
        data: state.data!.withFavorites(favorites),
        draft: null,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void cancel() {
    if (state.status != RequestStatus.success || state.data == null) return;
    final favorites = state.data!.favorites;
    final services = getServices(favorites);
    emit(
      state.copyWith(
        draft: null,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void reset() {
    if (state.status != RequestStatus.success || state.data == null) return;
    emit(
      state.copyWith(
        data: state.data!.withFavorites([]),
        draft: null,
        activeFavorites: const [],
        favoriteServices: const [],
        canAddFavorite: true,
        isFavoritesLimitReached: false,
      ),
    );
  }

  List<DashboardService> getServices(List<String> ids) {
    return [
      for (final id in ids)
        for (final service in DashboardService.values)
          if (service.id == id) service,
    ];
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
