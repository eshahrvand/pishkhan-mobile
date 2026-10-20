import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/agent_request.dart';
import '../repositories/agent_repository.dart';

class SubmitAgents {
  const SubmitAgents(this.repository);
  final AgentRepository repository;

  Future<Result<AgentReceipt>> call(AgentRequest request) async {
    try {
      return await repository.submit(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
