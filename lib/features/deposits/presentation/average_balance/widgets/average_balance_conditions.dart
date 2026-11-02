import 'package:pishkhan_mobile/core/config/constant.dart';

import 'average_balance_date_field.dart';
import 'average_balance_turnover_field.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/listed_deposit.dart';

import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/average_balance_cubit.dart';

class AverageBalanceConditions extends StatelessWidget {
  const AverageBalanceConditions({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
      buildWhen: (previous, current) =>
          previous.catalog != current.catalog ||
          previous.deposit != current.deposit,
      builder: (context, state) {
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
              onChanged: context.read<AverageBalanceCubit>().selectDeposit,
            ),
            if (state.deposit != null) ...[
              const SizedBox(height: 22),
              const DepositDivider(
                asset: '${AppConstants.baseImage}certificate_certDivider.svg',
              ),
              const SizedBox(height: 20),
              Text(
                S.current.certificateConditionsPrompt,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
                buildWhen: (previous, current) =>
                    previous.language != current.language ||
                    previous.turnover != current.turnover,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CertificateSelect<CertificateLanguage>(
                        label: S.current.certificateLanguage,
                        hint: S.current.certificateStatementLanguageHint,
                        value: state.language,
                        options: [
                          AppSelectOption(
                            value: CertificateLanguage.persian,
                            label: S.current.certificatePersian,
                          ),
                          AppSelectOption(
                            value: CertificateLanguage.english,
                            label: S.current.certificateEnglish,
                          ),
                        ],
                        onChanged: context
                            .read<AverageBalanceCubit>()
                            .selectLanguage,
                      ),
                      const SizedBox(height: 20),
                      if (state.turnover == null) ...[
                        AverageBalanceTurnoverField(
                          value: state.turnover,
                          onChanged: context
                              .read<AverageBalanceCubit>()
                              .selectTurnover,
                        ),
                        const SizedBox(height: 20),
                      ],
                      BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
                        buildWhen: (previous, current) =>
                            previous.fromDate != current.fromDate ||
                            previous.toDate != current.toDate,
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AverageBalanceDateField(
                                label: S.current.certificateFromDate,
                                hint: S.current.certificateFromDateHint,
                                value: state.fromDate,
                              ),
                              const SizedBox(height: 20),
                              AverageBalanceDateField(
                                label: S.current.certificateToDate,
                                hint: S.current.certificateToDateHint,
                                value: state.toDate,
                              ),
                            ],
                          );
                        },
                      ),
                      if (state.turnover != null) ...[
                        const SizedBox(height: 20),
                        AverageBalanceTurnoverField(
                          value: state.turnover,
                          onChanged: context
                              .read<AverageBalanceCubit>()
                              .selectTurnover,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            depositIcon(
                              '${AppConstants.baseImage}certificate_certPrintNotice.svg',
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                S.current.certificatePrintingNotice,
                                style: certificateLabelStyle(
                                  context,
                                ).copyWith(color: context.colors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
