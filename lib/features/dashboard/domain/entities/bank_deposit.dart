import 'dashboard_item.dart';

/// Presentation data for the deposits prototype; no bank API is connected.
class BankDeposit extends DashboardItem {
  const BankDeposit({
    required this.id,
    this.typeLabel = 'جاری حقیقی',
    this.number = '10.12003456.1',
    this.iban = 'IR550700010001112003761001',
    this.openingDate = '۱۴۰۳/۰۶/۲۴',
    this.hasChequeOperations = false,
  });

  @override
  final String id;
  final String typeLabel, number, iban, openingDate;
  final bool hasChequeOperations;

  @override
  List<Object?> get props => [
    id,
    typeLabel,
    number,
    iban,
    openingDate,
    hasChequeOperations,
  ];
  @override
  BankDeposit snapshot() => this;
}
