import 'package:pishkhan_mobile/core/config/constant.dart';

import 'financial_latin_names.dart';
import 'financial_passport_fields.dart';
import 'financial_latin_address_field.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialLatinIdentityForm extends StatelessWidget {
  const FinancialLatinIdentityForm({super.key});
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
        const FinancialLatinNames(),
        const FinancialPassportFields(),
        const DepositDivider(
          asset: '${AppConstants.baseImage}certificate_certDivider.svg',
        ),
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
              BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
                buildWhen: (previous, current) =>
                    previous.latinAddress != current.latinAddress,
                builder: (context, state) {
                  return FinancialLatinAddressField(
                    value: state.latinAddress,
                    onChanged: (value) => context
                        .read<FinancialCertificateCubit>()
                        .updateLatinAddress(value),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
