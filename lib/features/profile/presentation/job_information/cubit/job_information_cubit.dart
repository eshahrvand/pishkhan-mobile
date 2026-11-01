import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/validators/required_text_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/personal_information.dart';
import '../../../domain/repositories/personal_information_repository.dart';
part 'job_information_state.dart';
part 'job_information_cubit.freezed.dart';

class JobInformationCubit extends Cubit<JobInformationState> {
  JobInformationCubit({
    JobInformationState initialState = const JobInformationState.initial(),
  }) : super(initialState);
  final repository = getIt<PersonalInformationRepository>();
  Future<void> fetchJobInformation() async {
    emit(state.copyWith(jobInformationStatus: RequestStatus.loading));
    final result = await repository.fetchJobInformation();
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            jobInformation: data,
            jobInformationStatus: RequestStatus.success,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            jobInformationStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void requestJobInformationActions(ProfileJobInformation jobInformation) {
    emit(
      state.copyWith(
        selectedJobInformation: jobInformation,
        effect: JobInformationEffect.actions,
      ),
    );
  }

  void applyJobInformationAction(JobInformationAction? action) {
    switch (action) {
      case JobInformationAction.edit:
        emit(
          state.copyWith(
            step: JobInformationStep.form,
            kind: state.selectedJobInformation!.kind,
            description: state.selectedJobInformation!.description,
            isDescriptionValid: true,
            isDescriptionError: false,
            conflictingJobInformation: null,
            requiresOperatorReview: false,
            termsAccepted: false,
            canSubmit: false,
            submissionStatus: RequestStatus.initial,
            idempotencyKey: null,
          ),
        );
      case JobInformationAction.delete:
        emit(
          state.copyWith(
            effect: state.jobInformation.length > 1
                ? JobInformationEffect.confirmDeletion
                : JobInformationEffect.minimumJobInformation,
          ),
        );
      case null:
        break;
    }
  }

  void requestNewJobInformation() {
    emit(
      state.copyWith(
        step: JobInformationStep.form,
        selectedJobInformation: null,
        kind: null,
        description: '',
        isDescriptionValid: false,
        isDescriptionError: false,
        conflictingJobInformation: null,
        requiresOperatorReview: false,
        termsAccepted: false,
        canSubmit: false,
        submissionStatus: RequestStatus.initial,
        idempotencyKey: null,
      ),
    );
  }

  void selectKind(JobInformationKind kind) {
    final conflict = state.selectedJobInformation == null
        ? state.jobInformation
              .where(
                (jobInformation) =>
                    _isDifferentJobInformationGroup(jobInformation.kind, kind),
              )
              .firstOrNull
        : null;
    emit(
      state.copyWith(
        kind: kind,
        submissionStatus: RequestStatus.initial,
        conflictingJobInformation: conflict,
        requiresOperatorReview:
            state.selectedJobInformation != null &&
            _isDifferentJobInformationGroup(
              state.selectedJobInformation!.kind,
              kind,
            ),
        canSubmit: _canSubmitJobInformation(
          kind,
          state.isDescriptionValid,
          state.termsAccepted,
          conflict,
        ),
        idempotencyKey: null,
      ),
    );
  }

  void updateDescription(String value) {
    final valid = RequiredTextValidator.isValid(value);
    emit(
      state.copyWith(
        description: value,
        submissionStatus: RequestStatus.initial,
        isDescriptionValid: valid,
        isDescriptionError: value.isNotEmpty && !valid,
        canSubmit: _canSubmitJobInformation(
          state.kind,
          valid,
          state.termsAccepted,
          state.conflictingJobInformation,
        ),
        idempotencyKey: null,
      ),
    );
  }

  void updateTerms(bool value) {
    emit(
      state.copyWith(
        termsAccepted: value,
        canSubmit: _canSubmitJobInformation(
          state.kind,
          state.isDescriptionValid,
          value,
          state.conflictingJobInformation,
        ),
      ),
    );
  }

  bool _canSubmitJobInformation(
    JobInformationKind? kind,
    bool isDescriptionValid,
    bool termsAccepted,
    ProfileJobInformation? conflict,
  ) {
    return kind != null &&
        isDescriptionValid &&
        conflict == null &&
        termsAccepted;
  }

  bool _isDifferentJobInformationGroup(
    JobInformationKind first,
    JobInformationKind second,
  ) {
    return (first == JobInformationKind.homemaker) !=
        (second == JobInformationKind.homemaker);
  }

  Future<void> submitJobInformation() async {
    final key =
        state.idempotencyKey ??
        'occupation-${DateTime.now().microsecondsSinceEpoch}';
    final jobInformation = ProfileJobInformation(
      id: state.selectedJobInformation?.id ?? key,
      kind: state.kind!,
      description: state.description.trim(),
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        idempotencyKey: key,
      ),
    );
    final result = await repository.saveJobInformation(
      jobInformation,
      idempotencyKey: key,
    );
    switch (result) {
      case Success():
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            canSubmit: false,
            effect: JobInformationEffect.submitted,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void applySubmissionDismissal() {
    emit(state.copyWith(step: JobInformationStep.list));
  }

  Future<void> submitDeletion(ProfileJobInformation jobInformation) async {
    emit(state.copyWith(deletionStatus: RequestStatus.loading));
    final result = await repository.deleteJobInformation(jobInformation.id);
    switch (result) {
      case Success():
        emit(
          state.copyWith(
            jobInformation: state.jobInformation
                .where((item) => item.id != jobInformation.id)
                .toList(),
            deletionStatus: RequestStatus.success,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            deletionStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.step == JobInformationStep.form
            ? JobInformationEffect.confirmExit
            : JobInformationEffect.back,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    if (confirmed == true) {
      emit(state.copyWith(step: JobInformationStep.list));
    }
  }

  void requestTerms() {
    emit(state.copyWith(effect: JobInformationEffect.terms));
  }

  void requestAssistant() {
    emit(state.copyWith(effect: JobInformationEffect.assistant));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeJobInformationInteraction() {
    emit(state.copyWith(effect: null));
  }
}
