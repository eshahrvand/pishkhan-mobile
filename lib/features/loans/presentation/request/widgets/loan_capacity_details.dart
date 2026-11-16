import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_credit_assessment.dart';
import 'loan_money.dart';
import 'loan_text_link.dart';
import 'loan_value_row.dart';

class LoanCapacityDetails extends StatelessWidget {
  const LoanCapacityDetails({
    super.key,
    required this.assessment,
    required this.onMeratPressed,
  });
  final LoanCreditAssessment assessment;
  final VoidCallback onMeratPressed;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoanValueRow(
          height: 18,
          valueFontSize: 12,
          label: S.current.loanRequestNeededCapacity,
          valueContent: LoanMoney(
            amountRial: assessment.requiredCapacityRial,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          padding: EdgeInsets.zero,
          bordered: false,
        ),
        Divider(height: 24, thickness: .5, color: context.colors.borderSubtle),
        LoanValueRow(
          height: 18,
          valueFontSize: 12,
          label: S.current.loanRequestYourCapacity,
          valueContent: LoanMoney(
            amountRial: assessment.availableCapacityRial,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          padding: EdgeInsets.zero,
          bordered: false,
        ),
        Divider(height: 24, thickness: .5, color: context.colors.borderSubtle),
        LoanValueRow(
          height: 18,
          valueFontSize: 12,
          label: S.current.loanRequestCapacityDeficit,
          valueContent: LoanMoney(
            amountRial: assessment.capacityDeficitRial,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          padding: EdgeInsets.zero,
          bordered: false,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppPalette.gray50,
            borderRadius: AppRadius.borderSm,
          ),
          child: Text(
            S.current.loanRequestSolution,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          S.current.loanRequestIncomeSolution,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: AppPalette.gray800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.current.loanRequestIncomeExplanation,
          style: AppTypography.bodySmall.copyWith(letterSpacing: 0),
        ),
        const SizedBox(height: 12),
        LoanTextLink(
          label: S.current.loanRequestMeratLink,
          onPressed: onMeratPressed,
        ),
        const SizedBox(height: 20),
        Text(
          S.current.loanRequestSettle,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: AppPalette.gray800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.current.loanRequestSettleExplanation,
          style: AppTypography.bodySmall.copyWith(letterSpacing: 0),
        ),
      ],
    );
  }
}
