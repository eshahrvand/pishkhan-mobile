import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/cheque_cancellation.dart';
import '../repositories/cheque_cancellation_repository.dart';

class FetchChequeCancellationCatalog {
  const FetchChequeCancellationCatalog(this.repository);
  final ChequeCancellationRepository repository;
  Future<Result<ChequeCancellationCatalog>> call() async {
    try {
      return await repository.fetchCatalog();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class FetchCancellableCheques {
  const FetchCancellableCheques(this.repository);
  final ChequeCancellationRepository repository;
  Future<Result<List<CancellableCheque>>> call(
    String depositId,
    CancellationChequeType type,
  ) async {
    try {
      return await repository.fetchCheques(depositId, type);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitChequeCancellation {
  const SubmitChequeCancellation(this.repository);
  final ChequeCancellationRepository repository;
  Future<Result<ChequeCancellationReceipt>> call(
    ChequeCancellationRequest request,
  ) async {
    try {
      return await repository.submitCancellation(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
