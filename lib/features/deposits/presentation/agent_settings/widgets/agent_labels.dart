import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_agent_cards.dart';

import '../../../domain/entities/deposit_agent.dart';

String agentKindLabel(AgentKind kind) {
  return switch (kind) {
    AgentKind.chequeBook => S.current.agentChequeBook,
    AgentKind.cancelCheque => S.current.dashboardCancelCheque,
    AgentKind.loanReferral => S.current.agentSettingsLoanReferral,
    AgentKind.clearChequeRecord => S.current.agentSettingsClearChequeRecord,
  };
}

String agentStatusLabel(AgentStatus status) {
  return switch (status) {
    AgentStatus.active => S.current.agentSettingsActive,
    AgentStatus.waiting => S.current.agentSettingsWaiting,
    AgentStatus.expired => S.current.agentSettingsExpired,
  };
}

AppAgentStatus agentCardStatus(AgentStatus status) {
  return switch (status) {
    AgentStatus.active => AppAgentStatus.active,
    AgentStatus.waiting => AppAgentStatus.waiting,
    AgentStatus.expired => AppAgentStatus.expired,
  };
}
