import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/cheque_cancellation_cubit.dart';

class ChequeCancellationFooter extends StatelessWidget {
  const ChequeCancellationFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChequeCancellationCubit, ChequeCancellationState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.step == ChequeCancellationStep.confirmation) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  constraints: const BoxConstraints(minHeight: 44),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Row(
                    children: [
                      AppCheckbox(
                        value: state.termsAccepted,
                        size: AppCheckboxSize.md,
                        onChanged: state.isEditable
                            ? context
                                  .read<ChequeCancellationCubit>()
                                  .updateTermsAcceptance
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          children: [
                            InkWell(
                              onTap: context
                                  .read<ChequeCancellationCubit>()
                                  .requestTerms,
                              child: Text(
                                S.current.chequeTerms,
                                style: certificateLabelStyle(context).copyWith(
                                  color: context.colors.primaryHover,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              ' ${S.current.chequeTermsPrompt}',
                              style: certificateLabelStyle(context).copyWith(
                                fontWeight: FontWeight.w400,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (state.submissionFailure != null) ...[
                Text(
                  S.current.chequeSubmitFailure,
                  style: certificateLabelStyle(context)
                      .copyWith(color: context.colors.error),
                ),
                const SizedBox(height: 8),
              ],
              AppButton(
                label: state.step == ChequeCancellationStep.confirmation
                    ? S.current.chequeSubmit
                    : S.current.issuanceNext,
                size: AppButtonSize.lg,
                disabledAppearance: AppButtonDisabledAppearance.service,
                isLoading:
                    state.chequesStatus == RequestStatus.loading ||
                    state.submissionStatus == RequestStatus.loading,
                onPressed: state.canContinue
                    ? context.read<ChequeCancellationCubit>().continueFlow
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
