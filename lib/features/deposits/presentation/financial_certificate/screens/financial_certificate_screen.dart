import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
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
    this.initialState = const FinancialCertificateState(),
    this.onCompleted,
  });
  final FinancialCertificateRepository? repository;
  final String? initialDepositNumber;
  final FinancialCertificateState initialState;
  final ValueChanged<CertificateReceipt>? onCompleted;
  @override
  Widget build(BuildContext context) => BlocProvider(
    // A changed adapter or entry account intentionally resets the flow scope.
    key: ValueKey((repository, initialDepositNumber)),
    create: (_) => FinancialCertificateCubit(
      repository: repository ?? MockFinancialCertificateRepository(),
      initialDepositNumber: initialDepositNumber,
      initialState: initialState,
    )..load(),
    child: _FinancialCertificateView(onCompleted: onCompleted),
  );
}

class _FinancialCertificateView extends StatelessWidget {
  const _FinancialCertificateView({this.onCompleted});
  final ValueChanged<CertificateReceipt>? onCompleted;
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<FinancialCertificateCubit, FinancialCertificateState>(
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
            '${state.receipt!.isMock ? context.l10n.certificateMockComplete : context.l10n.issuanceComplete}\n${state.receipt!.reference}',
          ),
          actions: [
            AppButton(
              label: context.l10n.backLabel,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
      if (context.mounted) NavigationActions.returnHome(context);
    },
    builder: (context, state) {
      final cubit = context.read<FinancialCertificateCubit>();
      final titles = [
        context.l10n.certificateConditionsStep,
        context.l10n.financialRecipientStep,
        context.l10n.financialLatinStep,
        context.l10n.financialDeliveryStep,
        context.l10n.issuanceConfirmTitle,
      ];
      return Directionality(
        textDirection: TextDirection.rtl,
        child: PopScope(
          canPop:
              state.step == FinancialCertificateStep.conditions &&
              state.submissionStatus != RequestStatus.loading,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) cubit.back();
          },
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: context.l10n.financialCertificateTitle,
                    leadingAction: const SizedBox.shrink(),
                    showLeadingActions: false,
                    trailingIcon: depositIcon(AppAssets.depositFeatureBack),
                    trailingTooltip: context.l10n.backLabel,
                    onTrailingPressed: () {
                      if (!cubit.back()) NavigationActions.back(context);
                    },
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppStepper(
                                currentStep: state.step.index + 1,
                                totalSteps: 5,
                                title: titles[state.step.index],
                                supportingText:
                                    state.step ==
                                        FinancialCertificateStep.confirmation
                                    ? context.l10n.issuanceEnd
                                    : '${context.l10n.certificateNextPrefix} ${titles[state.step.index + 1]}',
                              ),
                              const SizedBox(height: 26),
                              if (state.status != RequestStatus.success ||
                                  state.catalog!.deposits.isEmpty)
                                Column(
                                  children: [
                                    Text(
                                      state.status == RequestStatus.failure
                                          ? context.l10n.dashboardLoadError
                                          : state.status ==
                                                RequestStatus.success
                                          ? context.l10n.depositsEmpty
                                          : context.l10n.dashboardLoading,
                                    ),
                                    if (state.status == RequestStatus.failure)
                                      AppButton(
                                        label: context.l10n.dashboardRetry,
                                        onPressed: cubit.load,
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
                                  recipientName: state.deliveryRecipientName,
                                  recipientNationalId:
                                      state.deliveryRecipientNationalId,
                                  includeAgent: state.includeAgent,
                                  agentIdentifier: state.agentIdentifier,
                                  onAddress: cubit.selectAddress,
                                  onAddAddress: cubit.addAddress,
                                  onDeleteAddress: cubit.removeAddress,
                                  onOtherRecipient: cubit.setOtherRecipient,
                                  onRecipient: cubit.deliveryRecipientChanged,
                                  onIncludeAgent: cubit.setIncludeAgent,
                                  onAgent: cubit.agentChanged,
                                )
                              else
                                CertificateConfirmation(
                                  depositNumber: state.deposit!.number,
                                  operation: context.l10n.financialCertificate,
                                  catalog: state.catalog!,
                                  total: state.totalRial,
                                  walletSufficient: state.walletSufficient,
                                  summaryExpanded: state.summaryExpanded,
                                  invoiceExpanded: state.invoiceExpanded,
                                  onSummary: cubit.expandSummary,
                                  onInvoice: cubit.expandInvoice,
                                  operationDivider:
                                      AppAssets.financialCertificateOperation,
                                  summaryChevron:
                                      AppAssets.financialCertificateChevron,
                                ),
                              if (state.failure != null &&
                                  state.status == RequestStatus.success)
                                Text(
                                  context.l10n.issuanceSubmitError,
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(color: context.colors.error),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: AppAssistantButton(
                            onPressed:
                                state.submissionStatus == RequestStatus.loading
                                ? () {}
                                : () => NavigationActions.returnHome(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: AppButton(
                      label: state.step == FinancialCertificateStep.confirmation
                          ? context.l10n.issuanceSubmit
                          : context.l10n.issuanceNext,
                      size: AppButtonSize.lg,
                      disabledAppearance: AppButtonDisabledAppearance.service,
                      isLoading:
                          state.submissionStatus == RequestStatus.loading,
                      onPressed:
                          state.canContinue &&
                              state.status == RequestStatus.success &&
                              state.submissionStatus != RequestStatus.loading &&
                              state.submissionStatus != RequestStatus.success
                          ? state.step == FinancialCertificateStep.confirmation
                                ? cubit.submit
                                : cubit.next
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
  );
}
