/// Presentation data for the deposits prototype; no bank API is connected.
class BankDeposit {
  const BankDeposit({
    required this.id,
    this.typeLabel = 'جاری حقیقی',
    this.number = '10.12003456.1',
    this.iban = 'IR550700010001112003761001',
    this.openingDate = '۱۴۰۳/۰۶/۲۴',
    this.hasChequeOperations = false,
  });

  final String id, typeLabel, number, iban, openingDate;
  final bool hasChequeOperations;

  static const singleExample = BankDeposit(
    id: 'current-single',
    hasChequeOperations: true,
  );
  static const examples = [
    BankDeposit(id: 'current-1'),
    BankDeposit(id: 'current-2'),
    BankDeposit(id: 'current-3'),
  ];
}
