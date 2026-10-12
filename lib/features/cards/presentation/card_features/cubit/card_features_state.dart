import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/listed_card.dart';

part 'card_features_state.freezed.dart';

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

@freezed
abstract class CardFeaturesState with _$CardFeaturesState {
  const factory CardFeaturesState({
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
