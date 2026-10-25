part of 'card_features_cubit.dart';

@Freezed(toStringOverride: false)
abstract class CardFeaturesState with _$CardFeaturesState {
  const factory CardFeaturesState.initial({
    ListedCard? selectedCard,
    @Default(<ListedCard>[]) List<ListedCard> visibleCards,
    @Default(<String>[]) List<String> depositNumbers,
    @Default(RequestStatus.initial) RequestStatus cardsStatus,
    @Default(<ListedCard>[]) List<ListedCard> cards,
    @Default(CardCategory.resalat) CardCategory category,
    @Default('') String searchQuery,
    @Default(CardFilter()) CardFilter filter,
    CardFilter? draftFilter,
    Failure? failure,
    String? message,
    CardFeatureAction? footerAction,
    CardFeaturesEffect? effect,
  }) = _CardFeaturesState;
}
