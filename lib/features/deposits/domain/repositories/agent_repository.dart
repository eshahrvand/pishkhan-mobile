import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/agent_request.dart';

abstract interface class AgentRepository {
  Future<Result<AgentReceipt>> submit(AgentRequest request);
}
