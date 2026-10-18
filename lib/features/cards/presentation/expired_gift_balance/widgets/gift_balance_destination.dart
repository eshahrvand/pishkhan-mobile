import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';
import 'gift_balance_card_details.dart';

class GiftBalanceDestination extends StatelessWidget {
  const GiftBalanceDestination({super.key, required this.state});
  final ExpiredGiftBalanceState state;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !state.isEditable,
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
                    label: S.current.giftBalanceCount,
                    value: '${state.selectedCards.length}',
                  ),
                  const SizedBox(height: 12),
                  const CardServiceRowDivider(),
                  const SizedBox(height: 12),
                  GiftBalanceDetailRow(
                    label: S.current.giftBalanceTotal,
                    value: CurrencyFormatter.format(state.totalRial),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const CardServiceDivider(),
            const SizedBox(height: 20),
            AppSelect<CardServiceDeposit>(
              label: S.current.giftBalanceTransferTo,
              hintText: S.current.giftBalanceDepositHint,
              value: state.destination,
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
                  AppSelectOption(value: d, label: d.number),
              ],
              onChanged: context
                  .read<ExpiredGiftBalanceCubit>()
                  .selectDestination,
            ),
            if (state.submissionFailure != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  S.current.cardServiceSubmitError,
                  style: cardServiceSmall(context, color: context.colors.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
