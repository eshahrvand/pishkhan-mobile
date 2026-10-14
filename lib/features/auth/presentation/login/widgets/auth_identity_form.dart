import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_form_shared.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthIdentityForm extends StatelessWidget {
  const AuthIdentityForm({required this.changePhone, super.key});
  final bool changePhone;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthSectionHeading(
          title: changePhone
              ? S.current.changeMobileTitle
              : S.current.loginTitle,
          description: changePhone
              ? S.current.changeMobileDescription
              : S.current.loginDescription,
        ),
        const SizedBox(height: 32),
        AuthIdentityFields(changePhone: changePhone),
        const SizedBox(height: 24),
        const AuthCaptchaRow(),
        const SizedBox(height: 24),
        AppButton(
          label: S.current.requestOtp,
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

class AuthCaptchaRow extends StatelessWidget {
  const AuthCaptchaRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (previous, current) =>
                previous.captcha != current.captcha ||
                previous.isCaptchaError != current.isCaptchaError,
            builder: (context, state) => AppTextField(
              value: state.captcha,
              hintText: S.current.captchaHint,
              errorText: state.isCaptchaError
                  ? S.current.authInvalidCaptcha
                  : null,
              suffixIcon: AuthFieldIcon(
                AuthAssets.refresh,
                semanticLabel: S.current.refreshCaptcha,
                onPressed: cubit.refreshCaptcha,
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
              onChanged: cubit.updateCaptcha,
              onFocusLost: () => cubit.validateCaptcha(),
              onSubmitted: (_) {
                if (cubit.requestOtp()) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 7),
        SizedBox(
          width: 148,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(color: context.colors.border),
              borderRadius: AppRadius.borderSm,
              boxShadow: AppShadows.xs,
            ),
            child: Image.asset(
              AuthAssets.captcha,
              width: 100,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthIdentityFields extends StatelessWidget {
  const AuthIdentityFields({super.key, required this.changePhone});
  final bool changePhone;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.nationalId != current.nationalId ||
              previous.isNationalIdError != current.isNationalIdError,
          builder: (context, state) => AppTextField(
            value: state.nationalId,
            hintText: changePhone
                ? S.current.changeNationalIdHint
                : S.current.loginNationalIdHint,
            errorText: state.isNationalIdError
                ? S.current.authInvalidNationalId
                : null,
            prefixIcon: const AuthFieldIcon(AuthAssets.user),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.start,
            textStyle: Theme.of(context).textTheme.bodyMedium!
                .copyWith(height: 20 / 14, letterSpacing: 0),
            normalizeDigits: true,
            focusRing: AppTextFieldFocusRing.subtle,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 10,
            onChanged: cubit.updateNationalId,
            onFocusLost: () => cubit.validateNationalId(),
          ),
        ),
        const SizedBox(height: 20),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.phone != current.phone ||
              previous.isPhoneError != current.isPhoneError,
          builder: (context, state) => AppTextField(
            value: state.phone,
            hintText: changePhone
                ? S.current.changePhoneHint
                : S.current.loginPhoneHint,
            errorText: state.isPhoneError ? S.current.authInvalidPhone : null,
            prefixIcon: const AuthFieldIcon(AuthAssets.mobile),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.start,
            textStyle: Theme.of(context).textTheme.bodyMedium!
                .copyWith(height: 20 / 14, letterSpacing: 0),
            normalizeDigits: true,
            focusRing: AppTextFieldFocusRing.subtle,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            maxLength: 11,
            keyboardType: TextInputType.phone,
            onChanged: cubit.updatePhoneNumber,
            onFocusLost: () => cubit.validatePhoneNumber(),
          ),
        ),
        const SizedBox(height: 12),
        if (changePhone)
          Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 14, 6),
            decoration: const BoxDecoration(
              color: AppLoginColors.noticeSurface,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                SvgPicture.asset(AuthAssets.infoCircle, width: 20, height: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.current.phoneOwnershipNotice,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppLoginColors.noticeText,
                      fontWeight: FontWeight.w500,
                      height: 18 / 12,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Semantics(
              button: true,
              label: S.current.changePhoneAction,
              child: InkWell(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  cubit.openChangePhone();
                },
                borderRadius: AppRadius.borderSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    S.current.changePhoneAction,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: context.colors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
