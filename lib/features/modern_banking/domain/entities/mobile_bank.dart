import 'package:equatable/equatable.dart';

enum MobileBankOperation { activation, passwordRecovery }

enum MobileBankRequestStatus { none, pending, approved, rejected }

enum MobileBankDestination {
  passwordRecovery,
  passwordGuide,
  transferLimits,
  deactivation,
}

class MobileBankRecord extends Equatable {
  const MobileBankRecord({
    this.status = MobileBankRequestStatus.none,
    this.trackingCode,
  });
  final MobileBankRequestStatus status;
  final String? trackingCode;
  @override
  List<Object?> get props => [status, trackingCode];
}

class TransferLimits extends Equatable {
  const TransferLimits({
    required this.internalRial,
    required this.payaRial,
    required this.satnaRial,
  });
  final int internalRial;
  final int payaRial;
  final int satnaRial;
  @override
  List<Object?> get props => [internalRial, payaRial, satnaRial];
}

class DeactivationReason extends Equatable {
  const DeactivationReason({required this.id, required this.code});
  final String id;
  final String code;
  @override
  List<Object?> get props => [id, code];
}

class MobileBankCatalog extends Equatable {
  const MobileBankCatalog({
    required this.username,
    required this.depositId,
    required this.activation,
    required this.recovery,
    required this.limits,
    required this.maximumLimits,
    required this.registryFeeRial,
    required this.identityFeeRial,
    required this.passwordFeeRial,
    required this.walletBalanceRial,
    required this.reasons,
    this.activationVideoUrl,
    this.identityVideoUrl,
  });
  final String username;
  final String depositId;
  final MobileBankRecord activation;
  final MobileBankRecord recovery;
  final TransferLimits limits;
  final TransferLimits maximumLimits;
  final int registryFeeRial;
  final int identityFeeRial;
  final int passwordFeeRial;
  final int walletBalanceRial;
  final List<DeactivationReason> reasons;
  final String? activationVideoUrl;
  final String? identityVideoUrl;
  @override
  List<Object?> get props => [
    username,
    depositId,
    activation,
    recovery,
    limits,
    maximumLimits,
    registryFeeRial,
    identityFeeRial,
    passwordFeeRial,
    walletBalanceRial,
    reasons,
    activationVideoUrl,
    identityVideoUrl,
  ];
}

/// This request explicitly describes the prototype preview, never captured KYC.
class MobileBankIdentityRequest extends Equatable {
  const MobileBankIdentityRequest({
    required this.operation,
    required this.nationalCardSerial,
    required this.idempotencyKey,
    required this.isPrototypePreview,
  });
  final MobileBankOperation operation;
  final String nationalCardSerial;
  final String idempotencyKey;
  final bool isPrototypePreview;
  @override
  List<Object?> get props => [
    operation,
    nationalCardSerial,
    idempotencyKey,
    isPrototypePreview,
  ];
  @override
  bool get stringify => false;
}

class TransferLimitsRequest extends Equatable {
  const TransferLimitsRequest({
    required this.depositId,
    required this.limits,
    required this.idempotencyKey,
  });
  final String depositId;
  final TransferLimits limits;
  final String idempotencyKey;
  @override
  List<Object?> get props => [depositId, limits, idempotencyKey];
}

class MobileBankDeactivationRequest extends Equatable {
  const MobileBankDeactivationRequest({
    required this.username,
    required this.reason,
    required this.idempotencyKey,
  });
  final String username;
  final DeactivationReason reason;
  final String idempotencyKey;
  @override
  List<Object?> get props => [username, reason, idempotencyKey];
}
