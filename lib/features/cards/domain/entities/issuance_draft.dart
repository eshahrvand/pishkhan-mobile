import 'package:equatable/equatable.dart';

import 'issuance_data.dart';

class IssuanceDraft extends Equatable {
  const IssuanceDraft({
    this.depositId,
    this.type,
    this.addressId,
    this.noPhysicalCard = false,
    this.otherRecipient = false,
    this.includeAgent = false,
    this.termsAccepted = false,
    this.recipient = const DeliveryPerson(),
    this.agent = const BankAgent(),
  });
  final String? depositId, addressId;
  final IssuanceType? type;
  final bool noPhysicalCard, otherRecipient, includeAgent, termsAccepted;
  final DeliveryPerson recipient;
  final BankAgent agent;
  IssuanceDraft copyWith({
    String? depositId,
    bool clearDeposit = false,
    IssuanceType? type,
    bool clearType = false,
    String? addressId,
    bool clearAddress = false,
    bool? noPhysicalCard,
    bool? otherRecipient,
    bool? includeAgent,
    bool? termsAccepted,
    DeliveryPerson? recipient,
    BankAgent? agent,
  }) => IssuanceDraft(
    depositId: clearDeposit ? null : depositId ?? this.depositId,
    type: clearType ? null : type ?? this.type,
    addressId: clearAddress ? null : addressId ?? this.addressId,
    noPhysicalCard: noPhysicalCard ?? this.noPhysicalCard,
    otherRecipient: otherRecipient ?? this.otherRecipient,
    includeAgent: includeAgent ?? this.includeAgent,
    termsAccepted: termsAccepted ?? this.termsAccepted,
    recipient: recipient ?? this.recipient,
    agent: agent ?? this.agent,
  );
  @override
  List<Object?> get props => [
    depositId,
    type,
    addressId,
    noPhysicalCard,
    otherRecipient,
    includeAgent,
    termsAccepted,
    recipient,
    agent,
  ];
}
