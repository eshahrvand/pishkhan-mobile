import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/login_captcha.dart';
import '../../../domain/entities/login_identity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/login.dart';

import 'package:pishkhan_mobile/core/validators/validators.dart';

import 'auth_effect.dart';

export 'auth_effect.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

/// Owns the real CAPTCHA → check-cif → check-sms login flow.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthState initialState = const AuthState.initial()})
    : super(initialState);

  final repository = getIt<AuthRepository>();
  Timer? _otpTimer;

  Future<void> fetchCaptcha() {
    _startOtpClock();
    emit(
      state.copyWith(
        captchaStatus: RequestStatus.loading,
        captchaImage: null,
        sessionId: '',
        captcha: '',
        isCaptchaValid: false,
        isCaptchaError: false,
        canRequestOtp: false,
        failure: null,
      ),
    );
    return FetchLoginCaptcha(repository)().then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              captchaStatus: RequestStatus.success,
              captchaImage: data,
              sessionId: data.sessionId,
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              captchaStatus: RequestStatus.failure,
              failure: failure,
            ),
          );
      }
    });
  }

  void requestServices() {
    emit(
      state.copyWith(
        effect: const AuthServicesRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  /// A null sheet result is dismissal, rather than a selected service.
  void selectGuestService(String? id) {
    switch (id) {
      case null:
        break;
      case 'identity.changePhone':
        openChangePhone();
      default:
        emit(
          state.copyWith(
            effect: AuthGuestServiceRequested(id),
            effectId: state.effectId + 1,
          ),
        );
    }
  }

  void updateNationalId(String value) {
    final isValid = NationalCodeValidator.isValid(value);
    emit(
      state.copyWith(
        nationalId: value,
        isNationalIdValid: isValid,
        isNationalIdError: value.isNotEmpty && !isValid,
        canRequestOtp:
            isValid &&
            state.isPhoneNumberValid &&
            state.isCaptchaValid &&
            state.captchaStatus == RequestStatus.success,
      ),
    );
  }

  void updatePhoneNumber(String value) {
    final isValid = PhoneNumberValidator.isValid(value);
    emit(
      state.copyWith(
        phoneNumber: value,
        isPhoneNumberValid: isValid,
        isPhoneNumberError: value.isNotEmpty && !isValid,
        canRequestOtp:
            isValid &&
            state.isNationalIdValid &&
            state.isCaptchaValid &&
            state.captchaStatus == RequestStatus.success,
      ),
    );
  }

  void updateCaptcha(String value) {
    final isValid = CodeValidator.isValid(value, length: 6);
    emit(
      state.copyWith(
        captcha: value,
        isCaptchaValid: isValid,
        isCaptchaError: false,
        canRequestOtp:
            isValid &&
            state.isNationalIdValid &&
            state.isPhoneNumberValid &&
            state.captchaStatus == RequestStatus.success,
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
        isCaptchaError: state.captcha.isNotEmpty && !state.isCaptchaValid,
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
        final identity = LoginIdentity(
          nationalCode: state.nationalId,
          mobile: state.phoneNumber,
          captcha: state.captcha,
          sessionId: state.sessionId,
        );
        emit(
          state.copyWith(
            otpRequestStatus: RequestStatus.loading,
            failure: null,
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
                  maskedPhone:
                      '${identity.mobile.substring(0, 4)}*******${identity.mobile.substring(9)}',
                  otp: '',
                  isOtpValid: false,
                  remainingSeconds: 60,
                  otpStartTick: _otpTimer!.tick,
                  canSubmitLogin: false,
                  canResendOtp: false,
                  effect: const AuthOtpRequested(),
                  effectId: state.effectId + 1,
                ),
              );
            case Err(:final failure):
              emit(
                state.copyWith(
                  otpRequestStatus: RequestStatus.failure,
                  failure: failure,
                ),
              );
          }
        });
    }
  }

  void updateOtp(String value) {
    final isValid = CodeValidator.isValid(value, length: 6);
    emit(
      state.copyWith(
        otp: value,
        isOtpValid: isValid,
        canSubmitLogin:
            isValid && state.remainingSeconds > 0 && state.challenge != null,
      ),
    );
  }

  /// No resend endpoint was supplied. A fresh CAPTCHA avoids reusing a consumed one.
  Future<void> submitOtpResend() {
    emit(
      state.copyWith(
        step: AuthStep.login,
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
    emit(state.copyWith(loginStatus: RequestStatus.loading, failure: null));
    return VerifyLoginOtp(repository)(challenge, state.otp).then((result) {
      switch (result) {
        case Success():
          emit(
            state.copyWith(
              loginStatus: RequestStatus.success,
              canSubmitLogin: false,
              canResendOtp: false,
              challenge: null,
              otpStartTick: null,
              otp: '',
              captcha: '',
              captchaImage: null,
              effect: const AuthCompleted(),
              effectId: state.effectId + 1,
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              loginStatus: RequestStatus.failure,
              failure: failure,
            ),
          );
      }
    });
  }

  void openChangePhone() {
    emit(
      state.copyWith(
        step: AuthStep.changePhone,
        nationalId: '',
        phoneNumber: '',
        captcha: '',
        otp: '',
        maskedPhone: '',
        isNationalIdValid: false,
        isPhoneNumberValid: false,
        isCaptchaValid: false,
        isOtpValid: false,
        isNationalIdError: false,
        isPhoneNumberError: false,
        isCaptchaError: false,
        canRequestOtp: false,
        canSubmitLogin: false,
        canResendOtp: false,
        remainingSeconds: 0,
        loginStatus: RequestStatus.initial,
        otpRequestStatus: RequestStatus.initial,
        failure: null,
        challenge: null,
        otpStartTick: null,
      ),
    );
  }

  Future<void> requestBack() {
    switch (state.step) {
      case AuthStep.login:
        return Future.value();
      case AuthStep.loginOtp:
      case AuthStep.changePhoneOtp:
        emit(
          state.copyWith(
            step: state.step == AuthStep.loginOtp
                ? AuthStep.login
                : AuthStep.changePhone,
            otp: '',
            isOtpValid: false,
            canSubmitLogin: false,
            canResendOtp: false,
            remainingSeconds: 0,
            challenge: null,
            otpStartTick: null,
            failure: null,
          ),
        );
        return fetchCaptcha();
      case AuthStep.changePhone:
        emit(
          state.copyWith(
            step: AuthStep.login,
            nationalId: '',
            phoneNumber: '',
            captcha: '',
            isNationalIdValid: false,
            isPhoneNumberValid: false,
            isCaptchaValid: false,
            isNationalIdError: false,
            isPhoneNumberError: false,
            isCaptchaError: false,
            canRequestOtp: false,
            failure: null,
            otpRequestStatus: RequestStatus.initial,
          ),
        );
        return Future.value();
    }
  }

  /// Attach the flow-owned clock during the explicit initial action. The server
  /// success snapshot records its start tick; inactive forms emit no timer updates.
  void _startOtpClock() {
    _otpTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      switch (state.otpStartTick) {
        case final startTick?:
          // Timer.tick includes elapsed periods skipped by a delayed callback.
          final remainingSeconds = (60 - (timer.tick - startTick)).clamp(0, 60);
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
                canSubmitLogin: state.isOtpValid && state.challenge != null,
              ),
            );
          }
        case null:
          break;
      }
    });
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }
}
