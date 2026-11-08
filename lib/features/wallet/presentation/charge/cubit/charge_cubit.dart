import '../../shared/wallet_labels.dart';
import '../../shared/wallet_receipt_effect.dart';

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';

import '../../../domain/entities/wallet.dart';
import '../../../domain/usecases/wallet_usecase.dart';
import '../../../domain/wallet_rules.dart';

part 'charge_state.dart';
part 'charge_cubit.freezed.dart';

class WalletChargeCubit extends Cubit<WalletChargeState> {
  WalletChargeCubit({
    WalletChargeState initialState = const WalletChargeState.initial(),
  }) : super(initialState);
  final fetchWalletCatalogUseCase = getIt<FetchWalletCatalogUseCase>();
  final requestWalletOtpUseCase = getIt<RequestWalletOtpUseCase>();
  final chargeWalletUseCase = getIt<ChargeWalletUseCase>();
  Timer? _timer;

  Future<void> fetchWallet() async {
    emit(state.copyWith(walletStatus: RequestStatus.loading));
    final result = await fetchWalletCatalogUseCase();
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            walletStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            walletStatus: RequestStatus.success,
            wallet: data.wallet,
            idempotencyKey: WalletRules.requestKey(),
          ),
        );
    }
  }

  void updateAmount(String value) {
    final amount = WalletRules.amount(value);
    final valid = WalletRules.validAmount(amount);
    _timer?.cancel();
    // Amount-bound OTP cannot authorize an edited payment. The visible OTP controls read these resets.
    emit(
      state.copyWith(
        amount: value,
        amountRial: amount,
        amountToman: amount == null ? null : amount / 10,
        isAmountValid: valid,
        isAmountError: value.isNotEmpty && !valid,
        challenge: null,
        otp: '',
        isOtpValid: false,
        remainingSeconds: 0,
        canSubmit: false,
        canRequestOtp: valid,
        idempotencyKey: WalletRules.requestKey(),
      ),
    );
  }

  void updateOtp(String value) {
    final normalized = WalletRules.normalize(value);
    final valid = WalletRules.validOtp(normalized, state.challenge!.codeLength);
    emit(
      state.copyWith(
        otp: normalized,
        isOtpValid: valid,
        canSubmit: _canSubmit(valid, state.remainingSeconds),
      ),
    );
  }

  Future<void> requestOtp() async {
    emit(state.copyWith(otpStatus: RequestStatus.loading));
    final result = await requestWalletOtpUseCase(
      WalletTransactionType.charge,
      state.amountRial!,
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            otpStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        _timer?.cancel();
        emit(
          state.copyWith(
            otpStatus: RequestStatus.success,
            challenge: data,
            otp: '',
            isOtpValid: false,
            canSubmit: false,
            canRequestOtp: false,
            remainingSeconds: WalletRules.remaining(data.expiresAt),
          ),
        );
        _timer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => updateCountdown(),
        );
    }
  }

  void updateCountdown() {
    final remaining = WalletRules.remaining(state.challenge!.expiresAt);
    if (remaining == 0) _timer?.cancel();
    emit(
      state.copyWith(
        remainingSeconds: remaining,
        canRequestOtp: remaining == 0 && state.isAmountValid,
        canSubmit: _canSubmit(state.isOtpValid, remaining),
      ),
    );
  }

  Future<void> submitPayment() async {
    final request = WalletPaymentRequest(
      amountRial: state.amountRial!,
      challengeId: state.challenge!.id,
      otp: state.otp,
      idempotencyKey: state.idempotencyKey!,
    );
    emit(state.copyWith(submissionStatus: RequestStatus.loading));
    final result = await chargeWalletUseCase(request);
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        _timer?.cancel();
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            shareText: walletReceiptShareText(data),
            canSubmit: false,
          ),
        );
    }
  }

  bool _canSubmit(bool isOtpValid, int remaining) =>
      state.isAmountValid && isOtpValid && remaining > 0;

  void applyShareResult(Result<void> result) {
    switch (result) {
      case Success():
        emit(state.copyWith(shareStatus: RequestStatus.success));
      case Err(:final failure):
        emit(
          state.copyWith(
            shareStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void requestShare() {
    emit(
      state.copyWith(
        shareStatus: RequestStatus.loading,
        effect: WalletReceiptEffect.share,
      ),
    );
  }

  void consumeInteraction() {
    emit(state.copyWith(effect: null));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
