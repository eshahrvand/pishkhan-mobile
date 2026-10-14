part of 'auth_cubit.dart';

enum AuthStep { login, loginOtp, changePhone, changePhoneOtp }

@Freezed(toStringOverride: false)
abstract class AuthState with _$AuthState {
  const factory AuthState.initial({
    @Default(true) bool isLoginForm,
    @Default(false) bool isOtp,
    @Default(false) bool isChangePhone,
    @Default(false) bool formValid,
    @Default(false) bool otpValid,
    @Default('0912*******42') String maskedPhone,
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(AuthStep.login) AuthStep step,
    @Default('') String nationalId,
    @Default('') String phone,
    @Default('') String captcha,
    @Default('') String otp,
    @Default(60) int secondsRemaining,
    @Default(false) bool isNationalIdError,
    @Default(false) bool isPhoneError,
    @Default(false) bool isCaptchaError,
  }) = _AuthState;
}
