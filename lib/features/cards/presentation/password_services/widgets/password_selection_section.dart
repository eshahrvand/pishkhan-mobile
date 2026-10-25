import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/cards/domain/entities/password_data.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';

import 'password_service_select.dart';

import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

class PasswordSelectionSection extends StatelessWidget {
  const PasswordSelectionSection({
    super.key,
    required this.state,
    required this.selectOperation,
  });
  final SecondPasswordState state;
  final bool selectOperation;
  String _kind(PasswordCardKind kind) => switch (kind) {
    PasswordCardKind.resalat => S.current.cardFeatureResalat,
    PasswordCardKind.coupon => S.current.cardFeatureCoupon,
    PasswordCardKind.gift => S.current.cardFeatureGift,
    PasswordCardKind.family => S.current.cardFeatureFamily,
  };
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SecondPasswordCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.passwordSelectionPrompt,
          style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        PasswordServiceSelect(
          title: S.current.passwordCardType,
          hint: S.current.passwordCardTypeHint,
          value: state.kind,
          options: [
            for (final kind in PasswordCardKind.values)
              AppSelectOption(value: kind, label: _kind(kind)),
          ],
          change: cubit.selectKind,
        ),
        const SizedBox(height: 20),
        PasswordServiceSelect(
          title: S.current.passwordCardNumber,
          hint: S.current.passwordCardNumberHint,
          value: state.card,
          options: [
            for (final card in state.cardsForSelectedKind)
              AppSelectOption(value: card, label: card.number),
          ],
          change: cubit.selectCard,
        ),
        const SizedBox(height: 20),
        PasswordServiceSelect(
          title: state.card != null && state.passwordType == PasswordType.second
              ? S.current.passwordOperation
              : S.current.passwordType,
          hint: S.current.passwordTypeHint,
          value: state.passwordType,
          options: [
            AppSelectOption(
              value: PasswordType.first,
              label: S.current.passwordFirst,
              supportingText: S.current.passwordFirstDescription,
            ),
            AppSelectOption(
              value: PasswordType.second,
              label: S.current.passwordSecond,
              supportingText: S.current.passwordSecondDescription,
            ),
          ],
          change: cubit.selectPasswordType,
        ),
        if (state.card != null &&
            state.passwordType == PasswordType.second) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 0,
            child: OverflowBox(
              minHeight: 1,
              maxHeight: 1,
              child: AvpImage(
                image: '${AppConstants.baseImage}issuance_divider.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (selectOperation)
            PasswordServiceSelect<PasswordOperation>(
              title: S.current.passwordOperation,
              hint: S.current.passwordOperationHint,
              value: state.operation,
              options: [
                AppSelectOption(
                  value: PasswordOperation.changePassword,
                  label: S.current.passwordChange,
                ),
                AppSelectOption(
                  value: PasswordOperation.forgotPassword,
                  label: S.current.passwordForgot,
                ),
              ],
              change: cubit.selectOperationType,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.current.passwordOperation,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 18 / 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  hintText: S.current.passwordSetSecond,
                  hintColor: context.colors.textSecondary,
                  readOnly: true,
                  textStyle: passwordBody(context),
                ),
              ],
            ),
        ],
        if (state.isSelectionComplete && !state.isChange) ...[
          const SizedBox(height: 20),
          AppInvoice(
            totalAmount: CurrencyFormatter.format(state.catalog!.feeRial),
            walletBalance: CurrencyFormatter.format(
              state.catalog!.walletBalanceRial,
            ),
            lines: const [],
            isExpanded: false,
            onExpandedChanged: (_) {},
            showToggle: false,
            title: S.current.issuancePayable,
            walletLabel: S.current.walletBalanceTitle,
            backgroundColor: context.colors.surface,
            borderRadius: BorderRadius.zero,
            zeroHeightDividers: true,
            labelColor: context.colors.textTertiary,
            isWalletBalanceSufficient: state.isWalletSufficient,
            walletSufficientLabel: S.current.issuanceWalletSufficient,
            walletInsufficientLabel: S.current.issuanceWalletInsufficient,
          ),
        ],
        if (state.card != null &&
            state.operation != null &&
            !state.isOperationSupported) ...[
          const SizedBox(height: 12),
          Text(S.current.passwordUnsupported),
        ],
      ],
    );
  }
}
