import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/validators/validators.dart';

part 'auth_state.dart';

part 'auth_cubit.freezed.dart';

/// UI state for the login prototype. Bank authentication is not connected yet.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthState initialState = const AuthState.initial()})
    : super(initialState);

  Timer? _timer;

  void updateNationalId(String value) {
    emit(
      state.copyWith(
        nationalId: value,
        isNationalIdError:
            value.isNotEmpty && !NationalCodeValidator.isValid(value),
        formValid: checkFormValid(value, state.phone, state.captcha),
      ),
    );
  }

  void updatePhoneNumber(String value) {
    emit(
      state.copyWith(
        phone: value,
        isPhoneError: value.isNotEmpty && !PhoneNumberValidator.isValid(value),
        formValid: checkFormValid(state.nationalId, value, state.captcha),
        maskedPhone: maskPhoneNumber(value),
      ),
    );
  }

  void updateCaptcha(String value) {
    emit(
      state.copyWith(
        captcha: value,
        isCaptchaError: false,
        formValid: checkFormValid(state.nationalId, state.phone, value),
      ),
    );
  }

  void updateOtp(String value) {
    emit(
      state.copyWith(
        otp: value,
        otpValid: checkOtpValid(value, state.secondsRemaining),
      ),
    );
  }

  void validateNationalId() {
    if (isClosed || state.isOtp) return;
    emit(
      state.copyWith(
        isNationalIdError: !NationalCodeValidator.isValid(state.nationalId),
      ),
    );
  }

  void validatePhoneNumber() {
    if (isClosed || state.isOtp) return;
    emit(
      state.copyWith(isPhoneError: !PhoneNumberValidator.isValid(state.phone)),
    );
  }

  void validateCaptcha() {
    if (isClosed || state.isOtp) return;
    emit(
      state.copyWith(
        isCaptchaError: !CodeValidator.isValid(state.captcha, length: 6),
      ),
    );
  }

  bool requestOtp() {
    if (state.isOtp || state.status == RequestStatus.loading) return false;
    final nationalIdValid = NationalCodeValidator.isValid(state.nationalId);
    final phoneValid = PhoneNumberValidator.isValid(state.phone);
    final captchaValid = CodeValidator.isValid(state.captcha, length: 6);
    if (!nationalIdValid || !phoneValid || !captchaValid) {
      emit(
        state.copyWith(
          isNationalIdError: !nationalIdValid,
          isPhoneError: !phoneValid,
          isCaptchaError: !captchaValid,
        ),
      );
      return false;
    }
    final changePhone = state.step == AuthStep.changePhone;
    emit(
      state.copyWith(
        step: changePhone ? AuthStep.changePhoneOtp : AuthStep.loginOtp,
        isLoginForm: false,
        isOtp: true,
        isChangePhone: changePhone,
        otp: '',
        otpValid: false,
        secondsRemaining: 60,
        isNationalIdError: false,
        isPhoneError: false,
        isCaptchaError: false,
      ),
    );
    _startTimer();
    return true;
  }

  void refreshCaptcha() {
    emit(state.copyWith(captcha: '', isCaptchaError: false, formValid: false));
  }

  void resendOtp() {
    if (!state.isOtp || state.secondsRemaining > 0) return;
    emit(state.copyWith(otp: '', otpValid: false, secondsRemaining: 60));
    _startTimer();
  }

  void openChangePhone() {
    _timer?.cancel();
    emit(
      const AuthState.initial(
        step: AuthStep.changePhone,
        isLoginForm: false,
        isChangePhone: true,
      ),
    );
  }

  void closeChangePhone() {
    _timer?.cancel();
    emit(const AuthState.initial());
  }

  void backToChangePhoneForm() {
    _timer?.cancel();
    emit(
      state.copyWith(
        step: AuthStep.changePhone,
        isLoginForm: false,
        isOtp: false,
        isChangePhone: true,
        otp: '',
        otpValid: false,
        isNationalIdError: false,
        isPhoneError: false,
        isCaptchaError: false,
      ),
    );
  }

  void back() {
    _timer?.cancel();
    switch (state.step) {
      case AuthStep.login:
        break;
      case AuthStep.loginOtp:
        emit(
          state.copyWith(
            step: AuthStep.login,
            isLoginForm: true,
            isOtp: false,
            isChangePhone: false,
            otp: '',
            otpValid: false,
            isNationalIdError: false,
            isPhoneError: false,
            isCaptchaError: false,
          ),
        );
      case AuthStep.changePhone:
        emit(const AuthState.initial());
      case AuthStep.changePhoneOtp:
        backToChangePhoneForm();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed || !state.isOtp) {
        timer.cancel();
        return;
      }
      final remaining = state.secondsRemaining - 1;
      if (remaining <= 0) timer.cancel();
      emit(
        state.copyWith(
          secondsRemaining: remaining < 0 ? 0 : remaining,
          otpValid: checkOtpValid(state.otp, remaining),
        ),
      );
    });
  }

  bool checkFormValid(String nationalId, String phone, String captcha) {
    return NationalCodeValidator.isValid(nationalId) &&
        PhoneNumberValidator.isValid(phone) &&
        CodeValidator.isValid(captcha, length: 6);
  }

  bool checkOtpValid(String otp, int remainingSeconds) {
    return CodeValidator.isValid(otp, length: 4) && remainingSeconds > 0;
  }

  String maskPhoneNumber(String phone) {
    return phone.length != 11
        ? '0912*******42'
        : '${phone.substring(0, 4)}*******${phone.substring(9)}';
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
