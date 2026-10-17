import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_form_shared.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthIdentityForm extends StatelessWidget {
  const AuthIdentityForm({required this.changePhone, super.key});
  final bool changePhone;

  @override
  Widget build(BuildContext context) {
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
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.nationalId != current.nationalId ||
              previous.isNationalIdError != current.isNationalIdError,
          builder: (context, state) {
            return AppTextField(
              value: state.nationalId,
              hintText: changePhone
                  ? S.current.changeNationalIdHint
                  : S.current.loginNationalIdHint,
              errorText: state.isNationalIdError
                  ? S.current.authInvalidNationalId
                  : null,
              prefixIcon: SizedBox(
                width: 48,
                height: 44,
                child: Center(
                  child: AvpImage(
                    image: AuthAssets.user,
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
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 10,
              onChanged: (value) {
                context.read<AuthCubit>().updateNationalId(value);
              },
              onFocusLost: () {
                context.read<AuthCubit>().validateNationalId();
              },
            );
          },
        ),
        const SizedBox(height: 20),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.phone != current.phone ||
              previous.isPhoneError != current.isPhoneError,
          builder: (context, state) {
            return AppTextField(
              value: state.phone,
              hintText: changePhone
                  ? S.current.changePhoneHint
                  : S.current.loginPhoneHint,
              errorText: state.isPhoneError ? S.current.authInvalidPhone : null,
              prefixIcon: SizedBox(
                width: 48,
                height: 44,
                child: Center(
                  child: AvpImage(
                    image: AuthAssets.mobile,
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
              textInputAction: TextInputAction.next,
              maxLength: 11,
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                context.read<AuthCubit>().updatePhoneNumber(value);
              },
              onFocusLost: () {
                context.read<AuthCubit>().validatePhoneNumber();
              },
            );
          },
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
                AvpImage(image: AuthAssets.infoCircle, width: 20, height: 20),
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
                  context.read<AuthCubit>().openChangePhone();
                },
                borderRadius: AppRadius.borderSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    S.current.changePhoneAction,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (previous, current) =>
                    previous.captcha != current.captcha ||
                    previous.isCaptchaError != current.isCaptchaError,
                builder: (context, state) {
                  return AppTextField(
                    value: state.captcha,
                    hintText: S.current.captchaHint,
                    errorText: state.isCaptchaError
                        ? S.current.authInvalidCaptcha
                        : null,
                    suffixIcon: SizedBox(
                      width: 48,
                      height: 44,
                      child: AppButton(
                        onPressed: () {
                          context.read<AuthCubit>().refreshCaptcha();
                        },
                        icon: AvpImage(
                          image: AuthAssets.refresh,
                          width: 20,
                          height: 20,
                        ),
                        tooltip: S.current.refreshCaptcha,
                        semanticLabel: S.current.refreshCaptcha,
                        variant: AppButtonVariant.text,
                        size: AppButtonSize.lg,
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
                      context.read<AuthCubit>().updateCaptcha(value);
                    },
                    onFocusLost: () {
                      context.read<AuthCubit>().validateCaptcha();
                    },
                    onSubmitted: (_) {
                      context.read<AuthCubit>().requestOtp();
                    },
                  );
                },
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
                child: AvpImage(
                  image: AuthAssets.captcha,
                  width: 100,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) {
            return previous.formValid != current.formValid ||
                previous.status != current.status;
          },
          builder: (context, state) {
            return AppButton(
              label: S.current.requestOtp,
              size: AppButtonSize.md,
              isActive: state.formValid,
              isLoading: state.status == RequestStatus.loading,
              onPressed: () {
                context.read<AuthCubit>().requestOtp();
              },
            );
          },
        ),
      ],
    );
  }
}
