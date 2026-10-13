import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/financial_certificate_data.dart';
import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialConditions extends StatelessWidget {
  const FinancialConditions({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
        buildWhen: (a, b) =>
            a.deposit != b.deposit || a.conditions != b.conditions,
        builder: (context, state) {
          final cubit = context.read<FinancialCertificateCubit>();
          final labels = [
            context.l10n.financialWithdrawalRules,
            context.l10n.financialHomeAddress,
            context.l10n.financialOpenedAt,
            context.l10n.financialPassportNumberCondition,
            context.l10n.financialAverageBalanceCondition,
            context.l10n.financialMaturityDate,
            context.l10n.financialDebitCredit,
            context.l10n.financialExchangeRate,
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CertificateSelect<String>(
                label: context.l10n.issuanceDeposit,
                hint: context.l10n.issuanceDepositHint,
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
                  context.l10n.certificateConditionsPrompt,
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
