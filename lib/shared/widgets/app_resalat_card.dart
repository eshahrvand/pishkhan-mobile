import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
      width: _isSingle ? 335 : 316,
      height: _isSingle ? 202 : 191,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [AppPalette.brand500, AppPalette.brand800],
        ),
        border: Border.all(color: AppPalette.white),
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _header(),
          Column(
            children: [
              _cardNumber(),
              const SizedBox(height: 16),
              _iban(),
              const SizedBox(height: 16),
              _securityDetails(),
            ],
          ),
        ],
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
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

  Widget _header() => Row(
    textDirection: TextDirection.ltr,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _assetAction(
        path: AppAssets.resalatCardMoreVertical,
        size: 24,
        onTap: onMorePressed,
        key: const Key('app_resalat_card_more'),
      ),
      const Spacer(),
      DecoratedBox(
        decoration: const BoxDecoration(
          color: AppPalette.warning400,
          borderRadius: AppRadius.borderXs,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            cardType,
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
    ],
  );

  Widget _cardNumber() => SizedBox(
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
              for (var index = 0; index < cardNumberParts.length; index++) ...[
                if (index > 0) const SizedBox(width: 20),
                Text(cardNumberParts[index], style: _cardNumberStyle),
              ],
            ],
          ),
          const SizedBox(width: 8),
          _assetAction(
            path: AppAssets.iconCopy16White,
            size: 16,
            onTap: onCopyCardNumber,
            key: const Key('app_resalat_card_copy_number'),
          ),
        ],
      ),
    ),
  );

  Widget _iban() => Row(
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
      _assetAction(
        path: AppAssets.iconCopy16White,
        size: 16,
        onTap: onCopyIban,
        key: const Key('app_resalat_card_copy_iban'),
      ),
    ],
  );

  Widget _securityDetails() => Row(
    textDirection: TextDirection.ltr,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(
        width: 80,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'انقضا: '),
              TextSpan(
                text: expiry,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          maxLines: 1,
          textDirection: TextDirection.rtl,
          style: _detailStyle(),
        ),
      ),
      SizedBox(
        width: 80,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'CVV2: '),
              TextSpan(
                text: cvv2,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          style: _detailStyle(),
        ),
      ),
      SizedBox(
        width: 64,
        child: Align(
          alignment: Alignment.centerRight,
          child: _assetAction(
            path: isVisible
                ? AppAssets.resalatCardEye
                : AppAssets.resalatCardEyeSlash,
            size: 20,
            onTap: onVisibilityChanged == null
                ? null
                : () => onVisibilityChanged!(!isVisible),
            key: const Key('app_resalat_card_visibility'),
          ),
        ),
      ),
    ],
  );

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

  Widget _assetAction({
    required String path,
    required double size,
    required VoidCallback? onTap,
    required Key key,
  }) {
    final icon = SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(path, fit: BoxFit.contain),
    );
    return onTap == null
        ? KeyedSubtree(key: key, child: icon)
        : InkWell(key: key, onTap: onTap, child: icon);
  }
}
