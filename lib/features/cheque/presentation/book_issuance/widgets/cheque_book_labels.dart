import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/cheque_book_cubit.dart';

String chequeBookStepTitle(ChequeBookStep step) => switch (step) {
  ChequeBookStep.selection => S.current.chequeBookSelectionStep,
  ChequeBookStep.checking ||
  ChequeBookStep.residency => S.current.chequeBookResidencyStep,
  ChequeBookStep.delivery => S.current.chequeBookDeliveryStep,
  ChequeBookStep.confirmation => S.current.issuanceConfirmTitle,
};
String chequeBookNextTitle(ChequeBookStep step) => switch (step) {
  ChequeBookStep.selection => S.current.chequeBookNextResidency,
  ChequeBookStep.checking ||
  ChequeBookStep.residency => S.current.chequeBookNextDelivery,
  ChequeBookStep.delivery => S.current.chequeBookNextConfirmation,
  ChequeBookStep.confirmation => S.current.issuanceEnd,
};
String chequeBookActionLabel(ChequeBookAction action) => switch (action) {
  ChequeBookAction.next => S.current.issuanceNext,
  ChequeBookAction.understood => S.current.passwordUnderstood,
  ChequeBookAction.submit => S.current.chequeSubmit,
};
