import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_field_icon.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_numeric_field.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_section_heading.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthOtpForm extends StatelessWidget {
  const AuthOtpForm({this.onAuthenticated, super.key});
  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final step = cubit.state.step;
    return Column(
      key: const Key('auth_otp_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocSelector<AuthCubit, AuthState, String>(
          selector: (state) => state.maskedPhone,
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
                builder: (context, otp) => AuthNumericField(
                  key: ValueKey('${step.name}-otp'),
                  value: otp,
                  hintText: context.l10n.otpHint,
                  prefixIcon: const AuthFieldIcon(AuthAssets.lock),
                  maxLength: 4,
                  textInputAction: TextInputAction.done,
                  onChanged: cubit.otpChanged,
                  onSubmitted: (_) => _submit(context),
                ),
              ),
            ),
            const SizedBox(width: 7),
            const SizedBox(width: 148, child: _OtpTimer()),
          ],
        ),
        const SizedBox(height: 24),
        BlocSelector<AuthCubit, AuthState, bool>(
          selector: (state) => state.isOtpValid,
          builder: (context, valid) => AppButton(
            key: const Key('submit_otp_button'),
            onPressed: valid ? () => _submit(context) : null,
            label: context.l10n.enterDashboard,
            size: AppButtonSize.lg,
          ),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    if (!context.read<AuthCubit>().state.isOtpValid) return;
    FocusManager.instance.primaryFocus?.unfocus();
    onAuthenticated?.call();
  }
}

class _OtpTimer extends StatelessWidget {
  const _OtpTimer();

  @override
  Widget build(BuildContext context) => BlocSelector<AuthCubit, AuthState, int>(
    selector: (state) => state.secondsRemaining,
    builder: (context, remaining) => SizedBox(
      height: 44,
      child: AppButton(
        key: const Key('otp_timer_button'),
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
