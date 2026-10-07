import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

class DashboardAllServicesScreen extends StatelessWidget {
  const DashboardAllServicesScreen({super.key, this.onServiceRequested});
  final ValueChanged<DashboardService>? onServiceRequested;
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: context.colors.surfaceSubtle,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  bottom: BorderSide(color: context.colors.border, width: .8),
                ),
              ),
              child: Row(
                children: [
                  AppButton(
                    key: const Key('dashboard_catalog_back'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    variant: AppButtonVariant.text,
                    semanticLabel: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    icon: SvgPicture.asset(AppAssets.dashboardCatalogBack),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      context.l10n.dashboardAllServices,
                      style: AppTypography.titleSmall.copyWith(
                        height: 20 / 14,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const Key('dashboard_all_services_scroll'),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final category in DashboardCategory.values) ...[
                      if (category != DashboardCategory.modern)
                        const SizedBox(height: 24),
                      DashboardCategoryHeading(category: category),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 300 ? 4 : 3;
                          final width =
                              (constraints.maxWidth - (columns - 1) * 6) /
                              columns;
                          return Wrap(
                            spacing: 6,
                            runSpacing: 10,
                            children: [
                              for (final service in category.services)
                                AppServiceGridItemView(
                                  width: width,
                                  tileColor: AppDashboardColors.tileSurface,
                                  labelStyle: AppTypography.bodySmall.copyWith(
                                    color: AppDashboardColors.optionText,
                                    fontWeight: FontWeight.w500,
                                    height: 18 / 12,
                                    letterSpacing: 0,
                                  ),
                                  item: AppServiceGridItem(
                                    id: 'all-${service.id}',
                                    label: service.catalogLabel(context.l10n),
                                    icon: SvgPicture.asset(
                                      service.catalogAsset,
                                    ),
                                    onTap: () =>
                                        onServiceRequested?.call(service),
                                  ),
                                ),
                            ],
                          );
                        },
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
  );
}

class DashboardCategoryHeading extends StatelessWidget {
  const DashboardCategoryHeading({
    super.key,
    required this.category,
    this.active = false,
    this.collapsed = false,
    this.compact = false,
    this.onTap,
    this.search = false,
  });
  final DashboardCategory category;
  final bool active, search, collapsed, compact;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final color = active
        ? context.colors.primary
        : search
        ? AppDashboardColors.categorySearch
        : AppDashboardColors.categoryMuted;
    final heading = Row(
      children: [
        SvgPicture.asset(
          search
              ? switch (category) {
                  DashboardCategory.cards => AppAssets.dashboardSearchCard,
                  DashboardCategory.wallet => AppAssets.dashboardSearchWallet,
                  DashboardCategory.identity =>
                    AppAssets.dashboardSearchIdentity,
                  _ => category.asset,
                }
              : active
              ? category.activeAsset
              : category.asset,
          width: 20,
          height: 20,
        ),
        const SizedBox(width: 6),
        Text(
          category.label(context.l10n),
          style: AppTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            height: 20 / 14,
            letterSpacing: 0,
          ),
        ),
        if (!search) ...[
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 1,
              child: SvgPicture.asset(switch (category) {
                DashboardCategory.modern =>
                  compact
                      ? AppAssets.dashboardDividerSheetModern
                      : AppAssets.dashboardDividerModern,
                DashboardCategory.cards =>
                  compact
                      ? AppAssets.dashboardDividerSheetCard
                      : AppAssets.dashboardDividerCard,
                DashboardCategory.cheque =>
                  compact
                      ? AppAssets.dashboardDividerSheetCheque
                      : AppAssets.dashboardDividerCheque,
                DashboardCategory.transfers =>
                  AppAssets.dashboardDividerTransfer,
                DashboardCategory.loans => AppAssets.dashboardDividerLoan,
                DashboardCategory.deposits => AppAssets.dashboardDividerDeposit,
                DashboardCategory.wallet => AppAssets.dashboardDividerWallet,
                DashboardCategory.identity =>
                  AppAssets.dashboardDividerIdentity,
                DashboardCategory.requests =>
                  AppAssets.dashboardDividerRequests,
              }, fit: BoxFit.fill),
            ),
          ),
          if (active) ...[
            const SizedBox(width: 20),
            Transform.rotate(
              angle: collapsed ? 3.141592653589793 : 0,
              child: SvgPicture.asset(AppAssets.dashboardCategoryCollapse),
            ),
          ],
        ],
      ],
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: search ? 28 : 20),
        decoration: search
            ? BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: AppDashboardColors.favoritesBorder,
                    width: .5,
                  ),
                ),
              )
            : null,
        padding: search
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : EdgeInsets.zero,
        child: heading,
      ),
    );
  }
}
