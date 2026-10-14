import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

enum AppTransactionType { discharge, charge, transfer, shopping }

/// Figma wallet transaction row with four transaction variants.
class AppTransactionCard extends StatelessWidget {
  const AppTransactionCard({
    super.key,
    this.type = AppTransactionType.discharge,
    this.amount = '20,000,000',
    this.date = '۱۴۰۳/۱۱/۱۳  -  ۰۸:۱۲',
    this.title,
    this.onTap,
  });

  final AppTransactionType type;
  final String amount;
  final String date;
  final String? title;
  final VoidCallback? onTap;

  String get _title =>
      title ??
      switch (type) {
        AppTransactionType.discharge => 'دشارژ',
        AppTransactionType.charge => 'شارژ',
        AppTransactionType.transfer => 'انتقال کیف به کیف',
        AppTransactionType.shopping => 'خرید',
      };

  String get _icon => switch (type) {
    AppTransactionType.discharge => AppAssets.transactionCardSend,
    AppTransactionType.charge => AppAssets.transactionCardReceived,
    AppTransactionType.transfer => AppAssets.transactionCardTransport,
    AppTransactionType.shopping => AppAssets.transactionCardShoppingCartCheck,
  };

  @override
  Widget build(BuildContext context) {
    final content = Container(
      key: const Key('app_transaction_card'),
      width: 361,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.gray50,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          _amount(),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: _titleStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: _dateStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppPalette.white,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(_icon),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('app_transaction_card_action'),
                onTap: onTap,
                borderRadius: AppRadius.borderMd,
                child: content,
              ),
            ),
    );
  }

  Widget _amount() => Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: TextDirection.ltr,
    children: [
      Text('ریال', style: _currencyStyle),
      const SizedBox(width: 2),
      Text(amount, textDirection: TextDirection.ltr, style: _amountStyle),
    ],
  );

  TextStyle get _currencyStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray700,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle get _amountStyle => AppTypography.bodyMedium.copyWith(
    color: AppPalette.gray900,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0,
  );

  TextStyle get _titleStyle =>
      _amountStyle.copyWith(fontWeight: FontWeight.w500);

  TextStyle get _dateStyle => _currencyStyle;
}
