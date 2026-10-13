import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialLatinIdentityForm extends StatelessWidget {
  const FinancialLatinIdentityForm({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
        buildWhen: (a, b) =>
            a.name != b.name ||
            a.surname != b.surname ||
            a.fatherName != b.fatherName ||
            a.passportNumber != b.passportNumber ||
            a.passportExpiryText != b.passportExpiryText ||
            a.latinAddress != b.latinAddress,
        builder: (context, state) {
          final cubit = context.read<FinancialCertificateCubit>();
          final labels = [
            context.l10n.financialLatinName,
            context.l10n.financialLatinSurname,
            context.l10n.financialLatinFather,
            context.l10n.financialLatinPassport,
            context.l10n.financialLatinExpiry,
          ];
          final hints = [
            context.l10n.financialNameHint,
            context.l10n.financialSurnameHint,
            context.l10n.financialFatherHint,
            context.l10n.financialPassportHint,
            context.l10n.financialExpiryHint,
          ];
          final values = [
            state.name,
            state.surname,
            state.fatherName,
            state.passportNumber,
            state.passportExpiryText,
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.financialPassportPrompt,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < labels.length; i++) ...[
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(labels[i], style: certificateLabelStyle(context)),
                      const SizedBox(height: 8),
                      AppTextField(
                        value: values[i],
                        hintText: hints[i],
                        textDirection: TextDirection.ltr,
                        hintTextDirection: TextDirection.rtl,
                        textAlign: TextAlign.left,
                        normalizeDigits: i >= 3,
                        autocorrect: false,
                        enableSuggestions: false,
                        enableIMEPersonalizedLearning: false,
                        textStyle: certificateValueStyle(context),
                        onChanged: (value) {
                          switch (i) {
                            case 0:
                              cubit.latinChanged(name: value);
                            case 1:
                              cubit.latinChanged(surname: value);
                            case 2:
                              cubit.latinChanged(fatherName: value);
                            case 3:
                              cubit.latinChanged(passportNumber: value);
                            case 4:
                              cubit.latinChanged(expiry: value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const DepositDivider(asset: AppAssets.certificateDivider),
              const SizedBox(height: 20),
              Text(
                context.l10n.financialLatinAddressPrompt,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.financialLatinAddress,
                      style: certificateValueStyle(context),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      value: state.latinAddress,
                      hintText: context.l10n.financialLatinAddressHint,
                      textDirection: TextDirection.ltr,
                      hintTextDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      minLines: 3,
                      maxLines: 3,
                      textStyle: Theme.of(context).textTheme.bodyLarge!
                          .copyWith(height: 24 / 16),
                      onChanged: (value) => cubit.latinChanged(address: value),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
}
