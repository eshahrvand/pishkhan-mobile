import 'package:pishkhan_mobile/core/config/constant.dart';

import 'app_deposit_card_data_row.dart';
import 'app_deposit_card_plain_row.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

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
          Row(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLogo)
                SizedBox.square(
                  dimension: 24,
                  child:
                      logo ??
                      AvpImage(
                        image:
                            '${AppConstants.baseImage}deposit_card_resalat_logo.svg',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
          ),
          Column(
            children: [
              AppDepositCardDataRow(
                value: depositNumber,
                label: 'شماره سپرده:',
                onCopy: onCopyDepositNumber,
                copyKey: const Key('app_deposit_card_copy_number'),
              ),
              SizedBox(height: _isSingle ? 20 : 16),
              AppDepositCardDataRow(
                value: iban,
                label: 'شماره شبا:',
                onCopy: onCopyIban,
                copyKey: const Key('app_deposit_card_copy_iban'),
              ),
              SizedBox(height: _isSingle ? 20 : 16),
              AppDepositCardPlainRow(
                value: openingDate,
                label: 'تاریخ افتتاح:',
              ),
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
}
