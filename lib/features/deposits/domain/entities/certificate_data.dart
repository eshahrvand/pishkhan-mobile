import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:equatable/equatable.dart';

import 'listed_deposit.dart';

typedef CertificateAddress = DeliveryAddress;

enum CertificateCurrency { usd, eur, irr }

class CertificateEmbassy extends Equatable {
  const CertificateEmbassy({required this.id, required this.label});
  final String id, label;
  @override
  List<Object?> get props => [id, label];
}

enum CertificateLanguage { persian, english }

enum StatementTurnover {
  depositsAndWithdrawals,
  deposits,
  withdrawals,
  averageBalance,
}

class CertificateCatalog extends Equatable {
  CertificateCatalog({
    required Iterable<ListedDeposit> deposits,
    required Iterable<CertificateAddress> addresses,
    this.printFeeRial = 300000,
    this.deliveryFeeRial = 1000000,
    this.walletBalanceRial = 2000000,
    Iterable<CertificateEmbassy> embassies = const [
      CertificateEmbassy(id: 'demo-embassy', label: 'سفارت نمونه'),
    ],
    Iterable<CertificateCurrency> currencies = const [
      CertificateCurrency.usd,
      CertificateCurrency.eur,
      CertificateCurrency.irr,
    ],
  }) : deposits = List.unmodifiable(deposits),
       addresses = List.unmodifiable(addresses),
       embassies = List.unmodifiable(embassies),
       currencies = List.unmodifiable(currencies);
  final List<CertificateEmbassy> embassies;
  final List<CertificateCurrency> currencies;
  final List<ListedDeposit> deposits;
  final List<CertificateAddress> addresses;
  final int printFeeRial, deliveryFeeRial, walletBalanceRial;
  @override
  List<Object?> get props => [
    deposits,
    addresses,
    printFeeRial,
    deliveryFeeRial,
    walletBalanceRial,
    embassies,
    currencies,
  ];
}

class AverageBalanceRequest extends Equatable {
  const AverageBalanceRequest({
    required this.depositId,
    required this.language,
    required this.turnover,
    required this.address,
    this.fromDate,
    this.toDate,
    this.recipientName,
    this.recipientNationalId,
    this.agentIdentifier,
    required this.idempotencyKey,
  });
  final String depositId, idempotencyKey;
  final CertificateLanguage language;
  final StatementTurnover turnover;
  final CertificateAddress address;
  final DateTime? fromDate, toDate;
  final String? recipientName, recipientNationalId, agentIdentifier;
  @override
  List<Object?> get props => [
    depositId,
    language,
    turnover,
    address,
    fromDate,
    toDate,
    recipientName,
    recipientNationalId,
    agentIdentifier,
    idempotencyKey,
  ];
  @override
  String toString() => 'AverageBalanceRequest(redacted)';
}

class CertificateReceipt extends Equatable {
  const CertificateReceipt({required this.reference, this.isMock = false});
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}
