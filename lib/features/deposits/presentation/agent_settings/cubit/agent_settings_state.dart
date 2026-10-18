part of 'agent_settings_cubit.dart';

@Freezed(toStringOverride: false)
abstract class AgentSettingsState with _$AgentSettingsState {
  const factory AgentSettingsState.initial({
    @Default(RequestStatus.initial) RequestStatus agentsStatus,
    Failure? agentsFailure,
    @Default(<DepositAgent>[]) List<DepositAgent> agents,
    @Default(<DepositAgent>[]) List<DepositAgent> visibleAgents,
    @Default(AgentTab.myAgents) AgentTab tab,
    @Default(true) bool canAddAgent,
    @Default(<String>[]) List<String> depositNumbers,
    Set<String>? depositFilter,
    Set<AgentKind>? kindFilter,
    Set<AgentStatus>? statusFilter,
    @Default(<String>{}) Set<String> draftDeposits,
    @Default(<AgentKind>{}) Set<AgentKind> draftKinds,
    @Default(<AgentStatus>{}) Set<AgentStatus> draftStatuses,
    @Default(false) bool isEveryDepositSelected,
    @Default(false) bool isEveryKindSelected,
    @Default(false) bool isEveryStatusSelected,
    DepositAgent? details,
    AgentSettingsEffect? effect,
    @Default(0) int effectId,
  }) = _AgentSettingsState;
}
