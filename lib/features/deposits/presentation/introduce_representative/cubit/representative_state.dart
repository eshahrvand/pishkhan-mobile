part of 'representative_cubit.dart';

enum RepresentativeEffect { addNext, confirmExit, back, home }

@Freezed(toStringOverride: false)
abstract class RepresentativeState with _$RepresentativeState {
  const factory RepresentativeState.initial({
    @Default(RequestStatus.initial) RequestStatus depositsStatus,
    @Default(<ListedDeposit>[]) List<ListedDeposit> deposits,
    Failure? depositsFailure,
    ListedDeposit? deposit,
    RepresentativeOperation? operation,
    @Default('') String nationalId,
    @Default(false) bool isNationalIdValid,
    @Default(false) bool isNationalIdError,
    @Default('') String validityText,
    DateTime? validUntil,
    @Default(false) bool isValidityValid,
    @Default(false) bool isValidityError,
    @Default(false) bool canSaveDraft,
    @Default(0) int draftSavedId,
    @Default(<PendingRepresentative>[])
    List<PendingRepresentative> representatives,
    @Default(false) bool hasChanges,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    @Default(true) bool isEditable,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    Failure? submissionFailure,
    RepresentativeReceipt? receipt,
    RepresentativeEffect? effect,
    @Default(0) int effectId,
    @Default(false) bool isExitToHome,
  }) = _RepresentativeState;
}
