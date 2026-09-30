// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Resalat Virtual Counter';

  @override
  String get changeMobileTitle => 'Change mobile number';

  @override
  String get backLabel => 'Back';

  @override
  String get closeLabel => 'Close';

  @override
  String get servicesMenuLabel => 'Services menu';

  @override
  String get changeMobileDescription =>
      'Enter the following information to access the counter and change your mobile number';

  @override
  String get loginTitle => 'Sign in to the virtual counter';

  @override
  String get loginNationalIdHint =>
      'National ID | Identity number | Foreigner code';

  @override
  String get changeNationalIdHint =>
      'Enter your national ID or identity number';

  @override
  String get loginPhoneHint => 'Enter your mobile number';

  @override
  String get changePhoneHint => 'Enter your new mobile number';

  @override
  String get changePhoneAction => 'Change mobile number';

  @override
  String get requestTwoFactorCode => 'Request two-factor code';

  @override
  String get requestOtp => 'Request verification code';

  @override
  String get phoneOwnershipNotice =>
      'The number must match the account holder\'s national ID';

  @override
  String get captchaHint => 'Enter the code';

  @override
  String otpSentMessage(String phone) {
    return 'Enter the dynamic code sent to $phone.';
  }

  @override
  String get otpHint => 'Enter the code';

  @override
  String get submitRequest => 'Submit request';

  @override
  String get enterDashboard => 'Enter the counter';

  @override
  String get resendOtp => 'Resend';

  @override
  String get servicesList => 'Services list';

  @override
  String get guestServices => 'Services available without signing in';

  @override
  String get assetReport => 'Asset report';

  @override
  String get changeMobileService => 'Change mobile number';

  @override
  String get requestStatus => 'Request status';

  @override
  String get inheritance => 'Inheritance monopoly';

  @override
  String get relatedLinks => 'Related links';

  @override
  String get mobileBank => 'Mobile banking';

  @override
  String get internetBank => 'Internet banking';

  @override
  String get memberContactCenter => 'Member contact center';

  @override
  String get resalatApp => 'Resalat app';

  @override
  String get securityTips => 'Security tips';

  @override
  String get updateGuide => 'Update guide';

  @override
  String get dashboardGreeting => 'Good morning, Mani';

  @override
  String get dashboardWelcomeMessage =>
      'Welcome to the Resalat Virtual Counter';

  @override
  String get walletBalanceTitle => 'Wallet balance';

  @override
  String get rialCurrency => 'Rial';

  @override
  String get dashboardWalletBalance => '1,200,000';

  @override
  String get depositServices => 'Deposit services';

  @override
  String get smsSettings => 'SMS settings';

  @override
  String get introduceRepresentative => 'Introduce representative';

  @override
  String get financialCertificate => 'Financial certificate';

  @override
  String get balanceAverageStatement => 'Balance average statement';

  @override
  String get cardServices => 'Card services';

  @override
  String get blockCard => 'Block card';

  @override
  String get changeCardDeposit => 'Change linked deposit';

  @override
  String get cardPasswordIssue => 'Issue first / second PIN';

  @override
  String get issueResalatCard => 'Issue Resalat card';

  @override
  String get loanServices => 'Loan services';

  @override
  String get changeInstallmentDeposit => 'Change installment deposit';

  @override
  String get consolidateDepositCredit => 'Consolidate deposit credit';

  @override
  String get introduceLoan => 'Introduce loan';

  @override
  String get loanEstimate => 'Loan estimate';

  @override
  String get selectedServices => 'Selected services';

  @override
  String get proxyDeposit => 'Proxy deposit';

  @override
  String get issueChequeBook => 'Issue cheque book';

  @override
  String get internetBankSettings => 'Internet bank settings';

  @override
  String get mobileBankSettings => 'Mobile bank settings';

  @override
  String get latestUpdatedRequests => 'Latest updated requests';

  @override
  String get dashboardRequestTitle =>
      'Request to change the installment deposit';

  @override
  String get requestIdentifier => 'Request identifier';

  @override
  String get automaticCompleted => 'Completed automatically';

  @override
  String get dashboardRequestNumber => '137/487567';

  @override
  String get dashboardRequestDate => '2024/09/16 | 12:45';

  @override
  String get profileLabel => 'Profile';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get dashboardAssistant => 'AI assistant';

  @override
  String get dashboardResoTitle => 'Leave it to Reso!';

  @override
  String get dashboardResoDescription =>
      'Reso does more than answer; it takes action.';

  @override
  String get dashboardPromptHint => 'Write your question...';

  @override
  String get dashboardSendPrompt => 'Send question';

  @override
  String get dashboardBankServices => 'Resalat Bank services';

  @override
  String get dashboardCustomize => 'Customize services';

  @override
  String get dashboardYourFavorites => 'Your favorites';

  @override
  String get dashboardFavoritesLimit => 'You can select up to 4 services.';

  @override
  String get dashboardAddService => 'Add a new service';

  @override
  String get dashboardRemoveService => 'Remove';

  @override
  String get dashboardConfirm => 'Confirm';

  @override
  String get dashboardCancel => 'Cancel';

  @override
  String get dashboardResetTitle => 'Reset settings';

  @override
  String get dashboardResetDescription =>
      'Resetting settings removes your changes and restores the original configuration.\nAre you sure you want to reset?';

  @override
  String get dashboardResetConfirm => 'Submit rating';

  @override
  String get dashboardSearchHint => 'Search';

  @override
  String get dashboardNoServices => 'No services found';

  @override
  String get dashboardTab => 'Dashboard';

  @override
  String get dashboardCardsTab => 'Cards';

  @override
  String get dashboardDepositsTab => 'Deposits';

  @override
  String get dashboardLoansTab => 'Loans';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationReadAll => 'Read all';

  @override
  String get notificationNew => 'New messages';

  @override
  String get notificationRead => 'Read messages';

  @override
  String get notificationSubject => 'Subject';

  @override
  String get notificationEmpty => 'No messages';

  @override
  String get notificationToday => 'Today';

  @override
  String get notificationYesterday => 'Yesterday';

  @override
  String get notificationFiveDays => '5 days ago';

  @override
  String get notificationSevenDays => '7 days ago';

  @override
  String get notificationSampleDate => '16 Shahrivar 1405';

  @override
  String get notificationLoanTitle => 'Borrow against your savings';

  @override
  String get notificationLoanSubtitle => 'Secured loan';

  @override
  String get notificationInvestmentTitle => 'Invest in gold';

  @override
  String get notificationInvestmentSubtitle =>
      'Easy, fast gold trading with instant settlement';

  @override
  String get notificationSecurityTitle => 'Watch out for scammers ⚠️';

  @override
  String get notificationSecuritySubtitle => 'Tips to keep your account secure';

  @override
  String get notificationSecurityIntro =>
      'Hi! You may receive messages from scammers pretending to be our support team. Keep these tips in mind to protect your account:';

  @override
  String get notificationSecurityAdvice =>
      'To avoid scams and keep your account safe, remember:';

  @override
  String get notificationSecurityCode =>
      'Never share your login code: our support team will never ask for your password or verification code.';

  @override
  String get notificationSecurityLinks =>
      'Do not open suspicious links: avoid unknown links claiming your account is blocked or that you won a prize.';

  @override
  String get notificationSecurityOfficial =>
      'Use official channels: make sure messages come from our official numbers or accounts.';

  @override
  String get notificationSecurityClosing =>
      'If you notice anything suspicious, let us know so we can check it promptly.';
}
