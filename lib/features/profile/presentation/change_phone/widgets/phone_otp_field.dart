import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../shared/profile_labels.dart';
import '../cubit/change_phone_cubit.dart';

/// Keeps the timer's subscription separate from the phone/settings form.
class PhoneOtpField extends StatelessWidget {
  const PhoneOtpField({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePhoneCubit, ChangePhoneState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        S.current.profileSecondPassword,
                        style: certificateLabelStyle(context),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        value: state.otp,
                        hintText: S.current.profileOtpHint,
                        // Keep the SVG at its 20px source size inside the field's 48×44 slot.
                        prefixIcon: SizedBox(
                          width: 48,
                          height: 44,
                          child: Center(
                            child: SizedBox.square(
                              dimension: 20,
                              child: AvpImage(
                                image:
                                    '${AppConstants.baseImage}profile_lock.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                        enabled:
                            state.challenge != null &&
                            state.remainingSeconds > 0 &&
                            state.otpRequestStatus != RequestStatus.loading &&
                            state.submissionStatus != RequestStatus.loading &&
                            state.submissionStatus != RequestStatus.success,
                        maxLength: state.challenge?.codeLength ?? 4,
                        normalizeDigits: true,
                        keyboardType: TextInputType.number,
                        autocorrect: false,
                        enableSuggestions: false,
                        enableIMEPersonalizedLearning: false,
                        textAlign: TextAlign.right,
                        textStyle: certificateValueStyle(context),
                        errorText: state.isOtpError
                            ? S.current.profileOtpInvalid
                            : null,
                        onChanged: (value) {
                          context.read<ChangePhoneCubit>().updateOtp(value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: state.remainingSeconds > 0
                      ? SizedBox(
                          height: 44,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                CurrencyFormatter.toPersianDigits(
                                  phoneCountdownLabel(state.remainingSeconds),
                                ),
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: context.colors.primary,
                                      height: 20 / 14,
                                      letterSpacing: 0,
                                    ),
                              ),
                              const SizedBox(width: 10),
                              AvpImage(
                                image:
                                    '${AppConstants.baseImage}auth_clock.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        )
                      : AppButton(
                          label: S.current.profileRequestOtp,
                          size: AppButtonSize.lg,
                          variant: AppButtonVariant.text,
                          constrainLabel: true,
                          isLoading:
                              state.otpRequestStatus == RequestStatus.loading,
                          onPressed: state.canRequestOtp
                              ? () {
                                  context
                                      .read<ChangePhoneCubit>()
                                      .submitOtpRequest();
                                }
                              : null,
                        ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
