import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../data/repositories/mock_financial_certificate_repository.dart';
import '../../../domain/entities/certificate_data.dart';
import '../../../domain/repositories/financial_certificate_repository.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_confirmation.dart';
import '../../shared/certificate_delivery_form.dart';
import '../cubit/financial_certificate_cubit.dart';
import '../widgets/financial_conditions.dart';
import '../widgets/financial_recipient.dart';
import '../widgets/financial_latin_identity.dart';

class FinancialCertificateScreen extends StatelessWidget {
  const FinancialCertificateScreen({
    super.key,
    this.repository,
    this.initialDepositNumber,
    this.initialState = const FinancialCertificateState.initial(),
    this.onCompleted,
  });
  final FinancialCertificateRepository? repository;
  final String? initialDepositNumber;
  final FinancialCertificateState initialState;
  final ValueChanged<CertificateReceipt>? onCompleted;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // A changed adapter or entry account intentionally resets the flow scope.
      key: ValueKey((repository, initialDepositNumber)),
      create: (_) => FinancialCertificateCubit(
        repository: repository ?? MockFinancialCertificateRepository(),
        initialDepositNumber: initialDepositNumber,
        initialState: initialState,
      )..load(),
      child: BlocConsumer<FinancialCertificateCubit, FinancialCertificateState>(
        listenWhen: (a, b) => a.submissionStatus != b.submissionStatus,
        buildWhen: (a, b) =>
            a.status != b.status ||
            a.submissionStatus != b.submissionStatus ||
            a.step != b.step ||
            a.canContinue != b.canContinue ||
            a.receipt != b.receipt ||
            a.failure != b.failure ||
            a.catalog != b.catalog ||
            a.summaryExpanded != b.summaryExpanded ||
            a.invoiceExpanded != b.invoiceExpanded ||
            a.addresses != b.addresses ||
            a.address != b.address ||
            a.otherRecipient != b.otherRecipient ||
            a.deliveryRecipientName != b.deliveryRecipientName ||
            a.deliveryRecipientNationalId != b.deliveryRecipientNationalId ||
            a.includeAgent != b.includeAgent ||
            a.agentIdentifier != b.agentIdentifier,
        listener: (context, state) async {
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
          if (context.mounted) NavigationActions.returnHome(context);
        },
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: PopScope(
              canPop:
                  state.step == FinancialCertificateStep.conditions &&
                  state.submissionStatus != RequestStatus.loading,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) context.read<FinancialCertificateCubit>().back();
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
                        trailingIcon: depositIcon(AppAssets.depositFeatureBack),
                        trailingTooltip: S.current.backLabel,
                        onTrailingPressed: () {
                          if (!context.read<FinancialCertificateCubit>().back()) {
                            NavigationActions.back(context);
                          }
                        },
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppStepper(
                                    currentStep: state.step.index + 1,
                                    totalSteps: 5,
                                    title: getFinancialCertificateStepTitle(
                                      state.step,
                                    ),
                                    supportingText:
                                        state.step ==
                                            FinancialCertificateStep
                                                .confirmation
                                        ? S.current.issuanceEnd
                                        : '${S.current.certificateNextPrefix} ${getFinancialCertificateNextStepTitle(state.step)}',
                                  ),
                                  const SizedBox(height: 26),
                                  if (state.status != RequestStatus.success ||
                                      state.catalog!.deposits.isEmpty)
                                    Column(
                                      children: [
                                        Text(
                                          state.status == RequestStatus.failure
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
                                                .read<
                                                  FinancialCertificateCubit
                                                >()
                                                .load,
                                          ),
                                      ],
                                    )
                                  else if (state.step ==
                                      FinancialCertificateStep.conditions)
                                    const FinancialConditions()
                                  else if (state.step ==
                                      FinancialCertificateStep.recipient)
                                    const FinancialRecipient()
                                  else if (state.step ==
                                      FinancialCertificateStep.latinIdentity)
                                    const FinancialLatinIdentityForm()
                                  else if (state.step ==
                                      FinancialCertificateStep.delivery)
                                    CertificateDeliveryForm(
                                      addresses: state.addresses,
                                      address: state.address,
                                      otherRecipient: state.otherRecipient,
                                      recipientName:
                                          state.deliveryRecipientName,
                                      recipientNationalId:
                                          state.deliveryRecipientNationalId,
                                      includeAgent: state.includeAgent,
                                      agentIdentifier: state.agentIdentifier,
                                      onAddress: context
                                          .read<FinancialCertificateCubit>()
                                          .selectAddress,
                                      onAddAddress: context
                                          .read<FinancialCertificateCubit>()
                                          .addAddress,
                                      onDeleteAddress: context
                                          .read<FinancialCertificateCubit>()
                                          .removeAddress,
                                      onOtherRecipient: context
                                          .read<FinancialCertificateCubit>()
                                          .setOtherRecipient,
                                      onRecipient: context
                                          .read<FinancialCertificateCubit>()
                                          .deliveryRecipientChanged,
                                      onIncludeAgent: context
                                          .read<FinancialCertificateCubit>()
                                          .setIncludeAgent,
                                      onAgent: context
                                          .read<FinancialCertificateCubit>()
                                          .agentChanged,
                                    )
                                  else
                                    CertificateConfirmation(
                                      depositNumber: state.deposit!.number,
                                      operation: S.current.financialCertificate,
                                      catalog: state.catalog!,
                                      total: state.totalRial,
                                      walletSufficient: state.walletSufficient,
                                      summaryExpanded: state.summaryExpanded,
                                      invoiceExpanded: state.invoiceExpanded,
                                      onSummary: context
                                          .read<FinancialCertificateCubit>()
                                          .expandSummary,
                                      onInvoice: context
                                          .read<FinancialCertificateCubit>()
                                          .expandInvoice,
                                      operationDivider: AppAssets
                                          .financialCertificateOperation,
                                      summaryChevron:
                                          AppAssets.financialCertificateChevron,
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
                                onPressed:
                                    state.submissionStatus ==
                                        RequestStatus.loading
                                    ? () {}
                                    : () =>
                                          NavigationActions.returnHome(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
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
                              state.submissionStatus == RequestStatus.loading,
                          onPressed:
                              state.canContinue &&
                                  state.status == RequestStatus.success &&
                                  state.submissionStatus !=
                                      RequestStatus.loading &&
                                  state.submissionStatus !=
                                      RequestStatus.success
                              ? state.step ==
                                        FinancialCertificateStep.confirmation
                                    ? context
                                          .read<FinancialCertificateCubit>()
                                          .submit
                                    : context
                                          .read<FinancialCertificateCubit>()
                                          .next
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
