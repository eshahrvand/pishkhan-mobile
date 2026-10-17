part of 'average_balance_cubit.dart';

enum AverageBalanceStep { conditions, delivery, confirmation }

@Freezed(toStringOverride: false)
abstract class AverageBalanceState with _$AverageBalanceState {
  const factory AverageBalanceState.initial({
    FlowNavigation? navigation,
    @Default(false) bool canCheckAgent,
    CertificateEffect? effect,
    @Default(0) int effectId,
    @Default(RequestStatus.initial) RequestStatus status,
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
    @Default(false) bool otherRecipient,
    @Default('') String recipientName,
    @Default('') String recipientNationalId,
    @Default(false) bool includeAgent,
    @Default('') String agentIdentifier,
    @Default(false) bool canContinue,
    @Default(0) int totalRial,
    @Default(false) bool walletSufficient,
    @Default(true) bool summaryExpanded,
    @Default(true) bool invoiceExpanded,
    Failure? failure,
    CertificateReceipt? receipt,
  }) = _AverageBalanceState;
}
