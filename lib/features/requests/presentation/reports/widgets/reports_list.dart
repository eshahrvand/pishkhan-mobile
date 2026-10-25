import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_request_report_card.dart';

import '../cubit/request_reports_cubit.dart';
import 'report_labels.dart';

class ReportsList extends StatelessWidget {
  const ReportsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestReportsCubit, RequestReportsState>(
      buildWhen: (previous, current) =>
          previous.reportsStatus != current.reportsStatus ||
          previous.visibleReports != current.visibleReports ||
          previous.cancellationStatus != current.cancellationStatus,
      builder: (context, state) {
        if (state.reportsStatus == RequestStatus.initial ||
            state.reportsStatus == RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.reportsStatus == RequestStatus.failure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox.shrink(),
                  const SizedBox(height: 12),
                  AppButton(
                    isLoading: state.reportsStatus == RequestStatus.loading,
                    label: S.current.dashboardRetry,
                    onPressed: () {
                      context.read<RequestReportsCubit>().fetchReports();
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          notificationPredicate: (notification) =>
              notification.depth == 0 &&
              state.cancellationStatus != RequestStatus.loading,
          onRefresh: () {
            return context.read<RequestReportsCubit>().fetchReports();
          },
          child: state.visibleReports.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(32),
                  children: [
                    Text(
                      S.current.reportNoResults,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 76),
                  itemCount: state.visibleReports.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return AppRequestReportCard(
                      width: double.infinity,
                      title: reportTypeLabel(state.visibleReports[index].type),
                      requestNumber: CurrencyFormatter.toPersianDigits(
                        state.visibleReports[index].trackingId,
                      ),
                      identifierLabel: '${S.current.reportIdentifier}:',
                      detailsLabel: '${S.current.reportDetails}:',
                      details: state.visibleReports[index].details,
                      showDetails: state.visibleReports[index].showListDetails,
                      date: reportDateLabel(
                        state.visibleReports[index].createdAt,
                      ),
                      statusLabel: reportStatusLabel(
                        state.visibleReports[index].status,
                      ),
                      statusColor: reportStatusColor(
                        state.visibleReports[index].status,
                      ),
                      statusCorner: AppBadgeCorner.pill,
                      onMoreTap:
                          state.cancellationStatus == RequestStatus.loading
                          ? null
                          : () {
                              context
                                  .read<RequestReportsCubit>()
                                  .requestDetails(state.visibleReports[index]);
                            },
                    );
                  },
                ),
        );
      },
    );
  }
}
