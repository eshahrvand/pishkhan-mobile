import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/login_captcha.dart';
import '../entities/login_identity.dart';
import '../repositories/auth_repository.dart';

class FetchLoginCaptchaUseCase {
  const FetchLoginCaptchaUseCase(this.repository);

  final AuthRepository repository;

  Future<Result<LoginCaptcha>> call() => repository.fetchCaptcha();
}

class RequestLoginOtpUseCase {
  const RequestLoginOtpUseCase(this.repository);
  final AuthRepository repository;
  Future<Result<LoginOtpChallenge>> call(LoginIdentity identity) =>
      repository.requestOtp(identity);
}

class VerifyLoginOtpUseCase {
  const VerifyLoginOtpUseCase(this.repository);
  final AuthRepository repository;
  Future<Result<AuthenticatedCustomer>> call(
    LoginOtpChallenge challenge,
    String code,
  ) => repository.verifyOtp(challenge, code);
}
