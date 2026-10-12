import 'card_features_state.dart';
import '../../../domain/entities/listed_card.dart';

ListedCard? cardFeaturesSelected(CardFeaturesState state) {
  for (final card in (state.cards ?? const <ListedCard>[])) {
    if (card.id == state.selectedId) return card;
  }
  return null;
}

List<ListedCard> cardFeaturesVisibleCards(CardFeaturesState state) =>
    List.unmodifiable(
      (state.cards ?? const <ListedCard>[]).where(
        (card) =>
            card.category == state.category &&
            state.filter.matches(card) &&
            (normalizeCardQuery(card.number)
                    .contains(normalizeCardQuery(state.query)) ||
                normalizeCardQuery(card.linkedDeposit)
                    .contains(normalizeCardQuery(state.query))),
      ),
    );

List<String> cardFeaturesDeposits(CardFeaturesState state) =>
    (state.cards ?? const <ListedCard>[])
        .map((card) => card.linkedDeposit)
        .toSet()
        .toList()
      ..sort();

/// Normalize Persian/Arabic digits and separators without changing copied values.
String normalizeCardQuery(String input) {
  const persian = '۰۱۲۳۴۵۶۷۸۹', arabic = '٠١٢٣٤٥٦٧٨٩';
  var value = input;
  for (var i = 0; i < 10; i++) {
    value = value.replaceAll(persian[i], '$i').replaceAll(arabic[i], '$i');
  }
  return value.replaceAll(RegExp(r'[\s\-\.\u200c]'), '').toLowerCase();
}
