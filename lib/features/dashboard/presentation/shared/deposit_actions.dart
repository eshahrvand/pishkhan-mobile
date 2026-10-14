import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Supported UI actions. IDs are integration keys, not arbitrary routes.
enum DepositAction {
  statement('deposit-statement'),
  certificate('deposit-certificate'),
  sms('deposit-sms'),
  block('deposit-block'),
  representative('deposit-representation-settings'),
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
    statement,
    certificate,
    sms,
    block,
    representative,
    virtualCard,
    linkedCards,
    linkedLoans,
  ];
  static const cheques = [issueCheque, cancelCheque, clearCheque];
  static const quick = [
    issueCard,
    localTransfer,
    estimateLoan,
    introduceLoan,
    proxy,
    mobileBank,
    internetBank,
    phoneBank,
  ];

  String label() => switch (this) {
    statement => S.current.balanceAverageStatement,
    certificate => S.current.financialCertificate,
    sms => S.current.smsSettings,
    block => S.current.dashboardBlockDeposit,
    representative => S.current.depositsRepresentative,
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
    statement => AppAssets.depositsStatement,
    certificate => AppAssets.depositsCertificate,
    sms => AppAssets.depositsSms,
    block => AppAssets.depositsBlock,
    representative => AppAssets.depositsRepresentative,
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
