part of 'change_card_deposit_cubit.dart';

@Freezed(toStringOverride: false)
abstract class ChangeCardDepositState with _$ChangeCardDepositState {
  const factory ChangeCardDepositState.initial({
    FlowNavigation? navigation,

    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    CardServiceCatalog? catalog,
    ServiceBankCard? card,
    CardServiceDeposit? source,
    @Default(<CardServiceDeposit>[]) List<CardServiceDeposit> destinations,
    CardServiceDeposit? destination,
    @Default(false) bool isCatalogEmpty,
    @Default(false) bool isEditable,
    @Default(false) bool isWalletSufficient,
    @Default(false) bool canSubmit,
    @Default(false) bool termsAccepted,
    Failure? failure,
    String? message,

    CardServiceReceipt? receipt,
  }) = _ChangeCardDepositState;
}
