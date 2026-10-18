import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/agent_request.dart';
import '../../domain/repositories/agent_repository.dart';

/// In-memory prototype only: grants no authority and makes no bank request.
class MockAgentRepository implements AgentRepository {
  final _requests = <String, AgentRequest>{};
  final _receipts = <String, AgentReceipt>{};

  @override
  Future<Result<AgentReceipt>> submit(AgentRequest request) async {
    final previous = _requests[request.idempotencyKey];
    if (previous != null && previous != request) {
      return const Err(DataFailure('agents.idempotency.conflict'));
    }
    _requests[request.idempotencyKey] = request;
    final receipt = _receipts.putIfAbsent(
      request.idempotencyKey,
      () => AgentReceipt(
        reference: 'DEMO-REP-${_receipts.length + 1}',
        isMock: true,
      ),
    );
    return Success(receipt);
  }
}
