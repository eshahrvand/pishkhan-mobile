import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_rules.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_form_shared.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthOtpForm extends StatelessWidget {
  const AuthOtpForm({this.onAuthenticated, super.key});
  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocSelector<AuthCubit, AuthState, String>(
          selector: (state) => authMaskedPhone(state),
          builder: (context, phone) => AuthSectionHeading(
            title: context.l10n.otpSentTitle,
            description: context.l10n.otpSentMessage('\u2066$phone\u2069'),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocSelector<AuthCubit, AuthState, String>(
                selector: (state) => state.otp,
                builder: (context, otp) => AppTextField(
                  value: otp,
                  hintText: context.l10n.otpHint,
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
                  onChanged: context.read<AuthCubit>().otpChanged,
                  onSubmitted: (_) => _submit(context),
                ),
              ),
            ),
            const SizedBox(width: 7),
            const SizedBox(width: 148, child: AuthOtpTimer()),
          ],
        ),
        const SizedBox(height: 24),
        BlocSelector<AuthCubit, AuthState, bool>(
          selector: (state) => authIsOtpValid(state),
          builder: (context, valid) => AppButton(
            onPressed: valid ? () => _submit(context) : null,
            label: context.l10n.enterDashboard,
            size: AppButtonSize.lg,
          ),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    if (!authIsOtpValid(context.read<AuthCubit>().state)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    onAuthenticated?.call();
  }
}

class AuthOtpTimer extends StatelessWidget {
  const AuthOtpTimer({super.key});

  @override
  Widget build(BuildContext context) => BlocSelector<AuthCubit, AuthState, int>(
    selector: (state) => state.secondsRemaining,
    builder: (context, remaining) => SizedBox(
      height: 44,
      child: AppButton(
        onPressed: remaining == 0 ? context.read<AuthCubit>().resendOtp : () {},
        label: remaining == 0
            ? context.l10n.resendOtp
            : '00:${remaining.toString().padLeft(2, '0')}',
        trailingIcon: SvgPicture.asset(AuthAssets.clock, width: 20, height: 20),
        variant: AppButtonVariant.text,
        size: AppButtonSize.lg,
        horizontalPadding: 4,
      ),
    ),
  );
}
