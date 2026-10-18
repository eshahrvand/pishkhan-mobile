import 'package:equatable/equatable.dart';

enum DepositKind { savings, current }

enum DepositStatus { open, closed, blocked }

enum DepositOwnerRole { ownerAndSignatory, owner, signatory }

class DepositOwner extends Equatable {
  const DepositOwner({
    required this.name,
    required this.nationalId,
    this.role = DepositOwnerRole.ownerAndSignatory,
    required this.percent,
  });
  final String name, nationalId;
  final DepositOwnerRole role;
  final int percent;
  @override
  List<Object?> get props => [name, nationalId, role, percent];
}

/// Standalone deposit list data, independent of dashboard summaries.
class ListedDeposit extends Equatable {
  ListedDeposit({
    required this.id,
    required this.number,
    this.kind = DepositKind.savings,
    this.status = DepositStatus.open,
    Iterable<DepositOwner> owners = const [],
  }) : owners = List.unmodifiable(owners);
  final String id, number;
  final DepositKind kind;
  final DepositStatus status;
  final List<DepositOwner> owners;
  @override
  List<Object?> get props => [id, number, kind, status, owners];
}
