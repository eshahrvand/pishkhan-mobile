import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../shared/card_service_sheet.dart';
import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';
import 'gift_balance_selection.dart';

Future<void> showGiftBalanceFilter(
  BuildContext context,
  ExpiredGiftBalanceCubit cubit,
) async {
  cubit.beginFilter();
  if (!cubit.state.filterOpen) return;
  await showCardServiceSheet<void>(
    context,
    (_) => GiftBalanceFilterSheet(cubit: cubit),
  );
  if (!cubit.isClosed) cubit.cancelFilter();
}

Future<void> showGiftBalanceReview(
  BuildContext context,
  ExpiredGiftBalanceCubit cubit, {
  bool advance = false,
}) async {
  if (!cubit.beginReview()) return;
  final proceed = await showCardServiceSheet<bool>(
    context,
    (_) => GiftBalanceReviewSheet(cubit: cubit),
  );
  if (!cubit.isClosed) cubit.finishReview(advance: advance && proceed == true);
}

class GiftBalanceFilterSheet extends StatelessWidget {
  const GiftBalanceFilterSheet({super.key, required this.cubit});
  final ExpiredGiftBalanceCubit cubit;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
        bloc: cubit,
        buildWhen: (old, next) =>
            old.draftFilterDepositId != next.draftFilterDepositId,
        builder: (context, state) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBottomSheetHeader(
                title: context.l10n.cardFeatureFilter,
                rightIcon: cardServiceIcon(AppAssets.cardFeaturesFilterHeader),
                showLeftAction: false,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: AppSelect<String>(
                  label: context.l10n.cardFeatureDeposit,
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
                      label: context.l10n.cardFeatureAll,
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
                  label: context.l10n.cardFeatureApplyFilter,
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

class GiftBalanceReviewSheet extends StatelessWidget {
  const GiftBalanceReviewSheet({super.key, required this.cubit});
  final ExpiredGiftBalanceCubit cubit;
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
    bloc: cubit,
    buildWhen: (old, next) => old.selectedIds != next.selectedIds,
    builder: (context, state) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          title: context.l10n.giftBalanceSelectedList(
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
                    child: Text(context.l10n.cardServiceEmpty),
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
                          label: context.l10n.giftBalanceRemoveCard(
                            state.selectedCards[i].number,
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                cubit.removeSelected(state.selectedCards[i].id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
            label: context.l10n.backLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
      ],
    ),
  );
}
