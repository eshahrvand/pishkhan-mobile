import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/dashboard_services_sheet_cubit.dart';
import 'dashboard_service_group_section.dart';

import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

Future<DashboardService?> showDashboardServicesSheet(
  BuildContext context, {
  Iterable<String> excluded = const [],
  List<DashboardService>? category,
}) => showModalBottomSheet<DashboardService>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  barrierColor: AppDashboardColors.sheetScrim.withValues(alpha: .64),
  builder: (_) => BackdropFilter(
    filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
    child: DashboardServicesSheet(excluded: excluded, category: category),
  ),
);

class DashboardServicesSheet extends StatefulWidget {
  const DashboardServicesSheet({
    super.key,
    this.excluded = const [],
    this.category,
    this.initialQuery = '',
  });
  final Iterable<String> excluded;
  final List<DashboardService>? category;
  final String initialQuery;
  @override
  State<DashboardServicesSheet> createState() => _DashboardServicesSheetState();
}

class _DashboardServicesSheetState extends State<DashboardServicesSheet> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardServicesSheetCubit(
        excluded: widget.excluded,
        category: widget.category,
        initialState: DashboardServicesSheetState.initial(
          query: widget.initialQuery,
        ),
      )..loadServices(getDashboardServiceSearchLabels()),
      child:
          BlocConsumer<
            DashboardServicesSheetCubit,
            DashboardServicesSheetState
          >(
            listenWhen: (previous, current) =>
                previous.selectionId != current.selectionId,
            listener: (context, state) =>
                Navigator.of(context).pop(state.selectedService),
            buildWhen: (previous, current) =>
                previous.groups != current.groups ||
                previous.isSearching != current.isSearching,
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
                                    image: AppAssets.iconClose24Gray700,
                                  ),
                                  onLeftAction: () =>
                                      Navigator.of(context).pop(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    20,
                                    20,
                                    0,
                                  ),
                                  child: AppSearchField(
                                    controller: _controller,
                                    clearIcon: AvpImage(
                                      image: AppAssets.dashboardSearchClear,
                                    ),
                                    hintText: S.current.dashboardSearchHint,
                                    textStyle: AppTypography.bodyMedium
                                        .copyWith(
                                          height: 20 / 14,
                                          letterSpacing: 0,
                                        ),
                                    searchIcon: SizedBox(
                                      width: 48,
                                      height: 44,
                                      child: Center(
                                        child: AvpImage(
                                          image:
                                              AppAssets.dashboardCatalogSearch,
                                        ),
                                      ),
                                    ),
                                    focusRing: AppTextFieldFocusRing.subtle,
                                    onChanged: (value) => context
                                        .read<DashboardServicesSheetCubit>()
                                        .updateQuery(value),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (state.groups.isEmpty)
                                          Text(
                                            S.current.dashboardNoServices,
                                            style: AppTypography.bodyMedium,
                                          ),
                                        for (final group in state.groups) ...[
                                          if (group != state.groups.first)
                                            SizedBox(
                                              height:
                                                  group.category ==
                                                      DashboardCategory
                                                          .transfers
                                                  ? 32
                                                  : 16,
                                            ),
                                          DashboardServiceGroupSection(
                                            group: group,
                                            isSearching: state.isSearching,
                                            onSelected: (service) => context
                                                .read<
                                                  DashboardServicesSheetCubit
                                                >()
                                                .selectService(service),
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
          ),
    );
  }
}

Future<bool?> showDashboardResetSheet(BuildContext context) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppDashboardColors.sheetScrim.withValues(alpha: .64),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Material(
            color: context.colors.surfaceSubtle,
            borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBottomSheetHeader(
                    title: S.current.dashboardResetTitle,
                    showRightIcon: false,
                    showLeftAction: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Text(
                      S.current.dashboardResetDescription,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                        letterSpacing: 0,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(
                          child: AppButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            label: S.current.dashboardResetConfirm,
                            size: AppButtonSize.lg,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            label: S.current.dashboardCancel,
                            variant: AppButtonVariant.secondaryGray,
                            size: AppButtonSize.lg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
