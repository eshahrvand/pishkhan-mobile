import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_captcha_row.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_field_icon.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_inline_action.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_phone_ownership_notice.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthIdentityForm extends StatelessWidget {
  const AuthIdentityForm({required this.state, super.key});

  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final l10n = context.l10n;
    final changePhone = state.step == AuthStep.changePhone;
    return Column(
      key: const Key('auth_identity_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (changePhone)
          Text(
            l10n.changeMobileDescription,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              height: 20 / 14,
              letterSpacing: 0,
            ),
          )
        else
          Text(
            l10n.loginTitle,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 28 / 18,
              letterSpacing: 0,
            ),
          ),
        SizedBox(height: changePhone ? 20 : 32),
        AppTextField(
          key: ValueKey('${state.step.name}-national-id'),
          hintText: changePhone
              ? l10n.changeNationalIdHint
              : l10n.loginNationalIdHint,
          prefixIcon: const AuthFieldIcon(AuthAssets.user),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          normalizeDigits: true,
          focusRing: AppTextFieldFocusRing.subtle,
          inputFormatters: [LengthLimitingTextInputFormatter(10)],
          onChanged: cubit.nationalIdChanged,
        ),
        const SizedBox(height: 20),
        AppTextField(
          key: ValueKey('${state.step.name}-phone'),
          hintText: changePhone ? l10n.changePhoneHint : l10n.loginPhoneHint,
          prefixIcon: const AuthFieldIcon(AuthAssets.mobile),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          normalizeDigits: true,
          focusRing: AppTextFieldFocusRing.subtle,
          inputFormatters: [LengthLimitingTextInputFormatter(11)],
          onChanged: cubit.phoneChanged,
        ),
        if (changePhone) ...[
          const SizedBox(height: 12),
          const AuthPhoneOwnershipNotice(),
          const SizedBox(height: 24),
        ] else ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: AuthInlineAction(
              key: const Key('change_phone_button'),
              onTap: cubit.openChangePhone,
              label: l10n.changePhoneAction,
            ),
          ),
          const SizedBox(height: 24),
        ],
        AuthCaptchaRow(step: state.step, onChanged: cubit.captchaChanged),
        const SizedBox(height: 24),
        AppButton(
          key: const Key('request_otp_button'),
          onPressed: state.isFormValid ? cubit.requestOtp : null,
          label: changePhone ? l10n.requestTwoFactorCode : l10n.requestOtp,
          size: AppButtonSize.lg,
        ),
      ],
    );
  }
}
