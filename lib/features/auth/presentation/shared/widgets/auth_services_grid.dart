import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

class AuthServicesSectionTitle extends StatelessWidget {
  const AuthServicesSectionTitle({
    required this.title,
    required this.dividerAsset,
    super.key,
  });
  final String title;
  final String dividerAsset;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        child: Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: AppLoginColors.sectionLabel,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            letterSpacing: 0,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: SvgPicture.asset(dividerAsset, height: 1, fit: BoxFit.fill),
      ),
    ],
  );
}

class AuthServicesRow extends StatelessWidget {
  const AuthServicesRow({
    required this.items,
    this.fillEmptySlots = false,
    super.key,
  });
  final List<AuthServiceItemData> items;
  final bool fillEmptySlots;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = fillEmptySlots ? 4 : items.length;
      if (constraints.maxWidth < count * 72) {
        return Wrap(
          alignment: WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: [for (final item in items) _tile(context, item)],
        );
      }
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 104),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items) _tile(context, item),
            if (fillEmptySlots)
              for (var i = items.length; i < 4; i++) const SizedBox(width: 72),
          ],
        ),
      );
    },
  );

  Widget _tile(BuildContext context, AuthServiceItemData item) =>
      AppServiceGridItemView(
        item: AppServiceGridItem(
          id: item.asset,
          label: item.label,
          icon: SvgPicture.asset(item.asset, width: 32, height: 32),
          onTap: item.onTap,
        ),
        tileColor: context.colors.surface,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: item.mutedLabel
              ? AppLoginColors.serviceLabelMuted
              : AppLoginColors.serviceLabel,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 16 / 10,
          letterSpacing: 0,
        ),
      );
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
