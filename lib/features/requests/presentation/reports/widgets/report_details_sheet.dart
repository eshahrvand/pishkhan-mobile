import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

import '../cubit/request_reports_cubit.dart';
import 'report_detail_row.dart';
import 'report_labels.dart';

Future<RequestDetailsAction?> showReportDetailsSheet(BuildContext context) {
  return showAppServiceSheet<RequestDetailsAction>(
    context,
    BlocProvider.value(
      value: context.read<RequestReportsCubit>(),
      child: const ReportDetailsSheet(),
    ),
  );
}

class ReportDetailsSheet extends StatelessWidget {
  const ReportDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestReportsCubit, RequestReportsState>(
      buildWhen: (previous, current) =>
          previous.selectedReport != current.selectedReport ||
          previous.canCancelRequest != current.canCancelRequest,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: S.current.reportDetailsTitle,
              showLeftAction: false,
              showRightIcon: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                children: [
                  ReportDetailRow(
                    label: S.current.reportRequestType,
                    value: Text(reportTypeLabel(state.selectedReport!.type)),
                  ),
                  ReportDetailRow(
                    label: S.current.reportIdentifier,
                    value: Text(
                      CurrencyFormatter.toPersianDigits(
                        state.selectedReport!.trackingId,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  ReportDetailRow(
                    label: S.current.reportRequestDate,
                    value: Text(
                      reportDateLabel(state.selectedReport!.createdAt),
                    ),
                  ),
                  ReportDetailRow(
                    label: S.current.reportDetails,
                    value: Text(state.selectedReport!.details),
                  ),
                  ReportDetailRow(
                    label: S.current.reportStatus,
                    showDivider: state.canCancelRequest,
                    value: AppBadge(
                      label: reportStatusLabel(state.selectedReport!.status),
                      color: reportStatusColor(state.selectedReport!.status),
                      background: AppBadgeBackground.light,
                      size: AppBadgeSize.small,
                      corner: AppBadgeCorner.pill,
                    ),
                  ),
                ],
              ),
            ),
            if (state.canCancelRequest)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: S.current.backLabel,
                        variant: AppButtonVariant.secondaryGray,
                        size: AppButtonSize.lg,
                        constrainLabel: true,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: S.current.reportCancelRequest,
                        isDestructive: true,
                        size: AppButtonSize.lg,
                        constrainLabel: true,
                        onPressed: () {
                          Navigator.of(context)
                              .pop(RequestDetailsAction.cancelRequest);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
