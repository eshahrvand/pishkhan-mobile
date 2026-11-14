import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../cubit/loan_request_cubit.dart';
import 'loan_value_row.dart';
import 'loan_money.dart';

class LoanInsuranceSheet extends StatelessWidget {
  const LoanInsuranceSheet({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.current.loanRequestInsuranceDetails,
                style: AppTypography.titleSmall,
              ),
              const SizedBox(height: 16),
              LoanValueRow(
                label: S.current.depositListNumber,
                value: state.quote!.input.deposit.number,
                valueDirection: TextDirection.ltr,
                backgroundColor: context.colors.surfaceSubtle,
                bordered: false,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              LoanValueRow(
                label: S.current.loanRequestInsuranceAmount,
                valueContent: LoanMoney(
                  amountRial: state.quote!.insuranceRial,
                  fontSize: 12,
                ),
                backgroundColor: context.colors.surfaceSubtle,
                bordered: false,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              const SizedBox(height: 16),
              Text(
                state.catalog!.insuranceText ??
                    S.current.loanRequestMissingInsurance,
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: S.current.backLabel,
                variant: AppButtonVariant.secondaryGray,
                size: AppButtonSize.lg,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
