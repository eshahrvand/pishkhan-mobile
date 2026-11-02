import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/certificate_confirmation.dart';
import 'average_balance_delivery_form.dart';
import '../cubit/average_balance_cubit.dart';
import 'average_balance_conditions.dart';

class AverageBalanceContent extends StatelessWidget {
  const AverageBalanceContent({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
      buildWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus,
      builder: (context, state) {
        return AbsorbPointer(
          absorbing:
              state.submissionStatus == RequestStatus.loading ||
              state.submissionStatus == RequestStatus.success,
          child: BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
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
                          getAverageBalanceCatalogMessage(state.catalogStatus),
                        ),
                        if (state.catalogStatus == RequestStatus.failure)
                          AppButton(
                            isLoading:
                                state.catalogStatus == RequestStatus.loading,
                            label: S.current.dashboardRetry,
                            onPressed: context
                                .read<AverageBalanceCubit>()
                                .fetchCatalog,
                          ),
                      ],
                    )
                  else if (state.step == AverageBalanceStep.conditions)
                    const AverageBalanceConditions()
                  else if (state.step == AverageBalanceStep.delivery)
                    const AverageBalanceDeliveryForm()
                  else
                    BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
                      buildWhen: (previous, current) =>
                          previous.isSummaryExpanded !=
                              current.isSummaryExpanded ||
                          previous.isInvoiceExpanded !=
                              current.isInvoiceExpanded,
                      builder: (context, state) {
                        return CertificateConfirmation(
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
                        );
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

String getAverageBalanceCatalogMessage(RequestStatus status) {
  return switch (status) {
    RequestStatus.failure => S.current.dashboardLoadError,
    RequestStatus.success => S.current.depositsEmpty,
    _ => S.current.dashboardLoading,
  };
}
