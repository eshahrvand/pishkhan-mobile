import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/card_issuance_cubit.dart';

class IssuanceFooter extends StatelessWidget {
  const IssuanceFooter({super.key, required this.onTermsRequested});
  final VoidCallback onTermsRequested;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardIssuanceCubit, CardIssuanceState>(
      buildWhen: (previous, current) =>
          previous.step != current.step ||
          previous.draft != current.draft ||
          previous.editable != current.editable ||
          previous.submissionStatus != current.submissionStatus ||
          previous.canContinue != current.canContinue,
      builder: (context, state) {
        return Container(
          color: context.colors.surfaceSubtle,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.step == IssuanceStep.confirmation) ...[
                Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppCardIssuanceColors.termsSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        label: S.current.issuanceTerms,
                        child: AppCheckbox(
                          value: state.draft.termsAccepted,
                          size: AppCheckboxSize.md,
                          onChanged: state.editable
                              ? context.read<CardIssuanceCubit>().acceptTerms
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Wrap(
                          spacing: 2,
                          children: [
                            InkWell(
                              onTap: onTermsRequested,
                              child: Text(
                                S.current.issuanceTerms,
                                style: AppTypography.bodySmall.copyWith(
                                  height: 18 / 12,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.primaryHover,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              S.current.issuanceTermsPrompt,
                              style: AppTypography.bodySmall.copyWith(
                                height: 18 / 12,
                                letterSpacing: 0,
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
              ],
              AppButton(
                size: AppButtonSize.lg,
                label: (state.step == IssuanceStep.confirmation)
                    ? S.current.issuanceSubmit
                    : S.current.issuanceNext,
                labelStyle: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0,
                ),
                constrainLabel: true,
                isLoading: state.submissionStatus == RequestStatus.loading,
                onPressed: state.canContinue
                    ? () {
                        if (state.step == IssuanceStep.confirmation) {
                          context.read<CardIssuanceCubit>().submit();
                        } else {
                          context.read<CardIssuanceCubit>().next();
                        }
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
