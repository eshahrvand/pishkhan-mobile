import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/password_services_repository.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'dart:math';

import 'package:pishkhan_mobile/core/validators/second_password_validator.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/password_data.dart';
import '../../../domain/usecases/password_services.dart';

part 'second_password_state.dart';
part 'second_password_cubit.freezed.dart';

class SecondPasswordCubit extends Cubit<SecondPasswordState> {
  SecondPasswordCubit({
    SecondPasswordState initialState = const SecondPasswordState.initial(),
    required this.repository,
    this.initialCardNumber,
    this.selectOperation = false,
  }) : super(initialState) {
    {
      final nextCard = getCard(state.catalog, state.cardId, state.kind);
      final nextChange = state.operation == PasswordOperation.changePassword;
      final nextEditable = checkEditable(
        state.status,
        state.catalog,
        state.checkStatus,
        state.submissionStatus,
      );
      final nextHasSelection = checkHasSelection(
        state.secondPasswordSelected,
        state.operation,
        nextCard,
      );
      final nextCurrentComplete = checkCurrentComplete(
        state.currentPassword,
        nextChange,
      );
      final nextLength = SecondPasswordValidator.hasValidLength(state.password);
      final nextPattern = SecondPasswordValidator.hasSafePattern(
        state.password,
      );
      final nextDate = checkDate(state.password, nextCard);
      final nextForm = checkForm(
        state.password,
        state.confirmation,
        state.terms,
        nextCurrentComplete,
        nextLength,
        nextPattern,
        nextDate,
      );
      final nextSerial = SecondPasswordValidator.validSerial(state.serial);
      emit(
        state.copyWith(
          card: nextCard,
          editable: nextEditable,
          isChange: nextChange,
          currentPasswordComplete: nextCurrentComplete,
          hasSelection: nextHasSelection,
          selectionComplete:
              nextHasSelection && nextCard!.supports(state.operation!),
          lengthValid: nextLength,
          patternValid: nextPattern,
          dateValid: nextDate,
          formComplete: nextForm,
          serialComplete: nextSerial,
          walletSufficient:
              state.catalog != null &&
              state.catalog!.walletBalanceRial >= state.catalog!.feeRial,
          canContinue:
              nextEditable &&
              switch (state.step) {
                SecondPasswordStep.selection => nextHasSelection,
                SecondPasswordStep.password => nextForm,
                SecondPasswordStep.serial => nextSerial,
                SecondPasswordStep.instruction => true,
                SecondPasswordStep.recording =>
                  state.recordingConfirmed && nextForm && nextSerial,
              },
        ),
      );
    }
  }
  final PasswordServicesRepository repository;
  final String? initialCardNumber;
  final bool selectOperation;

  int _generation = 0;
  String? _idempotencyKey;
  Future<void> load() async {
    final generation = ++_generation;
    _idempotencyKey = null;
    {
      final nextCard = getCard((null), (null), (null));
      final nextChange =
          ((selectOperation ? null : PasswordOperation.setSecondPassword)) ==
          PasswordOperation.changePassword;
      final nextEditable = checkEditable(
        (RequestStatus.loading),
        (null),
        (RequestStatus.initial),
        (RequestStatus.initial),
      );
      final nextHasSelection = checkHasSelection(
        false,
        ((selectOperation ? null : PasswordOperation.setSecondPassword)),
        nextCard,
      );
      final nextCurrentComplete = checkCurrentComplete((''), nextChange);
      final nextLength = SecondPasswordValidator.hasValidLength((''));
      final nextPattern = SecondPasswordValidator.hasSafePattern((''));
      final nextDate = checkDate((''), nextCard);
      final nextForm = checkForm(
        (''),
        (''),
        false,
        nextCurrentComplete,
        nextLength,
        nextPattern,
        nextDate,
      );
      final nextSerial = SecondPasswordValidator.validSerial((''));
      emit(
        state.copyWith(
          status: RequestStatus.loading,
          checkStatus: RequestStatus.initial,
          submissionStatus: RequestStatus.initial,
          step: SecondPasswordStep.selection,
          catalog: null,
          operation: (selectOperation
              ? null
              : PasswordOperation.setSecondPassword),
          kind: null,
          cardId: null,
          secondPasswordSelected: false,
          password: '',
          currentPassword: '',
          confirmation: '',
          serial: '',
          terms: false,
          recordingConfirmed: false,
          record: null,
          failure: null,
          card: nextCard,
          editable: nextEditable,
          isChange: nextChange,
          currentPasswordComplete: nextCurrentComplete,
          hasSelection: nextHasSelection,
          selectionComplete:
              nextHasSelection &&
              nextCard!.supports(
                ((selectOperation
                    ? null
                    : PasswordOperation.setSecondPassword))!,
              ),
          lengthValid: nextLength,
          patternValid: nextPattern,
          dateValid: nextDate,
          formComplete: nextForm,
          serialComplete: nextSerial,
          walletSufficient: false,
          canContinue: nextEditable && nextHasSelection,
        ),
      );
    }
    final result = await LoadPasswordCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        {
          final nextCard = getCard(
            (null as PasswordCatalog?),
            (null as String?),
            (null as PasswordCardKind?),
          );
          final nextChange =
              (PasswordOperation.setSecondPassword) ==
              PasswordOperation.changePassword;
          final nextEditable = checkEditable(
            (RequestStatus.failure),
            (null as PasswordCatalog?),
            (RequestStatus.initial),
            (RequestStatus.initial),
          );
          final nextHasSelection = checkHasSelection(
            false,
            (PasswordOperation.setSecondPassword),
            nextCard,
          );
          final nextCurrentComplete = checkCurrentComplete((''), nextChange);
          final nextLength = SecondPasswordValidator.hasValidLength((''));
          final nextPattern = SecondPasswordValidator.hasSafePattern((''));
          final nextDate = checkDate((''), nextCard);
          final nextForm = checkForm(
            (''),
            (''),
            false,
            nextCurrentComplete,
            nextLength,
            nextPattern,
            nextDate,
          );
          final nextSerial = SecondPasswordValidator.validSerial((''));
          emit(
            SecondPasswordState.initial(
              status: RequestStatus.failure,
              failure: failure,
              card: nextCard,
              editable: nextEditable,
              isChange: nextChange,
              currentPasswordComplete: nextCurrentComplete,
              hasSelection: nextHasSelection,
              selectionComplete:
                  nextHasSelection &&
                  nextCard!.supports((PasswordOperation.setSecondPassword)),
              lengthValid: nextLength,
              patternValid: nextPattern,
              dateValid: nextDate,
              formComplete: nextForm,
              serialComplete: nextSerial,
              walletSufficient: false,
              canContinue: nextEditable && nextHasSelection,
            ),
          );
        }
      case Success(:final data):
        PasswordCard? selected;
        for (final card in data.cards) {
          if (initialCardNumber != null &&
              DigitNormalizer.normalize(card.number).replaceAll(' ', '') ==
                  DigitNormalizer.normalize(initialCardNumber!)
                      .replaceAll(' ', '')) {
            selected = card;
          }
        }
        {
          final nextCard = getCard((data), (selected?.id), (selected?.kind));
          final nextChange =
              ((selectOperation
                  ? null
                  : PasswordOperation.setSecondPassword)) ==
              PasswordOperation.changePassword;
          final nextEditable = checkEditable(
            (RequestStatus.success),
            (data),
            (RequestStatus.initial),
            (RequestStatus.initial),
          );
          final nextHasSelection = checkHasSelection(
            false,
            ((selectOperation ? null : PasswordOperation.setSecondPassword)),
            nextCard,
          );
          final nextCurrentComplete = checkCurrentComplete((''), nextChange);
          final nextLength = SecondPasswordValidator.hasValidLength((''));
          final nextPattern = SecondPasswordValidator.hasSafePattern((''));
          final nextDate = checkDate((''), nextCard);
          final nextForm = checkForm(
            (''),
            (''),
            false,
            nextCurrentComplete,
            nextLength,
            nextPattern,
            nextDate,
          );
          final nextSerial = SecondPasswordValidator.validSerial((''));
          emit(
            SecondPasswordState.initial(
              status: RequestStatus.success,
              catalog: data,
              operation: (selectOperation
                  ? null
                  : PasswordOperation.setSecondPassword),
              kind: selected?.kind,
              cardId: selected?.id,
              card: nextCard,
              editable: nextEditable,
              isChange: nextChange,
              currentPasswordComplete: nextCurrentComplete,
              hasSelection: nextHasSelection,
              selectionComplete:
                  nextHasSelection &&
                  nextCard!.supports(
                    ((selectOperation
                        ? null
                        : PasswordOperation.setSecondPassword))!,
                  ),
              lengthValid: nextLength,
              patternValid: nextPattern,
              dateValid: nextDate,
              formComplete: nextForm,
              serialComplete: nextSerial,
              walletSufficient: (data).walletBalanceRial >= (data).feeRial,
              canContinue: nextEditable && nextHasSelection,
            ),
          );
        }
    }
  }

  void selectKind(PasswordCardKind kind) {
    if (!state.editable) return;
    {
      final nextCard = getCard((state.catalog), (null as String?), (kind));
      final nextChange =
          ((selectOperation ? null : PasswordOperation.setSecondPassword)) ==
          PasswordOperation.changePassword;
      final nextEditable = checkEditable(
        (RequestStatus.success),
        (state.catalog),
        (RequestStatus.initial),
        (RequestStatus.initial),
      );
      final nextHasSelection = checkHasSelection(
        false,
        ((selectOperation ? null : PasswordOperation.setSecondPassword)),
        nextCard,
      );
      final nextCurrentComplete = checkCurrentComplete((''), nextChange);
      final nextLength = SecondPasswordValidator.hasValidLength((''));
      final nextPattern = SecondPasswordValidator.hasSafePattern((''));
      final nextDate = checkDate((''), nextCard);
      final nextForm = checkForm(
        (''),
        (''),
        false,
        nextCurrentComplete,
        nextLength,
        nextPattern,
        nextDate,
      );
      final nextSerial = SecondPasswordValidator.validSerial((''));
      emit(
        SecondPasswordState.initial(
          status: RequestStatus.success,
          catalog: state.catalog,
          operation: (selectOperation
              ? null
              : PasswordOperation.setSecondPassword),
          kind: kind,
          card: nextCard,
          editable: nextEditable,
          isChange: nextChange,
          currentPasswordComplete: nextCurrentComplete,
          hasSelection: nextHasSelection,
          selectionComplete:
              nextHasSelection &&
              nextCard!.supports(
                ((selectOperation
                    ? null
                    : PasswordOperation.setSecondPassword))!,
              ),
          lengthValid: nextLength,
          patternValid: nextPattern,
          dateValid: nextDate,
          formComplete: nextForm,
          serialComplete: nextSerial,
          walletSufficient:
              (state.catalog) != null &&
              (state.catalog)!.walletBalanceRial >= (state.catalog)!.feeRial,
          canContinue: nextEditable && nextHasSelection,
        ),
      );
    }
    _idempotencyKey = null;
  }

  void selectCard(String id) {
    if (!state.editable ||
        !(state.catalog?.cards.any(
              (c) => c.id == id && (state.kind == null || c.kind == state.kind),
            ) ??
            false)) {
      return;
    }
    {
      final nextCard = getCard(
        (state.catalog),
        (id),
        (state.catalog!.cards.firstWhere((card) => card.id == id).kind),
      );
      final nextChange =
          ((selectOperation ? null : PasswordOperation.setSecondPassword)) ==
          PasswordOperation.changePassword;
      final nextEditable = checkEditable(
        (RequestStatus.success),
        (state.catalog),
        (RequestStatus.initial),
        (RequestStatus.initial),
      );
      final nextHasSelection = checkHasSelection(
        (state.secondPasswordSelected),
        ((selectOperation ? null : PasswordOperation.setSecondPassword)),
        nextCard,
      );
      final nextCurrentComplete = checkCurrentComplete((''), nextChange);
      final nextLength = SecondPasswordValidator.hasValidLength((''));
      final nextPattern = SecondPasswordValidator.hasSafePattern((''));
      final nextDate = checkDate((''), nextCard);
      final nextForm = checkForm(
        (''),
        (''),
        false,
        nextCurrentComplete,
        nextLength,
        nextPattern,
        nextDate,
      );
      final nextSerial = SecondPasswordValidator.validSerial((''));
      emit(
        SecondPasswordState.initial(
          status: RequestStatus.success,
          catalog: state.catalog,
          kind: state.catalog!.cards.firstWhere((card) => card.id == id).kind,
          cardId: id,
          operation: (selectOperation
              ? null
              : PasswordOperation.setSecondPassword),
          secondPasswordSelected: state.secondPasswordSelected,
          card: nextCard,
          editable: nextEditable,
          isChange: nextChange,
          currentPasswordComplete: nextCurrentComplete,
          hasSelection: nextHasSelection,
          selectionComplete:
              nextHasSelection &&
              nextCard!.supports(
                ((selectOperation
                    ? null
                    : PasswordOperation.setSecondPassword))!,
              ),
          lengthValid: nextLength,
          patternValid: nextPattern,
          dateValid: nextDate,
          formComplete: nextForm,
          serialComplete: nextSerial,
          walletSufficient:
              (state.catalog) != null &&
              (state.catalog)!.walletBalanceRial >= (state.catalog)!.feeRial,
          canContinue: nextEditable && nextHasSelection,
        ),
      );
    }
    _idempotencyKey = null;
  }

  void selectSecondPassword() {
    if (state.editable) {
      {
        final nextHasSelection = checkHasSelection(
          true,
          state.operation,
          state.card,
        );
        emit(
          state.copyWith(
            secondPasswordSelected: true,
            hasSelection: nextHasSelection,
            selectionComplete:
                nextHasSelection && state.card!.supports(state.operation!),
            canContinue:
                state.editable &&
                switch (state.step) {
                  SecondPasswordStep.selection => nextHasSelection,
                  SecondPasswordStep.password => state.formComplete,
                  SecondPasswordStep.serial => state.serialComplete,
                  SecondPasswordStep.instruction => true,
                  SecondPasswordStep.recording =>
                    state.recordingConfirmed &&
                        state.formComplete &&
                        state.serialComplete,
                },
          ),
        );
      }
    }
  }

  void chooseOperation(PasswordOperation operation) {
    if (!state.editable ||
        !selectOperation ||
        operation == PasswordOperation.setSecondPassword ||
        state.operation == operation) {
      return;
    }
    _idempotencyKey = null;
    {
      final nextCard = getCard((state.catalog), (state.cardId), (state.kind));
      final nextChange = (operation) == PasswordOperation.changePassword;
      final nextEditable = checkEditable(
        (RequestStatus.success),
        (state.catalog),
        (RequestStatus.initial),
        (RequestStatus.initial),
      );
      final nextHasSelection = checkHasSelection(
        (state.secondPasswordSelected),
        (operation),
        nextCard,
      );
      final nextCurrentComplete = checkCurrentComplete((''), nextChange);
      final nextLength = SecondPasswordValidator.hasValidLength((''));
      final nextPattern = SecondPasswordValidator.hasSafePattern((''));
      final nextDate = checkDate((''), nextCard);
      final nextForm = checkForm(
        (''),
        (''),
        false,
        nextCurrentComplete,
        nextLength,
        nextPattern,
        nextDate,
      );
      final nextSerial = SecondPasswordValidator.validSerial((''));
      emit(
        SecondPasswordState.initial(
          status: RequestStatus.success,
          catalog: state.catalog,
          kind: state.kind,
          cardId: state.cardId,
          secondPasswordSelected: state.secondPasswordSelected,
          operation: operation,
          card: nextCard,
          editable: nextEditable,
          isChange: nextChange,
          currentPasswordComplete: nextCurrentComplete,
          hasSelection: nextHasSelection,
          selectionComplete:
              nextHasSelection && nextCard!.supports((operation)),
          lengthValid: nextLength,
          patternValid: nextPattern,
          dateValid: nextDate,
          formComplete: nextForm,
          serialComplete: nextSerial,
          walletSufficient:
              (state.catalog) != null &&
              (state.catalog)!.walletBalanceRial >= (state.catalog)!.feeRial,
          canContinue: nextEditable && nextHasSelection,
        ),
      );
    }
  }

  void resetPasswordFormPresentation() {
    emit(
      state.copyWith(
        showPassword: false,
        showConfirmation: false,
        showCurrentPassword: false,
        isConfirmationError: false,
      ),
    );
  }

  void resetSerialValidation() {
    emit(state.copyWith(isSerialError: false));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  void toggleConfirmationVisibility() {
    emit(state.copyWith(showConfirmation: !state.showConfirmation));
  }

  void toggleCurrentPasswordVisibility() {
    emit(state.copyWith(showCurrentPassword: !state.showCurrentPassword));
  }

  void validateConfirmation() {
    emit(
      state.copyWith(
        isConfirmationError:
            state.confirmation.isNotEmpty &&
            state.password != state.confirmation,
      ),
    );
  }

  void validateSerial() {
    emit(
      state.copyWith(
        isSerialError: state.serial.isNotEmpty && !state.serialComplete,
      ),
    );
  }

  void currentPasswordChanged(String value) {
    if (state.isConfirmationError) {
      emit(state.copyWith(isConfirmationError: false));
    }
    if (!state.editable) return;
    final normalized = DigitNormalizer.normalize(value);
    if (normalized != state.currentPassword) _idempotencyKey = null;
    {
      final nextCurrentComplete = checkCurrentComplete(
        (normalized),
        state.isChange,
      );
      final nextForm = checkForm(
        state.password,
        state.confirmation,
        false,
        nextCurrentComplete,
        state.lengthValid,
        state.patternValid,
        state.dateValid,
      );
      emit(
        state.copyWith(
          currentPassword: normalized,
          terms: false,
          recordingConfirmed: false,
          failure: null,
          currentPasswordComplete: nextCurrentComplete,
          formComplete: nextForm,
          canContinue:
              state.editable &&
              switch (state.step) {
                SecondPasswordStep.selection => state.hasSelection,
                SecondPasswordStep.password => nextForm,
                SecondPasswordStep.serial => state.serialComplete,
                SecondPasswordStep.instruction => true,
                SecondPasswordStep.recording => false,
              },
        ),
      );
    }
  }

  void passwordChanged(String value) {
    if (state.isConfirmationError) {
      emit(state.copyWith(isConfirmationError: false));
    }
    if (state.editable) {
      if (DigitNormalizer.normalize(value) != state.password) {
        _idempotencyKey = null;
      }
      {
        final nextLength = SecondPasswordValidator.hasValidLength(
          (DigitNormalizer.normalize(value)),
        );
        final nextPattern = SecondPasswordValidator.hasSafePattern(
          (DigitNormalizer.normalize(value)),
        );
        final nextDate = checkDate(
          (DigitNormalizer.normalize(value)),
          state.card,
        );
        final nextForm = checkForm(
          (DigitNormalizer.normalize(value)),
          state.confirmation,
          false,
          state.currentPasswordComplete,
          nextLength,
          nextPattern,
          nextDate,
        );
        emit(
          state.copyWith(
            password: DigitNormalizer.normalize(value),
            terms: false,
            recordingConfirmed: false,
            failure: null,
            lengthValid: nextLength,
            patternValid: nextPattern,
            dateValid: nextDate,
            formComplete: nextForm,
            canContinue:
                state.editable &&
                switch (state.step) {
                  SecondPasswordStep.selection => state.hasSelection,
                  SecondPasswordStep.password => nextForm,
                  SecondPasswordStep.serial => state.serialComplete,
                  SecondPasswordStep.instruction => true,
                  SecondPasswordStep.recording => false,
                },
          ),
        );
      }
    }
  }

  void confirmationChanged(String value) {
    if (state.isConfirmationError) {
      emit(state.copyWith(isConfirmationError: false));
    }
    if (state.editable) {
      {
        final nextForm = checkForm(
          state.password,
          (DigitNormalizer.normalize(value)),
          false,
          state.currentPasswordComplete,
          state.lengthValid,
          state.patternValid,
          state.dateValid,
        );
        emit(
          state.copyWith(
            confirmation: DigitNormalizer.normalize(value),
            terms: false,
            recordingConfirmed: false,
            failure: null,
            formComplete: nextForm,
            canContinue:
                state.editable &&
                switch (state.step) {
                  SecondPasswordStep.selection => state.hasSelection,
                  SecondPasswordStep.password => nextForm,
                  SecondPasswordStep.serial => state.serialComplete,
                  SecondPasswordStep.instruction => true,
                  SecondPasswordStep.recording => false,
                },
          ),
        );
      }
    }
  }

  void serialChanged(String value) {
    if (state.isSerialError) {
      emit(state.copyWith(isSerialError: false));
    }
    if (state.editable) {
      if (DigitNormalizer.normalize(value).trim().toUpperCase() !=
          state.serial) {
        _idempotencyKey = null;
      }
      {
        final nextSerial = SecondPasswordValidator.validSerial(
          (DigitNormalizer.normalize(value).trim().toUpperCase()),
        );
        emit(
          state.copyWith(
            serial: DigitNormalizer.normalize(value).trim().toUpperCase(),
            recordingConfirmed: false,
            failure: null,
            serialComplete: nextSerial,
            canContinue:
                state.editable &&
                switch (state.step) {
                  SecondPasswordStep.selection => state.hasSelection,
                  SecondPasswordStep.password => state.formComplete,
                  SecondPasswordStep.serial => nextSerial,
                  SecondPasswordStep.instruction => true,
                  SecondPasswordStep.recording => false,
                },
          ),
        );
      }
    }
  }

  void acceptTerms(bool value) {
    if (state.editable) {
      final nextForm = checkForm(
        state.password,
        state.confirmation,
        (value),
        state.currentPasswordComplete,
        state.lengthValid,
        state.patternValid,
        state.dateValid,
      );
      emit(
        state.copyWith(
          terms: value,
          formComplete: nextForm,
          canContinue:
              state.editable &&
              switch (state.step) {
                SecondPasswordStep.selection => state.hasSelection,
                SecondPasswordStep.password => nextForm,
                SecondPasswordStep.serial => state.serialComplete,
                SecondPasswordStep.instruction => true,
                SecondPasswordStep.recording =>
                  state.recordingConfirmed && nextForm && state.serialComplete,
              },
        ),
      );
    }
  }

  void confirmMockRecording() {
    if (state.editable && state.step == SecondPasswordStep.recording) {
      {
        emit(
          state.copyWith(
            recordingConfirmed: true,
            canContinue:
                state.editable &&
                switch (state.step) {
                  SecondPasswordStep.selection => state.hasSelection,
                  SecondPasswordStep.password => state.formComplete,
                  SecondPasswordStep.serial => state.serialComplete,
                  SecondPasswordStep.instruction => true,
                  SecondPasswordStep.recording =>
                    true && state.formComplete && state.serialComplete,
                },
          ),
        );
      }
    }
  }

  void recordAgain() {
    if (state.editable) {
      {
        emit(
          state.copyWith(
            recordingConfirmed: false,
            canContinue:
                state.editable &&
                switch (state.step) {
                  SecondPasswordStep.selection => state.hasSelection,
                  SecondPasswordStep.password => state.formComplete,
                  SecondPasswordStep.serial => state.serialComplete,
                  SecondPasswordStep.instruction => true,
                  SecondPasswordStep.recording => false,
                },
          ),
        );
      }
    }
  }

  Future<void> next() async {
    if (!state.canContinue) return;
    if (state.step == SecondPasswordStep.selection) {
      final generation = ++_generation;
      {
        final nextEditable = checkEditable(
          state.status,
          state.catalog,
          (RequestStatus.loading),
          state.submissionStatus,
        );
        emit(
          state.copyWith(
            checkStatus: RequestStatus.loading,
            failure: null,
            record: null,
            editable: nextEditable,
            canContinue:
                nextEditable &&
                switch (state.step) {
                  SecondPasswordStep.selection => state.hasSelection,
                  SecondPasswordStep.password => state.formComplete,
                  SecondPasswordStep.serial => state.serialComplete,
                  SecondPasswordStep.instruction => true,
                  SecondPasswordStep.recording =>
                    state.recordingConfirmed &&
                        state.formComplete &&
                        state.serialComplete,
                },
          ),
        );
      }
      final result = await CheckPasswordRequest(repository)(
        state.cardId!,
        operation: state.operation!,
      );
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          {
            final nextEditable = checkEditable(
              state.status,
              state.catalog,
              (RequestStatus.failure),
              state.submissionStatus,
            );
            emit(
              state.copyWith(
                checkStatus: RequestStatus.failure,
                failure: failure,
                editable: nextEditable,
                canContinue:
                    nextEditable &&
                    switch (state.step) {
                      SecondPasswordStep.selection => state.hasSelection,
                      SecondPasswordStep.password => state.formComplete,
                      SecondPasswordStep.serial => state.serialComplete,
                      SecondPasswordStep.instruction => true,
                      SecondPasswordStep.recording =>
                        state.recordingConfirmed &&
                            state.formComplete &&
                            state.serialComplete,
                    },
              ),
            );
          }
        case Success(:final data):
          if (data.status != PasswordRequestStatus.none) {
            {
              final nextEditable = checkEditable(
                state.status,
                state.catalog,
                (RequestStatus.success),
                state.submissionStatus,
              );
              emit(
                state.copyWith(
                  checkStatus: RequestStatus.success,
                  record: data,
                  editable: nextEditable,
                  canContinue:
                      nextEditable &&
                      switch (state.step) {
                        SecondPasswordStep.selection => state.hasSelection,
                        SecondPasswordStep.password => state.formComplete,
                        SecondPasswordStep.serial => state.serialComplete,
                        SecondPasswordStep.instruction => true,
                        SecondPasswordStep.recording =>
                          state.recordingConfirmed &&
                              state.formComplete &&
                              state.serialComplete,
                      },
                ),
              );
            }
            return;
          }
          if (!state.selectionComplete ||
              (!state.isChange && !state.walletSufficient)) {
            {
              final nextEditable = checkEditable(
                state.status,
                state.catalog,
                (RequestStatus.failure),
                state.submissionStatus,
              );
              emit(
                state.copyWith(
                  checkStatus: RequestStatus.failure,
                  failure: const DataFailure('password.request.ineligible'),
                  editable: nextEditable,
                  canContinue:
                      nextEditable &&
                      switch (state.step) {
                        SecondPasswordStep.selection => state.hasSelection,
                        SecondPasswordStep.password => state.formComplete,
                        SecondPasswordStep.serial => state.serialComplete,
                        SecondPasswordStep.instruction => true,
                        SecondPasswordStep.recording =>
                          state.recordingConfirmed &&
                              state.formComplete &&
                              state.serialComplete,
                      },
                ),
              );
            }
            return;
          }
          _idempotencyKey = _newKey();
          {
            final nextEditable = checkEditable(
              state.status,
              state.catalog,
              (RequestStatus.success),
              state.submissionStatus,
            );
            emit(
              state.copyWith(
                checkStatus: RequestStatus.success,
                step: SecondPasswordStep.password,
                editable: nextEditable,
                canContinue: nextEditable && state.formComplete,
              ),
            );
          }
      }
    } else if (state.isChange && state.step == SecondPasswordStep.password) {
      await submit();
    } else if (state.step != SecondPasswordStep.recording) {
      {
        emit(
          state.copyWith(
            step: SecondPasswordStep.values[state.step.index + 1],
            failure: null,
            canContinue:
                state.editable &&
                switch ((SecondPasswordStep.values[state.step.index + 1])) {
                  SecondPasswordStep.selection => state.hasSelection,
                  SecondPasswordStep.password => state.formComplete,
                  SecondPasswordStep.serial => state.serialComplete,
                  SecondPasswordStep.instruction => true,
                  SecondPasswordStep.recording =>
                    state.recordingConfirmed &&
                        state.formComplete &&
                        state.serialComplete,
                },
          ),
        );
      }
    } else {
      await submit();
    }
  }

  bool back() {
    if (!state.editable || state.step == SecondPasswordStep.selection) {
      return false;
    }
    {
      emit(
        state.copyWith(
          step: SecondPasswordStep.values[state.step.index - 1],
          record: null,
          failure: null,
          canContinue:
              state.editable &&
              switch ((SecondPasswordStep.values[state.step.index - 1])) {
                SecondPasswordStep.selection => state.hasSelection,
                SecondPasswordStep.password => state.formComplete,
                SecondPasswordStep.serial => state.serialComplete,
                SecondPasswordStep.instruction => true,
                SecondPasswordStep.recording =>
                  state.recordingConfirmed &&
                      state.formComplete &&
                      state.serialComplete,
              },
        ),
      );
    }
    return true;
  }

  void dismissRecord() {
    if (state.editable) {
      emit(state.copyWith(record: null));
    }
  }

  Future<void> submit() async {
    if (!state.canContinue ||
        (state.isChange
            ? state.step != SecondPasswordStep.password
            : state.step != SecondPasswordStep.recording)) {
      return;
    }
    _idempotencyKey ??= _newKey();
    final generation = ++_generation;
    final request = SetSecondPasswordRequest(
      cardId: state.cardId!,
      operation: state.operation!,
      password: state.password,
      currentPassword: state.isChange ? state.currentPassword : null,
      nationalCardSerial: state.serial,
      idempotencyKey: _idempotencyKey!,
      kycReference: state.isChange ? '' : 'mock-kyc',
    );
    {
      final nextEditable = checkEditable(
        state.status,
        state.catalog,
        state.checkStatus,
        (RequestStatus.loading),
      );
      emit(
        state.copyWith(
          submissionStatus: RequestStatus.loading,
          failure: null,
          editable: nextEditable,
          canContinue:
              nextEditable &&
              switch (state.step) {
                SecondPasswordStep.selection => state.hasSelection,
                SecondPasswordStep.password => state.formComplete,
                SecondPasswordStep.serial => state.serialComplete,
                SecondPasswordStep.instruction => true,
                SecondPasswordStep.recording =>
                  state.recordingConfirmed &&
                      state.formComplete &&
                      state.serialComplete,
              },
        ),
      );
    }
    final result = await SubmitSecondPassword(repository)(request);
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        {
          final nextEditable = checkEditable(
            state.status,
            state.catalog,
            state.checkStatus,
            (RequestStatus.failure),
          );
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              failure: failure,
              editable: nextEditable,
              canContinue:
                  nextEditable &&
                  switch (state.step) {
                    SecondPasswordStep.selection => state.hasSelection,
                    SecondPasswordStep.password => state.formComplete,
                    SecondPasswordStep.serial => state.serialComplete,
                    SecondPasswordStep.instruction => true,
                    SecondPasswordStep.recording =>
                      state.recordingConfirmed &&
                          state.formComplete &&
                          state.serialComplete,
                  },
            ),
          );
        }
      case Success(:final data):
        {
          final nextEditable = checkEditable(
            state.status,
            state.catalog,
            state.checkStatus,
            (RequestStatus.success),
          );
          final nextCurrentComplete = checkCurrentComplete(
            (''),
            state.isChange,
          );
          final nextLength = SecondPasswordValidator.hasValidLength((''));
          final nextPattern = SecondPasswordValidator.hasSafePattern((''));
          final nextDate = checkDate((''), state.card);
          final nextForm = checkForm(
            (''),
            (''),
            false,
            nextCurrentComplete,
            nextLength,
            nextPattern,
            nextDate,
          );
          final nextSerial = SecondPasswordValidator.validSerial((''));
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              record: data,
              password: '',
              currentPassword: '',
              confirmation: '',
              serial: '',
              terms: false,
              recordingConfirmed: false,
              editable: nextEditable,
              currentPasswordComplete: nextCurrentComplete,
              lengthValid: nextLength,
              patternValid: nextPattern,
              dateValid: nextDate,
              formComplete: nextForm,
              serialComplete: nextSerial,
              canContinue:
                  nextEditable &&
                  switch (state.step) {
                    SecondPasswordStep.selection => state.hasSelection,
                    SecondPasswordStep.password => nextForm,
                    SecondPasswordStep.serial => nextSerial,
                    SecondPasswordStep.instruction => true,
                    SecondPasswordStep.recording => false,
                  },
            ),
          );
        }
    }
  }

  String _newKey() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }

  PasswordCard? getCard(
    PasswordCatalog? catalog,
    String? cardId,
    PasswordCardKind? kind,
  ) {
    return catalog?.cards
        .where((c) => c.id == cardId && c.kind == kind)
        .firstOrNull;
  }

  bool checkEditable(
    RequestStatus status,
    PasswordCatalog? catalog,
    RequestStatus checkStatus,
    RequestStatus submissionStatus,
  ) {
    return status == RequestStatus.success &&
        catalog?.cards.isNotEmpty == true &&
        checkStatus != RequestStatus.loading &&
        submissionStatus != RequestStatus.loading &&
        submissionStatus != RequestStatus.success;
  }

  bool checkHasSelection(
    bool secondPasswordSelected,
    PasswordOperation? operation,
    PasswordCard? card,
  ) {
    return card != null && secondPasswordSelected && operation != null;
  }

  bool checkCurrentComplete(String currentPassword, bool change) {
    return !change || SecondPasswordValidator.hasValidLength(currentPassword);
  }

  bool checkDate(String password, PasswordCard? card) {
    return SecondPasswordValidator.avoidsKnownDates(
      password,
      card?.datePinCandidates ?? [],
    );
  }

  bool checkForm(
    String password,
    String confirmation,
    bool terms,
    bool currentComplete,
    bool length,
    bool pattern,
    bool date,
  ) {
    return currentComplete &&
        length &&
        pattern &&
        date &&
        password == confirmation &&
        terms;
  }
}
