import '../../domain/entities/listed_deposit.dart';

enum DepositListAction {
  accountDetails,
  linkedCards,
  statement,
  certificate,
  sms,
  agent,
  block,
  linkedLoans,
}

class DepositListActionRequest {
  const DepositListActionRequest({required this.action, required this.deposit});
  final DepositListAction action;
  final ListedDeposit deposit;
}
