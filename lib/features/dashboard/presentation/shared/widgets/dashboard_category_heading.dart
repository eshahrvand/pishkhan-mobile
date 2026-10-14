import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
          category.label(),
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
