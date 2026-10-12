import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../../domain/entities/bank_deposit.dart';
import '../../../../domain/repositories/dashboard_repositories.dart';
import '../../../../domain/usecases/home/load_dashboard_items.dart';
import 'deposits_state.dart';

class DepositsCubit extends Cubit<DepositsState> {
  DepositsCubit({required DashboardDepositsRepository repository})
    : _loadItems = LoadDashboardItems(repository.getDeposits),
      super(const DepositsState());

  LoadDashboardItems<BankDeposit> _loadItems;
  int _request = 0;

  Future<void> load() async {
    final token = ++_request;
    final previous = state;
    emit(state.copyWith(status: RequestStatus.loading, failure: null));
    final result = await _loadItems();
    if (isClosed || token != _request) return;
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: RequestStatus.failure, failure: failure));
      case Success(:final data):
        final items = data.isEmpty ? null : data;
        final id = data.any((item) => item.id == previous.selectedId)
            ? previous.selectedId
            : data.firstOrNull?.id;
        emit(
          state.copyWith(
            status: RequestStatus.success,
            items: items,
            selectedId: id,
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
    emit(current.copyWith(selectedId: items[index].id));
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
