import 'auth_state.dart';

bool authIsLoginForm(AuthState state) => state.step == AuthStep.login;

bool authIsOtp(AuthState state) =>
    state.step == AuthStep.loginOtp || state.step == AuthStep.changePhoneOtp;

bool authIsChangePhone(AuthState state) =>
    state.step == AuthStep.changePhone || state.step == AuthStep.changePhoneOtp;

bool authIsFormValid(AuthState state) =>
    state.nationalId.length == 10 &&
    state.phone.length == 11 &&
    state.phone.startsWith('09') &&
    state.captcha.length == 6;

bool authIsOtpValid(AuthState state) =>
    state.otp.length == 4 && state.secondsRemaining > 0;

String authMaskedPhone(AuthState state) {
  if (state.phone.length != 11) return '0912*******42';
  return '${state.phone.substring(0, 4)}*******${state.phone.substring(9)}';
}
