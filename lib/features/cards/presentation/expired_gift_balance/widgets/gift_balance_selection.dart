import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';

class GiftBalanceSelection extends StatelessWidget {
  const GiftBalanceSelection({
    super.key,
    required this.cubit,
    required this.state,
    required this.onFilter,
  });
  final ExpiredGiftBalanceCubit cubit;
  final ExpiredGiftBalanceState state;
  final VoidCallback onFilter;
  @override
  Widget build(BuildContext context) => AbsorbPointer(
    absorbing: !state.editable,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.giftBalanceIntro,
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
                  onChanged: cubit.search,
                  hintText: context.l10n.giftBalanceSearch,
                  prefixIcon: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: cardServiceIcon(AppAssets.cardFeaturesSearch),
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
              if (state.hasFilter) ...[
                const SizedBox(width: 8),
                SizedBox.square(
                  dimension: 44,
                  child: AppButton(
                    onPressed: onFilter,
                    variant: AppButtonVariant.secondaryGray,
                    tooltip: context.l10n.cardFeatureFilter,
                    backgroundColor: AppPalette.warning300,
                    icon: cardServiceIcon(AppAssets.giftBalanceFilter),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Semantics(
                label: context.l10n.giftBalanceSelectAll,
                child: AppToggle(
                  value: state.allVisibleSelected,
                  appearance: AppToggleAppearance.issuance,
                  onChanged: state.visibleCards.isEmpty
                      ? null
                      : cubit.selectAllVisible,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.giftBalanceSelectAll,
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
                context.l10n.cardServiceEmpty,
                textAlign: TextAlign.center,
              ),
            ),
          for (final card in state.visibleCards) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => cubit.toggleCard(card.id),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: state.selectedIds.contains(card.id)
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
                          value: state.selectedIds.contains(card.id),
                          size: AppCheckboxSize.md,
                          onChanged: (_) => cubit.toggleCard(card.id),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GiftBalanceCardDetails(
                          card: card,
                          deposit: state.hasFilter
                              ? state.catalog!.deposits
                                    .where((d) => d.id == card.depositId)
                                    .first
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

/// The same card details are used in selection and the removable review list.
class GiftBalanceCardDetails extends StatelessWidget {
  const GiftBalanceCardDetails({super.key, required this.card, this.deposit});
  final ExpiredGiftCard card;
  final CardServiceDeposit? deposit;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      GiftBalanceDetailRow(
        label: context.l10n.cardFeatureNumber,
        value: card.number,
      ),
      const SizedBox(height: 8),
      if (deposit != null) ...[
        const CardServiceRowDivider(),
        const SizedBox(height: 8),
        GiftBalanceDetailRow(
          label: context.l10n.cardFeatureDeposit,
          value: deposit!.number,
        ),
        const SizedBox(height: 8),
      ],
      const CardServiceRowDivider(),
      const SizedBox(height: 8),
      GiftBalanceDetailRow(
        label: context.l10n.giftBalanceRemaining,
        value: CurrencyFormatter.format(card.balanceRial),
      ),
    ],
  );
}

class GiftBalanceDetailRow extends StatelessWidget {
  const GiftBalanceDetailRow({
    super.key,
    required this.label,
    required this.value,
  });
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(child: Text(label, style: cardServiceSmall(context))),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          value,
          textDirection: TextDirection.ltr,
          style: cardServiceSmall(
            context,
            color: context.colors.textPrimary,
            medium: true,
          ),
        ),
      ),
    ],
  );
}
