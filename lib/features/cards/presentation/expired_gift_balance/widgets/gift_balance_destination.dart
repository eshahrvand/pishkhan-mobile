import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';
import 'gift_balance_selection.dart';

class GiftBalanceDestination extends StatelessWidget {
  const GiftBalanceDestination({
    super.key,
    required this.cubit,
    required this.state,
  });
  final ExpiredGiftBalanceCubit cubit;
  final ExpiredGiftBalanceState state;
  @override
  Widget build(BuildContext context) => AbsorbPointer(
    absorbing: !state.editable,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                GiftBalanceDetailRow(
                  label: context.l10n.giftBalanceCount,
                  value: '${state.selectedCards.length}',
                ),
                const SizedBox(height: 12),
                const CardServiceRowDivider(),
                const SizedBox(height: 12),
                GiftBalanceDetailRow(
                  label: context.l10n.giftBalanceTotal,
                  value: CurrencyFormatter.format(state.totalRial),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const CardServiceDivider(),
          const SizedBox(height: 20),
          AppSelect<String>(
            label: context.l10n.giftBalanceTransferTo,
            hintText: context.l10n.giftBalanceDepositHint,
            value: state.destinationId,
            labelStyle: cardServiceSmall(context, medium: true),
            labelSpacing: 8,
            textStyle: AppTypography.bodyMedium.copyWith(
              height: 20 / 14,
              letterSpacing: 0,
              color: state.destination == null
                  ? context.colors.textDisabled
                  : context.colors.textPrimary,
            ),
            trailing: cardServiceIcon(AppAssets.cardFeaturesChevron),
            options: [
              for (final d in state.catalog!.deposits)
                AppSelectOption(value: d.id, label: d.number),
            ],
            onChanged: cubit.selectDestination,
          ),
          if (state.failure != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                context.l10n.cardServiceSubmitError,
                style: cardServiceSmall(context, color: context.colors.error),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
