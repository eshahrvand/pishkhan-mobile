import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
    list => AppAssets.depositsCards,
    statement => AppAssets.depositsStatement,
    certificate => AppAssets.depositsCertificate,
    sms => AppAssets.depositsSms,
    block => AppAssets.depositsBlock,
    agent => AppAssets.depositsAgent,
    introduceAgent => AppAssets.depositsAgent,
    unblock => AppAssets.depositsBlock,
    closeExtras => AppAssets.depositsBlock,
    virtualCard => AppAssets.depositsVirtual,
    linkedCards => AppAssets.depositsCards,
    linkedLoans => AppAssets.depositsLoans,
    issueCheque => AppAssets.depositsChequeIssue,
    cancelCheque => AppAssets.depositsChequeCancel,
    clearCheque => AppAssets.depositsChequeClear,
    issueCard => AppAssets.depositsQuickIssue,
    localTransfer => AppAssets.depositsQuickTransfer,
    estimateLoan => AppAssets.depositsQuickEstimate,
    introduceLoan => AppAssets.depositsQuickIntroduce,
    proxy => AppAssets.depositsQuickProxy,
    mobileBank => AppAssets.depositsQuickMobile,
    internetBank => AppAssets.depositsQuickInternet,
    phoneBank => AppAssets.depositsQuickPhone,
  };
}

/// The caller receives the selected deposit, including its original copy values.
class DepositActionRequest {
  const DepositActionRequest({required this.action, required this.deposit});
  final DepositAction action;
  final BankDeposit deposit;
}
