import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../shared/dashboard_services.dart';
import '../cubit/home_cubit.dart';
import 'dashboard_service_group_section.dart';

Future<DashboardService?> showDashboardServicesSheet(BuildContext context) =>
    showModalBottomSheet<DashboardService>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppDashboardColors.sheetScrim.withValues(alpha: .64),
      builder: (_) => BlocProvider.value(
        value: context.read<HomeCubit>(),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: const DashboardServicesSheet(),
        ),
      ),
    );

class DashboardServicesSheet extends StatelessWidget {
  const DashboardServicesSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.pickedService != current.pickedService &&
          current.pickedService != null,
      listener: (context, state) =>
          Navigator.of(context).pop(state.pickedService),
      buildWhen: (previous, current) =>
          previous.servicePickerGroups != current.servicePickerGroups ||
          previous.isServicePickerSearching != current.isServicePickerSearching,
      builder: (context, state) {
        final insets = MediaQuery.viewInsetsOf(context).bottom;
        return LayoutBuilder(
          builder: (context, constraints) {
            final available =
                constraints.maxHeight -
                insets -
                MediaQuery.paddingOf(context).bottom;
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(bottom: insets),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: math.min(728, math.max(180, available - 20)),
                    child: Material(
                      color: context.colors.surfaceSubtle,
                      borderRadius: const BorderRadius.vertical(
                        top: AppRadius.xl,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          AppBottomSheetHeader(
                            title: S.current.servicesList,
                            showRightIcon: false,
                            leftIcon: AvpImage(
                              image:
                                  '${AppConstants.baseImage}icon_close_24_gray700.svg',
                            ),
                            onLeftAction: () => Navigator.of(context).pop(),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: AppSearchField(
                              clearIcon: AvpImage(
                                image:
                                    '${AppConstants.baseImage}dashboard_search_clear.svg',
                              ),
                              hintText: S.current.dashboardSearchHint,
                              textStyle: AppTypography.bodyMedium.copyWith(
                                height: 20 / 14,
                                letterSpacing: 0,
                              ),
                              searchIcon: SizedBox(
                                width: 48,
                                height: 44,
                                child: Center(
                                  child: AvpImage(
                                    image:
                                        '${AppConstants.baseImage}dashboard_catalog_search.svg',
                                  ),
                                ),
                              ),
                              focusRing: AppTextFieldFocusRing.subtle,
                              onChanged: (value) => context
                                  .read<HomeCubit>()
                                  .updateServicePickerQuery(value),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                24,
                                20,
                                32,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (state.servicePickerGroups.isEmpty)
                                    Text(
                                      S.current.dashboardNoServices,
                                      style: AppTypography.bodyMedium,
                                    ),
                                  for (final group
                                      in state.servicePickerGroups) ...[
                                    if (group !=
                                        state.servicePickerGroups.first)
                                      SizedBox(
                                        height:
                                            group.category ==
                                                DashboardCategory.transfers
                                            ? 32
                                            : 16,
                                      ),
                                    DashboardServiceGroupSection(
                                      group: group,
                                      isSearching:
                                          state.isServicePickerSearching,
                                      onSelected: (service) => context
                                          .read<HomeCubit>()
                                          .selectPickerService(service),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
