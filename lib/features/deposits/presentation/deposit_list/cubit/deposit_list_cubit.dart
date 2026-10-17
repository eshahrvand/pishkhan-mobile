import 'package:pishkhan_mobile/core/di/injection_container.dart';

import '../deposit_list_action.dart';
import 'deposit_list_effect.dart';
export 'deposit_list_effect.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/repositories/deposits_repository.dart';
import '../../../domain/usecases/deposit_list.dart';

part 'deposit_list_state.dart';
part 'deposit_list_cubit.freezed.dart';

class DepositListCubit extends Cubit<DepositListState> {
  DepositListCubit({
    DepositListState initialState = const DepositListState.initial(),
  }) : super(initialState);
  final _repository = getIt<DepositsRepository>();
  late final LoadDeposits _loadDeposits = LoadDeposits(_repository);
  int _generation = 0;

  void requestActions(String id) {
    if (isClosed) return;
    final deposit = state.visibleDeposits.where((d) => d.id == id).firstOrNull;
    if (deposit == null) return;
    emit(
      state.copyWith(
        effect: DepositActionsRequested(deposit),
        effectId: state.effectId + 1,
      ),
    );
  }

  void actionSelected(ListedDeposit deposit, DepositListAction? action) {
    if (isClosed || action == null || !state.deposits.contains(deposit)) return;
    if (action == DepositListAction.accountDetails) {
      emit(
        state.copyWith(
          effect: DepositDetailsRequested(deposit),
          effectId: state.effectId + 1,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        effect: DepositServiceRequested(
          DepositListActionRequest(action: action, deposit: deposit),
          switch (action) {
            DepositListAction.statement => 'deposit-statement',
            DepositListAction.certificate => 'deposit-certificate',
            _ => null,
          },
        ),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestKindFilter() {
    if (isClosed || state.status != RequestStatus.success) return;
    if (state.kind != null) {
      filterKind(null);
      return;
    }
    emit(
      state.copyWith(
        effect: const DepositKindFilterRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestStatusFilter() {
    if (isClosed || state.status != RequestStatus.success) return;
    if (state.depositStatus != null) {
      filterStatus(null);
      return;
    }
    emit(
      state.copyWith(
        effect: const DepositStatusFilterRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void kindFilterResult(DepositKind? value) {
    if (value != null) filterKind(value);
  }

  void statusFilterResult(DepositStatus? value) {
    if (value != null) filterStatus(value);
  }

  Future<void> load() async {
    if (isClosed) return;
    final generation = ++_generation;
    emit(state.copyWith(status: RequestStatus.loading, failure: null));
    final result = await _loadDeposits();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: RequestStatus.failure, failure: failure));
      case Success(:final data):
        emit(
          state.copyWith(
            status: RequestStatus.success,
            deposits: data,
            visibleDeposits: data
                .where(
                  (d) =>
                      (state.kind == null || d.kind == state.kind) &&
                      (state.depositStatus == null ||
                          d.status == state.depositStatus),
                )
                .toList(),
          ),
        );
    }
  }

  void filterKind(DepositKind? kind) {
    if (isClosed || state.status != RequestStatus.success) return;
    emit(
      state.copyWith(
        kind: kind,
        visibleDeposits: state.deposits
            .where(
              (d) =>
                  (kind == null || d.kind == kind) &&
                  (state.depositStatus == null ||
                      d.status == state.depositStatus),
            )
            .toList(),
      ),
    );
  }

  void filterStatus(DepositStatus? status) {
    if (isClosed || state.status != RequestStatus.success) return;
    emit(
      state.copyWith(
        depositStatus: status,
        visibleDeposits: state.deposits
            .where(
              (d) =>
                  (state.kind == null || d.kind == state.kind) &&
                  (status == null || d.status == status),
            )
            .toList(),
      ),
    );
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
