import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/loan_application.dart';
import 'loan_money.dart';

class LoanInstallmentsSheet extends StatelessWidget {
  const LoanInstallmentsSheet({super.key, required this.quote});
  final LoanQuote quote;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          title: S.current.loanRequestScheduleTitle,
          showRightIcon: false,
          onLeftAction: () {
            Navigator.of(context).pop();
          },
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              for (final installment in quote.schedule.indexed) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    border: Border.all(color: context.colors.borderSubtle),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            // AppBadge has fixed 16px horizontal padding and cannot fit
                            // the authored 22px number cell; use this plain cell instead.
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                CurrencyFormatter.toPersianDigits(
                                  (installment.$1 + 1).toString(),
                                ),
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 12,
                                  color: context.colors.textOnPrimary,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          AppBadge(
                            label:
                                installment.$2.kind == LoanInstallmentKind.fee
                                ? S.current.loanRequestFee
                                : S.current.loanRequestInstallment,
                            corner: AppBadgeCorner.rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(height: 1, color: context.colors.borderSubtle),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: LoanMoney(
                                amountRial: installment.$2.amountRial,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            JalaliDateFormatter.format(installment.$2.dueAt),
                            textDirection: TextDirection.ltr,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const AvpImage(
                            image:
                                '${AppConstants.baseImage}loan_request_schedule_calendar.svg',
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
