import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/deposit_agent.dart';
import '../../domain/repositories/agent_settings_repository.dart';

/// Preview catalog only; these records do not represent bank authorizations.
class MockAgentSettingsRepository implements AgentSettingsRepository {
  @override
  Future<Result<List<DepositAgent>>> fetchAgents() async {
    return Success(
      List.unmodifiable([
        DepositAgent(
          id: 'mine-loan',
          tab: AgentTab.myAgents,
          agentName: 'الهام غریبی',
          agentNationalId: '0081234567',
          depositNumber: '10.1234567.1',
          ownerName: 'بهار مبارک',
          kind: AgentKind.loanReferral,
          status: AgentStatus.active,
          introducedAt: DateTime.utc(2024, 11, 10),
          expiresAt: DateTime.utc(2026, 9, 21),
          confirmers: _confirmers,
        ),
        DepositAgent(
          id: 'mine-waiting',
          tab: AgentTab.myAgents,
          agentName: 'بهار مبارک',
          agentNationalId: '0081234567',
          depositNumber: '10.1234567.2',
          ownerName: 'بهار مبارک',
          kind: AgentKind.chequeBook,
          status: AgentStatus.waiting,
          introducedAt: DateTime.utc(2024, 11, 10),
          expiresAt: DateTime.utc(2026, 11, 11),
          confirmers: _confirmers,
        ),
        DepositAgent(
          id: 'mine-expired',
          tab: AgentTab.myAgents,
          agentName: 'بهار مبارک',
          agentNationalId: '0081234567',
          depositNumber: '10.1234567.3',
          ownerName: 'بهار مبارک',
          kind: AgentKind.chequeBook,
          status: AgentStatus.expired,
          introducedAt: DateTime.utc(2024, 11, 10),
          expiresAt: DateTime.utc(2026, 9, 21),
          confirmers: _confirmers,
        ),
        for (final status in [AgentStatus.active, AgentStatus.expired])
          DepositAgent(
            id: 'delegated-${status.name}',
            tab: AgentTab.representingOthers,
            agentName: 'کاربر آزمایشی',
            agentNationalId: '1234567891',
            depositNumber: '10.1234567.1',
            ownerName: 'بهار مبارک',
            kind: AgentKind.chequeBook,
            status: status,
            introducedAt: DateTime.utc(2024, 11, 10),
            expiresAt: DateTime.utc(2026, 9, 21),
            confirmers: _confirmers,
          ),
      ]),
    );
  }

  static const _confirmers = [
    AgentConfirmer(
      name: 'بهار مبارک',
      nationalId: '0081234567',
      isApproved: true,
      sharePercentage: 40,
    ),
    AgentConfirmer(
      name: 'بهار مبارک',
      nationalId: '0081234567',
      isApproved: false,
      sharePercentage: 40,
    ),
  ];
}
