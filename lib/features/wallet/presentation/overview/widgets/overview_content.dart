import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_credit_card_mockup.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

import '../cubit/overview_cubit.dart';

class WalletOverviewContent extends StatelessWidget {
  const WalletOverviewContent({super.key, required this.state});
  final WalletOverviewState state;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.wallet != null)
            AppCreditCardMockup(
              state: AppCreditCardMockupState.wallet,
              isCompact: true,
              walletBalance: CurrencyFormatter.format(
                state.wallet!.balanceRial,
              ),
              linkedDeposit: state.wallet!.linkedDeposit.number,
              onRefresh: context.read<WalletOverviewCubit>().fetchWallet,
            ),
          const SizedBox(height: 24),
          AppServiceGridCard(
            title: S.current.walletOperations,
            items: [
              AppServiceGridItem(
                id: 'wallet-charge',
                label: S.current.walletCharge,
                icon: const AvpImage(
                  image: '${AppConstants.baseImage}wallet_operation_charge.svg',
                  width: 32,
                  height: 32,
                ),
                onTap: context.read<WalletOverviewCubit>().openCharge,
              ),
              AppServiceGridItem(
                id: 'wallet-withdraw',
                label: S.current.walletWithdraw,
                icon: const AvpImage(
                  image:
                      '${AppConstants.baseImage}wallet_operation_withdraw.svg',
                  width: 32,
                  height: 32,
                ),
                onTap: context.read<WalletOverviewCubit>().openWithdraw,
              ),
              AppServiceGridItem(
                id: 'wallet-transfer',
                label: S.current.walletTransfer,
                icon: const AvpImage(
                  image:
                      '${AppConstants.baseImage}wallet_operation_transfer.svg',
                  width: 32,
                  height: 32,
                ),
                onTap: context.read<WalletOverviewCubit>().openTransfer,
              ),
              AppServiceGridItem(
                id: 'wallet-deposit',
                label: S.current.walletLinkedDepositShort,
                icon: const AvpImage(
                  image:
                      '${AppConstants.baseImage}wallet_operation_deposit.svg',
                  width: 32,
                  height: 32,
                ),
                onTap: context.read<WalletOverviewCubit>().openLinkedDeposit,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Material(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: context.read<WalletOverviewCubit>().openTransactions,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: const AvpImage(
                        image:
                            '${AppConstants.baseImage}wallet_operation_history.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        S.current.walletViewTransactions,
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                    const SizedBox.square(
                      dimension: 24,
                      child: Center(
                        child: AvpImage(
                          image:
                              '${AppConstants.baseImage}icon_angle_left_20_gray700.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
