import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/listed_deposit.dart';
import '../entities/surplus_deposit_closure.dart';
import '../repositories/surplus_deposits_repository.dart';

class FetchPrimaryDeposits {
  const FetchPrimaryDeposits(this.repository);
  final SurplusDepositsRepository repository;

  Future<Result<List<ListedDeposit>>> call() async {
    try {
      return switch (await repository.fetchPrimaryDeposits()) {
        Success(:final data) => Success(List.unmodifiable(data)),
        Err(:final failure) => Err(failure),
      };
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class FetchSurplusDeposits {
  const FetchSurplusDeposits(this.repository);
  final SurplusDepositsRepository repository;

  Future<Result<SurplusDepositReview>> call(
    ListedDeposit primaryDeposit,
  ) async {
    try {
      return await repository.fetchSurplusDeposits(primaryDeposit);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitCloseSurplusDeposits {
  const SubmitCloseSurplusDeposits(this.repository);
  final SurplusDepositsRepository repository;

  Future<Result<SurplusDepositClosureReceipt>> call(
    CloseSurplusDepositsRequest request,
  ) async {
    try {
      return await repository.closeSurplusDeposits(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
