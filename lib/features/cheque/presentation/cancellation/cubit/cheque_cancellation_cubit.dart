import 'dart:math';

import 'package:avp_ui/avp_ui.dart' show DigitNormalizer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/cheque_cancellation.dart';
import '../../../domain/entities/cheque_clearance.dart';
import '../../../domain/repositories/cheque_cancellation_repository.dart';
import '../../../domain/usecases/cheque_cancellation.dart';

part 'cheque_cancellation_state.dart';
part 'cheque_cancellation_cubit.freezed.dart';

class ChequeCancellationCubit extends Cubit<ChequeCancellationState> {
  ChequeCancellationCubit({
    this.initialDepositNumber,
    ChequeCancellationState initialState =
        const ChequeCancellationState.initial(),
  }) : super(initialState);
  final String? initialDepositNumber;
  final repository = getIt<ChequeCancellationRepository>();
  int _chequesRequestId = 0;

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        catalogFailure: null,
      ),
    );
    return FetchChequeCancellationCatalog(repository)().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.failure,
              catalogFailure: failure,
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              deposit: data.deposits
                  .where((deposit) => deposit.number == initialDepositNumber)
                  .firstOrNull,
              isEditable: true,
            ),
          );
      }
    });
  }

  void selectDeposit(ChequeDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        cheques: const [],
        visibleCheques: const [],
        selectedEntries: const [],
        searchQuery: '',
        isAllSelected: false,
        canContinue: state.type != null,
        confirmedRequest: null,
        submissionFailure: null,
      ),
    );
  }

  void selectType(CancellationChequeType type) {
    emit(
      state.copyWith(
        type: type,
        cheques: const [],
        visibleCheques: const [],
        selectedEntries: const [],
        searchQuery: '',
        isAllSelected: false,
        canContinue: state.deposit != null,
        confirmedRequest: null,
        submissionFailure: null,
      ),
    );
  }

  Future<void> continueFlow() {
    switch (state.step) {
      case ChequeCancellationStep.selection:
        return fetchCheques();
      case ChequeCancellationStep.cheques:
        emit(
          state.copyWith(
            isReviewContinuing: true,
            effect: ChequeCancellationEffect.review,
            effectId: state.effectId + 1,
          ),
        );
      case ChequeCancellationStep.reasons:
        emit(
          state.copyWith(
            step: ChequeCancellationStep.confirmation,
            stepNumber: 4,
            stepRevealId: state.stepRevealId + 1,
            submissionStatus: RequestStatus.initial,
            submissionFailure: null,
            termsAccepted: false,
            canContinue: false,
            confirmedRequest:
                state.confirmedRequest ??
                ChequeCancellationRequest(
                  depositId: state.deposit!.id,
                  type: state.type!,
                  entries: state.selectedEntries,
                  idempotencyKey:
                      'cheque-cancel-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
                ),
          ),
        );
      case ChequeCancellationStep.confirmation:
        return submitCancellation();
    }
    return Future.value();
  }

  Future<void> fetchCheques() {
    // Back/re-entry can overlap the previous list request.
    final requestId = ++_chequesRequestId;
    emit(
      state.copyWith(
        step: ChequeCancellationStep.cheques,
        stepNumber: 2,
        stepRevealId: state.stepRevealId + 1,
        chequesStatus: RequestStatus.loading,
        chequesFailure: null,
        canContinue: false,
      ),
    );
    return FetchCancellableCheques(repository)(
      state.deposit!.id,
      state.type!,
    ).then((result) {
      if (requestId != _chequesRequestId) return;
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              chequesStatus: RequestStatus.failure,
              chequesFailure: failure,
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              chequesStatus: RequestStatus.success,
              cheques: data,
              visibleCheques: _visibleCheques(
                data,
                state.searchQuery,
                state.selectedEntries,
              ),
              canContinue: state.selectedEntries.isNotEmpty,
            ),
          );
      }
    });
  }

  void updateSearchQuery(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        visibleCheques: _visibleCheques(
          state.cheques,
          query,
          state.selectedEntries,
        ),
      ),
    );
  }

  void toggleCheque(CancellableCheque cheque) {
    final entries = state.selectedEntries.any((entry) => entry.cheque == cheque)
        ? state.selectedEntries
              .where((entry) => entry.cheque != cheque)
              .toList()
        : [...state.selectedEntries, ChequeCancellationEntry(cheque: cheque)];
    emit(
      state.copyWith(
        selectedEntries: entries,
        visibleCheques: _visibleCheques(
          state.cheques,
          state.searchQuery,
          entries,
        ),
        isAllSelected: entries.length == state.cheques.length,
        canContinue: entries.isNotEmpty,
        confirmedRequest: null,
      ),
    );
  }

  void toggleAllCheques(bool selected) {
    final entries = selected
        ? [
            for (final cheque in state.cheques)
              state.selectedEntries
                      .where((entry) => entry.cheque == cheque)
                      .firstOrNull ??
                  ChequeCancellationEntry(cheque: cheque),
          ]
        : <ChequeCancellationEntry>[];
    emit(
      state.copyWith(
        selectedEntries: entries,
        visibleCheques: _visibleCheques(
          state.cheques,
          state.searchQuery,
          entries,
        ),
        isAllSelected: selected,
        canContinue: entries.isNotEmpty,
        confirmedRequest: null,
      ),
    );
  }

  void requestSelectedCheques() {
    emit(
      state.copyWith(
        isReviewContinuing: false,
        effect: ChequeCancellationEffect.review,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyReviewDismissal(bool? continued) {
    final advance =
        continued == true &&
        state.isReviewContinuing &&
        state.selectedEntries.isNotEmpty;
    if (advance) {
      emit(
        state.copyWith(
          step: ChequeCancellationStep.reasons,
          stepNumber: 3,
          stepRevealId: state.stepRevealId + 1,
          canContinue: _hasReasons(state.selectedEntries),
          effect: null,
        ),
      );
    } else {
      emit(state.copyWith(effect: null));
    }
  }

  void requestChequeRemoval(CancellableCheque cheque) {
    emit(
      state.copyWith(
        pendingCheque: cheque,
        effect: ChequeCancellationEffect.deleteCheque,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestReviewChequeRemoval(CancellableCheque cheque) {
    emit(
      state.copyWith(
        pendingCheque: cheque,
        effect: ChequeCancellationEffect.deleteReviewCheque,
        effectId: state.effectId + 1,
      ),
    );
  }

  void removeCheque(CancellableCheque cheque) {
    final entries = state.selectedEntries
        .where((entry) => entry.cheque != cheque)
        .toList();
    if (entries.isEmpty && state.step == ChequeCancellationStep.reasons) {
      emit(
        state.copyWith(
          selectedEntries: entries,
          visibleCheques: _visibleCheques(
            state.cheques,
            state.searchQuery,
            entries,
          ),
          isAllSelected: false,
          step: ChequeCancellationStep.cheques,
          stepNumber: 2,
          stepRevealId: state.stepRevealId + 1,
          canContinue: false,
          confirmedRequest: null,
          pendingCheque: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          selectedEntries: entries,
          visibleCheques: _visibleCheques(
            state.cheques,
            state.searchQuery,
            entries,
          ),
          isAllSelected: false,
          canContinue: state.step == ChequeCancellationStep.reasons
              ? _hasReasons(entries)
              : entries.isNotEmpty,
          confirmedRequest: null,
          pendingCheque: null,
        ),
      );
    }
  }

  void requestReason(ChequeCancellationEntry entry) {
    emit(
      state.copyWith(
        pendingCheque: entry.cheque,
        reasonDraft: entry.reason,
        isReasonForAll: false,
        effect: ChequeCancellationEffect.reason,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestReasonForAll() {
    emit(
      state.copyWith(
        pendingCheque: null,
        reasonDraft: null,
        isReasonForAll: true,
        effect: ChequeCancellationEffect.reason,
        effectId: state.effectId + 1,
      ),
    );
  }

  void selectReasonDraft(ChequeCancellationReason reason) {
    emit(state.copyWith(reasonDraft: reason));
  }

  void applyReason() {
    final entries = [
      for (final entry in state.selectedEntries)
        if (state.isReasonForAll || entry.cheque == state.pendingCheque)
          ChequeCancellationEntry(
            cheque: entry.cheque,
            reason: state.reasonDraft!,
          )
        else
          entry,
    ];
    emit(
      state.copyWith(
        selectedEntries: entries,
        canContinue: _hasReasons(entries),
        confirmedRequest: null,
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(state.copyWith(termsAccepted: accepted, canContinue: accepted));
  }

  Future<void> submitCancellation() {
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        submissionFailure: null,
        isEditable: false,
      ),
    );
    return SubmitChequeCancellation(repository)(state.confirmedRequest!)
        .then((result) {
          switch (result) {
            case Err(:final failure):
              emit(
                state.copyWith(
                  submissionStatus: RequestStatus.failure,
                  submissionFailure: failure,
                  isEditable: true,
                ),
              );
            case Success(:final data):
              emit(
                state.copyWith(
                  submissionStatus: RequestStatus.success,
                  receipt: data,
                  canContinue: false,
                  effect: ChequeCancellationEffect.receipt,
                  effectId: state.effectId + 1,
                ),
              );
          }
        });
  }

  void requestPostalOffices() {
    emit(
      state.copyWith(
        effect: ChequeCancellationEffect.postalOffices,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestLetter() {
    emit(
      state.copyWith(
        effect: ChequeCancellationEffect.contentUnavailable,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestTerms() {
    emit(
      state.copyWith(
        effect: ChequeCancellationEffect.contentUnavailable,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestBack() {
    switch (state.step) {
      case ChequeCancellationStep.selection:
        emit(
          state.copyWith(
            isExitToAssistant: false,
            effect: state.deposit != null || state.type != null
                ? ChequeCancellationEffect.confirmExit
                : ChequeCancellationEffect.back,
            effectId: state.effectId + 1,
          ),
        );
      case ChequeCancellationStep.cheques:
        _chequesRequestId++;
        emit(
          state.copyWith(
            step: ChequeCancellationStep.selection,
            stepNumber: 1,
            stepRevealId: state.stepRevealId + 1,
            chequesStatus: RequestStatus.initial,
            canContinue: true,
          ),
        );
      case ChequeCancellationStep.reasons:
        emit(
          state.copyWith(
            step: ChequeCancellationStep.cheques,
            stepNumber: 2,
            stepRevealId: state.stepRevealId + 1,
            canContinue: state.selectedEntries.isNotEmpty,
          ),
        );
      case ChequeCancellationStep.confirmation:
        emit(
          state.copyWith(
            step: ChequeCancellationStep.reasons,
            stepNumber: 3,
            stepRevealId: state.stepRevealId + 1,
            termsAccepted: false,
            canContinue: _hasReasons(state.selectedEntries),
          ),
        );
    }
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        isExitToAssistant: true,
        effect: state.deposit != null || state.type != null
            ? ChequeCancellationEffect.confirmExit
            : ChequeCancellationEffect.assistant,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToAssistant
                  ? ChequeCancellationEffect.assistant
                  : ChequeCancellationEffect.back)
            : null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(
      state.copyWith(
        effect: ChequeCancellationEffect.home,
        effectId: state.effectId + 1,
      ),
    );
  }

  bool _hasReasons(List<ChequeCancellationEntry> entries) =>
      entries.isNotEmpty && entries.every((entry) => entry.reason != null);
  List<CancellationChequeChoice> _visibleCheques(
    List<CancellableCheque> cheques,
    String query,
    List<ChequeCancellationEntry> entries,
  ) {
    final normalized = DigitNormalizer.normalize(query)
        .replaceAll(RegExp(r'[\s/.-]'), '');
    return [
      for (final cheque in cheques)
        if (cheque.number.replaceAll('/', '').contains(normalized) ||
            cheque.sayadId.contains(normalized))
          CancellationChequeChoice(
            cheque: cheque,
            isSelected: entries.any((entry) => entry.cheque == cheque),
          ),
    ];
  }
}
