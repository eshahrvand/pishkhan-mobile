import 'package:pishkhan_mobile/core/config/constant.dart';
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
        context.read<CardIssuanceCubit>().consumeCardIssuanceInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<CardIssuanceCubit>().applyExitConfirmation(confirmed);
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
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case IssuanceTermsRequested():
        context.read<CardIssuanceCubit>().consumeCardIssuanceInteraction();
        if (widget.onTermsRequested != null) {
          widget.onTermsRequested!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.issuanceTermsUnavailable)),
          );
        }
      case IssuanceAddressRequested():
        context.read<CardIssuanceCubit>().consumeCardIssuanceInteraction();
        await showIssuanceAddressSheet(
          context,
          context.read<CardIssuanceCubit>(),
        );
      case IssuanceAddressRemovalRequested(:final address):
        context.read<CardIssuanceCubit>().consumeCardIssuanceInteraction();
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
  }

  void _handleProgress(BuildContext context, CardIssuanceState state) {
    if (scroll.hasClients) {
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
            (previous.navigation != current.navigation &&
            current.navigation != null),
        listener: _handleNavigation,
        child: BlocListener<CardIssuanceCubit, CardIssuanceState>(
          listenWhen: (previous, current) =>
              (previous.effect != current.effect &&
                  current.effect != null) ||
              ((previous.catalogStatus != current.catalogStatus &&
                      current.catalogStatus == RequestStatus.failure) ||
                  (previous.submissionStatus != current.submissionStatus &&
                      current.submissionStatus == RequestStatus.failure)),
          listener: _handleEffect,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocConsumer<CardIssuanceCubit, CardIssuanceState>(
              listenWhen: (previous, current) =>
                  previous.step != current.step ||
                  (previous.catalogStatus != current.catalogStatus &&
                      current.catalogStatus != RequestStatus.loading) ||
                  (previous.submissionStatus != current.submissionStatus &&
                      current.submissionStatus != RequestStatus.loading),
              listener: _handleProgress,
              builder: (context, state) {
                return PopScope<void>(
                  canPop:
                      (state.catalogStatus != RequestStatus.loading &&
                          state.submissionStatus != RequestStatus.loading) &&
                      (state.navigation == FlowNavigation.back),
                  onPopInvokedWithResult: (didPop, _) {
                    if (!didPop &&
                        state.catalogStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading) {
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
                              '${AppConstants.baseImage}card_features_back.svg',
                              size: 24,
                            ),
                            trailingTooltip: S.current.backLabel,
                            onTrailingPressed:
                                (state.catalogStatus != RequestStatus.loading &&
                                    state.submissionStatus !=
                                        RequestStatus.loading)
                                ? () => context
                                      .read<CardIssuanceCubit>()
                                      .requestBack()
                                : null,
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
                                        currentStep: state.stepNumber,
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
                                              state.stepNumber,
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
                                if (state.catalogStatus ==
                                        RequestStatus.success &&
                                    state.submissionStatus !=
                                        RequestStatus.success &&
                                    !state.isCatalogEmpty) ...[
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
