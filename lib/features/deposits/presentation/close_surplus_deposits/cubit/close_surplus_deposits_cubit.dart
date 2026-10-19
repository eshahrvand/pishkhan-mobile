import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/surplus_deposit_closure.dart';
import '../../../domain/repositories/surplus_deposits_repository.dart';
import '../../../domain/usecases/close_surplus_deposits.dart';

part 'close_surplus_deposits_state.dart';
part 'close_surplus_deposits_cubit.freezed.dart';

class CloseSurplusDepositsCubit extends Cubit<CloseSurplusDepositsState> {
  CloseSurplusDepositsCubit({
    this.initialDepositNumber,
    CloseSurplusDepositsState initialState =
        const CloseSurplusDepositsState.initial(),
  }) : super(initialState);

  final String? initialDepositNumber;
  final _repository = getIt<SurplusDepositsRepository>();
  late final _fetchPrimaryDeposits = FetchPrimaryDeposits(_repository);
  late final _closeRemainingDeposits = CloseRemainingDeposits(_repository);

  Future<void> fetchPrimaryDeposits() {
    emit(
      state.copyWith(
        depositsStatus: RequestStatus.loading,
        depositsFailure: null,
        isEditable: false,
      ),
    );
    return _fetchPrimaryDeposits().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              depositsStatus: RequestStatus.failure,
              depositsFailure: failure,
              isEditable: true,
            ),
          );
        case Success(:final data):
          final number = DigitNormalizer.normalize(initialDepositNumber ?? '')
              .replaceAll(RegExp(r'[^0-9]'), '');
          final deposit = data.length > 1
              ? state.deposit ??
                    data
                        .where(
                          (deposit) =>
                              DigitNormalizer.normalize(deposit.number)
                                  .replaceAll(RegExp(r'[^0-9]'), '') ==
                              number,
                        )
                        .firstOrNull
              : null;
          emit(
            state.copyWith(
              depositsStatus: RequestStatus.success,
              deposits: data,
              deposit: deposit,
              isEditable: true,
              step: data.length > 1
                  ? CloseSurplusDepositsStep.primaryDeposit
                  : CloseSurplusDepositsStep.empty,
              canContinue:
                  data.length <= 1 || (deposit != null && state.termsAccepted),
              idempotencyKey:
                  'close-surplus-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
            ),
          );
      }
    });
  }

  void selectPrimaryDeposit(ListedDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        termsAccepted: false,
        canContinue: false,
        hasChanges: true,
        submissionStatus: RequestStatus.initial,
        submissionFailure: null,
        idempotencyKey:
            'close-surplus-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
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

  Future<void> continueFlow() {
    switch (state.step) {
      case CloseSurplusDepositsStep.primaryDeposit:
        return submitClosure();
      case CloseSurplusDepositsStep.empty:
        emit(
          state.copyWith(
            effect: CloseSurplusDepositsEffect.back,
            effectId: state.effectId + 1,
          ),
        );
        return Future.value();
    }
  }

  Future<void> submitClosure() {
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        submissionFailure: null,
        isEditable: false,
      ),
    );
    return _closeRemainingDeposits(
      state.deposit!,
      idempotencyKey: state.idempotencyKey!,
    ).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              submissionFailure: failure,
              isEditable: true,
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
              canContinue: false,
              hasChanges: false,
            ),
          );
      }
    });
  }

  void requestTerms() {
    emit(
      state.copyWith(
        effect: CloseSurplusDepositsEffect.termsUnavailable,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? CloseSurplusDepositsEffect.confirmExit
            : CloseSurplusDepositsEffect.back,
        isExitToAssistant: false,
        effectId: state.effectId + 1,
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
        effectId: state.effectId + 1,
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
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(
      state.copyWith(
        effect: CloseSurplusDepositsEffect.home,
        effectId: state.effectId + 1,
      ),
    );
  }
}
