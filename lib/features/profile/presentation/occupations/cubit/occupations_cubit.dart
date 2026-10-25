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
part 'occupations_state.dart';
part 'occupations_cubit.freezed.dart';

class OccupationsCubit extends Cubit<OccupationsState> {
  OccupationsCubit({
    OccupationsState initialState = const OccupationsState.initial(),
  }) : super(initialState);
  final repository = getIt<PersonalInformationRepository>();
  Future<void> fetchOccupations() {
    emit(
      state.copyWith(
        occupationsStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return repository.fetchOccupations().then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              occupations: data,
              occupationsStatus: RequestStatus.success,
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              occupationsStatus: RequestStatus.failure,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
      }
    });
  }

  void requestOccupationActions(ProfileOccupation occupation) {
    emit(
      state.copyWith(
        selectedOccupation: occupation,
        effect: OccupationEffect.actions,
        message: null,
      ),
    );
  }

  void applyOccupationAction(OccupationAction? action) {
    switch (action) {
      case OccupationAction.edit:
        emit(
          state.copyWith(
            step: OccupationStep.form,
            kind: state.selectedOccupation!.kind,
            description: state.selectedOccupation!.description,
            isDescriptionValid: true,
            isDescriptionError: false,
            conflictingOccupation: null,
            requiresOperatorReview: false,
            termsAccepted: false,
            canSubmit: false,
            submissionStatus: RequestStatus.initial,
            idempotencyKey: null,
            failure: null,
            message: null,
          ),
        );
      case OccupationAction.delete:
        emit(
          state.copyWith(
            effect: state.occupations.length > 1
                ? OccupationEffect.confirmDeletion
                : OccupationEffect.minimumOccupation,
            message: null,
          ),
        );
      case null:
        break;
    }
  }

  void requestNewOccupation() {
    emit(
      state.copyWith(
        step: OccupationStep.form,
        selectedOccupation: null,
        kind: null,
        description: '',
        isDescriptionValid: false,
        isDescriptionError: false,
        conflictingOccupation: null,
        requiresOperatorReview: false,
        termsAccepted: false,
        canSubmit: false,
        submissionStatus: RequestStatus.initial,
        idempotencyKey: null,
        failure: null,
        message: null,
      ),
    );
  }

  void selectKind(OccupationKind kind) {
    final conflict = state.selectedOccupation == null
        ? state.occupations
              .where(
                (occupation) =>
                    (occupation.kind == OccupationKind.homemaker) !=
                    (kind == OccupationKind.homemaker),
              )
              .firstOrNull
        : null;
    emit(
      state.copyWith(
        kind: kind,
        submissionStatus: RequestStatus.initial,
        conflictingOccupation: conflict,
        requiresOperatorReview:
            state.selectedOccupation != null &&
            (state.selectedOccupation!.kind == OccupationKind.homemaker) !=
                (kind == OccupationKind.homemaker),
        canSubmit:
            conflict == null && state.isDescriptionValid && state.termsAccepted,
        idempotencyKey: null,
        failure: null,
        message: null,
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
        canSubmit:
            valid &&
            state.kind != null &&
            state.conflictingOccupation == null &&
            state.termsAccepted,
        idempotencyKey: null,
        failure: null,
        message: null,
      ),
    );
  }

  void updateTerms(bool value) {
    emit(
      state.copyWith(
        termsAccepted: value,
        canSubmit:
            value &&
            state.kind != null &&
            state.isDescriptionValid &&
            state.conflictingOccupation == null,
      ),
    );
  }

  Future<void> submitOccupation() {
    final key =
        state.idempotencyKey ??
        'occupation-${DateTime.now().microsecondsSinceEpoch}';
    final occupation = ProfileOccupation(
      id: state.selectedOccupation?.id ?? key,
      kind: state.kind!,
      description: state.description.trim(),
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        idempotencyKey: key,
        failure: null,
        message: null,
      ),
    );
    return repository.saveOccupation(occupation, idempotencyKey: key).then((
      result,
    ) {
      switch (result) {
        case Success():
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              canSubmit: false,
              effect: OccupationEffect.submitted,
              message: null,
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
    });
  }

  void applySubmissionDismissal() {
    emit(state.copyWith(step: OccupationStep.list));
  }

  Future<void> submitDeletion(ProfileOccupation occupation) {
    emit(
      state.copyWith(
        deletionStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return repository.deleteOccupation(occupation.id).then((result) {
      switch (result) {
        case Success():
          emit(
            state.copyWith(
              occupations: state.occupations
                  .where((item) => item.id != occupation.id)
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
    });
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.step == OccupationStep.form
            ? OccupationEffect.confirmExit
            : OccupationEffect.back,
        message: null,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    if (confirmed == true) {
      emit(state.copyWith(step: OccupationStep.list));
    }
  }

  void requestTerms() {
    emit(state.copyWith(effect: OccupationEffect.terms, message: null));
  }

  void requestAssistant() {
    emit(state.copyWith(effect: OccupationEffect.assistant, message: null));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeOccupationsInteraction() {
    emit(state.copyWith(effect: null));
  }
}
