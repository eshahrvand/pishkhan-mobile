import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../domain/virtual_card_data.dart';
import '../data/mock_virtual_card_repository.dart';
import 'cubit/virtual_card_cubit.dart';

class VirtualCardRequestScreen extends StatefulWidget {
  const VirtualCardRequestScreen({
    super.key,
    this.repository,
    this.initialDepositNumber,
    this.onTermsRequested,
    this.onSubmitted,
  });
  final VirtualCardRepository? repository;
  final String? initialDepositNumber;
  final VoidCallback? onTermsRequested;
  final ValueChanged<VirtualCardReceipt>? onSubmitted;
  @override
  State<VirtualCardRequestScreen> createState() =>
      _VirtualCardRequestScreenState();
}

class _VirtualCardRequestScreenState extends State<VirtualCardRequestScreen> {
  late VirtualCardCubit cubit;
  final count = TextEditingController();
  @override
  void initState() {
    super.initState();
    _createCubit();
  }

  void _createCubit() => cubit = VirtualCardCubit(
    repository: widget.repository ?? MockVirtualCardRepository(),
    initialDepositNumber: widget.initialDepositNumber,
  )..load();
  @override
  void didUpdateWidget(VirtualCardRequestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.initialDepositNumber != widget.initialDepositNumber) {
      cubit.close();
      count.clear();
      _createCubit();
    }
  }

  @override
  void dispose() {
    cubit.close();
    count.dispose();
    super.dispose();
  }

  void _back() {
    if (cubit.state.status != VirtualCardStatus.submitting &&
        Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  TextStyle _body(BuildContext context) => AppTypography.bodyMedium.copyWith(
    height: 20 / 14,
    letterSpacing: 0,
    color: AppPasswordServiceColors.title,
  );
  TextStyle _label(BuildContext context) => AppTypography.bodySmall.copyWith(
    height: 18 / 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: context.colors.textSecondary,
  );
  Widget _icon(String path) =>
      SizedBox.square(dimension: 20, child: SvgPicture.asset(path));
  Widget _notice(BuildContext context, String text, {Key? key}) => Container(
    key: key,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppPalette.blueGray100,
      borderRadius: AppRadius.borderSm,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _icon(AppAssets.passwordCameraInfo),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: _label(context)
                .copyWith(color: AppPasswordServiceColors.body),
          ),
        ),
      ],
    ),
  );
  void _receipt(VirtualCardReceipt receipt) {
    widget.onSubmitted?.call(receipt);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: cubit,
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<VirtualCardCubit, VirtualCardState>(
        listenWhen: (a, b) => a.receipt != b.receipt && b.receipt != null,
        listener: (context, state) => _receipt(state.receipt!),
        builder: (context, state) => PopScope<void>(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: context.l10n.virtualRequestTitle,
                    showLeadingActions: false,
                    trailingIcon: SizedBox.square(
                      dimension: 24,
                      child: SvgPicture.asset(AppAssets.virtualRequestBack),
                    ),
                    trailingTooltip: context.l10n.backLabel,
                    onTrailingPressed: _back,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: _content(context, state),
                    ),
                  ),
                  if (state.catalog != null &&
                      state.status != VirtualCardStatus.empty)
                    _footer(context, state),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Widget _content(BuildContext context, VirtualCardState state) {
    final l = context.l10n;
    if (state.status == VirtualCardStatus.loading ||
        state.status == VirtualCardStatus.initial) {
      return AppButton(
        onPressed: null,
        isLoading: true,
        label: l.dashboardLoading,
      );
    }
    if (state.status == VirtualCardStatus.failed ||
        state.status == VirtualCardStatus.empty) {
      return Column(
        children: [
          Text(
            state.status == VirtualCardStatus.empty
                ? l.virtualRequestEmpty
                : l.dashboardLoadError,
          ),
          const SizedBox(height: 12),
          AppButton(
            onPressed: () {
              count.clear();
              cubit.load();
            },
            label: l.dashboardRetry,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.virtualRequestPrompt,
          style: _body(context).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        _notice(
          context,
          l.virtualRequestNotice,
          key: const Key('virtual_notice'),
        ),
        const SizedBox(height: 20),
        IgnorePointer(
          ignoring: !state.editable,
          child: AppSelect<String>(
            key: const Key('virtual_deposit'),
            label: l.virtualRequestDepositLabel,
            hintText: l.virtualRequestDepositHint,
            value: state.depositId,
            options: [
              for (final d in state.catalog!.deposits)
                AppSelectOption(value: d.id, label: d.number),
            ],
            onChanged: cubit.selectDeposit,
            labelSpacing: 8,
            labelStyle: _label(context),
            textStyle: _body(context).copyWith(
              color: state.depositId == null
                  ? AppPalette.gray400
                  : context.colors.textPrimary,
            ),
            trailing: _icon(
              state.depositId == null
                  ? AppAssets.issuanceSelectEmpty
                  : AppAssets.cardFeaturesChevron,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(l.virtualRequestCount, style: _label(context)),
        const SizedBox(height: 8),
        AppTextField(
          key: const Key('virtual_count'),
          controller: count,
          enabled: state.editable,
          hintText: l.virtualRequestCountHint,
          hintColor: AppPalette.gray400,
          textStyle: _body(context),
          textAlign: TextAlign.right,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.number,
          normalizeDigits: true,
          focusRing: AppTextFieldFocusRing.none,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          errorText: state.countText.isNotEmpty && !state.validCount
              ? l.virtualRequestCountError(state.catalog!.maxCount)
              : null,
          onChanged: cubit.countChanged,
        ),
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
        if (state.quote != null)
          AppInvoice(
            key: const Key('virtual_invoice'),
            totalAmount: CurrencyFormatter.format(state.quote!.totalRial),
            walletBalance: CurrencyFormatter.format(
              state.quote!.walletBalanceRial,
            ),
            lines: [
              AppInvoiceLine(
                id: 'virtual-unit-fee',
                label: l.virtualRequestUnitFee,
                amount: CurrencyFormatter.format(state.quote!.perCardFeeRial),
                icon: SizedBox.square(
                  dimension: 20,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20 * .0833,
                        top: 20 * .1667,
                        key: const Key('virtual_card_fee_art'),
                        width: 16.2878,
                        height: 12.9544,
                        child: SvgPicture.asset(AppAssets.virtualRequestCard),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            isExpanded: state.expanded,
            onExpandedChanged: cubit.setExpanded,
            isWalletBalanceSufficient: state.quote!.walletSufficient,
            title: l.issuancePayable,
            walletLabel: l.walletBalanceTitle,
            backgroundColor: context.colors.surface,
            labelColor: context.colors.textTertiary,
            walletSufficientLabel: l.issuanceWalletSufficient,
            walletInsufficientLabel: l.issuanceWalletInsufficient,
            zeroHeightDividers: true,
          )
        else
          _notice(
            context,
            l.virtualRequestFeeNotice(
              CurrencyFormatter.format(state.catalog!.indicativePerCardFeeRial),
            ),
          ),
        if (state.status == VirtualCardStatus.quoting) ...[
          const SizedBox(height: 12),
          Text(l.virtualRequestQuoting),
        ],
        if (state.failure != null) ...[
          const SizedBox(height: 12),
          Text(
            l.dashboardLoadError,
            style: _body(context).copyWith(color: context.colors.error),
          ),
          AppButton(
            onPressed: state.editable
                ? (state.quote == null ? cubit.refreshQuote : cubit.submit)
                : null,
            label: l.dashboardRetry,
            variant: AppButtonVariant.text,
          ),
        ],
      ],
    );
  }

  Widget _footer(BuildContext context, VirtualCardState state) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            children: [
              AppCheckbox(
                key: const Key('virtual_terms'),
                value: state.terms,
                size: AppCheckboxSize.md,
                onChanged: state.status == VirtualCardStatus.ready
                    ? cubit.acceptTerms
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  children: [
                    InkWell(
                      onTap:
                          widget.onTermsRequested ??
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.issuanceTermsUnavailable,
                              ),
                            ),
                          ),
                      child: Text(
                        context.l10n.issuanceTerms,
                        style: _label(context).copyWith(
                          color: context.colors.primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      ' ${context.l10n.issuanceTermsPrompt}',
                      style: _label(context).copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          key: const Key('virtual_submit'),
          onPressed: state.canSubmit
              ? () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  cubit.submit();
                }
              : null,
          label: context.l10n.virtualRequestSubmit,
          size: AppButtonSize.lg,
          constrainLabel: true,
          isLoading: state.status == VirtualCardStatus.submitting,
          disabledAppearance: AppButtonDisabledAppearance.service,
        ),
      ],
    ),
  );
}
