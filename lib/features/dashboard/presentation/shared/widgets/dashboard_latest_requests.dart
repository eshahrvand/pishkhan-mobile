import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_assets.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_request_report_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

class DashboardLatestRequests extends StatelessWidget {
  const DashboardLatestRequests({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 1,
          child: Image.asset(
            DashboardAssets.sectionDivider,
            width: double.infinity,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.latestUpdatedRequests,
                style: AppTypography.titleSmall.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0,
                ),
              ),
            ),
            AppServiceGridIcons.angleLeft(),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              for (var index = 0; index < 3; index++) ...[
                if (index > 0) const SizedBox(width: 12),
                AppRequestReportCard(
                  type: AppRequestReportCardType.dashboard,
                  width: 320,
                  contentPadding: const EdgeInsets.all(16),
                  sectionSpacing: 12,
                  footerSpacing: 10,
                  headerHeight: 24,
                  title: l10n.dashboardRequestTitle,
                  requestNumber: l10n.dashboardRequestNumber,
                  date: l10n.dashboardRequestDate,
                  statusLabel: l10n.automaticCompleted,
                  identifierLabel: l10n.requestIdentifier,
                  showDetails: false,
                  dividerHeight: 1,
                  divider: Image.asset(
                    DashboardAssets.requestDivider,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
