import 'average_balance_date_field.dart';
import 'average_balance_turnover_field.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
          previous.deposit != current.deposit ||
          previous.language != current.language ||
          previous.turnover != current.turnover ||
          previous.fromDate != current.fromDate ||
          previous.toDate != current.toDate,
      builder: (context, state) {
        final cubit = context.read<AverageBalanceCubit>();
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
              const SizedBox(height: 22),
              const DepositDivider(asset: AppAssets.certificateDivider),
              const SizedBox(height: 20),
              Text(
                S.current.certificateConditionsPrompt,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
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
                onChanged: cubit.selectLanguage,
              ),
              const SizedBox(height: 20),
              if (state.turnover == null) ...[
                AverageBalanceTurnoverField(
                  value: state.turnover,
                  onChanged: context.read<AverageBalanceCubit>().selectTurnover,
                ),
                const SizedBox(height: 20),
              ],
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
              if (state.turnover != null) ...[
                const SizedBox(height: 20),
                AverageBalanceTurnoverField(
                  value: state.turnover,
                  onChanged: context.read<AverageBalanceCubit>().selectTurnover,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    depositIcon(AppAssets.certificatePrintNotice, size: 20),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        S.current.certificatePrintingNotice,
                        style: certificateLabelStyle(context)
                            .copyWith(color: context.colors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}
