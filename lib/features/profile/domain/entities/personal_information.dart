import 'package:equatable/equatable.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';

enum ResidenceStatus { unchecked, querying, valid, missing }

class ProfileAddress extends Equatable {
  const ProfileAddress({
    required this.address,
    this.status = ResidenceStatus.unchecked,
  });
  final DeliveryAddress address;
  final ResidenceStatus status;
  ProfileAddress withStatus(ResidenceStatus status) =>
      ProfileAddress(address: address, status: status);
  @override
  List<Object?> get props => [address, status];
}

enum OccupationKind { designer, teacher, professor, homemaker }

class ProfileOccupation extends Equatable {
  const ProfileOccupation({
    required this.id,
    required this.kind,
    required this.description,
  });
  final String id;
  final OccupationKind kind;
  final String description;
  @override
  List<Object?> get props => [id, kind, description];
}

class PhoneSettings extends Equatable {
  const PhoneSettings({
    required this.phoneNumber,
    required this.feeRial,
    required this.walletBalanceRial,
  });
  final String phoneNumber;
  final int feeRial;
  final int walletBalanceRial;
  @override
  List<Object?> get props => [phoneNumber, feeRial, walletBalanceRial];
}

class PhoneChallenge extends Equatable {
  const PhoneChallenge({
    required this.id,
    required this.expiresAt,
    this.codeLength = 4,
  });
  final String id;
  final DateTime expiresAt;
  final int codeLength;
  @override
  List<Object?> get props => [id, expiresAt, codeLength];
}
