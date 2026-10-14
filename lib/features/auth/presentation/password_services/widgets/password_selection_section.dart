import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pishkhan_mobile/features/auth/domain/entities/password_data.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_sheets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

class PasswordSelectionSection extends StatelessWidget {
  const PasswordSelectionSection({
    super.key,
    required this.state,
    required this.selectOperation,
  });
  final SecondPasswordState state;
  final bool selectOperation;
  String _kind(BuildContext context, PasswordCardKind kind) => switch (kind) {
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
              AppSelectOption(value: kind, label: _kind(context, kind)),
          ],
          change: cubit.selectKind,
        ),
        const SizedBox(height: 20),
        PasswordServiceSelect(
          title: S.current.passwordCardNumber,
          hint: S.current.passwordCardNumberHint,
          value: state.cardId,
          options: [
            for (final card in state.catalog!.cards.where(
              (c) => c.kind == (state.kind ?? PasswordCardKind.resalat),
            ))
              AppSelectOption(value: card.id, label: card.number),
          ],
          change: cubit.selectCard,
        ),
        const SizedBox(height: 20),
        PasswordServiceSelect(
          title: state.card != null && state.secondPasswordSelected
              ? S.current.passwordOperation
              : S.current.passwordType,
          hint: S.current.passwordTypeHint,
          value: state.secondPasswordSelected ? 'second' : null,
          options: [
            AppSelectOption(
              value: 'first',
              label: S.current.passwordFirst,
              supportingText: S.current.passwordFirstDescription,
            ),
            AppSelectOption(
              value: 'second',
              label: S.current.passwordSecond,
              supportingText: S.current.passwordSecondDescription,
            ),
          ],
          change: (value) {
            if (value == 'second') {
              cubit.selectSecondPassword();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.current.passwordUnsupported)),
              );
            }
          },
        ),
        if (state.card != null && state.secondPasswordSelected) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 0,
            child: OverflowBox(
              minHeight: 1,
              maxHeight: 1,
              child: SvgPicture.asset(
                AppAssets.issuanceDivider,
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
              operationSelection: true,
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
              change: cubit.chooseOperation,
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
        if (state.selectionComplete && !state.isChange) ...[
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
            isWalletBalanceSufficient: state.walletSufficient,
            walletSufficientLabel: S.current.issuanceWalletSufficient,
            walletInsufficientLabel: S.current.issuanceWalletInsufficient,
          ),
        ],
        if (state.card != null &&
            state.operation != null &&
            !state.card!.supports(state.operation!)) ...[
          const SizedBox(height: 12),
          Text(S.current.passwordUnsupported),
        ],
      ],
    );
  }
}

class PasswordServiceSelect<T> extends StatelessWidget {
  const PasswordServiceSelect({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.options,
    required this.change,
    this.operationSelection = false,
  });
  final String title, hint;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T> change;
  final bool operationSelection;
  @override
  Widget build(BuildContext context) {
    return AppSelect<T>(
      label: title,
      hintText: hint,
      value: value,
      options: options,
      onChanged: change,
      labelSpacing: 8,
      labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
        height: 18 / 12,
        fontWeight: FontWeight.w500,
        color: context.colors.textSecondary,
        letterSpacing: 0,
      ),
      textStyle: passwordBody(context).copyWith(
        fontWeight: FontWeight.w400,
        color: value == null
            ? AppPasswordServiceColors.hint
            : context.colors.textPrimary,
      ),
      trailing: SizedBox.square(
        dimension: 20,
        child: SvgPicture.asset(
          value == null
              ? AppAssets.issuanceSelectEmpty
              : AppAssets.cardFeaturesChevron,
          fit: BoxFit.contain,
        ),
      ),
      menuBuilder: (context, options, selected) => showPasswordOptions(
        context,
        title,
        options,
        selected,
        scrimAsset: operationSelection
            ? AppAssets.passwordOperationScrim
            : null,
      ),
    );
  }
}
