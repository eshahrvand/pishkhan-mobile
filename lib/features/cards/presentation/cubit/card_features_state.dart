import 'package:equatable/equatable.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../domain/entities/listed_card.dart';

class CardFilter extends Equatable {
  const CardFilter({this.status, this.deposit});
  final CardStatus? status;
  final String? deposit;
  bool get isActive => status != null || deposit != null;
  bool matches(ListedCard card) =>
      (status == null || card.status == status) &&
      (deposit == null || card.linkedDeposit == deposit);
  @override
  List<Object?> get props => [status, deposit];
}

enum CardsLoadStatus { initial, loading, loaded, empty, error }

class CardFeaturesState extends Equatable {
  CardFeaturesState({
    this.status = CardsLoadStatus.initial,
    Iterable<ListedCard> cards = const [],
    this.category = CardCategory.resalat,
    this.query = '',
    this.filter = const CardFilter(),
    this.draftFilter,
    this.selectedId,
    this.failure,
  }) : cards = List.unmodifiable(cards);
  final CardsLoadStatus status;
  final List<ListedCard> cards;
  final CardCategory category;
  final String query;
  final CardFilter filter;
  final CardFilter? draftFilter;
  final String? selectedId;
  final Failure? failure;
  ListedCard? get selected {
    for (final card in cards) {
      if (card.id == selectedId) return card;
    }
    return null;
  }

  List<ListedCard> get visibleCards => List.unmodifiable(
    cards.where(
      (card) =>
          card.category == category &&
          filter.matches(card) &&
          (normalizeCardQuery(card.number)
                  .contains(normalizeCardQuery(query)) ||
              normalizeCardQuery(card.linkedDeposit)
                  .contains(normalizeCardQuery(query))),
    ),
  );
  List<String> get deposits =>
      cards.map((card) => card.linkedDeposit).toSet().toList()..sort();
  CardFeaturesState copyWith({
    CardsLoadStatus? status,
    Iterable<ListedCard>? cards,
    CardCategory? category,
    String? query,
    CardFilter? filter,
    CardFilter? draftFilter,
    bool clearDraft = false,
    String? selectedId,
    bool clearSelection = false,
    Failure? failure,
    bool clearFailure = false,
  }) => CardFeaturesState(
    status: status ?? this.status,
    cards: cards ?? this.cards,
    category: category ?? this.category,
    query: query ?? this.query,
    filter: filter ?? this.filter,
    draftFilter: clearDraft ? null : draftFilter ?? this.draftFilter,
    selectedId: clearSelection ? null : selectedId ?? this.selectedId,
    failure: clearFailure ? null : failure ?? this.failure,
  );
  @override
  List<Object?> get props => [
    status,
    cards,
    category,
    query,
    filter,
    draftFilter,
    selectedId,
    failure,
  ];
}

/// Normalize Persian/Arabic digits and separators without changing copied values.
String normalizeCardQuery(String input) {
  const persian = '۰۱۲۳۴۵۶۷۸۹', arabic = '٠١٢٣٤٥٦٧٨٩';
  var value = input;
  for (var i = 0; i < 10; i++) {
    value = value.replaceAll(persian[i], '$i').replaceAll(arabic[i], '$i');
  }
  return value.replaceAll(RegExp(r'[\s\-\.\u200c]'), '').toLowerCase();
}
