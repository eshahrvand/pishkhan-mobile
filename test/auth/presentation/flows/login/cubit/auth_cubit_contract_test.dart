import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';

void main() {
  test('OTP completion is guarded and published only once', () async {
    final cubit = AuthCubit(
      initialState: const AuthState.initial(
        isOtp: true,
        step: AuthStep.loginOtp,
        otp: '1234',
        otpValid: true,
      ),
    );
    cubit.submitOtp();
    expect(cubit.state.effect, isA<AuthCompleted>());
    final effectId = cubit.state.effectId;
    cubit.submitOtp();
    expect(cubit.state.effectId, effectId);
    await cubit.close();
    final expired = AuthCubit(
      initialState: const AuthState.initial(
        isOtp: true,
        step: AuthStep.loginOtp,
        otp: '1234',
        otpValid: true,
        secondsRemaining: 0,
      ),
    );
    expired.submitOtp();
    expect(expired.state.effect, isNull);
    await expired.close();
  });
  test(
    'guest service selection owns change-phone routing and repeated effects',
    () async {
      final cubit = AuthCubit();
      cubit.selectGuestService(null);
      expect(cubit.state.effectId, 0);
      cubit.selectGuestService('requests.status');
      expect(
        (cubit.state.effect as AuthGuestServiceRequested).id,
        'requests.status',
      );
      final first = cubit.state.effectId;
      cubit.selectGuestService('requests.status');
      expect(cubit.state.effectId, first + 1);
      cubit.selectGuestService('identity.changePhone');
      expect(cubit.state.step, AuthStep.changePhone);
      await cubit.close();
    },
  );
}
