import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/validators/validators.dart';

import 'auth_effect.dart';

export 'auth_effect.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

/// Login prototype only; bank OTP requests and verification are not connected.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthState initialState = const AuthState.initial()})
    : super(initialState);

  Timer? _otpTimer;

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
            isValid && state.isPhoneNumberValid && state.isCaptchaValid,
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
            isValid && state.isNationalIdValid && state.isCaptchaValid,
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
            isValid && state.isNationalIdValid && state.isPhoneNumberValid,
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
    emit(state.copyWith(isCaptchaError: !state.isCaptchaValid));
  }

  void resetCaptcha() {
    emit(
      state.copyWith(
        captcha: '',
        isCaptchaValid: false,
        isCaptchaError: false,
        canRequestOtp: false,
      ),
    );
  }

  void submitOtpRequest() {
    emit(
      state.copyWith(
        step: state.step == AuthStep.changePhone
            ? AuthStep.changePhoneOtp
            : AuthStep.loginOtp,
        maskedPhone:
            '${state.phoneNumber.substring(0, 4)}*******${state.phoneNumber.substring(9)}',
        otp: '',
        isOtpValid: false,
        remainingSeconds: 60,
        canSubmitLogin: false,
        canResendOtp: false,
        loginStatus: RequestStatus.initial,
        effect: const AuthOtpRequested(),
        effectId: state.effectId + 1,
      ),
    );
    _startOtpTimer();
  }

  void updateOtp(String value) {
    final isValid = CodeValidator.isValid(value, length: 4);
    emit(
      state.copyWith(
        otp: value,
        isOtpValid: isValid,
        canSubmitLogin: isValid && state.remainingSeconds > 0,
      ),
    );
  }

  void submitOtpResend() {
    emit(
      state.copyWith(
        otp: '',
        isOtpValid: false,
        remainingSeconds: 60,
        canSubmitLogin: false,
        canResendOtp: false,
      ),
    );
    _startOtpTimer();
  }

  void submitLogin() {
    _otpTimer?.cancel();
    emit(
      state.copyWith(
        loginStatus: RequestStatus.success,
        canSubmitLogin: false,
        canResendOtp: false,
        effect: const AuthCompleted(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void openChangePhone() {
    _otpTimer?.cancel();
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
      ),
    );
  }

  void requestBack() {
    _otpTimer?.cancel();
    switch (state.step) {
      case AuthStep.login:
        break;
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
          ),
        );
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
          ),
        );
    }
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // tick counts elapsed periods, including periods skipped by a delayed callback.
      final remainingSeconds = (60 - timer.tick).clamp(0, 60);
      if (remainingSeconds == 0) timer.cancel();
      emit(
        state.copyWith(
          remainingSeconds: remainingSeconds,
          canSubmitLogin: state.isOtpValid && remainingSeconds > 0,
          canResendOtp: remainingSeconds == 0,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }
}
