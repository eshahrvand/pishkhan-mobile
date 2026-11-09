import 'package:equatable/equatable.dart';

import 'card_service_data.dart';

enum CardRestrictionOperation { block, unblock }

enum CardRestrictionReason { lost, stolen, depositManagement, found, other }

class CardRestrictionDetails extends Equatable {
  const CardRestrictionDetails({
    required this.reason,
    required this.blockedAt,
    required this.description,
  });
  final CardRestrictionReason reason;
  final DateTime blockedAt;
  final String description;
  @override
  List<Object?> get props => [reason, blockedAt, description];
}

class RestrictionCard extends Equatable {
  const RestrictionCard({
    required this.id,
    required this.number,
    required this.deposit,
    this.blockDetails,
  });
  final String id;
  final String number;
  final CardServiceDeposit deposit;
  final CardRestrictionDetails? blockDetails;
  @override
  List<Object?> get props => [id, number, deposit, blockDetails];
}

class CardRestrictionCatalog extends Equatable {
  CardRestrictionCatalog({
    required Iterable<RestrictionCard> cards,
    required Iterable<CardRestrictionReason> reasons,
    required this.feeRial,
    required this.walletBalanceRial,
    required this.quoteToken,
  }) : cards = List.unmodifiable(cards),
       reasons = List.unmodifiable(reasons);
  final List<RestrictionCard> cards;
  final List<CardRestrictionReason> reasons;
  final int feeRial;
  final int walletBalanceRial;
  final String quoteToken;
  @override
  List<Object?> get props => [
    cards,
    reasons,
    feeRial,
    walletBalanceRial,
    quoteToken,
  ];
}

class CardRestrictionRequest extends Equatable {
  const CardRestrictionRequest({
    required this.operation,
    required this.cardId,
    required this.reason,
    required this.description,
    required this.quoteToken,
    required this.idempotencyKey,
  });
  final CardRestrictionOperation operation;
  final String cardId;
  final CardRestrictionReason reason;
  final String description;
  final String quoteToken;
  final String idempotencyKey;
  @override
  List<Object?> get props => [
    operation,
    cardId,
    reason,
    description,
    quoteToken,
    idempotencyKey,
  ];
}
