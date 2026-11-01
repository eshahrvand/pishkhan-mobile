import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/deposit_restriction.dart';
import '../../../domain/usecases/deposit_restrictions_usecase.dart';

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
  final fetchDepositRestrictionCatalogUseCase =
      getIt<FetchDepositRestrictionCatalogUseCase>();
  final submitDepositRestrictionUseCase =
      getIt<SubmitDepositRestrictionUseCase>();

  Future<void> fetchCatalog() async {
    emit(
      state.copyWith(catalogStatus: RequestStatus.loading, isEditable: false),
    );
    final result = await fetchDepositRestrictionCatalogUseCase(operation);
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        final deposit = _resolveInitialDeposit(data.deposits);
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            deposit: deposit,
            isWalletSufficient: _isWalletSufficient(data),
            isEditable: true,
            canSubmit: _canSubmit(
              deposit,
              state.reason,
              state.termsAccepted,
              _isWalletSufficient(data),
            ),
            idempotencyKey: _createRequestKey(),
          ),
        );
    }
  }

  void selectDeposit(DepositRestrictionOption deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void selectReason(DepositRestrictionReason reason) {
    emit(
      state.copyWith(
        reason: reason,
        canSubmit: _canSubmit(
          state.deposit,
          reason,
          state.termsAccepted,
          state.isWalletSufficient,
        ),
        hasChanges: true,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void updateDescription(String description) {
    emit(
      state.copyWith(
        description: description,
        hasChanges: true,
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
        canSubmit: _canSubmit(
          state.deposit,
          state.reason,
          accepted,
          state.isWalletSufficient,
        ),
        hasChanges: true,
      ),
    );
  }

  Future<void> submitRestriction() async {
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
        isEditable: false,
      ),
    );
    final result = await submitDepositRestrictionUseCase(request);
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
            canSubmit: false,
          ),
        );
    }
  }

  void requestTerms() {
    emit(state.copyWith(effect: DepositRestrictionEffect.termsUnavailable));
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? DepositRestrictionEffect.confirmExit
            : DepositRestrictionEffect.back,
        isExitToAssistant: false,
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
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: DepositRestrictionEffect.home));
  }

  DepositRestrictionOption? _resolveInitialDeposit(
    List<DepositRestrictionOption> deposits,
  ) {
    final number = _normalizeDepositNumber(initialDepositNumber ?? '');
    return deposits
        .where(
          (option) => _normalizeDepositNumber(option.deposit.number) == number,
        )
        .firstOrNull;
  }

  String _normalizeDepositNumber(String number) =>
      DigitNormalizer.normalize(number).replaceAll(RegExp(r'[^0-9]'), '');

  bool _isWalletSufficient(DepositRestrictionCatalog catalog) =>
      catalog.walletBalanceRial >= catalog.feeRial;

  bool _canSubmit(
    DepositRestrictionOption? deposit,
    DepositRestrictionReason? reason,
    bool termsAccepted,
    bool isWalletSufficient,
  ) {
    return deposit != null &&
        reason != null &&
        termsAccepted &&
        isWalletSufficient;
  }

  String _createRequestKey() =>
      'deposit-restriction-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeDepositRestrictionInteraction() {
    emit(state.copyWith(effect: null));
  }
}
