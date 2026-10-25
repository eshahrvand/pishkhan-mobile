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
import '../../../domain/usecases/mobile_bank.dart';

part 'mobile_bank_deactivation_state.dart';
part 'mobile_bank_deactivation_cubit.freezed.dart';

class MobileBankDeactivationCubit extends Cubit<MobileBankDeactivationState> {
  MobileBankDeactivationCubit({
    MobileBankDeactivationState initialState =
        const MobileBankDeactivationState.initial(),
  }) : super(initialState);
  final repository = getIt<ModernBankingRepository>();
  MobileBankDeactivationRequest? _submittedRequest;

  Future<void> fetchMobileBank() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return FetchMobileBankCatalog(repository)().then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(catalogStatus: RequestStatus.success, catalog: data),
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
    });
  }

  void selectReason(DeactivationReason reason) {
    emit(state.copyWith(reason: reason, canSubmit: state.termsAccepted));
  }

  void updateTermsAccepted(bool value) {
    emit(
      state.copyWith(
        termsAccepted: value,
        canSubmit: value && state.reason != null,
      ),
    );
  }

  Future<void> submitDeactivation() {
    final request = MobileBankDeactivationRequest(
      username: state.catalog!.username,
      reason: state.reason!,
      idempotencyKey: _submittedRequest?.reason == state.reason
          ? _submittedRequest!.idempotencyKey
          : Random.secure().nextInt(1 << 32).toRadixString(16),
    );
    _submittedRequest = request;
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return repository.submitDeactivation(request).then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
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
    });
  }

  void requestBack() {
    emit(
      state.copyWith(
        navigation:
            (state.reason != null || state.termsAccepted) &&
                state.submissionStatus != RequestStatus.success
            ? FlowNavigation.confirmExit
            : FlowNavigation.back,
        message: null,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        message: null,
      ),
    );
  }

  void requestHome() {
    emit(state.copyWith(navigation: FlowNavigation.home, message: null));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeMobileBankDeactivationInteraction() {
    emit(state.copyWith(navigation: null));
  }
}
