import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/repositories/dashboard_repositories.dart';
import '../../domain/usecases/load_dashboard_home.dart';
import 'dashboard_state.dart';
export 'dashboard_state.dart';

/// Home loading and transactional favorite editing share one state owner.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required DashboardHomeRepository repository})
    : _loadHome = LoadDashboardHome(repository),
      super(const DashboardInitial());
  static const maxFavorites = 8;
  LoadDashboardHome _loadHome;
  int _request = 0;
  Future<void> load() async {
    final token = ++_request;
    emit(const DashboardLoading());
    final result = await _loadHome();
    if (isClosed || token != _request) {
      return;
    }
    switch (result) {
      case Err(:final failure):
        emit(DashboardError(failure));
      case Success(:final data):
        emit(
          data == null
              ? const DashboardEmpty()
              : DashboardLoaded(
                  data: data.withFavorites(
                    data.favorites.toSet().take(maxFavorites),
                  ),
                ),
        );
    }
  }

  Future<void> changeRepository(DashboardHomeRepository repository) {
    _loadHome = LoadDashboardHome(repository);
    return load();
  }

  void edit({Iterable<String> suggestions = const []}) {
    final current = state;
    if (current is! DashboardLoaded) return;
    emit(
      DashboardLoaded(
        data: current.data,
        draft: current.favorites.isEmpty
            ? suggestions.toSet().take(maxFavorites)
            : current.favorites,
      ),
    );
  }

  void add(String id) {
    final current = state;
    if (current is! DashboardLoaded ||
        current.draft == null ||
        current.draft!.length >= maxFavorites ||
        current.draft!.contains(id)) {
      return;
    }
    emit(DashboardLoaded(data: current.data, draft: [...current.draft!, id]));
  }

  void remove(String id) {
    final current = state;
    if (current is! DashboardLoaded || current.draft == null) return;
    emit(
      DashboardLoaded(
        data: current.data,
        draft: current.draft!.where((item) => item != id),
      ),
    );
  }

  void confirm() {
    final current = state;
    if (current is DashboardLoaded) {
      emit(
        DashboardLoaded(
          data: current.data.withFavorites(current.visibleFavorites),
        ),
      );
    }
  }

  void cancel() {
    final current = state;
    if (current is DashboardLoaded) {
      emit(DashboardLoaded(data: current.data));
    }
  }

  void reset() {
    final current = state;
    if (current is DashboardLoaded) {
      emit(DashboardLoaded(data: current.data.withFavorites([])));
    }
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
