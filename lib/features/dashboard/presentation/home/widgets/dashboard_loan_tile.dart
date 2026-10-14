import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_loan_card.dart';

/// Loan fetching, persistence, details and service execution are caller-owned.
class DashboardLoanTile extends StatelessWidget {
  const DashboardLoanTile({
    super.key,
    required this.loan,
    required this.width,
    required this.isSingle,
    required this.height,
    this.onCopyNumber,
    this.onDetailsRequested,
  });
  final BankLoan loan;
  final double width;
  final bool isSingle;
  final double height;
  final ValueChanged<String>? onCopyNumber;
  final ValueChanged<BankLoan>? onDetailsRequested;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        child: AppLoanCard(
          key: ValueKey('loan_card_${loan.id}'),
          size: isSingle ? AppLoanCardSize.single : AppLoanCardSize.multi,
          cardName: loan.title ?? S.current.loansDefaultName,
          loanNumber: loan.number,
          loanTotal: loan.total,
          installmentAmount: loan.installmentAmount,
          installmentsPaid: loan.installmentsPaid,
          nextInstallment: loan.nextInstallment,
          progress: loan.progress,
          onArrowPressed: () => onDetailsRequested?.call(loan),
          onCopyLoanNumber: () => onCopyNumber != null
              ? onCopyNumber!(loan.number)
              : Clipboard.setData(ClipboardData(text: loan.number)),
        ),
      ),
    );
  }
}
