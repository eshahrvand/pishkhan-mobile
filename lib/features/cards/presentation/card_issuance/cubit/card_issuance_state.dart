import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/issuance_data.dart';
import '../../../domain/entities/issuance_draft.dart';
export '../../../domain/entities/issuance_draft.dart';

part 'card_issuance_state.freezed.dart';

enum IssuanceStep { selection, delivery, confirmation }

@freezed
abstract class CardIssuanceState with _$CardIssuanceState {
  const factory CardIssuanceState({
    IssuanceDeposit? deposit,
    IssuanceAddress? address,
    @Default(false) bool selectionComplete,
    @Default(false) bool deliveryComplete,
    @Default(<IssuanceFee>[]) List<IssuanceFee> fees,
    @Default(0) int totalRial,
    @Default(false) bool walletSufficient,
    @Default(false) bool editable,
    @Default(false) bool canContinue,
    IssuanceRequest? request,
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    IssuanceCatalog? catalog,
    @Default(IssuanceDraft()) IssuanceDraft draft,
    @Default(IssuanceStep.selection) IssuanceStep step,
    @Default(true) bool invoiceExpanded,
    @Default(true) bool summaryExpanded,
    Failure? failure,
    IssuanceReceipt? receipt,
  }) = _CardIssuanceState;
}
