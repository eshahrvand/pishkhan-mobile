import 'package:equatable/equatable.dart';

import 'issuance_data.dart';

class IssuanceDraft extends Equatable {
  const IssuanceDraft({
    this.deposit,
    this.type,
    this.address,
    this.noPhysicalCard = false,
    this.otherRecipient = false,
    this.includeAgent = false,
    this.termsAccepted = false,
    this.recipient = const DeliveryPerson(),
    this.agent = const BankAgent(),
  });
  final IssuanceDeposit? deposit;
  final IssuanceAddress? address;
  final IssuanceType? type;
  final bool noPhysicalCard, otherRecipient, includeAgent, termsAccepted;
  final DeliveryPerson recipient;
  final BankAgent agent;
  IssuanceDraft copyWith({
    IssuanceDeposit? deposit,
    IssuanceType? type,
    IssuanceAddress? address,
    bool clearAddress = false,
    bool? noPhysicalCard,
    bool? otherRecipient,
    bool? includeAgent,
    bool? termsAccepted,
    DeliveryPerson? recipient,
    BankAgent? agent,
  }) => IssuanceDraft(
    deposit: deposit ?? this.deposit,
    type: type ?? this.type,
    address: clearAddress ? null : address ?? this.address,
    noPhysicalCard: noPhysicalCard ?? this.noPhysicalCard,
    otherRecipient: otherRecipient ?? this.otherRecipient,
    includeAgent: includeAgent ?? this.includeAgent,
    termsAccepted: termsAccepted ?? this.termsAccepted,
    recipient: recipient ?? this.recipient,
    agent: agent ?? this.agent,
  );
  @override
  List<Object?> get props => [
    deposit,
    type,
    address,
    noPhysicalCard,
    otherRecipient,
    includeAgent,
    termsAccepted,
    recipient,
    agent,
  ];
}
