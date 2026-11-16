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
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppPalette.blueGray50,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                const AvpImage(
                  image: '${AppConstants.baseImage}loan_request_edit.svg',
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    S.current.loanRequestCurrentHeader,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppPalette.blueGray700,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                if (state.draftRemainingSeconds != null) ...[
                  Text(
                    loanCountdown(state.draftRemainingSeconds!),
                    style: AppTypography.labelMedium.copyWith(letterSpacing: 0),
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
          const SizedBox(height: 8),
          LoanValueRow(
            height: 22,
            valueFontSize: 12,
            label: S.current.depositListNumber,
            value: state.catalog!.currentDraft!.quote.input.deposit.number,
            valueDirection: TextDirection.ltr,
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 8),
          LoanValueRow(
            height: 22,
            valueFontSize: 12,
            label: S.current.loanRequestAmount,
            valueContent: LoanMoney(
              amountRial: state.catalog!.currentDraft!.quote.input.amountRial,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 8),
          LoanValueRow(
            height: 22,
            valueFontSize: 12,
            label: S.current.loanRequestCurrentStage,
            valueContent: AppBadge(
              label: loanDraftStageLabel(state.catalog!.currentDraft!.step),
              color: AppBadgeColor.blueGray,
              corner: AppBadgeCorner.rounded,
            ),
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 12),
          Divider(height: 0, thickness: .5, color: context.colors.borderSubtle),
          const SizedBox(height: 12),
          SizedBox(
            height: 20,
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: S.current.loanRequestCancel,
                    variant: AppButtonVariant.text,
                    isDestructive: true,
                    horizontalPadding: 0,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      letterSpacing: 0,
                    ),
                    isLoading:
                        state.cancellationStatus == RequestStatus.loading,
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
                    horizontalPadding: 0,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      letterSpacing: 0,
                    ),
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
          ),
        ],
      ),
    );
  }
}
