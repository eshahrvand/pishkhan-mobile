import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/cheque_request_validator.dart';

import '../../../domain/entities/cheque_clearance.dart';
import '../../../domain/repositories/cheque_clearance_repository.dart';
import '../../../domain/usecases/cheque_clearance.dart';

part 'cheque_clearance_state.dart';
part 'cheque_clearance_cubit.freezed.dart';

class ChequeClearanceCubit extends Cubit<ChequeClearanceState> {
  ChequeClearanceCubit({
    ChequeClearanceState initialState = const ChequeClearanceState.initial(),
  }) : super(initialState);

  final _repository = getIt<ChequeClearanceRepository>();
  late final _fetchCatalog = FetchChequeClearanceCatalog(_repository);
  late final _fetchPostalOffices = FetchChequePostalOffices(_repository);
  late final _submitClearance = SubmitChequeClearance(_repository);

  int _postalRequestId = 0;

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        catalogFailure: null,
      ),
    );
    return _fetchCatalog().then((result) {
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
              isEditable: true,
              idempotencyKey: _createRequestKey(),
            ),
          );
      }
    });
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
        submissionFailure: null,
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
        canSubmit:
            valid &&
            state.deposit != null &&
            state.reason != null &&
            state.termsAccepted &&
            (!state.isJudicialLetterRequired ||
                state.isJudicialLetterNumberValid),
        hasChanges: true,
        submissionFailure: null,
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
        submissionFailure: null,
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
        canSubmit:
            valid &&
            state.deposit != null &&
            state.reason != null &&
            state.isChequeNumberValid &&
            state.chequeNumberError != ChequeNumberError.notFound &&
            state.termsAccepted,
        hasChanges: true,
        submissionFailure: null,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit:
            accepted &&
            state.deposit != null &&
            state.reason != null &&
            state.isChequeNumberValid &&
            state.chequeNumberError != ChequeNumberError.notFound &&
            (!state.isJudicialLetterRequired ||
                state.isJudicialLetterNumberValid),
        hasChanges: true,
      ),
    );
  }

  Future<void> submitClearance() {
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
        submissionFailure: null,
        isEditable: false,
      ),
    );
    return _submitClearance(request).then((result) {
      switch (result) {
        case Err(:final failure):
          if (failure.code == 'cheque.not-found') {
            emit(
              state.copyWith(
                submissionStatus: RequestStatus.failure,
                isEditable: true,
                chequeNumberError: ChequeNumberError.notFound,
                canSubmit: false,
              ),
            );
          } else {
            emit(
              state.copyWith(
                submissionStatus: RequestStatus.failure,
                submissionFailure: failure,
                isEditable: true,
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
    });
  }

  void requestPostalOffices() {
    // Reopening can overlap an earlier lookup whose sheet was dismissed.
    _postalRequestId++;
    emit(
      state.copyWith(
        postalStep: ChequePostalStep.location,
        postalOfficesStatus: RequestStatus.initial,
        postalOfficesFailure: null,
        effect: ChequeClearanceEffect.postalOffices,
        effectId: state.effectId + 1,
      ),
    );
  }

  void selectProvince(PostalProvince province) {
    emit(
      state.copyWith(
        province: province,
        cities: province.cities,
        city: null,
        canSearchPostalOffices: false,
        postalOffices: const [],
        postalOfficesStatus: RequestStatus.initial,
        postalOfficesFailure: null,
      ),
    );
  }

  void selectCity(PostalCity city) {
    emit(
      state.copyWith(
        city: city,
        canSearchPostalOffices: true,
        postalOffices: const [],
        postalOfficesStatus: RequestStatus.initial,
        postalOfficesFailure: null,
      ),
    );
  }

  Future<void> searchPostalOffices() {
    final requestId = ++_postalRequestId;
    emit(
      state.copyWith(
        postalOfficesStatus: RequestStatus.loading,
        postalOfficesFailure: null,
      ),
    );
    return _fetchPostalOffices(state.city!.id).then((result) {
      if (requestId != _postalRequestId) return;
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              postalOfficesStatus: RequestStatus.failure,
              postalOfficesFailure: failure,
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              postalOfficesStatus: RequestStatus.success,
              postalOffices: data,
              postalStep: ChequePostalStep.results,
            ),
          );
      }
    });
  }

  void requestPostalSearch() {
    emit(state.copyWith(postalStep: ChequePostalStep.location));
  }

  void requestPostalShare() {
    final text =
        '${state.province!.name} - ${state.city!.name}\n${state.postalOffices.map((office) => '• ${office.address}').join('\n')}';
    emit(
      state.copyWith(
        postalShareText: text,
        effect: ChequeClearanceEffect.sharePostalOffices,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestTerms() {
    emit(
      state.copyWith(
        effect: ChequeClearanceEffect.contentUnavailable,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestConsentConditions() {
    emit(
      state.copyWith(
        effect: ChequeClearanceEffect.contentUnavailable,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestConsentSample() {
    emit(
      state.copyWith(
        effect: ChequeClearanceEffect.contentUnavailable,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? ChequeClearanceEffect.confirmExit
            : ChequeClearanceEffect.back,
        isExitToAssistant: false,
        effectId: state.effectId + 1,
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
        effectId: state.effectId + 1,
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
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(
      state.copyWith(
        effect: ChequeClearanceEffect.home,
        effectId: state.effectId + 1,
      ),
    );
  }

  String _createRequestKey() =>
      'cheque-clearance-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
}
