import 'package:pishkhan_mobile/core/config/constant.dart';

import 'app_resalat_card_security_details.dart';
import 'app_resalat_card_asset_action.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

enum AppResalatCardSize { single, multi }

/// Figma-aligned Resalat bank card with controlled visibility state.
class AppResalatCard extends StatelessWidget {
  const AppResalatCard({
    super.key,
    this.cardType = 'رسالت کارت (جاری)',
    this.cardNumberParts = const ['1234', '1234', '1234', '1234'],
    this.iban = 'IR۵۵۰۷۰۰۰۱۰۰۰۱۱۱۲۰۰۳۷۶۱۰۰۱',
    this.expiry = '**/**',
    this.cvv2 = '****',
    this.size = AppResalatCardSize.single,
    this.width,
    this.expiryLabel = ': انقضا',
    this.visibilityLabel,
    this.moreLabel,
    this.copyNumberLabel,
    this.copyIbanLabel,
    this.isVisible = true,
    this.isSelected = true,
    this.onMorePressed,
    this.onCopyCardNumber,
    this.onCopyIban,
    this.onVisibilityChanged,
  });

  final String cardType;
  final List<String> cardNumberParts;
  final String iban;
  final String expiry;
  final String cvv2;
  final AppResalatCardSize size;
  final double? width;
  final String expiryLabel;
  final String? visibilityLabel, moreLabel, copyNumberLabel, copyIbanLabel;
  final bool isVisible;
  final bool isSelected;
  final VoidCallback? onMorePressed;
  final VoidCallback? onCopyCardNumber;
  final VoidCallback? onCopyIban;
  final ValueChanged<bool>? onVisibilityChanged;

  bool get _isSingle => size == AppResalatCardSize.single;

  @override
  Widget build(BuildContext context) {
    assert(
      cardNumberParts.length == 4,
      'AppResalatCard requires exactly four card-number parts.',
    );
    final card = Container(
      key: const Key('app_resalat_card'),
      width: width ?? (_isSingle ? 335 : 316),
      height:
          (_isSingle ? 202 : 191) +
          math.max(0, MediaQuery.textScalerOf(context).scale(1) - 1) * 50,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: AppGradients.fromAngle(
          angleInDegrees: _isSingle ? -58.86308919844143 : -58.92376501651299,
          colors: [AppPalette.brand500, AppPalette.brand800],
          stops: const [.0077394, .97863],
        ),
        border: Border.all(color: AppPalette.white),
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.bankCard,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppResalatCardAssetAction(
                path: '${AppConstants.baseImage}resalat_card_more_vertical.svg',
                label: moreLabel,
                size: 24,
                onTap: onMorePressed,
                contentKey: const Key('app_resalat_card_more'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IntrinsicWidth(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppPalette.warning400,
                        borderRadius: AppRadius.borderXs,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          cardType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppPalette.brand700,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 16 / 10,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    children: [
                      Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          for (
                            var index = 0;
                            index < cardNumberParts.length;
                            index++
                          ) ...[
                            if (index > 0) const SizedBox(width: 20),
                            Text(
                              cardNumberParts[index],
                              style: _cardNumberStyle,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(width: 8),
                      AppResalatCardAssetAction(
                        path: '${AppConstants.baseImage}icon_copy_16_white.svg',
                        size: 16,
                        onTap: onCopyCardNumber,
                        label: copyNumberLabel,
                        contentKey: const Key('app_resalat_card_copy_number'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.ltr,
                children: [
                  Flexible(
                    child: Text(
                      iban,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: _detailStyle(fontSize: 14, height: 20 / 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppResalatCardAssetAction(
                    path: '${AppConstants.baseImage}icon_copy_16_white.svg',
                    size: 16,
                    onTap: onCopyIban,
                    label: copyIbanLabel,
                    contentKey: const Key('app_resalat_card_copy_iban'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppResalatCardSecurityDetails(
                cvv2: cvv2,
                expiry: expiry,
                expiryLabel: expiryLabel,
                isVisible: isVisible,
                onVisibilityChanged: onVisibilityChanged,
                size: size,
                visibilityLabel: visibilityLabel,
              ),
            ],
          ),
        ],
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          if (!isSelected)
            Positioned.fill(
              child: AbsorbPointer(
                child: DecoratedBox(
                  key: const Key('app_resalat_card_disabled_overlay'),
                  decoration: BoxDecoration(
                    color: const Color(0x66D9D9D9),
                    borderRadius: AppRadius.borderLg,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  TextStyle get _cardNumberStyle => AppTypography.titleMedium.copyWith(
    color: AppPalette.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: 0,
  );

  TextStyle _detailStyle({double fontSize = 12, double height = 18 / 12}) =>
      AppTypography.bodySmall.copyWith(
        color: AppPalette.brand100,
        fontSize: fontSize,
        height: height,
        letterSpacing: 0,
      );
}
