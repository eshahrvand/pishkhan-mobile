
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_drawer.dart';

class AppDrawerSubItemRow extends StatelessWidget {
  const AppDrawerSubItemRow({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppDrawerSubItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      key: Key('app_drawer_sub_item_${item.id}'),
      onTap: item.enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 36,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              item.label,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: isSelected ? colors.primary : colors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
