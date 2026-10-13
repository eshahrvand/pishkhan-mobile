import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/listed_deposit.dart';

part 'deposit_list_state.freezed.dart';

@Freezed(toStringOverride: false)
abstract class DepositListState with _$DepositListState {
  const factory DepositListState({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(<ListedDeposit>[]) List<ListedDeposit> deposits,
    @Default(<ListedDeposit>[]) List<ListedDeposit> visibleDeposits,
    DepositKind? kind,
    @Default(DepositStatus.open) DepositStatus? depositStatus,
    Failure? failure,
  }) = _DepositListState;
}
