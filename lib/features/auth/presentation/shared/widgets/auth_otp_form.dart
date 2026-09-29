import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_field_icon.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthOtpForm extends StatelessWidget {
  const AuthOtpForm({required this.state, super.key});

  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final l10n = context.l10n;
    final isChangePhone = state.step == AuthStep.changePhoneOtp;
    return Column(
      key: const Key('auth_otp_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.otpSentMessage(state.maskedPhone),
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textSecondary,
            height: 20 / 14,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                key: ValueKey('${state.step.name}-otp'),
                hintText: l10n.otpHint,
                prefixIcon: const AuthFieldIcon('$authAssetPath/lock.svg'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                normalizeDigits: true,
                focusRing: AppTextFieldFocusRing.subtle,
                inputFormatters: [LengthLimitingTextInputFormatter(4)],
                onChanged: cubit.otpChanged,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(child: _OtpTimer(state: state)),
          ],
        ),
        const SizedBox(height: 24),
        AppButton(
          key: const Key('submit_otp_button'),
          onPressed: state.isOtpValid ? () {} : null,
          label: isChangePhone ? l10n.submitRequest : l10n.enterDashboard,
          size: AppButtonSize.lg,
        ),
      ],
    );
  }
}

class _OtpTimer extends StatelessWidget {
  const _OtpTimer({required this.state});

  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final seconds = state.secondsRemaining.toString().padLeft(2, '0');
    final expired = state.secondsRemaining == 0;
    return SizedBox(
      height: 44,
      child: AppButton(
        key: const Key('otp_timer_button'),
        onPressed: expired ? context.read<AuthCubit>().resendOtp : () {},
        label: expired ? context.l10n.resendOtp : '00:$seconds',
        trailingIcon: SvgPicture.asset(
          '$authAssetPath/clock.svg',
          width: 20,
          height: 20,
        ),
        variant: AppButtonVariant.text,
        size: AppButtonSize.lg,
      ),
    );
  }
}
