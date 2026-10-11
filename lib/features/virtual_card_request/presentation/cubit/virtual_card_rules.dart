import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'virtual_card_state.dart';

int? virtualCardCount(VirtualCardState state) => int.tryParse(state.countText);

bool virtualCardValidCount(VirtualCardState state) =>
    RegExp(r'^[0-9]+$').hasMatch(state.countText) &&
    virtualCardCount(state) != null &&
    virtualCardCount(state)! >= 1 &&
    virtualCardCount(state)! <= (state.catalog?.maxCount ?? 0);

bool virtualCardEditable(VirtualCardState state) =>
    state.status == RequestStatus.success &&
    state.catalog?.deposits.isNotEmpty == true &&
    state.submissionStatus != RequestStatus.loading &&
    state.submissionStatus != RequestStatus.success;

bool virtualCardCanSubmit(VirtualCardState state) =>
    virtualCardEditable(state) &&
    state.quoteStatus == RequestStatus.success &&
    state.terms &&
    virtualCardValidCount(state) &&
    state.quote != null &&
    state.quote!.depositId == state.depositId &&
    state.quote!.count == virtualCardCount(state) &&
    state.quote!.walletSufficient;
