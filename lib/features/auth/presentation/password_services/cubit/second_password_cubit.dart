import 'package:pishkhan_mobile/features/auth/domain/repositories/password_services_repository.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'dart:math';

import 'package:pishkhan_mobile/core/validators/second_password_validator.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import 'second_password_state.dart';
export 'second_password_state.dart';

import '../../../domain/entities/password_data.dart';
import '../../../domain/usecases/password_services.dart';

class SecondPasswordCubit extends Cubit<SecondPasswordState> {
  SecondPasswordCubit({
    SecondPasswordState initialState = const SecondPasswordState(),
    required this.repository,
    this.initialCardNumber,
    this.selectOperation = false,
  }) : super(_prepareState(initialState));
  final PasswordServicesRepository repository;
  final String? initialCardNumber;
  final bool selectOperation;

  int _generation = 0;
  String? _idempotencyKey;
  Future<void> load() async {
    final generation = ++_generation;
    _idempotencyKey = null;
    emit(
      _prepareState(
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
        ),
      ),
    );
    final result = await LoadPasswordCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          _prepareState(
            SecondPasswordState(
              status: RequestStatus.failure,
              failure: failure,
            ),
          ),
        );
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
        emit(
          _prepareState(
            SecondPasswordState(
              status: RequestStatus.success,
              catalog: data,
              operation: (selectOperation
                  ? null
                  : PasswordOperation.setSecondPassword),
              kind: selected?.kind,
              cardId: selected?.id,
            ),
          ),
        );
    }
  }

  void selectKind(PasswordCardKind kind) {
    if (!state.editable) return;
    emit(
      _prepareState(
        SecondPasswordState(
          status: RequestStatus.success,
          catalog: state.catalog,
          operation: (selectOperation
              ? null
              : PasswordOperation.setSecondPassword),
          kind: kind,
        ),
      ),
    );
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
    emit(
      _prepareState(
        SecondPasswordState(
          status: RequestStatus.success,
          catalog: state.catalog,
          kind: state.catalog!.cards.firstWhere((card) => card.id == id).kind,
          cardId: id,
          operation: (selectOperation
              ? null
              : PasswordOperation.setSecondPassword),
          secondPasswordSelected: state.secondPasswordSelected,
        ),
      ),
    );
    _idempotencyKey = null;
  }

  void selectSecondPassword() {
    if (state.editable) {
      emit(_prepareState(state.copyWith(secondPasswordSelected: true)));
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
    emit(
      _prepareState(
        SecondPasswordState(
          status: RequestStatus.success,
          catalog: state.catalog,
          kind: state.kind,
          cardId: state.cardId,
          secondPasswordSelected: state.secondPasswordSelected,
          operation: operation,
        ),
      ),
    );
  }

  void currentPasswordChanged(String value) {
    if (!state.editable) return;
    final normalized = DigitNormalizer.normalize(value);
    if (normalized != state.currentPassword) _idempotencyKey = null;
    emit(
      _prepareState(
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
    if (state.editable) {
      if (DigitNormalizer.normalize(value) != state.password) {
        _idempotencyKey = null;
      }
      emit(
        _prepareState(
          state.copyWith(
            password: DigitNormalizer.normalize(value),
            terms: false,
            recordingConfirmed: false,
            failure: null,
          ),
        ),
      );
    }
  }

  void confirmationChanged(String value) {
    if (state.editable) {
      emit(
        _prepareState(
          state.copyWith(
            confirmation: DigitNormalizer.normalize(value),
            terms: false,
            recordingConfirmed: false,
            failure: null,
          ),
        ),
      );
    }
  }

  void serialChanged(String value) {
    if (state.editable) {
      if (DigitNormalizer.normalize(value).trim().toUpperCase() !=
          state.serial) {
        _idempotencyKey = null;
      }
      emit(
        _prepareState(
          state.copyWith(
            serial: DigitNormalizer.normalize(value).trim().toUpperCase(),
            recordingConfirmed: false,
            failure: null,
          ),
        ),
      );
    }
  }

  void acceptTerms(bool value) {
    if (state.editable) emit(_prepareState(state.copyWith(terms: value)));
  }

  void confirmMockRecording() {
    if (state.editable && state.step == SecondPasswordStep.recording) {
      emit(_prepareState(state.copyWith(recordingConfirmed: true)));
    }
  }

  void recordAgain() {
    if (state.editable) {
      emit(_prepareState(state.copyWith(recordingConfirmed: false)));
    }
  }

  Future<void> next() async {
    if (!state.canContinue) return;
    if (state.step == SecondPasswordStep.selection) {
      final generation = ++_generation;
      emit(
        _prepareState(
          state.copyWith(
            checkStatus: RequestStatus.loading,
            failure: null,
            record: null,
          ),
        ),
      );
      final result = await CheckPasswordRequest(repository)(
        state.cardId!,
        operation: state.operation!,
      );
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            _prepareState(
              state.copyWith(
                checkStatus: RequestStatus.failure,
                failure: failure,
              ),
            ),
          );
        case Success(:final data):
          if (data.status != PasswordRequestStatus.none) {
            emit(
              _prepareState(
                state.copyWith(
                  checkStatus: RequestStatus.success,
                  record: data,
                ),
              ),
            );
            return;
          }
          if (!state.selectionComplete ||
              (!state.isChange && !state.walletSufficient)) {
            emit(
              _prepareState(
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
            _prepareState(
              state.copyWith(
                checkStatus: RequestStatus.success,
                step: SecondPasswordStep.password,
              ),
            ),
          );
      }
    } else if (state.isChange && state.step == SecondPasswordStep.password) {
      await submit();
    } else if (state.step != SecondPasswordStep.recording) {
      emit(
        _prepareState(
          state.copyWith(
            step: SecondPasswordStep.values[state.step.index + 1],
            failure: null,
          ),
        ),
      );
    } else {
      await submit();
    }
  }

  bool back() {
    if (!state.editable || state.step == SecondPasswordStep.selection) {
      return false;
    }
    emit(
      _prepareState(
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
    if (state.editable) emit(_prepareState(state.copyWith(record: null)));
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
    emit(
      _prepareState(
        state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
      ),
    );
    final result = await SubmitSecondPassword(repository)(request);
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          _prepareState(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              failure: failure,
            ),
          ),
        );
      case Success(:final data):
        emit(
          _prepareState(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              record: data,
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

  static SecondPasswordState _prepareState(SecondPasswordState next) {
    final card = next.catalog?.cards
        .where((c) => c.id == next.cardId && c.kind == next.kind)
        .firstOrNull;
    final change = next.operation == PasswordOperation.changePassword;
    final editable =
        next.status == RequestStatus.success &&
        next.catalog?.cards.isNotEmpty == true &&
        next.checkStatus != RequestStatus.loading &&
        next.submissionStatus != RequestStatus.loading &&
        next.submissionStatus != RequestStatus.success;
    final hasSelection =
        card != null && next.secondPasswordSelected && next.operation != null;
    final currentComplete =
        !change || SecondPasswordValidator.hasValidLength(next.currentPassword);
    final length = SecondPasswordValidator.hasValidLength(next.password);
    final pattern = SecondPasswordValidator.hasSafePattern(next.password);
    final date = SecondPasswordValidator.avoidsKnownDates(
      next.password,
      card?.datePinCandidates ?? [],
    );
    final form =
        currentComplete &&
        length &&
        pattern &&
        date &&
        next.password == next.confirmation &&
        next.terms;
    final serial = SecondPasswordValidator.validSerial(next.serial);
    return next.copyWith(
      card: card,
      editable: editable,
      isChange: change,
      currentPasswordComplete: currentComplete,
      hasSelection: hasSelection,
      selectionComplete: hasSelection && card.supports(next.operation!),
      lengthValid: length,
      patternValid: pattern,
      dateValid: date,
      formComplete: form,
      serialComplete: serial,
      walletSufficient:
          next.catalog != null &&
          next.catalog!.walletBalanceRial >= next.catalog!.feeRial,
      canContinue:
          editable &&
          switch (next.step) {
            SecondPasswordStep.selection => hasSelection,
            SecondPasswordStep.password => form,
            SecondPasswordStep.serial => serial,
            SecondPasswordStep.instruction => true,
            SecondPasswordStep.recording =>
              next.recordingConfirmed && form && serial,
          },
    );
  }
}
