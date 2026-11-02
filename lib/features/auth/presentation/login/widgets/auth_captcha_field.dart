import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

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
                previous.canRequestOtp != current.canRequestOtp ||
                previous.captchaStatus != current.captchaStatus ||
                previous.otpRequestStatus != current.otpRequestStatus,
            builder: (context, state) {
              return AppTextField(
                value: state.captcha,
                enabled:
                    state.captchaStatus != RequestStatus.loading &&
                    state.otpRequestStatus != RequestStatus.loading,
                hintText: S.current.captchaHint,
                errorText: state.isCaptchaError
                    ? S.current.authInvalidCaptcha
                    : null,
                suffixIcon: SizedBox(
                  width: 48,
                  height: 44,
                  child: AppButton(
                    isLoading:
                        state.captchaStatus == RequestStatus.loading ||
                        state.otpRequestStatus == RequestStatus.loading,
                    onPressed: context.read<AuthCubit>().fetchCaptcha,
                    icon: AvpImage(
                      image: '${AppConstants.baseImage}auth_refresh.svg',
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
                onSubmitted:
                    state.canRequestOtp &&
                        state.otpRequestStatus != RequestStatus.loading
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
            child: BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  previous.captchaImage != current.captchaImage,
              builder: (context, state) {
                return state.captchaImage == null
                    ? const SizedBox(width: 100, height: 34)
                    // AvpImage has no in-memory byte source. Keep sensitive CAPTCHA
                    // bytes in memory, without network/disk image caching.
                    : Image.memory(
                        state.captchaImage!.bytes,
                        width: 100,
                        height: 34,
                        fit: BoxFit.contain,
                        gaplessPlayback: false,
                        excludeFromSemantics: true,
                        errorBuilder: (context, error, stackTrace) => AvpImage(
                          image:
                              '${AppConstants.baseImage}auth_info_circle.svg',
                          width: 20,
                          height: 20,
                        ),
                      );
              },
            ),
          ),
        ),
      ],
    );
  }
}
