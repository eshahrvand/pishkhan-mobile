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
  late final _fetchSurplusDeposits = FetchSurplusDeposits(_repository);
  late final _submitClosure = SubmitCloseSurplusDeposits(_repository);

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
            ),
          );
        case Success(:final data):
          final number = DigitNormalizer.normalize(initialDepositNumber ?? '')
              .replaceAll(RegExp(r'[^0-9]'), '');
          final deposit =
              state.deposit ??
              data
                  .where(
                    (deposit) =>
                        DigitNormalizer.normalize(deposit.number)
                            .replaceAll(RegExp(r'[^0-9]'), '') ==
                        number,
                  )
                  .firstOrNull;
          emit(
            state.copyWith(
              depositsStatus: RequestStatus.success,
              deposits: data,
              deposit: deposit,
              isEditable: true,
              canContinue: deposit != null && state.termsAccepted,
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
        review: null,
        reviewStatus: RequestStatus.initial,
        reviewFailure: null,
        submissionStatus: RequestStatus.initial,
        submissionFailure: null,
        idempotencyKey: null,
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
    return switch (state.step) {
      CloseSurplusDepositsStep.primaryDeposit => fetchSurplusDeposits(),
      CloseSurplusDepositsStep.review => submitClosure(),
    };
  }

  Future<void> fetchSurplusDeposits() {
    emit(
      state.copyWith(
        reviewStatus: RequestStatus.loading,
        reviewFailure: null,
        isEditable: false,
      ),
    );
    return _fetchSurplusDeposits(state.deposit!).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              reviewStatus: RequestStatus.failure,
              reviewFailure: failure,
              isEditable: true,
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              reviewStatus: RequestStatus.success,
              review: data,
              step: CloseSurplusDepositsStep.review,
              canContinue: data.deposits.isNotEmpty,
              isEditable: true,
              idempotencyKey:
                  'close-surplus-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
            ),
          );
      }
    });
  }

  Future<void> submitClosure() {
    final request = CloseSurplusDepositsRequest(
      primaryDepositId: state.deposit!.id,
      reviewToken: state.review!.token,
      depositIds: state.review!.deposits.map((deposit) => deposit.id),
      idempotencyKey: state.idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        submissionFailure: null,
        isEditable: false,
      ),
    );
    return _submitClosure(request).then((result) {
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
    if (state.step == CloseSurplusDepositsStep.review) {
      emit(
        state.copyWith(
          step: CloseSurplusDepositsStep.primaryDeposit,
          canContinue: state.deposit != null && state.termsAccepted,
        ),
      );
    } else {
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
