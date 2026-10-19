import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_artwork_tile.dart';

import '../../shared/card_actions.dart';
export '../../shared/card_actions.dart';

/// Second primary tab. Service execution and card fetching belong to the caller.
class DashboardCardsServiceGroup extends StatelessWidget {
  const DashboardCardsServiceGroup({
    super.key,
    required this.title,
    required this.actions,
    required this.onActionRequested,
    this.quick = false,
  });
  final String title;
  final List<CardAction> actions;
  final ValueChanged<CardAction> onActionRequested;
  final bool quick;
  @override
  Widget build(BuildContext context) {
    return AppServiceGridCard(
      title: title,
      itemSpacing: 6,
      stretchItems: false,
      titleColor: quick
          ? AppDashboardColors.sectionText
          : AppDashboardColors.serviceText,
      type: quick
          ? AppServiceGridCardType.quick
          : AppServiceGridCardType.service,
      headerAction: quick ? AvpImage(image: AppAssets.cardsQuickAccess) : null,
      items: [
        for (final action in actions)
          AppServiceGridItem(
            id: action.id,
            label: getCardActionLabel(action),
            onTap: () => onActionRequested(action),
            iconSize: Size.square(quick ? 64 : 32),
            icon: quick
                ? AppServiceArtworkTile(asset: getCardActionAsset(action))
                : AvpImage(image: getCardActionAsset(action)),
          ),
      ],
    );
  }
}

String getCardActionLabel(CardAction action) => switch (action) {
  CardAction.list => S.current.dashboardCardsList,
  CardAction.virtualList => S.current.cardsVirtual,
  CardAction.reissue => S.current.cardsReissue,
  CardAction.changeDeposit => S.current.changeCardDeposit,
  CardAction.block => S.current.blockCard,
  CardAction.changeFirstPin => S.current.cardsChangeFirst,
  CardAction.setSecondPin => S.current.cardsSetSecond,
  CardAction.changeSecondPin => S.current.passwordChange,
  CardAction.forgotFirstPin => S.current.cardsForgotFirst,
  CardAction.forgotSecondPin => S.current.cardsForgotSecond,
  CardAction.issue => S.current.issueResalatCard,
  CardAction.virtualCard => S.current.dashboardVirtualCard,
  CardAction.giftPurchase => S.current.cardsBuyGift,
  CardAction.giftBalance => S.current.dashboardExpiredGift,
};
String getCardActionAsset(CardAction action) => switch (action) {
  CardAction.list => AppAssets.cardsListCreditCard,
  CardAction.virtualList => AppAssets.cardsListVirtualCard,
  CardAction.reissue => AppAssets.cardsActionReissue,
  CardAction.changeDeposit => AppAssets.cardsActionDeposit,
  CardAction.block => AppAssets.cardsActionBlock,
  CardAction.changeFirstPin => AppAssets.cardsActionChangeFirst,
  CardAction.setSecondPin => AppAssets.cardsActionSetSecond,
  CardAction.changeSecondPin => AppAssets.cardsActionSetSecond,
  CardAction.forgotFirstPin => AppAssets.cardsActionForgotFirst,
  CardAction.forgotSecondPin => AppAssets.cardsActionForgotSecond,
  CardAction.issue => AppAssets.cardsQuickIssue,
  CardAction.virtualCard => AppAssets.cardsQuickVirtual,
  CardAction.giftPurchase => AppAssets.cardsQuickGiftBuy,
  CardAction.giftBalance => AppAssets.cardsQuickGiftBalance,
};
