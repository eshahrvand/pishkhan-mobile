import 'package:pishkhan_mobile/core/flow/service_registry.dart';

import '../../shared/certificate_receipt_dialog.dart';

import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';

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
import '../cubit/average_balance_cubit.dart';
import '../widgets/average_balance_content.dart';

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
        final address = await ServiceRegistry.openAddressEditor(context);
        if (context.mounted) {
          context.read<AverageBalanceCubit>().applyAddressSelection(address);
        }
      case CertificateAddressRemovalRequested(:final address):
        final cubit = context.read<AverageBalanceCubit>();
        await showModalBottomSheet<void>(
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
            onConfirm: () {
              cubit.removeAddress(address);
              sheetContext.pop();
            },
            onCancel: () => sheetContext.pop(),
          ),
        );
      case CertificateAgentUnavailable():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.certificateAgentUnavailable)),
        );
      case null:
        switch (state.navigation) {
          case FlowNavigation.confirmExit:
            final confirmed = await showFlowExitDialog(context);
            if (context.mounted) {
              context.read<AverageBalanceCubit>().applyExitConfirmation(
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
    onCompleted?.call(state.receipt!);
    await showCertificateReceiptDialog(context, state.receipt!);
    if (context.mounted) {
      context.read<AverageBalanceCubit>().applyReceiptDismissal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AverageBalanceCubit(
        initialDepositNumber: initialDepositNumber,
        initialState: initialState,
      )..fetchCatalog(),
      child: BlocListener<AverageBalanceCubit, AverageBalanceState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleEffect,
        child: BlocConsumer<AverageBalanceCubit, AverageBalanceState>(
          listenWhen: (previous, current) =>
              previous.submissionStatus != current.submissionStatus &&
              current.submissionStatus == RequestStatus.success,
          listener: _handleReceipt,
          buildWhen: (previous, current) =>
              previous.navigation != current.navigation,
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
                                    BlocBuilder<
                                      AverageBalanceCubit,
                                      AverageBalanceState
                                    >(
                                      buildWhen: (previous, current) =>
                                          previous.step != current.step ||
                                          previous.stepNumber !=
                                              current.stepNumber ||
                                          previous.progress != current.progress,
                                      builder: (context, state) {
                                        return AppStepper(
                                          currentStep: state.stepNumber,
                                          totalSteps: 3,
                                          progress: state.progress,
                                          title: getAverageBalanceStepTitle(
                                            state.step,
                                          ),
                                          supportingText:
                                              state.step ==
                                                  AverageBalanceStep
                                                      .confirmation
                                              ? S.current.issuanceEnd
                                              : '${S.current.certificateNextPrefix} ${getAverageBalanceNextStepTitle(state.step)}',
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 26),
                                    const AverageBalanceContent(),
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
                        BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
                          buildWhen: (previous, current) =>
                              previous.canContinue != current.canContinue ||
                              previous.submissionStatus !=
                                  current.submissionStatus ||
                              previous.step != current.step,
                          builder: (context, state) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: AppButton(
                                label:
                                    state.step ==
                                        AverageBalanceStep.confirmation
                                    ? S.current.issuanceSubmit
                                    : S.current.issuanceNext,
                                size: AppButtonSize.lg,
                                disabledAppearance:
                                    AppButtonDisabledAppearance.service,
                                isLoading:
                                    state.submissionStatus ==
                                    RequestStatus.loading,
                                onPressed: state.canContinue
                                    ? context
                                          .read<AverageBalanceCubit>()
                                          .continueFlow
                                    : null,
                              ),
                            );
                          },
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
