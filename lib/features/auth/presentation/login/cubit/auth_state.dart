part of 'auth_cubit.dart';

enum AuthStep { login, loginOtp, changePhone, changePhoneOtp }

@Freezed(toStringOverride: false)
abstract class AuthState with _$AuthState {
  const factory AuthState.initial({
    @Default(AuthStep.login) AuthStep step,
    LoginCaptcha? captchaImage,
    LoginOtpChallenge? challenge,
    Failure? failure,
    String? message,
    @Default(RequestStatus.initial) RequestStatus captchaStatus,
    @Default(RequestStatus.initial) RequestStatus otpRequestStatus,
    @Default('') String nationalId,
    @Default('') String phoneNumber,
    @Default('') String captcha,
    @Default('') String otp,
    @Default('') String maskedPhone,
    @Default(false) bool isNationalIdValid,
    @Default(false) bool isPhoneNumberValid,
    @Default(false) bool isCaptchaValid,
    @Default(false) bool isOtpValid,
    @Default(false) bool isNationalIdError,
    @Default(false) bool isPhoneNumberError,
    @Default(false) bool isCaptchaError,
    @Default(false) bool canRequestOtp,
    @Default(false) bool canSubmitLogin,
    @Default(false) bool canResendOtp,
    @Default(0) int remainingSeconds,
    int? otpStartTick,
    @Default(RequestStatus.initial) RequestStatus loginStatus,
    AuthEffect? effect,
    @Default(0) int effectId,
  }) = _AuthState;
}
