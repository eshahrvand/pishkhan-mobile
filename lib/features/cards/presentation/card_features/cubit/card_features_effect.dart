import '../../../domain/entities/listed_card.dart';
import '../card_feature_action.dart';

sealed class CardFeaturesEffect {
  const CardFeaturesEffect();
}

final class CardCategoryRevealRequested extends CardFeaturesEffect {
  const CardCategoryRevealRequested(this.category, {required this.scrollToEnd});
  final CardCategory category;
  final bool scrollToEnd;
}

final class CardActionsRequested extends CardFeaturesEffect {
  const CardActionsRequested(this.card);
  final ListedCard card;
}

final class CardDetailsRequested extends CardFeaturesEffect {
  const CardDetailsRequested(this.card);
  final ListedCard card;
}

final class CardServiceRequested extends CardFeaturesEffect {
  const CardServiceRequested(this.request, {this.serviceId});
  final CardFeatureRequest request;
  final String? serviceId;
}

final class CardFilterRequested extends CardFeaturesEffect {
  const CardFilterRequested();
}
