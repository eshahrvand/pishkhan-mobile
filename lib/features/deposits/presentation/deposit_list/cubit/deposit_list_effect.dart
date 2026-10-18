import '../../../domain/entities/listed_deposit.dart';
import '../deposit_list_action.dart';

sealed class DepositListEffect {
  const DepositListEffect();
}

final class DepositActionsRequested extends DepositListEffect {
  const DepositActionsRequested(this.deposit);
  final ListedDeposit deposit;
}

final class DepositDetailsRequested extends DepositListEffect {
  const DepositDetailsRequested(this.deposit);
  final ListedDeposit deposit;
}

final class DepositServiceRequested extends DepositListEffect {
  const DepositServiceRequested(this.request, this.serviceId);
  final DepositListActionRequest request;
  final String? serviceId;
}

final class DepositKindFilterRequested extends DepositListEffect {
  const DepositKindFilterRequested();
}

final class DepositStatusFilterRequested extends DepositListEffect {
  const DepositStatusFilterRequested();
}
