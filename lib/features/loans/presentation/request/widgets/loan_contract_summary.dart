import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/loan_request_cubit.dart';

import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_summary_row.dart';

import 'loan_money.dart';
import 'loan_summary_money_row.dart';
import 'loan_text_link.dart';

class LoanContractSummary extends StatelessWidget {
  const LoanContractSummary({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.primarySubtle,
            borderRadius: AppRadius.borderSm,
            boxShadow: AppShadows.cardList,
          ),
          child: Column(
            children: [
              InkWell(
                onTap: context.read<LoanRequestCubit>().toggleSummary,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.current.issuanceSummary,
                        style: AppTypography.titleSmall,
                      ),
                    ),
                    RotatedBox(
                      quarterTurns: state.isSummaryExpanded ? 0 : 2,
                      child: const AvpImage(
                        image:
                            '${AppConstants.baseImage}issuance_summary_chevron.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isSummaryExpanded) ...[
                const SizedBox(height: 16),
                CertificateSummaryRow(
                  label: S.current.depositListNumber,
                  value: '\u2066${state.quote!.input.deposit.number}\u2069',
                  asset:
                      '${AppConstants.baseImage}issuance_summary_divider.svg',
                ),
                const SizedBox(height: 12),
                LoanSummaryMoneyRow(
                  label: S.current.loanRequestAmount,
                  amountRial: state.quote!.input.amountRial,
                ),
                const SizedBox(height: 12),
                LoanSummaryMoneyRow(
                  label: S.current.loanRequestInsuranceAmount,
                  amountRial: state.isInsuranceSelected
                      ? state.quote!.insuranceRial
                      : 0,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.borderSubtle),
            borderRadius: AppRadius.borderSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const AvpImage(
                    image:
                        '${AppConstants.baseImage}loan_request_insurance_info.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  if (state.quote!.insuranceOptional) ...[
                    AppCheckbox(
                      value: state.isInsuranceSelected,
                      onChanged: (value) {
                        context
                            .read<LoanRequestCubit>()
                            .updateInsuranceSelection(value);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      state.quote!.insuranceOptional
                          ? S.current.loanRequestInsuranceOptional
                          : S.current.loanRequestInsurance,
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  LoanTextLink(
                    label: state.quote!.insuranceOptional
                        ? S.current.loanRequestDetails
                        : S.current.loanRequestViewContract,
                    showArrow: false,
                    onPressed: context
                        .read<LoanRequestCubit>()
                        .requestInsurance,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                state.quote!.insuranceOptional
                    ? S.current.loanRequestInsuranceOptionalHint
                    : S.current.loanRequestInsuranceHint,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      S.current.loanRequestInsuranceAmount,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                  LoanMoney(amountRial: state.quote!.insuranceRial),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
