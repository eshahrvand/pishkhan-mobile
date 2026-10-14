import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/deposit_actions.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_artwork_tile.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

/// Deposit fetching, persistence and service execution are caller-owned.
class DashboardDepositsServiceGroup extends StatelessWidget {
  const DashboardDepositsServiceGroup({
    super.key,
    required this.groupId,
    required this.title,
    required this.actions,
    required this.onActionRequested,
    this.quick = false,
  });
  final String groupId;
  final String title;
  final List<DepositAction> actions;
  final ValueChanged<DepositAction> onActionRequested;
  final bool quick;
  @override
  Widget build(BuildContext context) {
    return AppServiceGridCard(
      key: Key(groupId),
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
          ? SvgPicture.asset(AppAssets.depositsQuickAccess)
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
                : SvgPicture.asset(action.asset),
          ),
      ],
    );
  }
}
