import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma CardsList variants.
enum AppCardsListType { resalat, gift, virtual, coupon, family }

/// Local Figma SVG assets used by [AppCardsList].
abstract final class AppCardsListIcons {
  static const _basePath = 'assets/images/cards_list/';

  static Widget moreHorizontal() =>
      Transform.rotate(angle: -math.pi / 2, child: _svg('more_horizontal.svg'));

  static Widget divider() => SizedBox(
    height: .5,
    width: double.infinity,
    child: SvgPicture.asset('${_basePath}divider.svg', fit: BoxFit.fill),
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
            child: SvgPicture.asset('${_basePath}virtual_card.svg'),
          ),
        ),
      );
    }

    final name = switch (type) {
      AppCardsListType.resalat => 'credit_card.svg',
      AppCardsListType.gift => 'gift_card.svg',
      AppCardsListType.coupon => 'coupon.svg',
      AppCardsListType.family => 'family.svg',
      AppCardsListType.virtual => throw StateError('Handled above.'),
    };
    return Transform.rotate(
      angle: math.pi,
      child: Transform.flip(flipY: true, child: _svg(name)),
    );
  }

  static Widget _svg(String name) => SizedBox(
    width: 20,
    height: 20,
    child: SvgPicture.asset('$_basePath$name', fit: BoxFit.contain),
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
  });

  final AppCardsListType type;
  final String cardNumber;
  final String linkedDeposit;
  final String? title;
  final Widget? moreIcon;
  final Widget? cardIcon;
  final VoidCallback? onMoreTap;

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
          color: colors.surfaceSubtle,
          borderRadius: AppRadius.borderMd,
          boxShadow: AppShadows.sm,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context),
                const SizedBox(height: 8),
                AppCardsListIcons.divider(),
                const SizedBox(height: 8),
                _detailRow(context, value: cardNumber, label: 'شماره کارت'),
                const SizedBox(height: 8),
                _detailRow(context, value: linkedDeposit, label: 'سپرده متصل'),
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
    return SizedBox(
      height: 20,
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
          const Spacer(),
          Flexible(
            child: Text(
              _title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: _mediumStyle(context.colors.textPrimary),
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
        Text(label, style: _regularStyle(context.colors.textSecondary)),
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
