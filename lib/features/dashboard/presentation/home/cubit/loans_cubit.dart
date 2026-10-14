import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/bank_loan.dart';
import '../../../domain/repositories/dashboard_repositories.dart';
import '../../../domain/usecases/home.dart';

part 'loans_state.dart';
part 'loans_cubit.freezed.dart';

class LoansCubit extends Cubit<LoansState> {
  LoansCubit({
    LoansState initialState = const LoansState.initial(),
    required DashboardLoansRepository repository,
  }) : _loadItems = LoadDashboardItems(repository.getLoans),
       super(initialState) {
    final items = initialState.status == RequestStatus.success
        ? initialState.items ?? const <BankLoan>[]
        : const <BankLoan>[];
    final index = items.indexWhere(
      (item) => item.id == initialState.selectedId,
    );
    emit(
      state.copyWith(
        visibleItems: items,
        selectedIndex: index < 0 ? 0 : index,
        selectedLoan: index < 0 ? null : items[index],
      ),
    );
  }

  LoadDashboardItems<BankLoan> _loadItems;
  int _request = 0;

  Future<void> load() async {
    final token = ++_request;
    final previous = state;
    emit(
      state.copyWith(
        status: RequestStatus.loading,
        failure: null,
        visibleItems: const [],
        selectedIndex: 0,
        selectedLoan: null,
      ),
    );
    final result = await _loadItems();
    if (isClosed || token != _request) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            status: RequestStatus.failure,
            failure: failure,
            visibleItems: const [],
            selectedIndex: 0,
            selectedLoan: null,
          ),
        );
      case Success(:final data):
        final id = data.any((item) => item.id == previous.selectedId)
            ? previous.selectedId
            : data.firstOrNull?.id;
        final index = data.indexWhere((item) => item.id == id);
        emit(
          state.copyWith(
            status: RequestStatus.success,
            items: data.isEmpty ? null : data,
            selectedId: id,
            visibleItems: data,
            selectedIndex: index < 0 ? 0 : index,
            selectedLoan: index < 0 ? null : data[index],
          ),
        );
    }
  }

  Future<void> changeRepository(DashboardLoansRepository repository) {
    _loadItems = LoadDashboardItems(repository.getLoans);
    return load();
  }

  void select(int index) {
    final items = state.items;
    if (state.status != RequestStatus.success ||
        items == null ||
        index < 0 ||
        index >= items.length) {
      return;
    }
    final selectedIndex = items.indexWhere(
      (item) => item.id == items[index].id,
    );
    emit(
      state.copyWith(
        selectedId: items[index].id,
        selectedIndex: selectedIndex,
        selectedLoan: items[selectedIndex],
      ),
    );
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
