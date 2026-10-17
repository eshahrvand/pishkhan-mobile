part of 'financial_certificate_cubit.dart';

enum FinancialCertificateStep {
  conditions,
  recipient,
  latinIdentity,
  delivery,
  confirmation,
}

@Freezed(toStringOverride: false)
abstract class FinancialCertificateState with _$FinancialCertificateState {
  const factory FinancialCertificateState.initial({
    FlowNavigation? navigation,
    @Default(false) bool canCheckAgent,
    CertificateEffect? effect,
    @Default(0) int effectId,
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(FinancialCertificateStep.conditions) FinancialCertificateStep step,
    CertificateCatalog? catalog,
    ListedDeposit? deposit,
    @Default(<FinancialCertificateCondition>{})
    Set<FinancialCertificateCondition> conditions,
    FinancialCertificateRecipient? recipient,
    String? embassyId,
    @Default('') String authorityName,
    CertificateCurrency? currency,
    @Default('') String name,
    @Default('') String surname,
    @Default('') String fatherName,
    @Default('') String passportNumber,
    @Default('') String passportExpiryText,
    DateTime? passportExpiry,
    @Default('') String latinAddress,
    @Default(false) bool latinComplete,
    @Default(false) bool recipientComplete,
    @Default(<CertificateAddress>[]) List<CertificateAddress> addresses,
    CertificateAddress? address,
    @Default(false) bool otherRecipient,
    @Default('') String deliveryRecipientName,
    @Default('') String deliveryRecipientNationalId,
    @Default(false) bool includeAgent,
    @Default('') String agentIdentifier,
    @Default(false) bool canContinue,
    @Default(0) int totalRial,
    @Default(false) bool walletSufficient,
    @Default(true) bool summaryExpanded,
    @Default(true) bool invoiceExpanded,
    Failure? failure,
    CertificateReceipt? receipt,
  }) = _FinancialCertificateState;
}
