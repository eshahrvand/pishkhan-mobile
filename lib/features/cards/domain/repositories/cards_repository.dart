import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/listed_card.dart';

abstract interface class CardsRepository {
  Future<Result<List<ListedCard>>> getCards();
}
