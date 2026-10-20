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

class PostalCity extends Equatable {
  const PostalCity({required this.id, required this.name});
  final String id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}

class PostalProvince extends Equatable {
  PostalProvince({
    required this.id,
    required this.name,
    required Iterable<PostalCity> cities,
  }) : cities = List.unmodifiable(cities);
  final String id;
  final String name;
  final List<PostalCity> cities;
  @override
  List<Object?> get props => [id, name, cities];
}

class PostalOffice extends Equatable {
  const PostalOffice({required this.id, required this.address});
  final String id;
  final String address;
  @override
  List<Object?> get props => [id, address];
}

class ChequeClearanceCatalog extends Equatable {
  ChequeClearanceCatalog({
    required Iterable<ChequeDeposit> deposits,
    required Iterable<ChequeClearanceReason> reasons,
    required Iterable<PostalProvince> provinces,
    required this.mailingAddress,
  }) : deposits = List.unmodifiable(deposits),
       reasons = List.unmodifiable(reasons),
       provinces = List.unmodifiable(provinces);
  final List<ChequeDeposit> deposits;
  final List<ChequeClearanceReason> reasons;
  final List<PostalProvince> provinces;
  final String mailingAddress;
  @override
  List<Object?> get props => [deposits, reasons, provinces, mailingAddress];
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
