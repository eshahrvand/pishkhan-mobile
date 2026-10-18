import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../shared/certificate_confirmation.dart';
import 'financial_certificate_delivery_form.dart';
import '../cubit/financial_certificate_cubit.dart';
import 'financial_conditions.dart';
import 'financial_recipient.dart';
import 'financial_latin_identity.dart';

class FinancialCertificateContent extends StatelessWidget {
  const FinancialCertificateContent({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
      buildWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus,
      builder: (context, state) {
        return AbsorbPointer(
          absorbing:
              state.submissionStatus == RequestStatus.loading ||
              state.submissionStatus == RequestStatus.success,
          child:
              BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
                buildWhen: (previous, current) =>
                    previous.catalogStatus != current.catalogStatus ||
                    previous.catalog != current.catalog ||
                    previous.step != current.step,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.catalogStatus != RequestStatus.success ||
                          state.catalog!.deposits.isEmpty)
                        Column(
                          children: [
                            Text(
                              getFinancialCertificateCatalogMessage(
                                state.catalogStatus,
                              ),
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
                      else if (state.step ==
                          FinancialCertificateStep.conditions)
                        const FinancialConditions()
                      else if (state.step == FinancialCertificateStep.recipient)
                        const FinancialRecipient()
                      else if (state.step ==
                          FinancialCertificateStep.latinIdentity)
                        const FinancialLatinIdentityForm()
                      else if (state.step == FinancialCertificateStep.delivery)
                        const FinancialCertificateDeliveryForm()
                      else
                        BlocBuilder<
                          FinancialCertificateCubit,
                          FinancialCertificateState
                        >(
                          buildWhen: (previous, current) =>
                              previous.isSummaryExpanded !=
                                  current.isSummaryExpanded ||
                              previous.isInvoiceExpanded !=
                                  current.isInvoiceExpanded,
                          builder: (context, state) {
                            return CertificateConfirmation(
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
                              operationDivider:
                                  AppAssets.financialCertificateOperation,
                              summaryChevron:
                                  AppAssets.financialCertificateChevron,
                            );
                          },
                        ),
                      BlocBuilder<
                        FinancialCertificateCubit,
                        FinancialCertificateState
                      >(
                        buildWhen: (previous, current) =>
                            previous.submissionFailure !=
                                current.submissionFailure ||
                            previous.catalogStatus != current.catalogStatus,
                        builder: (context, state) {
                          if (state.submissionFailure != null &&
                              state.catalogStatus == RequestStatus.success) {
                            return Text(
                              S.current.issuanceSubmitError,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: context.colors.error),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  );
                },
              ),
        );
      },
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
