import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/financial_certificate_data.dart';
import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialConditions extends StatelessWidget {
  const FinancialConditions({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
      buildWhen: (a, b) =>
          a.deposit != b.deposit || a.conditions != b.conditions,
      builder: (context, state) {
        final cubit = context.read<FinancialCertificateCubit>();
        final labels = [
          S.current.financialWithdrawalRules,
          S.current.financialHomeAddress,
          S.current.financialOpenedAt,
          S.current.financialPassportNumberCondition,
          S.current.financialAverageBalanceCondition,
          S.current.financialMaturityDate,
          S.current.financialDebitCredit,
          S.current.financialExchangeRate,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CertificateSelect<String>(
              label: S.current.issuanceDeposit,
              hint: S.current.issuanceDepositHint,
              value: state.deposit?.id,
              options: [
                for (final d in state.catalog!.deposits)
                  AppSelectOption(value: d.id, label: d.number),
              ],
              onChanged: cubit.selectDeposit,
            ),
            if (state.deposit != null) ...[
              const SizedBox(height: 20),
              const DepositDivider(asset: AppAssets.certificateDivider),
              const SizedBox(height: 20),
              Text(
                S.current.certificateConditionsPrompt,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < labels.length; i++)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Row(
                    children: [
                      AppCheckbox(
                        value: state.conditions.contains(
                          FinancialCertificateCondition.values[i],
                        ),
                        size: AppCheckboxSize.md,
                        onChanged: (value) => cubit.toggleCondition(
                          FinancialCertificateCondition.values[i],
                          value,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => cubit.toggleCondition(
                            FinancialCertificateCondition.values[i],
                            !state.conditions.contains(
                              FinancialCertificateCondition.values[i],
                            ),
                          ),
                          child: Text(
                            labels[i],
                            style: certificateValueStyle(context).copyWith(
                              fontWeight: FontWeight.w500,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
