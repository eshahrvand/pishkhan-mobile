import 'dashboard_item.dart';

/// Caller-owned loan presentation data; no bank repository is connected.
class BankLoan extends DashboardItem {
  const BankLoan({
    required this.id,
    this.title,
    this.number = '10-122-1234567-1',
    this.total = '500,000,000',
    this.installmentAmount = '50,000,000',
    this.paidInstallments = 4,
    this.totalInstallments = 10,
    this.nextInstallment = '۱۴۰۴/۰۸/۰۳',
  }) : assert(paidInstallments >= 0),
       assert(totalInstallments >= 0);

  @override
  final String id;
  final String? title;
  final String number, total, installmentAmount, nextInstallment;
  final int paidInstallments, totalInstallments;

  String get installmentsPaid => '$paidInstallments/$totalInstallments';

  /// A zero/unknown total cannot define a ratio. Inconsistent counts are bounded.
  double get progress => totalInstallments <= 0
      ? 0
      : (paidInstallments / totalInstallments).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
    id,
    title,
    number,
    total,
    installmentAmount,
    nextInstallment,
    paidInstallments,
    totalInstallments,
  ];
  @override
  BankLoan snapshot() => this;
}
