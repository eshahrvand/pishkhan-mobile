import 'package:equatable/equatable.dart';

enum AgentTab { myAgents, representingOthers }

enum AgentKind { chequeBook, cancelCheque, loanReferral, clearChequeRecord }

enum AgentStatus { active, waiting, expired }

final class AgentConfirmer extends Equatable {
  const AgentConfirmer({
    required this.name,
    required this.nationalId,
    required this.isApproved,
    required this.sharePercentage,
  });

  final String name;
  final String nationalId;
  final bool isApproved;
  final int sharePercentage;

  @override
  List<Object?> get props => [name, nationalId, isApproved, sharePercentage];
}

final class DepositAgent extends Equatable {
  DepositAgent({
    required this.id,
    required this.tab,
    required this.agentName,
    required this.agentNationalId,
    required this.depositNumber,
    required this.ownerName,
    required this.kind,
    required this.status,
    required this.introducedAt,
    required this.expiresAt,
    required List<AgentConfirmer> confirmers,
  }) : confirmers = List.unmodifiable(confirmers);

  final String id;
  final AgentTab tab;
  final String agentName;
  final String agentNationalId;
  final String depositNumber;
  final String ownerName;
  final AgentKind kind;
  final AgentStatus status;
  final DateTime introducedAt;
  final DateTime expiresAt;
  final List<AgentConfirmer> confirmers;

  @override
  List<Object?> get props => [
    id,
    tab,
    agentName,
    agentNationalId,
    depositNumber,
    ownerName,
    kind,
    status,
    introducedAt,
    expiresAt,
    confirmers,
  ];
}
