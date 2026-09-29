import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

void main() {
  Widget buildSubject({
    required AppServiceGridCardType type,
    VoidCallback? onTap,
  }) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: 343,
          child: AppServiceGridCard(
            title: type == AppServiceGridCardType.service
                ? 'خدمات'
                : 'دسترسی سریع',
            type: type,
            items: [
              AppServiceGridItem(
                id: 'statement',
                label: 'صورتحساب، معدل موجودی',
                icon: const Icon(Icons.person_outline),
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  testWidgets('reports selected service item', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      buildSubject(
        type: AppServiceGridCardType.service,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.text('صورتحساب، معدل موجودی'));
    expect(tapped, isTrue);
  });

  testWidgets('renders the quick-access variant in RTL', (tester) async {
    await tester.pumpWidget(buildSubject(type: AppServiceGridCardType.quick));

    expect(find.text('دسترسی سریع'), findsOneWidget);
  });

  testWidgets('aligns icon cards independently from label line count', (
    tester,
  ) async {
    const items = [
      AppServiceGridItem(
        id: 'one-line',
        label: 'معرفی وام',
        icon: Icon(Icons.calculate_outlined),
      ),
      AppServiceGridItem(
        id: 'two-lines',
        label: 'تغییر سپرده جهت کسر اقساط',
        icon: Icon(Icons.account_balance_outlined),
      ),
      AppServiceGridItem(
        id: 'short',
        label: 'برآورد وام',
        icon: Icon(Icons.wallet_outlined),
      ),
      AppServiceGridItem(
        id: 'long',
        label: 'تجمیع اعتبار سپرده',
        icon: Icon(Icons.more_horiz),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 328,
              child: AppServiceGridCard(title: 'خدمات وام', items: items),
            ),
          ),
        ),
      ),
    );

    final iconTopPositions = items
        .map(
          (item) => tester
              .getTopLeft(find.byKey(Key('app_service_grid_icon_${item.id}')))
              .dy,
        )
        .toSet();
    expect(iconTopPositions, hasLength(1));
  });
}
