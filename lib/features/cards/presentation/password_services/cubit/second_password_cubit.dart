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

  final repository = getIt<PasswordServicesRepository>();
  final String? initialCardNumber;
  final bool selectOperation;

  int _generation = 0;
  String? _idempotencyKey;

  void requestBack() {
    if (state.effect is PasswordExitRequested ||
        state.exitConfirmationOpen ||
        state.recordSheetOpen) {
      return;
    }
    if (!state.showFullStatus && back()) return;
    if (!state.showFullStatus &&
        state.submissionStatus != RequestStatus.success &&
        state.selectionComplete) {
      emit(
        state.copyWith(
          exitConfirmationOpen: true,
          effect: const PasswordExitConfirmationRequested(),
          effectId: state.effectId + 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          effect: const PasswordExitRequested(),
          effectId: state.effectId + 1,
        ),
      );
    }
  }

  void exitConfirmationResult(bool? confirmed) {
    if (!state.exitConfirmationOpen) return;
    emit(
      state.copyWith(
        exitConfirmationOpen: false,
        effect: confirmed == true ? const PasswordExitRequested() : null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void recordPresentationClosed() {
    if (!state.recordSheetOpen) return;
    if (state.submissionStatus == RequestStatus.success) {
      emit(
        state.copyWith(
          recordSheetOpen: false,
          effect: const PasswordHomeRequested(),
          effectId: state.effectId + 1,
        ),
      );
    } else {
      emit(state.copyWith(recordSheetOpen: false, record: null));
    }
  }

  void updateRecordingConfirmed(bool? confirmed) {
    if (confirmed == true) {
      confirmMockRecording();
    } else {
      recordAgain();
    }
  }

  Future<void> load() {
    final generation = ++_generation;
    _idempotencyKey = null;
    final initialOperation =
        selectOperation ? null : PasswordOperation.setSecondPassword;
    emit(
      _derive(
        state.copyWith(
          status: RequestStatus.loading,
          checkStatus: RequestStatus.initial,
          submissionStatus: RequestStatus.initial,
          step: SecondPasswordStep.selection,
          catalog: null,
          operation: initialOperation,
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
        ),
      ),
    );

    return LoadPasswordCatalog(repository)().then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            _derive(
              state.copyWith(
                status: RequestStatus.failure,
                failure: failure,
              ),
            ),
          );
        case Success(:final data):
          PasswordCard? selected;
          if (initialCardNumber != null) {
            final target = DigitNormalizer.normalize(initialCardNumber!)
                .replaceAll(' ', '');
            for (final card in data.cards) {
              if (DigitNormalizer.normalize(card.number).replaceAll(' ', '') ==
                  target) {
                selected = card;
                break;
              }
            }
          }
          emit(
            _derive(
              state.copyWith(
                status: RequestStatus.success,
                catalog: data,
                kind: selected?.kind,
                cardId: selected?.id,
                operation: initialOperation,
              ),
            ),
          );
      }
    });
  }

  void selectKind(PasswordCardKind kind) {
    if (!state.editable) return;
    _idempotencyKey = null;
    emit(
      _derive(
        state.copyWith(
          kind: kind,
          cardId: null,
          password: '',
          currentPassword: '',
          confirmation: '',
          serial: '',
          terms: false,
          recordingConfirmed: false,
        ),
      ),
    );
  }

  void selectCard(String id) {
    final card = state.catalog?.cards
        .where((c) => c.id == id && (state.kind == null || c.kind == state.kind))
        .firstOrNull;
    if (!state.editable || card == null) return;
    _idempotencyKey = null;
    emit(
      _derive(
        state.copyWith(
          cardId: id,
          kind: card.kind,
          operation:
              selectOperation ? null : PasswordOperation.setSecondPassword,
          password: '',
          currentPassword: '',
          confirmation: '',
          serial: '',
          terms: false,
          recordingConfirmed: false,
        ),
      ),
    );
  }

  void selectSecondPassword() {
    if (!state.editable) return;
    emit(_derive(state.copyWith(secondPasswordSelected: true)));
  }

  void chooseOperation(PasswordOperation operation) {
    if (!state.editable ||
        !selectOperation ||
        operation == PasswordOperation.setSecondPassword ||
        state.operation == operation) {
      return;
    }
    _idempotencyKey = null;
    emit(
      _derive(
        state.copyWith(
          operation: operation,
          password: '',
          currentPassword: '',
          confirmation: '',
          serial: '',
          terms: false,
          recordingConfirmed: false,
        ),
      ),
    );
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
    emit(
      _derive(
        state.copyWith(
          currentPassword: normalized,
          terms: false,
          recordingConfirmed: false,
          failure: null,
        ),
      ),
    );
  }

  void passwordChanged(String value) {
    if (state.isConfirmationError) {
      emit(state.copyWith(isConfirmationError: false));
    }
    if (!state.editable) return;
    final normalized = DigitNormalizer.normalize(value);
    if (normalized != state.password) _idempotencyKey = null;
    emit(
      _derive(
        state.copyWith(
          password: normalized,
          terms: false,
          recordingConfirmed: false,
          failure: null,
        ),
      ),
    );
  }

  void confirmationChanged(String value) {
    if (state.isConfirmationError) {
      emit(state.copyWith(isConfirmationError: false));
    }
    if (!state.editable) return;
    final normalized = DigitNormalizer.normalize(value);
    emit(
      _derive(
        state.copyWith(
          confirmation: normalized,
          terms: false,
          recordingConfirmed: false,
          failure: null,
        ),
      ),
    );
  }

  void serialChanged(String value) {
    if (state.isSerialError) {
      emit(state.copyWith(isSerialError: false));
    }
    if (!state.editable) return;
    final normalized = DigitNormalizer.normalize(value).trim().toUpperCase();
    if (normalized != state.serial) _idempotencyKey = null;
    emit(
      _derive(
        state.copyWith(
          serial: normalized,
          recordingConfirmed: false,
          failure: null,
        ),
      ),
    );
  }

  void acceptTerms(bool value) {
    if (!state.editable) return;
    emit(_derive(state.copyWith(terms: value)));
  }

  void confirmMockRecording() {
    if (!state.editable || state.step != SecondPasswordStep.recording) return;
    emit(_derive(state.copyWith(recordingConfirmed: true)));
  }

  void recordAgain() {
    if (!state.editable) return;
    emit(_derive(state.copyWith(recordingConfirmed: false)));
  }

  Future<void> next() {
    if (!state.canContinue) return Future.value();
    if (state.step == SecondPasswordStep.selection) {
      final generation = ++_generation;
      emit(
        _derive(
          state.copyWith(
            checkStatus: RequestStatus.loading,
            failure: null,
            record: null,
          ),
        ),
      );
      return CheckPasswordRequest(repository)(
        state.cardId!,
        operation: state.operation!,
      ).then((result) {
        if (isClosed || generation != _generation) return;
        switch (result) {
          case Err(:final failure):
            emit(
              _derive(
                state.copyWith(
                  checkStatus: RequestStatus.failure,
                  failure: failure,
                ),
              ),
            );
          case Success(:final data):
            if (data.status != PasswordRequestStatus.none) {
              emit(
                _derive(
                  state.copyWith(
                    checkStatus: RequestStatus.success,
                    record: data,
                    showFullStatus: state.isChange,
                    recordSheetOpen: !state.isChange,
                    effect: state.isChange
                        ? null
                        : PasswordRecordRequested(
                            data,
                            state.operation!,
                            newlySubmitted: false,
                          ),
                    effectId: state.effectId + 1,
                  ),
                ),
              );
              return;
            }
            if (!state.selectionComplete ||
                (!state.isChange && !state.walletSufficient)) {
              emit(
                _derive(
                  state.copyWith(
                    checkStatus: RequestStatus.failure,
                    failure: const DataFailure('password.request.ineligible'),
                  ),
                ),
              );
              return;
            }
            _idempotencyKey = _newKey();
            emit(
              _derive(
                state.copyWith(
                  checkStatus: RequestStatus.success,
                  step: SecondPasswordStep.password,
                ),
              ),
            );
        }
      });
    } else if (state.isChange && state.step == SecondPasswordStep.password) {
      return submit();
    } else if (state.step != SecondPasswordStep.recording) {
      emit(
        _derive(
          state.copyWith(
            step: SecondPasswordStep.values[state.step.index + 1],
            failure: null,
          ),
        ),
      );
      return Future.value();
    } else {
      return submit();
    }
  }

  bool back() {
    if (state.step == SecondPasswordStep.selection) {
      return false;
    }
    emit(
      _derive(
        state.copyWith(
          step: SecondPasswordStep.values[state.step.index - 1],
          record: null,
          failure: null,
        ),
      ),
    );
    return true;
  }

  void dismissRecord() {
    emit(
      state.copyWith(
        record: null,
        showFullStatus: false,
        recordSheetOpen: false,
      ),
    );
  }

  Future<void> submit() {
    if (!state.canContinue ||
        (state.isChange
            ? state.step != SecondPasswordStep.password
            : state.step != SecondPasswordStep.recording)) {
      return Future.value();
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
    emit(
      _derive(
        state.copyWith(
          submissionStatus: RequestStatus.loading,
          failure: null,
        ),
      ),
    );
    return SubmitSecondPassword(repository)(request).then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            _derive(
              state.copyWith(
                submissionStatus: RequestStatus.failure,
                failure: failure,
              ),
            ),
          );
        case Success(:final data):
          emit(
            _derive(
              state.copyWith(
                submissionStatus: RequestStatus.success,
                record: data,
                showFullStatus: false,
                recordSheetOpen: true,
                effect: PasswordRecordRequested(
                  data,
                  state.operation!,
                  newlySubmitted: true,
                ),
                effectId: state.effectId + 1,
                password: '',
                currentPassword: '',
                confirmation: '',
                serial: '',
                terms: false,
                recordingConfirmed: false,
              ),
            ),
          );
      }
    });
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

  List<PasswordCard> cardsForKind(
    PasswordCatalog? catalog,
    PasswordCardKind? kind,
  ) {
    final selectedKind = kind ?? PasswordCardKind.resalat;
    return catalog?.cards.where((card) => card.kind == selectedKind).toList() ??
        <PasswordCard>[];
  }

  SecondPasswordState _derive(SecondPasswordState s) {
    final card = s.catalog?.cards
        .where((c) => c.id == s.cardId && (s.kind == null || c.kind == s.kind))
        .firstOrNull;
    final isChange = s.operation == PasswordOperation.changePassword;
    final editable = s.status == RequestStatus.success &&
        (s.catalog?.cards.isNotEmpty ?? false) &&
        s.checkStatus != RequestStatus.loading &&
        s.submissionStatus != RequestStatus.loading &&
        s.submissionStatus != RequestStatus.success;
    final hasSelection =
        card != null && s.secondPasswordSelected && s.operation != null;
    final selectionComplete = hasSelection && card.supports(s.operation!);
    final walletSufficient = s.catalog != null &&
        s.catalog!.walletBalanceRial >= s.catalog!.feeRial;
    final currentPasswordComplete =
        !isChange || SecondPasswordValidator.hasValidLength(s.currentPassword);
    final lengthValid = SecondPasswordValidator.hasValidLength(s.password);
    final patternValid = SecondPasswordValidator.hasSafePattern(s.password);
    final dateValid = SecondPasswordValidator.avoidsKnownDates(
      s.password,
      card?.datePinCandidates ?? const [],
    );
    final formComplete = currentPasswordComplete &&
        lengthValid &&
        patternValid &&
        dateValid &&
        s.password == s.confirmation &&
        s.terms;
    final serialComplete = SecondPasswordValidator.validSerial(s.serial);
    final canContinue = editable &&
        switch (s.step) {
          SecondPasswordStep.selection => hasSelection,
          SecondPasswordStep.password => formComplete,
          SecondPasswordStep.serial => serialComplete,
          SecondPasswordStep.instruction => true,
          SecondPasswordStep.recording =>
            s.recordingConfirmed && formComplete && serialComplete,
        };

    return s.copyWith(
      card: card,
      cardsForSelectedKind: cardsForKind(s.catalog, s.kind),
      isChange: isChange,
      editable: editable,
      hasSelection: hasSelection,
      selectionComplete: selectionComplete,
      walletSufficient: walletSufficient,
      currentPasswordComplete: currentPasswordComplete,
      lengthValid: lengthValid,
      patternValid: patternValid,
      dateValid: dateValid,
      formComplete: formComplete,
      serialComplete: serialComplete,
      canContinue: canContinue,
    );
  }
}
