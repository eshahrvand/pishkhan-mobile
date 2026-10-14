
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_cards_list.dart';

class AppCardsListTitleText extends StatelessWidget {
  const AppCardsListTitleText({
    super.key,
    required this.coloredHeader,
    required this.title,
    required this.type,
  });
  final bool coloredHeader;
  final String? title;
  final AppCardsListType type;

  @override
  Widget build(BuildContext context) {
    return Text(
      _title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: coloredHeader ? TextAlign.right : TextAlign.end,
      style: _mediumStyle(context.colors.textPrimary),
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
