import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/login_captcha.dart';
import '../entities/login_identity.dart';
import '../repositories/auth_repository.dart';

class FetchLoginCaptcha {
  const FetchLoginCaptcha(this.repository);

  final AuthRepository repository;

  Future<Result<LoginCaptcha>> call() => repository.fetchCaptcha();
}

class RequestLoginOtp {
  const RequestLoginOtp(this.repository);
  final AuthRepository repository;
  Future<Result<LoginOtpChallenge>> call(LoginIdentity identity) =>
      repository.requestOtp(identity);
}

class VerifyLoginOtp {
  const VerifyLoginOtp(this.repository);
  final AuthRepository repository;
  Future<Result<AuthenticatedCustomer>> call(
    LoginOtpChallenge challenge,
    String code,
  ) => repository.verifyOtp(challenge, code);
}
