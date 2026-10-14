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
    required DepositsRepository repository,
    DepositListState initialState = const DepositListState.initial(),
  }) : _loadDeposits = LoadDeposits(repository),
       super(initialState);
  final LoadDeposits _loadDeposits;
  int _generation = 0;

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
