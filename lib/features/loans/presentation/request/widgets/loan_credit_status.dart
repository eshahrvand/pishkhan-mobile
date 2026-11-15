import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';
import '../../../domain/entities/loan_credit_assessment.dart';
import '../cubit/loan_request_cubit.dart';
import 'loan_credit_scale.dart';
import 'loan_request_labels.dart';
import 'loan_value_row.dart';
import 'loan_status_card.dart';
import 'loan_capacity_details.dart';

class LoanCreditStatus extends StatelessWidget {
  const LoanCreditStatus({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: context.read<LoanRequestCubit>().requestCreditInfo,
          child: Padding(
            padding: const EdgeInsets.only(left: 1),
            child: LoanValueRow(
              height: 42,
              valueWidth: 140,
              labelStyle: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                color: context.colors.textSecondary,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              backgroundColor: AppPalette.gray25,
              valueFontSize: 12,
              valueFontWeight: FontWeight.w600,
              label: S.current.loanRequestTier,
              value: loanAssessmentRangeLabel(
                state.deposit!.creditTier,
                state.assessment!.range,
              ),
              color:
                  state.assessment!.range == LoanCreditRange.unsuitable ||
                      state.assessment!.range == LoanCreditRange.unknown
                  ? AppPalette.error500
                  : context.colors.primary,
              onInfoPressed: context.read<LoanRequestCubit>().requestCreditInfo,
              icon: '${AppConstants.baseImage}loan_request_gauge.svg',
            ),
          ),
        ),
        if (state.assessment!.range != LoanCreditRange.unknown) ...[
          const SizedBox(height: 16),
          LoanCreditScale(
            assessment: state.assessment!,
            tier: state.deposit!.creditTier,
          ),
        ],
        const SizedBox(height: 20),
        const SizedBox(
          height: 0,
          child: OverflowBox(
            minHeight: 1,
            maxHeight: 1,
            child: AvpImage(
              image: '${AppConstants.baseImage}loan_request_divider.svg',
              height: 1,
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(S.current.loanRequestStatusCheck, style: AppTypography.titleSmall),
        const SizedBox(height: 20),
        LoanStatusCard(
          label: S.current.loanRequestAvailability,
          approved: true,
        ),
        const SizedBox(height: 8),
        LoanStatusCard(
          label: S.current.loanRequestCreditEnough,
          approved: true,
        ),
        const SizedBox(height: 8),
        LoanStatusCard(
          label:
              '${S.current.loanRequestTier}: ${loanAssessmentRangeLabel(state.deposit!.creditTier, state.assessment!.range)}',
          approved: state.assessment!.canProceed,
          onPressed: context.read<LoanRequestCubit>().toggleCredit,
          expanded: state.isCreditExpanded,
        ),
        if (state.isCreditExpanded) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(color: context.colors.borderSubtle),
              borderRadius: AppRadius.borderSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.assessment!.range != LoanCreditRange.unsuitable)
                  Text(
                    loanCreditExplanation(state.assessment!),
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 12,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                if (state.assessment!.range == LoanCreditRange.unknown) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    label: S.current.loanRequestMerat,
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.secondaryColor,
                    foregroundColor: AppPalette.brand700,
                    trailingIcon: const AvpImage(
                      image:
                          '${AppConstants.baseImage}loan_request_link_arrow.svg',
                      width: 20,
                      height: 20,
                    ),
                    onPressed: context
                        .read<LoanRequestCubit>()
                        .requestUnavailable,
                  ),
                ],
                if (state.assessment!.range == LoanCreditRange.unsuitable)
                  LoanCapacityDetails(
                    assessment: state.assessment!,
                    onMeratPressed: context
                        .read<LoanRequestCubit>()
                        .requestUnavailable,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

String loanCreditExplanation(LoanCreditAssessment assessment) =>
    switch (assessment.range) {
      LoanCreditRange.excellent => S.current.loanRequestNoCollateral,
      LoanCreditRange.fullySuitable => S.current.loanRequestOwnAssessmentHint(
        loanMoney(assessment.collateralRial),
      ),
      LoanCreditRange.suitable => S.current.loanRequestBothAssessmentHint(
        loanMoney(assessment.collateralRial),
      ),
      LoanCreditRange.unknown => S.current.loanRequestUnknownHint,
      LoanCreditRange.unsuitable => S.current.loanRequestUnsuitableHint,
    };
