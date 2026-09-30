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
  cardDeposit('card-deposit'),
  block('card-block'),
  estimate('loan-estimate'),
  introduce('loan-introduce'),
  consolidation('loan-consolidate'),
  loanDeposit('loan-deposit');

  const DashboardService(this.id);
  final String id;

  static const fixed = [assistant, password, estimate, sms];
  static const deposits = [statement, certificate, representative, sms];
  static const cards = [issue, password, cardDeposit, block];
  static const loans = [estimate, introduce, consolidation, loanDeposit];

  String label(AppLocalizations l10n) => switch (this) {
    assistant => l10n.dashboardAssistant,
    statement => l10n.balanceAverageStatement,
    certificate => l10n.financialCertificate,
    representative => l10n.introduceRepresentative,
    sms => l10n.smsSettings,
    issue => l10n.issueResalatCard,
    password => l10n.cardPasswordIssue,
    cardDeposit => l10n.changeCardDeposit,
    block => l10n.blockCard,
    estimate => l10n.loanEstimate,
    introduce => l10n.introduceLoan,
    consolidation => l10n.consolidateDepositCredit,
    loanDeposit => l10n.changeInstallmentDeposit,
  };

  String get catalogAsset => switch (this) {
    assistant => AppAssets.dashboardAssistantStar,
    statement => AppAssets.dashboardCatalogStatement,
    certificate => AppAssets.dashboardCatalogCertificate,
    representative => AppAssets.dashboardCatalogRepresentative,
    sms => AppAssets.dashboardCatalogSms,
    issue => AppAssets.dashboardCatalogIssue,
    password => AppAssets.dashboardCatalogPassword,
    cardDeposit => AppAssets.dashboardCatalogCardDeposit,
    block => AppAssets.dashboardCatalogBlock,
    estimate => AppAssets.dashboardCatalogEstimate,
    introduce => AppAssets.dashboardCatalogIntroduce,
    consolidation => AppAssets.dashboardCatalogConsolidation,
    loanDeposit => AppAssets.dashboardCatalogLoanDeposit,
  };

  String? tileAsset({
    bool fixed = false,
    bool editing = false,
    bool full = false,
  }) => switch (this) {
    estimate =>
      fixed
          ? AppAssets.dashboardEstimateTile
          : editing && full
          ? AppAssets.dashboardEstimateFullTile
          : AppAssets.dashboardEstimateSelectedTile,
    password =>
      fixed
          ? AppAssets.dashboardPasswordTile
          : editing
          ? full
                ? AppAssets.dashboardPasswordFullTile
                : AppAssets.dashboardPasswordEditTile
          : AppAssets.dashboardPasswordSelectedTile,
    block =>
      editing
          ? full
                ? AppAssets.dashboardBlockFullTile
                : AppAssets.dashboardBlockEditTile
          : AppAssets.dashboardBlockSelectedTile,
    issue =>
      editing
          ? AppAssets.dashboardIssueEditTile
          : AppAssets.dashboardIssueSelectedTile,
    _ => null,
  };
}
