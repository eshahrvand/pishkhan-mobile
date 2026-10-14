import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
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
    this.initialState = const AverageBalanceState.initial(),
    this.onCompleted,
  });
  final DepositCertificatesRepository? repository;
  final String? initialDepositNumber;
  final AverageBalanceState initialState;
  final ValueChanged<CertificateReceipt>? onCompleted;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // A different adapter or entry seed starts a fresh flow; rebuilds retain state.
      key: ValueKey((repository, initialDepositNumber)),
      create: (_) => AverageBalanceCubit(
        repository: repository ?? MockDepositCertificatesRepository(),
        initialDepositNumber: initialDepositNumber,
        initialState: initialState,
      )..load(),
      child: BlocConsumer<AverageBalanceCubit, AverageBalanceState>(
        listenWhen: (a, b) => a.submissionStatus != b.submissionStatus,
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
                  state.step == AverageBalanceStep.conditions &&
                  state.submissionStatus != RequestStatus.loading,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) context.read<AverageBalanceCubit>().back();
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
                        trailingIcon: depositIcon(AppAssets.depositFeatureBack),
                        trailingTooltip: S.current.backLabel,
                        onTrailingPressed: () {
                          if (!context.read<AverageBalanceCubit>().back()) {
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
                                          .addAddress,
                                      onDeleteAddress: context
                                          .read<AverageBalanceCubit>()
                                          .removeAddress,
                                      onOtherRecipient: context
                                          .read<AverageBalanceCubit>()
                                          .setOtherRecipient,
                                      onRecipient: context
                                          .read<AverageBalanceCubit>()
                                          .recipientChanged,
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
                                      walletSufficient: state.walletSufficient,
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
                              ? state.step == AverageBalanceStep.confirmation
                                    ? context.read<AverageBalanceCubit>().submit
                                    : context.read<AverageBalanceCubit>().next
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
