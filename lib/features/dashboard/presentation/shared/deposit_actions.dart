import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
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

  String label(AppLocalizations l10n) => switch (this) {
    statement => l10n.balanceAverageStatement,
    certificate => l10n.financialCertificate,
    sms => l10n.smsSettings,
    block => l10n.dashboardBlockDeposit,
    representative => l10n.depositsRepresentative,
    virtualCard => l10n.dashboardVirtualCard,
    linkedCards => l10n.depositsLinkedCards,
    linkedLoans => l10n.depositsLinkedLoans,
    issueCheque => l10n.issueChequeBook,
    cancelCheque => l10n.dashboardCancelCheque,
    clearCheque => l10n.dashboardClearCheque,
    issueCard => l10n.issueResalatCard,
    localTransfer => l10n.depositsLocalTransfer,
    estimateLoan => l10n.loanEstimate,
    introduceLoan => l10n.introduceLoan,
    proxy => l10n.proxyDeposit,
    mobileBank => l10n.depositsMobileBank,
    internetBank => l10n.internetBank,
    phoneBank => l10n.dashboardPhoneBank,
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
