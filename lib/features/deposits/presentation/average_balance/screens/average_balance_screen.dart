import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../data/repositories/mock_deposit_certificates_repository.dart';
import '../../../domain/entities/certificate_data.dart';
import '../../../domain/repositories/deposit_certificates_repository.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_confirmation.dart';
import '../../shared/certificate_delivery_form.dart';
import '../cubit/average_balance_cubit.dart';
import '../widgets/average_balance_conditions.dart';

class AverageBalanceScreen extends StatelessWidget {
  const AverageBalanceScreen({
    super.key,
    this.repository,
    this.initialDepositNumber,
    this.initialState = const AverageBalanceState(),
    this.onCompleted,
  });
  final DepositCertificatesRepository? repository;
  final String? initialDepositNumber;
  final AverageBalanceState initialState;
  final ValueChanged<CertificateReceipt>? onCompleted;
  @override
  Widget build(BuildContext context) => BlocProvider(
    // A different adapter or entry seed starts a fresh flow; rebuilds retain state.
    key: ValueKey((repository, initialDepositNumber)),
    create: (_) => AverageBalanceCubit(
      repository: repository ?? MockDepositCertificatesRepository(),
      initialDepositNumber: initialDepositNumber,
      initialState: initialState,
    )..load(),
    child: _AverageBalanceView(onCompleted: onCompleted),
  );
}

class _AverageBalanceView extends StatelessWidget {
  const _AverageBalanceView({this.onCompleted});
  final ValueChanged<CertificateReceipt>? onCompleted;
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<AverageBalanceCubit, AverageBalanceState>(
    listenWhen: (a, b) => a.submissionStatus != b.submissionStatus,
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
      final cubit = context.read<AverageBalanceCubit>();
      final titles = [
        context.l10n.certificateConditionsStep,
        context.l10n.certificateDeliveryStep,
        context.l10n.issuanceConfirmTitle,
      ];
      return Directionality(
        textDirection: TextDirection.rtl,
        child: PopScope(
          canPop:
              state.step == AverageBalanceStep.conditions &&
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
                    leadingAction: const SizedBox.shrink(),
                    title: context.l10n.certificateAverageTitle,
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
                                totalSteps: 3,
                                progress: [.3, .6, 1.0][state.step.index],
                                title: titles[state.step.index],
                                supportingText:
                                    state.step ==
                                        AverageBalanceStep.confirmation
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
                                  onAddress: cubit.selectAddress,
                                  onAddAddress: cubit.addAddress,
                                  onDeleteAddress: cubit.removeAddress,
                                  onOtherRecipient: cubit.setOtherRecipient,
                                  onRecipient: cubit.recipientChanged,
                                  onIncludeAgent: cubit.setIncludeAgent,
                                  onAgent: cubit.agentChanged,
                                )
                              else
                                CertificateConfirmation(
                                  depositNumber: state.deposit!.number,
                                  operation:
                                      context.l10n.balanceAverageStatement,
                                  catalog: state.catalog!,
                                  total: state.totalRial,
                                  walletSufficient: state.walletSufficient,
                                  summaryExpanded: state.summaryExpanded,
                                  invoiceExpanded: state.invoiceExpanded,
                                  onSummary: cubit.expandSummary,
                                  onInvoice: cubit.expandInvoice,
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
                      label: state.step == AverageBalanceStep.confirmation
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
                          ? state.step == AverageBalanceStep.confirmation
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
