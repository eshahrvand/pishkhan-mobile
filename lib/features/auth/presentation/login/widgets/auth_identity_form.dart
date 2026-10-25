import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_form_shared.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'auth_captcha_field.dart';
import 'auth_request_error.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';

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
              previous.isNationalIdError != current.isNationalIdError ||
              previous.otpRequestStatus != current.otpRequestStatus,
          builder: (context, state) {
            return AppTextField(
              value: state.nationalId,
              enabled: state.otpRequestStatus != RequestStatus.loading,
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
                    image: '${AppConstants.baseImage}auth_user.svg',
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
              previous.phoneNumber != current.phoneNumber ||
              previous.isPhoneNumberError != current.isPhoneNumberError ||
              previous.otpRequestStatus != current.otpRequestStatus,
          builder: (context, state) {
            return AppTextField(
              value: state.phoneNumber,
              enabled: state.otpRequestStatus != RequestStatus.loading,
              hintText: changePhone
                  ? S.current.changePhoneHint
                  : S.current.loginPhoneHint,
              errorText: state.isPhoneNumberError
                  ? S.current.authInvalidPhone
                  : null,
              prefixIcon: SizedBox(
                width: 48,
                height: 44,
                child: Center(
                  child: AvpImage(
                    image: '${AppConstants.baseImage}auth_mobile.svg',
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
                AvpImage(
                  image: '${AppConstants.baseImage}auth_info_circle.svg',
                  width: 20,
                  height: 20,
                ),
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
            child: BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  previous.otpRequestStatus != current.otpRequestStatus,
              builder: (context, state) => Semantics(
                button: true,
                label: S.current.changePhoneAction,
                child: InkWell(
                  onTap: state.otpRequestStatus != RequestStatus.loading
                      ? () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          context.read<AuthCubit>().openChangePhone();
                        }
                      : null,
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
          ),
        const SizedBox(height: 24),
        const AuthCaptchaField(),
        const SizedBox(height: 24),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) {
            return previous.canRequestOtp != current.canRequestOtp ||
                previous.otpRequestStatus != current.otpRequestStatus;
          },
          builder: (context, state) {
            return AppButton(
              label: S.current.requestOtp,
              isLoading: state.otpRequestStatus == RequestStatus.loading,
              size: AppButtonSize.md,
              onPressed: state.canRequestOtp
                  ? () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      context.read<AuthCubit>().submitOtpRequest();
                    }
                  : null,
            );
          },
        ),
        if (changePhone) const AuthRequestError(),
      ],
    );
  }
}
