import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

part 'auth_state.freezed.dart';

enum AuthStep { login, loginOtp, changePhone, changePhoneOtp }

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(AuthStep.login) AuthStep step,
    @Default('') String nationalId,
    @Default('') String phone,
    @Default('') String captcha,
    @Default('') String otp,
    @Default(60) int secondsRemaining,
    @Default({}) Set<String> invalidFields,
  }) = _AuthState;
}
