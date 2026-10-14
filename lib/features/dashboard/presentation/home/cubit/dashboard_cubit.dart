import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/repositories/dashboard_repositories.dart';
import '../../../domain/usecases/home.dart';
import 'dashboard_state.dart';
export 'dashboard_state.dart';

/// Home loading and transactional favorite editing share one state owner.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    DashboardState initialState = const DashboardState(),
    required DashboardHomeRepository repository,
  }) : _loadHome = LoadDashboardHome(repository),
       super(initialState);
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
      ),
    );
    final result = await _loadHome();
    if (isClosed || token != _request) {
      return;
    }
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: RequestStatus.failure, failure: failure));
      case Success(:final data):
        emit(
          state.copyWith(
            status: RequestStatus.success,
            data: data?.withFavorites(
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
    if (current.status != RequestStatus.success || current.data == null) return;
    emit(
      current.copyWith(
        draft: current.data!.favorites.isEmpty
            ? suggestions.toSet().take(maxFavorites).toList()
            : current.data!.favorites,
      ),
    );
  }

  void add(String id) {
    final current = state;
    if (current.status != RequestStatus.success ||
        current.data == null ||
        current.draft == null ||
        current.draft!.length >= maxFavorites ||
        current.draft!.contains(id)) {
      return;
    }
    emit(current.copyWith(draft: [...current.draft!, id]));
  }

  void remove(String id) {
    final current = state;
    if (current.status != RequestStatus.success ||
        current.data == null ||
        current.draft == null) {
      return;
    }
    emit(
      current.copyWith(
        draft: current.draft!.where((item) => item != id).toList(),
      ),
    );
  }

  void confirm() {
    final current = state;
    if (current.status == RequestStatus.success && current.data != null) {
      emit(
        current.copyWith(
          data: current.data!.withFavorites(
            current.draft ?? current.data!.favorites,
          ),
          draft: null,
        ),
      );
    }
  }

  void cancel() {
    final current = state;
    if (current.status == RequestStatus.success && current.data != null) {
      emit(current.copyWith(draft: null));
    }
  }

  void reset() {
    final current = state;
    if (current.status == RequestStatus.success && current.data != null) {
      emit(
        current.copyWith(data: current.data!.withFavorites([]), draft: null),
      );
    }
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
