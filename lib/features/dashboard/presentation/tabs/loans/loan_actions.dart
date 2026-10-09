import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Supported UI integration IDs; these do not execute banking operations.
enum LoanAction {
  payInstallments('loan-pay-installments'),
  defer('loan-defer'),
  correctInstallments('loan-correct-installments'),
  changeDeposit('loan-deposit'),
  relationships('loan-relationships'),
  consolidate('loan-consolidate');

  const LoanAction(this.id);
  final String id;
  static const operations = [
    payInstallments,
    defer,
    correctInstallments,
    changeDeposit,
  ];
  static const quick = [relationships, consolidate];

  String label(AppLocalizations l10n) => switch (this) {
    payInstallments => l10n.loansPayInstallments,
    defer => l10n.dashboardDeferLoan,
    correctInstallments => l10n.dashboardCorrectInstallments,
    changeDeposit => l10n.loansChangeDeposit,
    relationships => l10n.loansRelationships,
    consolidate => l10n.consolidateDepositCredit,
  };
  String get asset => switch (this) {
    payInstallments => AppAssets.loansPay,
    defer => AppAssets.loansDefer,
    correctInstallments => AppAssets.loansCorrectInstallments,
    changeDeposit => AppAssets.loansChangeDeposit,
    relationships => AppAssets.loansQuickRelationships,
    consolidate => AppAssets.loansQuickConsolidate,
  };
}

class LoanActionRequest {
  const LoanActionRequest({required this.action, required this.loan});
  final LoanAction action;
  final BankLoan loan;
}
