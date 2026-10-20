import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/deposit_agent.dart';
import '../repositories/agent_settings_repository.dart';

class FetchAgents {
  const FetchAgents(this.repository);

  final AgentSettingsRepository repository;

  Future<Result<List<DepositAgent>>> call() async {
    try {
      return switch (await repository.fetchAgents()) {
        Success(:final data) => Success(List.unmodifiable(data)),
        Err(:final failure) => Err(failure),
      };
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
