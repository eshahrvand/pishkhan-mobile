import 'package:equatable/equatable.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

enum PasswordCardKind { resalat, coupon, gift, family }

enum PasswordRequestStatus { none, pending, approved }

class PasswordCard extends Equatable {
  PasswordCard({
    required this.id,
    required this.number,
    this.kind = PasswordCardKind.resalat,
    this.canSetSecondPassword = true,
    Iterable<String> datePinCandidates = const [],
  }) : datePinCandidates = List.unmodifiable(datePinCandidates);
  final String id, number;
  final PasswordCardKind kind;
  final bool canSetSecondPassword;

  /// Known birth/expiry-derived values, normalized by the data adapter.
  final List<String> datePinCandidates;
  @override
  List<Object?> get props => [
    id,
    number,
    kind,
    canSetSecondPassword,
    datePinCandidates,
  ];
}

class PasswordCatalog extends Equatable {
  PasswordCatalog({
    required Iterable<PasswordCard> cards,
    this.feeRial = 1300000,
    this.walletBalanceRial = 2000000,
  }) : cards = List.unmodifiable(cards);
  final List<PasswordCard> cards;
  final int feeRial, walletBalanceRial;
  @override
  List<Object?> get props => [cards, feeRial, walletBalanceRial];
}

class PasswordRequestRecord extends Equatable {
  const PasswordRequestRecord({
    required this.status,
    this.trackingCode,
    this.isMock = false,
  });
  final PasswordRequestStatus status;
  final String? trackingCode;
  final bool isMock;
  @override
  List<Object?> get props => [status, trackingCode, isMock];
}

/// Ephemeral sensitive payload. Never log, persist or include in diagnostics.
class SetSecondPasswordRequest {
  const SetSecondPasswordRequest({
    required this.cardId,
    required this.password,
    required this.nationalCardSerial,
    required this.idempotencyKey,
    required this.kycReference,
  });
  final String cardId,
      password,
      nationalCardSerial,
      idempotencyKey,
      kycReference;
  @override
  String toString() => 'SetSecondPasswordRequest(redacted)';
}

abstract interface class PasswordServicesRepository {
  Future<Result<PasswordCatalog>> load();
  Future<Result<PasswordRequestRecord>> status(String cardId);
  Future<Result<PasswordRequestRecord>> submit(
    SetSecondPasswordRequest request,
  );
}
