enum BankCardKind { current, qarz }

/// Card data supplied by the caller; the built-in examples mirror Figma.
class BankCard {
  const BankCard({
    required this.id,
    this.kind = BankCardKind.current,
    this.numberParts = const ['1234', '1234', '1234', '1234'],
    this.iban = 'IR550700010001112003761001',
    this.expiry = '**/**',
    this.cvv2 = '****',
    this.canSetSecondPin = true,
  });
  final String id;
  final BankCardKind kind;
  final List<String> numberParts;
  final String iban, expiry, cvv2;
  final bool canSetSecondPin;
  String get number => numberParts.join();
  static const singleExample = BankCard(id: 'current');
  static const examples = [
    BankCard(id: 'qarz-1', kind: BankCardKind.qarz, canSetSecondPin: false),
    BankCard(id: 'qarz-2', kind: BankCardKind.qarz, canSetSecondPin: false),
  ];
}
