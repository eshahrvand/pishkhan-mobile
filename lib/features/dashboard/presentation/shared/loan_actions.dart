import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
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

  String label() => switch (this) {
    payInstallments => S.current.loansPayInstallments,
    defer => S.current.dashboardDeferLoan,
    correctInstallments => S.current.dashboardCorrectInstallments,
    changeDeposit => S.current.loansChangeDeposit,
    relationships => S.current.loansRelationships,
    consolidate => S.current.consolidateDepositCredit,
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
