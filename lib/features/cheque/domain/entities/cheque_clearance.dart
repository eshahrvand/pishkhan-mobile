import 'package:equatable/equatable.dart';

enum ChequeClearanceReason {
  depositAndBlock,
  olderThanThreeYears,
  originalCheque,
  partialPaymentCertificate,
  notarizedConsent,
  judicialLetter,
}

enum ChequeClearanceDocument {
  originalCheque,
  partialPaymentCertificate,
  notarizedConsent,
  judicialLetter,
}

class ChequeDeposit extends Equatable {
  const ChequeDeposit({required this.id, required this.number});
  final String id;
  final String number;
  @override
  List<Object?> get props => [id, number];
}

class ChequeClearanceCatalog extends Equatable {
  ChequeClearanceCatalog({
    required Iterable<ChequeDeposit> deposits,
    required Iterable<ChequeClearanceReason> reasons,
    required this.mailingAddress,
  }) : deposits = List.unmodifiable(deposits),
       reasons = List.unmodifiable(reasons);
  final List<ChequeDeposit> deposits;
  final List<ChequeClearanceReason> reasons;
  final String mailingAddress;
  @override
  List<Object?> get props => [deposits, reasons, mailingAddress];
}

class ChequeClearanceRequest extends Equatable {
  const ChequeClearanceRequest({
    required this.depositId,
    required this.chequeNumber,
    required this.reason,
    required this.idempotencyKey,
    this.judicialLetterNumber,
  });
  final String depositId;
  final String chequeNumber;
  final ChequeClearanceReason reason;
  final String? judicialLetterNumber;
  final String idempotencyKey;
  @override
  List<Object?> get props => [
    depositId,
    chequeNumber,
    reason,
    judicialLetterNumber,
    idempotencyKey,
  ];
}

class ChequeClearanceReceipt extends Equatable {
  const ChequeClearanceReceipt({required this.reference, required this.isMock});
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}
