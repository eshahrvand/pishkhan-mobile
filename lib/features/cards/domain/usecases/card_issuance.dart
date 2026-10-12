import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/issuance_data.dart';
import '../repositories/card_issuance_repository.dart';

class LoadIssuanceCatalog {
  const LoadIssuanceCatalog(this.repository);
  final CardIssuanceRepository repository;
  Future<Result<IssuanceCatalog>> call() => repository.load();
}

class SubmitCardIssuance {
  const SubmitCardIssuance(this.repository);
  final CardIssuanceRepository repository;
  Future<Result<IssuanceReceipt>> call(IssuanceRequest request) =>
      repository.submit(request);
}
