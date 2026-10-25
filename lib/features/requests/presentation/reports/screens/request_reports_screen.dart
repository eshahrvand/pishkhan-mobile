import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
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
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case RequestReportsEffect.typeFilter:
        context.read<RequestReportsCubit>().consumeRequestReportsInteraction();
        await showReportTypeFilterSheet(context);
        if (context.mounted) {
          context.read<RequestReportsCubit>().cancelDraftFilter();
        }
      case RequestReportsEffect.statusFilter:
        context.read<RequestReportsCubit>().consumeRequestReportsInteraction();
        await showReportStatusFilterSheet(context);
        if (context.mounted) {
          context.read<RequestReportsCubit>().cancelDraftFilter();
        }
      case RequestReportsEffect.dateFilter:
        context.read<RequestReportsCubit>().consumeRequestReportsInteraction();
        await showReportDateFilterSheet(context);
        if (context.mounted) {
          context.read<RequestReportsCubit>().cancelDraftFilter();
        }
      case RequestReportsEffect.details:
        context.read<RequestReportsCubit>().consumeRequestReportsInteraction();
        final result = await showReportDetailsSheet(context);
        if (context.mounted) {
          context.read<RequestReportsCubit>().applyDetailsResult(result);
        }
      case RequestReportsEffect.cancelConfirmation:
        context.read<RequestReportsCubit>().consumeRequestReportsInteraction();
        await showReportCancellationSheet(context);
      case RequestReportsEffect.back:
        NavigationActions.back(context);
      case RequestReportsEffect.assistant:
        context.read<RequestReportsCubit>().consumeRequestReportsInteraction();
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
            (previous.effect != current.effect && current.effect != null) ||
            ((previous.reportsStatus != current.reportsStatus &&
                    current.reportsStatus == RequestStatus.failure) ||
                (previous.cancellationStatus != current.cancellationStatus &&
                    current.cancellationStatus == RequestStatus.failure)),
        listener: _handleEffect,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<RequestReportsCubit, RequestReportsState>(
            builder: (context, state) {
              return PopScope(
                canPop:
                    state.reportsStatus != RequestStatus.loading &&
                    state.cancellationStatus != RequestStatus.loading,
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
                                    image:
                                        '${AppConstants.baseImage}deposit_list_back.svg',
                                  ),
                                  trailingTooltip: S.current.backLabel,
                                  onTrailingPressed:
                                      (state.reportsStatus !=
                                              RequestStatus.loading &&
                                          state.cancellationStatus !=
                                              RequestStatus.loading)
                                      ? () {
                                          context
                                              .read<RequestReportsCubit>()
                                              .requestBack();
                                        }
                                      : null,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
