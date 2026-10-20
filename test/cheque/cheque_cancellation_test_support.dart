import 'dart:async';

import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cheque/data/repositories/mock_cheque_cancellation_repository.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_cancellation.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_cancellation_repository.dart';

class TestChequeCancellationRepository implements ChequeCancellationRepository {
  final delegate = MockChequeCancellationRepository();
  final requests = <ChequeCancellationRequest>[];
  final listRequests = <Completer<Result<List<CancellableCheque>>>>[];
  bool failCatalog = false;
  bool throwCatalog = false;
  bool controlLists = false;
  Result<ChequeCancellationReceipt>? submissionResult;
  Completer<Result<ChequeCancellationReceipt>>? pendingSubmission;

  @override
  Future<Result<ChequeCancellationCatalog>> fetchCatalog() {
    if (throwCatalog) throw StateError('invalid service response');
    return failCatalog
        ? Future.value(const Err(DataFailure('offline')))
        : delegate.fetchCatalog();
  }

  @override
  Future<Result<List<CancellableCheque>>> fetchCheques(
    String depositId,
    CancellationChequeType type,
  ) {
    if (controlLists) {
      final request = Completer<Result<List<CancellableCheque>>>();
      listRequests.add(request);
      return request.future;
    }
    return delegate.fetchCheques(depositId, type);
  }

  @override
  Future<Result<ChequeCancellationReceipt>> submitCancellation(
    ChequeCancellationRequest request,
  ) {
    requests.add(request);
    return pendingSubmission?.future ??
        (submissionResult == null
            ? delegate.submitCancellation(request)
            : Future.value(submissionResult));
  }
}
