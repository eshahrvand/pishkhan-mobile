import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/request_report.dart';
import '../cubit/request_reports_cubit.dart';

class ReportFilters extends StatelessWidget {
  const ReportFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestReportsCubit, RequestReportsState>(
      buildWhen: (previous, current) =>
          previous.filter != current.filter ||
          previous.trackingQuery != current.trackingQuery ||
          previous.reportsStatus != current.reportsStatus,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: SingleChildScrollView(
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  // Leave room for shadows without narrowing the chip row.
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      AppChips(
                        label: S.current.reportRequestType,
                        selected: state.filter.types != null,
                        icon: AvpImage(
                          image: state.filter.types == null
                              ? AppAssets.depositFeatureChevron
                              : AppAssets.depositFeatureClear,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: state.reportsStatus == RequestStatus.success
                            ? () {
                                context
                                    .read<RequestReportsCubit>()
                                    .requestTypeFilter();
                              }
                            : null,
                      ),
                      const SizedBox(width: 12),
                      AppChips(
                        label: S.current.reportDate,
                        selected: state.filter.period != ReportDatePeriod.all,
                        icon: AvpImage(
                          image: state.filter.period == ReportDatePeriod.all
                              ? AppAssets.depositFeatureChevron
                              : AppAssets.depositFeatureClear,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: state.reportsStatus == RequestStatus.success
                            ? () {
                                context
                                    .read<RequestReportsCubit>()
                                    .requestDateFilter();
                              }
                            : null,
                      ),
                      const SizedBox(width: 12),
                      AppChips(
                        label: S.current.reportStatus,
                        selected: state.filter.statuses != null,
                        icon: AvpImage(
                          image: state.filter.statuses == null
                              ? AppAssets.depositFeatureChevron
                              : AppAssets.depositFeatureClear,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: state.reportsStatus == RequestStatus.success
                            ? () {
                                context
                                    .read<RequestReportsCubit>()
                                    .requestStatusFilter();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const AvpImage(
                image: AppAssets.cardFeaturesSeparator,
                height: 1,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 15),
              AppTextField(
                value: state.trackingQuery,
                hintText: S.current.reportSearchIdentifier,
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 20 / 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
                normalizeDigits: true,
                prefixIcon: const SizedBox(
                  width: 48,
                  height: 44,
                  child: Center(
                    child: AvpImage(
                      image: AppAssets.cardFeaturesSearch,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                enabled: state.reportsStatus == RequestStatus.success,
                onChanged: (value) {
                  context.read<RequestReportsCubit>().updateTrackingQuery(
                    value,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
