import 'app_drawer_menu_item.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_drawer.dart';

class AppDrawerNavigation extends StatelessWidget {
  const AppDrawerNavigation({
    super.key,
    required this.expandedItemId,
    required this.items,
    required this.onItemSelected,
    required this.onSearchChanged,
    required this.onSubItemSelected,
    required this.searchController,
    required this.searchHint,
    required this.selectedItemId,
    required this.selectedSubItemId,
  });
  final String? expandedItemId;
  final List<AppDrawerItem> items;
  final ValueChanged<AppDrawerItem> onItemSelected;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<AppDrawerSubItem> onSubItemSelected;
  final TextEditingController? searchController;
  final String searchHint;
  final String? selectedItemId;
  final String? selectedSubItemId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppSearchField(
              controller: searchController,
              hintText: searchHint,
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (_, index) => AppDrawerMenuItem(
                  item: items[index],
                  isSelected: items[index].id == selectedItemId,
                  isExpanded: items[index].id == expandedItemId,
                  selectedSubItemId: selectedSubItemId,
                  onTap: () => onItemSelected(items[index]),
                  onSubItemTap: onSubItemSelected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
