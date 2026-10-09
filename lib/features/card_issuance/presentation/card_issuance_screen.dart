import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../data/mock/mock_card_issuance_repository.dart';
import '../domain/entities/issuance_data.dart';
import '../domain/repositories/card_issuance_repository.dart';
import 'cubit/card_issuance_cubit.dart';
import 'widgets/issuance_sections.dart';
import 'widgets/issuance_address_sheet.dart';

class CardIssuanceScreen extends StatefulWidget {
  const CardIssuanceScreen({
    super.key,
    this.repository,
    this.initialDepositNumber,
    this.onAssistantPressed,
    this.onTermsRequested,
    this.onCompleted,
  });
  final CardIssuanceRepository? repository;
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed, onTermsRequested;
  final ValueChanged<IssuanceReceipt>? onCompleted;
  @override
  State<CardIssuanceScreen> createState() => _CardIssuanceScreenState();
}

class _CardIssuanceScreenState extends State<CardIssuanceScreen> {
  late final CardIssuanceCubit cubit;
  final scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    cubit = CardIssuanceCubit(
      repository: widget.repository ?? MockCardIssuanceRepository(),
      initialDepositNumber: widget.initialDepositNumber,
    )..load();
  }

  @override
  void didUpdateWidget(covariant CardIssuanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      cubit.changeRepository(widget.repository ?? MockCardIssuanceRepository());
    }
  }

  @override
  void dispose() {
    cubit.close();
    scroll.dispose();
    super.dispose();
  }

  void _back() {
    if (cubit.state.status == IssuanceStatus.submitting) return;
    if (!cubit.back()) Navigator.of(context).maybePop();
  }

  void _terms() {
    if (widget.onTermsRequested != null) {
      widget.onTermsRequested!();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.issuanceTermsUnavailable)),
    );
  }

  Future<void> _deleteAddress(IssuanceAddress address) async {
    final remove = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceSubtle,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: AppDeleteAddressSheet(
            address: address.detail,
            postalCode: address.postalCode,
            onConfirm: () => Navigator.of(sheetContext).pop(true),
            onCancel: () => Navigator.of(sheetContext).pop(false),
          ),
        ),
      ),
    );
    if (mounted && remove == true) cubit.removeAddress(address.id);
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocConsumer<CardIssuanceCubit, CardIssuanceState>(
      bloc: cubit,
      listenWhen: (old, next) =>
          old.step != next.step || old.status != next.status,
      listener: (context, state) {
        if (scroll.hasClients && state.status != IssuanceStatus.submitting) {
          scroll.jumpTo(0);
        }
        if (state.status == IssuanceStatus.submitted && state.receipt != null) {
          widget.onCompleted?.call(state.receipt!);
        }
      },
      builder: (context, state) {
        final confirmation = state.step == IssuanceStep.confirmation;
        final stepNumber = state.step.index + 1;
        final title = switch (state.step) {
          IssuanceStep.selection => context.l10n.issuanceSelectionTitle,
          IssuanceStep.delivery => context.l10n.issuanceDeliveryTitle,
          IssuanceStep.confirmation => context.l10n.issuanceConfirmTitle,
        };
        final next = switch (state.step) {
          IssuanceStep.selection =>
            state.draft.noPhysicalCard
                ? context.l10n.issuanceNextConfirm
                : context.l10n.issuanceNextDelivery,
          IssuanceStep.delivery => context.l10n.issuanceNextConfirm,
          IssuanceStep.confirmation => context.l10n.issuanceEnd,
        };
        return PopScope<void>(
          canPop:
              state.status != IssuanceStatus.submitting &&
              (state.step == IssuanceStep.selection ||
                  state.status == IssuanceStatus.submitted),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) cubit.back();
          },
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: context.l10n.issuanceTitle,
                    showLeadingActions: false,
                    trailingIcon: issuanceIcon(
                      AppAssets.cardFeaturesBack,
                      size: 24,
                    ),
                    trailingTooltip: context.l10n.backLabel,
                    onTrailingPressed: _back,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                26,
                              ),
                              child: AppStepper(
                                key: const Key('issuance_stepper'),
                                currentStep: stepNumber,
                                totalSteps: 3,
                                progress: switch (state.step) {
                                  IssuanceStep.selection => .3,
                                  IssuanceStep.delivery => .6,
                                  IssuanceStep.confirmation => 1,
                                },
                                title: title,
                                supportingText: next,
                                semanticLabel: context.l10n
                                    .issuanceStepSemantic(stepNumber, 3, title),
                              ),
                            ),
                            Expanded(
                              child: _body(context, state, confirmation),
                            ),
                          ],
                        ),
                        if (state.status == IssuanceStatus.loaded ||
                            state.status == IssuanceStatus.submitting) ...[
                          Positioned(
                            left: 16,
                            bottom: confirmation ? 136 : 76,
                            child: AppAssistantButton(
                              key: const Key('issuance_assistant'),
                              onPressed: widget.onAssistantPressed ?? _back,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _footer(context, state, confirmation),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  Widget _body(
    BuildContext context,
    CardIssuanceState state,
    bool confirmation,
  ) {
    if (state.status == IssuanceStatus.initial ||
        state.status == IssuanceStatus.loading) {
      return Center(
        child: AppButton(
          onPressed: null,
          isLoading: true,
          label: context.l10n.dashboardLoading,
        ),
      );
    }
    if (state.status == IssuanceStatus.error ||
        state.status == IssuanceStatus.empty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.status == IssuanceStatus.empty
                    ? context.l10n.issuanceEmpty
                    : context.l10n.dashboardLoadError,
              ),
              const SizedBox(height: 16),
              AppButton(
                key: const Key('issuance_retry'),
                onPressed: cubit.load,
                label: context.l10n.dashboardRetry,
              ),
            ],
          ),
        ),
      );
    }
    if (state.status == IssuanceStatus.submitted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.receipt!.isMock
                    ? context.l10n.issuanceMockComplete
                    : context.l10n.issuanceComplete,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(state.receipt!.reference),
              const SizedBox(height: 24),
              AppButton(
                key: const Key('issuance_done'),
                onPressed: () => Navigator.of(context).maybePop(),
                label: context.l10n.issuanceDone,
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      key: const Key('issuance_scroll'),
      controller: scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(16, 0, 16, confirmation ? 196 : 136),
      child: AbsorbPointer(
        absorbing: !state.isEditable,
        child: switch (state.step) {
          IssuanceStep.selection => IssuanceSelection(
            state: state,
            cubit: cubit,
          ),
          IssuanceStep.delivery => IssuanceDelivery(
            state: state,
            cubit: cubit,
            onAddAddress: () => showIssuanceAddressSheet(context, cubit),
            onDeleteAddress: _deleteAddress,
          ),
          IssuanceStep.confirmation => IssuanceConfirmation(
            state: state,
            cubit: cubit,
          ),
        },
      ),
    );
  }

  Widget _footer(
    BuildContext context,
    CardIssuanceState state,
    bool confirmation,
  ) => Container(
    color: context.colors.surfaceSubtle,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (confirmation) ...[
          Container(
            key: const Key('issuance_terms_row'),
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppCardIssuanceColors.termsSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Semantics(
                  label: context.l10n.issuanceTerms,
                  child: AppCheckbox(
                    key: const Key('issuance_terms_checkbox'),
                    value: state.draft.termsAccepted,
                    size: AppCheckboxSize.md,
                    onChanged: state.isEditable ? cubit.acceptTerms : null,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Wrap(
                    spacing: 2,
                    children: [
                      InkWell(
                        key: const Key('issuance_terms_link'),
                        onTap: _terms,
                        child: Text(
                          context.l10n.issuanceTerms,
                          style: AppTypography.bodySmall.copyWith(
                            height: 18 / 12,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            color: context.colors.primaryHover,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        context.l10n.issuanceTermsPrompt,
                        style: AppTypography.bodySmall.copyWith(
                          height: 18 / 12,
                          letterSpacing: 0,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        AppButton(
          key: const Key('issuance_continue'),
          size: AppButtonSize.lg,
          label: confirmation
              ? context.l10n.issuanceSubmit
              : context.l10n.issuanceNext,
          labelStyle: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            letterSpacing: 0,
          ),
          constrainLabel: true,
          isLoading: state.status == IssuanceStatus.submitting,
          onPressed: state.canContinue
              ? () {
                  if (confirmation) {
                    cubit.submit();
                  } else {
                    cubit.next();
                  }
                }
              : null,
        ),
      ],
    ),
  );
}
