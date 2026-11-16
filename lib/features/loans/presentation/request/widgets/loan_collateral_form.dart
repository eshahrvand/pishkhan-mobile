import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';
import '../cubit/loan_request_cubit.dart';
import 'loan_value_row.dart';
import 'loan_money.dart';
import 'loan_collateral_notice.dart';
import 'loan_guarantor_form.dart';
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
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          label: S.current.loanRequestRequestedAmount,
          valueContent: LoanMoney(
            amountRial: state.quote!.input.amountRial,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            unitSize: 20,
          ),
          bordered: false,
          icon: '${AppConstants.baseImage}loan_request_coins.svg',
        ),
        const SizedBox(height: 12),
        LoanValueRow(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          valueFontSize: 12,
          bordered: false,
          label: S.current.loanRequestTier,
          value: loanRangeLabel(state.quote!.range),
          icon: '${AppConstants.baseImage}loan_request_gauge.svg',
          color: context.colors.success,
        ),
        const SizedBox(height: 12),
        LoanValueRow(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          label: state.ownInstrument == LoanInstrument.promissoryNote
              ? S.current.loanRequestNoteAmount
              : S.current.loanRequestCollateralAmount,
          valueContent: LoanMoney(
            amountRial: state.quote!.collateralRial,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            unitSize: 20,
            color: context.colors.warning,
          ),
          bordered: false,
          icon: '${AppConstants.baseImage}loan_request_cheque.svg',
          color: context.colors.warning,
        ),
        const SizedBox(height: 12),
        LoanCollateralNotice(quote: state.quote!),
        const SizedBox(height: 16),
        const AvpImage(
          image: '${AppConstants.baseImage}loan_request_divider.svg',
          height: 1,
          fit: BoxFit.fill,
        ),
        if (state.quote!.needsGuarantor) LoanGuarantorForm(state: state),
        if (!state.quote!.needsGuarantor ||
            state.guarantor?.outcome == LoanGuarantorOutcome.approved) ...[
          const SizedBox(height: 24),
          if (state.quote!.needsGuarantor) ...[
            Text(
              S.current.loanRequestEnterBoth,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (state.quote!.needsGuarantor) ...[
                Text(
                  S.current.loanRequestOwnInfo,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: LoanRepaymentChoices(
                  checkMark: true,
                  labelStyle: AppTypography.bodySmall.copyWith(
                    color: AppPalette.gray700,
                    letterSpacing: 0,
                  ),
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
          if (!state.quote!.needsGuarantor) ...[
            Text(
              state.ownInstrument == LoanInstrument.promissoryNote
                  ? S.current.loanRequestNoteNumber
                  : S.current.loanRequestChequeNumber,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppPalette.gray700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
          ],
          AppTextField(
            hintText: state.ownInstrument == LoanInstrument.promissoryNote
                ? S.current.loanRequestNoteHint
                : S.current.loanRequestChequeHint,
            value: state.ownNumber,
            onFocusLost: context.read<LoanRequestCubit>().validateOwnNumber,
            normalizeDigits: true,
            maxLength: 20,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textStyle: AppTypography.bodyMedium.copyWith(letterSpacing: 0),
            hintTextDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
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
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LoanRepaymentChoices(
                    checkMark: true,
                    labelStyle: AppTypography.bodySmall.copyWith(
                      color: AppPalette.gray700,
                      letterSpacing: 0,
                    ),
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
              textStyle: AppTypography.bodyMedium.copyWith(letterSpacing: 0),
              hintTextDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
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
