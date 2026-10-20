import 'package:equatable/equatable.dart';

import 'listed_deposit.dart';

enum DepositRestrictionOperation { block, unblock }

enum DepositRestrictionReason { depositManagement }

class DepositBlockDetails extends Equatable {
  const DepositBlockDetails({
    required this.reason,
    required this.blockedAt,
    required this.description,
  });
  final DepositRestrictionReason reason;
  final DateTime blockedAt;
  final String description;
  @override
  List<Object?> get props => [reason, blockedAt, description];
}

class DepositRestrictionOption extends Equatable {
  const DepositRestrictionOption({required this.deposit, this.blockDetails});
  final ListedDeposit deposit;
  final DepositBlockDetails? blockDetails;
  @override
  List<Object?> get props => [deposit, blockDetails];
}

/// The service supplies eligible deposits, supported reasons and a fee quote.
class DepositRestrictionCatalog extends Equatable {
  DepositRestrictionCatalog({
    required Iterable<DepositRestrictionOption> deposits,
    required Iterable<DepositRestrictionReason> reasons,
    required this.quoteToken,
    required this.feeRial,
    required this.walletBalanceRial,
  }) : deposits = List.unmodifiable(deposits),
       reasons = List.unmodifiable(reasons);
  final List<DepositRestrictionOption> deposits;
  final List<DepositRestrictionReason> reasons;
  final String quoteToken;
  final int feeRial;
  final int walletBalanceRial;
  @override
  List<Object?> get props => [
    deposits,
    reasons,
    quoteToken,
    feeRial,
    walletBalanceRial,
  ];
}

class DepositRestrictionRequest extends Equatable {
  const DepositRestrictionRequest({
    required this.operation,
    required this.depositId,
    required this.reason,
    required this.description,
    required this.quoteToken,
    required this.idempotencyKey,
  });
  final DepositRestrictionOperation operation;
  final String depositId;
  final DepositRestrictionReason reason;
  final String description;
  final String quoteToken;
  final String idempotencyKey;
  @override
  List<Object?> get props => [
    operation,
    depositId,
    reason,
    description,
    quoteToken,
    idempotencyKey,
  ];
}

class DepositRestrictionReceipt extends Equatable {
  const DepositRestrictionReceipt({
    required this.reference,
    required this.isMock,
  });
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}
