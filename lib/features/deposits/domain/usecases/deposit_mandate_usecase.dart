import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/deposit_mandate.dart';
import '../repositories/deposit_mandate_repository.dart';

class FetchDepositMandateCatalogUseCase {
  const FetchDepositMandateCatalogUseCase(this.repository);
  final DepositMandateRepository repository;
  Future<Result<DepositMandateCatalog>> call() async {
    try {
      return await repository.fetchCatalog();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitDepositMandateUseCase {
  const SubmitDepositMandateUseCase(this.repository);
  final DepositMandateRepository repository;
  Future<Result<DepositMandateReceipt>> call(
    DepositMandateRequest request,
  ) async {
    try {
      return await repository.submitDepositMandate(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
