import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/certificate_confirmation.dart';
import '../../shared/certificate_delivery_form.dart';
import '../cubit/average_balance_cubit.dart';
import 'average_balance_conditions.dart';

class AverageBalanceContent extends StatelessWidget {
  const AverageBalanceContent({super.key, required this.state});
  final AverageBalanceState state;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing:
          state.submissionStatus == RequestStatus.loading ||
          state.submissionStatus == RequestStatus.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.catalogStatus != RequestStatus.success ||
              state.catalog!.deposits.isEmpty)
            Column(
              children: [
                Text(getAverageBalanceCatalogMessage(state.catalogStatus)),
                if (state.catalogStatus == RequestStatus.failure)
                  AppButton(
                    label: S.current.dashboardRetry,
                    onPressed: context.read<AverageBalanceCubit>().fetchCatalog,
                  ),
              ],
            )
          else if (state.step == AverageBalanceStep.conditions)
            AverageBalanceConditions(state: state)
          else if (state.step == AverageBalanceStep.delivery)
            CertificateDeliveryForm(
              addresses: state.addresses,
              address: state.address,
              otherRecipient: state.isOtherRecipient,
              recipientName: state.recipientName,
              recipientNationalId: state.recipientNationalId,
              includeAgent: state.isIncludeAgent,
              agentIdentifier: state.agentIdentifier,
              onAddress: context.read<AverageBalanceCubit>().selectAddress,
              onAddAddress: context
                  .read<AverageBalanceCubit>()
                  .requestAddAddress,
              onDeleteAddress: context
                  .read<AverageBalanceCubit>()
                  .requestDeleteAddress,
              onOtherRecipient: context
                  .read<AverageBalanceCubit>()
                  .updateOtherRecipient,
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
                  .updateIncludeAgent,
              onAgent: context
                  .read<AverageBalanceCubit>()
                  .updateAgentIdentifier,
            )
          else
            CertificateConfirmation(
              depositNumber: state.deposit!.number,
              operation: S.current.balanceAverageStatement,
              catalog: state.catalog!,
              total: state.totalRial,
              walletSufficient: state.isWalletSufficient,
              summaryExpanded: state.isSummaryExpanded,
              invoiceExpanded: state.isInvoiceExpanded,
              onSummary: context
                  .read<AverageBalanceCubit>()
                  .updateSummaryExpanded,
              onInvoice: context
                  .read<AverageBalanceCubit>()
                  .updateInvoiceExpanded,
            ),
          if (state.submissionFailure != null &&
              state.catalogStatus == RequestStatus.success)
            Text(
              S.current.issuanceSubmitError,
              style: Theme.of(context).textTheme.bodySmall!
                  .copyWith(color: context.colors.error),
            ),
        ],
      ),
    );
  }
}

String getAverageBalanceCatalogMessage(RequestStatus status) {
  return switch (status) {
    RequestStatus.failure => S.current.dashboardLoadError,
    RequestStatus.success => S.current.depositsEmpty,
    _ => S.current.dashboardLoading,
  };
}
