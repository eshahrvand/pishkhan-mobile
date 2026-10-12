import 'package:pishkhan_mobile/modules/auth/domain/repositories/password_services_repository.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/modules/auth/presentation/features/password_services/cubit/password_rules.dart';

import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import 'second_password_state.dart';
export 'second_password_state.dart';

import '../../../../domain/entities/password_data.dart';
import '../../../../domain/usecases/password_services/password_usecases.dart';

class SecondPasswordCubit extends Cubit<SecondPasswordState> {
  SecondPasswordCubit({
    required this.repository,
    this.initialCardNumber,
    this.selectOperation = false,
  }) : super(const SecondPasswordState());
  final PasswordServicesRepository repository;
  final String? initialCardNumber;
  final bool selectOperation;
  PasswordOperation? get _initialOperation =>
      selectOperation ? null : PasswordOperation.setSecondPassword;
  int _generation = 0;
  String? _idempotencyKey;
  Future<void> load() async {
    final generation = ++_generation;
    _idempotencyKey = null;
    emit(
      state.copyWith(
        status: RequestStatus.loading,
        checkStatus: RequestStatus.initial,
        submissionStatus: RequestStatus.initial,
        step: SecondPasswordStep.selection,
        catalog: null,
        operation: _initialOperation,
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
    );
    final result = await LoadPasswordCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          SecondPasswordState(status: RequestStatus.failure, failure: failure),
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
          SecondPasswordState(
            status: RequestStatus.success,
            catalog: data,
            operation: _initialOperation,
            kind: selected?.kind,
            cardId: selected?.id,
          ),
        );
    }
  }

  void selectKind(PasswordCardKind kind) {
    if (!passwordEditable(state)) return;
    emit(
      SecondPasswordState(
        status: RequestStatus.success,
        catalog: state.catalog,
        operation: _initialOperation,
        kind: kind,
      ),
    );
    _idempotencyKey = null;
  }

  void selectCard(String id) {
    if (!passwordEditable(state) ||
        !(state.catalog?.cards.any(
              (c) => c.id == id && (state.kind == null || c.kind == state.kind),
            ) ??
            false)) {
      return;
    }
    emit(
      SecondPasswordState(
        status: RequestStatus.success,
        catalog: state.catalog,
        kind: state.catalog!.cards.firstWhere((card) => card.id == id).kind,
        cardId: id,
        operation: _initialOperation,
        secondPasswordSelected: state.secondPasswordSelected,
      ),
    );
    _idempotencyKey = null;
  }

  void selectSecondPassword() {
    if (passwordEditable(state)) {
      emit(state.copyWith(secondPasswordSelected: true));
    }
  }

  void chooseOperation(PasswordOperation operation) {
    if (!passwordEditable(state) ||
        !selectOperation ||
        operation == PasswordOperation.setSecondPassword ||
        state.operation == operation) {
      return;
    }
    _idempotencyKey = null;
    emit(
      SecondPasswordState(
        status: RequestStatus.success,
        catalog: state.catalog,
        kind: state.kind,
        cardId: state.cardId,
        secondPasswordSelected: state.secondPasswordSelected,
        operation: operation,
      ),
    );
  }

  void currentPasswordChanged(String value) {
    if (!passwordEditable(state)) return;
    final normalized = DigitNormalizer.normalize(value);
    if (normalized != state.currentPassword) _idempotencyKey = null;
    emit(
      state.copyWith(
        currentPassword: normalized,
        terms: false,
        recordingConfirmed: false,
        failure: null,
      ),
    );
  }

  void passwordChanged(String value) {
    if (passwordEditable(state)) {
      if (DigitNormalizer.normalize(value) != state.password) {
        _idempotencyKey = null;
      }
      emit(
        state.copyWith(
          password: DigitNormalizer.normalize(value),
          terms: false,
          recordingConfirmed: false,
          failure: null,
        ),
      );
    }
  }

  void confirmationChanged(String value) {
    if (passwordEditable(state)) {
      emit(
        state.copyWith(
          confirmation: DigitNormalizer.normalize(value),
          terms: false,
          recordingConfirmed: false,
          failure: null,
        ),
      );
    }
  }

  void serialChanged(String value) {
    if (passwordEditable(state)) {
      if (DigitNormalizer.normalize(value).trim().toUpperCase() !=
          state.serial) {
        _idempotencyKey = null;
      }
      emit(
        state.copyWith(
          serial: DigitNormalizer.normalize(value).trim().toUpperCase(),
          recordingConfirmed: false,
          failure: null,
        ),
      );
    }
  }

  void acceptTerms(bool value) {
    if (passwordEditable(state)) emit(state.copyWith(terms: value));
  }

  void confirmMockRecording() {
    if (passwordEditable(state) && state.step == SecondPasswordStep.recording) {
      emit(state.copyWith(recordingConfirmed: true));
    }
  }

  void recordAgain() {
    if (passwordEditable(state)) {
      emit(state.copyWith(recordingConfirmed: false));
    }
  }

  Future<void> next() async {
    if (!passwordCanContinue(state)) return;
    if (state.step == SecondPasswordStep.selection) {
      final generation = ++_generation;
      emit(
        state.copyWith(
          checkStatus: RequestStatus.loading,
          failure: null,
          record: null,
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
            state.copyWith(
              checkStatus: RequestStatus.failure,
              failure: failure,
            ),
          );
        case Success(:final data):
          if (data.status != PasswordRequestStatus.none) {
            emit(
              state.copyWith(checkStatus: RequestStatus.success, record: data),
            );
            return;
          }
          if (!passwordSelectionComplete(state) ||
              (!passwordIsChange(state) && !passwordWalletSufficient(state))) {
            emit(
              state.copyWith(
                checkStatus: RequestStatus.failure,
                failure: const DataFailure('password.request.ineligible'),
              ),
            );
            return;
          }
          _idempotencyKey = _newKey();
          emit(
            state.copyWith(
              checkStatus: RequestStatus.success,
              step: SecondPasswordStep.password,
            ),
          );
      }
    } else if (passwordIsChange(state) &&
        state.step == SecondPasswordStep.password) {
      await submit();
    } else if (state.step != SecondPasswordStep.recording) {
      emit(
        state.copyWith(
          step: SecondPasswordStep.values[state.step.index + 1],
          failure: null,
        ),
      );
    } else {
      await submit();
    }
  }

  bool back() {
    if (!passwordEditable(state) ||
        state.step == SecondPasswordStep.selection) {
      return false;
    }
    emit(
      state.copyWith(
        step: SecondPasswordStep.values[state.step.index - 1],
        record: null,
        failure: null,
      ),
    );
    return true;
  }

  void dismissRecord() {
    if (passwordEditable(state)) emit(state.copyWith(record: null));
  }

  Future<void> submit() async {
    if (!passwordCanContinue(state) ||
        (passwordIsChange(state)
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
      currentPassword: passwordIsChange(state) ? state.currentPassword : null,
      nationalCardSerial: state.serial,
      idempotencyKey: _idempotencyKey!,
      kycReference: passwordIsChange(state) ? '' : 'mock-kyc',
    );
    emit(
      state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
    );
    final result = await SubmitSecondPassword(repository)(request);
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
          ),
        );
      case Success(:final data):
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
}
