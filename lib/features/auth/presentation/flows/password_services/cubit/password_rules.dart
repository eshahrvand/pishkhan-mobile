import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/validators/second_password_validator.dart';

import 'second_password_state.dart';
import '../../../../domain/entities/password_data.dart';

bool passwordEditable(SecondPasswordState state) =>
    state.status == RequestStatus.success &&
    state.catalog?.cards.isNotEmpty == true &&
    state.checkStatus != RequestStatus.loading &&
    state.submissionStatus != RequestStatus.loading &&
    state.submissionStatus != RequestStatus.success;

bool passwordIsChange(SecondPasswordState state) =>
    state.operation == PasswordOperation.changePassword;

bool passwordCurrentPasswordComplete(SecondPasswordState state) =>
    !passwordIsChange(state) ||
    SecondPasswordValidator.hasValidLength(state.currentPassword);

PasswordCard? passwordCard(SecondPasswordState state) {
  for (final card in state.catalog?.cards ?? <PasswordCard>[]) {
    if (card.id == state.cardId && card.kind == state.kind) return card;
  }
  return null;
}

bool passwordSelectionComplete(SecondPasswordState state) =>
    passwordHasSelection(state) &&
    passwordCard(state)!.supports(state.operation!);

bool passwordHasSelection(SecondPasswordState state) =>
    passwordCard(state) != null &&
    state.secondPasswordSelected &&
    state.operation != null;

bool passwordLengthValid(SecondPasswordState state) =>
    SecondPasswordValidator.hasValidLength(state.password);

bool passwordPatternValid(SecondPasswordState state) =>
    SecondPasswordValidator.hasSafePattern(state.password);

bool passwordDateValid(SecondPasswordState state) =>
    SecondPasswordValidator.avoidsKnownDates(
      state.password,
      passwordCard(state)?.datePinCandidates ?? [],
    );

bool passwordFormComplete(SecondPasswordState state) =>
    passwordCurrentPasswordComplete(state) &&
    passwordLengthValid(state) &&
    passwordPatternValid(state) &&
    passwordDateValid(state) &&
    state.password == state.confirmation &&
    state.terms;

bool passwordSerialComplete(SecondPasswordState state) =>
    SecondPasswordValidator.validSerial(state.serial);

bool passwordWalletSufficient(SecondPasswordState state) =>
    state.catalog != null &&
    state.catalog!.walletBalanceRial >= state.catalog!.feeRial;

bool passwordCanContinue(SecondPasswordState state) =>
    passwordEditable(state) &&
    switch (state.step) {
      // Status reads must remain possible for an already-approved card or a
      // user with insufficient balance; only a new request needs eligibility.
      SecondPasswordStep.selection => passwordHasSelection(state),
      SecondPasswordStep.password => passwordFormComplete(state),
      SecondPasswordStep.serial => passwordSerialComplete(state),
      SecondPasswordStep.instruction => true,
      SecondPasswordStep.recording =>
        state.recordingConfirmed &&
            passwordFormComplete(state) &&
            passwordSerialComplete(state),
    };
