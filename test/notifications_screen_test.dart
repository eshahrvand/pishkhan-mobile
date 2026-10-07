import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/notifications/models/notification_message.dart';
import 'package:pishkhan_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader(AppTypography.defaultFontFamily)
      ..addFont(
        rootBundle.load(
          'packages/avp_ui/assets/fonts/IRANYekanXFaNum-Regular.ttf',
        ),
      );
    await font.load();
  });

  Widget subject({Widget? home, double scale = 1}) => MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('fa'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: home ?? const DashboardScreen(enableAnimations: false),
  );

  Future<void> render(
    WidgetTester tester, {
    Widget? home,
    double scale = 1,
    Size size = const Size(375, 814),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(subject(home: home, scale: scale));
    await tester.pumpAndSettle();
  }

  Future<void> openList(WidgetTester tester) async {
    await tester.tap(find.byTooltip('اعلان‌ها'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'dashboard opens list, detail receives selected content, back retains read status',
    (tester) async {
      await render(tester);
      await openList(tester);
      expect(find.text('پیام‌های جدید'), findsOneWidget);
      expect(find.text('پیام‌های خوانده شده'), findsOneWidget);
      expect(
        find.byKey(const Key('notification_unread_secured-loan')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('notification_secured-loan')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('notification_detail_screen')),
        findsOneWidget,
      );
      expect(find.text('با سرمایه خودت وام بگیر'), findsOneWidget);
      expect(find.text('امروز'), findsOneWidget);
      await tester.tap(find.byKey(const Key('notification_back')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('notification_unread_secured-loan')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('notification_unread_gold-investment')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('notification_back')));
      await tester.pumpAndSettle();
      await openList(tester);
      expect(
        find.byKey(const Key('notification_unread_secured-loan')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('read all moves unread messages and remains read on reopening', (
    tester,
  ) async {
    await render(tester);
    await openList(tester);
    await tester.tap(find.byKey(const Key('notification_read_all')));
    await tester.pumpAndSettle();
    expect(find.text('پیام‌های جدید'), findsNothing);
    expect(
      find.byKey(const Key('notification_unread_gold-investment')),
      findsNothing,
    );
    expect(
      tester
          .widget<AppButton>(find.byKey(const Key('notification_read_all')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('notification_back')));
    await tester.pumpAndSettle();
    await openList(tester);
    expect(find.text('پیام‌های جدید'), findsNothing);
  });

  testWidgets('security detail renders the Figma body and image', (
    tester,
  ) async {
    await render(tester);
    await openList(tester);
    await tester.tap(
      find.byKey(const Key('notification_security-۱۶ شهريور ۱۴۰۵')),
    );
    await tester.pumpAndSettle();
    expect(find.text('۱۶ شهريور ۱۴۰۵'), findsOneWidget);
    expect(find.textContaining('کد ورودت رو به کسی نده'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty list and externally supplied messages are supported', (
    tester,
  ) async {
    await render(tester, home: const NotificationsScreen(messages: []));
    expect(find.text('پیامی ندارید'), findsOneWidget);
    List<NotificationMessage>? changed;
    await tester.pumpWidget(
      subject(
        home: NotificationsScreen(
          messages: const [
            NotificationMessage(
              id: 'custom',
              title: 'عنوان سفارشی',
              subtitle: 'متن سفارشی',
              dateLabel: 'امروز',
            ),
          ],
          onChanged: (messages) => changed = messages,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_custom')));
    await tester.pumpAndSettle();
    expect(changed!.single.isRead, isTrue);
    expect(find.text('متن سفارشی'), findsOneWidget);
  });

  testWidgets(
    'narrow screen and enlarged text can scroll through list and detail',
    (tester) async {
      await render(tester, size: const Size(320, 640), scale: 1.5);
      await openList(tester);
      final card = find.byKey(
        const Key('notification_security-۱۶ شهريور ۱۴۰۵'),
      );
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
