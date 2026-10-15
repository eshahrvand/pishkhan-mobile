import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/dashboard_services_sheet_cubit.dart';
import 'dashboard_service_option.dart';

import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_category_heading.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

Future<DashboardService?> showDashboardServicesSheet(
  BuildContext context, {
  Set<String> excluded = const {},
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
    this.excluded = const {},
    this.category,
    this.initialQuery = '',
  });
  final Set<String> excluded;
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
      create: (context) =>
          DashboardServicesSheetCubit(initialQuery: widget.initialQuery),
      child: BlocBuilder<DashboardServicesSheetCubit, DashboardServicesSheetState>(
        buildWhen: (previous, current) =>
            previous.query != current.query ||
            previous.collapsedCategories != current.collapsedCategories,
        builder: (context, state) {
          final groups = {
            for (final category in DashboardCategory.values)
              category: context
                  .read<DashboardServicesSheetCubit>()
                  .searchServices(category, widget.category),
          }..removeWhere((category, services) => services.isEmpty);
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
                              onLeftAction: () => Navigator.of(context).pop(),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: AppSearchField(
                                controller: _controller,
                                clearIcon: AvpImage(
                                  image: AppAssets.dashboardSearchClear,
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
                                      image: AppAssets.dashboardCatalogSearch,
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
                                    if (groups.isEmpty)
                                      Text(
                                        S.current.dashboardNoServices,
                                        style: AppTypography.bodyMedium,
                                      ),
                                    for (final group in groups.entries) ...[
                                      if (group.key != groups.keys.first)
                                        SizedBox(
                                          height:
                                              group.key ==
                                                  DashboardCategory.transfers
                                              ? 32
                                              : 16,
                                        ),
                                      DashboardCategoryHeading(
                                        category: group.key,
                                        compact: true,
                                        collapsed: state.collapsedCategories
                                            .contains(group.key),
                                        active:
                                            state.query.isEmpty &&
                                            group.key ==
                                                DashboardCategory.cards,
                                        search: state.query.isNotEmpty,
                                        onTap:
                                            state.query.isNotEmpty ||
                                                group.key !=
                                                    DashboardCategory.cards
                                            ? null
                                            : () => context
                                                  .read<
                                                    DashboardServicesSheetCubit
                                                  >()
                                                  .toggleCategory(group.key),
                                      ),
                                      if (state.query.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        for (final service in group.value) ...[
                                          DashboardServiceOption(
                                            service: service,
                                            enabled: !widget.excluded.contains(
                                              service.id,
                                            ),
                                            plain: true,
                                          ),
                                          if (service != group.value.last)
                                            const SizedBox(height: 16),
                                        ],
                                      ] else if (!state.collapsedCategories
                                          .contains(group.key)) ...[
                                        const SizedBox(height: 16),
                                        LayoutBuilder(
                                          builder: (context, constraints) => Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              for (final service in group.value)
                                                SizedBox(
                                                  width:
                                                      service ==
                                                              DashboardService
                                                                  .cardDeposit ||
                                                          service ==
                                                              DashboardService
                                                                  .expiredGift ||
                                                          (group
                                                                  .value
                                                                  .length
                                                                  .isOdd &&
                                                              service ==
                                                                  group
                                                                      .value
                                                                      .last)
                                                      ? constraints.maxWidth
                                                      : (constraints.maxWidth -
                                                                8) /
                                                            2,
                                                  child: DashboardServiceOption(
                                                    service: service,
                                                    enabled: !widget.excluded
                                                        .contains(service.id),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
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
