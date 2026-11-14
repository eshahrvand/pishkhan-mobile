import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/loan_request_cubit.dart';
import 'loan_request_labels.dart';
import 'loan_value_row.dart';
import 'loan_money.dart';

class LoanCurrentRequestCard extends StatelessWidget {
  const LoanCurrentRequestCard({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardList,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primarySubtle,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                const AvpImage(
                  image: '${AppConstants.baseImage}loan_request_edit.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    S.current.loanRequestCurrentHeader,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                if (state.draftRemainingSeconds != null) ...[
                  Text(
                    loanCountdown(state.draftRemainingSeconds!),
                    style: AppTypography.labelSmall,
                  ),
                  const SizedBox(width: 4),
                  const AvpImage(
                    image:
                        '${AppConstants.baseImage}loan_request_hourglass.svg',
                    width: 9.33333,
                    height: 13.3345,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          LoanValueRow(
            valueFontSize: 12,
            label: S.current.depositListNumber,
            value: state.catalog!.currentDraft!.quote.input.deposit.number,
            valueDirection: TextDirection.ltr,
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          LoanValueRow(
            valueFontSize: 12,
            label: S.current.loanRequestAmount,
            valueContent: LoanMoney(
              amountRial: state.catalog!.currentDraft!.quote.input.amountRial,
              fontSize: 12,
            ),
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          LoanValueRow(
            valueFontSize: 12,
            label: S.current.loanRequestCurrentStage,
            valueContent: AppBadge(
              label: loanDraftStageLabel(state.catalog!.currentDraft!.step),
              color: AppBadgeColor.indigo,
              corner: AppBadgeCorner.rounded,
            ),
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: context.colors.borderSubtle),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: S.current.loanRequestCancel,
                  variant: AppButtonVariant.text,
                  isDestructive: true,
                  labelStyle: AppTypography.bodySmall,
                  isLoading: state.cancellationStatus == RequestStatus.loading,
                  onPressed: context.read<LoanRequestCubit>().requestCancel,
                ),
              ),
              SizedBox(
                height: 18,
                child: VerticalDivider(
                  width: 1,
                  color: context.colors.borderSubtle,
                ),
              ),
              Expanded(
                child: AppButton(
                  label: S.current.loanRequestContinue,
                  variant: AppButtonVariant.text,
                  labelStyle: AppTypography.bodySmall,
                  isActive: state.cancellationStatus != RequestStatus.loading,
                  onPressed: () {
                    context.read<LoanRequestCubit>().resumeRequest(
                      state.catalog!.currentDraft!,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
