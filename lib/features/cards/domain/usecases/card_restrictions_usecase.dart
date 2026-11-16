import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/card_restriction.dart';
import '../entities/card_service_data.dart';
import '../repositories/card_restrictions_repository.dart';

class FetchCardRestrictionCatalogUseCase {
  const FetchCardRestrictionCatalogUseCase(this.repository);
  final CardRestrictionsRepository repository;
  Future<Result<CardRestrictionCatalog>> call(
    CardRestrictionOperation operation,
  ) async {
    try {
      return await repository.fetchCatalog(operation);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitCardRestrictionUseCase {
  const SubmitCardRestrictionUseCase(this.repository);
  final CardRestrictionsRepository repository;
  Future<Result<CardServiceReceipt>> call(
    CardRestrictionRequest request,
  ) async {
    try {
      return await repository.submitRestriction(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
