import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/listed_deposit.dart';
import '../../domain/entities/surplus_deposit_closure.dart';
import '../../domain/repositories/surplus_deposits_repository.dart';

/// In-memory scenarios only. No bank account or balance is changed.
class MockSurplusDepositsRepository implements SurplusDepositsRepository {
  static final primaryDeposits = List<ListedDeposit>.unmodifiable([
    ListedDeposit(id: 'primary-1', number: '10.1234567.1'),
    ListedDeposit(id: 'primary-2', number: '10.1234567.2'),
    ListedDeposit(id: 'primary-3', number: '10.1234567.3'),
  ]);
  static final _surplusDeposits = List<ListedDeposit>.unmodifiable([
    ListedDeposit(id: 'surplus-1', number: '10.1234567.4'),
    ListedDeposit(id: 'surplus-2', number: '10.1234567.5'),
  ]);

  final _reviews = <String, SurplusDepositReview>{};
  final _requests = <String, CloseSurplusDepositsRequest>{};
  final _receipts = <String, SurplusDepositClosureReceipt>{};
  final _closedDepositIds = <String>{};
  int _reviewSequence = 0;

  @override
  Future<Result<List<ListedDeposit>>> fetchPrimaryDeposits() async {
    return Success(primaryDeposits);
  }

  @override
  Future<Result<SurplusDepositReview>> fetchSurplusDeposits(
    ListedDeposit primaryDeposit,
  ) async {
    if (!primaryDeposits.any((deposit) => deposit.id == primaryDeposit.id)) {
      return const Err(DataFailure('surplus.primary.unavailable'));
    }
    final review = SurplusDepositReview(
      primaryDepositId: primaryDeposit.id,
      token: 'mock-review-${++_reviewSequence}',
      // The second primary deposit reproduces the supplied empty-state frame.
      deposits: primaryDeposit.id == 'primary-2'
          ? const <ListedDeposit>[]
          : _surplusDeposits.where(
              (deposit) => !_closedDepositIds.contains(deposit.id),
            ),
    );
    _reviews[review.token] = review;
    return Success(review);
  }

  @override
  Future<Result<SurplusDepositClosureReceipt>> closeSurplusDeposits(
    CloseSurplusDepositsRequest request,
  ) async {
    if (_requests.containsKey(request.idempotencyKey)) {
      return request == _requests[request.idempotencyKey]
          ? Success(_receipts[request.idempotencyKey]!)
          : const Err(DataFailure('surplus.idempotency.conflict'));
    }
    final review = _reviews[request.reviewToken];
    if (review == null ||
        review.primaryDepositId != request.primaryDepositId ||
        request.depositIds.isEmpty ||
        request.depositIds.contains(request.primaryDepositId) ||
        request.depositIds.toSet().length != request.depositIds.length ||
        request.depositIds.length != review.deposits.length ||
        !review.deposits.every(
          (deposit) => request.depositIds.contains(deposit.id),
        ) ||
        request.depositIds.any(_closedDepositIds.contains)) {
      return const Err(DataFailure('surplus.review.invalid'));
    }
    final receipt = SurplusDepositClosureReceipt(
      reference: 'DEMO-CLOSE-${_receipts.length + 1}',
      isMock: true,
    );
    _requests[request.idempotencyKey] = request;
    _receipts[request.idempotencyKey] = receipt;
    _closedDepositIds.addAll(request.depositIds);
    return Success(receipt);
  }
}
