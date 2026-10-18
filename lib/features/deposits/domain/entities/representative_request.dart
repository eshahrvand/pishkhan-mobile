import 'package:equatable/equatable.dart';

import 'listed_deposit.dart';

enum RepresentativeOperation { chequeBook }

/// A local draft; national-code validation does not verify a person's identity.
class PendingRepresentative extends Equatable {
  const PendingRepresentative({
    required this.deposit,
    required this.operation,
    required this.nationalId,
    required this.validUntil,
  });

  final ListedDeposit deposit;
  final RepresentativeOperation operation;
  final String nationalId;
  final DateTime validUntil;

  @override
  List<Object?> get props => [deposit.id, operation, nationalId, validUntil];
}

class RepresentativeRequest extends Equatable {
  RepresentativeRequest({
    required Iterable<PendingRepresentative> representatives,
    required this.idempotencyKey,
  }) : representatives = List.unmodifiable(representatives);

  final List<PendingRepresentative> representatives;
  final String idempotencyKey;

  @override
  List<Object?> get props => [representatives, idempotencyKey];
}

class RepresentativeReceipt extends Equatable {
  const RepresentativeReceipt({required this.reference, required this.isMock});
  final String reference;
  final bool isMock;

  @override
  List<Object?> get props => [reference, isMock];
}
