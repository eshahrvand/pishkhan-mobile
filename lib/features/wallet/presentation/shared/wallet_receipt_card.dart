import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../domain/entities/wallet.dart';
import 'wallet_labels.dart';
import 'wallet_balance_summary.dart';
import 'wallet_receipt_row.dart';

class WalletReceiptCard extends StatelessWidget {
  const WalletReceiptCard({super.key, required this.receipt});
  final WalletReceipt receipt;
  Future<void> _copyTracking(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: receipt.trackingId));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.current.walletCopied)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        receipt.type == WalletTransactionType.transfer ? 73 : 88,
        16,
        24,
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: receipt.type == WalletTransactionType.transfer
                  ? 390
                  : 360,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: AvpImage(
                    image: receipt.type == WalletTransactionType.transfer
                        ? '${AppConstants.baseImage}wallet_transfer_receipt_paper.svg'
                        : '${AppConstants.baseImage}wallet_receipt_paper.svg',
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        walletSuccessTitle(receipt.type),
                        textAlign: TextAlign.center,
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        walletSuccessDescription(receipt.type),
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const AvpImage(
                        image:
                            '${AppConstants.baseImage}wallet_receipt_divider.png',
                        height: 1,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 24),
                      WalletReceiptRow(
                        label: S.current.walletAmount,
                        value: CurrencyFormatter.format(
                          receipt.amountRial,
                          unit: S.current.rialCurrency,
                        ),
                      ),
                      WalletReceiptRow(
                        label: S.current.walletTransactionDate,
                        value: walletDateLabel(receipt.createdAt),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: AvpImage(
                          image:
                              '${AppConstants.baseImage}wallet_receipt_rule.svg',
                          height: 1,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                      if (receipt.type != WalletTransactionType.charge)
                        WalletReceiptRow(
                          label: S.current.walletReceiptSource,
                          value: receipt.source,
                        ),
                      if (receipt.type != WalletTransactionType.withdraw)
                        WalletReceiptRow(
                          label: S.current.walletReceiptDestination,
                          value: receipt.destination,
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: WalletReceiptRow(
                              label: S.current.walletTrackingId,
                              value: receipt.trackingId,
                            ),
                          ),
                          AppButton(
                            tooltip: S.current.walletTrackingId,
                            size: AppButtonSize.sm,
                            variant: AppButtonVariant.text,
                            icon: const AvpImage(
                              image:
                                  '${AppConstants.baseImage}wallet_receipt_copy.svg',
                              width: 14,
                              height: 14,
                            ),
                            onPressed: () => _copyTracking(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppPalette.indigo25,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AvpImage(
                              image: switch (receipt.type) {
                                WalletTransactionType.charge =>
                                  '${AppConstants.baseImage}wallet_receipt_charge.svg',
                                WalletTransactionType.withdraw =>
                                  '${AppConstants.baseImage}wallet_receipt_withdraw.svg',
                                _ =>
                                  '${AppConstants.baseImage}wallet_receipt_transfer.svg',
                              },
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              walletTypeLabel(receipt.type),
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppPalette.indigo600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  top: -38,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AvpImage(
                      image:
                          '${AppConstants.baseImage}wallet_receipt_success.svg',
                      width: 88,
                      height: 88,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AvpImage(
            image: '${AppConstants.baseImage}wallet_receipt_outer_divider.png',
            height: 1,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 24),
          WalletBalanceSummary(
            balanceRial: receipt.balanceRial,
            afterTransaction: true,
          ),
        ],
      ),
    );
  }
}
