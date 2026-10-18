import '../../../domain/entities/listed_deposit.dart';
import 'financial_condition_option.dart';

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
  const FinancialConditions({super.key, required this.state});
  final FinancialCertificateState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CertificateSelect<ListedDeposit>(
          label: S.current.issuanceDeposit,
          hint: S.current.issuanceDepositHint,
          value: state.deposit,
          options: [
            for (final d in state.catalog!.deposits)
              AppSelectOption(value: d, label: d.number),
          ],
          onChanged: context.read<FinancialCertificateCubit>().selectDeposit,
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
          FinancialConditionOption(
            condition: FinancialCertificateCondition.withdrawalRules,
            label: S.current.financialWithdrawalRules,
            state: state,
          ),
          FinancialConditionOption(
            condition: FinancialCertificateCondition.homeAddress,
            label: S.current.financialHomeAddress,
            state: state,
          ),
          FinancialConditionOption(
            condition: FinancialCertificateCondition.openedAt,
            label: S.current.financialOpenedAt,
            state: state,
          ),
          FinancialConditionOption(
            condition: FinancialCertificateCondition.passportNumber,
            label: S.current.financialPassportNumberCondition,
            state: state,
          ),
          FinancialConditionOption(
            condition: FinancialCertificateCondition.averageBalance,
            label: S.current.financialAverageBalanceCondition,
            state: state,
          ),
          FinancialConditionOption(
            condition: FinancialCertificateCondition.maturityDate,
            label: S.current.financialMaturityDate,
            state: state,
          ),
          FinancialConditionOption(
            condition: FinancialCertificateCondition.debitCredit,
            label: S.current.financialDebitCredit,
            state: state,
          ),
          FinancialConditionOption(
            condition: FinancialCertificateCondition.exchangeRate,
            label: S.current.financialExchangeRate,
            state: state,
          ),
        ],
      ],
    );
  }
}
