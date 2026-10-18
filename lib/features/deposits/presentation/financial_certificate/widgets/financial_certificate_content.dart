import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../shared/certificate_confirmation.dart';
import '../../shared/certificate_delivery_form.dart';
import '../cubit/financial_certificate_cubit.dart';
import 'financial_conditions.dart';
import 'financial_recipient.dart';
import 'financial_latin_identity.dart';

class FinancialCertificateContent extends StatelessWidget {
  const FinancialCertificateContent({super.key, required this.state});
  final FinancialCertificateState state;
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
                Text(
                  getFinancialCertificateCatalogMessage(state.catalogStatus),
                ),
                if (state.catalogStatus == RequestStatus.failure)
                  AppButton(
                    label: S.current.dashboardRetry,
                    onPressed: context
                        .read<FinancialCertificateCubit>()
                        .fetchCatalog,
                  ),
              ],
            )
          else if (state.step == FinancialCertificateStep.conditions)
            FinancialConditions(state: state)
          else if (state.step == FinancialCertificateStep.recipient)
            FinancialRecipient(state: state)
          else if (state.step == FinancialCertificateStep.latinIdentity)
            FinancialLatinIdentityForm(state: state)
          else if (state.step == FinancialCertificateStep.delivery)
            CertificateDeliveryForm(
              addresses: state.addresses,
              address: state.address,
              otherRecipient: state.isOtherRecipient,
              recipientName: state.deliveryRecipientName,
              recipientNationalId: state.deliveryRecipientNationalId,
              includeAgent: state.isIncludeAgent,
              agentIdentifier: state.agentIdentifier,
              onAddress: context
                  .read<FinancialCertificateCubit>()
                  .selectAddress,
              onAddAddress: context
                  .read<FinancialCertificateCubit>()
                  .requestAddAddress,
              onDeleteAddress: context
                  .read<FinancialCertificateCubit>()
                  .requestDeleteAddress,
              onOtherRecipient: context
                  .read<FinancialCertificateCubit>()
                  .updateOtherRecipient,
              onRecipientName: context
                  .read<FinancialCertificateCubit>()
                  .updateRecipientName,
              onRecipientNationalId: context
                  .read<FinancialCertificateCubit>()
                  .updateRecipientNationalId,
              canCheckAgent: state.canCheckAgent,
              onAgentLookup: context
                  .read<FinancialCertificateCubit>()
                  .requestAgentLookup,
              onIncludeAgent: context
                  .read<FinancialCertificateCubit>()
                  .updateIncludeAgent,
              onAgent: context
                  .read<FinancialCertificateCubit>()
                  .updateAgentIdentifier,
            )
          else
            CertificateConfirmation(
              depositNumber: state.deposit!.number,
              operation: S.current.financialCertificate,
              catalog: state.catalog!,
              total: state.totalRial,
              walletSufficient: state.isWalletSufficient,
              summaryExpanded: state.isSummaryExpanded,
              invoiceExpanded: state.isInvoiceExpanded,
              onSummary: context
                  .read<FinancialCertificateCubit>()
                  .updateSummaryExpanded,
              onInvoice: context
                  .read<FinancialCertificateCubit>()
                  .updateInvoiceExpanded,
              operationDivider: AppAssets.financialCertificateOperation,
              summaryChevron: AppAssets.financialCertificateChevron,
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

String getFinancialCertificateCatalogMessage(RequestStatus status) {
  return switch (status) {
    RequestStatus.failure => S.current.dashboardLoadError,
    RequestStatus.success => S.current.depositsEmpty,
    _ => S.current.dashboardLoading,
  };
}
