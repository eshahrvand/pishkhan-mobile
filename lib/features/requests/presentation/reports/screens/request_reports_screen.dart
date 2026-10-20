import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../cubit/request_reports_cubit.dart';
import '../widgets/report_cancellation_sheet.dart';
import '../widgets/report_date_filter_sheet.dart';
import '../widgets/report_details_sheet.dart';
import '../widgets/report_filters.dart';
import '../widgets/report_status_filter_sheet.dart';
import '../widgets/report_type_filter_sheet.dart';
import '../widgets/reports_list.dart';

class RequestReportsScreen extends StatelessWidget {
  const RequestReportsScreen({super.key, this.onAssistantPressed});

  final VoidCallback? onAssistantPressed;

  Future<void> _handleEffect(
    BuildContext context,
    RequestReportsState state,
  ) async {
    switch (state.effect) {
      case RequestReportsEffect.typeFilter:
        await showReportTypeFilterSheet(context);
        if (context.mounted) {
          context.read<RequestReportsCubit>().cancelDraftFilter();
        }
      case RequestReportsEffect.statusFilter:
        await showReportStatusFilterSheet(context);
        if (context.mounted) {
          context.read<RequestReportsCubit>().cancelDraftFilter();
        }
      case RequestReportsEffect.dateFilter:
        await showReportDateFilterSheet(context);
        if (context.mounted) {
          context.read<RequestReportsCubit>().cancelDraftFilter();
        }
      case RequestReportsEffect.details:
        final result = await showReportDetailsSheet(context);
        if (context.mounted) {
          context.read<RequestReportsCubit>().applyDetailsResult(result);
        }
      case RequestReportsEffect.cancelConfirmation:
        await showReportCancellationSheet(context);
      case RequestReportsEffect.back:
        NavigationActions.back(context);
      case RequestReportsEffect.assistant:
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RequestReportsCubit()..fetchReports(),
      child: BlocListener<RequestReportsCubit, RequestReportsState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleEffect,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      Builder(
                        builder: (context) {
                          return AppTopBar(
                            title: S.current.reportTitle,
                            showLeadingActions: false,
                            trailingIcon: const AvpImage(
                              image: AppAssets.depositFeatureBack,
                            ),
                            trailingTooltip: S.current.backLabel,
                            onTrailingPressed: () {
                              context.read<RequestReportsCubit>().requestBack();
                            },
                          );
                        },
                      ),
                      const ReportFilters(),
                      const Expanded(child: ReportsList()),
                    ],
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Builder(
                      builder: (context) {
                        return AppAssistantButton(
                          onPressed: () {
                            context
                                .read<RequestReportsCubit>()
                                .requestAssistant();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
