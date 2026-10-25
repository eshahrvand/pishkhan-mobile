import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/second_password_validator.dart';

import '../../../domain/entities/mobile_bank.dart';
import '../../../domain/repositories/modern_banking_repository.dart';
import '../../../domain/usecases/mobile_bank.dart';

part 'mobile_bank_state.dart';
part 'mobile_bank_cubit.freezed.dart';

class MobileBankCubit extends Cubit<MobileBankState> {
  MobileBankCubit({
    this.operation = MobileBankOperation.activation,
    MobileBankState initialState = const MobileBankState.initial(),
  }) : super(initialState);
  final MobileBankOperation operation;
  final repository = getIt<ModernBankingRepository>();
  MobileBankIdentityRequest? _submittedRequest;

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
          final record = operation == MobileBankOperation.activation
              ? data.activation
              : data.recovery;
          final totalRial =
              data.registryFeeRial +
              data.identityFeeRial +
              data.passwordFeeRial;
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              record: record,
              totalRial: totalRial,
              isWalletSufficient: data.walletBalanceRial >= totalRial,
              step: switch (record.status) {
                MobileBankRequestStatus.pending => MobileBankStep.pending,
                MobileBankRequestStatus.approved =>
                  operation == MobileBankOperation.activation
                      ? MobileBankStep.active
                      : MobileBankStep.recoveryApproved,
                MobileBankRequestStatus.none ||
                MobileBankRequestStatus.rejected =>
                  operation == MobileBankOperation.activation
                      ? MobileBankStep.introduction
                      : MobileBankStep.serial,
              },
              canContinue:
                  record.status != MobileBankRequestStatus.pending &&
                  (operation == MobileBankOperation.activation ||
                      record.status == MobileBankRequestStatus.approved),
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
    });
  }

  void updateNationalCardSerial(String value) {
    final isValid = SecondPasswordValidator.validSerial(value);
    emit(
      state.copyWith(
        nationalCardSerial: value,
        isSerialValid: isValid,
        isSerialError: false,
        canContinue: isValid,
      ),
    );
  }

  void validateSerial() {
    emit(state.copyWith(isSerialError: !state.isSerialValid));
  }

  void toggleInvoice(bool value) {
    emit(state.copyWith(isInvoiceExpanded: value));
  }

  void updateTermsAccepted(bool value) {
    emit(
      state.copyWith(
        termsAccepted: value,
        canContinue: value && state.isWalletSufficient,
      ),
    );
  }

  Future<void> continueFlow() {
    switch (state.step) {
      case MobileBankStep.introduction:
        emit(
          state.copyWith(
            step: MobileBankStep.serial,
            canContinue: state.isSerialValid,
          ),
        );
      case MobileBankStep.serial:
        emit(
          state.copyWith(
            step: MobileBankStep.payment,
            stepNumber: 2,
            progress: .6,
            canContinue: state.termsAccepted && state.isWalletSufficient,
          ),
        );
      case MobileBankStep.payment:
        emit(
          state.copyWith(
            step: MobileBankStep.instruction,
            stepNumber: 3,
            progress: 1,
            canContinue: true,
          ),
        );
      case MobileBankStep.instruction:
        // A preview transition only. The future KYC adapter will supply real evidence.
        emit(state.copyWith(step: MobileBankStep.preview));
      case MobileBankStep.preview:
        return submitIdentity();
      case MobileBankStep.receipt:
      case MobileBankStep.recoveryApproved:
        requestHome();
      case MobileBankStep.pending:
      case MobileBankStep.active:
        break;
    }
    return Future.value();
  }

  void requestRecordingAgain() {
    emit(state.copyWith(step: MobileBankStep.instruction));
  }

  Future<void> submitIdentity() {
    final request = MobileBankIdentityRequest(
      operation: operation,
      nationalCardSerial: state.nationalCardSerial,
      idempotencyKey:
          _submittedRequest?.nationalCardSerial == state.nationalCardSerial
          ? _submittedRequest!.idempotencyKey
          : Random.secure().nextInt(1 << 32).toRadixString(16),
      isPrototypePreview: true,
    );
    _submittedRequest = request;
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return repository.submitIdentity(request).then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              record: data,
              step: MobileBankStep.receipt,
              canContinue: false,
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

  void requestDestination(MobileBankDestination destination) {
    emit(
      state.copyWith(destination: destination, navigation: null, message: null),
    );
  }

  Future<void> refreshAfterService() {
    emit(state.copyWith(destination: null));
    return fetchMobileBank();
  }

  void requestBack() {
    switch (state.step) {
      case MobileBankStep.serial
          when operation == MobileBankOperation.activation:
        emit(
          state.copyWith(step: MobileBankStep.introduction, canContinue: true),
        );
      case MobileBankStep.payment:
        emit(
          state.copyWith(
            step: MobileBankStep.serial,
            stepNumber: 1,
            progress: .3,
            canContinue: state.isSerialValid,
          ),
        );
      case MobileBankStep.instruction:
        emit(
          state.copyWith(
            step: MobileBankStep.payment,
            stepNumber: 2,
            progress: .6,
            canContinue: state.termsAccepted && state.isWalletSufficient,
          ),
        );
      case MobileBankStep.preview:
        emit(state.copyWith(step: MobileBankStep.instruction));
      default:
        emit(
          state.copyWith(
            navigation:
                _requiresExitConfirmation(state.nationalCardSerial, state.step)
                ? FlowNavigation.confirmExit
                : FlowNavigation.back,
            isExitToHome: false,
            destination: null,
            message: null,
          ),
        );
    }
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true
            ? (state.isExitToHome ? FlowNavigation.home : FlowNavigation.back)
            : null,
        message: null,
      ),
    );
  }

  void requestHome() {
    emit(
      state.copyWith(
        navigation:
            _requiresExitConfirmation(state.nationalCardSerial, state.step)
            ? FlowNavigation.confirmExit
            : FlowNavigation.home,
        isExitToHome: true,
        destination: null,
        message: null,
      ),
    );
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeMobileBankInteraction() {
    emit(state.copyWith(navigation: null, destination: null));
  }
}

bool _requiresExitConfirmation(String serial, MobileBankStep step) =>
    serial.isNotEmpty &&
    step != MobileBankStep.receipt &&
    step != MobileBankStep.pending &&
    step != MobileBankStep.active &&
    step != MobileBankStep.recoveryApproved;
