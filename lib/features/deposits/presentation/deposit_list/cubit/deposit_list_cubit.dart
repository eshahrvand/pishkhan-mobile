import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/repositories/deposits_repository.dart';
import '../../../domain/usecases/deposit_list.dart';
import '../deposit_list_action.dart';
import 'deposit_list_effect.dart';

export 'deposit_list_effect.dart';

part 'deposit_list_state.dart';
part 'deposit_list_cubit.freezed.dart';

class DepositListCubit extends Cubit<DepositListState> {
  DepositListCubit({
    DepositListState initialState = const DepositListState.initial(),
  }) : super(initialState);

  final _repository = getIt<DepositsRepository>();
  late final LoadDeposits _loadDeposits = LoadDeposits(_repository);

  void requestDepositActions(ListedDeposit deposit) {
    emit(
      state.copyWith(
        effect: DepositActionsRequested(deposit),
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyActionSelection(ListedDeposit deposit, DepositListAction? action) {
    switch (action) {
      case DepositListAction.accountDetails:
        emit(
          state.copyWith(
            effect: DepositDetailsRequested(deposit),
            effectId: state.effectId + 1,
          ),
        );
      case null:
        break;
      default:
        emit(
          state.copyWith(
            effect: DepositServiceRequested(
              DepositListActionRequest(action: action, deposit: deposit),
              switch (action) {
                DepositListAction.statement => 'deposit-statement',
                DepositListAction.certificate => 'deposit-certificate',
                DepositListAction.block => 'deposit-block',
                DepositListAction.agent =>
                  'deposit-representation-settings',
                _ => null,
              },
            ),
            effectId: state.effectId + 1,
          ),
        );
    }
  }

  void requestKindFilter() {
    if (state.kind != null) {
      selectKindFilter(null);
    } else {
      emit(
        state.copyWith(
          effect: const DepositKindFilterRequested(),
          effectId: state.effectId + 1,
        ),
      );
    }
  }

  void requestStatusFilter() {
    if (state.depositStatus != null) {
      selectStatusFilter(null);
    } else {
      emit(
        state.copyWith(
          effect: const DepositStatusFilterRequested(),
          effectId: state.effectId + 1,
        ),
      );
    }
  }

  void applyKindFilterSelection(DepositKind? value) {
    if (value != null) selectKindFilter(value);
  }

  void applyStatusFilterSelection(DepositStatus? value) {
    if (value != null) selectStatusFilter(value);
  }

  Future<void> fetchDeposits() {
    emit(
      state.copyWith(
        depositsStatus: RequestStatus.loading,
        depositsFailure: null,
      ),
    );
    return _loadDeposits().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              depositsStatus: RequestStatus.failure,
              depositsFailure: failure,
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              depositsStatus: RequestStatus.success,
              deposits: data,
              visibleDeposits: _filterDeposits(
                data,
                state.kind,
                state.depositStatus,
              ),
            ),
          );
      }
    });
  }

  void selectKindFilter(DepositKind? kind) {
    emit(
      state.copyWith(
        kind: kind,
        visibleDeposits: _filterDeposits(
          state.deposits,
          kind,
          state.depositStatus,
        ),
      ),
    );
  }

  void selectStatusFilter(DepositStatus? status) {
    emit(
      state.copyWith(
        depositStatus: status,
        visibleDeposits: _filterDeposits(state.deposits, state.kind, status),
      ),
    );
  }

  List<ListedDeposit> _filterDeposits(
    List<ListedDeposit> deposits,
    DepositKind? kind,
    DepositStatus? status,
  ) {
    return deposits
        .where(
          (deposit) =>
              (kind == null || deposit.kind == kind) &&
              (status == null || deposit.status == status),
        )
        .toList();
  }
}
