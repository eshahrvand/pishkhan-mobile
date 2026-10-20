import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/cheque_cancellation.dart';
import '../../domain/entities/cheque_clearance.dart';
import '../../domain/repositories/cheque_cancellation_repository.dart';

/// Session fixtures only: no banking records are cancelled.
class MockChequeCancellationRepository implements ChequeCancellationRepository {
  final _requests = <String, ChequeCancellationRequest>{};
  final _receipts = <String, ChequeCancellationReceipt>{};
  static final _catalog = ChequeCancellationCatalog(
    deposits: const [
      ChequeDeposit(id: 'cancel-1', number: '10.1234567.1'),
      ChequeDeposit(id: 'cancel-2', number: '10.1234567.2'),
    ],
    types: CancellationChequeType.values,
    reasons: ChequeCancellationReason.values,
  );

  List<CancellableCheque> _cheques(
    String depositId,
    CancellationChequeType type,
  ) {
    // Second deposit's digital list deliberately exercises the empty state.
    return depositId == 'cancel-2' && type == CancellationChequeType.digital
        ? const []
        : List.generate(
            10,
            (index) => CancellableCheque(
              id: '$depositId-${type.name}-$index',
              number: '137/${487567 + index}',
              sayadId: '${2854678398765490 + index}',
            ),
          );
  }

  @override
  Future<Result<ChequeCancellationCatalog>> fetchCatalog() async =>
      Success(_catalog);
  @override
  Future<Result<List<CancellableCheque>>> fetchCheques(
    String depositId,
    CancellationChequeType type,
  ) async {
    if (!_catalog.deposits.any((deposit) => deposit.id == depositId) ||
        !_catalog.types.contains(type)) {
      return const Err(DataFailure('cheque.selection-invalid'));
    }
    return Success(List.unmodifiable(_cheques(depositId, type)));
  }

  @override
  Future<Result<ChequeCancellationReceipt>> submitCancellation(
    ChequeCancellationRequest request,
  ) async {
    final previous = _requests[request.idempotencyKey];
    if (previous != null) {
      return previous == request
          ? Success(_receipts[request.idempotencyKey]!)
          : const Err(DataFailure('cheque.idempotency-conflict'));
    }
    if (!_catalog.deposits.any((deposit) => deposit.id == request.depositId) ||
        !_catalog.types.contains(request.type)) {
      return const Err(DataFailure('cheque.selection-invalid'));
    }
    final available = _cheques(request.depositId, request.type);
    if (request.entries.isEmpty ||
        request.entries.map((entry) => entry.cheque.id).toSet().length !=
            request.entries.length ||
        request.entries.any(
          (entry) =>
              !available.contains(entry.cheque) ||
              !_catalog.reasons.contains(entry.reason),
        )) {
      return const Err(DataFailure('cheque.cancellation-invalid'));
    }
    final receipt = ChequeCancellationReceipt(
      reference: 'DEMO-CANCEL-${_receipts.length + 1}',
      isMock: true,
    );
    _requests[request.idempotencyKey] = request;
    _receipts[request.idempotencyKey] = receipt;
    return Success(receipt);
  }
}
