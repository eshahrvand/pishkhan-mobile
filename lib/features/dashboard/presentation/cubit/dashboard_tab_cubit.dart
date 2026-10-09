import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/dashboard_item.dart';
import '../../domain/usecases/load_dashboard_items.dart';
import 'dashboard_tab_state.dart';

abstract class DashboardTabCubit<T extends DashboardItem>
    extends Cubit<DashboardTabState<T>> {
  DashboardTabCubit(this._loadItems) : super(DashboardTabInitial<T>());
  LoadDashboardItems<T> _loadItems;
  int _request = 0;
  DashboardTabLoaded<T> loaded(
    List<T> items,
    String selectedId,
    DashboardTabLoaded<T>? previous,
  );
  Future<void> load() async {
    final token = ++_request;
    final previous = state.previous;
    emit(DashboardTabLoading<T>(previous: previous));
    final result = await _loadItems();
    if (isClosed || token != _request) {
      return;
    }
    switch (result) {
      case Err<List<T>>(:final failure):
        emit(DashboardTabError<T>(failure, previous: previous));
      case Success<List<T>>(:final data):
        if (data.isEmpty) {
          emit(DashboardTabEmpty<T>());
        } else {
          final id = data.any((item) => item.id == previous?.selectedId)
              ? previous!.selectedId
              : data.first.id;
          emit(loaded(data, id, previous));
        }
    }
  }

  Future<void> changeLoader(LoadDashboardItems<T> loader) {
    _loadItems = loader;
    return load();
  }

  void select(int index) {
    final current = state;
    if (current is! DashboardTabLoaded<T> ||
        index < 0 ||
        index >= current.items.length) {
      return;
    }
    emit(loaded(current.items, current.items[index].id, current));
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
