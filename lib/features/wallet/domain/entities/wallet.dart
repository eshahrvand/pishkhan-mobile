import 'package:equatable/equatable.dart';

enum WalletTransactionType { charge, withdraw, shopping, transfer }

enum WalletDatePeriod { today, lastWeek, lastMonth, lastThreeMonths, custom }

enum WalletFilterKind { types, date, amount }

class WalletDeposit extends Equatable {
  const WalletDeposit(this.id, this.number);
  final String id, number;
  @override
  List<Object?> get props => [id, number];
}

class WalletSummary extends Equatable {
  const WalletSummary({
    required this.id,
    required this.balanceRial,
    required this.linkedDeposit,
  });
  final String id;
  final int balanceRial;
  final WalletDeposit linkedDeposit;
  @override
  List<Object?> get props => [id, balanceRial, linkedDeposit];
}

class WalletCatalog {
  const WalletCatalog({
    required this.wallet,
    required this.deposits,
    required this.terms,
  });
  final WalletSummary wallet;
  final List<WalletDeposit> deposits;
  final String terms;
}

class WalletOtpChallenge {
  const WalletOtpChallenge({
    required this.id,
    required this.expiresAt,
    required this.codeLength,
  });
  final String id;
  final DateTime expiresAt;
  final int codeLength;
}

class WalletRecipient extends Equatable {
  const WalletRecipient({required this.id, required this.name});
  final String id, name;
  @override
  List<Object?> get props => [id, name];
}

class WalletPaymentRequest {
  const WalletPaymentRequest({
    required this.amountRial,
    required this.challengeId,
    required this.otp,
    required this.idempotencyKey,
  });
  final int amountRial;
  final String challengeId, otp, idempotencyKey;
}

class WalletTransferRequest {
  const WalletTransferRequest({
    required this.amountRial,
    required this.recipientId,
    required this.idempotencyKey,
  });
  final int amountRial;
  final String recipientId, idempotencyKey;
}

class WalletReceipt extends Equatable {
  const WalletReceipt({
    required this.trackingId,
    required this.type,
    required this.amountRial,
    required this.createdAt,
    required this.source,
    required this.destination,
    required this.balanceRial,
  });
  final String trackingId, source, destination;
  final WalletTransactionType type;
  final int amountRial, balanceRial;
  final DateTime createdAt;
  @override
  List<Object?> get props => [
    trackingId,
    type,
    amountRial,
    createdAt,
    source,
    destination,
    balanceRial,
  ];
}

class WalletTransactionFilter extends Equatable {
  const WalletTransactionFilter({
    this.types = const {},
    this.period,
    this.from,
    this.to,
    this.minRial,
    this.maxRial,
  });
  final Set<WalletTransactionType> types;
  final WalletDatePeriod? period;
  final DateTime? from, to;
  final int? minRial, maxRial;
  @override
  List<Object?> get props => [types, period, from, to, minRial, maxRial];
}
