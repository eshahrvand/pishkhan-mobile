import 'package:equatable/equatable.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../domain/entities/issuance_data.dart';

enum IssuanceStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
  submitting,
  submitted,
}

enum IssuanceStep { selection, delivery, confirmation }

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

class CardIssuanceState extends Equatable {
  const CardIssuanceState({
    this.status = IssuanceStatus.initial,
    this.catalog,
    this.draft = const IssuanceDraft(),
    this.step = IssuanceStep.selection,
    this.invoiceExpanded = true,
    this.summaryExpanded = true,
    this.failure,
    this.receipt,
  });
  final IssuanceStatus status;
  final IssuanceCatalog? catalog;
  final IssuanceDraft draft;
  final IssuanceStep step;
  final bool invoiceExpanded, summaryExpanded;
  final Failure? failure;
  final IssuanceReceipt? receipt;
  IssuanceDeposit? get deposit {
    for (final value in catalog?.deposits ?? <IssuanceDeposit>[]) {
      if (value.id == draft.depositId) return value;
    }
    return null;
  }

  IssuanceAddress? get address {
    for (final value in catalog?.addresses ?? <IssuanceAddress>[]) {
      if (value.id == draft.addressId) return value;
    }
    return null;
  }

  bool get selectionComplete =>
      deposit != null &&
      draft.type != null &&
      (catalog?.types.contains(draft.type) ?? false);
  bool get deliveryComplete =>
      draft.noPhysicalCard ||
      (address != null &&
          (!draft.otherRecipient || draft.recipient.isComplete) &&
          (!draft.includeAgent || draft.agent.isComplete));
  List<IssuanceFee> get fees => List.unmodifiable(
    (catalog?.fees ?? <IssuanceFee>[]).where(
      (fee) => !draft.noPhysicalCard || fee.kind != IssuanceFeeKind.delivery,
    ),
  );
  int get totalRial => fees.fold(0, (sum, fee) => sum + fee.amountRial);
  bool get walletSufficient =>
      catalog != null && catalog!.walletBalanceRial >= totalRial;
  bool get isEditable => status == IssuanceStatus.loaded;
  bool get canContinue =>
      isEditable &&
      switch (step) {
        IssuanceStep.selection => selectionComplete,
        IssuanceStep.delivery => selectionComplete && deliveryComplete,
        IssuanceStep.confirmation =>
          selectionComplete &&
              deliveryComplete &&
              draft.termsAccepted &&
              walletSufficient,
      };
  IssuanceRequest? get request => selectionComplete && deliveryComplete
      ? IssuanceRequest(
          depositId: deposit!.id,
          type: draft.type!,
          noPhysicalCard: draft.noPhysicalCard,
          address: draft.noPhysicalCard ? null : address,
          recipient: !draft.noPhysicalCard && draft.otherRecipient
              ? draft.recipient
              : null,
          agent: !draft.noPhysicalCard && draft.includeAgent
              ? draft.agent
              : null,
        )
      : null;
  CardIssuanceState copyWith({
    IssuanceStatus? status,
    IssuanceCatalog? catalog,
    IssuanceDraft? draft,
    IssuanceStep? step,
    bool? invoiceExpanded,
    bool? summaryExpanded,
    Failure? failure,
    bool clearFailure = false,
    IssuanceReceipt? receipt,
  }) => CardIssuanceState(
    status: status ?? this.status,
    catalog: catalog ?? this.catalog,
    draft: draft ?? this.draft,
    step: step ?? this.step,
    invoiceExpanded: invoiceExpanded ?? this.invoiceExpanded,
    summaryExpanded: summaryExpanded ?? this.summaryExpanded,
    failure: clearFailure ? null : failure ?? this.failure,
    receipt: receipt ?? this.receipt,
  );
  @override
  List<Object?> get props => [
    status,
    catalog,
    draft,
    step,
    invoiceExpanded,
    summaryExpanded,
    failure,
    receipt,
  ];
}
