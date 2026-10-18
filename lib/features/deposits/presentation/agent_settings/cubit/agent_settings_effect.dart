import '../../../domain/entities/deposit_agent.dart';

enum AgentAction { details, cancel }

sealed class AgentSettingsEffect {
  const AgentSettingsEffect();
}

final class AgentDepositFilterRequested extends AgentSettingsEffect {
  const AgentDepositFilterRequested();
}

final class AgentKindFilterRequested extends AgentSettingsEffect {
  const AgentKindFilterRequested();
}

final class AgentStatusFilterRequested extends AgentSettingsEffect {
  const AgentStatusFilterRequested();
}

final class AgentActionsRequested extends AgentSettingsEffect {
  const AgentActionsRequested(this.agent);
  final DepositAgent agent;
}

final class AgentIntroductionRequested extends AgentSettingsEffect {
  const AgentIntroductionRequested(this.depositNumber);
  final String? depositNumber;
}

final class AgentUnavailableRequested extends AgentSettingsEffect {
  const AgentUnavailableRequested();
}

final class AgentBackRequested extends AgentSettingsEffect {
  const AgentBackRequested();
}

final class AgentAssistantRequested extends AgentSettingsEffect {
  const AgentAssistantRequested();
}
