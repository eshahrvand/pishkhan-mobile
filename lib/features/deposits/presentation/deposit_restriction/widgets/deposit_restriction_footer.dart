import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/certificate_fields.dart';
import '../cubit/deposit_restriction_cubit.dart';

class DepositRestrictionFooter extends StatelessWidget {
  const DepositRestrictionFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositRestrictionCubit, DepositRestrictionState>(
      buildWhen: (previous, current) =>
          previous.termsAccepted != current.termsAccepted ||
          previous.isEditable != current.isEditable ||
          previous.canSubmit != current.canSubmit ||
          previous.submissionStatus != current.submissionStatus ||
          previous.submissionFailure != current.submissionFailure,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
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
                                .read<DepositRestrictionCubit>()
                                .updateTermsAcceptance
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        children: [
                          InkWell(
                            onTap: context
                                .read<DepositRestrictionCubit>()
                                .requestTerms,
                            child: Text(
                              S.current.issuanceTerms,
                              style: certificateLabelStyle(context).copyWith(
                                color: context.colors.primaryHover,
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
              if (state.submissionFailure != null) ...[
                Text(
                  S.current.issuanceSubmitError,
                  style: certificateLabelStyle(context)
                      .copyWith(color: context.colors.error),
                ),
                const SizedBox(height: 8),
              ],
              AppButton(
                label: S.current.issuanceSubmit,
                size: AppButtonSize.lg,
                constrainLabel: true,
                disabledAppearance: AppButtonDisabledAppearance.service,
                isLoading: state.submissionStatus == RequestStatus.loading,
                onPressed: state.canSubmit
                    ? context.read<DepositRestrictionCubit>().submitRestriction
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
