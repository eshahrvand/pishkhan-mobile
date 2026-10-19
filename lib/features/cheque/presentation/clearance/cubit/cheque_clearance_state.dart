
part of 'cheque_clearance_cubit.dart';

enum ChequeNumberError { invalid, notFound }

enum ChequePostalStep { location, results }

enum ChequeClearanceEffect {
  back,
  confirmExit,
  assistant,
  home,
  postalOffices,
  contentUnavailable,
  sharePostalOffices,
}

@Freezed(toStringOverride: false)
abstract class ChequeClearanceState with _$ChequeClearanceState {
  const factory ChequeClearanceState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    ChequeClearanceCatalog? catalog,
    Failure? catalogFailure,
    ChequeDeposit? deposit,
    @Default('') String chequeNumber,
    @Default(false) bool isChequeNumberValid,
    ChequeNumberError? chequeNumberError,
    ChequeClearanceReason? reason,
    ChequeClearanceDocument? requiredDocument,
    @Default(false) bool isJudicialLetterRequired,
    @Default(false) bool isConsentRequired,
    @Default('') String judicialLetterNumber,
    @Default(false) bool isJudicialLetterNumberValid,
    @Default(false) bool isJudicialLetterNumberError,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    @Default(false) bool isEditable,
    @Default(false) bool hasChanges,
    @Default(false) bool isExitToAssistant,
    String? idempotencyKey,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    Failure? submissionFailure,
    ChequeClearanceReceipt? receipt,
    @Default(ChequePostalStep.location) ChequePostalStep postalStep,
    PostalProvince? province,
    PostalCity? city,
    @Default(<PostalCity>[]) List<PostalCity> cities,
    @Default(false) bool canSearchPostalOffices,
    @Default(RequestStatus.initial) RequestStatus postalOfficesStatus,
    Failure? postalOfficesFailure,
    @Default(<PostalOffice>[]) List<PostalOffice> postalOffices,
    String? postalShareText,
    ChequeClearanceEffect? effect,
    @Default(0) int effectId,
  }) = _ChequeClearanceState;
}
