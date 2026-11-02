import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/login_captcha.dart';
import '../entities/login_identity.dart';

abstract interface class AuthRepository {
  Future<Result<LoginCaptcha>> fetchCaptcha();
  Future<Result<LoginOtpChallenge>> requestOtp(LoginIdentity identity);
  Future<Result<AuthenticatedCustomer>> verifyOtp(
    LoginOtpChallenge challenge,
    String code,
  );
}
