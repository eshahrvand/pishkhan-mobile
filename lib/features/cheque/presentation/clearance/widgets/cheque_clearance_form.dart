import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/cheque_clearance.dart';
import '../cubit/cheque_clearance_cubit.dart';
import 'cheque_clearance_ui.dart';
import 'cheque_postal_instructions.dart';

class ChequeClearanceForm extends StatelessWidget {
  const ChequeClearanceForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChequeClearanceCubit, ChequeClearanceState>(
      buildWhen: (previous, current) =>
          previous.catalogStatus != current.catalogStatus ||
          previous.catalog != current.catalog ||
          previous.deposit != current.deposit ||
          previous.reason != current.reason ||
          previous.chequeNumber != current.chequeNumber ||
          previous.chequeNumberError != current.chequeNumberError ||
          previous.judicialLetterNumber != current.judicialLetterNumber ||
          previous.isJudicialLetterNumberError !=
              current.isJudicialLetterNumberError ||
          previous.isEditable != current.isEditable,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.current.chequeClearanceIntro,
                style: chequeValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              AppSelect<ChequeDeposit>(
                label: S.current.chequeDepositLabel,
                labelStyle: chequeLabelStyle(context),
                labelSpacing: 8,
                trailing: AvpImage(
                  image: state.deposit == null
                      ? '${AppConstants.baseImage}issuance_select_empty.svg'
                      : '${AppConstants.baseImage}card_features_chevron.svg',
                  width: 20,
                  height: 20,
                ),
                hintText: S.current.chequeDepositHint,
                textStyle: chequeValueStyle(context).copyWith(
                  color: state.deposit == null
                      ? context.colors.textDisabled
                      : context.colors.textPrimary,
                ),
                value: state.deposit,
                enabled: state.isEditable,
                options: [
                  for (final deposit
                      in state.catalog?.deposits ?? <ChequeDeposit>[])
                    AppSelectOption(value: deposit, label: deposit.number),
                ],
                onChanged: context.read<ChequeClearanceCubit>().selectDeposit,
              ),
              const SizedBox(height: 20),
              Text(
                S.current.chequeNumberLabel,
                style: chequeLabelStyle(context),
              ),
              const SizedBox(height: 8),
              // The design uses a compact 12px error row with its own icon.
              // Keep the package input and supplement its border/message layout.
              DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.borderSm,
                  border: state.chequeNumberError == null
                      ? null
                      : Border.all(color: context.colors.error),
                ),
                child: AppTextField(
                  value: state.chequeNumber,
                  hintText: S.current.chequeNumberHint,
                  enabled: state.isEditable,
                  normalizeDigits: true,
                  maxLength: 32,
                  keyboardType: TextInputType.datetime,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  hintTextDirection: TextDirection.rtl,
                  textStyle: chequeValueStyle(context),
                  onChanged: context
                      .read<ChequeClearanceCubit>()
                      .updateChequeNumber,
                ),
              ),
              if (state.chequeNumberError != null) ...[
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AvpImage(
                        image:
                            '${AppConstants.baseImage}cheque_clearance_question.svg',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          switch (state.chequeNumberError!) {
                            ChequeNumberError.notFound =>
                              S.current.chequeNumberNotFound,
                            ChequeNumberError.invalid =>
                              S.current.chequeNumberInvalid,
                          },
                          style: chequeLabelStyle(context).copyWith(
                            color: context.colors.error,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AppSelect<ChequeClearanceReason>(
                label: S.current.chequeReasonLabel,
                labelStyle: chequeLabelStyle(context),
                labelSpacing: 8,
                trailing: AvpImage(
                  image: state.reason == null
                      ? '${AppConstants.baseImage}issuance_select_empty.svg'
                      : '${AppConstants.baseImage}card_features_chevron.svg',
                  width: 20,
                  height: 20,
                ),
                hintText: S.current.chequeReasonHint,
                textStyle: chequeValueStyle(context).copyWith(
                  color: state.reason == null
                      ? context.colors.textDisabled
                      : context.colors.textPrimary,
                ),
                value: state.reason,
                enabled: state.isEditable,
                options: [
                  for (final reason
                      in state.catalog?.reasons ?? <ChequeClearanceReason>[])
                    AppSelectOption(
                      value: reason,
                      label: chequeReasonLabel(reason),
                    ),
                ],
                onChanged: (reason) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context.read<ChequeClearanceCubit>().selectReason(reason);
                },
              ),
              if (state.isJudicialLetterRequired) ...[
                const SizedBox(height: 20),
                Text(
                  S.current.chequeJudicialNumber,
                  style: chequeLabelStyle(context),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  value: state.judicialLetterNumber,
                  hintText: S.current.chequeJudicialNumberHint,
                  enabled: state.isEditable,
                  normalizeDigits: true,
                  keyboardType: TextInputType.number,
                  maxLength: 32,
                  textAlign: TextAlign.right,
                  textStyle: chequeValueStyle(context),
                  errorText: state.isJudicialLetterNumberError
                      ? S.current.chequeJudicialNumberInvalid
                      : null,
                  onChanged: context
                      .read<ChequeClearanceCubit>()
                      .updateJudicialLetterNumber,
                ),
              ],
              if (state.reason != null) ...[
                const SizedBox(height: 20),
                const AvpImage(
                  image: '${AppConstants.baseImage}issuance_divider.svg',
                  height: 1,
                  fit: BoxFit.fill,
                ),
                const SizedBox(height: 20),
                if (state.requiredDocument != null)
                  ChequePostalInstructions(state: state)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppPasswordServiceColors.cameraNotice,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Row(
                      children: [
                        const AvpImage(
                          image:
                              '${AppConstants.baseImage}password_camera_info.svg',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            S.current.chequeNoPostRequired,
                            style: chequeLabelStyle(context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              if (state.catalogStatus == RequestStatus.loading) ...[
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
              ],
              if (state.catalogStatus == RequestStatus.failure) ...[
                const SizedBox(height: 20),
                const SizedBox.shrink(),
                AppButton(
                  isLoading: state.catalogStatus == RequestStatus.loading,
                  label: S.current.dashboardRetry,
                  onPressed: context.read<ChequeClearanceCubit>().fetchCatalog,
                ),
              ],
              if (state.catalogStatus == RequestStatus.success &&
                  state.catalog!.deposits.isEmpty)
                Text(S.current.depositsEmpty),
            ],
          ),
        );
      },
    );
  }
}
