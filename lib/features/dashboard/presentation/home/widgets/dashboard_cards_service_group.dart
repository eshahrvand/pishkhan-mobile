import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
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
      headerAction: quick
          ? AvpImage(image: '${AppConstants.baseImage}cards_quick_access.svg')
          : null,
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
  CardAction.list => '${AppConstants.baseImage}cards_list_credit_card.svg',
  CardAction.virtualList =>
    '${AppConstants.baseImage}cards_list_virtual_card.svg',
  CardAction.reissue => '${AppConstants.baseImage}cards_action_reissue.svg',
  CardAction.changeDeposit =>
    '${AppConstants.baseImage}cards_action_deposit.svg',
  CardAction.block => '${AppConstants.baseImage}cards_action_block.svg',
  CardAction.changeFirstPin =>
    '${AppConstants.baseImage}cards_action_change_first.svg',
  CardAction.setSecondPin =>
    '${AppConstants.baseImage}cards_action_set_second.svg',
  CardAction.changeSecondPin =>
    '${AppConstants.baseImage}cards_action_set_second.svg',
  CardAction.forgotFirstPin =>
    '${AppConstants.baseImage}cards_action_forgot_first.svg',
  CardAction.forgotSecondPin =>
    '${AppConstants.baseImage}cards_action_forgot_second.svg',
  CardAction.issue => '${AppConstants.baseImage}cards_quick_issue.svg',
  CardAction.virtualCard => '${AppConstants.baseImage}cards_quick_virtual.svg',
  CardAction.giftPurchase =>
    '${AppConstants.baseImage}cards_quick_gift_buy.svg',
  CardAction.giftBalance =>
    '${AppConstants.baseImage}cards_quick_gift_balance.svg',
};
