import 'certificate_summary_row.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import '../../domain/entities/certificate_data.dart';
import '../deposit_list/widgets/deposit_ui.dart';

class CertificateConfirmation extends StatelessWidget {
  const CertificateConfirmation({
    super.key,
    required this.depositNumber,
    required this.operation,
    required this.catalog,
    required this.total,
    required this.walletSufficient,
    required this.summaryExpanded,
    required this.invoiceExpanded,
    required this.onSummary,
    required this.onInvoice,
    this.operationDivider = AppAssets.certificateSummaryOperation,
    this.summaryChevron = AppAssets.certificateSummaryChevron,
  });
  final String depositNumber, operation;
  final CertificateCatalog catalog;
  final int total;
  final bool walletSufficient, summaryExpanded, invoiceExpanded;
  final ValueChanged<bool> onSummary, onInvoice;
  final String operationDivider, summaryChevron;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppCardIssuanceColors.summarySurface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppShadows.cardList,
          ),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSummary(!summaryExpanded),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.current.issuanceSummary,
                        style: Theme.of(context).textTheme.bodySmall!
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    RotatedBox(
                      quarterTurns: summaryExpanded ? 0 : 2,
                      child: depositIcon(summaryChevron, size: 20),
                    ),
                  ],
                ),
              ),
              if (summaryExpanded) ...[
                const SizedBox(height: 16),
                CertificateSummaryRow(
                  label: S.current.depositListNumber,
                  value: depositNumber,
                  asset: AppAssets.certificateSummaryDeposit,
                ),
                const SizedBox(height: 12),
                CertificateSummaryRow(
                  label: S.current.issuanceOperation,
                  value: operation,
                  asset: operationDivider,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        const DepositDivider(asset: AppAssets.certificateDivider),
        const SizedBox(height: 20),
        AppInvoice(
          title: S.current.issuancePayable,
          walletLabel: S.current.issuanceWallet,
          totalAmount: CurrencyFormatter.format(total),
          walletBalance: CurrencyFormatter.format(catalog.walletBalanceRial),
          lines: [
            AppInvoiceLine(
              id: 'print',
              label: S.current.issuancePrintFee,
              amount: CurrencyFormatter.format(catalog.printFeeRial),
              icon: depositIcon(AppAssets.certificateFeePrint, size: 20),
            ),
            AppInvoiceLine(
              id: 'delivery',
              label: S.current.issuanceDeliveryFee,
              amount: CurrencyFormatter.format(catalog.deliveryFeeRial),
              icon: depositIcon(AppAssets.certificateFeeDelivery, size: 20),
            ),
          ],
          isExpanded: invoiceExpanded,
          onExpandedChanged: onInvoice,
          isWalletBalanceSufficient: walletSufficient,
          backgroundColor: context.colors.surface,
          labelColor: context.colors.textTertiary,
          zeroHeightDividers: true,
          walletSufficientLabel: S.current.issuanceWalletSufficient,
          walletInsufficientLabel: S.current.issuanceWalletInsufficient,
        ),
      ],
    );
  }
}
