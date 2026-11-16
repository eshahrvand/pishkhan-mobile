import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';

String loanRangeLabel(LoanCreditRange range) => switch (range) {
  LoanCreditRange.unknown => S.current.loanRequestUnknown,
  LoanCreditRange.excellent => S.current.loanRequestExcellent,
  LoanCreditRange.fullySuitable => S.current.loanRequestFullySuitable,
  LoanCreditRange.suitable => S.current.loanRequestSuitable,
  LoanCreditRange.unsuitable => S.current.loanRequestUnsuitable,
};
String loanStepLabel(LoanApplicationStep step) => switch (step) {
  LoanApplicationStep.introduction => S.current.loanRequestTitle,
  LoanApplicationStep.assessment => S.current.loanRequestAssessment,
  LoanApplicationStep.inquiries => S.current.loanRequestInquiries,
  LoanApplicationStep.collateral => S.current.loanRequestCollateral,
  LoanApplicationStep.contract => S.current.loanRequestContract,
};

String loanPrimaryActionLabel(
  LoanApplicationStep step,
  LoanCreditRange? range,
) => switch (step) {
  LoanApplicationStep.introduction => S.current.loanRequestTitle,
  LoanApplicationStep.contract => S.current.loanRequestContractContinue,
  LoanApplicationStep.assessment when range == LoanCreditRange.unknown =>
    S.current.loanRequestTitle,
  _ => S.current.loanRequestNext,
};
String loanNextLabel(LoanApplicationStep step) => switch (step) {
  LoanApplicationStep.assessment =>
    S.current.loanRequestNextPrefix + S.current.loanRequestInquiries,
  LoanApplicationStep.inquiries =>
    S.current.loanRequestNextPrefix + S.current.loanRequestCollateral,
  LoanApplicationStep.collateral =>
    S.current.loanRequestNextPrefix + S.current.loanRequestContract,
  _ => S.current.loanRequestEnd,
};
String loanInquiryLabel(LoanInquiryKind kind) => switch (kind) {
  LoanInquiryKind.returnedCheque => S.current.loanRequestReturnedCheque,
  LoanInquiryKind.bankDebt => S.current.loanRequestBankDebt,
  LoanInquiryKind.outstandingDebt => S.current.loanRequestOutstandingDebt,
  LoanInquiryKind.militaryService => S.current.loanRequestMilitary,
};
String loanMoney(int rial) =>
    '${CurrencyFormatter.format(rial)} ${S.current.rialCurrency}';
String loanCountdown(int seconds) => CurrencyFormatter.toPersianDigits(
  '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
);

String loanDraftStageLabel(LoanApplicationStep step) => switch (step) {
  LoanApplicationStep.collateral => S.current.loanRequestAwaitingCollateral,
  _ => S.current.loanRequestAwaitingSignature,
};

String loanAssessmentRangeLabel(LoanCreditTier tier, LoanCreditRange range) =>
    tier == LoanCreditTier.socialCore && range != LoanCreditRange.unsuitable
    ? S.current.loanRequestSocialCore
    : loanRangeLabel(range);
