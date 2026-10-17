import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';

import '../../shared/certificate_address_sheet.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_confirmation.dart';
import '../../shared/certificate_delivery_form.dart';
import '../cubit/average_balance_cubit.dart';
import '../widgets/average_balance_conditions.dart';

class AverageBalanceScreen extends StatelessWidget {
  const AverageBalanceScreen({
    super.key,
    this.initialDepositNumber,
    this.initialState = const AverageBalanceState.initial(),
    this.onCompleted,
  });
  final String? initialDepositNumber;
  final AverageBalanceState initialState;
  final ValueChanged<CertificateReceipt>? onCompleted;
  Future<void> _handleEffect(
    BuildContext context,
    AverageBalanceState state,
  ) async {
    switch (state.effect) {
      case CertificateAddressRequested():
        final address = await showCertificateAddressSheet(context);
        if (context.mounted) {
          context.read<AverageBalanceCubit>().addressResult(address);
        }
      case CertificateAddressRemovalRequested(:final address):
        final confirmed = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (sheetContext) => AppDeleteAddressSheet(
            address: address.detail,
            postalCode: address.postalCode,
            title: S.current.issuanceDeleteAddress,
            prompt: S.current.certificateDeleteAddressPrompt,
            confirmLabel: S.current.issuanceDeleteAddress,
            cancelLabel: S.current.backLabel,
            onConfirm: () => sheetContext.pop(true),
            onCancel: () => sheetContext.pop(false),
          ),
        );
        if (context.mounted) {
          context.read<AverageBalanceCubit>().addressRemovalResult(
            address.id,
            confirmed,
          );
        }
      case CertificateAgentUnavailable():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.certificateAgentUnavailable)),
        );
      case null:
        switch (state.navigation) {
          case FlowNavigation.confirmExit:
            final confirmed = await showFlowExitDialog(context);
            if (context.mounted) {
              context.read<AverageBalanceCubit>().exitConfirmationResult(
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
  }

  Future<void> _handleReceipt(
    BuildContext context,
    AverageBalanceState state,
  ) async {
    if (state.receipt == null) return;
    onCompleted?.call(state.receipt!);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(
          '${state.receipt!.isMock ? S.current.certificateMockComplete : S.current.issuanceComplete}\n${state.receipt!.reference}',
        ),
        actions: [
          AppButton(
            label: S.current.backLabel,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
    if (context.mounted) {
      context.read<AverageBalanceCubit>().receiptPresentationClosed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AverageBalanceCubit(
        initialDepositNumber: initialDepositNumber,
        initialState: initialState,
      )..load(),
      child: BlocListener<AverageBalanceCubit, AverageBalanceState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleEffect,
        child: BlocConsumer<AverageBalanceCubit, AverageBalanceState>(
          listenWhen: (previous, current) =>
              previous.submissionStatus != current.submissionStatus,
          listener: _handleReceipt,
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop: state.navigation == FlowNavigation.back,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    context.read<AverageBalanceCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          leadingAction: const SizedBox.shrink(),
                          title: S.current.certificateAverageTitle,
                          showLeadingActions: false,
                          trailingIcon: depositIcon(
                            AppAssets.depositFeatureBack,
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed: context
                              .read<AverageBalanceCubit>()
                              .requestBack,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  64,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AppStepper(
                                      currentStep: state.step.index + 1,
                                      totalSteps: 3,
                                      progress: [.3, .6, 1.0][state.step.index],
                                      title: getAverageBalanceStepTitle(
                                        state.step,
                                      ),
                                      supportingText:
                                          state.step ==
                                              AverageBalanceStep.confirmation
                                          ? S.current.issuanceEnd
                                          : '${S.current.certificateNextPrefix} ${getAverageBalanceNextStepTitle(state.step)}',
                                    ),
                                    const SizedBox(height: 26),
                                    if (state.status != RequestStatus.success ||
                                        state.catalog!.deposits.isEmpty)
                                      Column(
                                        children: [
                                          Text(
                                            state.status ==
                                                    RequestStatus.failure
                                                ? S.current.dashboardLoadError
                                                : state.status ==
                                                      RequestStatus.success
                                                ? S.current.depositsEmpty
                                                : S.current.dashboardLoading,
                                          ),
                                          if (state.status ==
                                              RequestStatus.failure)
                                            AppButton(
                                              label: S.current.dashboardRetry,
                                              onPressed: context
                                                  .read<AverageBalanceCubit>()
                                                  .load,
                                            ),
                                        ],
                                      )
                                    else if (state.step ==
                                        AverageBalanceStep.conditions)
                                      const AverageBalanceConditions()
                                    else if (state.step ==
                                        AverageBalanceStep.delivery)
                                      CertificateDeliveryForm(
                                        addresses: state.addresses,
                                        address: state.address,
                                        otherRecipient: state.otherRecipient,
                                        recipientName: state.recipientName,
                                        recipientNationalId:
                                            state.recipientNationalId,
                                        includeAgent: state.includeAgent,
                                        agentIdentifier: state.agentIdentifier,
                                        onAddress: context
                                            .read<AverageBalanceCubit>()
                                            .selectAddress,
                                        onAddAddress: context
                                            .read<AverageBalanceCubit>()
                                            .requestAddAddress,
                                        onDeleteAddress: context
                                            .read<AverageBalanceCubit>()
                                            .requestDeleteAddress,
                                        onOtherRecipient: context
                                            .read<AverageBalanceCubit>()
                                            .setOtherRecipient,
                                        onRecipientName: context
                                            .read<AverageBalanceCubit>()
                                            .updateRecipientName,
                                        onRecipientNationalId: context
                                            .read<AverageBalanceCubit>()
                                            .updateRecipientNationalId,
                                        canCheckAgent: state.canCheckAgent,
                                        onAgentLookup: context
                                            .read<AverageBalanceCubit>()
                                            .requestAgentLookup,
                                        onIncludeAgent: context
                                            .read<AverageBalanceCubit>()
                                            .setIncludeAgent,
                                        onAgent: context
                                            .read<AverageBalanceCubit>()
                                            .agentChanged,
                                      )
                                    else
                                      CertificateConfirmation(
                                        depositNumber: state.deposit!.number,
                                        operation:
                                            S.current.balanceAverageStatement,
                                        catalog: state.catalog!,
                                        total: state.totalRial,
                                        walletSufficient:
                                            state.walletSufficient,
                                        summaryExpanded: state.summaryExpanded,
                                        invoiceExpanded: state.invoiceExpanded,
                                        onSummary: context
                                            .read<AverageBalanceCubit>()
                                            .expandSummary,
                                        onInvoice: context
                                            .read<AverageBalanceCubit>()
                                            .expandInvoice,
                                      ),
                                    if (state.failure != null &&
                                        state.status == RequestStatus.success)
                                      Text(
                                        S.current.issuanceSubmitError,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: context.colors.error,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: AppAssistantButton(
                                  onPressed: context
                                      .read<AverageBalanceCubit>()
                                      .requestHome,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: AppButton(
                            label: state.step == AverageBalanceStep.confirmation
                                ? S.current.issuanceSubmit
                                : S.current.issuanceNext,
                            size: AppButtonSize.lg,
                            disabledAppearance:
                                AppButtonDisabledAppearance.service,
                            isLoading:
                                state.submissionStatus == RequestStatus.loading,
                            onPressed:
                                state.canContinue &&
                                    state.status == RequestStatus.success &&
                                    state.submissionStatus !=
                                        RequestStatus.loading &&
                                    state.submissionStatus !=
                                        RequestStatus.success
                                ? context
                                      .read<AverageBalanceCubit>()
                                      .continueFlow
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

String getAverageBalanceStepTitle(AverageBalanceStep step) {
  switch (step) {
    case AverageBalanceStep.conditions:
      return S.current.certificateConditionsStep;
    case AverageBalanceStep.delivery:
      return S.current.certificateDeliveryStep;
    case AverageBalanceStep.confirmation:
      return S.current.issuanceConfirmTitle;
  }
}

String getAverageBalanceNextStepTitle(AverageBalanceStep step) {
  switch (step) {
    case AverageBalanceStep.conditions:
      return S.current.certificateDeliveryStep;
    case AverageBalanceStep.delivery:
      return S.current.issuanceConfirmTitle;
    case AverageBalanceStep.confirmation:
      return S.current.issuanceEnd;
  }
}
