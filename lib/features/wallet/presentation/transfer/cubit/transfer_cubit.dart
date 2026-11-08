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

part 'transfer_state.dart';
part 'transfer_cubit.freezed.dart';

class WalletTransferCubit extends Cubit<WalletTransferState> {
  WalletTransferCubit({
    WalletTransferState initialState = const WalletTransferState.initial(),
  }) : super(initialState);
  final fetchWalletCatalogUseCase = getIt<FetchWalletCatalogUseCase>();
  final inquireWalletRecipientUseCase = getIt<InquireWalletRecipientUseCase>();
  final transferWalletUseCase = getIt<TransferWalletUseCase>();
  int _recipientRequestId = 0;
  Timer? _inquiryTimer;
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

  void updateDestination(String value) {
    final normalized = WalletRules.normalize(value);
    final valid = WalletRules.validRecipient(normalized);
    _recipientRequestId++;
    _inquiryTimer?.cancel();
    // Editing invalidates the displayed owner immediately, even before the next debounced inquiry.
    emit(
      state.copyWith(
        destination: normalized,
        recipient: null,
        isDestinationError: value.isNotEmpty && !valid,
        canSubmit: false,
        recipientStatus: RequestStatus.initial,
        idempotencyKey: WalletRules.requestKey(),
      ),
    );
    if (valid) {
      _inquiryTimer = Timer(
        const Duration(milliseconds: 350),
        inquireRecipient,
      );
    }
  }

  Future<void> inquireRecipient() async {
    _inquiryTimer?.cancel();
    final requestId = ++_recipientRequestId;
    emit(state.copyWith(recipientStatus: RequestStatus.loading));
    final result = await inquireWalletRecipientUseCase(state.destination);
    if (requestId != _recipientRequestId) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            recipientStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            recipientStatus: RequestStatus.success,
            recipient: data,
            canSubmit: state.isAmountValid,
          ),
        );
    }
  }

  void updateAmount(String value) {
    final amount = WalletRules.amount(value);
    final valid = WalletRules.validAmount(
      amount,
      balance: state.wallet!.balanceRial,
    );
    emit(
      state.copyWith(
        amount: value,
        amountRial: amount,
        amountToman: amount == null ? null : amount / 10,
        isAmountValid: valid,
        isAmountError: value.isNotEmpty && !valid,
        canSubmit: valid && state.recipient != null,
        idempotencyKey: WalletRules.requestKey(),
      ),
    );
  }

  Future<void> submitTransfer() async {
    final request = WalletTransferRequest(
      amountRial: state.amountRial!,
      recipientId: state.recipient!.id,
      idempotencyKey: state.idempotencyKey!,
    );
    emit(state.copyWith(submissionStatus: RequestStatus.loading));
    final result = await transferWalletUseCase(request);
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
    _inquiryTimer?.cancel();
    return super.close();
  }
}
