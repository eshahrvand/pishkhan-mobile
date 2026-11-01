import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
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
  Future<void> fetchSettings() async {
    emit(state.copyWith(settingsStatus: RequestStatus.loading));
    final result = await repository.fetchPhoneSettings();
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
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
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
        submissionStatus: RequestStatus.initial,
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
        isOtpValid: valid,
        isOtpError: normalized.isNotEmpty && !valid,
        canSubmit: _canSubmitOtp(
          isOtpValid: valid,
          termsAccepted: state.termsAccepted,
          remainingSeconds: state.remainingSeconds,
        ),
        idempotencyKey: null,
      ),
    );
  }

  void updateTerms(bool value) {
    emit(
      state.copyWith(
        termsAccepted: value,
        canSubmit:
            state.isPhoneNumberValid &&
            _canSubmitOtp(
              isOtpValid: state.isOtpValid,
              termsAccepted: value,
              remainingSeconds: state.remainingSeconds,
            ),
      ),
    );
  }

  Future<void> submitOtpRequest() async {
    emit(state.copyWith(otpRequestStatus: RequestStatus.loading));
    final result = await repository.requestPhoneOtp(state.phoneNumber);
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
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void _refreshOtpTime() {
    final remaining = _remainingSeconds(state.challenge!.expiresAt);
    if (remaining == 0) {
      _timer?.cancel();
    }
    emit(
      state.copyWith(
        remainingSeconds: remaining,
        canRequestOtp: _canRequestOtp(remaining, state.submissionStatus),
        canSubmit: _canSubmitOtp(
          isOtpValid: state.isOtpValid,
          termsAccepted: state.termsAccepted,
          remainingSeconds: remaining,
        ),
      ),
    );
  }

  bool _canSubmitOtp({
    required bool isOtpValid,
    required bool termsAccepted,
    required int remainingSeconds,
  }) {
    return isOtpValid &&
        remainingSeconds > 0 &&
        termsAccepted &&
        state.walletSufficient;
  }

  bool _canRequestOtp(int remainingSeconds, RequestStatus submissionStatus) {
    return remainingSeconds == 0 &&
        state.isPhoneNumberValid &&
        submissionStatus != RequestStatus.loading &&
        submissionStatus != RequestStatus.success;
  }

  int _remainingSeconds(DateTime deadline) {
    final milliseconds = deadline
        .difference(DateTime.now().toUtc())
        .inMilliseconds;
    return milliseconds <= 0 ? 0 : (milliseconds / 1000).ceil();
  }

  Future<void> submitPhoneChange() async {
    final key =
        state.idempotencyKey ??
        'phone-${DateTime.now().microsecondsSinceEpoch}';
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        canRequestOtp: false,
        idempotencyKey: key,
      ),
    );
    final result = await repository.changePhone(
      phoneNumber: state.phoneNumber,
      otp: state.otp,
      challengeId: state.challenge!.id,
      idempotencyKey: key,
    );
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
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            canRequestOtp: _canRequestOtp(
              state.remainingSeconds,
              RequestStatus.failure,
            ),
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void requestBack() {
    emit(state.copyWith(effect: ChangePhoneEffect.confirmExit));
  }

  void applyExitConfirmation(bool? confirmed) {
    if (confirmed == true) {
      emit(state.copyWith(effect: ChangePhoneEffect.back));
    }
  }

  void applySubmissionDismissal() {
    emit(state.copyWith(effect: ChangePhoneEffect.home));
  }

  void requestTerms() {
    emit(state.copyWith(effect: ChangePhoneEffect.terms));
  }

  void requestAssistant() {
    emit(state.copyWith(effect: ChangePhoneEffect.assistant));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeChangePhoneInteraction() {
    emit(state.copyWith(effect: null));
  }
}
