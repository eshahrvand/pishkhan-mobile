import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class WalletBalanceSummary extends StatelessWidget {
  const WalletBalanceSummary({
    super.key,
    required this.balanceRial,
    this.afterTransaction = false,
  });
  final int balanceRial;
  final bool afterTransaction;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppPalette.brand25,
        border: Border.all(color: AppPalette.brand200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const AvpImage(
            image: '${AppConstants.baseImage}wallet_summary.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              afterTransaction
                  ? S.current.walletBalanceAfter
                  : S.current.walletCurrentBalance,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            CurrencyFormatter.format(balanceRial, unit: S.current.rialCurrency),
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
