import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_agent_settings_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/agent_settings_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/usecases/agent_settings.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/cubit/agent_settings_cubit.dart';

class ControlledAgentRepository implements AgentSettingsRepository {
  bool fails = true;
  bool throwsException = false;

  @override
  Future<Result<List<DepositAgent>>> fetchAgents() async {
    if (throwsException) throw StateError('invalid response');
    return fails
        ? const Err(DataFailure('unavailable'))
        : MockAgentSettingsRepository().fetchAgents();
  }
}

void main() {
  setUp(() {
    getIt.registerSingleton<AgentSettingsRepository>(
      MockAgentSettingsRepository(),
    );
  });
  tearDown(() => getIt.reset());

  AgentSettingsCubit createCubit({
    String? number,
    AgentSettingsState? initialState,
  }) {
    final cubit = AgentSettingsCubit(
      initialDepositNumber: number,
      initialState: initialState ?? const AgentSettingsState.initial(),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  test('constructor preserves seed; real fetch loads both tabs and independent records', () async {
    const seed = AgentSettingsState.initial(
      tab: AgentTab.representingOthers,
      canAddAgent: false,
    );
    final cubit = createCubit(initialState: seed);
    expect(cubit.state, seed);
    await cubit.fetchAgents();
    expect(cubit.state.agentsStatus, RequestStatus.success);
    expect(cubit.state.visibleAgents.length, 2);
    cubit.selectTab(AgentTab.myAgents);
    expect(cubit.state.visibleAgents.length, 3);
    expect(cubit.state.canAddAgent, isTrue);
    cubit.selectTab(AgentTab.representingOthers);
    expect(cubit.state.canAddAgent, isFalse);
  });

  test('optional deposit entry normalizes digits and separators; invalid entry leaves catalog unfiltered', () async {
    final cubit = createCubit(number: '۱۰-۱۲۳۴۵۶۷-۲');
    await cubit.fetchAgents();
    expect(cubit.state.depositFilter, {'10.1234567.2'});
    expect(cubit.state.visibleAgents.single.id, 'mine-waiting');
    final unknown = createCubit(number: 'not-a-deposit');
    await unknown.fetchAgents();
    expect(unknown.state.depositFilter, isNull);
    expect(unknown.state.visibleAgents.length, 3);
  });

  test('draft edits never filter before Apply; cancel and dismissal discard every draft', () async {
    final cubit = createCubit();
    await cubit.fetchAgents();
    final original = cubit.state.visibleAgents;
    cubit.requestDepositFilter();
    cubit.toggleAllDraftDeposits();
    cubit.toggleDraftDeposit('10.1234567.2');
    expect(cubit.state.visibleAgents, original);
    cubit.applyDepositFilterResult(null);
    expect(cubit.state.depositFilter, isNull);
    expect(cubit.state.draftDeposits, isEmpty);
    cubit.requestKindFilter();
    cubit.toggleAllDraftKinds();
    cubit.toggleDraftKind(AgentKind.loanReferral);
    cubit.applyKindFilterResult(false);
    expect(cubit.state.kindFilter, isNull);
    expect(cubit.state.draftKinds, isEmpty);
    cubit.requestStatusFilter();
    cubit.toggleAllDraftStatuses();
    cubit.toggleDraftStatus(AgentStatus.expired);
    cubit.applyStatusFilterResult(null);
    expect(cubit.state.statusFilter, isNull);
    expect(cubit.state.draftStatuses, isEmpty);
    expect(cubit.state.visibleAgents, original);
  });

  test(
    'all three filter groups intersect; chip clears only its own group',
    () async {
      final cubit = createCubit();
      await cubit.fetchAgents();
      cubit.requestDepositFilter();
      cubit.toggleDraftDeposit('10.1234567.1');
      cubit.applyDepositFilterResult(true);
      expect(cubit.state.visibleAgents.length, 2);
      cubit.requestKindFilter();
      cubit.toggleAllDraftKinds();
      cubit.toggleDraftKind(AgentKind.chequeBook);
      cubit.applyKindFilterResult(true);
      cubit.requestStatusFilter();
      cubit.toggleAllDraftStatuses();
      cubit.toggleDraftStatus(AgentStatus.waiting);
      cubit.applyStatusFilterResult(true);
      expect(cubit.state.visibleAgents.single.id, 'mine-waiting');
      cubit.requestDepositFilter();
      expect(cubit.state.depositFilter, isNull);
      expect(cubit.state.kindFilter, {AgentKind.chequeBook});
      expect(cubit.state.statusFilter, {AgentStatus.waiting});
      expect(cubit.state.visibleAgents.single.id, 'mine-waiting');
      cubit.requestStatusFilter();
      expect(cubit.state.visibleAgents.length, 2);
      cubit.requestKindFilter();
      expect(cubit.state.visibleAgents.length, 3);
    },
  );

  test('empty selection matches nothing; select all restores unrestricted filtering', () async {
    final cubit = createCubit();
    await cubit.fetchAgents();
    cubit.requestStatusFilter();
    cubit.toggleAllDraftStatuses();
    cubit.applyStatusFilterResult(true);
    expect(cubit.state.statusFilter, isEmpty);
    expect(cubit.state.visibleAgents, isEmpty);
    cubit.requestStatusFilter();
    cubit.requestStatusFilter();
    expect(cubit.state.isEveryStatusSelected, isTrue);
    cubit.applyStatusFilterResult(true);
    expect(cubit.state.statusFilter, isNull);
    expect(cubit.state.visibleAgents.length, 3);
  });

  test('tab changes and reload preserve active filters', () async {
    final cubit = createCubit();
    await cubit.fetchAgents();
    cubit.requestStatusFilter();
    cubit.toggleDraftStatus(AgentStatus.waiting);
    cubit.applyStatusFilterResult(true);
    cubit.selectTab(AgentTab.representingOthers);
    expect(cubit.state.visibleAgents.length, 2);
    await cubit.fetchAgents();
    expect(cubit.state.statusFilter, {AgentStatus.active, AgentStatus.expired});
    cubit.selectTab(AgentTab.myAgents);
    expect(cubit.state.visibleAgents.length, 2);
  });

  test('details retain exact record; Back retains filters; repeated cancellation has a fresh effect', () async {
    final cubit = createCubit();
    await cubit.fetchAgents();
    final agent = cubit.state.visibleAgents[1];
    cubit.requestAgentActions(agent);
    expect((cubit.state.effect as AgentActionsRequested).agent, agent);
    cubit.selectAgentAction(agent, AgentAction.details);
    expect(cubit.state.details, agent);
    expect(cubit.state.details!.confirmers.length, 2);
    cubit.requestCancellation();
    final effectId = cubit.state.effectId;
    cubit.requestCancellation();
    expect(cubit.state.effectId, effectId + 1);
    expect(cubit.state.effect, isA<AgentUnavailableRequested>());
    expect(cubit.state.agents.length, 5);
    cubit.requestBack();
    expect(cubit.state.details, isNull);
    expect(cubit.state.visibleAgents.length, 3);
    cubit.requestBack();
    expect(cubit.state.effect, isA<AgentBackRequested>());
  });

  test(
    'request failure retries; thrown boundary exceptions become Err',
    () async {
      final repository = ControlledAgentRepository();
      await getIt.unregister<AgentSettingsRepository>();
      getIt.registerSingleton<AgentSettingsRepository>(repository);
      final cubit = createCubit(number: '10-1234567-2');
      await cubit.fetchAgents();
      expect(cubit.state.agentsStatus, RequestStatus.failure);
      expect(cubit.state.agentsFailure, const DataFailure('unavailable'));
      repository.fails = false;
      await cubit.fetchAgents();
      expect(cubit.state.visibleAgents.single.id, 'mine-waiting');
      expect(cubit.state.agentsFailure, isNull);
      repository.throwsException = true;
      final result = await FetchAgents(repository)();
      expect(result, isA<Err<List<DepositAgent>>>());
      expect((result as Err).failure, isA<UnexpectedFailure>());
    },
  );
}
