import 'package:pishkhan_mobile/core/config/constant.dart';

import 'app_drawer_header.dart';
import 'app_drawer_navigation.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// The Figma-exported icons used by the Pishkhan drawer examples.
///
/// Applications can pass their own icon widgets through [AppDrawerItem]. These
/// helpers provide the canonical local assets for the shared-component gallery
/// and for product areas that use the same navigation vocabulary.
abstract final class AppDrawerIcons {
  static Widget close() =>
      _svg('${AppConstants.baseImage}drawer_close.svg', width: 24, height: 24);
  static Widget resalat() => _svg(
    '${AppConstants.baseImage}drawer_resalat.svg',
    width: 30.108,
    height: 30,
  );
  static Widget chevronDown() =>
      _svg('${AppConstants.baseImage}drawer_chevron_down.svg');
  static Widget chevronUp() =>
      _svg('${AppConstants.baseImage}drawer_chevron_up.svg');
  static Widget home() => _svg('${AppConstants.baseImage}drawer_home.svg');
  static Widget modernBanking() =>
      _svg('${AppConstants.baseImage}drawer_modern_banking.svg');
  static Widget card() => _svg('${AppConstants.baseImage}drawer_card.svg');
  static Widget cheque() => _svg('${AppConstants.baseImage}drawer_cheque.svg');
  static Widget moneyTransfer() =>
      _svg('${AppConstants.baseImage}drawer_money_transfer.svg');
  static Widget loan() => _svg('${AppConstants.baseImage}drawer_loan.svg');
  static Widget deposit() =>
      _svg('${AppConstants.baseImage}drawer_deposit.svg');
  static Widget wallet() =>
      _svg('${AppConstants.baseImage}icon_wallet_20_gray600.svg');
  static Widget personalInformation() =>
      _svg('${AppConstants.baseImage}drawer_personal_information.svg');
  static Widget personalInformationDeselected() => _svg(
    '${AppConstants.baseImage}drawer_personal_information_deselected.svg',
  );
  static Widget myRequests() =>
      _svg('${AppConstants.baseImage}drawer_my_requests.svg');
  static Widget submenuLine({required double height}) => SizedBox(
    width: 2,
    height: height,
    child: AvpImage(
      image: '${AppConstants.baseImage}drawer_submenu_line.svg',
      fit: BoxFit.fill,
    ),
  );

  static Widget _svg(String path, {double width = 20, double height = 20}) {
    return AvpImage(
      image: path,
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
                          AppDrawerHeader(
                            title: title,
                            logo: logo,
                            onClose: () => onOpenChanged(false),
                          ),
                          Expanded(
                            child: AppDrawerNavigation(
                              expandedItemId: expandedItemId,
                              items: items,
                              onItemSelected: onItemSelected,
                              onSearchChanged: onSearchChanged,
                              onSubItemSelected: onSubItemSelected,
                              searchController: searchController,
                              searchHint: searchHint,
                              selectedItemId: selectedItemId,
                              selectedSubItemId: selectedSubItemId,
                            ),
                          ),
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
}
