import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

enum AppPrimaryTab { dashboard, cards, deposits, loans }

/// Shared dashboard/cards navigation with the Figma physical RTL order.
class AppPrimaryNavigation extends StatelessWidget {
  const AppPrimaryNavigation({
    super.key,
    required this.selectedTab,
    required this.onSelected,
  });
  final AppPrimaryTab selectedTab;
  final ValueChanged<AppPrimaryTab> onSelected;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: AppRadius.borderMd,
      boxShadow: AppShadows.sm,
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 24 - 16) / 4;
        return Row(
          textDirection: TextDirection.rtl,
          children: [
            for (final tab in AppPrimaryTab.values) ...[
              if (tab != AppPrimaryTab.dashboard) const SizedBox(width: 8),
              SizedBox(
                width: width + (tab == selectedTab ? 16 : 0),
                child: Semantics(
                  selected: tab == selectedTab,
                  child: Material(
                    color: tab == selectedTab
                        ? AppDashboardColors.navActive
                        : Colors.transparent,
                    borderRadius: AppRadius.borderSm,
                    child: InkWell(
                      key: Key('primary_tab_${tab.name}'),
                      onTap: () => onSelected(tab),
                      borderRadius: AppRadius.borderSm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(switch (tab) {
                              AppPrimaryTab.dashboard =>
                                tab == selectedTab
                                    ? AppAssets.dashboardNavHome
                                    : AppAssets.cardsNavHome,
                              AppPrimaryTab.cards =>
                                tab == selectedTab
                                    ? AppAssets.cardsNavActive
                                    : AppAssets.dashboardNavCard,
                              AppPrimaryTab.deposits =>
                                AppAssets.dashboardNavDeposit,
                              AppPrimaryTab.loans => AppAssets.dashboardNavLoan,
                            }),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                switch (tab) {
                                  AppPrimaryTab.dashboard =>
                                    context.l10n.dashboardTab,
                                  AppPrimaryTab.cards =>
                                    context.l10n.dashboardCardsTab,
                                  AppPrimaryTab.deposits =>
                                    context.l10n.dashboardDepositsTab,
                                  AppPrimaryTab.loans =>
                                    context.l10n.dashboardLoansTab,
                                },
                                maxLines: 1,
                                style: AppTypography.bodySmall.copyWith(
                                  color: tab == selectedTab
                                      ? context.colors.textOnPrimary
                                      : context.colors.textDisabled,
                                  fontWeight: tab == selectedTab
                                      ? FontWeight.w600
                                      : FontWeight.w400,
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
              ),
            ],
          ],
        );
      },
    ),
  );
}
