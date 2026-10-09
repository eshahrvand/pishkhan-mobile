import 'dart:async';

import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cards/cards.dart';
import 'package:pishkhan_mobile/features/cards/data/mock/mock_cards_repository.dart';

class FakeCardsRepository implements CardsRepository {
  Result<List<ListedCard>> result = Success(MockCardsRepository.examples);
  final queue = <Completer<Result<List<ListedCard>>>>[];
  bool throws = false;
  @override
  Future<Result<List<ListedCard>>> getCards() async {
    if (throws) throw StateError('transport');
    return queue.isEmpty ? result : await queue.removeAt(0).future;
  }
}
