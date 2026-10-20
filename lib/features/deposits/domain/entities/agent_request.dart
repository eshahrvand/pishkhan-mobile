import 'package:equatable/equatable.dart';

import 'listed_deposit.dart';

enum AgentOperation { chequeBook }

/// A local draft; national-code validation does not verify a person's identity.
class PendingAgent extends Equatable {
  const PendingAgent({
    required this.deposit,
    required this.operation,
    required this.nationalId,
    required this.validUntil,
  });

  final ListedDeposit deposit;
  final AgentOperation operation;
  final String nationalId;
  final DateTime validUntil;

  @override
  List<Object?> get props => [deposit.id, operation, nationalId, validUntil];
}

class AgentRequest extends Equatable {
  AgentRequest({
    required Iterable<PendingAgent> agents,
    required this.idempotencyKey,
  }) : agents = List.unmodifiable(agents);

  final List<PendingAgent> agents;
  final String idempotencyKey;

  @override
  List<Object?> get props => [agents, idempotencyKey];
}

class AgentReceipt extends Equatable {
  const AgentReceipt({required this.reference, required this.isMock});
  final String reference;
  final bool isMock;

  @override
  List<Object?> get props => [reference, isMock];
}
