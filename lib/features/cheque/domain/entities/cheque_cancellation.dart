import 'package:equatable/equatable.dart';

import 'cheque_clearance.dart';

enum CancellationChequeType { paper, digital }

enum ChequeCancellationReason { damagedUnused, judicialOrder }

class CancellationChequeChoice extends Equatable {
  const CancellationChequeChoice({
    required this.cheque,
    required this.isSelected,
  });
  final CancellableCheque cheque;
  final bool isSelected;
  @override
  List<Object?> get props => [cheque, isSelected];
}

class CancellableCheque extends Equatable {
  const CancellableCheque({
    required this.id,
    required this.number,
    required this.sayadId,
  });
  final String id;
  final String number;
  final String sayadId;
  @override
  List<Object?> get props => [id, number, sayadId];
}

class ChequeCancellationCatalog extends Equatable {
  ChequeCancellationCatalog({
    required Iterable<ChequeDeposit> deposits,
    required Iterable<CancellationChequeType> types,
    required Iterable<ChequeCancellationReason> reasons,
  }) : deposits = List.unmodifiable(deposits),
       types = List.unmodifiable(types),
       reasons = List.unmodifiable(reasons);
  final List<ChequeDeposit> deposits;
  final List<CancellationChequeType> types;
  final List<ChequeCancellationReason> reasons;
  @override
  List<Object?> get props => [deposits, types, reasons];
}

class ChequeCancellationEntry extends Equatable {
  const ChequeCancellationEntry({required this.cheque, this.reason});
  final CancellableCheque cheque;
  final ChequeCancellationReason? reason;
  @override
  List<Object?> get props => [cheque, reason];
}

class ChequeCancellationRequest extends Equatable {
  ChequeCancellationRequest({
    required this.depositId,
    required this.type,
    required Iterable<ChequeCancellationEntry> entries,
    required this.idempotencyKey,
  }) : entries = List.unmodifiable(entries);
  final String depositId;
  final CancellationChequeType type;
  final List<ChequeCancellationEntry> entries;
  final String idempotencyKey;
  @override
  List<Object?> get props => [depositId, type, entries, idempotencyKey];
}

class ChequeCancellationReceipt extends Equatable {
  const ChequeCancellationReceipt({
    required this.reference,
    required this.isMock,
  });
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}
