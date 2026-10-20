import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/phone_number_validator.dart';
import 'package:pishkhan_mobile/core/validators/code_validator.dart';

import '../../../domain/entities/personal_information.dart';
import '../../../domain/repositories/personal_information_repository.dart';
part 'change_phone_state.dart';
part 'change_phone_cubit.freezed.dart';

class ChangePhoneCubit extends Cubit<ChangePhoneState> {
  ChangePhoneCubit({
    ChangePhoneState initialState = const ChangePhoneState.initial(),
  }) : super(initialState);
  final repository = getIt<PersonalInformationRepository>();
  Timer? _timer;
  Future<void> fetchSettings() {
    emit(state.copyWith(settingsStatus: RequestStatus.loading));
    return repository.fetchPhoneSettings().then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              settingsStatus: RequestStatus.success,
              settings: data,
              walletSufficient: data.walletBalanceRial >= data.feeRial,
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              settingsStatus: RequestStatus.failure,
              settingsFailure: failure,
            ),
          );
      }
    });
  }

  void updatePhoneNumber(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final valid =
        PhoneNumberValidator.isValid(normalized) &&
        normalized != state.settings!.phoneNumber;
    _timer?.cancel();
    emit(
      state.copyWith(
        phoneNumber: normalized,
        otpRequestStatus: RequestStatus.initial,
        otpRequestFailure: null,
        submissionStatus: RequestStatus.initial,
        submissionFailure: null,
        isPhoneNumberValid: valid,
        isPhoneNumberError: normalized.isNotEmpty && !valid,
        challenge: null,
        otp: '',
        isOtpValid: false,
        isOtpError: false,
        remainingSeconds: 0,
        canRequestOtp: valid,
        canSubmit: false,
        idempotencyKey: null,
      ),
    );
  }

  void validatePhoneNumber() {
    emit(state.copyWith(isPhoneNumberError: !state.isPhoneNumberValid));
  }

  void updateOtp(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final valid = CodeValidator.isValid(
      normalized,
      length: state.challenge!.codeLength,
    );
    emit(
      state.copyWith(
        otp: normalized,
        submissionStatus: RequestStatus.initial,
        submissionFailure: null,
        isOtpValid: valid,
        isOtpError: normalized.isNotEmpty && !valid,
        canSubmit:
            valid &&
            state.remainingSeconds > 0 &&
            state.termsAccepted &&
            state.walletSufficient,
        idempotencyKey: null,
      ),
    );
  }

  void updateTerms(bool value) {
    emit(
      state.copyWith(
        termsAccepted: value,
        canSubmit:
            value &&
            state.isOtpValid &&
            state.remainingSeconds > 0 &&
            state.isPhoneNumberValid &&
            state.walletSufficient,
      ),
    );
  }

  Future<void> submitOtpRequest() {
    emit(
      state.copyWith(
        otpRequestStatus: RequestStatus.loading,
        otpRequestFailure: null,
      ),
    );
    return repository.requestPhoneOtp(state.phoneNumber).then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              otpRequestStatus: RequestStatus.success,
              challenge: data,
              remainingSeconds: _remainingSeconds(data.expiresAt),
              canRequestOtp: false,
              otp: '',
              isOtpValid: false,
              isOtpError: false,
              canSubmit: false,
              idempotencyKey: null,
            ),
          );
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 1), (_) {
            _refreshOtpTime();
          });
        case Err(:final failure):
          emit(
            state.copyWith(
              otpRequestStatus: RequestStatus.failure,
              otpRequestFailure: failure,
            ),
          );
      }
    });
  }

  void _refreshOtpTime() {
    final remaining = _remainingSeconds(state.challenge!.expiresAt);
    if (remaining == 0) {
      _timer?.cancel();
    }
    emit(
      state.copyWith(
        remainingSeconds: remaining,
        canRequestOtp:
            remaining == 0 &&
            state.isPhoneNumberValid &&
            state.submissionStatus != RequestStatus.loading &&
            state.submissionStatus != RequestStatus.success,
        canSubmit:
            remaining > 0 &&
            state.isOtpValid &&
            state.termsAccepted &&
            state.walletSufficient,
      ),
    );
  }

  int _remainingSeconds(DateTime deadline) {
    final milliseconds = deadline
        .difference(DateTime.now().toUtc())
        .inMilliseconds;
    return milliseconds <= 0 ? 0 : (milliseconds / 1000).ceil();
  }

  Future<void> submitPhoneChange() {
    final key =
        state.idempotencyKey ??
        'phone-${DateTime.now().microsecondsSinceEpoch}';
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        canRequestOtp: false,
        submissionFailure: null,
        idempotencyKey: key,
      ),
    );
    return repository
        .changePhone(
          phoneNumber: state.phoneNumber,
          otp: state.otp,
          challengeId: state.challenge!.id,
          idempotencyKey: key,
        )
        .then((result) {
          switch (result) {
            case Success():
              _timer?.cancel();
              emit(
                state.copyWith(
                  submissionStatus: RequestStatus.success,
                  canSubmit: false,
                  canRequestOtp: false,
                  otp: '',
                  isOtpValid: false,
                  effect: ChangePhoneEffect.submitted,
                  effectId: state.effectId + 1,
                ),
              );
            case Err(:final failure):
              emit(
                state.copyWith(
                  submissionStatus: RequestStatus.failure,
                  canRequestOtp:
                      state.remainingSeconds == 0 && state.isPhoneNumberValid,
                  submissionFailure: failure,
                ),
              );
          }
        });
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: ChangePhoneEffect.confirmExit,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    if (confirmed == true) {
      emit(
        state.copyWith(
          effect: ChangePhoneEffect.back,
          effectId: state.effectId + 1,
        ),
      );
    }
  }

  void applySubmissionDismissal() {
    emit(
      state.copyWith(
        effect: ChangePhoneEffect.home,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestTerms() {
    emit(
      state.copyWith(
        effect: ChangePhoneEffect.terms,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        effect: ChangePhoneEffect.assistant,
        effectId: state.effectId + 1,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
