import 'auth_services_grid.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

class AuthServiceTile extends StatelessWidget {
  const AuthServiceTile({super.key, required this.item});

  final AuthServiceItemData item;

  @override
  Widget build(BuildContext context) {
    return AppServiceGridItemView(
      item: AppServiceGridItem(
        id: item.asset,
        label: item.label,
        icon: AvpImage(image: item.asset, width: 32, height: 32),
        onTap: item.onTap,
      ),
      tileColor: context.colors.surface,
      labelStyle: AppTypography.caption.copyWith(
        color: item.mutedLabel
            ? AppLoginColors.serviceLabelMuted
            : AppLoginColors.serviceLabel,
        fontWeight: FontWeight.w600,
        height: 16 / 10,
        letterSpacing: 0,
      ),
    );
  }
}
