import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import '../../domain/entities/issuance_data.dart';
import '../cubit/card_issuance_cubit.dart';

Widget issuanceIcon(String path, {double size = 20}) => SizedBox(
  width: size,
  height: size,
  child: SvgPicture.asset(path, width: size, height: size),
);
TextStyle issuanceBody(BuildContext context, {bool medium = false}) =>
    AppTypography.bodyMedium.copyWith(
      color: context.colors.textPrimary,
      fontWeight: medium ? FontWeight.w500 : FontWeight.w400,
      height: 20 / 14,
      letterSpacing: 0,
    );
String issuanceTypeLabel(BuildContext context, IssuanceType value) =>
    switch (value) {
      IssuanceType.newNumber => context.l10n.issuanceNewNumber,
      IssuanceType.existingNumber => context.l10n.issuanceExistingNumber,
    };

class IssuanceDivider extends StatelessWidget {
  const IssuanceDivider({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 0,
    width: double.infinity,
    child: OverflowBox(
      minHeight: 1,
      maxHeight: 1,
      child: SvgPicture.asset(AppAssets.issuanceDivider, fit: BoxFit.fill),
    ),
  );
}

class IssuanceSelect<T> extends StatelessWidget {
  const IssuanceSelect({
    super.key,
    required this.options,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.hintColor,
  });
  final List<AppSelectOption<T>> options;
  final String label, hint;
  final T? value;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final Color? hintColor;
  @override
  Widget build(BuildContext context) => AppSelect<T>(
    options: options,
    value: value,
    onChanged: onChanged,
    label: label,
    hintText: hint,
    enabled: enabled,
    labelSpacing: 8,
    textStyle: issuanceBody(context).copyWith(
      color: value == null
          ? hintColor ?? AppCardIssuanceColors.inputHint
          : context.colors.textPrimary,
    ),
    labelStyle: AppTypography.bodySmall.copyWith(
      fontWeight: FontWeight.w500,
      color: context.colors.textSecondary,
      height: 18 / 12,
      letterSpacing: 0,
    ),
    trailing: issuanceIcon(
      value == null
          ? AppAssets.issuanceSelectEmpty
          : AppAssets.cardFeaturesChevron,
    ),
  );
}

class IssuanceToggleRow extends StatelessWidget {
  const IssuanceToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onChanged == null ? null : () => onChanged!(!value),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: label,
          child: AppToggle(
            value: value,
            onChanged: onChanged,
            appearance: AppToggleAppearance.issuance,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: issuanceBody(
              context,
              medium: true,
            ).copyWith(color: context.colors.textSecondary),
          ),
        ),
      ],
    ),
  );
}

class IssuanceSelection extends StatelessWidget {
  const IssuanceSelection({
    super.key,
    required this.state,
    required this.cubit,
  });
  final CardIssuanceState state;
  final CardIssuanceCubit cubit;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      IssuanceSelect<String>(
        key: const Key('issuance_deposit'),
        options: [
          for (final d in state.catalog!.deposits)
            AppSelectOption(value: d.id, label: d.number),
        ],
        value: state.draft.depositId,
        label: context.l10n.issuanceDeposit,
        hint: context.l10n.issuanceDepositHint,
        onChanged: (v) {
          if (v != null) cubit.selectDeposit(v);
        },
      ),
      if (state.deposit != null) ...[
        const SizedBox(height: 12),
        Container(
          key: const Key('issuance_current_card'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _CurrentCardRow(
                label: context.l10n.issuanceCurrentCard,
                value: state.deposit!.cardNumber,
                asset: AppAssets.issuanceCredit,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 0,
                width: double.infinity,
                child: OverflowBox(
                  minHeight: .5,
                  maxHeight: .5,
                  child: SvgPicture.asset(
                    AppAssets.issuanceCardDivider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _CurrentCardRow(
                label: context.l10n.issuanceExpiry,
                value: state.deposit!.expiry,
                asset: AppAssets.issuanceCalendar,
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 20),
      const IssuanceDivider(),
      const SizedBox(height: 20),
      IssuanceSelect<IssuanceType>(
        key: const Key('issuance_type'),
        options: [
          for (final type in state.catalog!.types)
            AppSelectOption(
              value: type,
              label: issuanceTypeLabel(context, type),
            ),
        ],
        value: state.draft.type,
        label: context.l10n.issuanceType,
        hint: context.l10n.issuanceTypeHint,
        onChanged: (v) {
          if (v != null) cubit.selectType(v);
        },
      ),
      const SizedBox(height: 20),
      const IssuanceDivider(),
      const SizedBox(height: 20),
      IssuanceToggleRow(
        key: const Key('issuance_no_physical'),
        label: context.l10n.issuanceNoPhysical,
        value: state.draft.noPhysicalCard,
        onChanged: cubit.setNoPhysicalCard,
      ),
    ],
  );
}

class _CurrentCardRow extends StatelessWidget {
  const _CurrentCardRow({
    required this.label,
    required this.value,
    required this.asset,
  });
  final String label, value, asset;
  @override
  Widget build(BuildContext context) => Row(
    textDirection: TextDirection.ltr,
    children: [
      Expanded(
        child: Text(
          value,
          textDirection: TextDirection.ltr,
          style: issuanceBody(context, medium: true),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        textAlign: TextAlign.right,
        style: issuanceBody(context)
            .copyWith(color: context.colors.textTertiary),
      ),
      const SizedBox(width: 8),
      issuanceIcon(asset),
    ],
  );
}

class IssuanceDelivery extends StatefulWidget {
  const IssuanceDelivery({
    super.key,
    required this.state,
    required this.cubit,
    required this.onAddAddress,
    required this.onDeleteAddress,
  });
  final CardIssuanceState state;
  final CardIssuanceCubit cubit;
  final VoidCallback onAddAddress;
  final ValueChanged<IssuanceAddress> onDeleteAddress;
  @override
  State<IssuanceDelivery> createState() => _IssuanceDeliveryState();
}

class _IssuanceDeliveryState extends State<IssuanceDelivery> {
  late final name = TextEditingController(
    text: widget.state.draft.recipient.name,
  );
  late final national = TextEditingController(
    text: widget.state.draft.recipient.nationalId,
  );
  late final mobile = TextEditingController(
    text: widget.state.draft.recipient.mobile,
  );
  late final agentName = TextEditingController(
    text: widget.state.draft.agent.name,
  );
  late final agentCode = TextEditingController(
    text: widget.state.draft.agent.code,
  );
  @override
  void dispose() {
    name.dispose();
    national.dispose();
    mobile.dispose();
    agentName.dispose();
    agentCode.dispose();
    super.dispose();
  }

  void _recipient(String _) => widget.cubit.setRecipient(
    DeliveryPerson(
      name: name.text,
      nationalId: national.text,
      mobile: mobile.text,
    ),
  );
  void _agent(String _) => widget.cubit.setAgent(
    BankAgent(name: agentName.text, code: agentCode.text),
  );
  @override
  Widget build(BuildContext context) {
    final state = widget.state, cubit = widget.cubit, l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IssuanceSelect<String>(
          key: const Key('issuance_address'),
          hintColor: context.colors.textDisabled,
          options: [
            for (final a in state.catalog!.addresses)
              AppSelectOption(value: a.id, label: a.title),
          ],
          value: state.draft.addressId,
          label: state.address == null
              ? l.issuanceAddress
              : l.issuanceSelectAddress,
          hint: l.issuanceAddressHint,
          onChanged: (v) {
            if (v != null) cubit.selectAddress(v);
          },
        ),
        const SizedBox(height: 12),
        if (state.address != null)
          AppAddressCard(
            key: const Key('issuance_address_card'),
            variant: AppAddressCardVariant.delivery,
            deleteLabel: l.issuanceDeleteAddress,
            address: state.address!.detail,
            onDeleteTap: () => widget.onDeleteAddress(state.address!),
          )
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: 139,
              height: 20,
              child: AppButton(
                key: const Key('issuance_add_address'),
                size: AppButtonSize.sm,
                variant: AppButtonVariant.text,
                horizontalPadding: 0,
                foregroundColor: context.colors.primary,
                label: l.issuanceAddAddress,
                labelStyle: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 18 / 12,
                  letterSpacing: 0,
                ),
                contentGap: 8,
                constrainLabel: true,
                leadingIcon: issuanceIcon(AppAssets.issuancePlus),
                onPressed: widget.onAddAddress,
              ),
            ),
          ),
        const SizedBox(height: 20),
        const IssuanceDivider(),
        const SizedBox(height: 20),
        IssuanceToggleRow(
          key: const Key('issuance_other_recipient'),
          label: l.issuanceOtherRecipient,
          value: state.draft.otherRecipient,
          onChanged: cubit.setOtherRecipient,
        ),
        if (state.draft.otherRecipient) ...[
          const SizedBox(height: 16),
          AppTextField(
            key: const Key('issuance_recipient_name'),
            controller: name,
            label: l.issuanceRecipientName,
            onChanged: _recipient,
          ),
          const SizedBox(height: 12),
          AppTextField(
            key: const Key('issuance_recipient_national'),
            controller: national,
            label: l.issuanceNationalId,
            keyboardType: TextInputType.number,
            normalizeDigits: true,
            onChanged: _recipient,
          ),
          const SizedBox(height: 12),
          AppTextField(
            key: const Key('issuance_recipient_mobile'),
            controller: mobile,
            label: l.issuanceRecipientMobile,
            keyboardType: TextInputType.phone,
            normalizeDigits: true,
            onChanged: _recipient,
          ),
        ],
        const SizedBox(height: 20),
        const IssuanceDivider(),
        const SizedBox(height: 20),
        IssuanceToggleRow(
          key: const Key('issuance_agent'),
          label: l.issuanceIncludeAgent,
          value: state.draft.includeAgent,
          onChanged: cubit.setIncludeAgent,
        ),
        if (state.draft.includeAgent) ...[
          const SizedBox(height: 16),
          AppTextField(
            key: const Key('issuance_agent_name'),
            controller: agentName,
            label: l.issuanceAgentName,
            onChanged: _agent,
          ),
          const SizedBox(height: 12),
          AppTextField(
            key: const Key('issuance_agent_code'),
            controller: agentCode,
            label: l.issuanceAgentCode,
            normalizeDigits: true,
            onChanged: _agent,
          ),
        ],
      ],
    );
  }
}

class IssuanceConfirmation extends StatelessWidget {
  const IssuanceConfirmation({
    super.key,
    required this.state,
    required this.cubit,
  });
  final CardIssuanceState state;
  final CardIssuanceCubit cubit;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final small = AppTypography.bodySmall.copyWith(
      height: 18 / 12,
      letterSpacing: 0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const Key('issuance_summary'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppCardIssuanceColors.summarySurface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppShadows.cardList,
          ),
          child: Column(
            children: [
              Semantics(
                button: true,
                expanded: state.summaryExpanded,
                child: InkWell(
                  key: const Key('issuance_summary_toggle'),
                  onTap: state.isEditable
                      ? () => cubit.expandSummary(!state.summaryExpanded)
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.issuanceSummary,
                          style: small.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppCardIssuanceColors.summaryTitle,
                          ),
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: state.summaryExpanded ? 0 : 2,
                        child: issuanceIcon(AppAssets.issuanceSummaryChevron),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.summaryExpanded) ...[
                const SizedBox(height: 16),
                _SummaryRow(
                  label: l.issuanceDepositNumber,
                  value: state.deposit!.number,
                  asset: AppAssets.issuanceSummaryDivider,
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: l.issuanceOperation,
                  value: l.issuanceTitle,
                  asset: AppAssets.issuanceSummaryDividerOperation,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        const IssuanceDivider(),
        const SizedBox(height: 20),
        AppInvoice(
          key: const Key('issuance_invoice'),
          title: l.issuancePayable,
          walletLabel: l.issuanceWallet,
          backgroundColor: context.colors.surface,
          labelColor: context.colors.textTertiary,
          totalAmount: CurrencyFormatter.format(state.totalRial),
          walletBalance: CurrencyFormatter.format(
            state.catalog!.walletBalanceRial,
          ),
          lines: [
            for (final fee in state.fees)
              AppInvoiceLine(
                id: fee.kind.name,
                label: switch (fee.kind) {
                  IssuanceFeeKind.print => l.issuancePrintFee,
                  IssuanceFeeKind.identity => l.issuanceIdentityFee,
                  IssuanceFeeKind.delivery => l.issuanceDeliveryFee,
                },
                amount: CurrencyFormatter.format(fee.amountRial),
                icon: switch (fee.kind) {
                  IssuanceFeeKind.print => AppInvoiceIcons.print(),
                  IssuanceFeeKind.identity => AppInvoiceIcons.identityVideo(),
                  IssuanceFeeKind.delivery => AppInvoiceIcons.delivery(),
                },
              ),
          ],
          isExpanded: state.invoiceExpanded,
          onExpandedChanged: cubit.expandInvoice,
          walletSufficientLabel: l.issuanceWalletSufficient,
          walletInsufficientLabel: l.issuanceWalletInsufficient,
          isWalletBalanceSufficient: state.walletSufficient,
        ),
        if (state.failure != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              l.issuanceSubmitError,
              style: small.copyWith(color: context.colors.error),
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.asset,
  });
  final String label, value, asset;
  @override
  Widget build(BuildContext context) {
    final small = AppTypography.bodySmall.copyWith(
      height: 18 / 12,
      letterSpacing: 0,
    );
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Flexible(
          child: Text(
            value,
            style: small.copyWith(
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: .5,
            child: SvgPicture.asset(asset, fit: BoxFit.fill),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: small.copyWith(color: context.colors.textTertiary)),
      ],
    );
  }
}
