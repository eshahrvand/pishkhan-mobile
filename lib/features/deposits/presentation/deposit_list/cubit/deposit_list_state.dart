part of 'deposit_list_cubit.dart';

@Freezed(toStringOverride: false)
abstract class DepositListState with _$DepositListState {
  const factory DepositListState.initial({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(<ListedDeposit>[]) List<ListedDeposit> deposits,
    @Default(<ListedDeposit>[]) List<ListedDeposit> visibleDeposits,
    DepositKind? kind,
    @Default(DepositStatus.open) DepositStatus? depositStatus,
    Failure? failure,
  }) = _DepositListState;
}
