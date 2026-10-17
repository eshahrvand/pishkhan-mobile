import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../shared/card_service_sheet.dart';
import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';
import 'gift_balance_selection.dart';

Future<void> showGiftBalanceFilter(
  BuildContext context,
  ExpiredGiftBalanceCubit cubit,
) => showCardServiceSheet<void>(
  context,
  (_) => GiftBalanceFilterSheet(cubit: cubit),
);

Future<bool?> showGiftBalanceReview(
  BuildContext context,
  ExpiredGiftBalanceCubit cubit,
) => showCardServiceSheet<bool>(
  context,
  (_) => GiftBalanceReviewSheet(cubit: cubit),
);

class GiftBalanceFilterSheet extends StatelessWidget {
  const GiftBalanceFilterSheet({super.key, required this.cubit});
  final ExpiredGiftBalanceCubit cubit;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
      bloc: cubit,
      buildWhen: (previous, current) =>
          previous.draftFilterDepositId != current.draftFilterDepositId,
      builder: (context, state) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: S.current.cardFeatureFilter,
              rightIcon: cardServiceIcon(AppAssets.cardFeaturesFilterHeader),
              showLeftAction: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: AppSelect<String>(
                label: S.current.cardFeatureDeposit,
                value: state.draftFilterDepositId ?? 'all',
                labelSpacing: 8,
                labelStyle: cardServiceSmall(context, medium: true),
                textStyle: AppTypography.bodyMedium.copyWith(
                  height: 20 / 14,
                  letterSpacing: 0,
                  color: context.colors.textPrimary,
                ),
                trailing: cardServiceIcon(AppAssets.cardFeaturesChevron),
                options: [
                  AppSelectOption(
                    value: 'all',
                    label: S.current.cardFeatureAll,
                  ),
                  for (final d in state.catalog!.deposits)
                    AppSelectOption(value: d.id, label: d.number),
                ],
                onChanged: (id) =>
                    cubit.selectDraftFilter(id == 'all' ? null : id),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: AppButton(
                size: AppButtonSize.lg,
                label: S.current.cardFeatureApplyFilter,
                onPressed: () {
                  cubit.applyFilter();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GiftBalanceReviewSheet extends StatelessWidget {
  const GiftBalanceReviewSheet({super.key, required this.cubit});
  final ExpiredGiftBalanceCubit cubit;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
      bloc: cubit,
      buildWhen: (previous, current) =>
          previous.selectedIds != current.selectedIds,
      builder: (context, state) => Column(
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
                              onTap: () => cubit.removeSelected(
                                state.selectedCards[i].id,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: cardServiceIcon(AppAssets.issuanceTrash),
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
      ),
    );
  }
}
