import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../../domain/entities/financial_certificate_data.dart';
import '../../../domain/entities/listed_deposit.dart';
part 'financial_certificate_state.freezed.dart';

enum FinancialCertificateStep {
  conditions,
  recipient,
  latinIdentity,
  delivery,
  confirmation,
}

@Freezed(toStringOverride: false)
abstract class FinancialCertificateState with _$FinancialCertificateState {
  const factory FinancialCertificateState({
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
