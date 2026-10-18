import 'package:equatable/equatable.dart';

import 'certificate_data.dart';

enum FinancialCertificateCondition {
  withdrawalRules,
  homeAddress,
  openedAt,
  passportNumber,
  averageBalance,
  maturityDate,
  debitCredit,
  exchangeRate,
}

enum FinancialCertificateRecipient { embassy, otherAuthority }

class FinancialLatinIdentity extends Equatable {
  const FinancialLatinIdentity({
    required this.name,
    required this.surname,
    required this.fatherName,
    required this.passportNumber,
    required this.passportExpiry,
    required this.address,
  });
  final String name, surname, fatherName, passportNumber, address;
  final DateTime passportExpiry;
  @override
  List<Object?> get props => [
    name,
    surname,
    fatherName,
    passportNumber,
    passportExpiry,
    address,
  ];
  @override
  String toString() => 'FinancialLatinIdentity(redacted)';
}

class FinancialCertificateRequest extends Equatable {
  FinancialCertificateRequest({
    required this.depositId,
    required Iterable<FinancialCertificateCondition> conditions,
    required this.recipient,
    this.embassyId,
    this.authorityName,
    required this.currency,
    required this.identity,
    required this.address,
    this.deliveryRecipientName,
    this.deliveryRecipientNationalId,
    this.agentIdentifier,
    required this.idempotencyKey,
  }) : conditions = Set.unmodifiable(conditions);
  final String depositId, idempotencyKey;
  final Set<FinancialCertificateCondition> conditions;
  final FinancialCertificateRecipient recipient;
  final String? embassyId,
      authorityName,
      deliveryRecipientName,
      deliveryRecipientNationalId,
      agentIdentifier;
  final CertificateCurrency currency;
  final FinancialLatinIdentity identity;
  final CertificateAddress address;
  @override
  List<Object?> get props => [
    depositId,
    conditions,
    recipient,
    embassyId,
    authorityName,
    currency,
    identity,
    address,
    deliveryRecipientName,
    deliveryRecipientNationalId,
    agentIdentifier,
    idempotencyKey,
  ];
  @override
  String toString() => 'FinancialCertificateRequest(redacted)';
}
