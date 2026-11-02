import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

/// Supported UI actions. IDs are integration keys, not arbitrary routes.
enum DepositAction {
  list('deposit-list'),
  statement('deposit-statement'),
  certificate('deposit-certificate'),
  sms('deposit-sms'),
  block('deposit-block'),
  agent('deposit-representation-settings'),
  introduceAgent('deposit-representative'),
  unblock('deposit-unblock'),
  closeExtras('deposit-close-extras'),
  virtualCard('card-virtual'),
  linkedCards('deposit-linked-cards'),
  linkedLoans('deposit-linked-loans'),
  issueCheque('cheque-issue'),
  cancelCheque('cheque-cancel'),
  clearCheque('cheque-clear'),
  issueCard('card-issue'),
  localTransfer('transfer-local'),
  estimateLoan('loan-estimate'),
  introduceLoan('loan-introduce'),
  proxy('deposit-proxy'),
  mobileBank('modern-mobile'),
  internetBank('modern-internet'),
  phoneBank('modern-phone');

  const DepositAction(this.id);
  final String id;
  static const operations = [
    list,
    statement,
    certificate,
    introduceAgent,
    agent,
    block,
    unblock,
    closeExtras,
    virtualCard,
    sms,
    linkedCards,
    linkedLoans,
  ];
  static const cheques = [issueCheque, cancelCheque, clearCheque];
  static const quick = [
    issueCard,
    proxy,
    localTransfer,
    estimateLoan,
    introduceLoan,
    mobileBank,
    internetBank,
    phoneBank,
  ];

  String label() => switch (this) {
    list => S.current.dashboardDepositsList,
    statement => S.current.balanceAverageStatement,
    certificate => S.current.financialCertificate,
    sms => S.current.smsSettings,
    block => S.current.dashboardBlockDeposit,
    agent => S.current.depositsAgent,
    introduceAgent => S.current.introduceAgent,
    unblock => S.current.dashboardUnblockDeposit,
    closeExtras => S.current.dashboardCloseExtras,
    virtualCard => S.current.dashboardVirtualCard,
    linkedCards => S.current.depositsLinkedCards,
    linkedLoans => S.current.depositsLinkedLoans,
    issueCheque => S.current.issueChequeBook,
    cancelCheque => S.current.dashboardCancelCheque,
    clearCheque => S.current.dashboardClearCheque,
    issueCard => S.current.issueResalatCard,
    localTransfer => S.current.depositsLocalTransfer,
    estimateLoan => S.current.loanEstimate,
    introduceLoan => S.current.introduceLoan,
    proxy => S.current.proxyDeposit,
    mobileBank => S.current.depositsMobileBank,
    internetBank => S.current.internetBank,
    phoneBank => S.current.dashboardPhoneBank,
  };

  String get asset => switch (this) {
    list => '${AppConstants.baseImage}deposits_cards.svg',
    statement => '${AppConstants.baseImage}deposits_statement.svg',
    certificate => '${AppConstants.baseImage}deposits_certificate.svg',
    sms => '${AppConstants.baseImage}deposits_sms.svg',
    block => '${AppConstants.baseImage}deposits_block.svg',
    agent => '${AppConstants.baseImage}deposits_agent.svg',
    introduceAgent => '${AppConstants.baseImage}deposits_agent.svg',
    unblock => '${AppConstants.baseImage}deposits_block.svg',
    closeExtras => '${AppConstants.baseImage}deposits_block.svg',
    virtualCard => '${AppConstants.baseImage}deposits_virtual.svg',
    linkedCards => '${AppConstants.baseImage}deposits_cards.svg',
    linkedLoans => '${AppConstants.baseImage}deposits_loans.svg',
    issueCheque => '${AppConstants.baseImage}deposits_cheque_issue.svg',
    cancelCheque => '${AppConstants.baseImage}deposits_cheque_cancel.svg',
    clearCheque => '${AppConstants.baseImage}deposits_cheque_clear.svg',
    issueCard => '${AppConstants.baseImage}deposits_quick_issue.svg',
    localTransfer => '${AppConstants.baseImage}deposits_quick_transfer.svg',
    estimateLoan => '${AppConstants.baseImage}deposits_quick_estimate.svg',
    introduceLoan => '${AppConstants.baseImage}deposits_quick_introduce.svg',
    proxy => '${AppConstants.baseImage}deposits_quick_proxy.svg',
    mobileBank => '${AppConstants.baseImage}deposits_quick_mobile.svg',
    internetBank => '${AppConstants.baseImage}deposits_quick_internet.svg',
    phoneBank => '${AppConstants.baseImage}deposits_quick_phone.svg',
  };
}

/// The caller receives the selected deposit, including its original copy values.
class DepositActionRequest {
  const DepositActionRequest({required this.action, required this.deposit});
  final DepositAction action;
  final BankDeposit deposit;
}
