import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/cheque_clearance_cubit.dart';
import 'cheque_clearance_ui.dart';

class ChequeClearanceFooter extends StatelessWidget {
  const ChequeClearanceFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChequeClearanceCubit, ChequeClearanceState>(
      buildWhen: (previous, current) =>
          previous.termsAccepted != current.termsAccepted ||
          previous.canSubmit != current.canSubmit ||
          previous.isEditable != current.isEditable ||
          previous.submissionStatus != current.submissionStatus ||
          previous.failure != current.failure,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                .read<ChequeClearanceCubit>()
                                .updateTermsAcceptance
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        children: [
                          InkWell(
                            onTap: context
                                .read<ChequeClearanceCubit>()
                                .requestTerms,
                            child: Text(
                              S.current.chequeTerms,
                              style: chequeLabelStyle(context).copyWith(
                                color: context.colors.primaryHover,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            ' ${S.current.chequeTermsPrompt}',
                            style: chequeLabelStyle(context).copyWith(
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
              const SizedBox(height: 16),

              AppButton(
                label: S.current.chequeSubmit,
                size: AppButtonSize.lg,
                constrainLabel: true,
                disabledAppearance: AppButtonDisabledAppearance.service,
                isLoading: state.submissionStatus == RequestStatus.loading,
                onPressed: state.canSubmit
                    ? context.read<ChequeClearanceCubit>().submitClearance
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
