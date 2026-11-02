part of 'job_information_cubit.dart';

enum JobInformationEffect {
  actions,
  confirmDeletion,
  minimumJobInformation,
  confirmExit,
  back,
  assistant,
  terms,
  submitted,
}

enum JobInformationAction { edit, delete }

enum JobInformationStep { list, form }

@Freezed(toStringOverride: false)
abstract class JobInformationState with _$JobInformationState {
  const factory JobInformationState.initial({
    @Default([]) List<ProfileJobInformation> jobInformation,
    @Default(JobInformationStep.list) JobInformationStep step,
    @Default(RequestStatus.initial) RequestStatus jobInformationStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(RequestStatus.initial) RequestStatus deletionStatus,
    Failure? failure,
    String? message,

    ProfileJobInformation? selectedJobInformation,
    JobInformationKind? kind,
    @Default('') String description,
    @Default(false) bool isDescriptionValid,
    @Default(false) bool isDescriptionError,
    ProfileJobInformation? conflictingJobInformation,
    @Default(false) bool requiresOperatorReview,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    String? idempotencyKey,
    JobInformationEffect? effect,
  }) = _JobInformationState;
}
