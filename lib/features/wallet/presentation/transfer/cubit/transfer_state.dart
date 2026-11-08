part of 'transfer_cubit.dart';

@Freezed(toStringOverride: false)
abstract class WalletTransferState with _$WalletTransferState {
  const factory WalletTransferState.initial({
    @Default(RequestStatus.initial) RequestStatus shareStatus,
    @Default(RequestStatus.initial) RequestStatus walletStatus,
    @Default(RequestStatus.initial) RequestStatus recipientStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    WalletSummary? wallet,
    @Default('') String destination,
    @Default(false) bool isDestinationError,
    WalletRecipient? recipient,
    @Default('') String amount,
    int? amountRial,
    num? amountToman,
    @Default(false) bool isAmountValid,
    @Default(false) bool isAmountError,
    @Default(false) bool canSubmit,
    String? idempotencyKey,
    WalletReceipt? receipt,
    String? shareText,
    WalletReceiptEffect? effect,
    Failure? failure,
    String? message,
  }) = _WalletTransferState;
}
