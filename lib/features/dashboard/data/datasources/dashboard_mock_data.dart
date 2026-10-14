import '../../domain/entities/bank_card.dart';
import '../../domain/entities/bank_deposit.dart';
import '../../domain/entities/bank_loan.dart';

abstract final class DashboardMockData {
  static const singleCard = BankCard(id: 'current');
  static const cards = [
    BankCard(id: 'qarz-1', kind: BankCardKind.qarz, canSetSecondPin: false),
    BankCard(id: 'qarz-2', kind: BankCardKind.qarz, canSetSecondPin: false),
  ];
  static const singleDeposit = BankDeposit(
    id: 'current-single',
    hasChequeOperations: true,
  );
  static const deposits = [
    BankDeposit(id: 'current-1'),
    BankDeposit(id: 'current-2'),
    BankDeposit(id: 'current-3'),
  ];
  static const singleLoan = BankLoan(id: 'loan-single');
  static const loans = [
    BankLoan(
      id: 'loan-1',
      total: '800,000,000',
      installmentAmount: '80,000,000',
      paidInstallments: 3,
      nextInstallment: '۱۴۰۴/۱۰/۰۳',
    ),
    BankLoan(
      id: 'loan-2',
      number: '10-122-1234567-2',
      paidInstallments: 7,
      nextInstallment: '۱۴۰۴/۱۰/۰۱',
    ),
    BankLoan(
      id: 'loan-3',
      number: '10-122-1234567-3',
      total: '400,000,000',
      installmentAmount: '40,000,000',
      paidInstallments: 9,
      nextInstallment: '۱۴۰۴/۱۰/۰۸',
    ),
  ];
}
