import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';

import '../../shared/certificate_receipt_dialog.dart';
import '../widgets/financial_certificate_content.dart';

import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialCertificateScreen extends StatelessWidget {
  const FinancialCertificateScreen({
    super.key,
    this.initialDepositNumber,
    this.initialState = const FinancialCertificateState.initial(),
    this.onCompleted,
  });
  final String? initialDepositNumber;
  final FinancialCertificateState initialState;
  final ValueChanged<CertificateReceipt>? onCompleted;
  Future<void> _handleEffect(
    BuildContext context,
    FinancialCertificateState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case CertificateAddressRequested():
        context
            .read<FinancialCertificateCubit>()
            .consumeFinancialCertificateInteraction();
        final address = await ServiceRegistry.openAddressEditor(context);
        if (context.mounted) {
          context.read<FinancialCertificateCubit>().applyAddressSelection(
            address,
          );
        }
      case CertificateAddressRemovalRequested(:final address):
        context
            .read<FinancialCertificateCubit>()
            .consumeFinancialCertificateInteraction();
        final cubit = context.read<FinancialCertificateCubit>();
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
        context
            .read<FinancialCertificateCubit>()
            .consumeFinancialCertificateInteraction();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.certificateAgentUnavailable)),
        );
      case null:
        switch (state.navigation) {
          case FlowNavigation.confirmExit:
            context
                .read<FinancialCertificateCubit>()
                .consumeFinancialCertificateInteraction();
            final confirmed = await showFlowExitDialog(context);
            if (context.mounted) {
              context.read<FinancialCertificateCubit>().applyExitConfirmation(
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
    FinancialCertificateState state,
  ) async {
    onCompleted?.call(state.receipt!);
    await showCertificateReceiptDialog(context, state.receipt!);
    if (context.mounted) {
      context.read<FinancialCertificateCubit>().applyReceiptDismissal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinancialCertificateCubit(
        initialDepositNumber: initialDepositNumber,
        initialState: initialState,
      )..fetchCatalog(),
      child: BlocListener<FinancialCertificateCubit, FinancialCertificateState>(
        listenWhen: (previous, current) =>
            (previous.effect != current.effect && current.effect != null) ||
            (previous.navigation != current.navigation &&
                current.navigation != null) ||
            ((previous.catalogStatus != current.catalogStatus &&
                    current.catalogStatus == RequestStatus.failure) ||
                (previous.submissionStatus != current.submissionStatus &&
                    current.submissionStatus == RequestStatus.failure)),
        listener: _handleEffect,
        child: BlocConsumer<FinancialCertificateCubit, FinancialCertificateState>(
          listenWhen: (previous, current) =>
              previous.submissionStatus != current.submissionStatus &&
              current.submissionStatus == RequestStatus.success,
          listener: _handleReceipt,
          buildWhen: (previous, current) =>
              previous.catalogStatus != current.catalogStatus ||
              previous.submissionStatus != current.submissionStatus ||
              previous.navigation != current.navigation,
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop:
                    (state.catalogStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading) &&
                    (state.navigation == FlowNavigation.back),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.catalogStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) {
                    context.read<FinancialCertificateCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: S.current.financialCertificateTitle,
                          leadingAction: const SizedBox.shrink(),
                          showLeadingActions: false,
                          trailingIcon: depositIcon(
                            '${AppConstants.baseImage}deposit_list_back.svg',
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed:
                              (state.catalogStatus != RequestStatus.loading &&
                                  state.submissionStatus !=
                                      RequestStatus.loading)
                              ? context
                                    .read<FinancialCertificateCubit>()
                                    .requestBack
                              : null,
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
                                      FinancialCertificateCubit,
                                      FinancialCertificateState
                                    >(
                                      buildWhen: (previous, current) =>
                                          previous.step != current.step ||
                                          previous.stepNumber !=
                                              current.stepNumber,
                                      builder: (context, state) {
                                        return AppStepper(
                                          currentStep: state.stepNumber,
                                          totalSteps: 5,
                                          title:
                                              getFinancialCertificateStepTitle(
                                                state.step,
                                              ),
                                          supportingText:
                                              state.step ==
                                                  FinancialCertificateStep
                                                      .confirmation
                                              ? S.current.issuanceEnd
                                              : '${S.current.certificateNextPrefix} ${getFinancialCertificateNextStepTitle(state.step)}',
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 26),
                                    const FinancialCertificateContent(),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: AppAssistantButton(
                                  onPressed: context
                                      .read<FinancialCertificateCubit>()
                                      .requestHome,
                                ),
                              ),
                            ],
                          ),
                        ),
                        BlocBuilder<
                          FinancialCertificateCubit,
                          FinancialCertificateState
                        >(
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
                                        FinancialCertificateStep.confirmation
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
                                          .read<FinancialCertificateCubit>()
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

String getFinancialCertificateStepTitle(FinancialCertificateStep step) {
  switch (step) {
    case FinancialCertificateStep.conditions:
      return S.current.certificateConditionsStep;
    case FinancialCertificateStep.recipient:
      return S.current.financialRecipientStep;
    case FinancialCertificateStep.latinIdentity:
      return S.current.financialLatinStep;
    case FinancialCertificateStep.delivery:
      return S.current.financialDeliveryStep;
    case FinancialCertificateStep.confirmation:
      return S.current.issuanceConfirmTitle;
  }
}

String getFinancialCertificateNextStepTitle(FinancialCertificateStep step) {
  switch (step) {
    case FinancialCertificateStep.conditions:
      return S.current.financialRecipientStep;
    case FinancialCertificateStep.recipient:
      return S.current.financialLatinStep;
    case FinancialCertificateStep.latinIdentity:
      return S.current.financialDeliveryStep;
    case FinancialCertificateStep.delivery:
      return S.current.issuanceConfirmTitle;
    case FinancialCertificateStep.confirmation:
      return S.current.issuanceEnd;
  }
}
