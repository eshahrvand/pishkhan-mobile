import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_cards_list.dart';

import '../domain/entities/listed_card.dart';
import 'card_feature_actions.dart';

String categoryLabel(BuildContext context, CardCategory category) =>
    switch (category) {
      CardCategory.resalat => context.l10n.cardFeatureResalat,
      CardCategory.gift => context.l10n.cardFeatureGift,
      CardCategory.virtual => context.l10n.cardsVirtual,
      CardCategory.coupon => context.l10n.cardFeatureCoupon,
      CardCategory.family => context.l10n.cardFeatureFamily,
    };
String statusLabel(BuildContext context, CardStatus status) => switch (status) {
  CardStatus.active => context.l10n.cardFeatureActive,
  CardStatus.blocked => context.l10n.cardFeatureBlocked,
  CardStatus.expired => context.l10n.cardFeatureExpired,
};
AppCardsListType listType(CardCategory category) =>
    AppCardsListType.values[category.index];
String actionLabel(
  BuildContext context,
  CardFeatureAction action,
) => switch (action) {
  CardFeatureAction.details => context.l10n.cardFeatureDetails,
  CardFeatureAction.reissue => context.l10n.cardsReissue,
  CardFeatureAction.changeDeposit => context.l10n.changeCardDeposit,
  CardFeatureAction.block => context.l10n.blockCard,
  CardFeatureAction.expiredGiftBalance => context.l10n.cardFeatureGiftTransfer,
  CardFeatureAction.requestVirtual => context.l10n.cardFeatureVirtualRequest,
};
String actionAsset(CardFeatureAction action) => switch (action) {
  CardFeatureAction.details => AppAssets.cardFeaturesInfo,
  CardFeatureAction.reissue => AppAssets.cardFeaturesReissue,
  CardFeatureAction.changeDeposit => AppAssets.cardFeaturesChangeDeposit,
  CardFeatureAction.block => AppAssets.cardFeaturesBlock,
  CardFeatureAction.expiredGiftBalance => AppAssets.cardFeaturesExpiredGift,
  CardFeatureAction.requestVirtual => AppAssets.cardFeaturesPlus,
};
Widget cardFeatureIcon(String path, {double size = 20}) => SizedBox.square(
  dimension: size,
  child: Center(child: SvgPicture.asset(path, fit: BoxFit.contain)),
);

Widget cardCategoryIcon(CardCategory category) {
  final asset = switch (category) {
    CardCategory.resalat => AppAssets.cardFeaturesResalat,
    CardCategory.gift => AppAssets.cardFeaturesGift,
    CardCategory.virtual => AppAssets.cardFeaturesVirtual,
    CardCategory.coupon => AppAssets.cardFeaturesCoupon,
    CardCategory.family => AppAssets.cardFeaturesFamily,
  };
  if (category == CardCategory.virtual) {
    return SizedBox.square(
      dimension: 20,
      child: Stack(
        children: [
          Positioned(
            left: 1.667,
            top: 3.334,
            width: 16.284,
            height: 12.95,
            child: SvgPicture.asset(asset),
          ),
        ],
      ),
    );
  }
  return Transform.rotate(
    angle: 3.141592653589793,
    child: Transform.flip(flipY: true, child: cardFeatureIcon(asset)),
  );
}
