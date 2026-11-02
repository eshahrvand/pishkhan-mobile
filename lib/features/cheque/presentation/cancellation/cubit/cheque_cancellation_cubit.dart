import 'dart:math';

import 'package:avp_ui/avp_ui.dart' show DigitNormalizer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/cheque_cancellation.dart';
import '../../../domain/entities/cheque_clearance.dart';
import '../../../domain/usecases/cheque_cancellation_usecase.dart';

part 'cheque_cancellation_state.dart';
part 'cheque_cancellation_cubit.freezed.dart';

class ChequeCancellationCubit extends Cubit<ChequeCancellationState> {
  ChequeCancellationCubit({
    this.initialDepositNumber,
    ChequeCancellationState initialState =
        const ChequeCancellationState.initial(),
  }) : super(initialState);
  final fetchChequeCancellationCatalogUseCase =
      getIt<FetchChequeCancellationCatalogUseCase>();
  final fetchCancellableChequesUseCase =
      getIt<FetchCancellableChequesUseCase>();
  final submitChequeCancellationUseCase =
      getIt<SubmitChequeCancellationUseCase>();

  final String? initialDepositNumber;
  int _chequesRequestId = 0;

  Future<void> fetchCatalog() async {
    emit(state.copyWith(catalogStatus: RequestStatus.loading));
    final result = await fetchChequeCancellationCatalogUseCase();
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
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
      ),
    );
  }

  Future<void> continueFlow() async {
    switch (state.step) {
      case ChequeCancellationStep.selection:
        await fetchCheques();
      case ChequeCancellationStep.cheques:
        emit(
          state.copyWith(
            isReviewContinuing: true,
            effect: ChequeCancellationEffect.review,
          ),
        );
      case ChequeCancellationStep.reasons:
        emit(
          state.copyWith(
            step: ChequeCancellationStep.confirmation,
            stepNumber: 4,
            submissionStatus: RequestStatus.initial,
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
        await submitCancellation();
    }
  }

  Future<void> fetchCheques() async {
    // Back/re-entry can overlap the previous list request.
    final requestId = ++_chequesRequestId;
    emit(
      state.copyWith(
        step: ChequeCancellationStep.cheques,
        stepNumber: 2,
        chequesStatus: RequestStatus.loading,
        canContinue: false,
      ),
    );
    final result = await fetchCancellableChequesUseCase(
      state.deposit!.id,
      state.type!,
    );
    if (requestId != _chequesRequestId) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            chequesStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
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
            canContinue: _hasSelectedCheques(state.selectedEntries),
          ),
        );
    }
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
        canContinue: _hasSelectedCheques(entries),
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
        canContinue: _hasSelectedCheques(entries),
        confirmedRequest: null,
      ),
    );
  }

  void requestSelectedCheques() {
    emit(
      state.copyWith(
        isReviewContinuing: false,
        effect: ChequeCancellationEffect.review,
      ),
    );
  }

  void applyReviewDismissal(bool? continued) {
    if (_canContinueAfterReview(continued)) {
      emit(
        state.copyWith(
          step: ChequeCancellationStep.reasons,
          stepNumber: 3,
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
      ),
    );
  }

  void requestReviewChequeRemoval(CancellableCheque cheque) {
    emit(
      state.copyWith(
        pendingCheque: cheque,
        effect: ChequeCancellationEffect.deleteReviewCheque,
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
              : _hasSelectedCheques(entries),
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

  Future<void> submitCancellation() async {
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
      ),
    );
    final result = await submitChequeCancellationUseCase(
      state.confirmedRequest!,
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            isEditable: true,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            canContinue: false,
            effect: ChequeCancellationEffect.receipt,
          ),
        );
    }
  }

  void requestPostalOffices() {
    emit(state.copyWith(effect: ChequeCancellationEffect.postalOffices));
  }

  void requestLetter() {
    emit(state.copyWith(effect: ChequeCancellationEffect.contentUnavailable));
  }

  void requestTerms() {
    emit(state.copyWith(effect: ChequeCancellationEffect.contentUnavailable));
  }

  void requestBack() {
    switch (state.step) {
      case ChequeCancellationStep.selection:
        emit(
          state.copyWith(
            isExitToAssistant: false,
            effect: _hasSelection()
                ? ChequeCancellationEffect.confirmExit
                : ChequeCancellationEffect.back,
          ),
        );
      case ChequeCancellationStep.cheques:
        _chequesRequestId++;
        emit(
          state.copyWith(
            step: ChequeCancellationStep.selection,
            stepNumber: 1,
            chequesStatus: RequestStatus.initial,
            canContinue: true,
          ),
        );
      case ChequeCancellationStep.reasons:
        emit(
          state.copyWith(
            step: ChequeCancellationStep.cheques,
            stepNumber: 2,
            canContinue: _hasSelectedCheques(state.selectedEntries),
          ),
        );
      case ChequeCancellationStep.confirmation:
        emit(
          state.copyWith(
            step: ChequeCancellationStep.reasons,
            stepNumber: 3,
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
        effect: _hasSelection()
            ? ChequeCancellationEffect.confirmExit
            : ChequeCancellationEffect.assistant,
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
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: ChequeCancellationEffect.home));
  }

  bool _hasSelection() => state.deposit != null || state.type != null;

  bool _hasSelectedCheques(List<ChequeCancellationEntry> entries) =>
      entries.isNotEmpty;

  bool _canContinueAfterReview(bool? continued) =>
      continued == true &&
      state.isReviewContinuing &&
      _hasSelectedCheques(state.selectedEntries);

  bool _hasReasons(List<ChequeCancellationEntry> entries) =>
      _hasSelectedCheques(entries) &&
      entries.every((entry) => entry.reason != null);
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

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeChequeCancellationInteraction() {
    emit(state.copyWith(effect: null));
  }
}
