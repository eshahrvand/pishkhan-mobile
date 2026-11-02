import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_request_error.dart';

import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_form_shared.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthOtpForm extends StatelessWidget {
  const AuthOtpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.maskedPhone != current.maskedPhone,
          builder: (context, state) {
            return AuthSectionHeading(
              title: S.current.otpSentTitle,
              description: S.current.otpSentMessage(
                '\u2066${state.maskedPhone}\u2069',
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (previous, current) =>
                    previous.otp != current.otp ||
                    previous.canSubmitLogin != current.canSubmitLogin ||
                    previous.loginStatus != current.loginStatus ||
                    previous.challenge != current.challenge,
                builder: (context, state) {
                  return AppTextField(
                    value: state.otp,
                    enabled:
                        state.loginStatus != RequestStatus.loading &&
                        state.loginStatus != RequestStatus.success,
                    autocorrect: false,
                    enableSuggestions: false,
                    enableIMEPersonalizedLearning: false,
                    hintText: S.current.otpHint,
                    prefixIcon: SizedBox(
                      width: 48,
                      height: 44,
                      child: Center(
                        child: AvpImage(
                          image: '${AppConstants.baseImage}auth_lock.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.start,
                    textStyle: Theme.of(context).textTheme.bodyMedium!
                        .copyWith(height: 20 / 14, letterSpacing: 0),
                    normalizeDigits: true,
                    focusRing: AppTextFieldFocusRing.subtle,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      context.read<AuthCubit>().updateOtp(value);
                    },
                    onSubmitted:
                        state.canSubmitLogin &&
                            state.loginStatus != RequestStatus.loading
                        ? (_) {
                            context.read<AuthCubit>().submitLogin(
                              state.challenge!,
                            );
                          }
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(width: 7),
            SizedBox(
              width: 148,
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (previous, current) =>
                    previous.remainingSeconds != current.remainingSeconds ||
                    previous.canResendOtp != current.canResendOtp ||
                    previous.loginStatus != current.loginStatus ||
                    previous.challenge != current.challenge,
                builder: (context, state) {
                  return SizedBox(
                    height: 44,
                    child: AppButton(
                      isLoading: state.loginStatus == RequestStatus.loading,
                      onPressed: state.canResendOtp
                          ? () {
                              context.read<AuthCubit>().submitOtpResend();
                            }
                          : null,
                      label: state.remainingSeconds == 0
                          ? S.current.resendOtp
                          : getOtpRemainingTime(state.remainingSeconds),
                      trailingIcon: AvpImage(
                        image: '${AppConstants.baseImage}auth_clock.svg',
                        width: 20,
                        height: 20,
                      ),
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.lg,
                      horizontalPadding: 4,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.canSubmitLogin != current.canSubmitLogin ||
              previous.loginStatus != current.loginStatus ||
              previous.challenge != current.challenge,
          builder: (context, state) {
            return AppButton(
              isLoading: state.loginStatus == RequestStatus.loading,
              onPressed: state.canSubmitLogin
                  ? () {
                      context.read<AuthCubit>().submitLogin(state.challenge!);
                    }
                  : null,
              label: S.current.enterDashboard,
              size: AppButtonSize.lg,
            );
          },
        ),
        const AuthRequestError(),
      ],
    );
  }
}

String getOtpRemainingTime(int remainingSeconds) {
  return '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:'
      '${(remainingSeconds % 60).toString().padLeft(2, '0')}';
}
