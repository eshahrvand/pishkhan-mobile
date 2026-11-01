import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/deposit_restriction.dart';
import '../repositories/deposit_restrictions_repository.dart';

class FetchDepositRestrictionCatalogUseCase {
  const FetchDepositRestrictionCatalogUseCase(this.repository);
  final DepositRestrictionsRepository repository;
  Future<Result<DepositRestrictionCatalog>> call(
    DepositRestrictionOperation operation,
  ) async {
    try {
      return await repository.fetchCatalog(operation);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitDepositRestrictionUseCase {
  const SubmitDepositRestrictionUseCase(this.repository);
  final DepositRestrictionsRepository repository;
  Future<Result<DepositRestrictionReceipt>> call(
    DepositRestrictionRequest request,
  ) async {
    try {
      return await repository.submitRestriction(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
