import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/agent_request.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_fields.dart';
import '../cubit/agent_cubit.dart';

/// Authored once for both the initial screen and the additional-person sheet.
class AgentForm extends StatelessWidget {
  const AgentForm({super.key, this.fieldSpacing = 20});
  final double fieldSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<AgentCubit, AgentState>(
          buildWhen: (previous, current) =>
              previous.deposit != current.deposit ||
              previous.operation != current.operation ||
              previous.deposits != current.deposits,
          builder: (context, state) {
            return Column(
              children: [
                CertificateSelect<ListedDeposit>(
                  label: S.current.agentDeposit,
                  hint: S.current.agentDepositHint,
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
                  onChanged: context.read<AgentCubit>().selectDeposit,
                ),
                SizedBox(height: fieldSpacing),
                CertificateSelect<AgentOperation>(
                  label: S.current.agentOperation,
                  hint: S.current.agentOperationHint,
                  value: state.operation,
                  options: [
                    AppSelectOption(
                      value: AgentOperation.chequeBook,
                      label: S.current.agentChequeBook,
                    ),
                  ],
                  onChanged: context.read<AgentCubit>().selectOperation,
                ),
              ],
            );
          },
        ),
        SizedBox(height: fieldSpacing),
        BlocBuilder<AgentCubit, AgentState>(
          buildWhen: (previous, current) =>
              previous.nationalId != current.nationalId ||
              previous.isNationalIdError != current.isNationalIdError,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.current.agentNationalId,
                  style: certificateLabelStyle(context),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  value: state.nationalId,
                  hintText: S.current.agentNationalIdHint,
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
                  onChanged: context.read<AgentCubit>().updateNationalId,
                ),
              ],
            );
          },
        ),
        SizedBox(height: fieldSpacing),
        BlocBuilder<AgentCubit, AgentState>(
          buildWhen: (previous, current) =>
              previous.validityText != current.validityText ||
              previous.isValidityError != current.isValidityError,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.current.agentValidity,
                  style: certificateLabelStyle(context),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  value: state.validityText,
                  hintText: S.current.agentValidityHint,
                  errorText: state.isValidityError
                      ? S.current.agentValidityError
                      : null,
                  normalizeDigits: true,
                  maxLength: 10,
                  keyboardType: TextInputType.datetime,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  hintTextDirection: TextDirection.rtl,
                  textStyle: certificateValueStyle(context),
                  onChanged: context.read<AgentCubit>().updateValidity,
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
