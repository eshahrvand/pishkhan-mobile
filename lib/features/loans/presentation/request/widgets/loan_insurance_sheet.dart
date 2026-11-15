import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_summary_row.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';

import '../cubit/loan_request_cubit.dart';
import 'loan_summary_money_row.dart';

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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.current.loanRequestInsuranceDetails,
                style: AppTypography.titleSmall.copyWith(letterSpacing: 0),
              ),
              const SizedBox(height: 20),
              CertificateSummaryRow(
                label: S.current.depositListNumber,
                value: '\u2066${state.quote!.input.deposit.number}\u2069',
                asset: '${AppConstants.baseImage}issuance_summary_divider.svg',
              ),
              const SizedBox(height: 12),
              LoanSummaryMoneyRow(
                label: S.current.loanRequestInsuranceAmount,
                amountRial: state.quote!.insuranceRial,
              ),
              const SizedBox(height: 20),
              Text(
                state.catalog!.insuranceText ??
                    S.current.loanRequestMissingInsurance,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppPalette.gray600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 32),
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
