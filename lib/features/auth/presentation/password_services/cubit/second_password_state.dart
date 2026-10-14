import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/password_data.dart';

part 'second_password_state.freezed.dart';

enum SecondPasswordStep { selection, password, serial, instruction, recording }

@Freezed(toStringOverride: false)
abstract class SecondPasswordState with _$SecondPasswordState {
  const factory SecondPasswordState({
    @Default(false) bool editable,
    @Default(false) bool isChange,
    @Default(true) bool currentPasswordComplete,
    PasswordCard? card,
    @Default(false) bool selectionComplete,
    @Default(false) bool hasSelection,
    @Default(false) bool lengthValid,
    @Default(false) bool patternValid,
    @Default(true) bool dateValid,
    @Default(false) bool formComplete,
    @Default(false) bool serialComplete,
    @Default(false) bool walletSufficient,
    @Default(false) bool canContinue,
    @Default(RequestStatus.initial) RequestStatus status,
    @Default(RequestStatus.initial) RequestStatus checkStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(SecondPasswordStep.selection) SecondPasswordStep step,
    PasswordCatalog? catalog,
    @Default(PasswordOperation.setSecondPassword) PasswordOperation? operation,
    PasswordCardKind? kind,
    String? cardId,
    @Default(false) bool secondPasswordSelected,
    @Default('') String password,
    @Default('') String currentPassword,
    @Default('') String confirmation,
    @Default('') String serial,
    @Default(false) bool terms,
    @Default(false) bool recordingConfirmed,
    PasswordRequestRecord? record,
    Failure? failure,
  }) = _SecondPasswordState;
}
