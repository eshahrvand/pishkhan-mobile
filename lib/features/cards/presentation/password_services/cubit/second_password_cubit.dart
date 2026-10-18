import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/second_password_validator.dart';

import '../../../domain/entities/password_data.dart';
import '../../../domain/repositories/password_services_repository.dart';
import '../../../domain/usecases/password_services.dart';
import 'password_effect.dart';

export 'password_effect.dart';

part 'second_password_state.dart';
part 'second_password_cubit.freezed.dart';

class SecondPasswordCubit extends Cubit<SecondPasswordState> {
  SecondPasswordCubit({
    SecondPasswordState initialState = const SecondPasswordState.initial(),
    this.initialCardNumber,
    this.selectOperation = false,
  }) : super(initialState);

  final _repository = getIt<PasswordServicesRepository>();
  final String? initialCardNumber;
  final bool selectOperation;

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        catalogFailure: null,
      ),
    );
    return LoadPasswordCatalog(_repository)().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.failure,
              catalogFailure: failure,
            ),
          );
        case Success(:final data):
          final number = _normalizeCardNumber(initialCardNumber ?? '');
          final card = initialCardNumber == null
              ? null
              : data.cards
                    .where(
                      (card) => _normalizeCardNumber(card.number) == number,
                    )
                    .firstOrNull;
          final operation = selectOperation
              ? null
              : PasswordOperation.setSecondPassword;
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              kind: card?.kind,
              card: card,
              operation: operation,
              cardsForSelectedKind: _cardsForKind(data, card?.kind),
              isOperationSupported:
                  card != null && operation != null && card.supports(operation),
              isWalletSufficient: data.walletBalanceRial >= data.feeRial,
              isEditable: data.cards.isNotEmpty,
            ),
          );
      }
    });
  }

  void selectKind(PasswordCardKind kind) {
    emit(
      state.copyWith(
        kind: kind,
        card: null,
        cardsForSelectedKind: _cardsForKind(state.catalog!, kind),
        isSelectionComplete: false,
        isOperationSupported: false,
        canContinue: false,
        isCurrentPasswordValid: !state.isChange,
        password: '',
        currentPassword: '',
        confirmation: '',
        nationalCardSerial: '',
        termsAccepted: false,
        isRecordingConfirmed: false,
        isPasswordLengthValid: false,
        isPasswordPatternValid: false,
        isPasswordDateValid: false,
        isConfirmationValid: true,
        isFormComplete: false,
        isSerialValid: false,
        isPasswordVisible: false,
        isConfirmationVisible: false,
        isCurrentPasswordVisible: false,
        isConfirmationError: false,
        isSerialError: false,
        idempotencyKey: null,
        existingRequestFailure: null,
        submissionFailure: null,
      ),
    );
  }

  void selectCard(PasswordCard card) {
    final operation = selectOperation
        ? null
        : PasswordOperation.setSecondPassword;
    final isSelected =
        state.passwordType == PasswordType.second && operation != null;
    final isSupported = operation != null && card.supports(operation);
    emit(
      state.copyWith(
        card: card,
        kind: card.kind,
        operation: operation,
        isChange: false,
        isSelectionComplete: isSelected && isSupported,
        isOperationSupported: isSupported,
        canContinue: isSelected,
        isCurrentPasswordValid: true,
        password: '',
        currentPassword: '',
        confirmation: '',
        nationalCardSerial: '',
        termsAccepted: false,
        isRecordingConfirmed: false,
        isPasswordLengthValid: false,
        isPasswordPatternValid: false,
        isPasswordDateValid: false,
        isConfirmationValid: true,
        isFormComplete: false,
        isSerialValid: false,
        isPasswordVisible: false,
        isConfirmationVisible: false,
        isCurrentPasswordVisible: false,
        isConfirmationError: false,
        isSerialError: false,
        idempotencyKey: null,
        existingRequestFailure: null,
        submissionFailure: null,
      ),
    );
  }

  void selectPasswordType(PasswordType type) {
    switch (type) {
      case PasswordType.first:
        emit(
          state.copyWith(
            effect: const PasswordUnsupportedRequested(),
            effectId: state.effectId + 1,
          ),
        );
      case PasswordType.second:
        emit(
          state.copyWith(
            passwordType: type,
            isSelectionComplete:
                state.card != null && state.isOperationSupported,
            canContinue: state.card != null && state.operation != null,
          ),
        );
    }
  }

  void selectOperationType(PasswordOperation operation) {
    final isSupported = state.card!.supports(operation);
    emit(
      state.copyWith(
        operation: operation,
        isChange: operation == PasswordOperation.changePassword,
        isOperationSupported: isSupported,
        isSelectionComplete:
            state.passwordType == PasswordType.second && isSupported,
        canContinue: state.passwordType == PasswordType.second,
        isCurrentPasswordValid: operation != PasswordOperation.changePassword,
        password: '',
        currentPassword: '',
        confirmation: '',
        nationalCardSerial: '',
        termsAccepted: false,
        isRecordingConfirmed: false,
        isPasswordLengthValid: false,
        isPasswordPatternValid: false,
        isPasswordDateValid: false,
        isConfirmationValid: true,
        isFormComplete: false,
        isSerialValid: false,
        isPasswordVisible: false,
        isConfirmationVisible: false,
        isCurrentPasswordVisible: false,
        isConfirmationError: false,
        isSerialError: false,
        idempotencyKey: null,
        existingRequestFailure: null,
        submissionFailure: null,
      ),
    );
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void toggleConfirmationVisibility() {
    emit(state.copyWith(isConfirmationVisible: !state.isConfirmationVisible));
  }

  void toggleCurrentPasswordVisibility() {
    emit(
      state.copyWith(isCurrentPasswordVisible: !state.isCurrentPasswordVisible),
    );
  }

  void validateConfirmation() {
    emit(
      state.copyWith(
        isConfirmationError:
            state.confirmation.isNotEmpty && !state.isConfirmationValid,
      ),
    );
  }

  void validateSerial() {
    emit(
      state.copyWith(
        isSerialError:
            state.nationalCardSerial.isNotEmpty && !state.isSerialValid,
      ),
    );
  }

  void updateCurrentPassword(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final isValid = SecondPasswordValidator.hasValidLength(normalized);
    emit(
      state.copyWith(
        currentPassword: normalized,
        isCurrentPasswordValid: isValid,
        isConfirmationError: false,
        termsAccepted: false,
        isRecordingConfirmed: false,
        isFormComplete: false,
        canContinue: false,
        primaryAction: PasswordPrimaryAction.continueFlow,
        submissionFailure: null,
        idempotencyKey: normalized == state.currentPassword
            ? state.idempotencyKey
            : null,
      ),
    );
  }

  void updatePassword(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final validation = SecondPasswordValidator.validate(
      normalized,
      state.card!.datePinCandidates,
    );
    emit(
      state.copyWith(
        password: normalized,
        isPasswordLengthValid: validation.isLengthValid,
        isPasswordPatternValid: validation.isPatternValid,
        isPasswordDateValid: validation.isDateValid,
        isConfirmationValid: normalized == state.confirmation,
        isConfirmationError: false,
        termsAccepted: false,
        isRecordingConfirmed: false,
        isFormComplete: false,
        canContinue: false,
        primaryAction: PasswordPrimaryAction.continueFlow,
        submissionFailure: null,
        idempotencyKey: normalized == state.password
            ? state.idempotencyKey
            : null,
      ),
    );
  }

  void updateConfirmation(String value) {
    final normalized = DigitNormalizer.normalize(value);
    emit(
      state.copyWith(
        confirmation: normalized,
        isConfirmationValid: normalized == state.password,
        isConfirmationError: false,
        termsAccepted: false,
        isRecordingConfirmed: false,
        isFormComplete: false,
        canContinue: false,
        primaryAction: PasswordPrimaryAction.continueFlow,
        submissionFailure: null,
      ),
    );
  }

  void updateNationalCardSerial(String value) {
    final normalized = DigitNormalizer.normalize(value).trim().toUpperCase();
    final isValid = SecondPasswordValidator.validSerial(normalized);
    emit(
      state.copyWith(
        nationalCardSerial: normalized,
        isSerialValid: isValid,
        isSerialError: false,
        isRecordingConfirmed: false,
        canContinue: isValid,
        submissionFailure: null,
        idempotencyKey: normalized == state.nationalCardSerial
            ? state.idempotencyKey
            : null,
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    final isComplete =
        state.isCurrentPasswordValid &&
        state.isPasswordLengthValid &&
        state.isPasswordPatternValid &&
        state.isPasswordDateValid &&
        state.isConfirmationValid &&
        accepted;
    emit(
      state.copyWith(
        termsAccepted: accepted,
        isFormComplete: isComplete,
        canContinue: isComplete,
        primaryAction: state.isChange && isComplete
            ? PasswordPrimaryAction.changePassword
            : PasswordPrimaryAction.continueFlow,
      ),
    );
  }

  void confirmMockRecording() {
    emit(
      state.copyWith(
        isRecordingConfirmed: true,
        canContinue: state.isFormComplete && state.isSerialValid,
      ),
    );
  }

  void resetRecordingConfirmation() {
    emit(state.copyWith(isRecordingConfirmed: false, canContinue: false));
  }

  void updateRecordingConfirmation(bool confirmed) {
    emit(
      state.copyWith(
        isRecordingConfirmed: confirmed,
        canContinue: confirmed && state.isFormComplete && state.isSerialValid,
      ),
    );
  }

  Future<void> submitCurrentStep() {
    switch (state.step) {
      case SecondPasswordStep.selection:
        return _fetchExistingRequest();
      case SecondPasswordStep.password:
        if (state.isChange) {
          return _submitPassword();
        } else {
          emit(
            state.copyWith(
              step: SecondPasswordStep.serial,
              canContinue: state.isSerialValid,
              existingRequestFailure: null,
              submissionFailure: null,
              isSerialError: false,
            ),
          );
          return Future.value();
        }
      case SecondPasswordStep.serial:
        emit(
          state.copyWith(
            step: SecondPasswordStep.instruction,
            canContinue: true,
            primaryAction: PasswordPrimaryAction.startKyc,
            existingRequestFailure: null,
            submissionFailure: null,
          ),
        );
        return Future.value();
      case SecondPasswordStep.instruction:
        emit(
          state.copyWith(
            step: SecondPasswordStep.recording,
            canContinue:
                state.isRecordingConfirmed &&
                state.isFormComplete &&
                state.isSerialValid,
            primaryAction: PasswordPrimaryAction.submit,
            existingRequestFailure: null,
            submissionFailure: null,
          ),
        );
        return Future.value();
      case SecondPasswordStep.recording:
        return _submitPassword();
    }
  }

  Future<void> _fetchExistingRequest() {
    emit(
      state.copyWith(
        existingRequestStatus: RequestStatus.loading,
        existingRequestFailure: null,
        record: null,
        isEditable: false,
        canContinue: false,
      ),
    );
    return CheckPasswordRequest(_repository)(
      state.card!.id,
      operation: state.operation!,
    ).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              existingRequestStatus: RequestStatus.failure,
              existingRequestFailure: failure,
              isEditable: true,
              canContinue: true,
            ),
          );
        case Success(:final data):
          if (data.status != PasswordRequestStatus.none) {
            emit(
              state.copyWith(
                existingRequestStatus: RequestStatus.success,
                record: data,
                isFullStatusVisible: state.isChange,
                effect: state.isChange
                    ? null
                    : PasswordRecordRequested(
                        data,
                        state.operation!,
                        newlySubmitted: false,
                      ),
                effectId: state.effectId + 1,
              ),
            );
          } else if (!state.isSelectionComplete ||
              (!state.isChange && !state.isWalletSufficient)) {
            emit(
              state.copyWith(
                existingRequestStatus: RequestStatus.failure,
                existingRequestFailure: const DataFailure(
                  'password.request.ineligible',
                ),
                isEditable: true,
                canContinue: true,
              ),
            );
          } else {
            emit(
              state.copyWith(
                existingRequestStatus: RequestStatus.success,
                step: SecondPasswordStep.password,
                isEditable: true,
                canContinue: state.isFormComplete,
                isPasswordVisible: false,
                isConfirmationVisible: false,
                isCurrentPasswordVisible: false,
                isConfirmationError: false,
                primaryAction: state.isChange && state.isFormComplete
                    ? PasswordPrimaryAction.changePassword
                    : PasswordPrimaryAction.continueFlow,
              ),
            );
          }
      }
    });
  }

  Future<void> _submitPassword() {
    final key = state.idempotencyKey ?? _newKey();
    final request = SetSecondPasswordRequest(
      cardId: state.card!.id,
      operation: state.operation!,
      password: state.password,
      currentPassword: state.isChange ? state.currentPassword : null,
      nationalCardSerial: state.nationalCardSerial,
      idempotencyKey: key,
      kycReference: state.isChange ? '' : 'mock-kyc',
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        submissionFailure: null,
        idempotencyKey: key,
        isEditable: false,
        canContinue: false,
      ),
    );
    return SubmitSecondPassword(_repository)(request).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              submissionFailure: failure,
              isEditable: true,
              canContinue: _canContinueAtStep(state.step),
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              record: data,
              isFullStatusVisible: false,
              effect: PasswordRecordRequested(
                data,
                state.operation!,
                newlySubmitted: true,
              ),
              effectId: state.effectId + 1,
              idempotencyKey: null,
              password: '',
              currentPassword: '',
              confirmation: '',
              nationalCardSerial: '',
              termsAccepted: false,
              isRecordingConfirmed: false,
              isPasswordLengthValid: false,
              isPasswordPatternValid: false,
              isPasswordDateValid: false,
              isCurrentPasswordValid: !state.isChange,
              isConfirmationValid: true,
              isFormComplete: false,
              isSerialValid: false,
              isPasswordVisible: false,
              isConfirmationVisible: false,
              isCurrentPasswordVisible: false,
              isConfirmationError: false,
              isSerialError: false,
            ),
          );
      }
    });
  }

  void requestBack() {
    if (state.isFullStatusVisible) {
      emit(
        state.copyWith(
          effect: const PasswordExitRequested(),
          effectId: state.effectId + 1,
        ),
      );
    } else {
      switch (state.step) {
        case SecondPasswordStep.selection:
          emit(
            state.copyWith(
              effect:
                  state.submissionStatus != RequestStatus.success &&
                      state.isSelectionComplete
                  ? const PasswordExitConfirmationRequested()
                  : const PasswordExitRequested(),
              effectId: state.effectId + 1,
            ),
          );
        case SecondPasswordStep.password:
          emit(
            state.copyWith(
              step: SecondPasswordStep.selection,
              canContinue:
                  state.isEditable &&
                  _canContinueAtStep(SecondPasswordStep.selection),
              primaryAction: PasswordPrimaryAction.continueFlow,
              record: null,
              existingRequestFailure: null,
              submissionFailure: null,
            ),
          );
        case SecondPasswordStep.serial:
          emit(
            state.copyWith(
              step: SecondPasswordStep.password,
              canContinue: state.isEditable && state.isFormComplete,
              primaryAction: PasswordPrimaryAction.continueFlow,
              isPasswordVisible: false,
              isConfirmationVisible: false,
              isCurrentPasswordVisible: false,
              isConfirmationError: false,
              record: null,
              existingRequestFailure: null,
              submissionFailure: null,
            ),
          );
        case SecondPasswordStep.instruction:
          emit(
            state.copyWith(
              step: SecondPasswordStep.serial,
              canContinue: state.isEditable && state.isSerialValid,
              primaryAction: PasswordPrimaryAction.continueFlow,
              isSerialError: false,
              record: null,
              existingRequestFailure: null,
              submissionFailure: null,
            ),
          );
        case SecondPasswordStep.recording:
          emit(
            state.copyWith(
              step: SecondPasswordStep.instruction,
              canContinue: state.isEditable,
              primaryAction: PasswordPrimaryAction.startKyc,
              record: null,
              existingRequestFailure: null,
              submissionFailure: null,
            ),
          );
      }
    }
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true ? const PasswordExitRequested() : null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyRecordDismissal() {
    if (state.submissionStatus == RequestStatus.success) {
      emit(
        state.copyWith(
          effect: const PasswordHomeRequested(),
          effectId: state.effectId + 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          record: null,
          isEditable: true,
          canContinue: _canContinueAtStep(state.step),
        ),
      );
    }
  }

  bool _canContinueAtStep(SecondPasswordStep step) => switch (step) {
    SecondPasswordStep.selection =>
      state.card != null &&
          state.passwordType == PasswordType.second &&
          state.operation != null,
    SecondPasswordStep.password => state.isFormComplete,
    SecondPasswordStep.serial => state.isSerialValid,
    SecondPasswordStep.instruction => true,
    SecondPasswordStep.recording =>
      state.isRecordingConfirmed && state.isFormComplete && state.isSerialValid,
  };

  List<PasswordCard> _cardsForKind(
    PasswordCatalog catalog,
    PasswordCardKind? kind,
  ) => catalog.cards
      .where((card) => card.kind == (kind ?? PasswordCardKind.resalat))
      .toList();

  String _normalizeCardNumber(String number) =>
      DigitNormalizer.normalize(number).replaceAll(' ', '');

  String _newKey() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
