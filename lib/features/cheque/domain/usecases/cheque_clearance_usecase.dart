import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/cheque_clearance.dart';
import '../repositories/cheque_clearance_repository.dart';

class FetchChequeClearanceCatalogUseCase {
  const FetchChequeClearanceCatalogUseCase(this.repository);
  final ChequeClearanceRepository repository;
  Future<Result<ChequeClearanceCatalog>> call() async {
    try {
      return await repository.fetchCatalog();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitChequeClearanceUseCase {
  const SubmitChequeClearanceUseCase(this.repository);
  final ChequeClearanceRepository repository;
  Future<Result<ChequeClearanceReceipt>> call(
    ChequeClearanceRequest request,
  ) async {
    try {
      return await repository.submitClearance(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
