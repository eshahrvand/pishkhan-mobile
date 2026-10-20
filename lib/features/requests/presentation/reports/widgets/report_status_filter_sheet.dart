import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

import '../../../domain/entities/request_report.dart';
import '../cubit/request_reports_cubit.dart';
import 'report_filter_footer.dart';
import 'report_filter_option.dart';
import 'report_labels.dart';

Future<void> showReportStatusFilterSheet(BuildContext context) {
  return showAppServiceSheet<void>(
    context,
    BlocProvider.value(
      value: context.read<RequestReportsCubit>(),
      child: const ReportStatusFilterSheet(),
    ),
  );
}

class ReportStatusFilterSheet extends StatelessWidget {
  const ReportStatusFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          title: S.current.reportRequestStatus,
          showLeftAction: false,
          showRightIcon: false,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: BlocBuilder<RequestReportsCubit, RequestReportsState>(
            buildWhen: (previous, current) =>
                previous.draftFilter != current.draftFilter,
            builder: (context, state) {
              return Column(
                children: [
                  ReportFilterOption(
                    label: S.current.reportSelectAll,
                    selected: state.draftFilter?.statuses == null,
                    onPressed: () {
                      context
                          .read<RequestReportsCubit>()
                          .toggleAllDraftStatuses();
                    },
                  ),
                  for (final status in const [
                    ReportRequestStatus.completed,
                    ReportRequestStatus.awaitingApproval,
                    ReportRequestStatus.rejected,
                    ReportRequestStatus.systemError,
                    ReportRequestStatus.cancelled,
                  ])
                    ReportFilterOption(
                      label: reportFilterStatusLabel(status),
                      selected:
                          state.draftFilter?.statuses?.contains(status) ?? true,
                      onPressed: () {
                        context.read<RequestReportsCubit>().toggleDraftStatus(
                          status,
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
        const ReportFilterFooter(),
      ],
    );
  }
}
