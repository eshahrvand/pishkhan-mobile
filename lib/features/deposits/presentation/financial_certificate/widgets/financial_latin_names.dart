import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/certificate_fields.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialLatinNames extends StatelessWidget {
  const FinancialLatinNames({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
      buildWhen: (previous, current) =>
          previous.name != current.name ||
          previous.surname != current.surname ||
          previous.fatherName != current.fatherName,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      context
                          .read<FinancialCertificateCubit>()
                          .updateLatinSurname(value);
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
          ],
        );
      },
    );
  }
}
