import 'dart:async';
import 'dart:convert';

import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/network/access_token_store.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/auth/domain/entities/login_captcha.dart';
import 'package:pishkhan_mobile/features/auth/domain/entities/login_identity.dart';
import 'package:pishkhan_mobile/features/auth/domain/repositories/auth_repository.dart';

const testCaptchaBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGP4DwQACfsD/fteaysAAAAASUVORK5CYII=';

const testLoginIdentity = LoginIdentity(
  nationalCode: '0081234562',
  mobile: '09121127934',
  captcha: '123456',
  sessionId: 'test-session',
);
const testOtpChallenge = LoginOtpChallenge(
  token: 'test-challenge-token',
  identity: testLoginIdentity,
);

void configureAuthTestDependencies() {
  configureDependencies();
  getIt.unregister<AuthRepository>();
  getIt.registerSingleton<AuthRepository>(
    FakeAuthRepository(tokens: getIt<AccessTokenStore>()),
  );
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.tokens});

  final AccessTokenStore? tokens;
  Failure? captchaFailure;
  Failure? otpFailure;
  Failure? loginFailure;
  Completer<Result<LoginCaptcha>>? captchaResponse;
  Completer<Result<LoginOtpChallenge>>? otpResponse;
  Completer<Result<AuthenticatedCustomer>>? loginResponse;
  int captchaCalls = 0;
  int otpCalls = 0;
  int loginCalls = 0;
  LoginIdentity? lastOtpIdentity;

  @override
  Future<Result<LoginCaptcha>> fetchCaptcha() async {
    captchaCalls++;
    if (captchaResponse != null) return captchaResponse!.future;
    return captchaFailure == null
        ? Success(
            LoginCaptcha(
              base64Decode(testCaptchaBase64),
              sessionId: 'server-captcha-$captchaCalls',
            ),
          )
        : Err(captchaFailure!);
  }

  @override
  Future<Result<LoginOtpChallenge>> requestOtp(LoginIdentity identity) async {
    otpCalls++;
    lastOtpIdentity = identity;
    return otpResponse != null
        ? otpResponse!.future
        : otpFailure == null
        ? Success(
            LoginOtpChallenge(
              token: 'test-challenge-token',
              identity: identity,
            ),
          )
        : Err(otpFailure!);
  }

  @override
  Future<Result<AuthenticatedCustomer>> verifyOtp(
    LoginOtpChallenge challenge,
    String code,
  ) async {
    loginCalls++;
    if (loginResponse != null) return loginResponse!.future;
    if (loginFailure != null) return Err(loginFailure!);
    tokens?.replace('test-final-token');
    return Success(
      AuthenticatedCustomer(
        customerCode: 'test-customer',
        nationalCode: challenge.identity.nationalCode,
        firstName: 'Test',
        lastName: 'Customer',
      ),
    );
  }
}
