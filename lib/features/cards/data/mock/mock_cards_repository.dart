import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/listed_card.dart';
import '../../domain/repositories/cards_repository.dart';

class MockCardsRepository implements CardsRepository {
  MockCardsRepository({Iterable<ListedCard>? cards})
    : cards = List.unmodifiable(cards ?? examples);
  final List<ListedCard> cards;
  static final List<ListedCard> examples = List.unmodifiable([
    for (final category in CardCategory.values)
      for (
        var i = 0;
        i <
            (category == CardCategory.coupon || category == CardCategory.family
                ? 2
                : 4);
        i++
      )
        ListedCard(
          id: '${category.name}-$i',
          category: category,
          number: '5041721456783407',
          linkedDeposit: i == 3 ? '10-1234567-2' : '10-122-1234567-1',
          iban: 'IR500700000010051234567890',
          expiry: '۱۴۰۶/۱۱/۱۷',
          status: i == 3 ? CardStatus.blocked : CardStatus.active,
        ),
  ]);
  @override
  Future<Result<List<ListedCard>>> getCards() async => Success(cards);
}
