import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/bank_deposit.dart';
import '../../../domain/repositories/dashboard_repositories.dart';
import '../../../domain/usecases/home.dart';
import 'deposits_state.dart';
export 'deposits_state.dart';

class DepositsCubit extends Cubit<DepositsState> {
  DepositsCubit({
    DepositsState initialState = const DepositsState(),
    required DashboardDepositsRepository repository,
  }) : _loadItems = LoadDashboardItems(repository.getDeposits),
       super(_prepareState(initialState));

  LoadDashboardItems<BankDeposit> _loadItems;
  int _request = 0;

  Future<void> load() async {
    final token = ++_request;
    final previous = state;
    emit(
      _prepareState(
        state.copyWith(status: RequestStatus.loading, failure: null),
      ),
    );
    final result = await _loadItems();
    if (isClosed || token != _request) return;
    switch (result) {
      case Err(:final failure):
        emit(
          _prepareState(
            state.copyWith(status: RequestStatus.failure, failure: failure),
          ),
        );
      case Success(:final data):
        final items = data.isEmpty ? null : data;
        final id = data.any((item) => item.id == previous.selectedId)
            ? previous.selectedId
            : data.firstOrNull?.id;
        emit(
          _prepareState(
            state.copyWith(
              status: RequestStatus.success,
              items: items,
              selectedId: id,
            ),
          ),
        );
    }
  }

  Future<void> changeRepository(DashboardDepositsRepository repository) {
    _loadItems = LoadDashboardItems(repository.getDeposits);
    return load();
  }

  void select(int index) {
    final current = state;
    final items = current.items;
    if (current.status != RequestStatus.success ||
        items == null ||
        index < 0 ||
        index >= items.length) {
      return;
    }
    emit(_prepareState(current.copyWith(selectedId: items[index].id)));
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }

  static DepositsState _prepareState(DepositsState next) {
    final items = next.status == RequestStatus.success
        ? next.items ?? const <BankDeposit>[]
        : const <BankDeposit>[];
    final selectedIndex = items.indexWhere(
      (item) => item.id == next.selectedId,
    );
    return next.copyWith(
      visibleItems: items,
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      selectedDeposit: selectedIndex < 0 ? null : items[selectedIndex],
    );
  }
}
