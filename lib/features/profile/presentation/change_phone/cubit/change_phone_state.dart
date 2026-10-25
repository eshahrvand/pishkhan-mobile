part of 'change_phone_cubit.dart';

enum ChangePhoneEffect { confirmExit, back, home, assistant, terms, submitted }

@Freezed(toStringOverride: false)
abstract class ChangePhoneState with _$ChangePhoneState {
  const factory ChangePhoneState.initial({
    @Default(RequestStatus.initial) RequestStatus settingsStatus,
    @Default(RequestStatus.initial) RequestStatus otpRequestStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    PhoneSettings? settings,
    PhoneChallenge? challenge,
    Failure? failure,
    String? message,

    @Default('') String phoneNumber,
    @Default('') String otp,
    @Default(false) bool isPhoneNumberValid,
    @Default(false) bool isPhoneNumberError,
    @Default(false) bool isOtpValid,
    @Default(false) bool isOtpError,
    @Default(false) bool termsAccepted,
    @Default(false) bool canRequestOtp,
    @Default(false) bool canSubmit,
    @Default(false) bool walletSufficient,
    @Default(0) int remainingSeconds,
    String? idempotencyKey,
    ChangePhoneEffect? effect,
  }) = _ChangePhoneState;
}
