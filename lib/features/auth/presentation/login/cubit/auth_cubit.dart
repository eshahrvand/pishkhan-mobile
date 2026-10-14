import 'package:pishkhan_mobile/core/validators/validators.dart';

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';
export 'auth_state.dart';

/// UI state for the login prototype. Bank authentication is not connected yet.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthState initialState = const AuthState()})
    : super(_prepareState(initialState));
  Timer? _timer;

  Set<String> _clearError(String field) =>
      {...state.invalidFields}..remove(field);

  void nationalIdChanged(String value) => emit(
    _prepareState(
      state.copyWith(
        nationalId: value,
        invalidFields: _clearError('nationalId'),
      ),
    ),
  );
  void phoneChanged(String value) => emit(
    _prepareState(
      state.copyWith(phone: value, invalidFields: _clearError('phone')),
    ),
  );
  void captchaChanged(String value) => emit(
    _prepareState(
      state.copyWith(captcha: value, invalidFields: _clearError('captcha')),
    ),
  );
  void otpChanged(String value) =>
      emit(_prepareState(state.copyWith(otp: value)));

  bool _fieldIsValid(String field) => switch (field) {
    'nationalId' => NationalCodeValidator.isValid(state.nationalId),
    'phone' => PhoneNumberValidator.isValid(state.phone),
    'captcha' => CodeValidator.isValid(state.captcha, length: 6),
    _ => true,
  };

  void validateField(String field) {
    if (isClosed || state.isOtp) return;
    final errors = {...state.invalidFields};
    if (_fieldIsValid(field)) {
      errors.remove(field);
    } else {
      errors.add(field);
    }
    emit(_prepareState(state.copyWith(invalidFields: errors)));
  }

  bool requestOtp() {
    if (state.isOtp) return false;
    final errors = {
      for (final field in ['nationalId', 'phone', 'captcha'])
        if (!_fieldIsValid(field)) field,
    };
    if (errors.isNotEmpty) {
      emit(_prepareState(state.copyWith(invalidFields: errors)));
      return false;
    }
    emit(
      _prepareState(
        state.copyWith(
          step: state.step == AuthStep.changePhone
              ? AuthStep.changePhoneOtp
              : AuthStep.loginOtp,
          otp: '',
          secondsRemaining: 60,
          invalidFields: {},
        ),
      ),
    );
    _startTimer();
    return true;
  }

  void refreshCaptcha() => emit(
    _prepareState(
      state.copyWith(captcha: '', invalidFields: _clearError('captcha')),
    ),
  );

  void resendOtp() {
    if (!state.isOtp || state.secondsRemaining > 0) return;
    emit(_prepareState(state.copyWith(otp: '', secondsRemaining: 60)));
    _startTimer();
  }

  void openChangePhone() {
    _timer?.cancel();
    emit(_prepareState(const AuthState(step: AuthStep.changePhone)));
  }

  void closeChangePhone() {
    _timer?.cancel();
    emit(_prepareState(const AuthState()));
  }

  void backToChangePhoneForm() {
    _timer?.cancel();
    emit(
      _prepareState(
        state.copyWith(step: AuthStep.changePhone, otp: '', invalidFields: {}),
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
          _prepareState(
            state.copyWith(step: AuthStep.login, otp: '', invalidFields: {}),
          ),
        );
      case AuthStep.changePhone:
        emit(_prepareState(const AuthState()));
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
        _prepareState(
          state.copyWith(secondsRemaining: remaining < 0 ? 0 : remaining),
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  static AuthState _prepareState(AuthState next) {
    final otp =
        next.step == AuthStep.loginOtp || next.step == AuthStep.changePhoneOtp;
    return next.copyWith(
      isLoginForm: next.step == AuthStep.login,
      isOtp: otp,
      isChangePhone:
          next.step == AuthStep.changePhone ||
          next.step == AuthStep.changePhoneOtp,
      formValid:
          NationalCodeValidator.isValid(next.nationalId) &&
          PhoneNumberValidator.isValid(next.phone) &&
          CodeValidator.isValid(next.captcha, length: 6),
      otpValid:
          CodeValidator.isValid(next.otp, length: 4) &&
          next.secondsRemaining > 0,
      maskedPhone: next.phone.length != 11
          ? '0912*******42'
          : '${next.phone.substring(0, 4)}*******${next.phone.substring(9)}',
    );
  }
}
