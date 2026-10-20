part of 'occupations_cubit.dart';

enum OccupationEffect {
  actions,
  confirmDeletion,
  minimumOccupation,
  confirmExit,
  back,
  assistant,
  terms,
  submitted,
}

enum OccupationAction { edit, delete }

enum OccupationStep { list, form }

@Freezed(toStringOverride: false)
abstract class OccupationsState with _$OccupationsState {
  const factory OccupationsState.initial({
    @Default([]) List<ProfileOccupation> occupations,
    @Default(OccupationStep.list) OccupationStep step,
    @Default(RequestStatus.initial) RequestStatus occupationsStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(RequestStatus.initial) RequestStatus deletionStatus,
    Failure? occupationsFailure,
    Failure? submissionFailure,
    Failure? deletionFailure,
    ProfileOccupation? selectedOccupation,
    OccupationKind? kind,
    @Default('') String description,
    @Default(false) bool isDescriptionValid,
    @Default(false) bool isDescriptionError,
    ProfileOccupation? conflictingOccupation,
    @Default(false) bool requiresOperatorReview,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    String? idempotencyKey,
    OccupationEffect? effect,
    @Default(0) int effectId,
  }) = _OccupationsState;
}
