import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_form_shared.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthOtpForm extends StatelessWidget {
  const AuthOtpForm({this.onAuthenticated, super.key});
  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.maskedPhone != current.maskedPhone,
          builder: (context, state) => AuthSectionHeading(
            title: S.current.otpSentTitle,
            description: S.current.otpSentMessage(
              '\u2066${state.maskedPhone}\u2069',
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (previous, current) => previous.otp != current.otp,
                builder: (context, state) => AppTextField(
                  value: state.otp,
                  hintText: S.current.otpHint,
                  prefixIcon: const AuthFieldIcon(AuthAssets.lock),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.start,
                  textStyle: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(height: 20 / 14, letterSpacing: 0),
                  normalizeDigits: true,
                  focusRing: AppTextFieldFocusRing.subtle,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onChanged: context.read<AuthCubit>().updateOtp,
                  onSubmitted: (_) => _submit(context),
                ),
              ),
            ),
            const SizedBox(width: 7),
            const SizedBox(width: 148, child: AuthOtpTimer()),
          ],
        ),
        const SizedBox(height: 24),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.otpValid != current.otpValid,
          builder: (context, state) => AppButton(
            onPressed: state.otpValid ? () => _submit(context) : null,
            label: S.current.enterDashboard,
            size: AppButtonSize.lg,
          ),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    if (!context.read<AuthCubit>().state.otpValid) return;
    FocusManager.instance.primaryFocus?.unfocus();
    onAuthenticated?.call();
  }
}

class AuthOtpTimer extends StatelessWidget {
  const AuthOtpTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          previous.secondsRemaining != current.secondsRemaining,
      builder: (context, state) => SizedBox(
        height: 44,
        child: AppButton(
          onPressed: state.secondsRemaining == 0
              ? context.read<AuthCubit>().resendOtp
              : () {},
          label: state.secondsRemaining == 0
              ? S.current.resendOtp
              : getOtpRemainingTime(state.secondsRemaining),
          trailingIcon: SvgPicture.asset(
            AuthAssets.clock,
            width: 20,
            height: 20,
          ),
          variant: AppButtonVariant.text,
          size: AppButtonSize.lg,
          horizontalPadding: 4,
        ),
      ),
    );
  }
}

String getOtpRemainingTime(int secondsRemaining) {
  return '${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:'
      '${(secondsRemaining % 60).toString().padLeft(2, '0')}';
}
