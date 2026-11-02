import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/mobile_bank.dart';
import '../../../domain/repositories/modern_banking_repository.dart';
import '../../../domain/usecases/mobile_bank_usecase.dart';

part 'transfer_limits_state.dart';
part 'transfer_limits_cubit.freezed.dart';

class TransferLimitsCubit extends Cubit<TransferLimitsState> {
  TransferLimitsCubit({
    TransferLimitsState initialState = const TransferLimitsState.initial(),
  }) : super(initialState);
  final repository = getIt<ModernBankingRepository>();
  final fetchMobileBankCatalogUseCase = getIt<FetchMobileBankCatalogUseCase>();
  TransferLimitsRequest? _submittedRequest;

  Future<void> fetchLimits() async {
    emit(state.copyWith(catalogStatus: RequestStatus.loading));
    final result = await fetchMobileBankCatalogUseCase();
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            internalAmount: data.limits.internalRial.toString(),
            payaAmount: data.limits.payaRial.toString(),
            satnaAmount: data.limits.satnaRial.toString(),
            internalToman: data.limits.internalRial ~/ 10,
            payaToman: data.limits.payaRial ~/ 10,
            satnaToman: data.limits.satnaRial ~/ 10,
            isInternalValid: data.limits.internalRial > 0,
            isPayaValid: data.limits.payaRial > 0,
            isSatnaValid: data.limits.satnaRial > 0,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void openEditor() {
    emit(state.copyWith(isEditing: true));
  }

  void updateInternalAmount(String value) {
    final valid = TransferLimitValidator.isValid(
      value,
      state.catalog!.maximumLimits.internalRial,
    );
    emit(
      state.copyWith(
        internalAmount: value,
        isInternalValid: valid,
        isInternalError: !valid,
        internalToman: _amountToman(value),
        canSubmit: _canSubmit(isInternalValid: valid),
      ),
    );
  }

  void updatePayaAmount(String value) {
    final valid = TransferLimitValidator.isValid(
      value,
      state.catalog!.maximumLimits.payaRial,
    );
    emit(
      state.copyWith(
        payaAmount: value,
        isPayaValid: valid,
        isPayaError: !valid,
        payaToman: _amountToman(value),
        canSubmit: _canSubmit(isPayaValid: valid),
      ),
    );
  }

  void updateSatnaAmount(String value) {
    final valid = TransferLimitValidator.isValid(
      value,
      state.catalog!.maximumLimits.satnaRial,
    );
    emit(
      state.copyWith(
        satnaAmount: value,
        isSatnaValid: valid,
        isSatnaError: !valid,
        satnaToman: _amountToman(value),
        canSubmit: _canSubmit(isSatnaValid: valid),
      ),
    );
  }

  void updateTermsAccepted(bool value) {
    emit(
      state.copyWith(
        termsAccepted: value,
        canSubmit: _canSubmit(termsAccepted: value),
      ),
    );
  }

  Future<void> submitLimits() async {
    final limits = TransferLimits(
      internalRial: int.parse(state.internalAmount),
      payaRial: int.parse(state.payaAmount),
      satnaRial: int.parse(state.satnaAmount),
    );
    final request = TransferLimitsRequest(
      depositId: state.catalog!.depositId,
      limits: limits,
      idempotencyKey: _submittedRequest?.limits == limits
          ? _submittedRequest!.idempotencyKey
          : Random.secure().nextInt(1 << 32).toRadixString(16),
    );
    _submittedRequest = request;
    emit(state.copyWith(submissionStatus: RequestStatus.loading));
    final result = await repository.submitTransferLimits(request);
    switch (result) {
      case Success():
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            canSubmit: false,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void requestBack() {
    emit(
      state.copyWith(
        navigation:
            state.isEditing && state.submissionStatus != RequestStatus.success
            ? FlowNavigation.confirmExit
            : FlowNavigation.back,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
      ),
    );
  }

  void requestHome() {
    emit(state.copyWith(navigation: FlowNavigation.home));
  }

  int _amountToman(String value) => (int.tryParse(value) ?? 0) ~/ 10;

  bool _canSubmit({
    bool? isInternalValid,
    bool? isPayaValid,
    bool? isSatnaValid,
    bool? termsAccepted,
  }) {
    return (isInternalValid ?? state.isInternalValid) &&
        (isPayaValid ?? state.isPayaValid) &&
        (isSatnaValid ?? state.isSatnaValid) &&
        (termsAccepted ?? state.termsAccepted);
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeTransferLimitsInteraction() {
    emit(state.copyWith(navigation: null));
  }
}
