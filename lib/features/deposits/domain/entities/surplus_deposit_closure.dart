import 'package:equatable/equatable.dart';

import 'listed_deposit.dart';

/// Server-approved closure candidates, bound to the retained primary deposit.
class SurplusDepositReview extends Equatable {
  SurplusDepositReview({
    required this.primaryDepositId,
    required this.token,
    required Iterable<ListedDeposit> deposits,
  }) : deposits = List.unmodifiable(deposits);

  final String primaryDepositId;
  final String token;
  final List<ListedDeposit> deposits;

  @override
  List<Object?> get props => [primaryDepositId, token, deposits];
}

class CloseSurplusDepositsRequest extends Equatable {
  CloseSurplusDepositsRequest({
    required this.primaryDepositId,
    required this.reviewToken,
    required Iterable<String> depositIds,
    required this.idempotencyKey,
  }) : depositIds = List.unmodifiable(depositIds);

  final String primaryDepositId;
  final String reviewToken;
  final List<String> depositIds;
  final String idempotencyKey;

  @override
  List<Object?> get props => [
    primaryDepositId,
    reviewToken,
    depositIds,
    idempotencyKey,
  ];
}

class SurplusDepositClosureReceipt extends Equatable {
  const SurplusDepositClosureReceipt({
    required this.reference,
    required this.isMock,
  });

  final String reference;
  final bool isMock;

  @override
  List<Object?> get props => [reference, isMock];
}
