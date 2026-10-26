import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/validators.dart';

import '../../../domain/entities/login_captcha.dart';
import '../../../domain/entities/login_identity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/login.dart';

import 'auth_effect.dart';
import 'auth_error_messages.dart';

export 'auth_effect.dart';

part 'auth_state.dart';

part 'auth_cubit.freezed.dart';

/// Owns the real CAPTCHA → check-cif → check-sms login flow.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthState initialState = const AuthState.initial()})
    : super(initialState);

  // Temporary countdown until the bank supplies OTP expiry metadata.
  static const _otpValiditySeconds = 60;

  final repository = getIt<AuthRepository>();
  Timer? _otpClock;

  Future<void> fetchCaptcha() {
    // Attach once during the explicit initial action; retries reuse this clock.
    _otpClock ??= Timer.periodic(
      const Duration(seconds: 1),
      _updateOtpCountdown,
    );
    emit(
      state.copyWith(
        captchaStatus: RequestStatus.loading,
        captchaImage: null,
        captcha: '',
        isCaptchaValid: false,
        isCaptchaError: false,
        canRequestOtp: false,
        failure: null,
        message: null,
      ),
    );
    return FetchLoginCaptcha(repository)().then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              captchaStatus: RequestStatus.success,
              captchaImage: data,
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              captchaStatus: RequestStatus.failure,
              failure: failure,
              message: getAuthErrorMessage(failure),
            ),
          );
      }
    });
  }

  void requestServices() {
    emit(state.copyWith(effect: const AuthServicesRequested(), message: null));
  }

  /// A null sheet result is dismissal, rather than a selected service.
  void selectGuestService(String? serviceId) {
    switch (serviceId) {
      case null:
        break;
      case 'identity.changePhone':
        openChangePhone();
      default:
        emit(
          state.copyWith(
            effect: AuthGuestServiceRequested(serviceId),
            message: null,
          ),
        );
    }
  }

  void updateNationalId(String value) {
    final isNationalIdValid = NationalCodeValidator.isValid(value);

    emit(
      state.copyWith(
        nationalId: value,
        isNationalIdValid: isNationalIdValid,
        // Empty input hides the typing error; reuse the validation result above.
        isNationalIdError: _isTypingError(value, isNationalIdValid),
        canRequestOtp: _canRequestOtp(isNationalIdValid: isNationalIdValid),
      ),
    );
  }

  void updatePhoneNumber(String value) {
    final isPhoneNumberValid = PhoneNumberValidator.isValid(value);

    emit(
      state.copyWith(
        phoneNumber: value,
        isPhoneNumberValid: isPhoneNumberValid,
        isPhoneNumberError: _isTypingError(value, isPhoneNumberValid),
        canRequestOtp: _canRequestOtp(isPhoneNumberValid: isPhoneNumberValid),
      ),
    );
  }

  void updateCaptcha(String value) {
    final isCaptchaValid = CodeValidator.isValid(value, length: 6);

    emit(
      state.copyWith(
        captcha: value,
        isCaptchaValid: isCaptchaValid,
        isCaptchaError: false,
        canRequestOtp: _canRequestOtp(isCaptchaValid: isCaptchaValid),
      ),
    );
  }

  void validateNationalId() {
    emit(state.copyWith(isNationalIdError: !state.isNationalIdValid));
  }

  void validatePhoneNumber() {
    emit(state.copyWith(isPhoneNumberError: !state.isPhoneNumberValid));
  }

  void validateCaptcha() {
    emit(
      state.copyWith(
        isCaptchaError: _isTypingError(state.captcha, state.isCaptchaValid),
      ),
    );
  }

  Future<void> submitOtpRequest() {
    switch (state.step) {
      case AuthStep.changePhone:
      case AuthStep.changePhoneOtp:
        emit(
          state.copyWith(
            failure: const DataFailure('auth.change_phone_unavailable'),
            otpRequestStatus: RequestStatus.failure,
          ),
        );
        return Future.value();
      case AuthStep.login:
      case AuthStep.loginOtp:
        return _submitLoginOtpRequest();
    }
  }

  Future<void> _submitLoginOtpRequest() {
    final identity = LoginIdentity(
      nationalCode: state.nationalId,
      mobile: state.phoneNumber,
      captcha: state.captcha,
      sessionId: state.captchaImage!.sessionId,
    );
    final maskedPhone =
        '${identity.mobile.substring(0, 4)}*******${identity.mobile.substring(9)}';

    emit(
      state.copyWith(
        otpRequestStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return RequestLoginOtp(repository)(identity).then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              otpRequestStatus: RequestStatus.success,
              challenge: data,
              step: AuthStep.loginOtp,
              maskedPhone: maskedPhone,
              otp: '',
              isOtpValid: false,
              remainingSeconds: _otpValiditySeconds,
              otpStartTick: _otpClock!.tick,
              canSubmitLogin: false,
              effect: const AuthOtpRequested(),
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              otpRequestStatus: RequestStatus.failure,
              failure: failure,
              message: getAuthErrorMessage(failure),
            ),
          );
      }
    });
  }

  void updateOtp(String value) {
    final isOtpValid = CodeValidator.isValid(value, length: 6);

    emit(
      state.copyWith(
        otp: value,
        isOtpValid: isOtpValid,
        canSubmitLogin: _canSubmitLogin(isOtpValid: isOtpValid),
      ),
    );
  }

  /// No resend endpoint was supplied. A fresh CAPTCHA avoids reusing a consumed one.
  Future<void> submitOtpResend() {
    emit(
      state.copyWith(
        step: state.step == AuthStep.changePhoneOtp
            ? AuthStep.changePhone
            : AuthStep.login,
        challenge: null,
        otpStartTick: null,
        otp: '',
        isOtpValid: false,
        canSubmitLogin: false,
        canResendOtp: false,
        remainingSeconds: 0,
      ),
    );
    return fetchCaptcha();
  }

  Future<void> submitLogin(LoginOtpChallenge challenge) {
    emit(
      state.copyWith(
        loginStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return VerifyLoginOtp(repository)(challenge, state.otp).then((result) {
      switch (result) {
        case Success():
          emit(
            state.copyWith(
              loginStatus: RequestStatus.success,
              canSubmitLogin: false,
              effect: const AuthCompleted(),
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              loginStatus: RequestStatus.failure,
              failure: failure,
              message: getAuthErrorMessage(failure),
            ),
          );
      }
    });
  }

  void openChangePhone() {
    emit(
      AuthState.initial(
        step: AuthStep.changePhone,
        captchaImage: state.captchaImage,
        captchaStatus: state.captchaStatus,
      ),
    );
  }

  Future<void> requestBack() {
    switch (state.step) {
      case AuthStep.login:
        return Future.value();
      case AuthStep.loginOtp:
      case AuthStep.changePhoneOtp:
        return submitOtpResend();
      case AuthStep.changePhone:
        emit(
          AuthState.initial(
            captchaImage: state.captchaImage,
            captchaStatus: state.captchaStatus,
          ),
        );
        return Future.value();
    }
  }

  bool _isTypingError(String value, bool isValid) {
    return value.isNotEmpty && !isValid;
  }

  bool _canRequestOtp({
    bool? isNationalIdValid,
    bool? isPhoneNumberValid,
    bool? isCaptchaValid,
  }) {
    return (isNationalIdValid ?? state.isNationalIdValid) &&
        (isPhoneNumberValid ?? state.isPhoneNumberValid) &&
        (isCaptchaValid ?? state.isCaptchaValid) &&
        state.captchaStatus == RequestStatus.success;
  }

  bool _canSubmitLogin({bool? isOtpValid, int? remainingSeconds}) {
    return (isOtpValid ?? state.isOtpValid) &&
        (remainingSeconds ?? state.remainingSeconds) > 0 &&
        state.challenge != null;
  }

  /// A successful challenge starts the countdown; identity forms stay idle.
  void _updateOtpCountdown(Timer clock) {
    switch (state.otpStartTick) {
      case final startTick?:
        // tick includes elapsed periods skipped by a delayed callback.
        final elapsedSeconds = clock.tick - startTick;
        final remainingSeconds = (_otpValiditySeconds - elapsedSeconds).clamp(
          0,
          _otpValiditySeconds,
        );
        if (remainingSeconds == 0) {
          emit(
            state.copyWith(
              otpStartTick: null,
              remainingSeconds: 0,
              canSubmitLogin: false,
              canResendOtp: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              remainingSeconds: remainingSeconds,
              canSubmitLogin: _canSubmitLogin(
                remainingSeconds: remainingSeconds,
              ),
            ),
          );
        }
      case null:
        break;
    }
  }

  @override
  Future<void> close() {
    _otpClock?.cancel();
    return super.close();
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeAuthInteraction() {
    emit(state.copyWith(effect: null));
  }
}
