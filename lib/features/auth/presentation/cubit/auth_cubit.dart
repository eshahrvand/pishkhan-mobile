import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  Timer? _timer;

  void nationalIdChanged(String value) =>
      emit(state.copyWith(nationalId: value));
  void phoneChanged(String value) => emit(state.copyWith(phone: value));
  void captchaChanged(String value) => emit(state.copyWith(captcha: value));
  void otpChanged(String value) => emit(state.copyWith(otp: value));

  void requestOtp() {
    if (!state.isFormValid) return;
    final nextStep = state.step == AuthStep.changePhone
        ? AuthStep.changePhoneOtp
        : AuthStep.loginOtp;
    emit(state.copyWith(step: nextStep, otp: '', secondsRemaining: 60));
    _startTimer();
  }

  void resendOtp() {
    emit(state.copyWith(secondsRemaining: 60));
    _startTimer();
  }

  void openChangePhone() {
    _timer?.cancel();
    emit(const AuthState(step: AuthStep.changePhone));
  }

  void closeChangePhone() {
    _timer?.cancel();
    emit(const AuthState());
  }

  void backToChangePhoneForm() {
    _timer?.cancel();
    emit(
      state.copyWith(step: AuthStep.changePhone, otp: '', secondsRemaining: 60),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining <= 1) {
        timer.cancel();
        emit(state.copyWith(secondsRemaining: 0));
      } else {
        emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
