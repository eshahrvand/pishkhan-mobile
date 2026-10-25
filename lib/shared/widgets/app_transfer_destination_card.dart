import 'package:pishkhan_mobile/core/config/constant.dart';

import 'app_transfer_destination_card_row.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

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
    this.numberLabel,
    this.wrapNumber = false,
    this.methodTitle,
    this.methodLabel,
    this.amountLabel,
    this.purposeLabel,
    this.identifierLabel,
    this.deleteLabel,
  });

  final AppTransferMethod method;
  final String recipientName;
  final String depositNumber;
  final String? amount;
  final String purpose;
  final String depositIdentifier;
  final VoidCallback? onDelete;
  final String? numberLabel;
  final bool wrapNumber;
  final String? methodTitle;
  final String? methodLabel;
  final String? amountLabel;
  final String? purposeLabel;
  final String? identifierLabel;
  final String? deleteLabel;

  bool get _isExternal => method != AppTransferMethod.internal;

  String get _amount =>
      amount ??
      (method == AppTransferMethod.satna ? '۲,000,000,000' : '1,000,000,000');

  String get _methodLabel => switch (method) {
    AppTransferMethod.internal => S.current.transferInternal,
    AppTransferMethod.satna => S.current.transferSatna,
    AppTransferMethod.paya => S.current.transferPaya,
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
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
                  Semantics(
                    button: true,
                    label: deleteLabel,
                    child: InkWell(
                      onTap: onDelete,
                      child: AvpImage(
                        image:
                            '${AppConstants.baseImage}transfer_destination_card_trash.svg',
                        width: 20,
                        height: 20,
                      ),
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
                    wrapValue: wrapNumber,
                    label: numberLabel ?? S.current.depositListNumber,
                    divider:
                        '${AppConstants.baseImage}transfer_destination_card_divider_1.svg',
                  ),
                  const SizedBox(height: 10),
                  AppTransferDestinationCardRow(
                    value: _amount,
                    label: amountLabel ?? S.current.transferAmountRial,
                    divider: method == AppTransferMethod.satna
                        ? '${AppConstants.baseImage}transfer_destination_card_divider_5.svg'
                        : '${AppConstants.baseImage}transfer_destination_card_divider_2.svg',
                  ),
                  const SizedBox(height: 10),
                  AppTransferDestinationCardRow(
                    value: methodTitle ?? _methodLabel,
                    label: methodLabel ?? S.current.transferMethodRow,
                    divider: method == AppTransferMethod.paya
                        ? '${AppConstants.baseImage}transfer_destination_card_divider_8.svg'
                        : method == AppTransferMethod.satna
                        ? '${AppConstants.baseImage}transfer_destination_card_divider_6.svg'
                        : '${AppConstants.baseImage}transfer_destination_card_divider_3.svg',
                  ),
                  const SizedBox(height: 10),
                  AppTransferDestinationCardRow(
                    value: _isExternal ? purpose : depositIdentifier,
                    label: _isExternal
                        ? (purposeLabel ?? S.current.transferPurpose)
                        : (identifierLabel ?? S.current.transferIdentifier),
                    divider: _isExternal
                        ? '${AppConstants.baseImage}transfer_destination_card_divider_7.svg'
                        : '${AppConstants.baseImage}transfer_destination_card_divider_4.svg',
                  ),
                  if (_isExternal) ...[
                    const SizedBox(height: 10),
                    AppTransferDestinationCardRow(
                      value: depositIdentifier,
                      label: identifierLabel ?? S.current.transferIdentifier,
                      divider:
                          '${AppConstants.baseImage}transfer_destination_card_divider_4.svg',
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
}
