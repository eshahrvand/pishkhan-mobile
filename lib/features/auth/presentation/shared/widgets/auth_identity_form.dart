import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_captcha_row.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_field_icon.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_inline_action.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_numeric_field.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_phone_ownership_notice.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_section_heading.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthIdentityForm extends StatelessWidget {
  const AuthIdentityForm({required this.changePhone, super.key});
  final bool changePhone;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final l10n = context.l10n;
    final step = changePhone ? AuthStep.changePhone : AuthStep.login;
    return Column(
      key: const Key('auth_identity_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthSectionHeading(
          title: changePhone ? l10n.changeMobileTitle : l10n.loginTitle,
          description: changePhone
              ? l10n.changeMobileDescription
              : l10n.loginDescription,
        ),
        const SizedBox(height: 32),
        BlocSelector<AuthCubit, AuthState, (String, bool)>(
          selector: (state) =>
              (state.nationalId, state.invalidFields.contains('nationalId')),
          builder: (context, value) => AuthNumericField(
            key: ValueKey('${step.name}-national-id'),
            value: value.$1,
            hintText: changePhone
                ? l10n.changeNationalIdHint
                : l10n.loginNationalIdHint,
            errorText: value.$2 ? l10n.authInvalidNationalId : null,
            prefixIcon: const AuthFieldIcon(AuthAssets.user),
            maxLength: 10,
            onChanged: cubit.nationalIdChanged,
            onFocusLost: () => cubit.validateField('nationalId'),
          ),
        ),
        const SizedBox(height: 20),
        BlocSelector<AuthCubit, AuthState, (String, bool)>(
          selector: (state) =>
              (state.phone, state.invalidFields.contains('phone')),
          builder: (context, value) => AuthNumericField(
            key: ValueKey('${step.name}-phone'),
            value: value.$1,
            hintText: changePhone ? l10n.changePhoneHint : l10n.loginPhoneHint,
            errorText: value.$2 ? l10n.authInvalidPhone : null,
            prefixIcon: const AuthFieldIcon(AuthAssets.mobile),
            maxLength: 11,
            keyboardType: TextInputType.phone,
            onChanged: cubit.phoneChanged,
            onFocusLost: () => cubit.validateField('phone'),
          ),
        ),
        const SizedBox(height: 12),
        if (changePhone)
          const AuthPhoneOwnershipNotice()
        else
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AuthInlineAction(
              key: const Key('change_phone_button'),
              label: l10n.changePhoneAction,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                cubit.openChangePhone();
              },
            ),
          ),
        const SizedBox(height: 24),
        AuthCaptchaRow(step: step),
        const SizedBox(height: 24),
        AppButton(
          key: const Key('request_otp_button'),
          label: l10n.requestOtp,
          size: AppButtonSize.md,
          onPressed: () {
            if (cubit.requestOtp()) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
        ),
      ],
    );
  }
}
