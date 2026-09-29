import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthServicesSectionTitle extends StatelessWidget {
  const AuthServicesSectionTitle({
    required this.title,
    required this.dividerAsset,
    super.key,
  });

  final String title;
  final String dividerAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: context.colors.textPrimary,
            fontSize: 14,
            height: 20 / 14,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SvgPicture.asset(dividerAsset, height: 1, fit: BoxFit.fill),
        ),
      ],
    );
  }
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
  Widget build(BuildContext context) {
    final children = items
        .map<Widget>((item) => SizedBox(width: 72, child: _ServiceItem(item)))
        .toList();
    if (fillEmptySlots) {
      while (children.length < 4) {
        children.add(const SizedBox(width: 72));
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class AuthServiceItemData {
  const AuthServiceItemData(this.label, this.asset, {this.onTap});

  final String label;
  final String asset;
  final VoidCallback? onTap;
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem(this.item);

  final AuthServiceItemData item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: item.onTap != null,
      label: item.label,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: AppRadius.borderMd,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: AppRadius.borderMd,
                boxShadow: AppShadows.sm,
              ),
              child: SvgPicture.asset(item.asset, width: 32, height: 32),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: context.colors.textSecondary,
                fontSize: 10,
                height: 16 / 10,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
