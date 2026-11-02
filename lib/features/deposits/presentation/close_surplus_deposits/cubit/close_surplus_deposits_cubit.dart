import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/surplus_deposit_closure.dart';
import '../../../domain/usecases/close_surplus_deposits_usecase.dart';

part 'close_surplus_deposits_state.dart';
part 'close_surplus_deposits_cubit.freezed.dart';

class CloseSurplusDepositsCubit extends Cubit<CloseSurplusDepositsState> {
  CloseSurplusDepositsCubit({
    this.initialDepositNumber,
    CloseSurplusDepositsState initialState =
        const CloseSurplusDepositsState.initial(),
  }) : super(initialState);

  final String? initialDepositNumber;
  final fetchPrimaryDepositsUseCase = getIt<FetchPrimaryDepositsUseCase>();
  final closeRemainingDepositsUseCase = getIt<CloseRemainingDepositsUseCase>();

  Future<void> fetchPrimaryDeposits() async {
    emit(
      state.copyWith(depositsStatus: RequestStatus.loading, isEditable: false),
    );
    final result = await fetchPrimaryDepositsUseCase();
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            depositsStatus: RequestStatus.failure,
            isEditable: true,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        final deposit = _resolvePrimaryDeposit(data);
        emit(
          state.copyWith(
            depositsStatus: RequestStatus.success,
            deposits: data,
            deposit: deposit,
            isEditable: true,
            step: _hasSurplusDeposits(data)
                ? CloseSurplusDepositsStep.primaryDeposit
                : CloseSurplusDepositsStep.empty,
            canContinue:
                !_hasSurplusDeposits(data) ||
                (deposit != null && state.termsAccepted),
            idempotencyKey: _createRequestKey(),
          ),
        );
    }
  }

  void selectPrimaryDeposit(ListedDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        termsAccepted: false,
        canContinue: false,
        hasChanges: true,
        submissionStatus: RequestStatus.initial,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canContinue: accepted && state.deposit != null,
        hasChanges: true,
      ),
    );
  }

  Future<void> continueFlow() async {
    switch (state.step) {
      case CloseSurplusDepositsStep.primaryDeposit:
        await submitClosure();
      case CloseSurplusDepositsStep.empty:
        emit(state.copyWith(effect: CloseSurplusDepositsEffect.back));
        break;
    }
  }

  Future<void> submitClosure() async {
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
      ),
    );
    final result = await closeRemainingDepositsUseCase(
      state.deposit!,
      idempotencyKey: state.idempotencyKey!,
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            isEditable: true,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            canContinue: false,
          ),
        );
    }
  }

  void requestTerms() {
    emit(state.copyWith(effect: CloseSurplusDepositsEffect.termsUnavailable));
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? CloseSurplusDepositsEffect.confirmExit
            : CloseSurplusDepositsEffect.back,
        isExitToAssistant: false,
      ),
    );
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? CloseSurplusDepositsEffect.confirmExit
            : CloseSurplusDepositsEffect.assistant,
        isExitToAssistant: true,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToAssistant
                  ? CloseSurplusDepositsEffect.assistant
                  : CloseSurplusDepositsEffect.back)
            : null,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: CloseSurplusDepositsEffect.home));
  }

  ListedDeposit? _resolvePrimaryDeposit(List<ListedDeposit> deposits) {
    final number = _normalizeDepositNumber(initialDepositNumber ?? '');
    return _hasSurplusDeposits(deposits)
        ? state.deposit ??
              deposits
                  .where(
                    (deposit) =>
                        _normalizeDepositNumber(deposit.number) == number,
                  )
                  .firstOrNull
        : null;
  }

  bool _hasSurplusDeposits(List<ListedDeposit> deposits) => deposits.length > 1;

  String _normalizeDepositNumber(String number) =>
      DigitNormalizer.normalize(number).replaceAll(RegExp(r'[^0-9]'), '');

  String _createRequestKey() =>
      'close-surplus-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeCloseSurplusDepositsInteraction() {
    emit(state.copyWith(effect: null));
  }
}
