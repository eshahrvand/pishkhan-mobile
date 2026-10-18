import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/certificate_fields.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialPassportFields extends StatelessWidget {
  const FinancialPassportFields({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
      buildWhen: (previous, current) =>
          previous.passportNumber != current.passportNumber ||
          previous.passportExpiryText != current.passportExpiryText,
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
          ],
        );
      },
    );
  }
}
