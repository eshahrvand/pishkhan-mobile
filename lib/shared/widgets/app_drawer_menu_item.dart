import 'app_drawer_sub_item_row.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_drawer.dart';

class AppDrawerMenuItem extends StatelessWidget {
  const AppDrawerMenuItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.selectedSubItemId,
    required this.onTap,
    required this.onSubItemTap,
  });

  final AppDrawerItem item;
  final bool isSelected;
  final bool isExpanded;
  final String? selectedSubItemId;
  final VoidCallback onTap;
  final ValueChanged<AppDrawerSubItem> onSubItemTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = isSelected || isExpanded;
    final submenuHeight = item.children.isEmpty
        ? 0.0
        : item.children.length * 36.0 + (item.children.length - 1) * 4.0;
    return Column(
      children: [
        Semantics(
          button: true,
          selected: isSelected,
          expanded: item.hasChildren ? isExpanded : null,
          child: InkWell(
            key: Key('app_drawer_item_${item.id}'),
            onTap: item.enabled ? onTap : null,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? colors.surfaceSubtle : colors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                // Keep the chevron on the physical left and pin the content
                // group (label + icon) to the physical right.
                textDirection: TextDirection.ltr,
                children: [
                  if (item.hasChildren)
                    isExpanded
                        ? AppDrawerIcons.chevronUp()
                        : AppDrawerIcons.chevronDown(),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        Flexible(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: isActive
                                  ? colors.primary
                                  : colors.textSecondary,
                              fontSize: 14,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          key: Key('app_drawer_item_icon_${item.id}'),
                          width: 20,
                          height: 20,
                          child: Center(
                            child: isActive
                                ? item.selectedIcon ?? item.icon
                                : item.icon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: isExpanded
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection: TextDirection.ltr,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 186,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (
                                  var index = 0;
                                  index < item.children.length;
                                  index++
                                ) ...[
                                  AppDrawerSubItemRow(
                                    item: item.children[index],
                                    isSelected:
                                        item.children[index].id ==
                                        selectedSubItemId,
                                    onTap: () =>
                                        onSubItemTap(item.children[index]),
                                  ),
                                  if (index < item.children.length - 1)
                                    const SizedBox(height: 4),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          KeyedSubtree(
                            key: Key('app_drawer_submenu_divider_${item.id}'),
                            child: AppDrawerIcons.submenuLine(
                              height: submenuHeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
