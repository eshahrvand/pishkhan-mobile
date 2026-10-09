import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';

enum CardAction {
  reissue('card-reissue'),
  changeDeposit('card-deposit'),
  block('card-block'),
  changeFirstPin('card-pin-first-change'),
  setSecondPin('card-pin-second-set'),
  forgotFirstPin('card-pin-first-forgot'),
  forgotSecondPin('card-pin-second-forgot'),
  issue('card-issue'),
  virtualCard('card-virtual'),
  giftPurchase('card-gift-purchase'),
  giftBalance('card-gift-balance');

  const CardAction(this.id);
  final String id;
}

class CardActionRequest {
  const CardActionRequest({required this.action, required this.card});
  final CardAction action;
  final BankCard card;
}
