import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Figma-exported icons used by the Pishkhan drawer examples.
///
/// Applications can pass their own icon widgets through [AppDrawerItem]. These
/// helpers provide the canonical local assets for the shared-component gallery
/// and for product areas that use the same navigation vocabulary.
abstract final class AppDrawerIcons {
  static const _assetPath = 'assets/images/drawer';

  static Widget close() => _svg('close.svg', width: 24, height: 24);
  static Widget resalat() => _svg('resalat.svg', width: 30.108, height: 30);
  static Widget chevronDown() => _svg('chevron_down.svg');
  static Widget chevronUp() => _svg('chevron_up.svg');
  static Widget home() => _svg('home.svg');
  static Widget modernBanking() => _svg('modern_banking.svg');
  static Widget card() => _svg('card.svg');
  static Widget cheque() => _svg('cheque.svg');
  static Widget moneyTransfer() => _svg('money_transfer.svg');
  static Widget loan() => _svg('loan.svg');
  static Widget deposit() => _svg('deposit.svg');
  static Widget wallet() => _svg('wallet.svg');
  static Widget personalInformation() => _svg('personal_information.svg');
  static Widget personalInformationDeselected() =>
      _svg('personal_information_deselected.svg');
  static Widget myRequests() => _svg('my_requests.svg');
  static Widget submenuLine({required double height}) => SizedBox(
    width: 2,
    height: height,
    child: SvgPicture.asset('$_assetPath/submenu_line.svg', fit: BoxFit.fill),
  );

  static Widget _svg(
    String assetName, {
    double width = 20,
    double height = 20,
  }) {
    return SvgPicture.asset(
      '$_assetPath/$assetName',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

/// A category displayed in [AppDrawer].
///
/// The caller owns labels, icons, routes, and submenu content. This keeps the
/// drawer reusable across features and makes its visual state independent from
/// the application's navigation implementation.
@immutable
class AppDrawerItem {
  const AppDrawerItem({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.children = const [],
    this.enabled = true,
  });

  /// A stable identifier used for selection and expanded-state tracking.
  final String id;
  final String label;
  final Widget icon;

  /// Optional Figma asset to render when this destination is selected/open.
  final Widget? selectedIcon;
  final List<AppDrawerSubItem> children;
  final bool enabled;

  bool get hasChildren => children.isNotEmpty;
}

/// A child destination beneath an [AppDrawerItem].
@immutable
class AppDrawerSubItem {
  const AppDrawerSubItem({
    required this.id,
    required this.label,
    this.enabled = true,
  });

  final String id;
  final String label;
  final bool enabled;
}

/// A controlled, RTL mobile navigation drawer matching the Pishkhan design.
///
/// [isOpen], [expandedItemId], and [selectedItemId] are controlled by the
/// parent. This makes a drawer's visible state reliable when navigation,
/// deep-links, or the Android back button change the surrounding page.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.isOpen,
    required this.items,
    required this.onOpenChanged,
    required this.onItemSelected,
    required this.onSubItemSelected,
    this.expandedItemId,
    this.selectedItemId,
    this.selectedSubItemId,
    this.title = 'پیشخوان مجازی رسالت',
    this.logo,
    this.searchHint = 'جستجو',
    this.searchController,
    this.onSearchChanged,
    this.scrimColor,
  });

  final bool isOpen;
  final List<AppDrawerItem> items;
  final ValueChanged<bool> onOpenChanged;
  final ValueChanged<AppDrawerItem> onItemSelected;
  final ValueChanged<AppDrawerSubItem> onSubItemSelected;
  final String? expandedItemId;
  final String? selectedItemId;
  final String? selectedSubItemId;
  final String title;
  final Widget? logo;
  final String searchHint;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final Color? scrimColor;

  static const _drawerWidth = 295.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IgnorePointer(
      ignoring: !isOpen,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isOpen ? 1 : 0,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onOpenChanged(false),
                child: ColoredBox(
                  color: scrimColor ?? colors.textPrimary.withValues(alpha: .4),
                ),
              ),
            ),
            Align(
              // The drawer is always physically attached to the right edge.
              // `AlignmentDirectional.end` would resolve to the left in RTL.
              alignment: Alignment.centerRight,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                offset: isOpen ? Offset.zero : const Offset(1, 0),
                child: Material(
                  color: colors.surface,
                  child: SizedBox(
                    key: const Key('app_drawer_panel'),
                    width: _drawerWidth,
                    height: double.infinity,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          _DrawerHeader(
                            title: title,
                            logo: logo,
                            onClose: () => onOpenChanged(false),
                          ),
                          Expanded(child: _buildNavigation(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
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
                itemBuilder: (_, index) => _DrawerMenuItem(
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

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.title,
    required this.logo,
    required this.onClose,
  });

  final String title;
  final Widget? logo;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: colors.surfaceSubtle,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              key: const Key('app_drawer_close'),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 24, height: 24),
              icon: AppDrawerIcons.close(),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 2,
                ),
              ),
            ),
          ),
          if (logo != null) ...[
            const SizedBox(width: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(child: logo),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
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
                                  _DrawerSubItem(
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

class _DrawerSubItem extends StatelessWidget {
  const _DrawerSubItem({
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
