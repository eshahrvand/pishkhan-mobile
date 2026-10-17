export 'auth_services_section_title.dart';
export 'auth_service_tile.dart';
import 'auth_service_tile.dart';

import 'package:flutter/material.dart';

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
        if (constraints.maxWidth < count * 72) {
          return Wrap(
            alignment: WrapAlignment.start,
            spacing: 12,
            runSpacing: 12,
            children: [for (final item in items) AuthServiceTile(item: item)],
          );
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 104),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in items) AuthServiceTile(item: item),
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
