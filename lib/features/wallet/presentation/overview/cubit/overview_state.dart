part of 'overview_cubit.dart';

enum WalletDestination {
  charge,
  withdraw,
  transfer,
  linkedDeposit,
  transactions,
}

@Freezed(toStringOverride: false)
abstract class WalletOverviewState with _$WalletOverviewState {
  const factory WalletOverviewState.initial({
    @Default(RequestStatus.initial) RequestStatus walletStatus,
    WalletSummary? wallet,
    WalletDestination? destination,
    Failure? failure,
    String? message,
  }) = _WalletOverviewState;
}
