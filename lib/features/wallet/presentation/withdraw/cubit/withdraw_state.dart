part of 'withdraw_cubit.dart';

@Freezed(toStringOverride: false)
abstract class WalletWithdrawState with _$WalletWithdrawState {
  const factory WalletWithdrawState.initial({
    @Default(RequestStatus.initial) RequestStatus shareStatus,
    @Default(RequestStatus.initial) RequestStatus walletStatus,
    @Default(RequestStatus.initial) RequestStatus otpStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    WalletSummary? wallet,
    @Default('') String amount,
    int? amountRial,
    num? amountToman,
    @Default(false) bool isAmountValid,
    @Default(false) bool isAmountError,
    @Default('') String otp,
    @Default(false) bool isOtpValid,
    WalletOtpChallenge? challenge,
    @Default(0) int remainingSeconds,
    @Default(false) bool canRequestOtp,
    @Default(false) bool canSubmit,
    String? idempotencyKey,
    WalletReceipt? receipt,
    String? shareText,
    WalletReceiptEffect? effect,
    Failure? failure,
    String? message,
  }) = _WalletWithdrawState;
}
