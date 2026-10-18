import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

class AuthServicesRow extends StatelessWidget {
  const AuthServicesRow({
    required this.items,
    this.fillEmptySlots = false,
    super.key,
  });

  final List<AuthServiceItemData> items;
  final bool fillEmptySlots;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = fillEmptySlots ? 4 : items.length;
        final tiles = <Widget>[
          for (final item in items)
            AppServiceGridItemView(
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
            ),
        ];
        if (constraints.maxWidth < count * 72) {
          return Wrap(
            alignment: WrapAlignment.start,
            spacing: 12,
            runSpacing: 12,
            children: tiles,
          );
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 104),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...tiles,
              if (fillEmptySlots)
                for (var i = items.length; i < 4; i++)
                  const SizedBox(width: 72),
            ],
          ),
        );
      },
    );
  }
}

class AuthServiceItemData {
  const AuthServiceItemData(
    this.label,
    this.asset, {
    this.onTap,
    this.mutedLabel = false,
  });

  final String label;
  final String asset;
  final VoidCallback? onTap;
  final bool mutedLabel;
}
