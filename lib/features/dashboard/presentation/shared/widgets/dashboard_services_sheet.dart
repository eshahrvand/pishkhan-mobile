import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_all_services_screen.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
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
  late String _query;
  final _collapsed = <DashboardCategory>{};
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _query = widget.initialQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _normalize(String value) => value
      .trim()
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll('\u200c', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
  @override
  Widget build(BuildContext context) {
    final searching = _query.isNotEmpty;
    final groups = [
      for (final category in DashboardCategory.values)
        (
          category,
          category.services
              .where(
                (service) =>
                    (widget.category == null ||
                        widget.category!.contains(service)) &&
                    _normalize(service.catalogLabel(context.l10n))
                        .contains(_normalize(_query)),
              )
              .toList(),
        ),
    ].where((group) => group.$2.isNotEmpty).toList();
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
                  key: const Key('dashboard_services_sheet'),
                  color: context.colors.surfaceSubtle,
                  borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      AppBottomSheetHeader(
                        title: context.l10n.servicesList,
                        showRightIcon: false,
                        leftIcon: SvgPicture.asset(
                          AppAssets.iconClose24Gray700,
                        ),
                        onLeftAction: () => Navigator.of(context).pop(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: AppSearchField(
                          key: const Key('dashboard_service_search'),
                          controller: _controller,
                          clearIcon: SvgPicture.asset(
                            AppAssets.dashboardSearchClear,
                          ),
                          hintText: context.l10n.dashboardSearchHint,
                          textStyle: AppTypography.bodyMedium.copyWith(
                            height: 20 / 14,
                            letterSpacing: 0,
                          ),
                          searchIcon: SizedBox(
                            width: 48,
                            height: 44,
                            child: Center(
                              child: SvgPicture.asset(
                                AppAssets.dashboardCatalogSearch,
                              ),
                            ),
                          ),
                          focusRing: AppTextFieldFocusRing.subtle,
                          onChanged: (value) =>
                              setState(() => _query = value.trim()),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          key: const Key('dashboard_service_options_scroll'),
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (groups.isEmpty)
                                Text(
                                  context.l10n.dashboardNoServices,
                                  style: AppTypography.bodyMedium,
                                ),
                              for (final group in groups) ...[
                                if (group != groups.first)
                                  SizedBox(
                                    height:
                                        group.$1 == DashboardCategory.transfers
                                        ? 32
                                        : 16,
                                  ),
                                DashboardCategoryHeading(
                                  key: Key(
                                    'dashboard_category_${group.$1.name}',
                                  ),
                                  category: group.$1,
                                  compact: true,
                                  collapsed: _collapsed.contains(group.$1),
                                  active:
                                      !searching &&
                                      group.$1 == DashboardCategory.cards,
                                  search: searching,
                                  onTap:
                                      searching ||
                                          group.$1 != DashboardCategory.cards
                                      ? null
                                      : () => setState(() {
                                          if (!_collapsed.remove(group.$1)) {
                                            _collapsed.add(group.$1);
                                          }
                                        }),
                                ),
                                if (searching) ...[
                                  const SizedBox(height: 16),
                                  for (final service in group.$2) ...[
                                    _option(context, service, plain: true),
                                    if (service != group.$2.last)
                                      const SizedBox(height: 16),
                                  ],
                                ] else if (!_collapsed.contains(group.$1)) ...[
                                  const SizedBox(height: 16),
                                  LayoutBuilder(
                                    builder: (context, constraints) => Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final service in group.$2)
                                          SizedBox(
                                            width:
                                                service ==
                                                        DashboardService
                                                            .cardDeposit ||
                                                    service ==
                                                        DashboardService
                                                            .expiredGift ||
                                                    (group.$2.length.isOdd &&
                                                        service ==
                                                            group.$2.last)
                                                ? constraints.maxWidth
                                                : (constraints.maxWidth - 8) /
                                                      2,
                                            child: _option(context, service),
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
  }

  Widget _option(
    BuildContext context,
    DashboardService service, {
    bool plain = false,
  }) {
    final enabled = !widget.excluded.contains(service.id);
    return Semantics(
      button: true,
      enabled: enabled,
      label: service.catalogLabel(context.l10n),
      child: Opacity(
        opacity: enabled ? 1 : .45,
        child: Material(
          color: plain ? Colors.transparent : AppDashboardColors.tileSurface,
          borderRadius: AppRadius.borderMd,
          child: InkWell(
            key: Key('app_service_grid_icon_catalog-${service.id}'),
            onTap: enabled ? () => Navigator.of(context).pop(service) : null,
            borderRadius: AppRadius.borderMd,
            child: Container(
              constraints: BoxConstraints(minHeight: plain ? 20 : 40),
              padding: plain
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: plain
                  ? null
                  : BoxDecoration(
                      border: Border.all(
                        color: context.colors.border,
                        width: .8,
                      ),
                      borderRadius: AppRadius.borderMd,
                    ),
              child: Row(
                children: [
                  SvgPicture.asset(service.optionAsset),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      service.catalogLabel(context.l10n),
                      style: AppTypography.bodySmall.copyWith(
                        color: plain
                            ? context.colors.textPrimary
                            : AppDashboardColors.optionText,
                        fontWeight: FontWeight.w500,
                        height: 18 / 12,
                        letterSpacing: 0,
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
            key: const Key('dashboard_reset_sheet'),
            color: context.colors.surfaceSubtle,
            borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBottomSheetHeader(
                    title: context.l10n.dashboardResetTitle,
                    showRightIcon: false,
                    showLeftAction: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Text(
                      context.l10n.dashboardResetDescription,
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
                            key: const Key('dashboard_reset_confirm'),
                            onPressed: () => Navigator.of(context).pop(true),
                            label: context.l10n.dashboardResetConfirm,
                            size: AppButtonSize.lg,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            key: const Key('dashboard_reset_cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                            label: context.l10n.dashboardCancel,
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
