import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';

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
        AvpImage(
          image: search
              ? switch (category) {
                  DashboardCategory.cards =>
                    '${AppConstants.baseImage}dashboard_search_card.svg',
                  DashboardCategory.wallet =>
                    '${AppConstants.baseImage}dashboard_search_wallet.svg',
                  DashboardCategory.identity =>
                    '${AppConstants.baseImage}dashboard_search_identity.svg',
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
              child: AvpImage(
                image: switch (category) {
                  DashboardCategory.modern =>
                    compact
                        ? '${AppConstants.baseImage}dashboard_divider_sheet_modern.svg'
                        : '${AppConstants.baseImage}dashboard_divider_modern.svg',
                  DashboardCategory.cards =>
                    compact
                        ? '${AppConstants.baseImage}dashboard_divider_sheet_card.svg'
                        : '${AppConstants.baseImage}dashboard_divider_card.svg',
                  DashboardCategory.cheque =>
                    compact
                        ? '${AppConstants.baseImage}dashboard_divider_sheet_cheque.svg'
                        : '${AppConstants.baseImage}dashboard_divider_cheque.svg',
                  DashboardCategory.transfers =>
                    '${AppConstants.baseImage}dashboard_divider_transfer.svg',
                  DashboardCategory.loans =>
                    '${AppConstants.baseImage}dashboard_divider_loan.svg',
                  DashboardCategory.deposits =>
                    '${AppConstants.baseImage}dashboard_divider_deposit.svg',
                  DashboardCategory.wallet =>
                    '${AppConstants.baseImage}dashboard_divider_wallet.svg',
                  DashboardCategory.identity =>
                    '${AppConstants.baseImage}dashboard_divider_identity.svg',
                  DashboardCategory.requests =>
                    '${AppConstants.baseImage}dashboard_divider_requests.svg',
                },
                fit: BoxFit.fill,
              ),
            ),
          ),
          if (active) ...[
            const SizedBox(width: 20),
            Transform.rotate(
              angle: collapsed ? 3.141592653589793 : 0,
              child: AvpImage(
                image:
                    '${AppConstants.baseImage}dashboard_category_collapse.svg',
              ),
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
