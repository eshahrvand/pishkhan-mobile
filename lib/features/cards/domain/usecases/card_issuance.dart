import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../entities/issuance_data.dart';
import '../repositories/card_issuance_repository.dart';

class LoadIssuanceCatalog {
  const LoadIssuanceCatalog(this.repository);
  final CardIssuanceRepository repository;
  Future<Result<IssuanceCatalog>> call() async {
    try {
      return await repository.load();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitCardIssuance {
  const SubmitCardIssuance(this.repository);
  final CardIssuanceRepository repository;
  Future<Result<IssuanceReceipt>> call(IssuanceRequest request) async {
    try {
      return await repository.submit(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
