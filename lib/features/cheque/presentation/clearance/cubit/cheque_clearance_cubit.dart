import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/cheque_request_validator.dart';

import '../../../domain/entities/cheque_clearance.dart';
import '../../../domain/usecases/cheque_clearance_usecase.dart';

part 'cheque_clearance_state.dart';
part 'cheque_clearance_cubit.freezed.dart';

class ChequeClearanceCubit extends Cubit<ChequeClearanceState> {
  ChequeClearanceCubit({
    ChequeClearanceState initialState = const ChequeClearanceState.initial(),
  }) : super(initialState);
  final fetchChequeClearanceCatalogUseCase =
      getIt<FetchChequeClearanceCatalogUseCase>();
  final submitChequeClearanceUseCase = getIt<SubmitChequeClearanceUseCase>();

  Future<void> fetchCatalog() async {
    emit(state.copyWith(catalogStatus: RequestStatus.loading));
    final result = await fetchChequeClearanceCatalogUseCase();
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
            isEditable: true,
            idempotencyKey: _createRequestKey(),
          ),
        );
    }
  }

  void selectDeposit(ChequeDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        chequeNumber: '',
        isChequeNumberValid: false,
        chequeNumberError: null,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void updateChequeNumber(String number) {
    final valid = ChequeRequestValidator.isChequeNumberValid(number);
    emit(
      state.copyWith(
        chequeNumber: number,
        isChequeNumberValid: valid,
        chequeNumberError: number.isNotEmpty && !valid
            ? ChequeNumberError.invalid
            : null,
        canSubmit: _canSubmit(isChequeNumberValid: valid),
        hasChanges: true,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void selectReason(ChequeClearanceReason reason) {
    final document = switch (reason) {
      ChequeClearanceReason.depositAndBlock ||
      ChequeClearanceReason.olderThanThreeYears => null,
      ChequeClearanceReason.originalCheque =>
        ChequeClearanceDocument.originalCheque,
      ChequeClearanceReason.partialPaymentCertificate =>
        ChequeClearanceDocument.partialPaymentCertificate,
      ChequeClearanceReason.notarizedConsent =>
        ChequeClearanceDocument.notarizedConsent,
      ChequeClearanceReason.judicialLetter =>
        ChequeClearanceDocument.judicialLetter,
    };
    emit(
      state.copyWith(
        reason: reason,
        requiredDocument: document,
        isJudicialLetterRequired:
            reason == ChequeClearanceReason.judicialLetter,
        isConsentRequired: reason == ChequeClearanceReason.notarizedConsent,
        judicialLetterNumber: '',
        isJudicialLetterNumberValid: false,
        isJudicialLetterNumberError: false,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void updateJudicialLetterNumber(String number) {
    final valid = ChequeRequestValidator.isJudicialLetterNumberValid(number);
    emit(
      state.copyWith(
        judicialLetterNumber: number,
        isJudicialLetterNumberValid: valid,
        isJudicialLetterNumberError: number.isNotEmpty && !valid,
        canSubmit: _canSubmit(isJudicialLetterNumberValid: valid),
        hasChanges: true,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit: _canSubmit(termsAccepted: accepted),
        hasChanges: true,
      ),
    );
  }

  Future<void> submitClearance() async {
    final request = ChequeClearanceRequest(
      depositId: state.deposit!.id,
      chequeNumber: state.chequeNumber,
      reason: state.reason!,
      judicialLetterNumber: state.isJudicialLetterRequired
          ? state.judicialLetterNumber
          : null,
      idempotencyKey: state.idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
      ),
    );
    final result = await submitChequeClearanceUseCase(request);
    switch (result) {
      case Err(:final failure):
        if (failure.code == 'cheque.not-found') {
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              isEditable: true,
              chequeNumberError: ChequeNumberError.notFound,
              canSubmit: false,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        } else {
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              isEditable: true,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        }
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            canSubmit: false,
            hasChanges: false,
          ),
        );
    }
  }

  void requestPostalOffices() {
    emit(state.copyWith(effect: ChequeClearanceEffect.postalOffices));
  }

  void requestTerms() {
    emit(state.copyWith(effect: ChequeClearanceEffect.contentUnavailable));
  }

  void requestConsentConditions() {
    emit(state.copyWith(effect: ChequeClearanceEffect.contentUnavailable));
  }

  void requestConsentSample() {
    emit(state.copyWith(effect: ChequeClearanceEffect.contentUnavailable));
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? ChequeClearanceEffect.confirmExit
            : ChequeClearanceEffect.back,
        isExitToAssistant: false,
      ),
    );
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? ChequeClearanceEffect.confirmExit
            : ChequeClearanceEffect.assistant,
        isExitToAssistant: true,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToAssistant
                  ? ChequeClearanceEffect.assistant
                  : ChequeClearanceEffect.back)
            : null,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: ChequeClearanceEffect.home));
  }

  bool _canSubmit({
    bool? isChequeNumberValid,
    bool? isJudicialLetterNumberValid,
    bool? termsAccepted,
  }) {
    return state.deposit != null &&
        state.reason != null &&
        (isChequeNumberValid ??
            (state.isChequeNumberValid &&
                state.chequeNumberError != ChequeNumberError.notFound)) &&
        (termsAccepted ?? state.termsAccepted) &&
        (isJudicialLetterNumberValid ??
            (!state.isJudicialLetterRequired ||
                state.isJudicialLetterNumberValid));
  }

  String _createRequestKey() =>
      'cheque-clearance-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeChequeClearanceInteraction() {
    emit(state.copyWith(effect: null));
  }
}
