import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/deposit_actions.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_artwork_tile.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

/// Deposit fetching, persistence and service execution are caller-owned.
class DashboardDepositsServiceGroup extends StatelessWidget {
  const DashboardDepositsServiceGroup({
    super.key,
    required this.title,
    required this.actions,
    required this.onActionRequested,
    this.quick = false,
  });
  final String title;
  final List<DepositAction> actions;
  final ValueChanged<DepositAction> onActionRequested;
  final bool quick;
  @override
  Widget build(BuildContext context) {
    return AppServiceGridCard(
      title: title,
      stretchItems: false,
      itemSpacing: 6,
      type: quick
          ? AppServiceGridCardType.quick
          : AppServiceGridCardType.service,
      titleColor: quick
          ? AppDashboardColors.sectionText
          : AppDashboardColors.serviceText,
      headerAction: quick
          ? AvpImage(
              image: '${AppConstants.baseImage}deposits_quick_access.svg',
            )
          : null,
      items: [
        for (final action in actions)
          AppServiceGridItem(
            id: 'deposits-${action.id}',
            label: action.label(),
            onTap: () => onActionRequested(action),
            iconSize: Size.square(quick ? 64 : 32),
            icon: quick
                ? AppServiceArtworkTile(asset: action.asset)
                : AvpImage(image: action.asset),
          ),
      ],
    );
  }
}
