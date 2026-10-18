import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';

void main() {
  AuthCubit createCubit([AuthState initialState = const AuthState.initial()]) {
    final cubit = AuthCubit(initialState: initialState);
    addTearDown(cubit.close);
    return cubit;
  }

  void fillIdentity(AuthCubit cubit) {
    cubit.updateNationalId('0081234562');
    cubit.updatePhoneNumber('09121127934');
    cubit.updateCaptcha('123456');
  }

  test(
    'construction preserves the supplied snapshot without initialization',
    () {
      const seed = AuthState.initial(
        step: AuthStep.changePhone,
        nationalId: '0',
        isNationalIdError: true,
      );
      final cubit = createCubit(seed);
      expect(cubit.state, seed);
    },
  );

  test(
    'field updates publish validity, live errors and aggregate eligibility',
    () {
      final cubit = createCubit();
      cubit.updateNationalId('0');
      expect(cubit.state.isNationalIdValid, isFalse);
      expect(cubit.state.isNationalIdError, isTrue);
      cubit.updatePhoneNumber('0');
      expect(cubit.state.isPhoneNumberValid, isFalse);
      expect(cubit.state.isPhoneNumberError, isTrue);

      fillIdentity(cubit);
      expect(cubit.state.isNationalIdValid, isTrue);
      expect(cubit.state.isNationalIdError, isFalse);
      expect(cubit.state.isPhoneNumberValid, isTrue);
      expect(cubit.state.isPhoneNumberError, isFalse);
      expect(cubit.state.isCaptchaValid, isTrue);
      expect(cubit.state.canRequestOtp, isTrue);

      cubit.updateNationalId('0081234563');
      expect(cubit.state.canRequestOtp, isFalse);
      cubit.updateNationalId('0081234562');
      expect(cubit.state.canRequestOtp, isTrue);
      cubit.updatePhoneNumber('08121127934');
      expect(cubit.state.canRequestOtp, isFalse);
      cubit.updatePhoneNumber('09121127934');
      expect(cubit.state.canRequestOtp, isTrue);
      cubit.updateCaptcha('12345');
      expect(cubit.state.canRequestOtp, isFalse);
    },
  );

  test(
    'focus-loss validation reads stored validity and captcha reset clears it',
    () {
      final cubit = createCubit();
      cubit.validateNationalId();
      cubit.validatePhoneNumber();
      cubit.validateCaptcha();
      expect(cubit.state.isNationalIdError, isTrue);
      expect(cubit.state.isPhoneNumberError, isTrue);
      expect(cubit.state.isCaptchaError, isTrue);

      fillIdentity(cubit);
      cubit.validateNationalId();
      cubit.validatePhoneNumber();
      cubit.validateCaptcha();
      expect(cubit.state.isNationalIdError, isFalse);
      expect(cubit.state.isPhoneNumberError, isFalse);
      expect(cubit.state.isCaptchaError, isFalse);
      cubit.resetCaptcha();
      expect(cubit.state.captcha, isEmpty);
      expect(cubit.state.isCaptchaValid, isFalse);
      expect(cubit.state.canRequestOtp, isFalse);
    },
  );

  for (final changePhone in [false, true]) {
    test(
      'OTP request and Back preserve identity (changePhone: $changePhone)',
      () {
        final cubit = createCubit();
        if (changePhone) cubit.openChangePhone();
        fillIdentity(cubit);
        cubit.submitOtpRequest();
        expect(
          cubit.state.step,
          changePhone ? AuthStep.changePhoneOtp : AuthStep.loginOtp,
        );
        expect(cubit.state.maskedPhone, '0912*******34');
        expect(cubit.state.effect, isA<AuthOtpRequested>());
        expect(cubit.state.remainingSeconds, 60);
        expect(cubit.state.canSubmitLogin, isFalse);
        expect(cubit.state.canResendOtp, isFalse);
        cubit.updateOtp('12');
        expect(cubit.state.isOtpValid, isFalse);
        cubit.updateOtp('1234');
        expect(cubit.state.isOtpValid, isTrue);
        expect(cubit.state.canSubmitLogin, isTrue);
        cubit.requestBack();
        expect(
          cubit.state.step,
          changePhone ? AuthStep.changePhone : AuthStep.login,
        );
        expect(cubit.state.nationalId, '0081234562');
        expect(cubit.state.phoneNumber, '09121127934');
        expect(cubit.state.captcha, '123456');
        expect(cubit.state.canRequestOtp, isTrue);
        expect(cubit.state.otp, isEmpty);
        expect(cubit.state.canSubmitLogin, isFalse);
        expect(cubit.state.remainingSeconds, 0);
      },
    );
  }

  test('expired OTP stays ineligible until resend and fresh entry', () {
    final cubit = createCubit(
      const AuthState.initial(step: AuthStep.loginOtp, canResendOtp: true),
    );
    cubit.updateOtp('1234');
    expect(cubit.state.isOtpValid, isTrue);
    expect(cubit.state.canSubmitLogin, isFalse);
    cubit.submitOtpResend();
    expect(cubit.state.otp, isEmpty);
    expect(cubit.state.isOtpValid, isFalse);
    expect(cubit.state.canSubmitLogin, isFalse);
    expect(cubit.state.canResendOtp, isFalse);
    expect(cubit.state.remainingSeconds, 60);
    cubit.updateOtp('1234');
    expect(cubit.state.canSubmitLogin, isTrue);
  });

  test(
    'login completion publishes its effect and disables further submission',
    () {
      final cubit = createCubit();
      fillIdentity(cubit);
      cubit.submitOtpRequest();
      cubit.updateOtp('1234');
      cubit.submitLogin();
      expect(cubit.state.loginStatus, RequestStatus.success);
      expect(cubit.state.effect, isA<AuthCompleted>());
      expect(cubit.state.canSubmitLogin, isFalse);
      expect(cubit.state.canResendOtp, isFalse);
    },
  );

  test('guest sheet cancellation and repeated effects preserve delivery', () {
    final cubit = createCubit();
    cubit.requestServices();
    expect(cubit.state.effect, isA<AuthServicesRequested>());
    final sheetEffectId = cubit.state.effectId;
    cubit.selectGuestService(null);
    expect(cubit.state.effectId, sheetEffectId);
    cubit.selectGuestService('requests.status');
    expect(
      (cubit.state.effect as AuthGuestServiceRequested).id,
      'requests.status',
    );
    final first = cubit.state.effectId;
    cubit.selectGuestService('requests.status');
    expect(cubit.state.effectId, first + 1);
    fillIdentity(cubit);
    cubit.selectGuestService('identity.changePhone');
    expect(cubit.state.step, AuthStep.changePhone);
    expect(cubit.state.nationalId, isEmpty);
    expect(cubit.state.isNationalIdValid, isFalse);
    expect(cubit.state.phoneNumber, isEmpty);
    expect(cubit.state.isPhoneNumberValid, isFalse);
    expect(cubit.state.captcha, isEmpty);
    expect(cubit.state.canRequestOtp, isFalse);
    cubit.requestBack();
    expect(cubit.state.step, AuthStep.login);
  });
}
