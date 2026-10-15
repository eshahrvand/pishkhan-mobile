import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_cards_list.dart';

import '../../../domain/entities/listed_card.dart';
import 'card_feature_actions.dart';

String categoryLabel(BuildContext context, CardCategory category) =>
    switch (category) {
      CardCategory.resalat => S.current.cardFeatureResalat,
      CardCategory.gift => S.current.cardFeatureGift,
      CardCategory.virtual => S.current.cardsVirtual,
      CardCategory.coupon => S.current.cardFeatureCoupon,
      CardCategory.family => S.current.cardFeatureFamily,
    };
String statusLabel(BuildContext context, CardStatus status) => switch (status) {
  CardStatus.active => S.current.cardFeatureActive,
  CardStatus.blocked => S.current.cardFeatureBlocked,
  CardStatus.expired => S.current.cardFeatureExpired,
};
AppCardsListType listType(CardCategory category) =>
    AppCardsListType.values[category.index];
String actionLabel(BuildContext context, CardFeatureAction action) =>
    switch (action) {
      CardFeatureAction.details => S.current.cardFeatureDetails,
      CardFeatureAction.reissue => S.current.cardsReissue,
      CardFeatureAction.changeDeposit => S.current.changeCardDeposit,
      CardFeatureAction.block => S.current.blockCard,
      CardFeatureAction.expiredGiftBalance => S.current.cardFeatureGiftTransfer,
      CardFeatureAction.requestVirtual => S.current.cardFeatureVirtualRequest,
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
  child: Center(
    child: AvpImage(image: path, fit: BoxFit.contain),
  ),
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
            child: AvpImage(image: asset),
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
