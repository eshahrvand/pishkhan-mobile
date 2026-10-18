import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/financial_certificate_data.dart';
import '../../../domain/entities/certificate_data.dart';
import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialRecipient extends StatelessWidget {
  const FinancialRecipient({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
          buildWhen: (previous, current) =>
              previous.recipient != current.recipient ||
              previous.embassy != current.embassy ||
              previous.authorityName != current.authorityName,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.current.financialRecipientPrompt,
                  style: certificateValueStyle(context)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                CertificateSelect<FinancialCertificateRecipient>(
                  label: S.current.financialRecipient,
                  hint: S.current.financialRecipientHint,
                  value: state.recipient,
                  options: [
                    AppSelectOption(
                      value: FinancialCertificateRecipient.embassy,
                      label: S.current.financialEmbassy,
                    ),
                    AppSelectOption(
                      value: FinancialCertificateRecipient.otherAuthority,
                      label: S.current.financialOtherAuthority,
                    ),
                  ],
                  onChanged: context
                      .read<FinancialCertificateCubit>()
                      .selectRecipient,
                ),
                if (state.recipient != null) ...[
                  const SizedBox(height: 20),
                  if (state.recipient == FinancialCertificateRecipient.embassy)
                    CertificateSelect<CertificateEmbassy>(
                      label: S.current.financialEmbassy,
                      hint: S.current.financialEmbassyHint,
                      value: state.embassy,
                      options: [
                        for (final embassy in state.catalog!.embassies)
                          AppSelectOption(value: embassy, label: embassy.label),
                      ],
                      onChanged: context
                          .read<FinancialCertificateCubit>()
                          .selectEmbassy,
                    )
                  else
                    CertificateInput(
                      label: S.current.financialAuthority,
                      hint: S.current.financialAuthorityHint,
                      value: state.authorityName,
                      onChanged: context
                          .read<FinancialCertificateCubit>()
                          .updateAuthorityName,
                    ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        const DepositDivider(asset: AppAssets.certificateDivider),
        const SizedBox(height: 20),
        BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
          buildWhen: (previous, current) =>
              previous.currency != current.currency ||
              previous.catalog != current.catalog,
          builder: (context, state) {
            return CertificateSelect<CertificateCurrency>(
              label: S.current.financialCurrency,
              hint: S.current.financialCurrencyHint,
              value: state.currency,
              options: [
                for (final currency in state.catalog!.currencies)
                  AppSelectOption(
                    value: currency,
                    label: switch (currency) {
                      CertificateCurrency.usd => S.current.financialUsd,
                      CertificateCurrency.eur => S.current.financialEur,
                      CertificateCurrency.irr => S.current.financialIrr,
                    },
                  ),
              ],
              onChanged: context
                  .read<FinancialCertificateCubit>()
                  .selectCurrency,
            );
          },
        ),
      ],
    );
  }
}
