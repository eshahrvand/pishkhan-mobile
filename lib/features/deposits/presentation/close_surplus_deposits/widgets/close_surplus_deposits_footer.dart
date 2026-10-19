import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/certificate_fields.dart';
import '../cubit/close_surplus_deposits_cubit.dart';

class CloseSurplusDepositsFooter extends StatelessWidget {
  const CloseSurplusDepositsFooter({super.key, required this.state});
  final CloseSurplusDepositsState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.step == CloseSurplusDepositsStep.primaryDeposit) ...[
            Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                              .read<CloseSurplusDepositsCubit>()
                              .updateTermsAcceptance
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      children: [
                        InkWell(
                          onTap: context
                              .read<CloseSurplusDepositsCubit>()
                              .requestTerms,
                          child: Text(
                            S.current.issuanceTerms,
                            style: certificateLabelStyle(context).copyWith(
                              color: context.colors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          ' ${S.current.issuanceTermsPrompt}',
                          style: certificateLabelStyle(context).copyWith(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (state.submissionFailure != null) ...[
            Text(
              S.current.issuanceSubmitError,
              style: certificateLabelStyle(context)
                  .copyWith(color: context.colors.error),
            ),
            const SizedBox(height: 8),
          ],
          AppButton(
            constrainLabel: true,
            label: S.current.surplusDepositsSubmit,
            size: AppButtonSize.lg,
            disabledAppearance: AppButtonDisabledAppearance.service,
            isLoading: state.submissionStatus == RequestStatus.loading,
            onPressed: state.canContinue
                ? context.read<CloseSurplusDepositsCubit>().continueFlow
                : null,
          ),
        ],
      ),
    );
  }
}
