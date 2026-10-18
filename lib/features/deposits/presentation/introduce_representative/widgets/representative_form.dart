import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/representative_request.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_fields.dart';
import '../cubit/representative_cubit.dart';

/// Authored once for both the initial screen and the additional-person sheet.
class RepresentativeForm extends StatelessWidget {
  const RepresentativeForm({super.key, this.fieldSpacing = 20});
  final double fieldSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<RepresentativeCubit, RepresentativeState>(
          buildWhen: (previous, current) =>
              previous.deposit != current.deposit ||
              previous.operation != current.operation ||
              previous.deposits != current.deposits,
          builder: (context, state) {
            return Column(
              children: [
                CertificateSelect<ListedDeposit>(
                  label: S.current.representativeDeposit,
                  hint: S.current.representativeDepositHint,
                  value: state.deposit,
                  options: [
                    for (final deposit in state.deposits)
                      AppSelectOption(
                        value: deposit,
                        label: CurrencyFormatter.toPersianDigits(
                          deposit.number,
                        ),
                      ),
                  ],
                  onChanged: context.read<RepresentativeCubit>().selectDeposit,
                ),
                SizedBox(height: fieldSpacing),
                CertificateSelect<RepresentativeOperation>(
                  label: S.current.representativeOperation,
                  hint: S.current.representativeOperationHint,
                  value: state.operation,
                  options: [
                    AppSelectOption(
                      value: RepresentativeOperation.chequeBook,
                      label: S.current.representativeChequeBook,
                    ),
                  ],
                  onChanged: context
                      .read<RepresentativeCubit>()
                      .selectOperation,
                ),
              ],
            );
          },
        ),
        SizedBox(height: fieldSpacing),
        BlocBuilder<RepresentativeCubit, RepresentativeState>(
          buildWhen: (previous, current) =>
              previous.nationalId != current.nationalId ||
              previous.isNationalIdError != current.isNationalIdError,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.current.representativeNationalId,
                  style: certificateLabelStyle(context),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  value: state.nationalId,
                  hintText: S.current.representativeNationalIdHint,
                  errorText: state.isNationalIdError
                      ? S.current.authInvalidNationalId
                      : null,
                  normalizeDigits: true,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  hintTextDirection: TextDirection.rtl,
                  textStyle: certificateValueStyle(context),
                  onChanged: context
                      .read<RepresentativeCubit>()
                      .updateNationalId,
                ),
              ],
            );
          },
        ),
        SizedBox(height: fieldSpacing),
        BlocBuilder<RepresentativeCubit, RepresentativeState>(
          buildWhen: (previous, current) =>
              previous.validityText != current.validityText ||
              previous.isValidityError != current.isValidityError,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.current.representativeValidity,
                  style: certificateLabelStyle(context),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  value: state.validityText,
                  hintText: S.current.representativeValidityHint,
                  errorText: state.isValidityError
                      ? S.current.representativeValidityError
                      : null,
                  normalizeDigits: true,
                  maxLength: 10,
                  keyboardType: TextInputType.datetime,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  hintTextDirection: TextDirection.rtl,
                  textStyle: certificateValueStyle(context),
                  onChanged: context.read<RepresentativeCubit>().updateValidity,
                  suffixIcon: ColoredBox(
                    color: AppPalette.brand500,
                    child: SizedBox(
                      width: 48,
                      height: 44,
                      child: Center(
                        child: depositIcon(
                          AppAssets.certificateCalendar,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
