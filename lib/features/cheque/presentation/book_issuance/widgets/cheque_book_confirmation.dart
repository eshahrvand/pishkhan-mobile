import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';
import 'package:pishkhan_mobile/shared/widgets/app_request_summary.dart';

import '../cubit/cheque_book_cubit.dart';

class ChequeBookConfirmation extends StatelessWidget {
  const ChequeBookConfirmation({super.key, required this.state});
  final ChequeBookState state;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !state.isEditable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppRequestSummary(
            depositNumber: state.deposit!.number,
            operation: S.current.issueChequeBook,
            operationDivider:
                '${AppConstants.baseImage}chequebook_summary_operation.svg',
            isExpanded: state.isSummaryExpanded,
            onExpandedChanged: context
                .read<ChequeBookCubit>()
                .updateSummaryExpansion,
          ),
          const SizedBox(height: 20),
          const AvpImage(
            image: '${AppConstants.baseImage}issuance_divider.svg',
            height: .5,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20),
          AppInvoice(
            title: S.current.issuancePayable,
            walletLabel: S.current.issuanceWallet,
            costIcon: const AvpImage(
              image: '${AppConstants.baseImage}chequebook_cost.svg',
              width: 20,
              height: 20,
            ),
            walletIcon: const AvpImage(
              image:
                  '${AppConstants.baseImage}dashboard_catalog_category_wallet.svg',
              width: 20,
              height: 20,
            ),
            totalAmount: CurrencyFormatter.format(state.totalRial),
            walletBalance: CurrencyFormatter.format(
              state.quote!.walletBalanceRial,
            ),
            lines: [
              AppInvoiceLine(
                id: 'chequebook',
                label: S.current.chequeBookIssueFee,
                amount: CurrencyFormatter.format(state.quote!.issueFeeRial),
                icon: const AvpImage(
                  image: '${AppConstants.baseImage}drawer_cheque.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              AppInvoiceLine(
                id: 'delivery',
                label: S.current.issuanceDeliveryFee,
                amount: CurrencyFormatter.format(state.quote!.deliveryFeeRial),
                icon: const AvpImage(
                  image: '${AppConstants.baseImage}chequebook_delivery.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
            backgroundColor: context.colors.surface,
            labelColor: context.colors.textTertiary,
            zeroHeightDividers: true,
            isExpanded: state.isInvoiceExpanded,
            onExpandedChanged: context
                .read<ChequeBookCubit>()
                .updateInvoiceExpansion,
            isWalletBalanceSufficient: state.isWalletSufficient,
            walletSufficientLabel: S.current.issuanceWalletSufficient,
            walletInsufficientLabel: S.current.issuanceWalletInsufficient,
          ),
        ],
      ),
    );
  }
}
