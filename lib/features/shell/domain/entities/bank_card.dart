import 'dashboard_item.dart';

enum BankCardKind { current, qarz }

/// Card data supplied by the caller; the built-in examples mirror Figma.
class BankCard extends DashboardItem {
  const BankCard({
    required this.id,
    this.kind = BankCardKind.current,
    List<String> numberParts = const ['1234', '1234', '1234', '1234'],
    this.iban = 'IR550700010001112003761001',
    this.expiry = '**/**',
    this.cvv2 = '****',
    this.canSetSecondPin = true,
    // Public constructor name intentionally differs from the private backing field.
    // ignore: prefer_initializing_formals
  }) : _numberParts = numberParts;
  @override
  final String id;
  final BankCardKind kind;
  final List<String> _numberParts;
  List<String> get numberParts => List.unmodifiable(_numberParts);
  final String iban, expiry, cvv2;
  final bool canSetSecondPin;
  String get number => numberParts.join();
  @override
  List<Object?> get props => [
    id,
    kind,
    numberParts,
    iban,
    expiry,
    cvv2,
    canSetSecondPin,
  ];
  @override
  BankCard snapshot() => BankCard(
    id: id,
    kind: kind,
    numberParts: List.unmodifiable(numberParts),
    iban: iban,
    expiry: expiry,
    cvv2: cvv2,
    canSetSecondPin: canSetSecondPin,
  );
}
