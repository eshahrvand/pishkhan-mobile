// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(percentage) => "${percentage}%";

  static String m1(number) => "Remove card ${number}";

  static String m2(count) => "Selected cards (${count})";

  static String m3(current, total, title) =>
      "Step ${current} of ${total}, ${title}";

  static String m4(phone) => "Enter the dynamic code sent to ${phone}.";

  static String m5(occupation) =>
      "Are you sure you want to delete your occupation (${occupation})?";

  static String m6(selected, existing) =>
      "The selected occupation (${selected}) is incompatible with your existing occupation (${existing}).";

  static String m7(previous, selected) =>
      "Changing from ${previous} to ${selected} requires operator review. Changes will be visible after approval.";

  static String m8(amount) => "${amount} tomans";

  static String m9(max) => "The card count must be between 1 and ${max}.";

  static String m10(amount) => "The issuance fee per card is ${amount}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "agentAddNext":
            MessageLookupByLibrary.simpleMessage("Add another agent"),
        "agentCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "agentChequeBook":
            MessageLookupByLibrary.simpleMessage("Cheque book issuance"),
        "agentDeposit": MessageLookupByLibrary.simpleMessage("Select deposit"),
        "agentDepositHint":
            MessageLookupByLibrary.simpleMessage("Select your deposit"),
        "agentDepositShort": MessageLookupByLibrary.simpleMessage("Deposit"),
        "agentKind": MessageLookupByLibrary.simpleMessage("Authorization type"),
        "agentMockComplete": MessageLookupByLibrary.simpleMessage(
            "Demo request recorded. No banking authority has been granted."),
        "agentNationalId":
            MessageLookupByLibrary.simpleMessage("Agent national ID"),
        "agentNationalIdHint":
            MessageLookupByLibrary.simpleMessage("Enter agent national ID"),
        "agentNewPerson": MessageLookupByLibrary.simpleMessage("New agent"),
        "agentOperation":
            MessageLookupByLibrary.simpleMessage("Operation type"),
        "agentOperationHint": MessageLookupByLibrary.simpleMessage(
            "Select the agent’s permitted operation"),
        "agentPreliminarySave":
            MessageLookupByLibrary.simpleMessage("Add to pending list"),
        "agentRemove": MessageLookupByLibrary.simpleMessage("Remove agent"),
        "agentSave": MessageLookupByLibrary.simpleMessage("Save"),
        "agentSettingsActive": MessageLookupByLibrary.simpleMessage("Active"),
        "agentSettingsAdd": MessageLookupByLibrary.simpleMessage("Add agent"),
        "agentSettingsCancel":
            MessageLookupByLibrary.simpleMessage("Cancel agent"),
        "agentSettingsClearChequeRecord":
            MessageLookupByLibrary.simpleMessage("Clear cheque record"),
        "agentSettingsConfirmers":
            MessageLookupByLibrary.simpleMessage("Approver details"),
        "agentSettingsDelegated":
            MessageLookupByLibrary.simpleMessage("Me as agent"),
        "agentSettingsDepositLabel":
            MessageLookupByLibrary.simpleMessage("Deposit number:"),
        "agentSettingsDepositRelation":
            MessageLookupByLibrary.simpleMessage("Deposit owner and signatory"),
        "agentSettingsDetails":
            MessageLookupByLibrary.simpleMessage("Agent details"),
        "agentSettingsEmpty": MessageLookupByLibrary.simpleMessage(
            "No agents match these filters."),
        "agentSettingsExpired": MessageLookupByLibrary.simpleMessage("Expired"),
        "agentSettingsExpiryLabel":
            MessageLookupByLibrary.simpleMessage("Expires:"),
        "agentSettingsIntroducedLabel":
            MessageLookupByLibrary.simpleMessage("Introduced:"),
        "agentSettingsIntroducer":
            MessageLookupByLibrary.simpleMessage("Introducer"),
        "agentSettingsKindLabel":
            MessageLookupByLibrary.simpleMessage("Authorization type:"),
        "agentSettingsLoanReferral":
            MessageLookupByLibrary.simpleMessage("Loan referral"),
        "agentSettingsMine": MessageLookupByLibrary.simpleMessage("My agents"),
        "agentSettingsNameLabel":
            MessageLookupByLibrary.simpleMessage("Agent:"),
        "agentSettingsNationalIdLabel":
            MessageLookupByLibrary.simpleMessage("National ID:"),
        "agentSettingsSelectAll":
            MessageLookupByLibrary.simpleMessage("(Select all)"),
        "agentSettingsShare": m0,
        "agentSettingsWaiting":
            MessageLookupByLibrary.simpleMessage("Awaiting approval"),
        "agentTitle":
            MessageLookupByLibrary.simpleMessage("Introduce a new agent"),
        "agentValidity": MessageLookupByLibrary.simpleMessage("Valid until"),
        "agentValidityError": MessageLookupByLibrary.simpleMessage(
            "Enter a valid date from today onward in Jalali YYYY/MM/DD format."),
        "agentValidityHint":
            MessageLookupByLibrary.simpleMessage("Enter expiry date"),
        "appTitle":
            MessageLookupByLibrary.simpleMessage("Resalat Virtual Counter"),
        "assetReport": MessageLookupByLibrary.simpleMessage("Asset report"),
        "authInvalidCaptcha": MessageLookupByLibrary.simpleMessage(
            "Enter the 6-digit security code"),
        "authInvalidNationalId": MessageLookupByLibrary.simpleMessage(
            "Enter a 10-digit national ID"),
        "authInvalidPhone": MessageLookupByLibrary.simpleMessage(
            "Enter an 11-digit mobile number starting with 09"),
        "automaticCompleted":
            MessageLookupByLibrary.simpleMessage("Completed automatically"),
        "backLabel": MessageLookupByLibrary.simpleMessage("Back"),
        "balanceAverageStatement":
            MessageLookupByLibrary.simpleMessage("Balance average statement"),
        "blockCard": MessageLookupByLibrary.simpleMessage("Block card"),
        "captchaHint": MessageLookupByLibrary.simpleMessage("Enter the code"),
        "cardFeatureActive": MessageLookupByLibrary.simpleMessage("Active"),
        "cardFeatureAll": MessageLookupByLibrary.simpleMessage("All"),
        "cardFeatureApplyFilter":
            MessageLookupByLibrary.simpleMessage("Apply filter"),
        "cardFeatureBlocked": MessageLookupByLibrary.simpleMessage("Blocked"),
        "cardFeatureCardStatus":
            MessageLookupByLibrary.simpleMessage("Card status"),
        "cardFeatureCoupon": MessageLookupByLibrary.simpleMessage("Bon card"),
        "cardFeatureDeposit":
            MessageLookupByLibrary.simpleMessage("Linked deposit"),
        "cardFeatureDepositType":
            MessageLookupByLibrary.simpleMessage("Deposit type"),
        "cardFeatureDetails":
            MessageLookupByLibrary.simpleMessage("Card details"),
        "cardFeatureExpired": MessageLookupByLibrary.simpleMessage("Expired"),
        "cardFeatureExpiry":
            MessageLookupByLibrary.simpleMessage("Expiry date"),
        "cardFeatureFamily":
            MessageLookupByLibrary.simpleMessage("Family card"),
        "cardFeatureFilter": MessageLookupByLibrary.simpleMessage("Filter"),
        "cardFeatureGift": MessageLookupByLibrary.simpleMessage("Gift card"),
        "cardFeatureGiftTransfer": MessageLookupByLibrary.simpleMessage(
            "Transfer expired gift card balance"),
        "cardFeatureIban": MessageLookupByLibrary.simpleMessage("IBAN"),
        "cardFeatureNoResults":
            MessageLookupByLibrary.simpleMessage("No matching cards"),
        "cardFeatureNumber":
            MessageLookupByLibrary.simpleMessage("Card number"),
        "cardFeatureQarz":
            MessageLookupByLibrary.simpleMessage("Qarz al-Hasan"),
        "cardFeatureRemoveFilter":
            MessageLookupByLibrary.simpleMessage("Remove filter"),
        "cardFeatureResalat":
            MessageLookupByLibrary.simpleMessage("Resalat card"),
        "cardFeatureStatus": MessageLookupByLibrary.simpleMessage("Status"),
        "cardFeatureUnavailable": MessageLookupByLibrary.simpleMessage(
            "This service is currently unavailable."),
        "cardFeatureVirtualRequest":
            MessageLookupByLibrary.simpleMessage("Request virtual card"),
        "cardPasswordIssue":
            MessageLookupByLibrary.simpleMessage("Issue first / second PIN"),
        "cardServiceCard": MessageLookupByLibrary.simpleMessage("Card"),
        "cardServiceCardHint":
            MessageLookupByLibrary.simpleMessage("Select your card"),
        "cardServiceComplete": MessageLookupByLibrary.simpleMessage(
            "Request submitted successfully."),
        "cardServiceCurrentDeposit":
            MessageLookupByLibrary.simpleMessage("Current deposit"),
        "cardServiceEmpty":
            MessageLookupByLibrary.simpleMessage("No items available."),
        "cardServiceFromDeposit":
            MessageLookupByLibrary.simpleMessage("From deposit"),
        "cardServiceMockComplete": MessageLookupByLibrary.simpleMessage(
            "Demo request recorded; no bank operation was performed."),
        "cardServiceQarzDeposit":
            MessageLookupByLibrary.simpleMessage("Qarz al-Hasan deposit"),
        "cardServiceSubmit":
            MessageLookupByLibrary.simpleMessage("Confirm and submit request"),
        "cardServiceSubmitError": MessageLookupByLibrary.simpleMessage(
            "The request could not be submitted. Try again."),
        "cardServiceToDeposit":
            MessageLookupByLibrary.simpleMessage("To deposit"),
        "cardServiceToDepositHint": MessageLookupByLibrary.simpleMessage(
            "Select the deposit to link to this card"),
        "cardServices": MessageLookupByLibrary.simpleMessage("Card services"),
        "cardsBuyGift": MessageLookupByLibrary.simpleMessage("Buy gift card"),
        "cardsChangeFirst":
            MessageLookupByLibrary.simpleMessage("Change first PIN"),
        "cardsCopyIban": MessageLookupByLibrary.simpleMessage("Copy IBAN"),
        "cardsCopyNumber":
            MessageLookupByLibrary.simpleMessage("Copy card number"),
        "cardsCurrent":
            MessageLookupByLibrary.simpleMessage("Resalat card (current)"),
        "cardsEmpty": MessageLookupByLibrary.simpleMessage("No cards yet"),
        "cardsExpiry": MessageLookupByLibrary.simpleMessage("Expiry:"),
        "cardsForgotFirst":
            MessageLookupByLibrary.simpleMessage("Forgot first PIN"),
        "cardsForgotSecond":
            MessageLookupByLibrary.simpleMessage("Forgot second PIN"),
        "cardsGiftBalance":
            MessageLookupByLibrary.simpleMessage("Transfer gift card balance"),
        "cardsHideDetails":
            MessageLookupByLibrary.simpleMessage("Hide card details"),
        "cardsMore": MessageLookupByLibrary.simpleMessage("Card options"),
        "cardsMyTitle": MessageLookupByLibrary.simpleMessage("My cards"),
        "cardsOperations":
            MessageLookupByLibrary.simpleMessage("Card operations"),
        "cardsPinOperations":
            MessageLookupByLibrary.simpleMessage("PIN operations"),
        "cardsQarz":
            MessageLookupByLibrary.simpleMessage("Resalat card (Qarz)"),
        "cardsQuickAccess":
            MessageLookupByLibrary.simpleMessage("Quick access"),
        "cardsReissue": MessageLookupByLibrary.simpleMessage("Reissue card"),
        "cardsSetSecond":
            MessageLookupByLibrary.simpleMessage("Set second PIN"),
        "cardsShowDetails":
            MessageLookupByLibrary.simpleMessage("Show card details"),
        "cardsVirtual": MessageLookupByLibrary.simpleMessage("Virtual card"),
        "certificateAddressHint": MessageLookupByLibrary.simpleMessage(
            "Select the certificate delivery address"),
        "certificateAgentIdentifier":
            MessageLookupByLibrary.simpleMessage("Agent national ID or phone"),
        "certificateAgentNotice": MessageLookupByLibrary.simpleMessage(
            "If you know a bank agent, enter their national ID or phone number."),
        "certificateAgentUnavailable": MessageLookupByLibrary.simpleMessage(
            "Agent verification requires bank integration."),
        "certificateAverageBalance":
            MessageLookupByLibrary.simpleMessage("Average balance"),
        "certificateAverageTitle": MessageLookupByLibrary.simpleMessage(
            "Statement | Average balance request"),
        "certificateBothTurnovers":
            MessageLookupByLibrary.simpleMessage("Deposits | Withdrawals"),
        "certificateCheckAgent": MessageLookupByLibrary.simpleMessage("Check"),
        "certificateConditionsPrompt": MessageLookupByLibrary.simpleMessage(
            "Select the conditions to include on the certificate."),
        "certificateConditionsStep": MessageLookupByLibrary.simpleMessage(
            "Select deposit and request conditions"),
        "certificateDeleteAddressPrompt":
            MessageLookupByLibrary.simpleMessage("Delete this address?"),
        "certificateDeliveryStep": MessageLookupByLibrary.simpleMessage(
            "Certificate delivery information"),
        "certificateDepositsOnly":
            MessageLookupByLibrary.simpleMessage("Deposits"),
        "certificateEnglish": MessageLookupByLibrary.simpleMessage("English"),
        "certificateFromDate":
            MessageLookupByLibrary.simpleMessage("From date"),
        "certificateFromDateHint":
            MessageLookupByLibrary.simpleMessage("Select start date"),
        "certificateLanguage": MessageLookupByLibrary.simpleMessage("Language"),
        "certificateMockComplete": MessageLookupByLibrary.simpleMessage(
            "Demo request recorded; no certificate issued and no wallet debit."),
        "certificateNextPrefix": MessageLookupByLibrary.simpleMessage("Next:"),
        "certificateOptional": MessageLookupByLibrary.simpleMessage("Optional"),
        "certificatePersian": MessageLookupByLibrary.simpleMessage("Persian"),
        "certificatePrintingNotice": MessageLookupByLibrary.simpleMessage(
            "Printing fees depend on the number of pages."),
        "certificateRecipientName":
            MessageLookupByLibrary.simpleMessage("Full name"),
        "certificateRecipientNameHint":
            MessageLookupByLibrary.simpleMessage("Enter recipient full name"),
        "certificateRecipientNationalIdHint":
            MessageLookupByLibrary.simpleMessage("Enter recipient national ID"),
        "certificateRecipientNotice": MessageLookupByLibrary.simpleMessage(
            "The package is delivered to you. If unavailable, provide the second recipient details."),
        "certificateStatementLanguageHint":
            MessageLookupByLibrary.simpleMessage("Select statement language"),
        "certificateToDate": MessageLookupByLibrary.simpleMessage("To date"),
        "certificateToDateHint":
            MessageLookupByLibrary.simpleMessage("Select end date"),
        "certificateTurnover":
            MessageLookupByLibrary.simpleMessage("Transaction type"),
        "certificateTurnoverHint": MessageLookupByLibrary.simpleMessage(
            "Select deposit transaction type"),
        "certificateWithdrawalsOnly":
            MessageLookupByLibrary.simpleMessage("Withdrawals"),
        "changeCardDeposit":
            MessageLookupByLibrary.simpleMessage("Change linked deposit"),
        "changeCardDepositIntro": MessageLookupByLibrary.simpleMessage(
            "Select a card, then choose the deposit to link to it."),
        "changeCardDepositTitle":
            MessageLookupByLibrary.simpleMessage("Change linked card deposit"),
        "changeInstallmentDeposit":
            MessageLookupByLibrary.simpleMessage("Change installment deposit"),
        "changeMobileDescription": MessageLookupByLibrary.simpleMessage(
            "Enter the following information to access the counter and change your mobile number"),
        "changeMobileService":
            MessageLookupByLibrary.simpleMessage("Change mobile number"),
        "changeMobileTitle":
            MessageLookupByLibrary.simpleMessage("Change mobile number"),
        "changeNationalIdHint": MessageLookupByLibrary.simpleMessage(
            "Enter your national ID or identity number"),
        "changePhoneAction":
            MessageLookupByLibrary.simpleMessage("Change mobile number"),
        "changePhoneHint": MessageLookupByLibrary.simpleMessage(
            "Enter your new mobile number"),
        "chequeBookAddressesNoticeEnd":
            MessageLookupByLibrary.simpleMessage("."),
        "chequeBookAddressesNoticeStart": MessageLookupByLibrary.simpleMessage(
            "To change an address, open Profile, "),
        "chequeBookChecking": MessageLookupByLibrary.simpleMessage(
            "Checking the housing registry…"),
        "chequeBookDeleteContinue":
            MessageLookupByLibrary.simpleMessage("Delete and continue"),
        "chequeBookDeletePrompt": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this address?"),
        "chequeBookDeliveryStep":
            MessageLookupByLibrary.simpleMessage("Delivery details"),
        "chequeBookDepositHint":
            MessageLookupByLibrary.simpleMessage("Select a deposit"),
        "chequeBookFiftyLeavesNotice": MessageLookupByLibrary.simpleMessage(
            "For individuals, a 50-leaf cheque book is available after the third year."),
        "chequeBookIssueFee":
            MessageLookupByLibrary.simpleMessage("Cheque book issuance fee"),
        "chequeBookLeafCount":
            MessageLookupByLibrary.simpleMessage("Number of leaves"),
        "chequeBookLeafCountHint": MessageLookupByLibrary.simpleMessage(
            "Select the number of cheque leaves"),
        "chequeBookLegalRecipientPrompt": MessageLookupByLibrary.simpleMessage(
            "Enter the cheque book recipient’s details"),
        "chequeBookLinkUnavailable": MessageLookupByLibrary.simpleMessage(
            "A browser could not be opened on this device."),
        "chequeBookMissingNotice": MessageLookupByLibrary.simpleMessage(
            "If this address is correct, register it in the housing registry before requesting a cheque book."),
        "chequeBookMockComplete": MessageLookupByLibrary.simpleMessage(
            "Demo request recorded. No real cheque book was issued and no payment was taken."),
        "chequeBookMultipleMissingNotice": MessageLookupByLibrary.simpleMessage(
            "Register your correct address in the housing registry or remove your extra addresses."),
        "chequeBookMyAddresses":
            MessageLookupByLibrary.simpleMessage("My addresses"),
        "chequeBookNextConfirmation": MessageLookupByLibrary.simpleMessage(
            "Next: Confirm details and pay fees"),
        "chequeBookNextDelivery":
            MessageLookupByLibrary.simpleMessage("Next: Delivery details"),
        "chequeBookNextResidency": MessageLookupByLibrary.simpleMessage(
            "Next: Housing registry check"),
        "chequeBookNotRegistered":
            MessageLookupByLibrary.simpleMessage("Not registered"),
        "chequeBookOpenedAt":
            MessageLookupByLibrary.simpleMessage("Account opening date:"),
        "chequeBookRecipientName":
            MessageLookupByLibrary.simpleMessage("Full name"),
        "chequeBookRecipientNameHint": MessageLookupByLibrary.simpleMessage(
            "Enter the recipient’s full name"),
        "chequeBookRecipientNameInvalid":
            MessageLookupByLibrary.simpleMessage("Enter a full name."),
        "chequeBookRecipientNationalId":
            MessageLookupByLibrary.simpleMessage("National ID"),
        "chequeBookRecipientNationalIdHint":
            MessageLookupByLibrary.simpleMessage(
                "Enter the recipient’s national ID"),
        "chequeBookRegistered":
            MessageLookupByLibrary.simpleMessage("Registered"),
        "chequeBookRegistryHost":
            MessageLookupByLibrary.simpleMessage("amlak.mrud.ir"),
        "chequeBookRegistryName":
            MessageLookupByLibrary.simpleMessage("housing registry"),
        "chequeBookRegistryUrlLabel":
            MessageLookupByLibrary.simpleMessage("Housing registry website:"),
        "chequeBookResidence":
            MessageLookupByLibrary.simpleMessage("Your residential address:"),
        "chequeBookResidences":
            MessageLookupByLibrary.simpleMessage("Your residential addresses:"),
        "chequeBookResidencyStep":
            MessageLookupByLibrary.simpleMessage("Housing registry check"),
        "chequeBookResidencyWarningEnd":
            MessageLookupByLibrary.simpleMessage("."),
        "chequeBookResidencyWarningStart": MessageLookupByLibrary.simpleMessage(
            "Your residential address is not verified in the "),
        "chequeBookSelectionPrompt": MessageLookupByLibrary.simpleMessage(
            "Select your current account and number of cheque leaves."),
        "chequeBookSelectionStep":
            MessageLookupByLibrary.simpleMessage("Cheque book details"),
        "chequeBookTitle":
            MessageLookupByLibrary.simpleMessage("Request a cheque book"),
        "chequeBookUsedLeavesNotice": MessageLookupByLibrary.simpleMessage(
            "At least 80% of your previous cheque book leaves must have been returned to the bank."),
        "chequeCancelAllReasons":
            MessageLookupByLibrary.simpleMessage("Apply one reason to all"),
        "chequeCancelAllReasonsTitle":
            MessageLookupByLibrary.simpleMessage("Select a reason for all"),
        "chequeCancelChequesPrompt": MessageLookupByLibrary.simpleMessage(
            "Select the cheques to cancel"),
        "chequeCancelChequesStep":
            MessageLookupByLibrary.simpleMessage("Select cheques"),
        "chequeCancelChoose": MessageLookupByLibrary.simpleMessage("Select"),
        "chequeCancelConfirmationStep":
            MessageLookupByLibrary.simpleMessage("Download letter and submit"),
        "chequeCancelDamaged":
            MessageLookupByLibrary.simpleMessage("Damaged — unused"),
        "chequeCancelDepositHint":
            MessageLookupByLibrary.simpleMessage("Select a deposit"),
        "chequeCancelDigital": MessageLookupByLibrary.simpleMessage("Digital"),
        "chequeCancelDownload": MessageLookupByLibrary.simpleMessage(
            "Save letter for postal delivery"),
        "chequeCancelEmpty":
            MessageLookupByLibrary.simpleMessage("No results found"),
        "chequeCancelJudicial":
            MessageLookupByLibrary.simpleMessage("Judicial authority order"),
        "chequeCancelLetterPrompt": MessageLookupByLibrary.simpleMessage(
            "To cancel the cheques, download the letter below, then submit your request."),
        "chequeCancelMailInstruction": MessageLookupByLibrary.simpleMessage(
            "Print the downloaded letter and deliver it with the listed cheques to an authorized post office for cancellation."),
        "chequeCancelMockComplete": MessageLookupByLibrary.simpleMessage(
            "Demo cancellation request recorded. No bank cheque was cancelled."),
        "chequeCancelNumber":
            MessageLookupByLibrary.simpleMessage("Cheque number"),
        "chequeCancelPaper": MessageLookupByLibrary.simpleMessage("Paper"),
        "chequeCancelReason":
            MessageLookupByLibrary.simpleMessage("Cancellation reason"),
        "chequeCancelReasonHint":
            MessageLookupByLibrary.simpleMessage("Select cancellation reason"),
        "chequeCancelReasonsPrompt": MessageLookupByLibrary.simpleMessage(
            "Select the cancellation reasons"),
        "chequeCancelReasonsStep":
            MessageLookupByLibrary.simpleMessage("Select cancellation reasons"),
        "chequeCancelRemove":
            MessageLookupByLibrary.simpleMessage("Yes, remove"),
        "chequeCancelRemovePrompt": MessageLookupByLibrary.simpleMessage(
            "Remove this cheque from the cancellation list?"),
        "chequeCancelReview":
            MessageLookupByLibrary.simpleMessage("Selected cheques"),
        "chequeCancelSayad": MessageLookupByLibrary.simpleMessage("Sayad ID"),
        "chequeCancelSearchHint": MessageLookupByLibrary.simpleMessage(
            "Search by cheque number or Sayad ID"),
        "chequeCancelSelectionNotice": MessageLookupByLibrary.simpleMessage(
            "Each request can include cheques from one deposit and one type (digital or paper)."),
        "chequeCancelSelectionPrompt": MessageLookupByLibrary.simpleMessage(
            "Select the deposit and type of cheques to cancel."),
        "chequeCancelSelectionStep": MessageLookupByLibrary.simpleMessage(
            "Select deposit and cheque type"),
        "chequeCancelTitle":
            MessageLookupByLibrary.simpleMessage("Cancel cheques"),
        "chequeCancelType": MessageLookupByLibrary.simpleMessage("Cheque type"),
        "chequeCancelTypeHint":
            MessageLookupByLibrary.simpleMessage("Select cheque type"),
        "chequeCityHint": MessageLookupByLibrary.simpleMessage("Select a city"),
        "chequeCityLabel": MessageLookupByLibrary.simpleMessage("City*"),
        "chequeCitySummary": MessageLookupByLibrary.simpleMessage("City"),
        "chequeClearanceIntro": MessageLookupByLibrary.simpleMessage(
            "Enter the cheque number, linked deposit and request reason."),
        "chequeClearanceTitle":
            MessageLookupByLibrary.simpleMessage("Clear cheque record"),
        "chequeConsentConditions":
            MessageLookupByLibrary.simpleMessage("View conditions"),
        "chequeConsentNotes": MessageLookupByLibrary.simpleMessage("Notes"),
        "chequeConsentNotice": MessageLookupByLibrary.simpleMessage(
            "The notarized consent must exactly match the attached conditions; otherwise it cannot be accepted."),
        "chequeConsentSample": MessageLookupByLibrary.simpleMessage(
            "Sample notarized consent text:"),
        "chequeContentUnavailable": MessageLookupByLibrary.simpleMessage(
            "This content is not ready yet."),
        "chequeDepositHint": MessageLookupByLibrary.simpleMessage(
            "Select the deposit linked to the cheque"),
        "chequeDepositLabel": MessageLookupByLibrary.simpleMessage("Deposit"),
        "chequeDocumentConsent":
            MessageLookupByLibrary.simpleMessage("Original notarized consent"),
        "chequeDocumentJudicial":
            MessageLookupByLibrary.simpleMessage("Original judicial letter"),
        "chequeDocumentOriginal":
            MessageLookupByLibrary.simpleMessage("Original cheque"),
        "chequeDocumentsTitle": MessageLookupByLibrary.simpleMessage(
            "Documents to deliver to the post office:"),
        "chequeDownloadSample":
            MessageLookupByLibrary.simpleMessage("Download sample"),
        "chequeJudicialNumber":
            MessageLookupByLibrary.simpleMessage("Judicial letter number"),
        "chequeJudicialNumberHint": MessageLookupByLibrary.simpleMessage(
            "Enter the judicial letter number"),
        "chequeJudicialNumberInvalid": MessageLookupByLibrary.simpleMessage(
            "Enter the judicial letter number using digits."),
        "chequeMailingAddressTitle": MessageLookupByLibrary.simpleMessage(
            "Address to write on the envelope for postal delivery:"),
        "chequeMailingInstruction": MessageLookupByLibrary.simpleMessage(
            "The post office will package the documents on delivery."),
        "chequeMockComplete": MessageLookupByLibrary.simpleMessage(
            "Demo request submitted; no real cheque record has been cleared."),
        "chequeNoPostRequired": MessageLookupByLibrary.simpleMessage(
            "No postal delivery is required."),
        "chequeNumberHint":
            MessageLookupByLibrary.simpleMessage("Enter the cheque number"),
        "chequeNumberInvalid": MessageLookupByLibrary.simpleMessage(
            "Enter the cheque number using digits and an optional /."),
        "chequeNumberLabel":
            MessageLookupByLibrary.simpleMessage("Cheque number"),
        "chequeNumberNotFound": MessageLookupByLibrary.simpleMessage(
            "The entered number is not in your cheque list"),
        "chequePostalAction": MessageLookupByLibrary.simpleMessage(
            "Find an authorized post office"),
        "chequePostalEmpty": MessageLookupByLibrary.simpleMessage(
            "No post office is available for this city in the demo data."),
        "chequePostalFailure": MessageLookupByLibrary.simpleMessage(
            "Could not retrieve post offices. Try again."),
        "chequePostalSearch": MessageLookupByLibrary.simpleMessage("Search"),
        "chequePostalSearchAgain":
            MessageLookupByLibrary.simpleMessage("Search again"),
        "chequePostalShare": MessageLookupByLibrary.simpleMessage("Share"),
        "chequePostalTitle": MessageLookupByLibrary.simpleMessage(
            "Nearest authorized post office"),
        "chequeProvinceHint":
            MessageLookupByLibrary.simpleMessage("Select a province"),
        "chequeProvinceLabel":
            MessageLookupByLibrary.simpleMessage("Province*"),
        "chequeProvinceSummary":
            MessageLookupByLibrary.simpleMessage("Province"),
        "chequeReasonConsent":
            MessageLookupByLibrary.simpleMessage("Notarized consent"),
        "chequeReasonDepositAndBlock": MessageLookupByLibrary.simpleMessage(
            "Deposit funds and block the amount"),
        "chequeReasonHint":
            MessageLookupByLibrary.simpleMessage("Select a request reason"),
        "chequeReasonJudicial":
            MessageLookupByLibrary.simpleMessage("Judicial letter"),
        "chequeReasonLabel":
            MessageLookupByLibrary.simpleMessage("Request reason"),
        "chequeReasonOlderThanThreeYears": MessageLookupByLibrary.simpleMessage(
            "Cheque record older than three years"),
        "chequeReasonOriginal":
            MessageLookupByLibrary.simpleMessage("Provide the original cheque"),
        "chequeReasonPartialPayment": MessageLookupByLibrary.simpleMessage(
            "Certificate of partial non-payment"),
        "chequeRequestComplete":
            MessageLookupByLibrary.simpleMessage("Request submitted."),
        "chequeShareUnavailable": MessageLookupByLibrary.simpleMessage(
            "Sharing is unavailable on this device."),
        "chequeSubmit":
            MessageLookupByLibrary.simpleMessage("Confirm and submit request"),
        "chequeSubmitFailure": MessageLookupByLibrary.simpleMessage(
            "The request could not be submitted. Try again."),
        "chequeTerms":
            MessageLookupByLibrary.simpleMessage("Terms and conditions"),
        "chequeTermsPrompt": MessageLookupByLibrary.simpleMessage(
            "I have read and accept this request."),
        "closeLabel": MessageLookupByLibrary.simpleMessage("Close"),
        "consolidateDepositCredit":
            MessageLookupByLibrary.simpleMessage("Consolidate deposit credit"),
        "dashboardAddFavorites":
            MessageLookupByLibrary.simpleMessage("Add favorite services"),
        "dashboardAddService":
            MessageLookupByLibrary.simpleMessage("Add a new service"),
        "dashboardAddresses":
            MessageLookupByLibrary.simpleMessage("Manage addresses"),
        "dashboardAgentSettings":
            MessageLookupByLibrary.simpleMessage("Agent settings"),
        "dashboardAllServices":
            MessageLookupByLibrary.simpleMessage("All services"),
        "dashboardAssistant":
            MessageLookupByLibrary.simpleMessage("AI assistant"),
        "dashboardBankServices":
            MessageLookupByLibrary.simpleMessage("Resalat Bank services"),
        "dashboardBlockDeposit":
            MessageLookupByLibrary.simpleMessage("Block deposit"),
        "dashboardCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "dashboardCancelCheque":
            MessageLookupByLibrary.simpleMessage("Cancel cheque"),
        "dashboardCardsList":
            MessageLookupByLibrary.simpleMessage("Cards list"),
        "dashboardCardsTab": MessageLookupByLibrary.simpleMessage("Cards"),
        "dashboardChangeIdentity":
            MessageLookupByLibrary.simpleMessage("Change identity details"),
        "dashboardChangePhone":
            MessageLookupByLibrary.simpleMessage("Change mobile number"),
        "dashboardChequeServices":
            MessageLookupByLibrary.simpleMessage("Cheques"),
        "dashboardClearCheque":
            MessageLookupByLibrary.simpleMessage("Clear cheque record"),
        "dashboardCloseExtras":
            MessageLookupByLibrary.simpleMessage("Close surplus deposits"),
        "dashboardConfirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "dashboardCorrectInstallments":
            MessageLookupByLibrary.simpleMessage("Correct paid installments"),
        "dashboardCustomize":
            MessageLookupByLibrary.simpleMessage("Customize services"),
        "dashboardDeferLoan":
            MessageLookupByLibrary.simpleMessage("Defer loan"),
        "dashboardDepositsList":
            MessageLookupByLibrary.simpleMessage("Deposits list"),
        "dashboardDepositsTab":
            MessageLookupByLibrary.simpleMessage("Deposits"),
        "dashboardEdit": MessageLookupByLibrary.simpleMessage("Edit"),
        "dashboardEmpty":
            MessageLookupByLibrary.simpleMessage("No information to display"),
        "dashboardEstimateCredit":
            MessageLookupByLibrary.simpleMessage("Estimate loan credit"),
        "dashboardExpiredGift": MessageLookupByLibrary.simpleMessage(
            "Transfer expired gift card balance"),
        "dashboardFavoritesLimit": MessageLookupByLibrary.simpleMessage(
            "You can select up to 8 services."),
        "dashboardGreeting":
            MessageLookupByLibrary.simpleMessage("Good morning, Mani"),
        "dashboardIdentityServices":
            MessageLookupByLibrary.simpleMessage("Personal information"),
        "dashboardLoadError": MessageLookupByLibrary.simpleMessage(
            "Could not load your information"),
        "dashboardLoading": MessageLookupByLibrary.simpleMessage("Loading…"),
        "dashboardLoanReport":
            MessageLookupByLibrary.simpleMessage("Loan referral report"),
        "dashboardLoansTab": MessageLookupByLibrary.simpleMessage("Loans"),
        "dashboardLocalTransfer":
            MessageLookupByLibrary.simpleMessage("On-site transfer"),
        "dashboardManageInstallments": MessageLookupByLibrary.simpleMessage(
            "Manage installment deductions"),
        "dashboardModernBanking":
            MessageLookupByLibrary.simpleMessage("Modern banking"),
        "dashboardMyLoans": MessageLookupByLibrary.simpleMessage("My loans"),
        "dashboardNoServices":
            MessageLookupByLibrary.simpleMessage("No services found"),
        "dashboardOccupation":
            MessageLookupByLibrary.simpleMessage("Manage occupation"),
        "dashboardOpenCurrent":
            MessageLookupByLibrary.simpleMessage("Open current account"),
        "dashboardPhoneBank":
            MessageLookupByLibrary.simpleMessage("Phone banking"),
        "dashboardPromptCard": MessageLookupByLibrary.simpleMessage(
            "How do I get a Resalat card?"),
        "dashboardPromptCertificate": MessageLookupByLibrary.simpleMessage(
            "I need a financial certificate…"),
        "dashboardPromptHint":
            MessageLookupByLibrary.simpleMessage("Write your question..."),
        "dashboardRemoveService":
            MessageLookupByLibrary.simpleMessage("Remove"),
        "dashboardRequestDate":
            MessageLookupByLibrary.simpleMessage("2024/09/16 | 12:45"),
        "dashboardRequestNumber":
            MessageLookupByLibrary.simpleMessage("137/487567"),
        "dashboardRequestServices":
            MessageLookupByLibrary.simpleMessage("My requests"),
        "dashboardRequestTitle": MessageLookupByLibrary.simpleMessage(
            "Request to change the installment deposit"),
        "dashboardRequests":
            MessageLookupByLibrary.simpleMessage("My requests"),
        "dashboardResetConfirm":
            MessageLookupByLibrary.simpleMessage("Reset settings"),
        "dashboardResetDescription": MessageLookupByLibrary.simpleMessage(
            "Resetting settings removes your changes and restores the original configuration.\nAre you sure you want to reset?"),
        "dashboardResetTitle":
            MessageLookupByLibrary.simpleMessage("Reset settings"),
        "dashboardResoDescription": MessageLookupByLibrary.simpleMessage(
            "Reso does more than answer; it takes action."),
        "dashboardResoTitle":
            MessageLookupByLibrary.simpleMessage("Leave it to Reso!"),
        "dashboardRetry": MessageLookupByLibrary.simpleMessage("Try again"),
        "dashboardSearchHint": MessageLookupByLibrary.simpleMessage("Search"),
        "dashboardSendPrompt":
            MessageLookupByLibrary.simpleMessage("Send question"),
        "dashboardTab": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "dashboardTransferServices":
            MessageLookupByLibrary.simpleMessage("Transfers"),
        "dashboardUnblockCard":
            MessageLookupByLibrary.simpleMessage("Unblock card"),
        "dashboardUnblockDeposit":
            MessageLookupByLibrary.simpleMessage("Unblock deposit"),
        "dashboardViewAll": MessageLookupByLibrary.simpleMessage("View all"),
        "dashboardVirtualCard":
            MessageLookupByLibrary.simpleMessage("Request virtual card"),
        "dashboardWalletBalance":
            MessageLookupByLibrary.simpleMessage("1,200,000"),
        "dashboardWalletCharge":
            MessageLookupByLibrary.simpleMessage("Add funds"),
        "dashboardWalletDeposit": MessageLookupByLibrary.simpleMessage(
            "Change linked wallet deposit"),
        "dashboardWalletHistory":
            MessageLookupByLibrary.simpleMessage("Wallet history"),
        "dashboardWalletInfo":
            MessageLookupByLibrary.simpleMessage("Wallet information"),
        "dashboardWalletServices":
            MessageLookupByLibrary.simpleMessage("Wallet"),
        "dashboardWalletTransfer":
            MessageLookupByLibrary.simpleMessage("Wallet to wallet transfer"),
        "dashboardWalletWithdraw":
            MessageLookupByLibrary.simpleMessage("Withdraw funds"),
        "dashboardWelcomeMessage": MessageLookupByLibrary.simpleMessage(
            "Welcome to the Resalat Virtual Counter"),
        "dashboardYourFavorites":
            MessageLookupByLibrary.simpleMessage("Your favorites"),
        "depositBlockIntro": MessageLookupByLibrary.simpleMessage(
            "Select a deposit and the reason for blocking it"),
        "depositBlockTitle":
            MessageLookupByLibrary.simpleMessage("Block deposit"),
        "depositBlockedDate":
            MessageLookupByLibrary.simpleMessage("Date blocked"),
        "depositBlockedReason":
            MessageLookupByLibrary.simpleMessage("Blocking reason"),
        "depositListAccountDetails":
            MessageLookupByLibrary.simpleMessage("Account details"),
        "depositListAccountType":
            MessageLookupByLibrary.simpleMessage("Account type"),
        "depositListBlock":
            MessageLookupByLibrary.simpleMessage("Deposit blocking"),
        "depositListBlocked": MessageLookupByLibrary.simpleMessage("Blocked"),
        "depositListClosed": MessageLookupByLibrary.simpleMessage("Closed"),
        "depositListCurrent":
            MessageLookupByLibrary.simpleMessage("Personal current account"),
        "depositListCustomerInformation":
            MessageLookupByLibrary.simpleMessage("Customer information"),
        "depositListLinkedCards":
            MessageLookupByLibrary.simpleMessage("Cards linked to account"),
        "depositListNationalId":
            MessageLookupByLibrary.simpleMessage("National ID"),
        "depositListNoMatches": MessageLookupByLibrary.simpleMessage(
            "No deposits match these filters."),
        "depositListNoOwners": MessageLookupByLibrary.simpleMessage(
            "Account owner information is unavailable."),
        "depositListNumber":
            MessageLookupByLibrary.simpleMessage("Deposit number"),
        "depositListOpen": MessageLookupByLibrary.simpleMessage("Open"),
        "depositListOwner":
            MessageLookupByLibrary.simpleMessage("Deposit owner"),
        "depositListOwnerAndSignatory":
            MessageLookupByLibrary.simpleMessage("Owner and signatory"),
        "depositListOwnerName": MessageLookupByLibrary.simpleMessage("Name"),
        "depositListOwnerPercent":
            MessageLookupByLibrary.simpleMessage("Share"),
        "depositListOwnerRole": MessageLookupByLibrary.simpleMessage("Role"),
        "depositListSavings":
            MessageLookupByLibrary.simpleMessage("Personal savings"),
        "depositListServiceUnavailable": MessageLookupByLibrary.simpleMessage(
            "This service will be available after bank integration."),
        "depositListSignatory":
            MessageLookupByLibrary.simpleMessage("Signatory"),
        "depositListSms":
            MessageLookupByLibrary.simpleMessage("SMS delivery settings"),
        "depositListStatement":
            MessageLookupByLibrary.simpleMessage("Statement | Average balance"),
        "depositListStatus": MessageLookupByLibrary.simpleMessage("Status"),
        "depositRestrictionDescription":
            MessageLookupByLibrary.simpleMessage("Description"),
        "depositRestrictionDescriptionHint":
            MessageLookupByLibrary.simpleMessage(
                "Enter a description if needed"),
        "depositRestrictionManagement":
            MessageLookupByLibrary.simpleMessage("Deposit management"),
        "depositRestrictionMockComplete": MessageLookupByLibrary.simpleMessage(
            "The request was simulated. No real deposit or wallet has changed."),
        "depositRestrictionReason":
            MessageLookupByLibrary.simpleMessage("Request reason"),
        "depositRestrictionReasonHint":
            MessageLookupByLibrary.simpleMessage("Select the request reason"),
        "depositServices":
            MessageLookupByLibrary.simpleMessage("Deposit services"),
        "depositUnblockIntro": MessageLookupByLibrary.simpleMessage(
            "Select a deposit and the reason for unblocking it"),
        "depositUnblockReason":
            MessageLookupByLibrary.simpleMessage("Unblocking reason"),
        "depositUnblockTitle":
            MessageLookupByLibrary.simpleMessage("Unblock deposit"),
        "depositsAgent": MessageLookupByLibrary.simpleMessage("Agent settings"),
        "depositsChequeOperations":
            MessageLookupByLibrary.simpleMessage("Cheque operations"),
        "depositsCopyNumber":
            MessageLookupByLibrary.simpleMessage("Copy deposit number"),
        "depositsEmpty":
            MessageLookupByLibrary.simpleMessage("No deposits yet"),
        "depositsLinkedCards":
            MessageLookupByLibrary.simpleMessage("Linked cards"),
        "depositsLinkedLoans":
            MessageLookupByLibrary.simpleMessage("Linked loan status"),
        "depositsLocalTransfer":
            MessageLookupByLibrary.simpleMessage("On-site transfer"),
        "depositsMobileBank":
            MessageLookupByLibrary.simpleMessage("Mobile banking"),
        "depositsMyTitle": MessageLookupByLibrary.simpleMessage("My deposits"),
        "depositsOperations":
            MessageLookupByLibrary.simpleMessage("Deposit operations"),
        "enterDashboard":
            MessageLookupByLibrary.simpleMessage("Enter the counter"),
        "financialAuthority": MessageLookupByLibrary.simpleMessage("Authority"),
        "financialAuthorityHint": MessageLookupByLibrary.simpleMessage(
            "Enter the exact authority name"),
        "financialAverageBalanceCondition":
            MessageLookupByLibrary.simpleMessage("Include average balance"),
        "financialCertificate":
            MessageLookupByLibrary.simpleMessage("Financial certificate"),
        "financialCertificateTitle": MessageLookupByLibrary.simpleMessage(
            "Financial solvency certificate request"),
        "financialCurrency":
            MessageLookupByLibrary.simpleMessage("Equivalent currency"),
        "financialCurrencyHint": MessageLookupByLibrary.simpleMessage(
            "Select currency for the solvency certificate"),
        "financialDebitCredit": MessageLookupByLibrary.simpleMessage(
            "Include debit and credit turnover"),
        "financialDeliveryStep": MessageLookupByLibrary.simpleMessage(
            "Certificate delivery information"),
        "financialEmbassy": MessageLookupByLibrary.simpleMessage("Embassy"),
        "financialEmbassyHint":
            MessageLookupByLibrary.simpleMessage("Select embassy"),
        "financialEur": MessageLookupByLibrary.simpleMessage("Euro"),
        "financialExchangeRate": MessageLookupByLibrary.simpleMessage(
            "Include current exchange rate"),
        "financialExpiryHint": MessageLookupByLibrary.simpleMessage(
            "Passport expiry date (YYYY/MM/DD)"),
        "financialFatherHint": MessageLookupByLibrary.simpleMessage(
            "Father\'s name in English as shown on passport"),
        "financialHomeAddress":
            MessageLookupByLibrary.simpleMessage("Home address"),
        "financialIrr": MessageLookupByLibrary.simpleMessage("Iranian rial"),
        "financialLatinAddress":
            MessageLookupByLibrary.simpleMessage("Address"),
        "financialLatinAddressHint": MessageLookupByLibrary.simpleMessage(
            "Unit, No, Alley, St, City, Province, Country, Postal code"),
        "financialLatinAddressPrompt": MessageLookupByLibrary.simpleMessage(
            "Enter your address in English for the solvency certificate, following the sample format."),
        "financialLatinExpiry":
            MessageLookupByLibrary.simpleMessage("Date of Expiry"),
        "financialLatinFather":
            MessageLookupByLibrary.simpleMessage("Father\'s name"),
        "financialLatinName": MessageLookupByLibrary.simpleMessage("Name"),
        "financialLatinPassport":
            MessageLookupByLibrary.simpleMessage("Passport No"),
        "financialLatinStep": MessageLookupByLibrary.simpleMessage(
            "Personal information in Latin letters"),
        "financialLatinSurname":
            MessageLookupByLibrary.simpleMessage("Surname"),
        "financialMaturityDate":
            MessageLookupByLibrary.simpleMessage("Deposit maturity date"),
        "financialNameHint": MessageLookupByLibrary.simpleMessage(
            "Name in English as shown on passport"),
        "financialOpenedAt": MessageLookupByLibrary.simpleMessage(
            "Include original deposit opening date"),
        "financialOtherAuthority":
            MessageLookupByLibrary.simpleMessage("Other authorities"),
        "financialPassportHint":
            MessageLookupByLibrary.simpleMessage("Passport number in English"),
        "financialPassportNumberCondition":
            MessageLookupByLibrary.simpleMessage(
                "Passport number / registration number"),
        "financialPassportPrompt": MessageLookupByLibrary.simpleMessage(
            "Enter the following information as shown on your passport."),
        "financialRecipient": MessageLookupByLibrary.simpleMessage("Recipient"),
        "financialRecipientHint": MessageLookupByLibrary.simpleMessage(
            "Select certificate recipient"),
        "financialRecipientPrompt": MessageLookupByLibrary.simpleMessage(
            "Select the certificate recipient and equivalent currency"),
        "financialRecipientStep": MessageLookupByLibrary.simpleMessage(
            "Certificate recipient and currency"),
        "financialSurnameHint": MessageLookupByLibrary.simpleMessage(
            "Surname in English as shown on passport"),
        "financialUsd": MessageLookupByLibrary.simpleMessage("US dollar"),
        "financialWithdrawalRules": MessageLookupByLibrary.simpleMessage(
            "Withdrawal conditions for joint / corporate deposits"),
        "flowExitTitle":
            MessageLookupByLibrary.simpleMessage("Leave this operation?"),
        "giftBalanceCount":
            MessageLookupByLibrary.simpleMessage("Expired gift card count"),
        "giftBalanceDepositHint":
            MessageLookupByLibrary.simpleMessage("Select destination deposit"),
        "giftBalanceDestination":
            MessageLookupByLibrary.simpleMessage("Select destination deposit"),
        "giftBalanceEnd": MessageLookupByLibrary.simpleMessage("End"),
        "giftBalanceIntro":
            MessageLookupByLibrary.simpleMessage("Select expired gift cards"),
        "giftBalanceNext": MessageLookupByLibrary.simpleMessage("Next step"),
        "giftBalanceNextDestination": MessageLookupByLibrary.simpleMessage(
            "Next: select destination deposit"),
        "giftBalanceRemaining":
            MessageLookupByLibrary.simpleMessage("Remaining balance (rial)"),
        "giftBalanceRemoveCard": m1,
        "giftBalanceSearch":
            MessageLookupByLibrary.simpleMessage("Search by card number"),
        "giftBalanceSelectAll":
            MessageLookupByLibrary.simpleMessage("Select all"),
        "giftBalanceSelectedList": m2,
        "giftBalanceSelection":
            MessageLookupByLibrary.simpleMessage("Select cards"),
        "giftBalanceSubmit":
            MessageLookupByLibrary.simpleMessage("Submit request"),
        "giftBalanceTitle": MessageLookupByLibrary.simpleMessage(
            "Transfer expired gift card balance"),
        "giftBalanceTotal":
            MessageLookupByLibrary.simpleMessage("Total amount (rial)"),
        "giftBalanceTransferTo":
            MessageLookupByLibrary.simpleMessage("Transfer to"),
        "guestServices": MessageLookupByLibrary.simpleMessage(
            "Services available without signing in"),
        "inheritance":
            MessageLookupByLibrary.simpleMessage("Inheritance monopoly"),
        "internetBank":
            MessageLookupByLibrary.simpleMessage("Internet banking"),
        "internetBankSettings":
            MessageLookupByLibrary.simpleMessage("Internet bank settings"),
        "introduceAgent":
            MessageLookupByLibrary.simpleMessage("Introduce agent"),
        "introduceLoan": MessageLookupByLibrary.simpleMessage("Introduce loan"),
        "issuanceAddAddress":
            MessageLookupByLibrary.simpleMessage("Add a new address"),
        "issuanceAddress": MessageLookupByLibrary.simpleMessage("Address"),
        "issuanceAddressDetail":
            MessageLookupByLibrary.simpleMessage("Full address"),
        "issuanceAddressHint": MessageLookupByLibrary.simpleMessage(
            "Select the card delivery address"),
        "issuanceAddressInvalid": MessageLookupByLibrary.simpleMessage(
            "Enter a label, full address and a 10-digit postal code."),
        "issuanceAddressTitle":
            MessageLookupByLibrary.simpleMessage("Address label"),
        "issuanceAgentCode": MessageLookupByLibrary.simpleMessage("Agent code"),
        "issuanceAgentName":
            MessageLookupByLibrary.simpleMessage("Agent full name"),
        "issuanceComplete":
            MessageLookupByLibrary.simpleMessage("Request submitted."),
        "issuanceConfirmTitle": MessageLookupByLibrary.simpleMessage(
            "Confirm information and pay fees"),
        "issuanceCurrentCard":
            MessageLookupByLibrary.simpleMessage("Current card number"),
        "issuanceDeleteAddress":
            MessageLookupByLibrary.simpleMessage("Delete address"),
        "issuanceDeliveryFee":
            MessageLookupByLibrary.simpleMessage("Delivery fee"),
        "issuanceDeliveryTitle":
            MessageLookupByLibrary.simpleMessage("Card delivery information"),
        "issuanceDeposit":
            MessageLookupByLibrary.simpleMessage("Select account"),
        "issuanceDepositHint": MessageLookupByLibrary.simpleMessage(
            "Select the account you want to use"),
        "issuanceDepositNumber":
            MessageLookupByLibrary.simpleMessage("Account number"),
        "issuanceDone": MessageLookupByLibrary.simpleMessage("Back"),
        "issuanceEmpty": MessageLookupByLibrary.simpleMessage(
            "No eligible account is available for card issuance."),
        "issuanceEnd": MessageLookupByLibrary.simpleMessage("End"),
        "issuanceExistingNumber": MessageLookupByLibrary.simpleMessage(
            "Issue a card with the current number"),
        "issuanceExpiry": MessageLookupByLibrary.simpleMessage("Expiry date"),
        "issuanceIdentityFee":
            MessageLookupByLibrary.simpleMessage("Identity verification fee"),
        "issuanceIncludeAgent":
            MessageLookupByLibrary.simpleMessage("Enter bank agent details"),
        "issuanceMockComplete": MessageLookupByLibrary.simpleMessage(
            "Request preview completed; no payment or card issuance was performed."),
        "issuanceNationalId":
            MessageLookupByLibrary.simpleMessage("Recipient national ID"),
        "issuanceNewNumber": MessageLookupByLibrary.simpleMessage(
            "Issue a card with a new number"),
        "issuanceNext": MessageLookupByLibrary.simpleMessage("Next step"),
        "issuanceNextConfirm":
            MessageLookupByLibrary.simpleMessage("Next: confirmation and fees"),
        "issuanceNextDelivery": MessageLookupByLibrary.simpleMessage(
            "Next: card delivery information"),
        "issuanceNoPhysical": MessageLookupByLibrary.simpleMessage(
            "I do not need a physical card"),
        "issuanceOperation":
            MessageLookupByLibrary.simpleMessage("Operation type"),
        "issuanceOtherRecipient": MessageLookupByLibrary.simpleMessage(
            "Receive through another person"),
        "issuancePayable":
            MessageLookupByLibrary.simpleMessage("Amount payable"),
        "issuancePostalCode":
            MessageLookupByLibrary.simpleMessage("Postal code"),
        "issuancePrintFee":
            MessageLookupByLibrary.simpleMessage("Report printing fee"),
        "issuanceRecipientMobile":
            MessageLookupByLibrary.simpleMessage("Recipient mobile number"),
        "issuanceRecipientName":
            MessageLookupByLibrary.simpleMessage("Recipient full name"),
        "issuanceSaveAddress":
            MessageLookupByLibrary.simpleMessage("Save address"),
        "issuanceSelectAddress":
            MessageLookupByLibrary.simpleMessage("Select address"),
        "issuanceSelectionTitle": MessageLookupByLibrary.simpleMessage(
            "Select account and issuance type"),
        "issuanceStepSemantic": m3,
        "issuanceSubmit":
            MessageLookupByLibrary.simpleMessage("Confirm and submit request"),
        "issuanceSubmitError": MessageLookupByLibrary.simpleMessage(
            "The request could not be submitted. Try again."),
        "issuanceSummary":
            MessageLookupByLibrary.simpleMessage("Information summary"),
        "issuanceTerms":
            MessageLookupByLibrary.simpleMessage("Terms and conditions"),
        "issuanceTermsPrompt": MessageLookupByLibrary.simpleMessage(
            "I have read and accept the request terms."),
        "issuanceTermsUnavailable": MessageLookupByLibrary.simpleMessage(
            "Official terms will be provided by the service integration."),
        "issuanceTitle":
            MessageLookupByLibrary.simpleMessage("Resalat card issuance"),
        "issuanceType":
            MessageLookupByLibrary.simpleMessage("Card issuance type"),
        "issuanceTypeHint":
            MessageLookupByLibrary.simpleMessage("Select an issuance type"),
        "issuanceWallet":
            MessageLookupByLibrary.simpleMessage("Wallet balance"),
        "issuanceWalletInsufficient": MessageLookupByLibrary.simpleMessage(
            "Wallet balance is insufficient"),
        "issuanceWalletSufficient": MessageLookupByLibrary.simpleMessage(
            "Wallet balance is sufficient"),
        "issueChequeBook":
            MessageLookupByLibrary.simpleMessage("Issue cheque book"),
        "issueResalatCard":
            MessageLookupByLibrary.simpleMessage("Issue Resalat card"),
        "latestUpdatedRequests":
            MessageLookupByLibrary.simpleMessage("Latest updated requests"),
        "loanEstimate": MessageLookupByLibrary.simpleMessage("Loan estimate"),
        "loanServices": MessageLookupByLibrary.simpleMessage("Loan services"),
        "loansChangeDeposit": MessageLookupByLibrary.simpleMessage(
            "Change installment debit deposit"),
        "loansDefaultName": MessageLookupByLibrary.simpleMessage(
            "Standard Qarz al-Hasaneh loan (no fee)"),
        "loansEmpty": MessageLookupByLibrary.simpleMessage("No loans yet"),
        "loansOperations":
            MessageLookupByLibrary.simpleMessage("Loan operations"),
        "loansPayInstallments":
            MessageLookupByLibrary.simpleMessage("Pay installments"),
        "loansRelationships":
            MessageLookupByLibrary.simpleMessage("Family relationships"),
        "loginDescription": MessageLookupByLibrary.simpleMessage(
            "Enter the following information to sign in to your account"),
        "loginNationalIdHint": MessageLookupByLibrary.simpleMessage(
            "National ID | Identity number | Foreigner code"),
        "loginPhoneHint":
            MessageLookupByLibrary.simpleMessage("Enter your mobile number"),
        "loginTitle":
            MessageLookupByLibrary.simpleMessage("Sign in with national ID"),
        "memberContactCenter":
            MessageLookupByLibrary.simpleMessage("Member contact center"),
        "mobileBank": MessageLookupByLibrary.simpleMessage("Mobile banking"),
        "mobileBankSettings":
            MessageLookupByLibrary.simpleMessage("Mobile bank settings"),
        "notificationEmpty":
            MessageLookupByLibrary.simpleMessage("No messages"),
        "notificationFiveDays":
            MessageLookupByLibrary.simpleMessage("5 days ago"),
        "notificationInvestmentSubtitle": MessageLookupByLibrary.simpleMessage(
            "Easy, fast gold trading with instant settlement"),
        "notificationInvestmentTitle":
            MessageLookupByLibrary.simpleMessage("Invest in gold"),
        "notificationLoanSubtitle":
            MessageLookupByLibrary.simpleMessage("Secured loan"),
        "notificationLoanTitle":
            MessageLookupByLibrary.simpleMessage("Borrow against your savings"),
        "notificationNew": MessageLookupByLibrary.simpleMessage("New messages"),
        "notificationRead":
            MessageLookupByLibrary.simpleMessage("Read messages"),
        "notificationReadAll": MessageLookupByLibrary.simpleMessage("Read all"),
        "notificationSampleDate":
            MessageLookupByLibrary.simpleMessage("16 Shahrivar 1405"),
        "notificationSecurityAdvice": MessageLookupByLibrary.simpleMessage(
            "To avoid scams and keep your account safe, remember:"),
        "notificationSecurityClosing": MessageLookupByLibrary.simpleMessage(
            "If you notice anything suspicious, let us know so we can check it promptly."),
        "notificationSecurityCode": MessageLookupByLibrary.simpleMessage(
            "Never share your login code: our support team will never ask for your password or verification code."),
        "notificationSecurityIntro": MessageLookupByLibrary.simpleMessage(
            "Hi! You may receive messages from scammers pretending to be our support team. Keep these tips in mind to protect your account:"),
        "notificationSecurityLinks": MessageLookupByLibrary.simpleMessage(
            "Do not open suspicious links: avoid unknown links claiming your account is blocked or that you won a prize."),
        "notificationSecurityOfficial": MessageLookupByLibrary.simpleMessage(
            "Use official channels: make sure messages come from our official numbers or accounts."),
        "notificationSecuritySubtitle": MessageLookupByLibrary.simpleMessage(
            "Tips to keep your account secure"),
        "notificationSecurityTitle":
            MessageLookupByLibrary.simpleMessage("Watch out for scammers ⚠️"),
        "notificationSevenDays":
            MessageLookupByLibrary.simpleMessage("7 days ago"),
        "notificationSubject": MessageLookupByLibrary.simpleMessage("Subject"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Notifications"),
        "notificationToday": MessageLookupByLibrary.simpleMessage("Today"),
        "notificationYesterday":
            MessageLookupByLibrary.simpleMessage("Yesterday"),
        "notificationsLabel":
            MessageLookupByLibrary.simpleMessage("Notifications"),
        "otpHint": MessageLookupByLibrary.simpleMessage("Enter the code"),
        "otpSentMessage": m4,
        "otpSentTitle": MessageLookupByLibrary.simpleMessage("Code sent."),
        "passwordApprovedBody": MessageLookupByLibrary.simpleMessage(
            "An SMS containing mobile banking credentials will be sent. You can sign in using the credentials in that message."),
        "passwordApprovedTitle": MessageLookupByLibrary.simpleMessage(
            "Your request was completed successfully"),
        "passwordCameraNotice": MessageLookupByLibrary.simpleMessage(
            "This step requires a camera and microphone."),
        "passwordCardNumber":
            MessageLookupByLibrary.simpleMessage("Card number"),
        "passwordCardNumberHint":
            MessageLookupByLibrary.simpleMessage("Select the card number"),
        "passwordCardType": MessageLookupByLibrary.simpleMessage("Card type"),
        "passwordCardTypeHint":
            MessageLookupByLibrary.simpleMessage("Select your card type"),
        "passwordChange":
            MessageLookupByLibrary.simpleMessage("Change password"),
        "passwordChangePrompt": MessageLookupByLibrary.simpleMessage(
            "Enter your current password and your chosen new password."),
        "passwordChangeSubmit":
            MessageLookupByLibrary.simpleMessage("Submit request"),
        "passwordChangeSuccessBody": MessageLookupByLibrary.simpleMessage(
            "Your password change was successful."),
        "passwordConfirmMock":
            MessageLookupByLibrary.simpleMessage("Confirm demo preview"),
        "passwordConfirmationHint":
            MessageLookupByLibrary.simpleMessage("Repeat password"),
        "passwordCurrentHint":
            MessageLookupByLibrary.simpleMessage("Current password"),
        "passwordDateRule": MessageLookupByLibrary.simpleMessage(
            "Avoid meaningful dates (birth date, card expiry)"),
        "passwordDemoVideo": MessageLookupByLibrary.simpleMessage(
            "Demo video: Big Buck Bunny — Blender Foundation (CC BY 3.0)"),
        "passwordExit": MessageLookupByLibrary.simpleMessage("Leave"),
        "passwordExitBody": MessageLookupByLibrary.simpleMessage(
            "Entered information will be cleared."),
        "passwordExitTitle":
            MessageLookupByLibrary.simpleMessage("Leave password setup?"),
        "passwordFirst": MessageLookupByLibrary.simpleMessage("First PIN"),
        "passwordFirstDescription": MessageLookupByLibrary.simpleMessage(
            "For in-person ATM and point-of-sale transactions."),
        "passwordForgot":
            MessageLookupByLibrary.simpleMessage("Forgot password"),
        "passwordHide": MessageLookupByLibrary.simpleMessage("Hide password"),
        "passwordInstructionPrompt": MessageLookupByLibrary.simpleMessage(
            "After watching the instructional video, identity verification begins."),
        "passwordLengthRule":
            MessageLookupByLibrary.simpleMessage("Use 4 to 6 digits"),
        "passwordMismatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match."),
        "passwordMockKyc": MessageLookupByLibrary.simpleMessage(
            "Demo recording and KYC: no video of you is captured."),
        "passwordMockReceipt": MessageLookupByLibrary.simpleMessage(
            "Demo result: no bank password has been set and no SMS is sent."),
        "passwordNewConfirmationHint":
            MessageLookupByLibrary.simpleMessage("Confirm new password"),
        "passwordNewHint": MessageLookupByLibrary.simpleMessage("New password"),
        "passwordOperation": MessageLookupByLibrary.simpleMessage("Operation"),
        "passwordOperationHint":
            MessageLookupByLibrary.simpleMessage("Select an operation"),
        "passwordPatternRule": MessageLookupByLibrary.simpleMessage(
            "Avoid sequential or repeating numbers"),
        "passwordPause": MessageLookupByLibrary.simpleMessage("Pause video"),
        "passwordPendingBody": MessageLookupByLibrary.simpleMessage(
            "• After validation, if identity is confirmed, an SMS containing password information will be sent.\n• During the validation period, other counter services requiring verification can be used without paying again."),
        "passwordPendingTitle": MessageLookupByLibrary.simpleMessage(
            "You have an open validation request"),
        "passwordPlay": MessageLookupByLibrary.simpleMessage("Play video"),
        "passwordPrompt": MessageLookupByLibrary.simpleMessage(
            "Enter your preferred second password."),
        "passwordRecordAgain":
            MessageLookupByLibrary.simpleMessage("Record again"),
        "passwordRecordingPrompt": MessageLookupByLibrary.simpleMessage(
            "Confirm the video and submit your request."),
        "passwordSecond":
            MessageLookupByLibrary.simpleMessage("Second password"),
        "passwordSecondDescription": MessageLookupByLibrary.simpleMessage(
            "For online transactions below 100,000 tomans."),
        "passwordSeek":
            MessageLookupByLibrary.simpleMessage("Playback position"),
        "passwordSelectionPrompt": MessageLookupByLibrary.simpleMessage(
            "Select the card and password type"),
        "passwordSerialError": MessageLookupByLibrary.simpleMessage(
            "Enter digits and exactly one Latin letter."),
        "passwordSerialHelper": MessageLookupByLibrary.simpleMessage(
            "Contains digits and one Latin letter"),
        "passwordSerialHint": MessageLookupByLibrary.simpleMessage(
            "National ID serial | receipt tracking code"),
        "passwordSerialPrompt": MessageLookupByLibrary.simpleMessage(
            "Enter the serial on the back of your national ID card or its receipt tracking code."),
        "passwordSetSecond":
            MessageLookupByLibrary.simpleMessage("Set second password"),
        "passwordShow": MessageLookupByLibrary.simpleMessage("Show password"),
        "passwordStartKyc":
            MessageLookupByLibrary.simpleMessage("Start identity verification"),
        "passwordStatusRegisteredTitle": MessageLookupByLibrary.simpleMessage(
            "Your request was registered successfully."),
        "passwordStay": MessageLookupByLibrary.simpleMessage("Continue setup"),
        "passwordSubmit":
            MessageLookupByLibrary.simpleMessage("Send and submit request"),
        "passwordSubmittedBody": MessageLookupByLibrary.simpleMessage(
            "After validation and identity approval, an SMS containing mobile banking credentials will be sent. You can then sign in using those credentials."),
        "passwordSubmittedTitle":
            MessageLookupByLibrary.simpleMessage("Your request was sent"),
        "passwordTitle":
            MessageLookupByLibrary.simpleMessage("Password services"),
        "passwordTracking":
            MessageLookupByLibrary.simpleMessage("Tracking code"),
        "passwordType": MessageLookupByLibrary.simpleMessage("Password type"),
        "passwordTypeHint":
            MessageLookupByLibrary.simpleMessage("Select the password type"),
        "passwordUnderstood":
            MessageLookupByLibrary.simpleMessage("Understood"),
        "passwordUnsupported": MessageLookupByLibrary.simpleMessage(
            "This operation is unavailable for the selected card."),
        "passwordValueHint": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordVideoUnavailable":
            MessageLookupByLibrary.simpleMessage("Video unavailable"),
        "phoneOwnershipNotice": MessageLookupByLibrary.simpleMessage(
            "The number must match the account holder\'s national ID"),
        "profileAddAddress":
            MessageLookupByLibrary.simpleMessage("Add new address"),
        "profileAddOccupation":
            MessageLookupByLibrary.simpleMessage("Add new occupation"),
        "profileAddressType":
            MessageLookupByLibrary.simpleMessage("Address type"),
        "profileAddressesEmpty":
            MessageLookupByLibrary.simpleMessage("No addresses yet"),
        "profileChangePhone":
            MessageLookupByLibrary.simpleMessage("Change mobile number"),
        "profileCurrentPhone":
            MessageLookupByLibrary.simpleMessage("Current number"),
        "profileDeleteAddress":
            MessageLookupByLibrary.simpleMessage("Delete address"),
        "profileDeleteOccupation":
            MessageLookupByLibrary.simpleMessage("Delete occupation"),
        "profileDeleteOccupationPrompt": m5,
        "profileDescription":
            MessageLookupByLibrary.simpleMessage("Description"),
        "profileDescriptionRequired": MessageLookupByLibrary.simpleMessage(
            "Enter an occupation description"),
        "profileDesigner": MessageLookupByLibrary.simpleMessage("Designer"),
        "profileEditAddress":
            MessageLookupByLibrary.simpleMessage("Edit address"),
        "profileEditOccupation":
            MessageLookupByLibrary.simpleMessage("Edit occupation"),
        "profileHome": MessageLookupByLibrary.simpleMessage("Home"),
        "profileHomemaker": MessageLookupByLibrary.simpleMessage("Homemaker"),
        "profileLabel": MessageLookupByLibrary.simpleMessage("Profile"),
        "profileMinimumAddress": MessageLookupByLibrary.simpleMessage(
            "At least one home address is required. Register another home address before changing this address to work or deleting it."),
        "profileMinimumOccupation": MessageLookupByLibrary.simpleMessage(
            "At least one registered occupation is required. You can edit this occupation instead of deleting it."),
        "profileMissingResidence":
            MessageLookupByLibrary.simpleMessage("Not in residence registry"),
        "profileNewPhone": MessageLookupByLibrary.simpleMessage("New number"),
        "profileNewPhoneHint": MessageLookupByLibrary.simpleMessage(
            "Enter your new mobile number"),
        "profileOccupation": MessageLookupByLibrary.simpleMessage("Occupation"),
        "profileOccupationConflict": m6,
        "profileOccupationDescription":
            MessageLookupByLibrary.simpleMessage("Occupation description"),
        "profileOccupationDescriptionHint":
            MessageLookupByLibrary.simpleMessage(
                "Enter your occupation description"),
        "profileOccupationHint":
            MessageLookupByLibrary.simpleMessage("Select your occupation"),
        "profileOccupationNotice": MessageLookupByLibrary.simpleMessage(
            "Your new occupation will be visible within 3 hours after submitting the request."),
        "profileOccupationQueued": MessageLookupByLibrary.simpleMessage(
            "Your occupation request was submitted and will appear after review."),
        "profileOccupationReview": m7,
        "profileOccupationsEmpty":
            MessageLookupByLibrary.simpleMessage("No occupations yet"),
        "profileOperationError": MessageLookupByLibrary.simpleMessage(
            "The operation failed. Please try again."),
        "profileOtpExpired": MessageLookupByLibrary.simpleMessage(
            "The code has expired. Request another code."),
        "profileOtpHint": MessageLookupByLibrary.simpleMessage("Enter code"),
        "profileOtpInvalid":
            MessageLookupByLibrary.simpleMessage("The code is incorrect."),
        "profilePhoneNotice": MessageLookupByLibrary.simpleMessage(
            "The number must belong to the account holder’s national ID."),
        "profilePhoneSubmitted": MessageLookupByLibrary.simpleMessage(
            "Your mobile number change request was submitted."),
        "profilePostalAddress":
            MessageLookupByLibrary.simpleMessage("Postal code:"),
        "profileProfessor": MessageLookupByLibrary.simpleMessage("Professor"),
        "profileQuerying": MessageLookupByLibrary.simpleMessage("Checking…"),
        "profileRequestOtp":
            MessageLookupByLibrary.simpleMessage("Request OTP"),
        "profileResidenceNotice": MessageLookupByLibrary.simpleMessage(
            "To request services such as a cheque book or current account, your residential address must be registered in the"),
        "profileResidenceRegistered": MessageLookupByLibrary.simpleMessage("."),
        "profileResidenceRegistry": MessageLookupByLibrary.simpleMessage(
            " residence and property registry"),
        "profileResidenceStatus":
            MessageLookupByLibrary.simpleMessage("Residence registry status"),
        "profileReview": MessageLookupByLibrary.simpleMessage("Review"),
        "profileReviewError": MessageLookupByLibrary.simpleMessage(
            "The inquiry failed. Please retry."),
        "profileSecondPassword":
            MessageLookupByLibrary.simpleMessage("Second password"),
        "profileShahkarFee":
            MessageLookupByLibrary.simpleMessage("Shahkar inquiry fee"),
        "profileSubmit": MessageLookupByLibrary.simpleMessage("Submit request"),
        "profileTeacher": MessageLookupByLibrary.simpleMessage("Teacher"),
        "profileTelephone": MessageLookupByLibrary.simpleMessage("Telephone:"),
        "profileTitle": MessageLookupByLibrary.simpleMessage("Title"),
        "profileValid": MessageLookupByLibrary.simpleMessage("Valid"),
        "profileWork": MessageLookupByLibrary.simpleMessage("Work"),
        "proxyAmount": MessageLookupByLibrary.simpleMessage("Amount"),
        "proxyAmountToman": m8,
        "proxyBroker": MessageLookupByLibrary.simpleMessage("Broker"),
        "proxyCompany": MessageLookupByLibrary.simpleMessage("Company"),
        "proxyCompanyHint":
            MessageLookupByLibrary.simpleMessage("Select a company"),
        "proxyDeposit": MessageLookupByLibrary.simpleMessage("Proxy deposit"),
        "proxyDepositHint":
            MessageLookupByLibrary.simpleMessage("Select your deposit"),
        "proxyDepositMockComplete": MessageLookupByLibrary.simpleMessage(
            "The proxy deposit request was simulated. No real mandate or balance reservation was created."),
        "proxySubject": MessageLookupByLibrary.simpleMessage("Subject"),
        "proxySubjectHint": MessageLookupByLibrary.simpleMessage(
            "Select a proxy deposit subject"),
        "refreshCaptcha":
            MessageLookupByLibrary.simpleMessage("Refresh security code"),
        "relatedLinks": MessageLookupByLibrary.simpleMessage("Related links"),
        "reportApplyFilter":
            MessageLookupByLibrary.simpleMessage("Apply filter"),
        "reportCancelError": MessageLookupByLibrary.simpleMessage(
            "Cancellation failed. Retry or refresh the reports."),
        "reportCancelPrompt": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to cancel this request?"),
        "reportCancelRequest":
            MessageLookupByLibrary.simpleMessage("Cancel request"),
        "reportConfirmCancel":
            MessageLookupByLibrary.simpleMessage("Yes, cancel"),
        "reportDate": MessageLookupByLibrary.simpleMessage("Date"),
        "reportDateLastMonth":
            MessageLookupByLibrary.simpleMessage("Last month"),
        "reportDateLastThreeMonths":
            MessageLookupByLibrary.simpleMessage("Last 3 months"),
        "reportDateLastWeek": MessageLookupByLibrary.simpleMessage("Last week"),
        "reportDateToday": MessageLookupByLibrary.simpleMessage("Today"),
        "reportDetails": MessageLookupByLibrary.simpleMessage("Details"),
        "reportDetailsTitle":
            MessageLookupByLibrary.simpleMessage("Request details"),
        "reportIdentifier": MessageLookupByLibrary.simpleMessage("Identifier"),
        "reportLoadError": MessageLookupByLibrary.simpleMessage(
            "Unable to load request reports."),
        "reportNoResults":
            MessageLookupByLibrary.simpleMessage("No matching requests found."),
        "reportNoTypes":
            MessageLookupByLibrary.simpleMessage("No request types found."),
        "reportRequestDate":
            MessageLookupByLibrary.simpleMessage("Request date"),
        "reportRequestStatus":
            MessageLookupByLibrary.simpleMessage("Request status"),
        "reportRequestType":
            MessageLookupByLibrary.simpleMessage("Request type"),
        "reportSearchIdentifier":
            MessageLookupByLibrary.simpleMessage("Payment identifier"),
        "reportSearchTypes":
            MessageLookupByLibrary.simpleMessage("Search request types"),
        "reportSelectAll": MessageLookupByLibrary.simpleMessage("(Select all)"),
        "reportStatus": MessageLookupByLibrary.simpleMessage("Status"),
        "reportStatusAwaitingApproval":
            MessageLookupByLibrary.simpleMessage("Awaiting approval"),
        "reportStatusAwaitingReview":
            MessageLookupByLibrary.simpleMessage("Awaiting review"),
        "reportStatusCancelled":
            MessageLookupByLibrary.simpleMessage("Cancelled"),
        "reportStatusCompleted":
            MessageLookupByLibrary.simpleMessage("Completed automatically"),
        "reportStatusProcessingError":
            MessageLookupByLibrary.simpleMessage("Processing error"),
        "reportStatusRejected":
            MessageLookupByLibrary.simpleMessage("Rejected"),
        "reportStatusSystemError":
            MessageLookupByLibrary.simpleMessage("System error"),
        "reportTitle": MessageLookupByLibrary.simpleMessage("Request reports"),
        "reportTypeBlockDeposit":
            MessageLookupByLibrary.simpleMessage("Block deposit"),
        "reportTypeChequeBook":
            MessageLookupByLibrary.simpleMessage("Issue cheque book"),
        "reportTypeChequeClearance":
            MessageLookupByLibrary.simpleMessage("Cheque record clearance"),
        "reportTypeCurrentDeposit":
            MessageLookupByLibrary.simpleMessage("Open current deposit"),
        "reportTypeInstallmentDeposit": MessageLookupByLibrary.simpleMessage(
            "Change installment repayment deposit"),
        "reportTypeInternetPassword": MessageLookupByLibrary.simpleMessage(
            "Change internet banking password"),
        "reportTypeMobilePassword": MessageLookupByLibrary.simpleMessage(
            "Change mobile banking password"),
        "reportTypeOnSiteTransfer":
            MessageLookupByLibrary.simpleMessage("On-site transfer"),
        "reportTypeUnblockDeposit":
            MessageLookupByLibrary.simpleMessage("Unblock deposit"),
        "requestIdentifier":
            MessageLookupByLibrary.simpleMessage("Request identifier"),
        "requestOtp":
            MessageLookupByLibrary.simpleMessage("Request verification code"),
        "requestStatus": MessageLookupByLibrary.simpleMessage("Request status"),
        "requestTwoFactorCode":
            MessageLookupByLibrary.simpleMessage("Request two-factor code"),
        "resalatApp": MessageLookupByLibrary.simpleMessage("Resalat app"),
        "resendOtp": MessageLookupByLibrary.simpleMessage("Resend"),
        "rialCurrency": MessageLookupByLibrary.simpleMessage("Rial"),
        "securityTips": MessageLookupByLibrary.simpleMessage("Security tips"),
        "selectedServices":
            MessageLookupByLibrary.simpleMessage("Selected services"),
        "servicesList": MessageLookupByLibrary.simpleMessage("Services list"),
        "servicesMenuLabel":
            MessageLookupByLibrary.simpleMessage("Services menu"),
        "smsSettings": MessageLookupByLibrary.simpleMessage("SMS settings"),
        "submitRequest": MessageLookupByLibrary.simpleMessage("Submit request"),
        "surplusDepositsDescription": MessageLookupByLibrary.simpleMessage(
            "Select the deposit you want to keep as your primary deposit. Your surplus deposits will be closed, and their balances and associated items will be transferred to your selected deposit."),
        "surplusDepositsEmptyBody": MessageLookupByLibrary.simpleMessage(
            "You have no surplus individual Qard al-Hasan savings deposits."),
        "surplusDepositsEmptyTitle":
            MessageLookupByLibrary.simpleMessage("No results found"),
        "surplusDepositsMockComplete": MessageLookupByLibrary.simpleMessage(
            "The deposit closure request was simulated. No real deposit or balance has changed."),
        "surplusDepositsReviewTitle":
            MessageLookupByLibrary.simpleMessage("Your surplus deposits"),
        "surplusDepositsSubmit":
            MessageLookupByLibrary.simpleMessage("Confirm and submit request"),
        "surplusDepositsTitle":
            MessageLookupByLibrary.simpleMessage("Close surplus deposits"),
        "surplusPrimaryDeposit":
            MessageLookupByLibrary.simpleMessage("Primary deposit"),
        "surplusPrimaryDepositHint":
            MessageLookupByLibrary.simpleMessage("Select your primary deposit"),
        "transferAddDestination":
            MessageLookupByLibrary.simpleMessage("Add destination"),
        "transferAddManual":
            MessageLookupByLibrary.simpleMessage("Add destination manually"),
        "transferAddNext":
            MessageLookupByLibrary.simpleMessage("Add another destination"),
        "transferAddressHint": MessageLookupByLibrary.simpleMessage(
            "Select the expert visit address"),
        "transferAmount": MessageLookupByLibrary.simpleMessage("Amount"),
        "transferAmountError": MessageLookupByLibrary.simpleMessage(
            "Enter a valid positive amount."),
        "transferAmountHint":
            MessageLookupByLibrary.simpleMessage("Enter the amount"),
        "transferAmountRial":
            MessageLookupByLibrary.simpleMessage("Amount (rial)"),
        "transferConfirmNext":
            MessageLookupByLibrary.simpleMessage("Confirm and continue"),
        "transferConfirmationStep": MessageLookupByLibrary.simpleMessage(
            "Final confirmation and service fee"),
        "transferCutoffNotice": MessageLookupByLibrary.simpleMessage(
            "Today can only be selected before 10 am."),
        "transferDate": MessageLookupByLibrary.simpleMessage("Transfer date"),
        "transferDateError": MessageLookupByLibrary.simpleMessage(
            "Enter an eligible date; today is available before 10 am."),
        "transferDateHint": MessageLookupByLibrary.simpleMessage(
            "Enter a Solar Hijri date: YYYY/MM/DD"),
        "transferDeleteDestination":
            MessageLookupByLibrary.simpleMessage("Remove destination"),
        "transferDeleteFile":
            MessageLookupByLibrary.simpleMessage("Remove file"),
        "transferDescription": MessageLookupByLibrary.simpleMessage(
            "Deposit reference / description"),
        "transferDescriptionHint": MessageLookupByLibrary.simpleMessage(
            "Enter a reference or description"),
        "transferDestinationPrompt":
            MessageLookupByLibrary.simpleMessage("Enter destination details."),
        "transferDestinationsStep":
            MessageLookupByLibrary.simpleMessage("Enter destinations"),
        "transferFileAccepted": MessageLookupByLibrary.simpleMessage(
            "Destination file accepted; spreadsheet content review is deferred."),
        "transferFileInvalid": MessageLookupByLibrary.simpleMessage(
            "Choose a nonempty XLS file up to 100 KB."),
        "transferFileRequirements": MessageLookupByLibrary.simpleMessage(
            "Format: XLS  |  Maximum size: 100 KB"),
        "transferHolidayNotice": MessageLookupByLibrary.simpleMessage(
            "The selected date must not be a public holiday."),
        "transferIbanError":
            MessageLookupByLibrary.simpleMessage("Enter a valid Iranian IBAN."),
        "transferIbanHint":
            MessageLookupByLibrary.simpleMessage("Enter IBAN digits"),
        "transferIdentifier":
            MessageLookupByLibrary.simpleMessage("Deposit reference"),
        "transferInternal": MessageLookupByLibrary.simpleMessage("Internal"),
        "transferMethod": MessageLookupByLibrary.simpleMessage("Transfer type"),
        "transferMethodHint":
            MessageLookupByLibrary.simpleMessage("Select transfer type"),
        "transferMethodRow":
            MessageLookupByLibrary.simpleMessage("Transfer method"),
        "transferMockComplete": MessageLookupByLibrary.simpleMessage(
            "Demo request recorded. No money or service fee was transferred at the bank."),
        "transferPaya": MessageLookupByLibrary.simpleMessage("PAYA"),
        "transferPurpose": MessageLookupByLibrary.simpleMessage("Purpose"),
        "transferPurposeHint":
            MessageLookupByLibrary.simpleMessage("Select the transfer purpose"),
        "transferReview": MessageLookupByLibrary.simpleMessage("Review"),
        "transferSalary":
            MessageLookupByLibrary.simpleMessage("Salary payment"),
        "transferSampleLink":
            MessageLookupByLibrary.simpleMessage("the template"),
        "transferSamplePrefix":
            MessageLookupByLibrary.simpleMessage("The Excel file must match "),
        "transferSampleSuffix": MessageLookupByLibrary.simpleMessage("."),
        "transferSatna": MessageLookupByLibrary.simpleMessage("SATNA"),
        "transferSave": MessageLookupByLibrary.simpleMessage("Save"),
        "transferServiceFee":
            MessageLookupByLibrary.simpleMessage("On-site service fee"),
        "transferSourcePrompt": MessageLookupByLibrary.simpleMessage(
            "Select the source deposit and transfer date"),
        "transferSourceStep": MessageLookupByLibrary.simpleMessage(
            "Deposit and request conditions"),
        "transferUploadAction":
            MessageLookupByLibrary.simpleMessage("upload a file, click here"),
        "transferUploadAfter": MessageLookupByLibrary.simpleMessage(""),
        "transferUploadBefore": MessageLookupByLibrary.simpleMessage("To"),
        "transferUploadExcel":
            MessageLookupByLibrary.simpleMessage("Upload Excel file"),
        "transferVisitDate": MessageLookupByLibrary.simpleMessage("Visit date"),
        "transferVisitDateError": MessageLookupByLibrary.simpleMessage(
            "The visit must be on a working day between today and the transfer date."),
        "transferVisitDateHint": MessageLookupByLibrary.simpleMessage(
            "Enter the visit date: YYYY/MM/DD"),
        "transferVisitPrompt": MessageLookupByLibrary.simpleMessage(
            "Select the expert visit address and date."),
        "transferVisitStep": MessageLookupByLibrary.simpleMessage(
            "Expert visit address and date"),
        "updateGuide": MessageLookupByLibrary.simpleMessage("Update guide"),
        "virtualRequestCount":
            MessageLookupByLibrary.simpleMessage("Number of virtual cards"),
        "virtualRequestCountError": m9,
        "virtualRequestCountHint": MessageLookupByLibrary.simpleMessage(
            "Enter the number of virtual cards you need"),
        "virtualRequestDepositHint":
            MessageLookupByLibrary.simpleMessage("Select a deposit"),
        "virtualRequestDepositLabel":
            MessageLookupByLibrary.simpleMessage("Deposit"),
        "virtualRequestEmpty": MessageLookupByLibrary.simpleMessage(
            "No deposits are available for virtual card issuance."),
        "virtualRequestFeeNotice": m10,
        "virtualRequestMockReceipt": MessageLookupByLibrary.simpleMessage(
            "Demo request registered. No virtual cards were created and no payment was made."),
        "virtualRequestNotice": MessageLookupByLibrary.simpleMessage(
            "A virtual card has no physical form. It is only a number that accepts incoming transfers; withdrawals and purchases are unavailable."),
        "virtualRequestPrompt": MessageLookupByLibrary.simpleMessage(
            "Select the deposit and number of virtual cards, then continue."),
        "virtualRequestQuoting":
            MessageLookupByLibrary.simpleMessage("Getting the request quote…"),
        "virtualRequestReceipt":
            MessageLookupByLibrary.simpleMessage("Request reference:"),
        "virtualRequestSubmit":
            MessageLookupByLibrary.simpleMessage("Confirm and submit request"),
        "virtualRequestSubmitted":
            MessageLookupByLibrary.simpleMessage("Request registered"),
        "virtualRequestTitle":
            MessageLookupByLibrary.simpleMessage("Virtual card request"),
        "virtualRequestUnitFee":
            MessageLookupByLibrary.simpleMessage("Issuance fee per card"),
        "walletBalanceTitle":
            MessageLookupByLibrary.simpleMessage("Wallet balance")
      };
}
