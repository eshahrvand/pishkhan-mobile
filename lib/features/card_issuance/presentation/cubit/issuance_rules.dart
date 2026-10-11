import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'card_issuance_state.dart';
import '../../domain/entities/issuance_data.dart';

IssuanceDeposit? issuanceDeposit(CardIssuanceState state) {
  for (final value in state.catalog?.deposits ?? <IssuanceDeposit>[]) {
    if (value.id == state.draft.depositId) return value;
  }
  return null;
}

IssuanceAddress? issuanceAddress(CardIssuanceState state) {
  for (final value in state.catalog?.addresses ?? <IssuanceAddress>[]) {
    if (value.id == state.draft.addressId) return value;
  }
  return null;
}

bool issuanceSelectionComplete(CardIssuanceState state) =>
    issuanceDeposit(state) != null &&
    state.draft.type != null &&
    (state.catalog?.types.contains(state.draft.type) ?? false);

bool issuanceDeliveryComplete(CardIssuanceState state) =>
    state.draft.noPhysicalCard ||
    (issuanceAddress(state) != null &&
        (!state.draft.otherRecipient || state.draft.recipient.isComplete) &&
        (!state.draft.includeAgent || state.draft.agent.isComplete));

List<IssuanceFee> issuanceFees(CardIssuanceState state) => List.unmodifiable(
  (state.catalog?.fees ?? <IssuanceFee>[]).where(
    (fee) =>
        !state.draft.noPhysicalCard || fee.kind != IssuanceFeeKind.delivery,
  ),
);

int issuanceTotalRial(CardIssuanceState state) =>
    issuanceFees(state).fold(0, (sum, fee) => sum + fee.amountRial);

bool issuanceWalletSufficient(CardIssuanceState state) =>
    state.catalog != null &&
    state.catalog!.walletBalanceRial >= issuanceTotalRial(state);

bool issuanceIsEditable(CardIssuanceState state) =>
    state.status == RequestStatus.success &&
    state.submissionStatus != RequestStatus.loading &&
    state.submissionStatus != RequestStatus.success &&
    state.catalog?.deposits.isNotEmpty == true &&
    state.catalog?.types.isNotEmpty == true;

bool issuanceCanContinue(CardIssuanceState state) =>
    issuanceIsEditable(state) &&
    switch (state.step) {
      IssuanceStep.selection => issuanceSelectionComplete(state),
      IssuanceStep.delivery =>
        issuanceSelectionComplete(state) && issuanceDeliveryComplete(state),
      IssuanceStep.confirmation =>
        issuanceSelectionComplete(state) &&
            issuanceDeliveryComplete(state) &&
            state.draft.termsAccepted &&
            issuanceWalletSufficient(state),
    };

IssuanceRequest? issuanceRequest(CardIssuanceState state) =>
    issuanceSelectionComplete(state) && issuanceDeliveryComplete(state)
    ? IssuanceRequest(
        depositId: issuanceDeposit(state)!.id,
        type: state.draft.type!,
        noPhysicalCard: state.draft.noPhysicalCard,
        address: state.draft.noPhysicalCard ? null : issuanceAddress(state),
        recipient: !state.draft.noPhysicalCard && state.draft.otherRecipient
            ? state.draft.recipient
            : null,
        agent: !state.draft.noPhysicalCard && state.draft.includeAgent
            ? state.draft.agent
            : null,
      )
    : null;
