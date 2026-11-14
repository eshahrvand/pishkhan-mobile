import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';
import '../cubit/loan_request_cubit.dart';
import 'loan_repayment_choices.dart';
import 'loan_value_row.dart';
import 'loan_credit_status.dart';
import 'loan_money.dart';
import 'loan_text_link.dart';

class LoanAssessment extends StatelessWidget {
  const LoanAssessment({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSelect<LoanDeposit>(
          label: S.current.loanRequestDeposit,
          hintText: S.current.loanRequestDepositHint,
          labelSpacing: 8,
          textStyle: AppTypography.bodyMedium.copyWith(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: const Color(0xFF181D27),
          ),
          labelStyle: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          trailing: const AvpImage(
            image: '${AppConstants.baseImage}loan_request_select_chevron.svg',
            width: 20,
            height: 20,
          ),
          value: state.deposit,
          options: [
            for (final deposit in state.catalog!.deposits)
              AppSelectOption(
                value: deposit,
                label: '\u2066${deposit.number}\u2069',
              ),
          ],
          onChanged: (value) {
            context.read<LoanRequestCubit>().selectDeposit(value);
          },
        ),
        if (state.deposit != null) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(
                  S.current.loanRequestRepayment,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.gray700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: LoanRepaymentChoices(
                    value: state.repayment,
                    first: LoanRepayment.installments,
                    second: LoanRepayment.lumpSum,
                    firstLabel: S.current.loanRequestInstallments,
                    secondLabel: S.current.loanRequestLumpSum,
                    onChanged: (value) {
                      context.read<LoanRequestCubit>().selectRepayment(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            height: 0,
            child: OverflowBox(
              minHeight: 1,
              maxHeight: 1,
              child: AvpImage(
                image: '${AppConstants.baseImage}loan_request_divider.svg',
                height: 1,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (state.assessment != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        LoanMoney(
                          amountRial: state.assessment!.scoreRial,
                          fontSize: 14,
                          color: const Color(0xFF181D27),
                          unitSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: context.colors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              S.current.loanRequestScore,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppPalette.gray700,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        LoanMoney(
                          amountRial: state.assessment!.currentLoansRial,
                          fontSize: 14,
                          color: const Color(0xFF181D27),
                          unitSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: context.colors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              S.current.loanRequestCurrentTotal,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppPalette.gray700,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          LoanValueRow(
            height: 44,
            valueWidth: 140,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            backgroundColor: AppPalette.gray25,
            labelStyle: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              color: const Color(0xFF454C52),
            ),
            label: S.current.loanRequestAmount,
            valueContent: LoanMoney(
              amountRial: state.amountRial,
              highlightUnit: true,
            ),
            icon: '${AppConstants.baseImage}loan_request_coins.svg',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return AppSlider(
                singleThumb: true,
                width: constraints.maxWidth,
                extraBars: [
                  AppSliderExtraBar(
                    start: 0,
                    end: state.assessment!.amountGreenEnd,
                    color: AppPalette.success400,
                    top: 10,
                  ),
                  AppSliderExtraBar(
                    start: state.assessment!.amountRedStart,
                    end: 1,
                    color: AppPalette.error400,
                    top: 20,
                    paintOverProgress: true,
                  ),
                ],
                values: RangeValues(0, state.amountPosition!),
                onChanged: (value) {
                  context.read<LoanRequestCubit>().updateAmount(value.end);
                },
              );
            },
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.ltr,
            children: [
              LoanMoney(
                amountRial: state.catalog!.minimumRial,
                fontSize: 12,
                color: AppPalette.gray600,
                fontWeight: FontWeight.w400,
              ),
              LoanMoney(
                amountRial: state.catalog!.maximumRial,
                fontSize: 12,
                color: AppPalette.gray600,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
          const SizedBox(height: 24),
          LoanValueRow(
            height: 44,
            valueWidth: 140,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            backgroundColor: AppPalette.gray25,
            labelStyle: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              color: const Color(0xFF454C52),
            ),
            label: S.current.loanRequestMonths,
            valueContent: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.ltr,
              children: [
                const AvpImage(
                  image: '${AppConstants.baseImage}loan_request_month_unit.svg',
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.toPersianDigits(state.months.toString()),
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    color: AppPalette.gray800,
                  ),
                ),
              ],
            ),
            icon: '${AppConstants.baseImage}loan_request_calendar.svg',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return AppSlider(
                singleThumb: true,
                width: constraints.maxWidth,
                values: RangeValues(0, state.monthsPosition!),
                onChanged: (value) {
                  context.read<LoanRequestCubit>().updateMonths(value.end);
                },
              );
            },
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.ltr,
            children: [
              Text(
                '${CurrencyFormatter.toPersianDigits(state.minimumMonths.toString())} ${S.current.loanRequestMonthUnit}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppPalette.gray600,
                  letterSpacing: 0,
                ),
              ),
              Text(
                '${CurrencyFormatter.toPersianDigits(state.maximumMonths.toString())} ${S.current.loanRequestMonthUnit}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppPalette.gray600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 4,
            child: state.quoteStatus == RequestStatus.loading
                ? const LinearProgressIndicator()
                : null,
          ),
          if (state.quoteStatus == RequestStatus.failure)
            AppButton(
              label: S.current.dashboardRetry,
              onPressed: context.read<LoanRequestCubit>().fetchQuote,
            ),
          if (state.assessment != null) ...[
            if (state.repayment == LoanRepayment.installments)
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: LoanValueRow(
                  height: 44,
                  valueWidth: 140,
                  labelStyle: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    color: const Color(0xFF454C52),
                  ),
                  label: S.current.loanRequestMonthly,
                  valueContent: LoanMoney(
                    amountRial: state.assessment!.monthlyPaymentRial,
                    highlightUnit: true,
                  ),
                  backgroundColor: context.colors.primarySubtle,
                  bordered: false,
                  icon: '${AppConstants.baseImage}loan_request_money.svg',
                ),
              ),
            const SizedBox(height: 20),
            LoanTextLink(
              label: S.current.loanRequestTable,
              isActive: state.quoteStatus == RequestStatus.success,
              onPressed: context.read<LoanRequestCubit>().requestInstallments,
            ),
            const SizedBox(height: 16),
            IgnorePointer(
              ignoring: state.quoteStatus != RequestStatus.success,
              child: ExcludeSemantics(
                excluding: state.quoteStatus != RequestStatus.success,
                child: LoanCreditStatus(state: state),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
