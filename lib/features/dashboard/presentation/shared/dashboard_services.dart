import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

enum DashboardService {
  assistant('assistant'),
  statement('deposit-statement'),
  certificate('deposit-certificate'),
  representative('deposit-representative'),
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
  representationSettings('deposit-representation-settings'),
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
  static const recommended = [issue, consolidation, cardDeposit];
  static const fixed = [
    assistant,
    password,
    estimate,
    sms,
    block,
    statement,
    certificate,
    representative,
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
    representative,
    representationSettings,
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

  String label(AppLocalizations l10n) => switch (this) {
    assistant => l10n.dashboardAssistant,
    statement => l10n.balanceAverageStatement,
    certificate => l10n.financialCertificate,
    representative => l10n.introduceRepresentative,
    sms => l10n.smsSettings,
    issue => l10n.issueResalatCard,
    password => l10n.cardPasswordIssue,
    forgotPassword => l10n.passwordForgot,
    changePassword => l10n.passwordChange,
    cardDeposit => l10n.changeCardDeposit,
    block => l10n.blockCard,
    estimate => l10n.loanEstimate,
    introduce => l10n.introduceLoan,
    consolidation => l10n.consolidateDepositCredit,
    loanDeposit => l10n.changeInstallmentDeposit,
    phoneBank => l10n.dashboardPhoneBank,
    mobileBank => l10n.mobileBankSettings,
    internetBank => l10n.internetBankSettings,
    cardsList => l10n.dashboardCardsList,
    virtualCard => l10n.dashboardVirtualCard,
    unblockCard => l10n.dashboardUnblockCard,
    expiredGift => l10n.dashboardExpiredGift,
    issueCheque => l10n.issueChequeBook,
    clearCheque => l10n.dashboardClearCheque,
    cancelCheque => l10n.dashboardCancelCheque,
    localTransfer => l10n.dashboardLocalTransfer,
    myLoans => l10n.dashboardMyLoans,
    loanReport => l10n.dashboardLoanReport,
    correctInstallments => l10n.dashboardCorrectInstallments,
    deferLoan => l10n.dashboardDeferLoan,
    depositsList => l10n.dashboardDepositsList,
    openCurrent => l10n.dashboardOpenCurrent,
    closeExtras => l10n.dashboardCloseExtras,
    representationSettings => l10n.dashboardRepresentationSettings,
    proxy => l10n.proxyDeposit,
    unblockDeposit => l10n.dashboardUnblockDeposit,
    blockDeposit => l10n.dashboardBlockDeposit,
    walletInfo => l10n.dashboardWalletInfo,
    walletCharge => l10n.dashboardWalletCharge,
    walletWithdraw => l10n.dashboardWalletWithdraw,
    walletTransfer => l10n.dashboardWalletTransfer,
    walletHistory => l10n.dashboardWalletHistory,
    walletDeposit => l10n.dashboardWalletDeposit,
    changeIdentity => l10n.dashboardChangeIdentity,
    occupation => l10n.dashboardOccupation,
    addresses => l10n.dashboardAddresses,
    changePhone => l10n.dashboardChangePhone,
    requests => l10n.dashboardRequests,
  };

  String catalogLabel(AppLocalizations l10n) => switch (this) {
    password => l10n.cardPasswordIssue.replaceAll(RegExp(r' *\/ *'), '/'),
    mobileBank => l10n.mobileBank,
    internetBank => l10n.internetBank,
    loanDeposit => l10n.dashboardManageInstallments,
    estimate => l10n.dashboardEstimateCredit,
    _ => label(l10n),
  };

  String get catalogAsset => switch (this) {
    statement => AppAssets.dashboardCatalogStatement,
    certificate => AppAssets.dashboardCatalogCertificate,
    representative => AppAssets.dashboardCatalogRepresentative,
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
    blockDeposit => AppAssets.dashboardCatalogRepresentative,
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
    representative => AppAssets.dashboardFixedRepresentative,
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

  String label(AppLocalizations l10n) => switch (this) {
    modern => l10n.dashboardModernBanking,
    cards => l10n.cardServices,
    cheque => l10n.dashboardChequeServices,
    transfers => l10n.dashboardTransferServices,
    loans => l10n.loanServices,
    deposits => l10n.depositServices,
    wallet => l10n.dashboardWalletServices,
    identity => l10n.dashboardIdentityServices,
    requests => l10n.dashboardRequestServices,
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
