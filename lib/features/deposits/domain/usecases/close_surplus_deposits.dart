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

/// One confirmed closure operation, scoped to its feature flow.
class CloseRemainingDeposits {
  CloseRemainingDeposits(this.repository);
  final SurplusDepositsRepository repository;

  // An uncertain response must retry the same reviewed payload and key.
  CloseSurplusDepositsRequest? _pendingRequest;

  Future<Result<SurplusDepositClosureReceipt>> call(
    ListedDeposit primaryDeposit, {
    required String idempotencyKey,
  }) async {
    if (_pendingRequest?.idempotencyKey != idempotencyKey) {
      final result = await FetchSurplusDeposits(repository)(primaryDeposit);
      switch (result) {
        case Err(:final failure):
          return Err(failure);
        case Success(:final data):
          _pendingRequest = CloseSurplusDepositsRequest(
            primaryDepositId: primaryDeposit.id,
            reviewToken: data.token,
            depositIds: data.deposits.map((deposit) => deposit.id),
            idempotencyKey: idempotencyKey,
          );
      }
    }
    return SubmitCloseSurplusDeposits(repository)(_pendingRequest!);
  }
}
