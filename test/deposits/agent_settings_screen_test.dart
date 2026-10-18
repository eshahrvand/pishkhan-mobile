import 'dart:async';
import 'dart:io';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/agent_settings_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/screens/introduce_agent_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/cubit/agent_settings_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/screens/agent_settings_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/widgets/agent_actions_sheet.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/widgets/agent_details.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/widgets/agent_filter_option.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/widgets/agent_filters.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/widgets/agent_settings_content.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_confirmer_details_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_agent_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_agent_cards.dart';

import 'certificate_test_support.dart';

Future<void> captureSettings(WidgetTester tester, String name) async {
  if (Platform.environment['CAPTURE_CERTIFICATE_PREVIEWS'] != '1') return;
  // Wait for the existing AvpImage SVG compilation before visual inspection.
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
  await captureCertificate(tester, 'agent-settings-$name');
}

AgentSettingsCubit screenCubit(WidgetTester tester) => tester
    .element(find.byType(AgentSettingsContent))
    .read<AgentSettingsCubit>();

Finder filterChip(String label) => find.descendant(
  of: find.byType(AgentFilters),
  matching: find.widgetWithText(AppChips, label),
);

Future<void> openFirstActions(WidgetTester tester) async {
  await tester.tap(
    find
        .descendant(
          of: find.byType(AppAgentCard).first,
          matching: find.byType(InkWell),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

class PendingAgentRepository implements AgentSettingsRepository {
  final result = Completer<Result<List<DepositAgent>>>();
  bool isPending = false;
  @override
  Future<Result<List<DepositAgent>>> fetchAgents() => isPending
      ? result.future
      : Future.value(const Err(DataFailure('unavailable')));
}

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(loadCertificateFonts);

  testWidgets(
    'both designed tabs reuse existing cards; Add appears only for my agents',
    (tester) async {
      await mountCertificate(tester, const AgentSettingsScreen());
      expect(tester.getTopLeft(find.byType(AppMyAgentCard).first).dy, 208);
      expect(find.text('الهام غریبی'), findsOneWidget);
      expect(find.text(S.current.agentSettingsAdd), findsOneWidget);
      await captureSettings(tester, 'mine');
      await tester.tap(find.text(S.current.agentSettingsDelegated));
      await tester.pumpAndSettle();
      expect(find.byType(AppMeAsAgentCard), findsNWidgets(2));
      expect(find.text(S.current.agentSettingsAdd), findsNothing);
      await captureSettings(tester, 'delegated');
      await tester.tap(find.text(S.current.agentSettingsMine));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.agentSettingsAdd));
      await tester.pumpAndSettle();
      expect(find.byType(IntroduceAgentScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'multi-select filters Apply, Cancel, outside dismissal and selected chip reset',
    (tester) async {
      await mountCertificate(tester, const AgentSettingsScreen());
      final cubit = screenCubit(tester);
      await tester.tap(filterChip(S.current.agentKind));
      await tester.pumpAndSettle();
      expect(find.byType(AgentFilterOption), findsNWidgets(5));
      await captureSettings(tester, 'kind-filter');
      await tester.tap(find.text(S.current.agentSettingsSelectAll));
      await tester.tap(find.text(S.current.agentSettingsLoanReferral).last);
      await tester.tap(find.text(S.current.dashboardCancel));
      await tester.pumpAndSettle();
      expect(cubit.state.kindFilter, isNull);
      await tester.tap(filterChip(S.current.agentDepositShort));
      await tester.pumpAndSettle();
      await captureSettings(tester, 'deposit-filter');
      await tester.tap(find.text(S.current.agentSettingsSelectAll));
      await tester.tap(
        find.text(CurrencyFormatter.toPersianDigits('10.1234567.1')).last,
      );
      await tester.tap(find.text(S.current.cardFeatureApplyFilter));
      await tester.pumpAndSettle();
      expect(cubit.state.visibleAgents.single.id, 'mine-loan');
      expect(
        tester
            .widget<AppChips>(filterChip(S.current.agentDepositShort))
            .selected,
        isTrue,
      );
      await captureSettings(tester, 'active-filter');
      await tester.tap(filterChip(S.current.agentDepositShort));
      await tester.pumpAndSettle();
      expect(cubit.state.depositFilter, isNull);
      await tester.tap(filterChip(S.current.depositListStatus));
      await tester.pumpAndSettle();
      await captureSettings(tester, 'status-filter');
      await tester.tap(find.text(S.current.agentSettingsSelectAll));
      await tester.tapAt(const Offset(180, 200));
      await tester.pumpAndSettle();
      expect(cubit.state.statusFilter, isNull);
      expect(cubit.state.draftStatuses, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'actions open exact record details; header and system Back retain list filters; cancel only informs',
    (tester) async {
      await mountCertificate(
        tester,
        const AgentSettingsScreen(initialDepositNumber: '10.1234567.1'),
      );
      final cubit = screenCubit(tester);
      await openFirstActions(tester);
      expect(find.byType(AgentActionsSheet), findsOneWidget);
      await captureSettings(tester, 'actions');
      await tester.tap(find.text(S.current.agentSettingsDetails));
      await tester.pumpAndSettle();
      expect(find.byType(AgentDetails), findsOneWidget);
      expect(cubit.state.details!.id, 'mine-loan');
      expect(find.byType(AppConfirmerDetailsCard), findsNWidgets(2));
      await captureSettings(tester, 'details');
      await tester.tap(find.byTooltip(S.current.agentSettingsCancel));
      await tester.pumpAndSettle();
      expect(find.text(S.current.cardFeatureUnavailable), findsOneWidget);
      expect(cubit.state.agents.length, 5);
      await tester.tap(find.byTooltip(S.current.backLabel));
      await tester.pumpAndSettle();
      expect(find.byType(AgentSettingsContent), findsOneWidget);
      expect(cubit.state.depositFilter, {'10.1234567.1'});
      await openFirstActions(tester);
      await tester.tap(find.text(S.current.agentSettingsDetails));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AgentSettingsContent), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'service registry opens settings with deposit context; ordinary rebuild preserves Cubit',
    (tester) async {
      await mountCertificate(
        tester,
        Builder(
          builder: (context) {
            return AppButton(
              label: 'open',
              onPressed: () => ServiceRegistry.openCardService(
                context,
                'deposit-representation-settings',
                initialDepositNumber: '۱۰-۱۲۳۴۵۶۷-۲',
              ),
            );
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(AgentSettingsScreen), findsOneWidget);
      final cubit = screenCubit(tester);
      expect(cubit.state.visibleAgents.single.id, 'mine-waiting');
      tester.element(find.byType(AgentSettingsScreen)).markNeedsBuild();
      await tester.pumpAndSettle();
      expect(identical(screenCubit(tester), cubit), isTrue);
      await tester.tap(find.text(S.current.agentSettingsAdd));
      await tester.pumpAndSettle();
      expect(find.byType(IntroduceAgentScreen), findsOneWidget);
      await tester.tap(find.byTooltip(S.current.backLabel));
      await tester.pumpAndSettle();
      // The existing introduction flow asks for exit confirmation.
      if (find.text(S.current.flowExitTitle).evaluate().isNotEmpty) {
        await tester.tap(find.text(S.current.passwordExit));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'loading disables filters; failure retries and empty selections show a message',
    (tester) async {
      await getIt.unregister<AgentSettingsRepository>();
      final pending = PendingAgentRepository();
      getIt.registerSingleton<AgentSettingsRepository>(pending);
      await mountCertificate(tester, const AgentSettingsScreen());
      expect(
        tester.widget<AppChips>(filterChip(S.current.agentKind)).onPressed,
        isNull,
      );
      expect(find.text(S.current.dashboardRetry), findsOneWidget);
      pending.isPending = true;
      await tester.tap(find.text(S.current.dashboardRetry));
      await tester.pump();
      expect(
        tester.widget<AppChips>(filterChip(S.current.agentKind)).onPressed,
        isNull,
      );
      pending.result.complete(const Success(<DepositAgent>[]));
      await tester.pumpAndSettle();
      expect(find.text(S.current.agentSettingsEmpty), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'narrow layout and large text remain scrollable in all filter sheets',
    (tester) async {
      await mountCertificate(
        tester,
        const AgentSettingsScreen(),
        size: const Size(320, 700),
        scale: 1.3,
      );
      for (final label in [
        S.current.agentDepositShort,
        S.current.agentKind,
        S.current.depositListStatus,
      ]) {
        await tester.ensureVisible(filterChip(label));
        await tester.tap(filterChip(label));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(S.current.dashboardCancel));
        await tester.tap(find.text(S.current.dashboardCancel));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );
}
