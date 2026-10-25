import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/shared/widgets/app_request_summary.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
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
    this.operationDivider =
        '${AppConstants.baseImage}certificate_certSummaryOperation.svg',
    this.summaryChevron =
        '${AppConstants.baseImage}certificate_certSummaryChevron.svg',
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
        AppRequestSummary(
          depositNumber: depositNumber,
          operation: operation,
          isExpanded: summaryExpanded,
          onExpandedChanged: onSummary,
          depositDivider:
              '${AppConstants.baseImage}certificate_certSummaryDeposit.svg',
          operationDivider: operationDivider,
          chevron: summaryChevron,
        ),
        const SizedBox(height: 20),
        const DepositDivider(
          asset: '${AppConstants.baseImage}certificate_certDivider.svg',
        ),
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
              icon: depositIcon(
                '${AppConstants.baseImage}certificate_certFeePrint.svg',
                size: 20,
              ),
            ),
            AppInvoiceLine(
              id: 'delivery',
              label: S.current.issuanceDeliveryFee,
              amount: CurrencyFormatter.format(catalog.deliveryFeeRial),
              icon: depositIcon(
                '${AppConstants.baseImage}certificate_certFeeDelivery.svg',
                size: 20,
              ),
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
