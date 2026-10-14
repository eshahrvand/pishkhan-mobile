import 'package:equatable/equatable.dart';

import 'listed_card.dart';

class CardFilter extends Equatable {
  const CardFilter({this.status, this.deposit})
    : isActive = status != null || deposit != null;
  final CardStatus? status;
  final String? deposit;
  final bool isActive;
  bool matches(ListedCard card) =>
      (status == null || card.status == status) &&
      (deposit == null || card.linkedDeposit == deposit);
  @override
  List<Object?> get props => [status, deposit];
}
