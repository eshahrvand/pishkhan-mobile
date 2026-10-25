import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

import '../cubit/request_reports_cubit.dart';
import 'report_filter_footer.dart';
import 'report_filter_option.dart';
import 'report_labels.dart';

Future<void> showReportTypeFilterSheet(BuildContext context) {
  return showAppServiceSheet<void>(
    context,
    BlocProvider.value(
      value: context.read<RequestReportsCubit>(),
      child: const ReportTypeFilterSheet(),
    ),
  );
}

class ReportTypeFilterSheet extends StatelessWidget {
  const ReportTypeFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        // Keep Apply/Cancel reachable while the type list scrolls above the keyboard.
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context).height -
              MediaQueryData.fromView(View.of(context)).viewPadding.vertical -
              MediaQuery.viewInsetsOf(context).bottom -
              12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: S.current.reportRequestType,
              showLeftAction: false,
              showRightIcon: false,
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: BlocBuilder<RequestReportsCubit, RequestReportsState>(
                    buildWhen: (previous, current) =>
                        previous.typeQuery != current.typeQuery ||
                        previous.draftFilter != current.draftFilter ||
                        previous.visibleTypes != current.visibleTypes,
                    builder: (context, state) {
                      return Column(
                        children: [
                          AppTextField(
                            value: state.typeQuery,
                            hintText: S.current.reportSearchTypes,
                            textStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  height: 20 / 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0,
                                ),
                            prefixIcon: const SizedBox(
                              width: 48,
                              height: 44,
                              child: Center(
                                child: AvpImage(
                                  image:
                                      '${AppConstants.baseImage}card_features_search.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              context
                                  .read<RequestReportsCubit>()
                                  .updateTypeQuery(value);
                            },
                          ),
                          const SizedBox(height: 12),
                          ReportFilterOption(
                            label: S.current.reportSelectAll,
                            selected: state.draftFilter?.types == null,
                            onPressed: () {
                              context
                                  .read<RequestReportsCubit>()
                                  .toggleAllDraftTypes();
                            },
                          ),
                          for (final type in state.visibleTypes)
                            ReportFilterOption(
                              label: reportTypeLabel(type),
                              selected:
                                  state.draftFilter?.types?.contains(type) ??
                                  true,
                              onPressed: () {
                                context
                                    .read<RequestReportsCubit>()
                                    .toggleDraftType(type);
                              },
                            ),
                          if (state.visibleTypes.isEmpty)
                            Text(S.current.reportNoTypes),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const ReportFilterFooter(),
          ],
        ),
      ),
    );
  }
}
