import 'dart:io';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/listed_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/cubit/close_surplus_deposits_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/screens/close_surplus_deposits_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/widgets/close_surplus_deposits_form.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/widgets/surplus_deposit_receipt_dialog.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_list.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import 'certificate_test_support.dart';

Future<void> captureSurplus(WidgetTester tester, String name) async {
  if (Platform.environment['CAPTURE_CERTIFICATE_PREVIEWS'] != '1') return;
  for (var attempt = 0; attempt < 40; attempt++) {
    if (find
            .descendant(
              of: find.byType(AvpImage),
              matching: find.byType(SvgPicture),
            )
            .evaluate()
            .length ==
        find.byType(AvpImage).evaluate().length) {
      break;
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }
  await captureCertificate(tester, 'surplus-deposits-$name');
}

Finder submitButton() =>
    find.widgetWithText(AppButton, S.current.surplusDepositsSubmit);

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(loadCertificateFonts);

  testWidgets(
    'designed initial, selected and empty states disable empty submission',
    (tester) async {
      await mountCertificate(tester, const CloseSurplusDepositsScreen());
      expect(tester.widget<AppButton>(submitButton()).onPressed, isNull);
      expect(tester.getTopLeft(find.byType(AppSelect<ListedDeposit>)).dy, 184);
      await captureSurplus(tester, 'initial');
      await tester.tap(find.byType(AppSelect<ListedDeposit>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10.1234567.2').last);
      await tester.pumpAndSettle();
      expect(tester.widget<AppButton>(submitButton()).onPressed, isNull);
      await captureSurplus(tester, 'selected');
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      expect(tester.widget<AppButton>(submitButton()).onPressed, isNotNull);
      await tester.tap(submitButton());
      await tester.pumpAndSettle();
      expect(find.text(S.current.surplusDepositsEmptyTitle), findsOneWidget);
      expect(find.byType(AppCheckbox), findsNothing);
      expect(tester.widget<AppButton>(submitButton()).onPressed, isNull);
      await captureSurplus(tester, 'empty');
      await tester.tap(find.byTooltip(S.current.backLabel));
      await tester.pumpAndSettle();
      expect(find.byType(AppSelect<ListedDeposit>), findsOneWidget);
      expect(
        tester.widget<AppCheckbox>(find.byType(AppCheckbox)).value,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'mock surplus list reuses deposit cards and reports simulated closure',
    (tester) async {
      await mountCertificate(
        tester,
        const CloseSurplusDepositsScreen(initialDepositNumber: '10.1234567.1'),
      );
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(submitButton());
      await tester.pumpAndSettle();
      expect(find.byType(AppDepositList), findsNWidgets(2));
      expect(find.text('10.1234567.4'), findsOneWidget);
      await captureSurplus(tester, 'list');
      await tester.tap(submitButton());
      await tester.pumpAndSettle();
      expect(find.byType(SurplusDepositReceiptDialog), findsOneWidget);
      expect(
        find.textContaining(S.current.surplusDepositsMockComplete),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('service entry uses central route and preserves primary number', (
    tester,
  ) async {
    await mountCertificate(
      tester,
      Builder(
        builder: (context) => AppButton(
          label: 'open',
          onPressed: () => ServiceRegistry.openCardService(
            context,
            'deposit-close-extras',
            initialDepositNumber: '10.1234567.2',
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(CloseSurplusDepositsScreen), findsOneWidget);
    final cubit = tester
        .element(find.byType(CloseSurplusDepositsForm))
        .read<CloseSurplusDepositsCubit>();
    expect(cubit.state.deposit?.number, '10.1234567.2');
    expect(find.byType(AppTopBar), findsOneWidget);
  });

  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets('small viewport and larger text remain usable in $locale', (
      tester,
    ) async {
      await mountCertificate(
        tester,
        const CloseSurplusDepositsScreen(),
        size: const Size(320, 640),
        scale: 1.5,
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getBottomRight(submitButton()).dy, lessThanOrEqualTo(600));
    });
  }
}
