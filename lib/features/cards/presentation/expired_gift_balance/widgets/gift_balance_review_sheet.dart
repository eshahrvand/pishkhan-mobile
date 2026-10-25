import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../shared/card_service_sheet.dart';
import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';
import 'gift_balance_card_details.dart';

Future<bool?> showGiftBalanceReview(
  BuildContext context,
  ExpiredGiftBalanceCubit cubit,
) => showCardServiceSheet<bool>(
  context,
  (_) =>
      BlocProvider.value(value: cubit, child: const GiftBalanceReviewSheet()),
);

class GiftBalanceReviewSheet extends StatelessWidget {
  const GiftBalanceReviewSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
      buildWhen: (previous, current) =>
          previous.selectedCards != current.selectedCards,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: S.current.giftBalanceSelectedList(
                state.selectedCards.length,
              ),
              showLeftAction: false,
              showRightIcon: false,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.selectedCards.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(S.current.cardServiceEmpty),
                      ),
                    for (var i = 0; i < state.selectedCards.length; i++) ...[
                      if (i > 0) const CardServiceRowDivider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${i + 1}',
                                textAlign: TextAlign.center,
                                style: cardServiceSmall(context, medium: true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GiftBalanceCardDetails(
                                card: state.selectedCards[i],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Semantics(
                              button: true,
                              label: S.current.giftBalanceRemoveCard(
                                state.selectedCards[i].number,
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => context
                                    .read<ExpiredGiftBalanceCubit>()
                                    .removeSelectedCard(state.selectedCards[i]),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: cardServiceIcon(
                                    '${AppConstants.baseImage}issuance_trash.svg',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: AppButton(
                size: AppButtonSize.lg,
                label: S.current.backLabel,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        );
      },
    );
  }
}
