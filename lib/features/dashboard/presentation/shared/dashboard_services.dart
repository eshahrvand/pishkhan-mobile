import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

// Localization stays in Presentation; Cubits receive searchable text as data.
Map<DashboardService, String> getDashboardServiceSearchLabels() {
  return {
    for (final service in DashboardService.values)
      service: service.catalogLabel(),
  };
}

enum DashboardService {
  assistant('assistant'),
  statement('deposit-statement'),
  certificate('deposit-certificate'),
  agent('deposit-representative'),
  sms('deposit-sms'),
  issue('card-issue'),
  password('card-password'),
  forgotPassword('card-pin-second-forgot'),
  changePassword('card-pin-second-change'),
  cardDeposit('card-deposit'),
  block('card-block'),
  estimate('loan-estimate'),
  introduce('loan-introduce'),
  consolidation('loan-consolidate'),
  loanDeposit('loan-deposit'),
  phoneBank('modern-phone'),
  mobileBank('modern-mobile'),
  mobileBankPasswordRecovery('modern-mobile-password-recovery'),
  mobileBankPasswordGuide('modern-mobile-password-guide'),
  mobileBankTransferLimits('modern-mobile-transfer-limits'),
  mobileBankDeactivation('modern-mobile-deactivation'),
  internetBank('modern-internet'),
  cardsList('card-list'),
  virtualCard('card-virtual'),
  unblockCard('card-unblock'),
  expiredGift('card-expired-gift'),
  issueCheque('cheque-issue'),
  clearCheque('cheque-clear'),
  cancelCheque('cheque-cancel'),
  localTransfer('transfer-local'),
  myLoans('loan-list'),
  loanReport('loan-report'),
  correctInstallments('loan-correct-installments'),
  deferLoan('loan-defer'),
  depositsList('deposit-list'),
  openCurrent('deposit-open-current'),
  closeExtras('deposit-close-extras'),
  agentSettings('deposit-representation-settings'),
  proxy('deposit-proxy'),
  unblockDeposit('deposit-unblock'),
  blockDeposit('deposit-block'),
  walletInfo('wallet-info'),
  walletCharge('wallet-charge'),
  walletWithdraw('wallet-withdraw'),
  walletTransfer('wallet-transfer'),
  walletHistory('wallet-history'),
  walletDeposit('wallet-deposit'),
  changeIdentity('identity-change'),
  occupation('identity-occupation'),
  addresses('identity-addresses'),
  changePhone('identity-phone'),
  requests('requests-list');

  const DashboardService(this.id);
  final String id;
  static const fixed = [
    assistant,
    password,
    estimate,
    sms,
    block,
    statement,
    certificate,
    agent,
  ];
  static const modern = [mobileBank, internetBank, phoneBank];
  static const cards = [
    cardsList,
    issue,
    password,
    forgotPassword,
    changePassword,
    virtualCard,
    cardDeposit,
    expiredGift,
    block,
    unblockCard,
  ];
  static const cheques = [clearCheque, issueCheque, cancelCheque];
  static const transfers = [localTransfer];
  static const loans = [
    myLoans,
    introduce,
    consolidation,
    loanReport,
    estimate,
    deferLoan,
    correctInstallments,
    loanDeposit,
  ];
  static const deposits = [
    depositsList,
    openCurrent,
    statement,
    certificate,
    agent,
    agentSettings,
    sms,
    closeExtras,
    blockDeposit,
    unblockDeposit,
    proxy,
  ];
  static const wallets = [
    walletInfo,
    walletCharge,
    walletWithdraw,
    walletTransfer,
    walletDeposit,
    walletHistory,
  ];
  static const identities = [
    changePhone,
    addresses,
    occupation,
    changeIdentity,
  ];
  static const requestServices = [requests];

  String label() => switch (this) {
    assistant => S.current.dashboardAssistant,
    statement => S.current.balanceAverageStatement,
    certificate => S.current.financialCertificate,
    agent => S.current.introduceAgent,
    sms => S.current.smsSettings,
    issue => S.current.issueResalatCard,
    password => S.current.cardPasswordIssue,
    forgotPassword => S.current.passwordForgot,
    changePassword => S.current.passwordChange,
    cardDeposit => S.current.changeCardDeposit,
    block => S.current.blockCard,
    estimate => S.current.loanEstimate,
    introduce => S.current.introduceLoan,
    consolidation => S.current.consolidateDepositCredit,
    loanDeposit => S.current.changeInstallmentDeposit,
    phoneBank => S.current.dashboardPhoneBank,
    mobileBank => S.current.mobileBankSettings,
    mobileBankPasswordRecovery => S.current.modernRecoveryTitle,
    mobileBankPasswordGuide => S.current.passwordChange,
    mobileBankTransferLimits => S.current.modernLimitsTitle,
    mobileBankDeactivation => S.current.modernDeactivationTitle,
    internetBank => S.current.internetBankSettings,
    cardsList => S.current.dashboardCardsList,
    virtualCard => S.current.dashboardVirtualCard,
    unblockCard => S.current.dashboardUnblockCard,
    expiredGift => S.current.dashboardExpiredGift,
    issueCheque => S.current.issueChequeBook,
    clearCheque => S.current.dashboardClearCheque,
    cancelCheque => S.current.dashboardCancelCheque,
    localTransfer => S.current.dashboardLocalTransfer,
    myLoans => S.current.dashboardMyLoans,
    loanReport => S.current.dashboardLoanReport,
    correctInstallments => S.current.dashboardCorrectInstallments,
    deferLoan => S.current.dashboardDeferLoan,
    depositsList => S.current.dashboardDepositsList,
    openCurrent => S.current.dashboardOpenCurrent,
    closeExtras => S.current.dashboardCloseExtras,
    agentSettings => S.current.dashboardAgentSettings,
    proxy => S.current.proxyDeposit,
    unblockDeposit => S.current.dashboardUnblockDeposit,
    blockDeposit => S.current.dashboardBlockDeposit,
    walletInfo => S.current.dashboardWalletInfo,
    walletCharge => S.current.dashboardWalletCharge,
    walletWithdraw => S.current.dashboardWalletWithdraw,
    walletTransfer => S.current.dashboardWalletTransfer,
    walletHistory => S.current.dashboardWalletHistory,
    walletDeposit => S.current.dashboardWalletDeposit,
    changeIdentity => S.current.dashboardChangeIdentity,
    occupation => S.current.dashboardOccupation,
    addresses => S.current.dashboardAddresses,
    changePhone => S.current.dashboardChangePhone,
    requests => S.current.dashboardRequests,
  };

  String catalogLabel() => switch (this) {
    password => S.current.cardPasswordIssue.replaceAll(RegExp(r' *\/ *'), '/'),
    mobileBank => S.current.mobileBank,
    internetBank => S.current.internetBank,
    loanDeposit => S.current.dashboardManageInstallments,
    estimate => S.current.dashboardEstimateCredit,
    _ => label(),
  };

  String get catalogAsset => switch (this) {
    statement => AppAssets.dashboardCatalogStatement,
    certificate => AppAssets.dashboardCatalogCertificate,
    agent => AppAssets.dashboardCatalogAgent,
    issue => AppAssets.dashboardCatalogIssue,
    password ||
    forgotPassword ||
    changePassword => AppAssets.dashboardCatalogPassword,
    cardDeposit => AppAssets.dashboardCatalogCardDeposit,
    block => AppAssets.dashboardCatalogBlock,
    estimate => AppAssets.dashboardCatalogEstimate,
    introduce => AppAssets.dashboardCatalogIntroduce,
    consolidation => AppAssets.dashboardCatalogConsolidation,
    loanDeposit => AppAssets.dashboardCatalogLoanDeposit,
    blockDeposit => AppAssets.dashboardCatalogAgent,
    requests => AppAssets.dashboardCatalogRequests,
    assistant => AppAssets.dashboardAssistantStar,
    _ => AppAssets.dashboardCatalogMore,
  };

  String get optionAsset => switch (this) {
    issue => AppAssets.dashboardOptionIssue,
    password ||
    forgotPassword ||
    changePassword => AppAssets.dashboardOptionPassword,
    cardDeposit => AppAssets.dashboardOptionCardDeposit,
    block => AppAssets.dashboardOptionBlock,
    _ => AppAssets.dashboardOptionMore,
  };

  String get fixedAsset => switch (this) {
    sms => AppAssets.dashboardFixedSms,
    estimate => AppAssets.dashboardFixedEstimate,
    password ||
    forgotPassword ||
    changePassword => AppAssets.dashboardFixedPassword,
    agent => AppAssets.dashboardFixedAgent,
    certificate => AppAssets.dashboardFixedCertificate,
    statement => AppAssets.dashboardFixedStatement,
    block => AppAssets.dashboardFixedBlock,
    _ => catalogAsset,
  };

  String? tileAsset({
    bool fixed = false,
    bool editing = false,
    bool full = false,
  }) {
    if (fixed) return null;
    return switch (this) {
      cardDeposit =>
        editing
            ? AppAssets.dashboardFavoriteCardDepositEdit
            : AppAssets.dashboardFavoriteCardDeposit,
      consolidation =>
        editing
            ? AppAssets.dashboardFavoriteConsolidationEdit
            : AppAssets.dashboardFavoriteConsolidation,
      issue =>
        editing
            ? AppAssets.dashboardFavoriteIssueEdit
            : AppAssets.dashboardFavoriteIssue,
      proxy =>
        editing
            ? AppAssets.dashboardFavoriteProxyEdit
            : AppAssets.dashboardFavoriteProxy,
      mobileBank =>
        editing
            ? AppAssets.dashboardFavoriteMobileEdit
            : AppAssets.dashboardFavoriteMobile,
      internetBank => editing ? AppAssets.dashboardFavoriteInternetEdit : null,
      loanDeposit =>
        editing ? AppAssets.dashboardFavoriteLoanDepositEdit : null,
      _ => null,
    };
  }
}

enum DashboardCategory {
  modern,
  cards,
  cheque,
  transfers,
  loans,
  deposits,
  wallet,
  identity,
  requests;

  String label() => switch (this) {
    modern => S.current.dashboardModernBanking,
    cards => S.current.cardServices,
    cheque => S.current.dashboardChequeServices,
    transfers => S.current.dashboardTransferServices,
    loans => S.current.loanServices,
    deposits => S.current.depositServices,
    wallet => S.current.dashboardWalletServices,
    identity => S.current.dashboardIdentityServices,
    requests => S.current.dashboardRequestServices,
  };

  List<DashboardService> get services => switch (this) {
    modern => DashboardService.modern,
    cards => DashboardService.cards,
    cheque => DashboardService.cheques,
    transfers => DashboardService.transfers,
    loans => DashboardService.loans,
    deposits => DashboardService.deposits,
    wallet => DashboardService.wallets,
    identity => DashboardService.identities,
    requests => DashboardService.requestServices,
  };

  String get asset => switch (this) {
    modern => AppAssets.dashboardCatalogCategoryModern,
    cards => AppAssets.dashboardCatalogCategoryCard,
    cheque => AppAssets.dashboardCatalogCategoryCheque,
    transfers => AppAssets.dashboardCatalogCategoryTransfer,
    loans => AppAssets.dashboardCatalogCategoryLoan,
    deposits => AppAssets.dashboardCatalogCategoryDeposit,
    wallet => AppAssets.dashboardCatalogCategoryWallet,
    identity => AppAssets.dashboardCatalogCategoryIdentity,
    requests => AppAssets.dashboardCatalogCategoryRequests,
  };

  String get activeAsset =>
      this == cards ? AppAssets.dashboardCategoryCardActive : asset;
}
