import 'app_transfer_destination_card_row.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
  Widget build(BuildContext context) {
    return Directionality(
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
                      AppAssets.transferDestinationCardTrash,
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
                  AppTransferDestinationCardRow(
                    value: depositNumber,
                    label: 'شماره سپرده',
                    divider: AppAssets.transferDestinationCardDivider1,
                  ),
                  const SizedBox(height: 10),
                  AppTransferDestinationCardRow(
                    value: _amount,
                    label: 'مبلغ (ریال)',
                    divider: method == AppTransferMethod.satna
                        ? AppAssets.transferDestinationCardDivider5
                        : AppAssets.transferDestinationCardDivider2,
                  ),
                  const SizedBox(height: 10),
                  AppTransferDestinationCardRow(
                    value: _methodLabel,
                    label: 'روش انتقال',
                    divider: method == AppTransferMethod.paya
                        ? AppAssets.transferDestinationCardDivider8
                        : method == AppTransferMethod.satna
                        ? AppAssets.transferDestinationCardDivider6
                        : AppAssets.transferDestinationCardDivider3,
                  ),
                  const SizedBox(height: 10),
                  AppTransferDestinationCardRow(
                    value: _isExternal ? purpose : depositIdentifier,
                    label: _isExternal ? 'بابت' : 'شناسه واریز',
                    divider: _isExternal
                        ? AppAssets.transferDestinationCardDivider7
                        : AppAssets.transferDestinationCardDivider4,
                  ),
                  if (_isExternal) ...[
                    const SizedBox(height: 10),
                    AppTransferDestinationCardRow(
                      value: depositIdentifier,
                      label: 'شناسه واریز',
                      divider: AppAssets.transferDestinationCardDivider4,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
