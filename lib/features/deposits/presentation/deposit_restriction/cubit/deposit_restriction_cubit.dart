import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/deposit_restriction.dart';
import '../../../domain/repositories/deposit_restrictions_repository.dart';
import '../../../domain/usecases/deposit_restrictions.dart';

part 'deposit_restriction_state.dart';
part 'deposit_restriction_cubit.freezed.dart';

class DepositRestrictionCubit extends Cubit<DepositRestrictionState> {
  DepositRestrictionCubit({
    required this.operation,
    this.initialDepositNumber,
    DepositRestrictionState initialState =
        const DepositRestrictionState.initial(),
  }) : super(initialState);
  final DepositRestrictionOperation operation;
  final String? initialDepositNumber;
  final _repository = getIt<DepositRestrictionsRepository>();
  late final _fetchCatalog = FetchDepositRestrictionCatalog(_repository);
  late final _submitRestriction = SubmitDepositRestriction(_repository);

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        catalogFailure: null,
        isEditable: false,
      ),
    );
    return _fetchCatalog(operation).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.failure,
              catalogFailure: failure,
            ),
          );
        case Success(:final data):
          final number = DigitNormalizer.normalize(initialDepositNumber ?? '')
              .replaceAll(RegExp(r'[^0-9]'), '');
          final deposit = data.deposits
              .where(
                (option) =>
                    DigitNormalizer.normalize(option.deposit.number)
                        .replaceAll(RegExp(r'[^0-9]'), '') ==
                    number,
              )
              .firstOrNull;
          final sufficient = data.walletBalanceRial >= data.feeRial;
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              deposit: deposit,
              isWalletSufficient: sufficient,
              isEditable: true,
              canSubmit:
                  deposit != null &&
                  state.reason != null &&
                  state.termsAccepted &&
                  sufficient,
              idempotencyKey: _createRequestKey(),
            ),
          );
      }
    });
  }

  void selectDeposit(DepositRestrictionOption deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        submissionFailure: null,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void selectReason(DepositRestrictionReason reason) {
    emit(
      state.copyWith(
        reason: reason,
        canSubmit:
            state.deposit != null &&
            state.termsAccepted &&
            state.isWalletSufficient,
        hasChanges: true,
        submissionFailure: null,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void updateDescription(String description) {
    emit(
      state.copyWith(
        description: description,
        hasChanges: true,
        submissionFailure: null,
        idempotencyKey: description.trim() == state.description.trim()
            ? state.idempotencyKey
            : _createRequestKey(),
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit:
            accepted &&
            state.deposit != null &&
            state.reason != null &&
            state.isWalletSufficient,
        hasChanges: true,
      ),
    );
  }

  Future<void> submitRestriction() {
    final request = DepositRestrictionRequest(
      operation: operation,
      depositId: state.deposit!.deposit.id,
      reason: state.reason!,
      description: state.description.trim(),
      quoteToken: state.catalog!.quoteToken,
      idempotencyKey: state.idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        submissionFailure: null,
        isEditable: false,
      ),
    );
    return _submitRestriction(request).then((result) {
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
              canSubmit: false,
              hasChanges: false,
            ),
          );
      }
    });
  }

  void requestTerms() {
    emit(
      state.copyWith(
        effect: DepositRestrictionEffect.termsUnavailable,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? DepositRestrictionEffect.confirmExit
            : DepositRestrictionEffect.back,
        isExitToAssistant: false,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? DepositRestrictionEffect.confirmExit
            : DepositRestrictionEffect.assistant,
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
                  ? DepositRestrictionEffect.assistant
                  : DepositRestrictionEffect.back)
            : null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(
      state.copyWith(
        effect: DepositRestrictionEffect.home,
        effectId: state.effectId + 1,
      ),
    );
  }

  String _createRequestKey() =>
      'deposit-restriction-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
}
