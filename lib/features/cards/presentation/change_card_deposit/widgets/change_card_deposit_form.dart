import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import '../../../domain/entities/card_service_data.dart';
import '../cubit/change_card_deposit_cubit.dart';
import '../../shared/card_service_widgets.dart';

class ChangeCardDepositForm extends StatelessWidget {
  const ChangeCardDepositForm({super.key, required this.state});
  final ChangeCardDepositState state;
  @override
  Widget build(BuildContext context) {
    final valueStyle = AppTypography.bodyMedium.copyWith(
      height: 20 / 14,
      letterSpacing: 0,
      color: context.colors.textPrimary,
    );
    return AbsorbPointer(
      absorbing: !state.isEditable,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S.current.changeCardDepositIntro,
              style: valueStyle.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            AppSelect<ServiceBankCard>(
              value: state.card,
              label: S.current.cardServiceCard,
              hintText: S.current.cardServiceCardHint,
              labelSpacing: 8,
              labelStyle: cardServiceSmall(context, medium: true),
              textStyle: valueStyle.copyWith(
                color: state.card == null
                    ? context.colors.textDisabled
                    : context.colors.textPrimary,
              ),
              trailing: cardServiceIcon(
                '${AppConstants.baseImage}card_features_chevron.svg',
              ),
              options: [
                for (final c in state.catalog!.cards)
                  AppSelectOption(
                    value: c,
                    // Keep grouped digits in reading order within the RTL field.
                    label:
                        '\u200e${CardDisplayFormatter.format(c.number, separator: ' ')}',
                  ),
              ],
              onChanged: context.read<ChangeCardDepositCubit>().selectCard,
            ),
            const SizedBox(height: 20),
            const CardServiceDivider(),
            const SizedBox(height: 20),
            if (state.source != null) ...[
              AppSelect<String>(
                value: state.source!.id,
                enabled: false,
                label: S.current.cardServiceFromDeposit,
                labelSpacing: 8,
                labelStyle: cardServiceSmall(context, medium: true),
                textStyle: valueStyle,
                trailing: const SizedBox.shrink(),
                options: [
                  AppSelectOption(
                    value: state.source!.id,
                    label: state.source!.number,
                  ),
                ],
                onChanged: null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  cardServiceIcon(
                    '${AppConstants.baseImage}card_deposit_info.svg',
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cardDepositLabel(state.source!),
                      style: cardServiceSmall(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppSelect<CardServiceDeposit>(
                value: state.destination,
                label: S.current.cardServiceToDeposit,
                hintText: S.current.cardServiceToDepositHint,
                labelSpacing: 8,
                labelStyle: cardServiceSmall(context, medium: true),
                textStyle: valueStyle.copyWith(
                  color: state.destination == null
                      ? context.colors.textDisabled
                      : context.colors.textPrimary,
                ),
                trailing: cardServiceIcon(
                  '${AppConstants.baseImage}card_features_chevron.svg',
                ),
                options: [
                  for (final d in state.destinations)
                    AppSelectOption(value: d, label: d.number),
                ],
                onChanged: context
                    .read<ChangeCardDepositCubit>()
                    .selectDestination,
              ),
              if (state.destination != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    cardServiceIcon(
                      '${AppConstants.baseImage}card_deposit_type.svg',
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cardDepositLabel(state.destination!),
                        style: cardServiceSmall(context),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              const CardServiceDivider(),
              const SizedBox(height: 20),
            ],
            AppInvoice(
              totalAmount: CurrencyFormatter.format(
                state.catalog!.changeDepositFeeRial,
              ),
              walletBalance: CurrencyFormatter.format(
                state.catalog!.walletBalanceRial,
              ),
              lines: const [],
              isExpanded: false,
              onExpandedChanged: (_) {},
              showToggle: false,
              zeroHeightDividers: true,
              backgroundColor: context.colors.surface,
              labelColor: context.colors.textTertiary,
              isWalletBalanceSufficient: state.isWalletSufficient,
              title: S.current.issuancePayable,
              walletLabel: S.current.issuanceWallet,
              walletSufficientLabel: S.current.issuanceWalletSufficient,
              walletInsufficientLabel: S.current.issuanceWalletInsufficient,
            ),
          ],
        ),
      ),
    );
  }
}
