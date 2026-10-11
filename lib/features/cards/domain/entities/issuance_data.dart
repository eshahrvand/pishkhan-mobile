import 'package:equatable/equatable.dart';

enum IssuanceType { newNumber, existingNumber }

enum IssuanceFeeKind { print, identity, delivery }

class IssuanceDeposit extends Equatable {
  const IssuanceDeposit({
    required this.id,
    required this.number,
    required this.cardNumber,
    required this.expiry,
  });
  final String id, number, cardNumber, expiry;
  @override
  List<Object?> get props => [id, number, cardNumber, expiry];
}

class IssuanceAddress extends Equatable {
  const IssuanceAddress({
    required this.id,
    required this.title,
    required this.detail,
    required this.postalCode,
  });
  final String id, title, detail, postalCode;
  @override
  List<Object?> get props => [id, title, detail, postalCode];
}

class IssuanceFee extends Equatable {
  const IssuanceFee(this.kind, this.amountRial) : assert(amountRial >= 0);
  final IssuanceFeeKind kind;
  final int amountRial;
  @override
  List<Object?> get props => [kind, amountRial];
}

class IssuanceCatalog extends Equatable {
  IssuanceCatalog({
    required Iterable<IssuanceDeposit> deposits,
    required Iterable<IssuanceAddress> addresses,
    required Iterable<IssuanceFee> fees,
    required this.walletBalanceRial,
    Iterable<IssuanceType> types = IssuanceType.values,
  }) : deposits = List.unmodifiable(deposits),
       addresses = List.unmodifiable(addresses),
       fees = List.unmodifiable(fees),
       types = List.unmodifiable(types);
  final List<IssuanceDeposit> deposits;
  final List<IssuanceAddress> addresses;
  final List<IssuanceFee> fees;
  final List<IssuanceType> types;
  final int walletBalanceRial;
  IssuanceCatalog withAddresses(Iterable<IssuanceAddress> value) =>
      IssuanceCatalog(
        deposits: deposits,
        addresses: value,
        fees: fees,
        types: types,
        walletBalanceRial: walletBalanceRial,
      );
  @override
  List<Object?> get props => [
    deposits,
    addresses,
    fees,
    types,
    walletBalanceRial,
  ];
}

/// Captured identity details belong to domain data, never to a shared widget.
class DeliveryPerson extends Equatable {
  const DeliveryPerson({
    this.name = '',
    this.nationalId = '',
    this.mobile = '',
  });
  final String name, nationalId, mobile;
  bool get isComplete =>
      name.trim().isNotEmpty &&
      RegExp(r'^[0-9]{10}$').hasMatch(nationalId) &&
      RegExp(r'^09[0-9]{9}$').hasMatch(mobile);
  DeliveryPerson copyWith({String? name, String? nationalId, String? mobile}) =>
      DeliveryPerson(
        name: name ?? this.name,
        nationalId: nationalId ?? this.nationalId,
        mobile: mobile ?? this.mobile,
      );
  @override
  List<Object?> get props => [name, nationalId, mobile];
}

class BankAgent extends Equatable {
  const BankAgent({this.name = '', this.code = ''});
  final String name, code;
  bool get isComplete => name.trim().isNotEmpty && code.trim().isNotEmpty;
  BankAgent copyWith({String? name, String? code}) =>
      BankAgent(name: name ?? this.name, code: code ?? this.code);
  @override
  List<Object?> get props => [name, code];
}

class IssuanceRequest extends Equatable {
  const IssuanceRequest({
    required this.depositId,
    required this.type,
    required this.noPhysicalCard,
    this.address,
    this.recipient,
    this.agent,
  });
  final String depositId;
  final IssuanceType type;
  final bool noPhysicalCard;
  final IssuanceAddress? address;
  final DeliveryPerson? recipient;
  final BankAgent? agent;
  @override
  List<Object?> get props => [
    depositId,
    type,
    noPhysicalCard,
    address,
    recipient,
    agent,
  ];
}

class IssuanceReceipt extends Equatable {
  const IssuanceReceipt({required this.reference, required this.isMock});
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}
