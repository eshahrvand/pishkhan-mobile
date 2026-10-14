import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

enum AppDepositCardSize { single, multi }

/// Figma-aligned deposit card for single and carousel layouts.
class AppDepositCard extends StatelessWidget {
  const AppDepositCard({
    super.key,
    this.cardType = 'جاری حقیقی',
    this.depositNumber = '۱۰.۱۲۰۰۳۴۵۶.۱',
    this.iban = 'IR۵۵۰۷۰۰۰۱۰۰۰۱۱۱۲۰۰۳۷۶۱۰۰۱',
    this.openingDate = '۱۴۰۳/۰۶/۲۴',
    this.size = AppDepositCardSize.single,
    this.isSelected = true,
    this.showLogo = true,
    this.logo,
    this.onCopyDepositNumber,
    this.onCopyIban,
  });

  final String cardType;
  final String depositNumber;
  final String iban;
  final String openingDate;
  final AppDepositCardSize size;
  final bool isSelected;
  final bool showLogo;
  final Widget? logo;
  final VoidCallback? onCopyDepositNumber;
  final VoidCallback? onCopyIban;

  bool get _isSingle => size == AppDepositCardSize.single;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      key: const Key('app_deposit_card'),
      width: _isSingle ? 335 : 316,
      height: _isSingle ? 202 : 191,
      padding: EdgeInsets.all(_isSingle ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          // The light stop is a component-specific Figma color without an
          // avp_ui palette token; the dark stop is Purple/800.
          colors: [Color(0xFF7D55D6), AppPalette.purple800],
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
              _dataRow(
                value: depositNumber,
                label: 'شماره سپرده:',
                onCopy: onCopyDepositNumber,
                copyKey: const Key('app_deposit_card_copy_number'),
              ),
              SizedBox(height: _isSingle ? 20 : 16),
              _dataRow(
                value: iban,
                label: 'شماره شبا:',
                onCopy: onCopyIban,
                copyKey: const Key('app_deposit_card_copy_iban'),
              ),
              SizedBox(height: _isSingle ? 20 : 16),
              _plainRow(value: openingDate, label: 'تاریخ افتتاح:'),
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
                  key: const Key('app_deposit_card_disabled_overlay'),
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
      if (showLogo)
        SizedBox.square(
          dimension: 24,
          child:
              logo ??
              SvgPicture.asset(
                AppAssets.depositCardResalatLogo,
                fit: BoxFit.contain,
              ),
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
              color: AppPalette.purple700,
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

  Widget _dataRow({
    required String value,
    required String label,
    required VoidCallback? onCopy,
    required Key copyKey,
  }) => Row(
    textDirection: TextDirection.ltr,
    children: [
      Expanded(
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
                style: _valueStyle,
              ),
            ),
            const SizedBox(width: 8),
            _copyButton(onTap: onCopy, key: copyKey),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(label, textDirection: TextDirection.rtl, style: _labelStyle),
    ],
  );

  Widget _plainRow({required String value, required String label}) => Row(
    textDirection: TextDirection.ltr,
    children: [
      Expanded(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.ltr,
          style: _valueStyle,
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
          style: _labelStyle,
        ),
      ),
    ],
  );

  Widget _copyButton({required VoidCallback? onTap, required Key key}) {
    final icon = SizedBox.square(
      dimension: 16,
      child: SvgPicture.asset(AppAssets.iconCopy16White, fit: BoxFit.contain),
    );
    return onTap == null
        ? KeyedSubtree(key: key, child: icon)
        : InkWell(key: key, onTap: onTap, child: icon);
  }

  TextStyle get _valueStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.white,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle get _labelStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.white,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
