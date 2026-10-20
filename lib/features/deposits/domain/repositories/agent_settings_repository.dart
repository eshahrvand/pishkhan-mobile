import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/deposit_agent.dart';

abstract interface class AgentSettingsRepository {
  Future<Result<List<DepositAgent>>> fetchAgents();
}
