import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/financial_certificate_data.dart';
import '../../../domain/entities/certificate_data.dart';
import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialRecipient extends StatelessWidget {
  const FinancialRecipient({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
        buildWhen: (a, b) =>
            a.recipient != b.recipient ||
            a.embassyId != b.embassyId ||
            a.authorityName != b.authorityName ||
            a.currency != b.currency,
        builder: (context, state) {
          final cubit = context.read<FinancialCertificateCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.financialRecipientPrompt,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              CertificateSelect<FinancialCertificateRecipient>(
                label: context.l10n.financialRecipient,
                hint: context.l10n.financialRecipientHint,
                value: state.recipient,
                options: [
                  AppSelectOption(
                    value: FinancialCertificateRecipient.embassy,
                    label: context.l10n.financialEmbassy,
                  ),
                  AppSelectOption(
                    value: FinancialCertificateRecipient.otherAuthority,
                    label: context.l10n.financialOtherAuthority,
                  ),
                ],
                onChanged: cubit.selectRecipient,
              ),
              if (state.recipient != null) ...[
                const SizedBox(height: 20),
                if (state.recipient == FinancialCertificateRecipient.embassy)
                  CertificateSelect<String>(
                    label: context.l10n.financialEmbassy,
                    hint: context.l10n.financialEmbassyHint,
                    value: state.embassyId,
                    options: [
                      for (final embassy in state.catalog!.embassies)
                        AppSelectOption(
                          value: embassy.id,
                          label: embassy.label,
                        ),
                    ],
                    onChanged: cubit.selectEmbassy,
                  )
                else
                  CertificateInput(
                    label: context.l10n.financialAuthority,
                    hint: context.l10n.financialAuthorityHint,
                    value: state.authorityName,
                    onChanged: cubit.authorityChanged,
                  ),
              ],
              const SizedBox(height: 20),
              const DepositDivider(asset: AppAssets.certificateDivider),
              const SizedBox(height: 20),
              CertificateSelect<CertificateCurrency>(
                label: context.l10n.financialCurrency,
                hint: context.l10n.financialCurrencyHint,
                value: state.currency,
                options: [
                  for (final currency in state.catalog!.currencies)
                    AppSelectOption(
                      value: currency,
                      label: switch (currency) {
                        CertificateCurrency.usd => context.l10n.financialUsd,
                        CertificateCurrency.eur => context.l10n.financialEur,
                        CertificateCurrency.irr => context.l10n.financialIrr,
                      },
                    ),
                ],
                onChanged: cubit.selectCurrency,
              ),
            ],
          );
        },
      );
}
