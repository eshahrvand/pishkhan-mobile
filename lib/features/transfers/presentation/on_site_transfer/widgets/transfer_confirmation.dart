import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../cubit/on_site_transfer_cubit.dart';

import 'package:pishkhan_mobile/shared/widgets/app_request_summary.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

class TransferConfirmation extends StatelessWidget {
  const TransferConfirmation({super.key, required this.state});
  final OnSiteTransferState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppRequestSummary(
          depositNumber: state.deposit!.number,
          operation: S.current.dashboardLocalTransfer,
          operationDivider: AppAssets.onSiteTransferSummaryOperation,
          isExpanded: state.isSummaryExpanded,
          onExpandedChanged: (value) {
            context.read<OnSiteTransferCubit>().updateSummaryExpanded(value);
          },
        ),
        const SizedBox(height: 20),
        AvpImage(
          image: AppAssets.issuanceDivider,
          height: 1,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 20),
        AppInvoice(
          totalAmount: CurrencyFormatter.format(state.catalog!.feeRial),
          walletBalance: CurrencyFormatter.format(
            state.catalog!.walletBalanceRial,
          ),
          title: S.current.issuancePayable,
          walletLabel: S.current.issuanceWallet,
          walletSufficientLabel: S.current.issuanceWalletSufficient,
          walletInsufficientLabel: S.current.issuanceWalletInsufficient,
          backgroundColor: context.colors.surface,
          labelColor: context.colors.textTertiary,
          zeroHeightDividers: true,
          isExpanded: state.isInvoiceExpanded,
          isWalletBalanceSufficient: state.isWalletSufficient,
          onExpandedChanged: (value) {
            context.read<OnSiteTransferCubit>().updateInvoiceExpanded(value);
          },
          lines: [
            AppInvoiceLine(
              id: 'onsite',
              label: S.current.transferServiceFee,
              amount: CurrencyFormatter.format(state.catalog!.feeRial),
              icon: AppInvoiceIcons.cost(),
            ),
          ],
        ),
      ],
    );
  }
}
