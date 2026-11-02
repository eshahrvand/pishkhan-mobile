import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

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
    payInstallments => '${AppConstants.baseImage}loans_pay.svg',
    defer => '${AppConstants.baseImage}loans_defer.svg',
    correctInstallments =>
      '${AppConstants.baseImage}loans_correct_installments.svg',
    changeDeposit => '${AppConstants.baseImage}loans_change_deposit.svg',
    relationships => '${AppConstants.baseImage}loans_quick_relationships.svg',
    consolidate => '${AppConstants.baseImage}loans_quick_consolidate.svg',
  };
}

class LoanActionRequest {
  const LoanActionRequest({required this.action, required this.loan});
  final LoanAction action;
  final BankLoan loan;
}
