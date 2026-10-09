import '../domain/entities/listed_card.dart';

enum CardFeatureAction {
  details,
  reissue,
  changeDeposit,
  block,
  expiredGiftBalance,
  requestVirtual,
}

class CardFeatureRequest {
  const CardFeatureRequest({
    required this.action,
    this.card,
    required this.category,
  });
  final CardFeatureAction action;
  final ListedCard? card;
  final CardCategory category;
}
