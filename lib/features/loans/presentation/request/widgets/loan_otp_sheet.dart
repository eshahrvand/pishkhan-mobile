import 'loan_otp_digits.dart';

import 'package:pishkhan_mobile/core/config/constant.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../cubit/loan_request_cubit.dart';
import 'loan_request_labels.dart';

class LoanOtpSheet extends StatelessWidget {
  const LoanOtpSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoanRequestCubit, LoanRequestState>(
      listenWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus &&
          current.submissionStatus == RequestStatus.success,
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      builder: (context, state) {
        return PopScope(
          canPop: state.submissionStatus != RequestStatus.loading,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppBottomSheetHeader(
                  type: AppBottomSheetHeaderType.handleOnly,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        S.current.loanRequestOtpTitle,
                        style: AppTypography.titleSmall,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        S.current.loanRequestOtpMessage(
                          '\u2066${state.challenge!.maskedPhone}\u2069',
                        ),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LoanOtpDigits(
                        value: state.otp,
                        length: state.challenge!.codeLength,
                        label: S.current.loanRequestOtpTitle,
                        enabled:
                            state.submissionStatus != RequestStatus.loading,
                        onChanged: (value) {
                          context.read<LoanRequestCubit>().updateOtp(value);
                        },
                      ),
                      if (state.isOtpError)
                        Text(
                          S.current.loanRequestOtpInvalid,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Center(
                        child: state.remainingSeconds > 0
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                textDirection: TextDirection.ltr,
                                children: [
                                  const AvpImage(
                                    image:
                                        '${AppConstants.baseImage}loan_request_clock.svg',
                                    width: 18,
                                    height: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    loanCountdown(state.remainingSeconds),
                                    style: AppTypography.labelMedium,
                                  ),
                                ],
                              )
                            : AppButton(
                                label: S.current.loanRequestResend,
                                variant: AppButtonVariant.text,
                                isLoading:
                                    state.otpStatus == RequestStatus.loading,
                                onPressed: context
                                    .read<LoanRequestCubit>()
                                    .requestSigningOtp,
                              ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: S.current.backLabel,
                              variant: AppButtonVariant.secondaryGray,
                              isActive:
                                  state.submissionStatus !=
                                  RequestStatus.loading,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: S.current.loanRequestSubmit,
                              isActive: state.canSubmit,
                              isLoading:
                                  state.submissionStatus ==
                                  RequestStatus.loading,
                              onPressed: context
                                  .read<LoanRequestCubit>()
                                  .submitLoan,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
