import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../entities/listed_card.dart';
import '../repositories/cards_repository.dart';

class LoadCards {
  const LoadCards(this.repository);
  final CardsRepository repository;
  Future<Result<List<ListedCard>>> call() async {
    try {
      final result = await repository.getCards();
      if (result is Err<List<ListedCard>>) return result;
      final cards = (result as Success<List<ListedCard>>).data;
      if (cards.any((card) => card.id.trim().isEmpty) ||
          cards.map((card) => card.id).toSet().length != cards.length) {
        return const Err(DataFailure('cards.invalid'));
      }
      return Success(List.unmodifiable(cards));
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
