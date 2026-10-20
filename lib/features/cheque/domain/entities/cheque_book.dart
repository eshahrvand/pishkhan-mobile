import 'package:equatable/equatable.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';

import 'cheque_clearance.dart';

enum ChequeBookApplicant { individual, legal }

class ChequeBookDeposit extends ChequeDeposit {
  ChequeBookDeposit({
    required super.id,
    required super.number,
    required this.openedAt,
    required Iterable<int> leafCounts,
  }) : leafCounts = List.unmodifiable(leafCounts);
  final DateTime openedAt;
  final List<int> leafCounts;
  @override
  List<Object?> get props => [...super.props, openedAt, leafCounts];
}

class ChequeBookCatalog extends Equatable {
  ChequeBookCatalog({
    required this.applicant,
    required Iterable<ChequeBookDeposit> deposits,
  }) : deposits = List.unmodifiable(deposits);
  final ChequeBookApplicant applicant;
  final List<ChequeBookDeposit> deposits;
  @override
  List<Object?> get props => [applicant, deposits];
}

class ChequeBookResidence extends Equatable {
  const ChequeBookResidence({
    required this.address,
    required this.isRegistered,
  });
  final DeliveryAddress address;
  final bool isRegistered;
  @override
  List<Object?> get props => [address, isRegistered];
}

class ChequeBookResidency extends Equatable {
  ChequeBookResidency({
    required this.token,
    required Iterable<ChequeBookResidence> residences,
  }) : residences = List.unmodifiable(residences);
  final String token;
  final List<ChequeBookResidence> residences;
  @override
  List<Object?> get props => [token, residences];
}

class ChequeBookDraft extends Equatable {
  const ChequeBookDraft({
    required this.depositId,
    required this.leafCount,
    required this.residencyToken,
    required this.address,
    this.recipientName,
    this.recipientNationalId,
    this.agentIdentifier,
  });
  final String depositId;
  final int leafCount;
  final String residencyToken;
  final DeliveryAddress address;
  final String? recipientName;
  final String? recipientNationalId;
  final String? agentIdentifier;
  @override
  List<Object?> get props => [
    depositId,
    leafCount,
    residencyToken,
    address,
    recipientName,
    recipientNationalId,
    agentIdentifier,
  ];
  @override
  String toString() => 'ChequeBookDraft(redacted)';
}

class ChequeBookQuote extends Equatable {
  const ChequeBookQuote({
    required this.token,
    required this.issueFeeRial,
    required this.deliveryFeeRial,
    required this.walletBalanceRial,
    required this.expiresAt,
  });
  final String token;
  final int issueFeeRial;
  final int deliveryFeeRial;
  final int walletBalanceRial;
  final DateTime expiresAt;
  @override
  List<Object?> get props => [
    token,
    issueFeeRial,
    deliveryFeeRial,
    walletBalanceRial,
    expiresAt,
  ];
}

class ChequeBookRequest extends Equatable {
  const ChequeBookRequest({
    required this.draft,
    required this.quoteToken,
    required this.idempotencyKey,
  });
  final ChequeBookDraft draft;
  final String quoteToken;
  final String idempotencyKey;
  @override
  List<Object?> get props => [draft, quoteToken, idempotencyKey];
  @override
  String toString() => 'ChequeBookRequest(redacted)';
}

class ChequeBookReceipt extends Equatable {
  const ChequeBookReceipt({required this.reference, required this.isMock});
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}
