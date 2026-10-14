import 'package:equatable/equatable.dart';

enum CardDepositKind { qarz, current }

class CardServiceDeposit extends Equatable {
  const CardServiceDeposit({
    required this.id,
    required this.number,
    this.kind = CardDepositKind.qarz,
  });
  final String id, number;
  final CardDepositKind kind;
  @override
  List<Object?> get props => [id, number, kind];
}

class ServiceBankCard extends Equatable {
  const ServiceBankCard({
    required this.id,
    required this.number,
    required this.depositId,
  });
  final String id, number, depositId;
  @override
  List<Object?> get props => [id, number, depositId];
}

class ExpiredGiftCard extends Equatable {
  const ExpiredGiftCard({
    required this.id,
    required this.number,
    required this.depositId,
    required this.balanceRial,
  });
  final String id, number, depositId;
  final int balanceRial;
  @override
  List<Object?> get props => [id, number, depositId, balanceRial];
}

class CardServiceCatalog extends Equatable {
  CardServiceCatalog({
    required Iterable<CardServiceDeposit> deposits,
    required Iterable<ServiceBankCard> cards,
    required Iterable<ExpiredGiftCard> gifts,
    required this.changeDepositFeeRial,
    required this.walletBalanceRial,
  }) : deposits = List.unmodifiable(deposits),
       cards = List.unmodifiable(cards),
       gifts = List.unmodifiable(gifts);
  final List<CardServiceDeposit> deposits;
  final List<ServiceBankCard> cards;
  final List<ExpiredGiftCard> gifts;
  final int changeDepositFeeRial, walletBalanceRial;
  @override
  List<Object?> get props => [
    deposits,
    cards,
    gifts,
    changeDepositFeeRial,
    walletBalanceRial,
  ];
}

class ChangeCardDepositRequest {
  const ChangeCardDepositRequest({
    required this.cardId,
    required this.sourceDepositId,
    required this.destinationDepositId,
    required this.idempotencyKey,
  });
  final String cardId, sourceDepositId, destinationDepositId, idempotencyKey;
}

class GiftBalanceRequest {
  GiftBalanceRequest({
    required Iterable<String> cardIds,
    required this.destinationDepositId,
    required this.idempotencyKey,
  }) : cardIds = List.unmodifiable(cardIds);
  final List<String> cardIds;
  final String destinationDepositId, idempotencyKey;
}

class CardServiceReceipt extends Equatable {
  const CardServiceReceipt({required this.reference, required this.isMock});
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}
