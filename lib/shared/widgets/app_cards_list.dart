import 'package:pishkhan_mobile/core/config/constant.dart';

import 'app_cards_list_header.dart';
import 'app_cards_list_detail_row.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Figma CardsList variants.
enum AppCardsListType { resalat, gift, virtual, coupon, family }

/// Local Figma SVG assets used by [AppCardsList].
abstract final class AppCardsListIcons {
  static Widget moreHorizontal() => Transform.rotate(
    angle: -math.pi / 2,
    child: _svg('${AppConstants.baseImage}icon_more_vertical_20_gray700.svg'),
  );

  static Widget divider() => SizedBox(
    height: .5,
    width: double.infinity,
    child: AvpImage(
      image: '${AppConstants.baseImage}divider_card_gray200.svg',
      fit: BoxFit.fill,
    ),
  );

  static Widget forType(AppCardsListType type) {
    if (type == AppCardsListType.virtual) {
      return SizedBox(
        width: 20,
        height: 20,
        child: Center(
          child: SizedBox(
            width: 16.284,
            height: 12.95,
            child: AvpImage(
              image: '${AppConstants.baseImage}cards_list_virtual_card.svg',
            ),
          ),
        ),
      );
    }

    final path = switch (type) {
      AppCardsListType.resalat =>
        '${AppConstants.baseImage}cards_list_credit_card.svg',
      AppCardsListType.gift =>
        '${AppConstants.baseImage}cards_list_gift_card.svg',
      AppCardsListType.coupon =>
        '${AppConstants.baseImage}cards_list_coupon.svg',
      AppCardsListType.family =>
        '${AppConstants.baseImage}cards_list_family.svg',
      AppCardsListType.virtual => throw StateError('Handled above.'),
    };
    return Transform.rotate(
      angle: math.pi,
      child: Transform.flip(flipY: true, child: _svg(path)),
    );
  }

  static Widget _svg(String path) => SizedBox(
    width: 20,
    height: 20,
    child: AvpImage(image: path, fit: BoxFit.contain),
  );
}

/// App-owned, Figma-aligned card-list row with five supported card types.
class AppCardsList extends StatelessWidget {
  const AppCardsList({
    super.key,
    required this.type,
    required this.cardNumber,
    required this.linkedDeposit,
    this.title,
    this.moreIcon,
    this.cardIcon,
    this.onMoreTap,
    this.coloredHeader = false,
    this.cardNumberLabel = 'شماره کارت',
    this.linkedDepositLabel = 'سپرده متصل',
  });

  final AppCardsListType type;
  final String cardNumber;
  final String linkedDeposit;
  final String? title;
  final Widget? moreIcon;
  final Widget? cardIcon;
  final VoidCallback? onMoreTap;
  final bool coloredHeader;
  final String cardNumberLabel, linkedDepositLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: coloredHeader ? colors.surface : colors.surfaceSubtle,
          borderRadius: AppRadius.borderMd,
          boxShadow: coloredHeader ? AppShadows.cardList : AppShadows.sm,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: coloredHeader
                ? const EdgeInsets.fromLTRB(8, 8, 8, 12)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCardsListHeader(
                  cardIcon: cardIcon,
                  coloredHeader: coloredHeader,
                  moreIcon: moreIcon,
                  onMoreTap: onMoreTap,
                  title: title,
                  type: type,
                ),
                const SizedBox(height: 8),
                if (!coloredHeader) ...[
                  AppCardsListIcons.divider(),
                  const SizedBox(height: 8),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: coloredHeader ? 8 : 0,
                  ),
                  child: Column(
                    children: [
                      AppCardsListDetailRow(
                        value: cardNumber,
                        label: cardNumberLabel,
                        coloredHeader: coloredHeader,
                      ),
                      const SizedBox(height: 8),
                      AppCardsListDetailRow(
                        value: linkedDeposit,
                        label: linkedDepositLabel,
                        coloredHeader: coloredHeader,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
