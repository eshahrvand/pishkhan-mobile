import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

import '../cubit/request_reports_cubit.dart';

Future<void> showReportCancellationSheet(BuildContext context) {
  return showAppServiceSheet<void>(
    context,
    BlocProvider.value(
      value: context.read<RequestReportsCubit>(),
      child: const ReportCancellationSheet(),
    ),
  );
}

class ReportCancellationSheet extends StatelessWidget {
  const ReportCancellationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestReportsCubit, RequestReportsState>(
      listenWhen: (previous, current) =>
          previous.cancellationStatus != current.cancellationStatus &&
          current.cancellationStatus == RequestStatus.success,
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      buildWhen: (previous, current) =>
          previous.cancellationStatus != current.cancellationStatus ||
          previous.canCancelRequest != current.canCancelRequest,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: S.current.reportCancelRequest,
              showLeftAction: false,
              showRightIcon: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    S.current.reportCancelPrompt,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: S.current.dashboardCancel,
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
                      label: S.current.reportConfirmCancel,
                      isDestructive: true,
                      size: AppButtonSize.lg,
                      constrainLabel: true,
                      isLoading:
                          state.cancellationStatus == RequestStatus.loading,
                      onPressed: state.canCancelRequest
                          ? () {
                              context
                                  .read<RequestReportsCubit>()
                                  .submitCancellation();
                            }
                          : null,
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
