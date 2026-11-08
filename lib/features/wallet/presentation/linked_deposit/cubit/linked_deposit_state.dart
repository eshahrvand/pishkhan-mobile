part of 'linked_deposit_cubit.dart';

@Freezed(toStringOverride: false)
abstract class WalletLinkedDepositState with _$WalletLinkedDepositState {
  const factory WalletLinkedDepositState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    WalletCatalog? catalog,
    @Default(<WalletDeposit>[]) List<WalletDeposit> destinations,
    WalletDeposit? deposit,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    String? idempotencyKey,
    Failure? failure,
    String? message,
  }) = _WalletLinkedDepositState;
}
