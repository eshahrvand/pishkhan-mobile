import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../../domain/entities/bank_loan.dart';
import '../../../../domain/repositories/dashboard_repositories.dart';
import '../../../../domain/usecases/home/load_dashboard_items.dart';
import 'loans_state.dart';

class LoansCubit extends Cubit<LoansState> {
  LoansCubit({required DashboardLoansRepository repository})
    : _loadItems = LoadDashboardItems(repository.getLoans),
      super(const LoansState());

  LoadDashboardItems<BankLoan> _loadItems;
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

  Future<void> changeRepository(DashboardLoansRepository repository) {
    _loadItems = LoadDashboardItems(repository.getLoans);
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
