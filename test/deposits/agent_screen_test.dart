import 'dart:io';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/validated_return_location.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/listed_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/cubit/agent_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/screens/introduce_agent_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/widgets/agent_initial_form.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/widgets/agent_list.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/widgets/agent_sheet.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_agent_card.dart';

import 'certificate_test_support.dart';
import 'agent_cubit_test.dart' show fillAgent;

AppButton button(WidgetTester tester, String label) => tester.widget<AppButton>(
  find
      .byWidgetPredicate(
        (widget) => widget is AppButton && widget.label == label,
      )
      .last,
);

Future<void> captureAgent(WidgetTester tester, String name) async {
  if (Platform.environment['CAPTURE_CERTIFICATE_PREVIEWS'] != '1') return;
  // AvpImage compiles SVGs on a real isolate. Pump between I/O turns rather
  // than waiting on a Future started in the test's fake async zone.
  for (var attempt = 0; attempt < 30; attempt++) {
    if (find.byType(SvgPicture).evaluate().length ==
        find.byType(AvpImage).evaluate().length) {
      break;
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }
  expect(
    find.byType(SvgPicture).evaluate().length,
    find.byType(AvpImage).evaluate().length,
  );
  await captureCertificate(tester, name);
}

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(loadCertificateFonts);

  testWidgets(
    'initial form geometry, validation and two pending cards match the designed flow',
    (tester) async {
      await mountCertificate(tester, const IntroduceAgentScreen());
      expect(tester.getTopLeft(find.byType(AppSelect<ListedDeposit>)).dy, 104);
      expect(button(tester, S.current.agentPreliminarySave).onPressed, isNull);
      expect(button(tester, S.current.issuanceSubmit).onPressed, isNull);
      await captureAgent(tester, 'agent-initial');
      final cubit = tester
          .element(find.byType(AgentInitialForm))
          .read<AgentCubit>();
      fillAgent(cubit);
      await tester.pumpAndSettle();
      expect(
        button(tester, S.current.agentPreliminarySave).onPressed,
        isNotNull,
      );
      await tester.tap(find.text(S.current.agentPreliminarySave));
      await tester.pumpAndSettle();
      expect(find.byType(AgentList), findsOneWidget);
      expect(find.byType(AppAgentCard), findsOneWidget);
      expect(tester.getTopLeft(find.byType(AppAgentCard)).dy, 104);
      expect(find.text('فعال'), findsNothing);
      expect(find.text('۱۲۳۴۵۶۷۸۹۱'), findsOneWidget);
      await captureAgent(tester, 'agent-one-pending');

      await tester.tap(find.text(S.current.agentAddNext));
      await tester.pumpAndSettle();
      expect(find.byType(AgentSheet), findsOneWidget);
      expect(button(tester, S.current.agentSave).onPressed, isNull);
      await captureAgent(tester, 'agent-sheet-empty');
      fillAgent(cubit, date: '۱۴۱۱/۰۱/۰۱');
      await tester.pumpAndSettle();
      await captureAgent(tester, 'agent-sheet-filled');
      await tester.tap(find.text(S.current.agentSave));
      await tester.pumpAndSettle();
      expect(find.byType(AgentSheet), findsNothing);
      expect(find.byType(AppAgentCard), findsNWidgets(2));
      await captureAgent(tester, 'agent-two-pending');
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      expect(button(tester, S.current.issuanceSubmit).onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cancel and system dismissal of the next form preserve the list; delete last restores form',
    (tester) async {
      await mountCertificate(tester, const IntroduceAgentScreen());
      final cubit = tester
          .element(find.byType(AgentInitialForm))
          .read<AgentCubit>();
      fillAgent(cubit);
      cubit.saveDraft();
      await tester.pumpAndSettle();
      for (final cancel in [true, false]) {
        await tester.tap(find.text(S.current.agentAddNext));
        await tester.pumpAndSettle();
        fillAgent(cubit, date: '۱۴۱۱/۰۱/۰۱');
        await tester.pumpAndSettle();
        if (cancel) {
          await tester.tap(find.text(S.current.agentCancel));
        } else {
          await tester.binding.handlePopRoute();
        }
        await tester.pumpAndSettle();
        expect(cubit.state.agents.length, 1);
        expect(find.byType(AgentSheet), findsNothing);
      }
      await tester.tap(find.bySemanticsLabel(S.current.agentRemove));
      await tester.pumpAndSettle();
      expect(find.byType(AgentInitialForm), findsOneWidget);
      expect(button(tester, S.current.agentPreliminarySave).onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('manual entry works through the existing selects and inputs', (
    tester,
  ) async {
    await mountCertificate(tester, const IntroduceAgentScreen());
    await tester.tap(find.text(S.current.agentDepositHint));
    await tester.pumpAndSettle();
    await tester.tap(find.text('۱۰-۱۲۲-۱۲۳۴۵۶۷-۱').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.agentOperationHint));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.agentChequeBook));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '۱۲۳۴۵۶۷۸۹۱');
    await tester.enterText(find.byType(TextField).last, '۱۴۱۰/۰۶/۳۰');
    await tester.pumpAndSettle();
    expect(button(tester, S.current.agentPreliminarySave).onPressed, isNotNull);
    await tester.tap(find.text(S.current.agentPreliminarySave));
    await tester.pumpAndSettle();
    expect(find.byType(AppAgentCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small viewport and keyboard keep the sheet actions reachable', (
    tester,
  ) async {
    await mountCertificate(
      tester,
      const IntroduceAgentScreen(),
      size: const Size(320, 640),
    );
    final cubit = tester
        .element(find.byType(AgentInitialForm))
        .read<AgentCubit>();
    fillAgent(cubit);
    cubit.saveDraft();
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.agentAddNext));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    await tester.pumpAndSettle();
    fillAgent(cubit);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(S.current.agentSave));
    await tester.tap(find.text(S.current.agentSave));
    await tester.pumpAndSettle();
    expect(cubit.state.agents.length, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'deposit service opens the feature and preselects the supplied deposit',
    (tester) async {
      await mountCertificate(
        tester,
        Builder(
          builder: (context) {
            return AppButton(
              label: 'open',
              onPressed: () => ServiceRegistry.openCardService(
                context,
                'deposit-representative',
                initialDepositNumber: '10-122-1234567-2',
              ),
            );
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(IntroduceAgentScreen), findsOneWidget);
      final cubit = tester
          .element(find.byType(AgentInitialForm))
          .read<AgentCubit>();
      expect(cubit.state.deposit!.id, 'current-1');
      expect(
        validatedReturnLocation(AppRoutes.introduceAgent),
        AppRoutes.introduceAgent,
      );
      fillAgent(cubit);
      cubit.saveDraft();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.issuanceSubmit));
      await tester.pumpAndSettle();
      expect(find.textContaining(S.current.agentMockComplete), findsOneWidget);
      expect(button(tester, S.current.issuanceSubmit).onPressed, isNull);
      await tester.tap(find.text(S.current.backLabel));
      await tester.pumpAndSettle();
      expect(find.byType(IntroduceAgentScreen), findsNothing);
      expect(find.text('open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final systemBack in [true, false]) {
    testWidgets(
      '${systemBack ? "system" : "header"} Back confirms pending changes and preserves them on Cancel',
      (tester) async {
        await mountCertificate(
          tester,
          Builder(
            builder: (context) {
              return AppButton(
                label: 'open',
                onPressed: () => ServiceRegistry.openCardService(
                  context,
                  'deposit-representative',
                ),
              );
            },
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        final cubit = tester
            .element(find.byType(AgentInitialForm))
            .read<AgentCubit>();
        cubit.updateNationalId('123');
        Future<void> back() async {
          if (systemBack) {
            await tester.binding.handlePopRoute();
          } else {
            await tester.tap(find.byTooltip(S.current.backLabel));
          }
          await tester.pumpAndSettle();
        }

        await back();
        expect(find.text(S.current.flowExitTitle), findsOneWidget);
        await tester.tap(find.text(S.current.passwordStay));
        await tester.pumpAndSettle();
        expect(cubit.state.nationalId, '123');
        await back();
        await tester.tap(find.text(S.current.passwordExit));
        await tester.pumpAndSettle();
        expect(find.byType(IntroduceAgentScreen), findsNothing);
        expect(find.text('open'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
