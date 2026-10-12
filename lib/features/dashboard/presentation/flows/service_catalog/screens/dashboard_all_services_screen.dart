import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_category_heading.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
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
                    onPressed: () => NavigationActions.back(context),
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
