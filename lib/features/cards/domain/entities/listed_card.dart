import 'package:equatable/equatable.dart';

enum CardCategory { resalat, gift, virtual, coupon, family }

enum CardStatus { active, blocked, expired }

class ListedCard extends Equatable {
  const ListedCard({
    required this.id,
    required this.category,
    required this.number,
    required this.linkedDeposit,
    required this.iban,
    required this.expiry,
    this.depositTypeKey = 'qarz',
    this.status = CardStatus.active,
  });
  final String id, number, linkedDeposit, iban, expiry, depositTypeKey;
  final CardCategory category;
  final CardStatus status;
  @override
  List<Object?> get props => [
    id,
    category,
    number,
    linkedDeposit,
    iban,
    expiry,
    depositTypeKey,
    status,
  ];
}
