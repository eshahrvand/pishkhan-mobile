part of 'change_card_deposit_cubit.dart';

@freezed
abstract class ChangeCardDepositState with _$ChangeCardDepositState {
  const factory ChangeCardDepositState.initial({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    CardServiceCatalog? catalog,
    String? cardId,
    ServiceBankCard? card,
    CardServiceDeposit? source,
    @Default(<CardServiceDeposit>[]) List<CardServiceDeposit> destinations,
    CardServiceDeposit? destination,
    @Default(false) bool isEmpty,
    @Default(false) bool editable,
    @Default(false) bool walletSufficient,
    @Default(false) bool canSubmit,
    String? destinationId,
    @Default(false) bool termsAccepted,
    Failure? failure,
    CardServiceReceipt? receipt,
  }) = _ChangeCardDepositState;
}
