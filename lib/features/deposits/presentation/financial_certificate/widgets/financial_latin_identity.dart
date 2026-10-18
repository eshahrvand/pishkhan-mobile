import 'financial_latin_address_field.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialLatinIdentityForm extends StatelessWidget {
  const FinancialLatinIdentityForm({super.key, required this.state});
  final FinancialCertificateState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.financialPassportPrompt,
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
                S.current.financialLatinName,
                style: certificateLabelStyle(context),
              ),
              const SizedBox(height: 8),
              AppTextField(
                value: state.name,
                hintText: S.current.financialNameHint,
                textDirection: TextDirection.ltr,
                hintTextDirection: TextDirection.rtl,
                textAlign: TextAlign.left,
                normalizeDigits: false,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                textStyle: certificateValueStyle(context).copyWith(
                  fontFamily: state.name.isEmpty
                      ? AppTypography.defaultFontFamily
                      : 'CertificateLatin',
                ),
                onChanged: (value) {
                  context.read<FinancialCertificateCubit>().updateLatinName(
                    value,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.current.financialLatinSurname,
                style: certificateLabelStyle(context),
              ),
              const SizedBox(height: 8),
              AppTextField(
                value: state.surname,
                hintText: S.current.financialSurnameHint,
                textDirection: TextDirection.ltr,
                hintTextDirection: TextDirection.rtl,
                textAlign: TextAlign.left,
                normalizeDigits: false,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                textStyle: certificateValueStyle(context).copyWith(
                  fontFamily: state.surname.isEmpty
                      ? AppTypography.defaultFontFamily
                      : 'CertificateLatin',
                ),
                onChanged: (value) {
                  context.read<FinancialCertificateCubit>().updateLatinSurname(
                    value,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.current.financialLatinFather,
                style: certificateLabelStyle(context),
              ),
              const SizedBox(height: 8),
              AppTextField(
                value: state.fatherName,
                hintText: S.current.financialFatherHint,
                textDirection: TextDirection.ltr,
                hintTextDirection: TextDirection.rtl,
                textAlign: TextAlign.left,
                normalizeDigits: false,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                textStyle: certificateValueStyle(context).copyWith(
                  fontFamily: state.fatherName.isEmpty
                      ? AppTypography.defaultFontFamily
                      : 'CertificateLatin',
                ),
                onChanged: (value) {
                  context
                      .read<FinancialCertificateCubit>()
                      .updateLatinFatherName(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.current.financialLatinPassport,
                style: certificateLabelStyle(context),
              ),
              const SizedBox(height: 8),
              AppTextField(
                value: state.passportNumber,
                hintText: S.current.financialPassportHint,
                textDirection: TextDirection.ltr,
                hintTextDirection: TextDirection.rtl,
                textAlign: TextAlign.left,
                normalizeDigits: true,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                textStyle:
                    (state.passportNumber.isNotEmpty
                            ? Theme.of(context).textTheme.bodyLarge!
                            : Theme.of(context).textTheme.bodyMedium!)
                        .copyWith(
                          fontFamily: state.passportNumber.isEmpty
                              ? AppTypography.defaultFontFamily
                              : 'CertificateLatin',
                        ),
                onChanged: (value) {
                  context
                      .read<FinancialCertificateCubit>()
                      .updatePassportNumber(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.current.financialLatinExpiry,
                style: certificateLabelStyle(context),
              ),
              const SizedBox(height: 8),
              AppTextField(
                value: state.passportExpiryText,
                hintText: S.current.financialExpiryHint,
                textDirection: TextDirection.ltr,
                hintTextDirection: TextDirection.rtl,
                textAlign: TextAlign.left,
                normalizeDigits: true,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                textStyle: certificateValueStyle(context).copyWith(
                  fontFamily: state.passportExpiryText.isEmpty
                      ? AppTypography.defaultFontFamily
                      : 'CertificateLatin',
                  fontSize: state.passportExpiryText.isNotEmpty ? 16 : 14,
                ),
                onChanged: (value) {
                  context
                      .read<FinancialCertificateCubit>()
                      .updatePassportExpiry(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const DepositDivider(asset: AppAssets.certificateDivider),
        const SizedBox(height: 20),
        Text(
          S.current.financialLatinAddressPrompt,
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
                S.current.financialLatinAddress,
                style: certificateValueStyle(context),
              ),
              const SizedBox(height: 8),
              FinancialLatinAddressField(
                value: state.latinAddress,
                onChanged: (value) => context
                    .read<FinancialCertificateCubit>()
                    .updateLatinAddress(value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
