import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_drawer.dart';

void main() {
  final items = [
    const AppDrawerItem(
      id: 'home',
      label: 'داشبورد',
      icon: Icon(Icons.home_outlined),
    ),
    const AppDrawerItem(
      id: 'cards',
      label: 'کارت',
      icon: Icon(Icons.credit_card_outlined),
      children: [
        AppDrawerSubItem(id: 'virtual-card', label: 'کارت مجازی'),
        AppDrawerSubItem(id: 'block-card', label: 'مسدودسازی کارت'),
      ],
    ),
  ];

  Widget buildSubject({
    required bool isOpen,
    String? expandedItemId,
    String? selectedItemId,
    ValueChanged<bool>? onOpenChanged,
    ValueChanged<AppDrawerItem>? onItemSelected,
    ValueChanged<AppDrawerSubItem>? onSubItemSelected,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: AppDrawer(
            isOpen: isOpen,
            items: items,
            expandedItemId: expandedItemId,
            selectedItemId: selectedItemId,
            onOpenChanged: onOpenChanged ?? (_) {},
            onItemSelected: onItemSelected ?? (_) {},
            onSubItemSelected: onSubItemSelected ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('does not receive pointer input while closed', (tester) async {
    var changes = 0;
    await tester.pumpWidget(
      buildSubject(isOpen: false, onOpenChanged: (_) => changes++),
    );
    await tester.pump(const Duration(milliseconds: 220));

    await tester.tapAt(const Offset(10, 10));
    expect(changes, 0);
  });

  testWidgets('attaches its panel to the physical right edge in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(isOpen: true));
    await tester.pump(const Duration(milliseconds: 220));

    final panel = find.byKey(const Key('app_drawer_panel'));
    final scaffold = find.byType(Scaffold);
    expect(tester.getTopRight(panel).dx, tester.getTopRight(scaffold).dx);
  });

  testWidgets('keeps the Figma 40dp item height and 8dp item gap', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(isOpen: true));

    final home = tester.getCenter(
      find.byKey(const Key('app_drawer_item_home')),
    );
    final cards = tester.getCenter(
      find.byKey(const Key('app_drawer_item_cards')),
    );
    expect(cards.dy - home.dy, 48);
  });

  testWidgets('keeps every destination icon aligned to the drawer right edge', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(isOpen: true));

    final panelRight = tester
        .getTopRight(find.byKey(const Key('app_drawer_panel')))
        .dx;
    final homeIconRight = tester
        .getTopRight(find.byKey(const Key('app_drawer_item_icon_home')))
        .dx;
    final cardsIconRight = tester
        .getTopRight(find.byKey(const Key('app_drawer_item_icon_cards')))
        .dx;

    expect(panelRight - homeIconRight, 36);
    expect(cardsIconRight, homeIconRight);
  });

  testWidgets('renders the divider only for the opened submenu', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(isOpen: true));
    expect(
      find.byKey(const Key('app_drawer_submenu_divider_cards')),
      findsNothing,
    );

    await tester.pumpWidget(
      buildSubject(isOpen: true, expandedItemId: 'cards'),
    );
    expect(
      find.byKey(const Key('app_drawer_submenu_divider_cards')),
      findsOneWidget,
    );
  });

  testWidgets(
    'reports category and submenu selections supplied by the parent',
    (tester) async {
      String? selectedCategory;
      String? selectedSubItem;
      await tester.pumpWidget(
        buildSubject(
          isOpen: true,
          expandedItemId: 'cards',
          onItemSelected: (item) => selectedCategory = item.id,
          onSubItemSelected: (item) => selectedSubItem = item.id,
        ),
      );

      await tester.tap(find.byKey(const Key('app_drawer_item_cards')));
      expect(selectedCategory, 'cards');

      await tester.tap(find.byKey(const Key('app_drawer_sub_item_block-card')));
      expect(selectedSubItem, 'block-card');
    },
  );

  testWidgets('renders a selected state and the expanded supplied submenu', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        isOpen: true,
        expandedItemId: 'cards',
        selectedItemId: 'home',
      ),
    );

    expect(find.text('کارت مجازی'), findsOneWidget);
    expect(find.text('مسدودسازی کارت'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('داشبورد')).style?.color,
      AppColors.light.primary,
    );
  });
}
