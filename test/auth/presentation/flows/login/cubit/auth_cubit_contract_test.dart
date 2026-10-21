import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/auth/domain/entities/login_identity.dart';
import 'package:pishkhan_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';

import '../../../../../support/auth_test_dependencies.dart';

void main() {
  setUp(configureAuthTestDependencies);
  tearDown(() => getIt.reset());

  AuthCubit createCubit([AuthState seed = const AuthState.initial()]) {
    final cubit = AuthCubit(initialState: seed);
    addTearDown(cubit.close);
    return cubit;
  }

  Future<void> fillIdentity(AuthCubit cubit) async {
    await cubit.fetchCaptcha();
    cubit.updateNationalId('0081234562');
    cubit.updatePhoneNumber('09121127934');
    cubit.updateCaptcha('123456');
  }

  test(
    'construction preserves the supplied snapshot without initialization',
    () {
      const seed = AuthState.initial(nationalId: '0', isNationalIdError: true);
      expect(createCubit(seed).state, seed);
    },
  );

  test(
    'eligibility requires a fetched CAPTCHA and independently valid fields',
    () async {
      final cubit = createCubit();
      cubit.updateNationalId('0081234562');
      cubit.updatePhoneNumber('09121127934');
      cubit.updateCaptcha('123456');
      expect(cubit.state.canRequestOtp, isFalse);
      await fillIdentity(cubit);
      expect(cubit.state.canRequestOtp, isTrue);
      cubit.updateNationalId('0');
      expect(cubit.state.isNationalIdError, isTrue);
      expect(cubit.state.canRequestOtp, isFalse);
      cubit.updateNationalId('0081234562');
      expect(cubit.state.canRequestOtp, isTrue);
      cubit.updatePhoneNumber('0');
      expect(cubit.state.isPhoneNumberError, isTrue);
      expect(cubit.state.canRequestOtp, isFalse);
    },
  );

  test(
    'refresh replaces the image/session pair and invalidates the old answer',
    () async {
      final cubit = createCubit();
      await fillIdentity(cubit);
      final sessionId = cubit.state.sessionId;
      await cubit.fetchCaptcha();
      expect(cubit.state.captcha, isEmpty);
      expect(cubit.state.canRequestOtp, isFalse);
      expect(cubit.state.captchaImage, isNotNull);
      expect(cubit.state.sessionId, isNot(sessionId));
      expect(cubit.state.sessionId, cubit.state.captchaImage!.sessionId);
      cubit.updateCaptcha('654321');
      await cubit.submitOtpRequest();
      expect(
        (getIt<AuthRepository>() as FakeAuthRepository)
            .lastOtpIdentity!
            .sessionId,
        cubit.state.captchaImage!.sessionId,
      );
    },
  );

  test('CAPTCHA failure remains retryable and cannot enable OTP', () async {
    final repository = getIt<AuthRepository>() as FakeAuthRepository;
    final cubit = createCubit();
    await fillIdentity(cubit);
    repository.captchaFailure = const DataFailure('network.connection');
    await cubit.fetchCaptcha();
    expect(cubit.state.captchaStatus, RequestStatus.failure);
    expect(cubit.state.sessionId, isEmpty);
    expect(cubit.state.captchaImage, isNull);
    expect(cubit.state.canRequestOtp, isFalse);
    repository.captchaFailure = null;
    await cubit.fetchCaptcha();
    expect(cubit.state.captchaStatus, RequestStatus.success);
    expect(cubit.state.failure, isNull);
  });

  test(
    'OTP request waits for success and preserves entered identity on failure',
    () async {
      final repository = getIt<AuthRepository>() as FakeAuthRepository;
      repository.otpResponse = Completer<Result<LoginOtpChallenge>>();
      final cubit = createCubit();
      await fillIdentity(cubit);
      final request = cubit.submitOtpRequest();
      expect(cubit.state.step, AuthStep.login);
      expect(cubit.state.otpRequestStatus, RequestStatus.loading);
      repository.otpResponse!.complete(
        const Err(DataFailure('auth.request_rejected')),
      );
      await request;
      expect(cubit.state.step, AuthStep.login);
      expect(cubit.state.nationalId, '0081234562');
      expect(cubit.state.otpRequestStatus, RequestStatus.failure);
    },
  );

  test(
    'six-digit OTP is accepted only after the bank creates a challenge',
    () async {
      final cubit = createCubit();
      await fillIdentity(cubit);
      await cubit.submitOtpRequest();
      expect(cubit.state.step, AuthStep.loginOtp);
      expect(cubit.state.maskedPhone, '0912*******34');
      expect(cubit.state.effect, isA<AuthOtpRequested>());
      cubit.updateOtp('1234');
      expect(cubit.state.canSubmitLogin, isFalse);
      cubit.updateOtp('123456');
      expect(cubit.state.canSubmitLogin, isTrue);
    },
  );

  test(
    'verification failures never publish authentication and permit retry',
    () async {
      final repository = getIt<AuthRepository>() as FakeAuthRepository;
      repository.loginFailure = const DataFailure('auth.otp_rejected');
      final cubit = createCubit();
      await fillIdentity(cubit);
      await cubit.submitOtpRequest();
      cubit.updateOtp('123456');
      await cubit.submitLogin(cubit.state.challenge!);
      expect(cubit.state.loginStatus, RequestStatus.failure);
      expect(cubit.state.effect, isNot(isA<AuthCompleted>()));
      expect(cubit.state.otp, '123456');
      repository.loginFailure = null;
      await cubit.submitLogin(cubit.state.challenge!);
      expect(cubit.state.loginStatus, RequestStatus.success);
      expect(cubit.state.effect, isA<AuthCompleted>());
      expect(cubit.state.otp, isEmpty);
      expect(cubit.state.challenge, isNull);
      expect(cubit.state.canSubmitLogin, isFalse);
    },
  );

  test(
    'resend starts a fresh CAPTCHA instead of reusing a consumed answer',
    () async {
      final cubit = createCubit();
      await fillIdentity(cubit);
      await cubit.submitOtpRequest();
      await cubit.submitOtpResend();
      expect(cubit.state.step, AuthStep.login);
      expect(cubit.state.remainingSeconds, 0);
      expect(cubit.state.challenge, isNull);
      expect(cubit.state.captcha, isEmpty);
      expect(cubit.state.nationalId, '0081234562');
    },
  );

  test(
    'change-phone does not call a login endpoint as a replacement service',
    () async {
      final cubit = createCubit();
      cubit.openChangePhone();
      await fillIdentity(cubit);
      await cubit.submitOtpRequest();
      expect(cubit.state.step, AuthStep.changePhone);
      expect(cubit.state.failure?.code, 'auth.change_phone_unavailable');
      expect((getIt<AuthRepository>() as FakeAuthRepository).otpCalls, 0);
    },
  );

  testWidgets('closing a flow cancels its OTP clock', (tester) async {
    final cubit = AuthCubit();
    await fillIdentity(cubit);
    await cubit.submitOtpRequest();
    await cubit.close();
    await tester.pump(const Duration(seconds: 61));
    expect(tester.takeException(), isNull);
  });

  test('guest dismissal and repeated effects preserve delivery', () {
    final cubit = createCubit();
    cubit.requestServices();
    final first = cubit.state.effectId;
    cubit.selectGuestService(null);
    expect(cubit.state.effectId, first);
    cubit.selectGuestService('requests.status');
    cubit.selectGuestService('requests.status');
    expect(cubit.state.effectId, first + 2);
  });
}
