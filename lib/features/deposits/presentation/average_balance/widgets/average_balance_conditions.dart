import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/average_balance_cubit.dart';

class AverageBalanceConditions extends StatelessWidget {
  const AverageBalanceConditions({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
        buildWhen: (a, b) =>
            a.deposit != b.deposit ||
            a.language != b.language ||
            a.turnover != b.turnover ||
            a.fromDate != b.fromDate ||
            a.toDate != b.toDate,
        builder: (context, state) {
          final cubit = context.read<AverageBalanceCubit>();
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
                const SizedBox(height: 22),
                const DepositDivider(asset: AppAssets.certificateDivider),
                const SizedBox(height: 20),
                Text(
                  context.l10n.certificateConditionsPrompt,
                  style: certificateValueStyle(context)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                CertificateSelect<CertificateLanguage>(
                  label: context.l10n.certificateLanguage,
                  hint: context.l10n.certificateStatementLanguageHint,
                  value: state.language,
                  options: [
                    AppSelectOption(
                      value: CertificateLanguage.persian,
                      label: context.l10n.certificatePersian,
                    ),
                    AppSelectOption(
                      value: CertificateLanguage.english,
                      label: context.l10n.certificateEnglish,
                    ),
                  ],
                  onChanged: cubit.selectLanguage,
                ),
                const SizedBox(height: 20),
                if (state.turnover == null) ...[
                  _TurnoverField(state: state),
                  const SizedBox(height: 20),
                ],
                _DateField(
                  label: context.l10n.certificateFromDate,
                  hint: context.l10n.certificateFromDateHint,
                  value: state.fromDate,
                ),
                const SizedBox(height: 20),
                _DateField(
                  label: context.l10n.certificateToDate,
                  hint: context.l10n.certificateToDateHint,
                  value: state.toDate,
                ),
                if (state.turnover != null) ...[
                  const SizedBox(height: 20),
                  _TurnoverField(state: state),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      depositIcon(AppAssets.certificatePrintNotice, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          context.l10n.certificatePrintingNotice,
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

class _TurnoverField extends StatelessWidget {
  const _TurnoverField({required this.state});
  final AverageBalanceState state;
  @override
  Widget build(BuildContext context) => CertificateSelect<StatementTurnover>(
    label: context.l10n.certificateTurnover,
    hint: context.l10n.certificateTurnoverHint,
    value: state.turnover,
    options: [
      for (final value in StatementTurnover.values)
        AppSelectOption(
          value: value,
          label: switch (value) {
            StatementTurnover.depositsAndWithdrawals =>
              context.l10n.certificateBothTurnovers,
            StatementTurnover.deposits => context.l10n.certificateDepositsOnly,
            StatementTurnover.withdrawals =>
              context.l10n.certificateWithdrawalsOnly,
            StatementTurnover.averageBalance =>
              context.l10n.certificateAverageBalance,
          },
        ),
    ],
    onChanged: context.read<AverageBalanceCubit>().selectTurnover,
  );
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.hint, this.value});
  final String label, hint;
  final DateTime? value;
  @override
  Widget build(BuildContext context) => CertificateInput(
    label: label,
    hint: hint,
    value: value == null ? '' : JalaliDateFormatter.format(value!),
    readOnly: true,
    addonEnd: ColoredBox(
      color: AppPalette.brand500,
      child: SizedBox(
        width: 48,
        height: 44,
        child: Center(
          child: depositIcon(AppAssets.certificateCalendar, size: 20),
        ),
      ),
    ),
  );
}
