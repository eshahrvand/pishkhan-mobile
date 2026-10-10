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
  String get loginTitle => 'Sign in with national ID';

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
  String get dashboardFavoritesLimit => 'You can select up to 8 services.';

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
  String get dashboardResetConfirm => 'Reset settings';

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

  @override
  String get loginDescription =>
      'Enter the following information to sign in to your account';

  @override
  String get otpSentTitle => 'Code sent.';

  @override
  String get refreshCaptcha => 'Refresh security code';

  @override
  String get authInvalidNationalId => 'Enter a 10-digit national ID';

  @override
  String get authInvalidPhone =>
      'Enter an 11-digit mobile number starting with 09';

  @override
  String get authInvalidCaptcha => 'Enter the 6-digit security code';

  @override
  String get dashboardModernBanking => 'Modern banking';

  @override
  String get dashboardChequeServices => 'Cheques';

  @override
  String get dashboardTransferServices => 'Transfers';

  @override
  String get dashboardWalletServices => 'Wallet';

  @override
  String get dashboardIdentityServices => 'Personal information';

  @override
  String get dashboardRequestServices => 'My requests';

  @override
  String get dashboardAllServices => 'All services';

  @override
  String get dashboardViewAll => 'View all';

  @override
  String get dashboardEdit => 'Edit';

  @override
  String get dashboardAddFavorites => 'Add favorite services';

  @override
  String get dashboardManageInstallments => 'Manage installment deductions';

  @override
  String get dashboardEstimateCredit => 'Estimate loan credit';

  @override
  String get dashboardPromptCertificate => 'I need a financial certificate…';

  @override
  String get dashboardPromptCard => 'How do I get a Resalat card?';

  @override
  String get dashboardPhoneBank => 'Phone banking';

  @override
  String get dashboardCardsList => 'Cards list';

  @override
  String get dashboardVirtualCard => 'Request virtual card';

  @override
  String get dashboardUnblockCard => 'Unblock card';

  @override
  String get dashboardExpiredGift => 'Transfer expired gift card balance';

  @override
  String get dashboardClearCheque => 'Clear cheque record';

  @override
  String get dashboardCancelCheque => 'Cancel cheque';

  @override
  String get dashboardLocalTransfer => 'On-site transfer';

  @override
  String get dashboardMyLoans => 'My loans';

  @override
  String get dashboardLoanReport => 'Loan referral report';

  @override
  String get dashboardCorrectInstallments => 'Correct paid installments';

  @override
  String get dashboardDeferLoan => 'Defer loan';

  @override
  String get dashboardDepositsList => 'Deposits list';

  @override
  String get dashboardOpenCurrent => 'Open current account';

  @override
  String get dashboardCloseExtras => 'Close surplus deposits';

  @override
  String get dashboardRepresentationSettings => 'Representation settings';

  @override
  String get dashboardUnblockDeposit => 'Unblock deposit';

  @override
  String get dashboardBlockDeposit => 'Block deposit';

  @override
  String get dashboardWalletInfo => 'Wallet information';

  @override
  String get dashboardWalletCharge => 'Add funds';

  @override
  String get dashboardWalletWithdraw => 'Withdraw funds';

  @override
  String get dashboardWalletTransfer => 'Wallet to wallet transfer';

  @override
  String get dashboardWalletHistory => 'Wallet history';

  @override
  String get dashboardWalletDeposit => 'Change linked wallet deposit';

  @override
  String get dashboardChangeIdentity => 'Change identity details';

  @override
  String get dashboardOccupation => 'Manage occupation';

  @override
  String get dashboardAddresses => 'Manage addresses';

  @override
  String get dashboardChangePhone => 'Change mobile number';

  @override
  String get dashboardRequests => 'My requests';

  @override
  String get cardsMyTitle => 'My cards';

  @override
  String get cardsOperations => 'Card operations';

  @override
  String get cardsPinOperations => 'PIN operations';

  @override
  String get cardsQuickAccess => 'Quick access';

  @override
  String get cardsReissue => 'Reissue card';

  @override
  String get cardsForgotFirst => 'Forgot first PIN';

  @override
  String get cardsSetSecond => 'Set second PIN';

  @override
  String get cardsForgotSecond => 'Forgot second PIN';

  @override
  String get cardsChangeFirst => 'Change first PIN';

  @override
  String get cardsGiftBalance => 'Transfer gift card balance';

  @override
  String get cardsBuyGift => 'Buy gift card';

  @override
  String get cardsVirtual => 'Virtual card';

  @override
  String get cardsCurrent => 'Resalat card (current)';

  @override
  String get cardsQarz => 'Resalat card (Qarz)';

  @override
  String get cardsExpiry => 'Expiry:';

  @override
  String get cardsCopyNumber => 'Copy card number';

  @override
  String get cardsCopyIban => 'Copy IBAN';

  @override
  String get cardsShowDetails => 'Show card details';

  @override
  String get cardsHideDetails => 'Hide card details';

  @override
  String get cardsMore => 'Card options';

  @override
  String get cardsEmpty => 'No cards yet';

  @override
  String get depositsMyTitle => 'My deposits';

  @override
  String get depositsOperations => 'Deposit operations';

  @override
  String get depositsChequeOperations => 'Cheque operations';

  @override
  String get depositsEmpty => 'No deposits yet';

  @override
  String get depositsRepresentative => 'Representative settings';

  @override
  String get depositsLinkedCards => 'Linked cards';

  @override
  String get depositsLinkedLoans => 'Linked loan status';

  @override
  String get depositsLocalTransfer => 'On-site transfer';

  @override
  String get depositsMobileBank => 'Mobile banking';

  @override
  String get depositsCopyNumber => 'Copy deposit number';

  @override
  String get loansOperations => 'Loan operations';

  @override
  String get loansEmpty => 'No loans yet';

  @override
  String get loansPayInstallments => 'Pay installments';

  @override
  String get loansRelationships => 'Family relationships';

  @override
  String get loansDefaultName => 'Standard Qarz al-Hasaneh loan (no fee)';

  @override
  String get loansChangeDeposit => 'Change installment debit deposit';

  @override
  String get dashboardLoading => 'Loading…';

  @override
  String get dashboardLoadError => 'Could not load your information';

  @override
  String get dashboardRetry => 'Try again';

  @override
  String get dashboardEmpty => 'No information to display';

  @override
  String get cardFeatureResalat => 'Resalat card';

  @override
  String get cardFeatureGift => 'Gift card';

  @override
  String get cardFeatureCoupon => 'Bon card';

  @override
  String get cardFeatureFamily => 'Family card';

  @override
  String get cardFeatureDetails => 'Card details';

  @override
  String get cardFeatureNumber => 'Card number';

  @override
  String get cardFeatureDeposit => 'Linked deposit';

  @override
  String get cardFeatureIban => 'IBAN';

  @override
  String get cardFeatureDepositType => 'Deposit type';

  @override
  String get cardFeatureExpiry => 'Expiry date';

  @override
  String get cardFeatureStatus => 'Status';

  @override
  String get cardFeatureActive => 'Active';

  @override
  String get cardFeatureBlocked => 'Blocked';

  @override
  String get cardFeatureExpired => 'Expired';

  @override
  String get cardFeatureQarz => 'Qarz al-Hasan';

  @override
  String get cardFeatureFilter => 'Filter';

  @override
  String get cardFeatureRemoveFilter => 'Remove filter';

  @override
  String get cardFeatureApplyFilter => 'Apply filter';

  @override
  String get cardFeatureAll => 'All';

  @override
  String get cardFeatureNoResults => 'No matching cards';

  @override
  String get cardFeatureCardStatus => 'Card status';

  @override
  String get cardFeatureGiftTransfer => 'Transfer expired gift card balance';

  @override
  String get cardFeatureVirtualRequest => 'Request virtual card';

  @override
  String get cardFeatureUnavailable => 'This service is currently unavailable.';

  @override
  String get issuanceTitle => 'Resalat card issuance';

  @override
  String get issuanceSelectionTitle => 'Select account and issuance type';

  @override
  String get issuanceDeliveryTitle => 'Card delivery information';

  @override
  String get issuanceConfirmTitle => 'Confirm information and pay fees';

  @override
  String get issuanceNextDelivery => 'Next: card delivery information';

  @override
  String get issuanceNextConfirm => 'Next: confirmation and fees';

  @override
  String get issuanceEnd => 'End';

  @override
  String get issuanceDeposit => 'Select account';

  @override
  String get issuanceDepositHint => 'Select the account you want to use';

  @override
  String get issuanceType => 'Card issuance type';

  @override
  String get issuanceTypeHint => 'Select an issuance type';

  @override
  String get issuanceNewNumber => 'Issue a card with a new number';

  @override
  String get issuanceExistingNumber => 'Issue a card with the current number';

  @override
  String get issuanceCurrentCard => 'Current card number';

  @override
  String get issuanceExpiry => 'Expiry date';

  @override
  String get issuanceNoPhysical => 'I do not need a physical card';

  @override
  String get issuanceNext => 'Next step';

  @override
  String get issuanceAddress => 'Address';

  @override
  String get issuanceSelectAddress => 'Select address';

  @override
  String get issuanceAddressHint => 'Select the card delivery address';

  @override
  String get issuanceAddAddress => 'Add a new address';

  @override
  String get issuanceDeleteAddress => 'Delete address';

  @override
  String get issuanceOtherRecipient => 'Receive through another person';

  @override
  String get issuanceIncludeAgent => 'Enter bank agent details';

  @override
  String get issuanceRecipientName => 'Recipient full name';

  @override
  String get issuanceNationalId => 'Recipient national ID';

  @override
  String get issuanceRecipientMobile => 'Recipient mobile number';

  @override
  String get issuanceAgentName => 'Agent full name';

  @override
  String get issuanceAgentCode => 'Agent code';

  @override
  String get issuanceAddressTitle => 'Address label';

  @override
  String get issuanceAddressDetail => 'Full address';

  @override
  String get issuancePostalCode => 'Postal code';

  @override
  String get issuanceSaveAddress => 'Save address';

  @override
  String get issuanceAddressInvalid =>
      'Enter a label, full address and a 10-digit postal code.';

  @override
  String get issuanceSummary => 'Information summary';

  @override
  String get issuanceDepositNumber => 'Account number';

  @override
  String get issuanceOperation => 'Operation type';

  @override
  String get issuancePayable => 'Amount payable';

  @override
  String get issuanceWallet => 'Wallet balance';

  @override
  String get issuancePrintFee => 'Report printing fee';

  @override
  String get issuanceIdentityFee => 'Identity verification fee';

  @override
  String get issuanceDeliveryFee => 'Delivery fee';

  @override
  String get issuanceTerms => 'Terms and conditions';

  @override
  String get issuanceTermsPrompt => 'I have read and accept the request terms.';

  @override
  String get issuanceTermsUnavailable =>
      'Official terms will be provided by the service integration.';

  @override
  String get issuanceSubmit => 'Confirm and submit request';

  @override
  String get issuanceSubmitError =>
      'The request could not be submitted. Try again.';

  @override
  String get issuanceEmpty =>
      'No eligible account is available for card issuance.';

  @override
  String get issuanceMockComplete =>
      'Request preview completed; no payment or card issuance was performed.';

  @override
  String get issuanceComplete => 'Request submitted.';

  @override
  String get issuanceDone => 'Back';

  @override
  String get issuanceWalletSufficient => 'Wallet balance is sufficient';

  @override
  String get issuanceWalletInsufficient => 'Wallet balance is insufficient';

  @override
  String issuanceStepSemantic(int current, int total, String title) {
    return 'Step $current of $total, $title';
  }

  @override
  String get passwordTitle => 'Password services';

  @override
  String get passwordSelectionPrompt => 'Select the card and password type';

  @override
  String get passwordCardType => 'Card type';

  @override
  String get passwordCardTypeHint => 'Select your card type';

  @override
  String get passwordCardNumber => 'Card number';

  @override
  String get passwordCardNumberHint => 'Select the card number';

  @override
  String get passwordType => 'Password type';

  @override
  String get passwordTypeHint => 'Select the password type';

  @override
  String get passwordFirst => 'First PIN';

  @override
  String get passwordSecond => 'Second password';

  @override
  String get passwordFirstDescription =>
      'For in-person ATM and point-of-sale transactions.';

  @override
  String get passwordSecondDescription =>
      'For online transactions below 100,000 tomans.';

  @override
  String get passwordOperation => 'Operation';

  @override
  String get passwordChangePrompt =>
      'Enter your current password and your chosen new password.';

  @override
  String get passwordCurrentHint => 'Current password';

  @override
  String get passwordNewHint => 'New password';

  @override
  String get passwordNewConfirmationHint => 'Confirm new password';

  @override
  String get passwordChangeSubmit => 'Submit request';

  @override
  String get passwordChangeSuccessBody =>
      'Your password change was successful.';

  @override
  String get passwordStatusRegisteredTitle =>
      'Your request was registered successfully.';

  @override
  String get passwordOperationHint => 'Select an operation';

  @override
  String get passwordChange => 'Change password';

  @override
  String get passwordForgot => 'Forgot password';

  @override
  String get passwordSetSecond => 'Set second password';

  @override
  String get passwordPrompt => 'Enter your preferred second password.';

  @override
  String get passwordValueHint => 'Password';

  @override
  String get passwordConfirmationHint => 'Repeat password';

  @override
  String get passwordLengthRule => 'Use 4 to 6 digits';

  @override
  String get passwordPatternRule => 'Avoid sequential or repeating numbers';

  @override
  String get passwordDateRule =>
      'Avoid meaningful dates (birth date, card expiry)';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get passwordShow => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String get passwordSerialPrompt =>
      'Enter the serial on the back of your national ID card or its receipt tracking code.';

  @override
  String get passwordSerialHint => 'National ID serial | receipt tracking code';

  @override
  String get passwordSerialHelper => 'Contains digits and one Latin letter';

  @override
  String get passwordSerialError =>
      'Enter digits and exactly one Latin letter.';

  @override
  String get passwordInstructionPrompt =>
      'After watching the instructional video, identity verification begins.';

  @override
  String get passwordCameraNotice =>
      'This step requires a camera and microphone.';

  @override
  String get passwordStartKyc => 'Start identity verification';

  @override
  String get passwordRecordingPrompt =>
      'Confirm the video and submit your request.';

  @override
  String get passwordRecordAgain => 'Record again';

  @override
  String get passwordSubmit => 'Send and submit request';

  @override
  String get passwordMockKyc =>
      'Demo recording and KYC: no video of you is captured.';

  @override
  String get passwordConfirmMock => 'Confirm demo preview';

  @override
  String get passwordPendingTitle => 'You have an open validation request';

  @override
  String get passwordPendingBody =>
      '• After validation, if identity is confirmed, an SMS containing password information will be sent.\n• During the validation period, other counter services requiring verification can be used without paying again.';

  @override
  String get passwordSubmittedTitle => 'Your request was sent';

  @override
  String get passwordSubmittedBody =>
      'After validation and identity approval, an SMS containing mobile banking credentials will be sent. You can then sign in using those credentials.';

  @override
  String get passwordApprovedTitle => 'Your request was completed successfully';

  @override
  String get passwordApprovedBody =>
      'An SMS containing mobile banking credentials will be sent. You can sign in using the credentials in that message.';

  @override
  String get passwordTracking => 'Tracking code';

  @override
  String get passwordUnderstood => 'Understood';

  @override
  String get passwordMockReceipt =>
      'Demo result: no bank password has been set and no SMS is sent.';

  @override
  String get passwordDemoVideo =>
      'Demo video: Big Buck Bunny — Blender Foundation (CC BY 3.0)';

  @override
  String get passwordPlay => 'Play video';

  @override
  String get passwordPause => 'Pause video';

  @override
  String get passwordSeek => 'Playback position';

  @override
  String get passwordVideoUnavailable => 'Video unavailable';

  @override
  String get passwordUnsupported =>
      'This operation is unavailable for the selected card.';

  @override
  String get passwordExitTitle => 'Leave password setup?';

  @override
  String get passwordExitBody => 'Entered information will be cleared.';

  @override
  String get passwordExit => 'Leave';

  @override
  String get passwordStay => 'Continue setup';
}
