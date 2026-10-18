import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthCaptchaField extends StatelessWidget {
  const AuthCaptchaField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (previous, current) =>
                previous.captcha != current.captcha ||
                previous.isCaptchaError != current.isCaptchaError ||
                previous.canRequestOtp != current.canRequestOtp,
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
                      context.read<AuthCubit>().resetCaptcha();
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
                onSubmitted: state.canRequestOtp
                    ? (_) {
                        context.read<AuthCubit>().submitOtpRequest();
                      }
                    : null,
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
    );
  }
}
