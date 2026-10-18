part of 'average_balance_cubit.dart';

enum AverageBalanceStep { conditions, delivery, confirmation }

@Freezed(toStringOverride: false)
abstract class AverageBalanceState with _$AverageBalanceState {
  const factory AverageBalanceState.initial({
    FlowNavigation? navigation,
    @Default(false) bool canCheckAgent,
    CertificateEffect? effect,
    @Default(0) int effectId,
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(AverageBalanceStep.conditions) AverageBalanceStep step,
    CertificateCatalog? catalog,
    ListedDeposit? deposit,
    CertificateLanguage? language,
    StatementTurnover? turnover,
    DateTime? fromDate,
    DateTime? toDate,
    @Default(<CertificateAddress>[]) List<CertificateAddress> addresses,
    CertificateAddress? address,
    @Default(false) bool isOtherRecipient,
    @Default('') String recipientName,
    @Default('') String recipientNationalId,
    @Default(false) bool isIncludeAgent,
    @Default('') String agentIdentifier,
    @Default(false) bool isRecipientNameValid,
    @Default(false) bool isRecipientNationalIdValid,
    @Default(1) int stepNumber,
    @Default(.3) double progress,
    @Default(false) bool canContinue,
    @Default(0) int totalRial,
    @Default(false) bool isWalletSufficient,
    @Default(true) bool isSummaryExpanded,
    @Default(true) bool isInvoiceExpanded,
    Failure? catalogFailure,
    Failure? submissionFailure,
    CertificateReceipt? receipt,
  }) = _AverageBalanceState;
}
