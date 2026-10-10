import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/validators/second_password_validator.dart';

import '../../domain/password_data.dart';
import '../../domain/password_usecases.dart';

enum SecondPasswordStep { selection, password, serial, instruction, recording }

enum SecondPasswordStatus {
  initial,
  loading,
  ready,
  checking,
  submitting,
  failed,
  empty,
  submitted,
}

class SecondPasswordState extends Equatable {
  const SecondPasswordState({
    this.status = SecondPasswordStatus.initial,
    this.step = SecondPasswordStep.selection,
    this.catalog,
    this.kind,
    this.cardId,
    this.secondPasswordSelected = false,
    this.password = '',
    this.confirmation = '',
    this.serial = '',
    this.terms = false,
    this.recordingConfirmed = false,
    this.record,
    this.failure,
  });
  final SecondPasswordStatus status;
  final SecondPasswordStep step;
  final PasswordCatalog? catalog;
  final PasswordCardKind? kind;
  final String? cardId;
  final bool secondPasswordSelected, terms, recordingConfirmed;
  final String password, confirmation, serial;
  final PasswordRequestRecord? record;
  final Failure? failure;
  PasswordCard? get card {
    for (final card in catalog?.cards ?? <PasswordCard>[]) {
      if (card.id == cardId && card.kind == kind) return card;
    }
    return null;
  }

  bool get selectionComplete =>
      card?.canSetSecondPassword == true && secondPasswordSelected;
  bool get hasSelection => card != null && secondPasswordSelected;
  bool get lengthValid => SecondPasswordValidator.hasValidLength(password);
  bool get patternValid => SecondPasswordValidator.hasSafePattern(password);
  bool get dateValid => SecondPasswordValidator.avoidsKnownDates(
    password,
    card?.datePinCandidates ?? [],
  );
  bool get passwordComplete =>
      lengthValid &&
      patternValid &&
      dateValid &&
      password == confirmation &&
      terms;
  bool get serialComplete => SecondPasswordValidator.validSerial(serial);
  bool get walletSufficient =>
      catalog != null && catalog!.walletBalanceRial >= catalog!.feeRial;
  bool get canContinue =>
      status == SecondPasswordStatus.ready &&
      switch (step) {
        // Status reads must remain possible for an already-approved card or a
        // user with insufficient balance; only a new request needs eligibility.
        SecondPasswordStep.selection => hasSelection,
        SecondPasswordStep.password => passwordComplete,
        SecondPasswordStep.serial => serialComplete,
        SecondPasswordStep.instruction => true,
        SecondPasswordStep.recording =>
          recordingConfirmed && passwordComplete && serialComplete,
      };
  SecondPasswordState copyWith({
    SecondPasswordStatus? status,
    SecondPasswordStep? step,
    PasswordCatalog? catalog,
    PasswordCardKind? kind,
    String? cardId,
    bool clearCard = false,
    bool? secondPasswordSelected,
    String? password,
    String? confirmation,
    String? serial,
    bool? terms,
    bool? recordingConfirmed,
    PasswordRequestRecord? record,
    bool clearRecord = false,
    Failure? failure,
    bool clearFailure = false,
  }) => SecondPasswordState(
    status: status ?? this.status,
    step: step ?? this.step,
    catalog: catalog ?? this.catalog,
    kind: kind ?? this.kind,
    cardId: clearCard ? null : cardId ?? this.cardId,
    secondPasswordSelected:
        secondPasswordSelected ?? this.secondPasswordSelected,
    password: password ?? this.password,
    confirmation: confirmation ?? this.confirmation,
    serial: serial ?? this.serial,
    terms: terms ?? this.terms,
    recordingConfirmed: recordingConfirmed ?? this.recordingConfirmed,
    record: clearRecord ? null : record ?? this.record,
    failure: clearFailure ? null : failure ?? this.failure,
  );
  @override
  bool get stringify => false;
  @override
  List<Object?> get props => [
    status,
    step,
    catalog,
    kind,
    cardId,
    secondPasswordSelected,
    password,
    confirmation,
    serial,
    terms,
    recordingConfirmed,
    record,
    failure,
  ];
}

class SecondPasswordCubit extends Cubit<SecondPasswordState> {
  SecondPasswordCubit({required this.repository, this.initialCardNumber})
    : super(const SecondPasswordState());
  final PasswordServicesRepository repository;
  final String? initialCardNumber;
  int _generation = 0;
  String? _idempotencyKey;
  bool get editable => state.status == SecondPasswordStatus.ready;
  Future<void> load() async {
    final generation = ++_generation;
    _idempotencyKey = null;
    emit(const SecondPasswordState(status: SecondPasswordStatus.loading));
    final result = await LoadPasswordCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          SecondPasswordState(
            status: SecondPasswordStatus.failed,
            failure: failure,
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
          SecondPasswordState(
            status: data.cards.isEmpty
                ? SecondPasswordStatus.empty
                : SecondPasswordStatus.ready,
            catalog: data,
            kind: selected?.kind,
            cardId: selected?.id,
          ),
        );
    }
  }

  void selectKind(PasswordCardKind kind) {
    if (!editable) return;
    emit(
      SecondPasswordState(
        status: SecondPasswordStatus.ready,
        catalog: state.catalog,
        kind: kind,
      ),
    );
    _idempotencyKey = null;
  }

  void selectCard(String id) {
    if (!editable ||
        !(state.catalog?.cards.any(
              (c) => c.id == id && (state.kind == null || c.kind == state.kind),
            ) ??
            false)) {
      return;
    }
    emit(
      SecondPasswordState(
        status: SecondPasswordStatus.ready,
        catalog: state.catalog,
        kind: state.catalog!.cards.firstWhere((card) => card.id == id).kind,
        cardId: id,
        secondPasswordSelected: state.secondPasswordSelected,
      ),
    );
    _idempotencyKey = null;
  }

  void selectSecondPassword() {
    if (editable) emit(state.copyWith(secondPasswordSelected: true));
  }

  void passwordChanged(String value) {
    if (editable) {
      if (DigitNormalizer.normalize(value) != state.password) {
        _idempotencyKey = null;
      }
      emit(
        state.copyWith(
          password: DigitNormalizer.normalize(value),
          terms: false,
          recordingConfirmed: false,
          clearFailure: true,
        ),
      );
    }
  }

  void confirmationChanged(String value) {
    if (editable) {
      emit(
        state.copyWith(
          confirmation: DigitNormalizer.normalize(value),
          terms: false,
          recordingConfirmed: false,
          clearFailure: true,
        ),
      );
    }
  }

  void serialChanged(String value) {
    if (editable) {
      if (DigitNormalizer.normalize(value).trim().toUpperCase() !=
          state.serial) {
        _idempotencyKey = null;
      }
      emit(
        state.copyWith(
          serial: DigitNormalizer.normalize(value).trim().toUpperCase(),
          recordingConfirmed: false,
          clearFailure: true,
        ),
      );
    }
  }

  void acceptTerms(bool value) {
    if (editable) emit(state.copyWith(terms: value));
  }

  void confirmMockRecording() {
    if (editable && state.step == SecondPasswordStep.recording) {
      emit(state.copyWith(recordingConfirmed: true));
    }
  }

  void recordAgain() {
    if (editable) emit(state.copyWith(recordingConfirmed: false));
  }

  Future<void> next() async {
    if (!state.canContinue) return;
    if (state.step == SecondPasswordStep.selection) {
      final generation = ++_generation;
      emit(
        state.copyWith(
          status: SecondPasswordStatus.checking,
          clearFailure: true,
          clearRecord: true,
        ),
      );
      final result = await CheckPasswordRequest(repository)(state.cardId!);
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              status: SecondPasswordStatus.ready,
              failure: failure,
            ),
          );
        case Success(:final data):
          if (data.status != PasswordRequestStatus.none) {
            emit(
              state.copyWith(status: SecondPasswordStatus.ready, record: data),
            );
            return;
          }
          if (!state.selectionComplete || !state.walletSufficient) {
            emit(
              state.copyWith(
                status: SecondPasswordStatus.ready,
                failure: const DataFailure('password.request.ineligible'),
              ),
            );
            return;
          }
          _idempotencyKey = _newKey();
          emit(
            state.copyWith(
              status: SecondPasswordStatus.ready,
              step: SecondPasswordStep.password,
            ),
          );
      }
    } else if (state.step != SecondPasswordStep.recording) {
      emit(
        state.copyWith(
          step: SecondPasswordStep.values[state.step.index + 1],
          clearFailure: true,
        ),
      );
    } else {
      await submit();
    }
  }

  bool back() {
    if (!editable || state.step == SecondPasswordStep.selection) return false;
    emit(
      state.copyWith(
        step: SecondPasswordStep.values[state.step.index - 1],
        clearRecord: true,
        clearFailure: true,
      ),
    );
    return true;
  }

  void dismissRecord() {
    if (editable) emit(state.copyWith(clearRecord: true));
  }

  Future<void> submit() async {
    if (!state.canContinue || state.step != SecondPasswordStep.recording) {
      return;
    }
    _idempotencyKey ??= _newKey();
    final generation = ++_generation;
    final request = SetSecondPasswordRequest(
      cardId: state.cardId!,
      password: state.password,
      nationalCardSerial: state.serial,
      idempotencyKey: _idempotencyKey!,
      kycReference: 'mock-kyc',
    );
    emit(
      state.copyWith(
        status: SecondPasswordStatus.submitting,
        clearFailure: true,
      ),
    );
    final result = await SubmitSecondPassword(repository)(request);
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(status: SecondPasswordStatus.ready, failure: failure),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            status: SecondPasswordStatus.submitted,
            record: data,
            password: '',
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
