import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import '../../../domain/entities/card_restriction.dart';
import '../cubit/card_restriction_cubit.dart';
import '../../shared/card_service_widgets.dart';
import 'card_restriction_details.dart';
import 'card_restriction_labels.dart';

class CardRestrictionForm extends StatelessWidget {
  const CardRestrictionForm({
    super.key,
    required this.operation,
    required this.state,
  });
  final CardRestrictionOperation operation;
  final CardRestrictionState state;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            cardRestrictionIntro(operation),
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              height: 20 / 14,
              color: context.colors.textPrimary,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 20),
          AppSelect<RestrictionCard>(
            label: S.current.cardServiceCard,
            hintText: S.current.cardServiceCardHint,
            labelSpacing: 8,
            labelStyle: certificateLabelStyle(context)
                .copyWith(height: 18 / 12),
            textStyle: certificateValueStyle(context).copyWith(
              color: state.card == null
                  ? context.colors.textDisabled
                  : context.colors.textPrimary,
            ),
            trailing: SizedBox.square(
              dimension: 20,
              child: AvpImage(
                image: state.card == null
                    ? '${AppConstants.baseImage}issuance_select_empty.svg'
                    : '${AppConstants.baseImage}card_features_chevron.svg',
              ),
            ),
            value: state.card,
            enabled: state.isEditable,
            options: [
              for (final card in state.catalog!.cards)
                AppSelectOption(
                  value: card,
                  label:
                      '‎${CardDisplayFormatter.format(card.number, separator: ' ')}',
                ),
            ],
            onChanged: context.read<CardRestrictionCubit>().selectCard,
          ),
          if (state.card != null) ...[
            const SizedBox(height: 12),
            CardRestrictionDetailsCard(card: state.card!),
          ],
          const SizedBox(height: 20),
          if (operation == CardRestrictionOperation.unblock) ...[
            const CardServiceDivider(),
            const SizedBox(height: 20),
          ],
          AppSelect<CardRestrictionReason>(
            label: operation == CardRestrictionOperation.block
                ? S.current.depositRestrictionReason
                : S.current.depositUnblockReason,
            hintText: S.current.depositRestrictionReasonHint,
            labelSpacing: 8,
            labelStyle: certificateLabelStyle(context)
                .copyWith(height: 18 / 12),
            textStyle: certificateValueStyle(context).copyWith(
              color: state.reason == null
                  ? context.colors.textDisabled
                  : context.colors.textPrimary,
            ),
            trailing: SizedBox.square(
              dimension: 20,
              child: AvpImage(
                image: state.reason == null
                    ? '${AppConstants.baseImage}issuance_select_empty.svg'
                    : '${AppConstants.baseImage}card_features_chevron.svg',
              ),
            ),
            value: state.reason,
            enabled: state.isEditable,
            options: [
              for (final reason in state.catalog!.reasons)
                AppSelectOption(
                  value: reason,
                  label: cardRestrictionReasonLabel(reason),
                ),
            ],
            onChanged: context.read<CardRestrictionCubit>().selectReason,
          ),
          const SizedBox(height: 20),
          Text(
            S.current.depositRestrictionDescription,
            style: certificateLabelStyle(context).copyWith(height: 18 / 12),
          ),
          const SizedBox(height: 8),
          AppTextField(
            hintText: S.current.depositRestrictionDescriptionHint,
            value: state.description,
            enabled: state.isEditable,
            textStyle: certificateValueStyle(context).copyWith(height: 20 / 14),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: context.read<CardRestrictionCubit>().updateDescription,
          ),
          const SizedBox(height: 20),
          const CardServiceDivider(),
          const SizedBox(height: 20),
          AppInvoice(
            totalAmount: CurrencyFormatter.format(state.catalog!.feeRial),
            walletBalance: CurrencyFormatter.format(
              state.catalog!.walletBalanceRial,
            ),
            lines: [
              AppInvoiceLine(
                id: operation.name,
                label: cardRestrictionTitle(operation),
                amount: CurrencyFormatter.format(state.catalog!.feeRial),
                icon: const SizedBox.shrink(),
              ),
            ],
            isExpanded: state.isInvoiceExpanded,
            onExpandedChanged: context
                .read<CardRestrictionCubit>()
                .updateInvoiceExpanded,
            zeroHeightDividers: true,
            backgroundColor: context.colors.surface,
            labelColor: context.colors.textTertiary,
            costIcon: const AvpImage(
              image: '${AppConstants.baseImage}chequebook_cost.svg',
              width: 20,
              height: 20,
            ),
            walletIcon: const AvpImage(
              image:
                  '${AppConstants.baseImage}dashboard_catalog_category_wallet.svg',
              width: 20,
              height: 20,
            ),
            isWalletBalanceSufficient: state.isWalletSufficient,
            title: S.current.issuancePayable,
            walletLabel: S.current.issuanceWallet,
            walletSufficientLabel: S.current.issuanceWalletSufficient,
            walletInsufficientLabel: S.current.issuanceWalletInsufficient,
          ),
          if (state.submissionStatus == RequestStatus.failure) ...[
            const SizedBox(height: 16),
            AppButton(
              label: S.current.cardRestrictionRefresh,
              isActive: state.isEditable,
              onPressed: context.read<CardRestrictionCubit>().fetchCatalog,
            ),
          ],
        ],
      ),
    );
  }
}
