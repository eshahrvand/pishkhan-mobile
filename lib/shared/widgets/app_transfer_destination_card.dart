import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppTransferMethod { internal, satna, paya }

/// Figma transfer destination summary for internal, Satna, and Paya methods.
class AppTransferDestinationCard extends StatelessWidget {
  const AppTransferDestinationCard({
    super.key,
    this.method = AppTransferMethod.internal,
    this.recipientName = 'بهار مبارک',
    this.depositNumber = '۱۰.۲۳۴۵۶۷.۱',
    this.amount,
    this.purpose = 'واریز حقوق',
    this.depositIdentifier = '۱۲۳۴۵۶۷۸۹',
    this.onDelete,
  });

  final AppTransferMethod method;
  final String recipientName;
  final String depositNumber;
  final String? amount;
  final String purpose;
  final String depositIdentifier;
  final VoidCallback? onDelete;

  static const _assetPath = 'assets/images/transfer_destination_card/';

  bool get _isExternal => method != AppTransferMethod.internal;

  String get _amount =>
      amount ??
      (method == AppTransferMethod.satna ? '۲,000,000,000' : '1,000,000,000');

  String get _methodLabel => switch (method) {
    AppTransferMethod.internal => 'داخلی',
    AppTransferMethod.satna => 'ساتنا',
    AppTransferMethod.paya => 'پایا',
  };

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      key: const Key('app_transfer_destination_card'),
      width: 343,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: AppPalette.gray200),
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            color: AppPalette.white,
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                InkWell(
                  key: const Key('app_transfer_destination_delete'),
                  onTap: onDelete,
                  child: SvgPicture.asset(
                    '${_assetPath}trash.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recipientName,
                    textAlign: TextAlign.right,
                    style: _nameStyle,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: AppPalette.gray25,
              border: Border(
                top: BorderSide(color: AppPalette.gray300, width: .5),
              ),
            ),
            child: Column(
              children: [
                _row(depositNumber, 'شماره سپرده', 'divider_1.svg'),
                const SizedBox(height: 10),
                _row(
                  _amount,
                  'مبلغ (ریال)',
                  method == AppTransferMethod.satna
                      ? 'divider_5.svg'
                      : 'divider_2.svg',
                ),
                const SizedBox(height: 10),
                _row(
                  _methodLabel,
                  'روش انتقال',
                  method == AppTransferMethod.paya
                      ? 'divider_8.svg'
                      : method == AppTransferMethod.satna
                      ? 'divider_6.svg'
                      : 'divider_3.svg',
                ),
                const SizedBox(height: 10),
                _row(
                  _isExternal ? purpose : depositIdentifier,
                  _isExternal ? 'بابت' : 'شناسه واریز',
                  _isExternal ? 'divider_7.svg' : 'divider_4.svg',
                ),
                if (_isExternal) ...[
                  const SizedBox(height: 10),
                  _row(depositIdentifier, 'شناسه واریز', 'divider_4.svg'),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _row(String value, String label, String divider) => SizedBox(
    height: 18,
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              style: _valueStyle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: .5,
            child: SvgPicture.asset('$_assetPath$divider', fit: BoxFit.fill),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          fit: FlexFit.loose,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(label, style: _labelStyle),
          ),
        ),
      ],
    ),
  );

  TextStyle get _nameStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray900,
    fontWeight: FontWeight.w700,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle get _valueStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray900,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle get _labelStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray900,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
