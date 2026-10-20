import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

import '../../../domain/entities/request_report.dart';
import '../cubit/request_reports_cubit.dart';
import 'report_filter_footer.dart';
import 'report_labels.dart';

Future<void> showReportDateFilterSheet(BuildContext context) {
  return showAppServiceSheet<void>(
    context,
    BlocProvider.value(
      value: context.read<RequestReportsCubit>(),
      child: const ReportDateFilterSheet(),
    ),
  );
}

class ReportDateFilterSheet extends StatelessWidget {
  const ReportDateFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          title: S.current.reportRequestDate,
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
                  for (final period in const [
                    ReportDatePeriod.today,
                    ReportDatePeriod.lastWeek,
                    ReportDatePeriod.lastMonth,
                    ReportDatePeriod.lastThreeMonths,
                  ])
                    SizedBox(
                      height: 56,
                      child: Semantics(
                        checked: state.draftFilter?.period == period,
                        inMutuallyExclusiveGroup: true,
                        child: InkWell(
                          onTap: () {
                            context
                                .read<RequestReportsCubit>()
                                .selectDraftPeriod(period);
                          },
                          child: Row(
                            children: [
                              // avp_ui has no circular radio. Reuse the authored
                              // cheque choice's exact Figma check and theme tokens.
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: state.draftFilter?.period == period
                                      ? context.colors.primary
                                      : context.colors.surface,
                                  border: Border.all(
                                    color: state.draftFilter?.period == period
                                        ? context.colors.primary
                                        : context.colors.border,
                                  ),
                                ),
                                child: state.draftFilter?.period == period
                                    ? const Center(
                                        child: AvpImage(
                                          image: AppAssets.chequeCancelCheck,
                                          width: 16,
                                          height: 16,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  reportPeriodLabel(period),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: context.colors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                        height: 20 / 14,
                                        letterSpacing: 0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
