import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/listed_card.dart';
import '../../../domain/entities/card_filter.dart';
export '../../../domain/entities/card_filter.dart';

part 'card_features_state.freezed.dart';

@freezed
abstract class CardFeaturesState with _$CardFeaturesState {
  const factory CardFeaturesState({
    ListedCard? selectedCard,
    @Default(<ListedCard>[]) List<ListedCard> visibleCards,
    @Default(<String>[]) List<String> deposits,
    @Default(RequestStatus.initial) RequestStatus status,
    List<ListedCard>? cards,
    @Default(CardCategory.resalat) CardCategory category,
    @Default('') String query,
    @Default(CardFilter()) CardFilter filter,
    CardFilter? draftFilter,
    String? selectedId,
    Failure? failure,
  }) = _CardFeaturesState;
}
