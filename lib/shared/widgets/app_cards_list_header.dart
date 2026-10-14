
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_cards_list.dart';
import 'app_cards_list_title_text.dart';

class AppCardsListHeader extends StatelessWidget {
  const AppCardsListHeader({
    super.key,
    required this.cardIcon,
    required this.coloredHeader,
    required this.moreIcon,
    required this.onMoreTap,
    required this.title,
    required this.type,
  });
  final Widget? cardIcon;
  final bool coloredHeader;
  final Widget? moreIcon;
  final VoidCallback? onMoreTap;
  final String? title;
  final AppCardsListType type;

  @override
  Widget build(BuildContext context) {
    final more = SizedBox(
      width: 20,
      height: 20,
      child: Center(child: moreIcon ?? AppCardsListIcons.moreHorizontal()),
    );
    return Container(
      height: coloredHeader ? 36 : 20,
      padding: coloredHeader ? const EdgeInsets.all(8) : EdgeInsets.zero,
      decoration: coloredHeader
          ? BoxDecoration(
              borderRadius: AppRadius.borderSm,
              color: switch (type) {
                AppCardsListType.resalat => AppCardFeatureColors.resalatHeader,
                AppCardsListType.gift => AppCardFeatureColors.giftHeader,
                AppCardsListType.virtual => AppCardFeatureColors.virtualHeader,
                AppCardsListType.coupon => AppCardFeatureColors.couponHeader,
                AppCardsListType.family => AppCardFeatureColors.familyHeader,
              },
            )
          : null,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          onMoreTap == null
              ? more
              : InkWell(
                  onTap: onMoreTap,
                  borderRadius: AppRadius.borderXs,
                  child: more,
                ),
          if (!coloredHeader) const Spacer(),
          if (coloredHeader)
            Expanded(
              child: AppCardsListTitleText(
                coloredHeader: coloredHeader,
                title: title,
                type: type,
              ),
            )
          else
            Flexible(
              child: AppCardsListTitleText(
                coloredHeader: coloredHeader,
                title: title,
                type: type,
              ),
            ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            height: 20,
            child: Center(child: cardIcon ?? AppCardsListIcons.forType(type)),
          ),
        ],
      ),
    );
  }

  TextStyle _mediumStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );
  String get _title =>
      title ??
      switch (type) {
        AppCardsListType.resalat => 'رسالت کارت',
        AppCardsListType.gift => 'کارت هدیه',
        AppCardsListType.virtual => 'کارت مجازی',
        AppCardsListType.coupon => 'بن کارت',
        AppCardsListType.family => 'کارت خانواده',
      };
}
