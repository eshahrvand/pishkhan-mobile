import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import '../../../domain/entities/issuance_data.dart';
import '../cubit/card_issuance_cubit.dart';

import 'issuance_styles.dart';
import 'issuance_divider.dart';
import 'issuance_summary_row.dart';

class IssuanceConfirmation extends StatelessWidget {
  const IssuanceConfirmation({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardIssuanceCubit, CardIssuanceState>(
      builder: (context, state) {
        final small = AppTypography.bodySmall.copyWith(
          height: 18 / 12,
          letterSpacing: 0,
        );
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
                  Semantics(
                    button: true,
                    expanded: state.isSummaryExpanded,
                    child: InkWell(
                      onTap: state.isEditable
                          ? () => context
                                .read<CardIssuanceCubit>()
                                .toggleSummaryExpansion()
                          : null,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              S.current.issuanceSummary,
                              style: small.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppCardIssuanceColors.summaryTitle,
                              ),
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: state.isSummaryExpanded ? 0 : 2,
                            child: issuanceIcon(
                              AppAssets.issuanceSummaryChevron,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.isSummaryExpanded) ...[
                    const SizedBox(height: 16),
                    IssuanceSummaryRow(
                      label: S.current.issuanceDepositNumber,
                      value: state.draft.deposit!.number,
                      asset: AppAssets.issuanceSummaryDivider,
                    ),
                    const SizedBox(height: 12),
                    IssuanceSummaryRow(
                      label: S.current.issuanceOperation,
                      value: S.current.issuanceTitle,
                      asset: AppAssets.issuanceSummaryDividerOperation,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const IssuanceDivider(),
            const SizedBox(height: 20),
            AppInvoice(
              title: S.current.issuancePayable,
              walletLabel: S.current.issuanceWallet,
              backgroundColor: context.colors.surface,
              labelColor: context.colors.textTertiary,
              totalAmount: CurrencyFormatter.format(state.totalRial),
              walletBalance: CurrencyFormatter.format(
                state.catalog!.walletBalanceRial,
              ),
              lines: [
                for (final fee in state.fees)
                  AppInvoiceLine(
                    id: fee.kind.name,
                    label: switch (fee.kind) {
                      IssuanceFeeKind.print => S.current.issuancePrintFee,
                      IssuanceFeeKind.identity => S.current.issuanceIdentityFee,
                      IssuanceFeeKind.delivery => S.current.issuanceDeliveryFee,
                    },
                    amount: CurrencyFormatter.format(fee.amountRial),
                    icon: switch (fee.kind) {
                      IssuanceFeeKind.print => AppInvoiceIcons.print(),
                      IssuanceFeeKind.identity =>
                        AppInvoiceIcons.identityVideo(),
                      IssuanceFeeKind.delivery => AppInvoiceIcons.delivery(),
                    },
                  ),
              ],
              isExpanded: state.isInvoiceExpanded,
              onExpandedChanged: context
                  .read<CardIssuanceCubit>()
                  .updateInvoiceExpansion,
              walletSufficientLabel: S.current.issuanceWalletSufficient,
              walletInsufficientLabel: S.current.issuanceWalletInsufficient,
              isWalletBalanceSufficient: state.isWalletSufficient,
            ),
            if (state.submissionFailure != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  S.current.issuanceSubmitError,
                  style: small.copyWith(color: context.colors.error),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
