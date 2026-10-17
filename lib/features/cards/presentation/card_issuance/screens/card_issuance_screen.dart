import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../widgets/issuance_address_sheet.dart';
import '../widgets/issuance_footer.dart';
import '../widgets/issuance_content.dart';

import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../domain/entities/issuance_data.dart';
import '../cubit/card_issuance_cubit.dart';
import '../widgets/issuance_sections.dart';

class CardIssuanceScreen extends StatefulWidget {
  const CardIssuanceScreen({
    super.key,
    this.initialDepositNumber,
    this.onAssistantPressed,
    this.onTermsRequested,
    this.onCompleted,
  });

  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed, onTermsRequested;
  final ValueChanged<IssuanceReceipt>? onCompleted;

  @override
  State<CardIssuanceScreen> createState() => _CardIssuanceScreenState();
}

class _CardIssuanceScreenState extends State<CardIssuanceScreen> {
  final scroll = ScrollController();

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation(
    BuildContext context,
    CardIssuanceState state,
  ) async {
    switch (state.navigation) {
      case FlowNavigation.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<CardIssuanceCubit>().handleExitConfirmationResult(
            confirmed,
          );
        }
      case FlowNavigation.back:
        // Wait for PopScope to rebuild with the authorized exit intent.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case FlowNavigation.home:
        NavigationActions.returnHome(context);
      case null:
        break;
    }
  }

  Future<void> _handleEffect(
    BuildContext context,
    CardIssuanceState state,
  ) async {
    switch (state.effect) {
      case IssuanceTermsRequested():
        if (widget.onTermsRequested != null) {
          widget.onTermsRequested!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.issuanceTermsUnavailable)),
          );
        }
      case IssuanceAddressRequested():
        await showIssuanceAddressSheet(
          context,
          context.read<CardIssuanceCubit>(),
        );
      case IssuanceAddressRemovalRequested(:final address):
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: context.colors.surfaceSubtle,
          builder: (sheetContext) => SafeArea(
            child: SingleChildScrollView(
              child: AppDeleteAddressSheet(
                address: address.detail,
                postalCode: address.postalCode,
                onConfirm: () {
                  context.read<CardIssuanceCubit>().removeAddress(address.id);
                  Navigator.of(sheetContext).pop();
                },
                onCancel: () => Navigator.of(sheetContext).pop(),
              ),
            ),
          ),
        );
      case null:
        break;
    }
    if (!context.mounted) return;
  }

  void _handleProgress(BuildContext context, CardIssuanceState state) {
    if (scroll.hasClients && state.submissionStatus != RequestStatus.loading) {
      scroll.jumpTo(0);
    }
    if (state.submissionStatus == RequestStatus.success &&
        state.receipt != null) {
      widget.onCompleted?.call(state.receipt!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardIssuanceCubit>(
      create: (_) =>
          CardIssuanceCubit(initialDepositNumber: widget.initialDepositNumber)
            ..fetchIssuanceCatalog(),
      child: BlocListener<CardIssuanceCubit, CardIssuanceState>(
        listenWhen: (previous, current) =>
            previous.navigationId != current.navigationId,
        listener: _handleNavigation,
        child: BlocListener<CardIssuanceCubit, CardIssuanceState>(
          listenWhen: (previous, current) =>
              previous.effectId != current.effectId,
          listener: _handleEffect,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocConsumer<CardIssuanceCubit, CardIssuanceState>(
              listenWhen: (previous, current) =>
                  previous.step != current.step ||
                  previous.status != current.status ||
                  previous.submissionStatus != current.submissionStatus,
              listener: _handleProgress,
              buildWhen: (previous, current) =>
                  previous.addressSavedId != current.addressSavedId ||
                  previous.navigation != current.navigation ||
                  previous.isAddressFormError != current.isAddressFormError ||
                  previous.deposit != current.deposit ||
                  previous.address != current.address ||
                  previous.selectionComplete != current.selectionComplete ||
                  previous.deliveryComplete != current.deliveryComplete ||
                  previous.fees != current.fees ||
                  previous.totalRial != current.totalRial ||
                  previous.walletSufficient != current.walletSufficient ||
                  previous.editable != current.editable ||
                  previous.canContinue != current.canContinue ||
                  previous.request != current.request ||
                  previous.status != current.status ||
                  previous.submissionStatus != current.submissionStatus ||
                  previous.catalog != current.catalog ||
                  previous.draft != current.draft ||
                  previous.step != current.step ||
                  previous.invoiceExpanded != current.invoiceExpanded ||
                  previous.summaryExpanded != current.summaryExpanded ||
                  previous.failure != current.failure ||
                  previous.receipt != current.receipt,
              builder: (context, state) {
                return PopScope<void>(
                  canPop: state.navigation == FlowNavigation.back,
                  onPopInvokedWithResult: (didPop, _) {
                    if (!didPop) {
                      context.read<CardIssuanceCubit>().requestBack();
                    }
                  },
                  child: Scaffold(
                    backgroundColor: context.colors.surfaceSubtle,
                    body: SafeArea(
                      child: Column(
                        children: [
                          AppTopBar(
                            title: S.current.issuanceTitle,
                            showLeadingActions: false,
                            trailingIcon: issuanceIcon(
                              AppAssets.cardFeaturesBack,
                              size: 24,
                            ),
                            trailingTooltip: S.current.backLabel,
                            onTrailingPressed: () =>
                                context.read<CardIssuanceCubit>().requestBack(),
                          ),
                          Expanded(
                            // The assistant and footer overlay the scroll viewport; a Column
                            // would change its height and the scroll/empty-state geometry.
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
                                        currentStep: state.step.index + 1,
                                        totalSteps: 3,
                                        progress: switch (state.step) {
                                          IssuanceStep.selection => .3,
                                          IssuanceStep.delivery => .6,
                                          IssuanceStep.confirmation => 1,
                                        },
                                        title: getIssuanceStepTitle(state.step),
                                        supportingText:
                                            getIssuanceSupportingText(
                                              state.step,
                                              state.draft.noPhysicalCard,
                                            ),
                                        semanticLabel: S.current
                                            .issuanceStepSemantic(
                                              state.step.index + 1,
                                              3,
                                              getIssuanceStepTitle(state.step),
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: IssuanceContent(
                                        scroll: scroll,
                                        onDeleteAddress: context
                                            .read<CardIssuanceCubit>()
                                            .requestDeleteAddress,
                                      ),
                                    ),
                                  ],
                                ),
                                if (state.status == RequestStatus.success &&
                                    state.submissionStatus !=
                                        RequestStatus.success &&
                                    state.catalog?.deposits.isNotEmpty ==
                                        true &&
                                    state.catalog?.types.isNotEmpty ==
                                        true) ...[
                                  Positioned(
                                    left: 16,
                                    bottom:
                                        (state.step ==
                                            IssuanceStep.confirmation)
                                        ? 136
                                        : 76,
                                    child: AppAssistantButton(
                                      onPressed:
                                          widget.onAssistantPressed ??
                                          () => context
                                              .read<CardIssuanceCubit>()
                                              .requestBack(),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: IssuanceFooter(
                                      onTermsRequested: context
                                          .read<CardIssuanceCubit>()
                                          .requestTerms,
                                    ),
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
          ),
        ),
      ),
    );
  }
}

String getIssuanceStepTitle(IssuanceStep step) => switch (step) {
  IssuanceStep.selection => S.current.issuanceSelectionTitle,
  IssuanceStep.delivery => S.current.issuanceDeliveryTitle,
  IssuanceStep.confirmation => S.current.issuanceConfirmTitle,
};

String getIssuanceSupportingText(IssuanceStep step, bool noPhysicalCard) =>
    switch (step) {
      IssuanceStep.selection =>
        noPhysicalCard
            ? S.current.issuanceNextConfirm
            : S.current.issuanceNextDelivery,
      IssuanceStep.delivery => S.current.issuanceNextConfirm,
      IssuanceStep.confirmation => S.current.issuanceEnd,
    };
