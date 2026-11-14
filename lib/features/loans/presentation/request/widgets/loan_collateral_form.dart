import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';
import '../cubit/loan_request_cubit.dart';
import 'loan_value_row.dart';
import 'loan_money.dart';
import 'loan_collateral_notice.dart';
import 'loan_guarantor_warning.dart';
import 'loan_request_labels.dart';
import 'loan_repayment_choices.dart';

class LoanCollateralForm extends StatelessWidget {
  const LoanCollateralForm({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoanValueRow(
          label: S.current.loanRequestRequestedAmount,
          valueContent: LoanMoney(amountRial: state.quote!.input.amountRial),
          bordered: false,
          icon: '${AppConstants.baseImage}loan_request_coins.svg',
        ),
        const SizedBox(height: 12),
        LoanValueRow(
          label: S.current.loanRequestTier,
          value: loanRangeLabel(state.quote!.range),
          icon: '${AppConstants.baseImage}loan_request_gauge.svg',
          color: context.colors.success,
        ),
        const SizedBox(height: 12),
        LoanValueRow(
          label: state.ownInstrument == LoanInstrument.promissoryNote
              ? S.current.loanRequestNoteAmount
              : S.current.loanRequestCollateralAmount,
          valueContent: LoanMoney(
            amountRial: state.quote!.collateralRial,
            color: context.colors.warning,
          ),
          bordered: false,
          icon: '${AppConstants.baseImage}loan_request_cheque.svg',
          color: context.colors.warning,
        ),
        const SizedBox(height: 16),
        LoanCollateralNotice(quote: state.quote!),
        const SizedBox(height: 16),
        Divider(height: 1, color: context.colors.borderSubtle),
        if (state.quote!.needsGuarantor) ...[
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppTextField(
                  label: S.current.loanRequestGuarantorId,
                  hintText: S.current.loanRequestGuarantorIdHint,
                  value: state.guarantorNationalId,
                  suffixIcon: state.guarantor != null
                      ? InkWell(
                          onTap: () {
                            context
                                .read<LoanRequestCubit>()
                                .updateGuarantorNationalId('');
                          },
                          child: const AvpImage(
                            image:
                                '${AppConstants.baseImage}loan_request_clear.svg',
                            width: 20,
                            height: 20,
                          ),
                        )
                      : null,
                  onFocusLost: context
                      .read<LoanRequestCubit>()
                      .validateGuarantorNationalId,
                  normalizeDigits: true,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.end,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  enabled: state.guarantorStatus != RequestStatus.loading,
                  errorText: state.isGuarantorIdError
                      ? S.current.authInvalidNationalId
                      : null,
                  onChanged: (value) {
                    context.read<LoanRequestCubit>().updateGuarantorNationalId(
                      value,
                    );
                  },
                ),
              ),
              if (state.guarantor == null) ...[
                const SizedBox(width: 12),
                AppButton(
                  label: S.current.loanRequestCheck,
                  isActive: state.canCheckGuarantor,
                  isLoading: state.guarantorStatus == RequestStatus.loading,
                  onPressed: context.read<LoanRequestCubit>().checkGuarantor,
                ),
              ],
            ],
          ),
          if (state.guarantor != null) ...[
            const SizedBox(height: 12),
            if (state.guarantor!.name != null)
              LoanValueRow(
                label: S.current.loanRequestGuarantorName,
                value: state.guarantor!.name!,
                backgroundColor: context.colors.surfaceSubtle,
                bordered: false,
                color: context.colors.textSecondary,
              ),
            if (state.guarantor!.outcome == LoanGuarantorOutcome.notCustomer)
              LoanGuarantorWarning(
                message: S.current.loanRequestGuarantorNotCustomer,
              ),
            if (state.guarantor!.outcome ==
                LoanGuarantorOutcome.capacityExceeded)
              LoanGuarantorWarning(message: S.current.loanRequestGuarantorFull),
          ],
        ],
        if (!state.quote!.needsGuarantor ||
            state.guarantor?.outcome == LoanGuarantorOutcome.approved) ...[
          const SizedBox(height: 24),
          if (state.quote!.needsGuarantor) ...[
            Text(
              S.current.loanRequestEnterBoth,
              style: AppTypography.titleSmall,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (state.quote!.needsGuarantor) ...[
                Text(
                  S.current.loanRequestOwnInfo,
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: LoanRepaymentChoices(
                  checkMark: true,
                  value: state.ownInstrument,
                  first: LoanInstrument.promissoryNote,
                  second: LoanInstrument.electronicCheque,
                  firstLabel: S.current.loanRequestNote,
                  secondLabel: S.current.loanRequestCheque,
                  onChanged: (value) {
                    context.read<LoanRequestCubit>().selectOwnInstrument(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: state.ownInstrument == LoanInstrument.promissoryNote
                ? S.current.loanRequestNoteNumber
                : S.current.loanRequestChequeNumber,
            hintText: state.ownInstrument == LoanInstrument.promissoryNote
                ? S.current.loanRequestNoteHint
                : S.current.loanRequestChequeHint,
            value: state.ownNumber,
            onFocusLost: context.read<LoanRequestCubit>().validateOwnNumber,
            normalizeDigits: true,
            maxLength: 20,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.end,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: state.isOwnNumberError || state.isCollateralError
                ? S.current.loanRequestInstrumentInvalid
                : null,
            onChanged: (value) {
              context.read<LoanRequestCubit>().updateOwnNumber(value);
            },
          ),
          if (state.quote!.needsGuarantor) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  S.current.loanRequestGuarantorInfo,
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LoanRepaymentChoices(
                    checkMark: true,
                    value: state.guarantorInstrument,
                    first: LoanInstrument.promissoryNote,
                    second: LoanInstrument.electronicCheque,
                    firstLabel: S.current.loanRequestNote,
                    secondLabel: S.current.loanRequestCheque,
                    onChanged: (value) {
                      context
                          .read<LoanRequestCubit>()
                          .selectGuarantorInstrument(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: state.guarantorInstrument == LoanInstrument.promissoryNote
                  ? S.current.loanRequestNoteNumber
                  : S.current.loanRequestChequeNumber,
              hintText:
                  state.guarantorInstrument == LoanInstrument.promissoryNote
                  ? S.current.loanRequestNoteHint
                  : S.current.loanRequestChequeHint,
              value: state.guarantorNumber,
              onFocusLost: context
                  .read<LoanRequestCubit>()
                  .validateGuarantorNumber,
              normalizeDigits: true,
              maxLength: 20,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.end,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              errorText: state.isGuarantorNumberError || state.isCollateralError
                  ? S.current.loanRequestInstrumentInvalid
                  : null,
              onChanged: (value) {
                context.read<LoanRequestCubit>().updateGuarantorNumber(value);
              },
            ),
          ],
        ],
      ],
    );
  }
}
