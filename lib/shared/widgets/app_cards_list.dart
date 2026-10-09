import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Figma CardsList variants.
enum AppCardsListType { resalat, gift, virtual, coupon, family }

/// Local Figma SVG assets used by [AppCardsList].
abstract final class AppCardsListIcons {
  static Widget moreHorizontal() => Transform.rotate(
    angle: -math.pi / 2,
    child: _svg(AppAssets.iconMoreVertical20Gray700),
  );

  static Widget divider() => SizedBox(
    height: .5,
    width: double.infinity,
    child: SvgPicture.asset(AppAssets.dividerCardGray200, fit: BoxFit.fill),
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
            child: SvgPicture.asset(AppAssets.cardsListVirtualCard),
          ),
        ),
      );
    }

    final path = switch (type) {
      AppCardsListType.resalat => AppAssets.cardsListCreditCard,
      AppCardsListType.gift => AppAssets.cardsListGiftCard,
      AppCardsListType.coupon => AppAssets.cardsListCoupon,
      AppCardsListType.family => AppAssets.cardsListFamily,
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
    child: SvgPicture.asset(path, fit: BoxFit.contain),
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

  String get _title =>
      title ??
      switch (type) {
        AppCardsListType.resalat => 'رسالت کارت',
        AppCardsListType.gift => 'کارت هدیه',
        AppCardsListType.virtual => 'کارت مجازی',
        AppCardsListType.coupon => 'بن کارت',
        AppCardsListType.family => 'کارت خانواده',
      };

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
                _header(context),
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
                      _detailRow(
                        context,
                        value: cardNumber,
                        label: cardNumberLabel,
                      ),
                      const SizedBox(height: 8),
                      _detailRow(
                        context,
                        value: linkedDeposit,
                        label: linkedDepositLabel,
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

  Widget _header(BuildContext context) {
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
            Expanded(child: _titleText(context))
          else
            Flexible(child: _titleText(context)),
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

  Widget _titleText(BuildContext context) => Text(
    _title,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: coloredHeader ? TextAlign.right : TextAlign.end,
    style: _mediumStyle(context.colors.textPrimary),
  );

  Widget _detailRow(
    BuildContext context, {
    required String value,
    required String label,
  }) => SizedBox(
    height: 22,
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: _mediumStyle(context.colors.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: _regularStyle(
            coloredHeader
                ? context.colors.textTertiary
                : context.colors.textSecondary,
          ),
        ),
      ],
    ),
  );

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle _mediumStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
