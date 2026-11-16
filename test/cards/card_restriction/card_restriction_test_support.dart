import 'dart:async';

import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_card_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/card_restriction.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/card_service_data.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_restrictions_repository.dart';

class ControlledCardRestrictionsRepository
    implements CardRestrictionsRepository {
  final delegate = MockCardRestrictionsRepository();
  final requests = <CardRestrictionRequest>[];
  Completer<Result<CardServiceReceipt>>? pendingSubmission;
  Completer<Result<CardRestrictionCatalog>>? pendingCatalog;
  bool failSubmission = false;
  bool failCatalog = false;
  @override
  Future<Result<CardRestrictionCatalog>> fetchCatalog(
    CardRestrictionOperation operation,
  ) async {
    if (pendingCatalog != null) return pendingCatalog!.future;
    if (failCatalog) return const Err(DataFailure('network.connection'));
    return delegate.fetchCatalog(operation);
  }

  @override
  Future<Result<CardServiceReceipt>> submitRestriction(
    CardRestrictionRequest request,
  ) async {
    requests.add(request);
    if (pendingSubmission != null) return pendingSubmission!.future;
    if (failSubmission) return const Err(DataFailure('network.connection'));
    return delegate.submitRestriction(request);
  }
}

void installRestrictionsRepository(CardRestrictionsRepository repository) {
  // Called before either lazy UseCase is resolved by a Cubit.
  getIt.unregister<CardRestrictionsRepository>();
  getIt.registerSingleton<CardRestrictionsRepository>(repository);
}
