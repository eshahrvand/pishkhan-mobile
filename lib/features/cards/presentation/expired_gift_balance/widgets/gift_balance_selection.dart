import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';
import 'gift_balance_card_details.dart';

class GiftBalanceSelection extends StatelessWidget {
  const GiftBalanceSelection({super.key, required this.state});
  final ExpiredGiftBalanceState state;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !state.isEditable,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S.current.giftBalanceIntro,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                height: 20 / 14,
                letterSpacing: 0,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    value: state.query,
                    onChanged: context
                        .read<ExpiredGiftBalanceCubit>()
                        .updateSearchQuery,
                    hintText: S.current.giftBalanceSearch,
                    prefixIcon: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: cardServiceIcon(
                        '${AppConstants.baseImage}card_features_search.svg',
                      ),
                    ),
                    normalizeDigits: true,
                    maxLength: 19,
                    textDirection: TextDirection.rtl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\s-]')),
                    ],
                    textStyle: AppTypography.bodyMedium.copyWith(
                      height: 20 / 14,
                      letterSpacing: 0,
                    ),
                    hintColor: context.colors.textDisabled,
                    focusRing: AppTextFieldFocusRing.none,
                  ),
                ),
                if (state.isFilterAvailable) ...[
                  const SizedBox(width: 8),
                  SizedBox.square(
                    dimension: 44,
                    child: AppButton(
                      onPressed: context
                          .read<ExpiredGiftBalanceCubit>()
                          .requestFilter,
                      variant: AppButtonVariant.secondaryGray,
                      tooltip: S.current.cardFeatureFilter,
                      backgroundColor: AppPalette.warning300,
                      icon: cardServiceIcon(
                        '${AppConstants.baseImage}gift_balance_filter.svg',
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Semantics(
                  label: S.current.giftBalanceSelectAll,
                  child: AppToggle(
                    value: state.isAllVisibleSelected,
                    appearance: AppToggleAppearance.issuance,
                    onChanged: state.visibleCards.isEmpty
                        ? null
                        : context
                              .read<ExpiredGiftBalanceCubit>()
                              .selectAllVisible,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  S.current.giftBalanceSelectAll,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                    height: 20 / 14,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.visibleCards.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  S.current.cardServiceEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            for (final card in state.visibleCards) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    context.read<ExpiredGiftBalanceCubit>().toggleCard(card),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.selectedCards.contains(card)
                          ? context.colors.primary
                          : context.colors.border,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Semantics(
                          label: card.number,
                          child: AppCheckbox(
                            value: state.selectedCards.contains(card),
                            size: AppCheckboxSize.md,
                            onChanged: (_) => context
                                .read<ExpiredGiftBalanceCubit>()
                                .toggleCard(card),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GiftBalanceCardDetails(
                            card: card,
                            deposit: state.isFilterAvailable
                                ? state.depositsByGiftId[card.id]
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
