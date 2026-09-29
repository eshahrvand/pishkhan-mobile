enum AuthStep { login, loginOtp, changePhone, changePhoneOtp }

class AuthState {
  const AuthState({
    this.step = AuthStep.login,
    this.nationalId = '',
    this.phone = '',
    this.captcha = '',
    this.otp = '',
    this.secondsRemaining = 60,
  });

  final AuthStep step;
  final String nationalId;
  final String phone;
  final String captcha;
  final String otp;
  final int secondsRemaining;

  bool get isLoginForm => step == AuthStep.login;
  bool get isOtp =>
      step == AuthStep.loginOtp || step == AuthStep.changePhoneOtp;
  bool get isChangePhone =>
      step == AuthStep.changePhone || step == AuthStep.changePhoneOtp;
  bool get isFormValid =>
      nationalId.length == 10 && phone.length == 11 && captcha.length == 6;
  bool get isOtpValid => otp.length == 4;

  String get maskedPhone {
    if (phone.length != 11) return '۴۲*******۰۹۱۲';
    return '${phone.substring(0, 4)}*******${phone.substring(9)}';
  }

  AuthState copyWith({
    AuthStep? step,
    String? nationalId,
    String? phone,
    String? captcha,
    String? otp,
    int? secondsRemaining,
  }) {
    return AuthState(
      step: step ?? this.step,
      nationalId: nationalId ?? this.nationalId,
      phone: phone ?? this.phone,
      captcha: captcha ?? this.captcha,
      otp: otp ?? this.otp,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}
