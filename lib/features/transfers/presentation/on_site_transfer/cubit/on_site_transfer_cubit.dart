import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/platform/selected_document.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/iban_validator.dart';
import 'package:pishkhan_mobile/core/validators/jalali_date_parser.dart';

import '../../../domain/entities/on_site_transfer.dart';
import '../../../domain/repositories/on_site_transfer_repository.dart';
import '../../../domain/usecases/on_site_transfer.dart';

export '../../../domain/entities/on_site_transfer.dart';
part 'on_site_transfer_state.dart';
part 'on_site_transfer_cubit.freezed.dart';

class OnSiteTransferCubit extends Cubit<OnSiteTransferState> {
  OnSiteTransferCubit({
    this.initialDepositNumber,
    OnSiteTransferState initialState = const OnSiteTransferState.initial(),
  }) : super(initialState);
  final String? initialDepositNumber;
  final _repository = getIt<OnSiteTransferRepository>();
  late final _upload = UploadTransferDestinations(_repository);
  int _uploadRequestId = 0;
  int _destinationRequestId = 0;
  String? _flowKey;
  int _payloadRevision = 0;

  Future<void> fetchCatalog() {
    // A fresh flow owns one request identity, retained across retries and review.
    _flowKey ??= base64UrlEncode(
      List<int>.generate(18, (_) => Random.secure().nextInt(256)),
    );
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return _repository.fetchCatalog().then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              addresses: data.addresses,
              deposit: data.deposits
                  .where((d) => d.number == initialDepositNumber)
                  .firstOrNull,
              isWalletSufficient: data.walletBalanceRial >= data.feeRial,
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

  void selectDeposit(TransferDeposit deposit) {
    emit(
      state.copyWith(deposit: deposit, canContinue: state.isTransferDateValid),
    );
  }

  void updateTransferDate(String value) {
    final date = JalaliDateParser.parse(value);
    final isValid =
        date != null &&
        TransferScheduleRules.isTransferDateValid(date, state.catalog!);
    emit(
      state.copyWith(
        transferDateInput: value,
        transferDate: isValid ? date : null,
        isTransferDateValid: isValid,
        isTransferDateError: value.isNotEmpty && !isValid,
        visitDate: null,
        isVisitDateValid: false,
        visitDateInput: '',
        isVisitDateError: false,
        canContinue: isValid && state.deposit != null,
      ),
    );
  }

  void selectAddress(DeliveryAddress address) {
    emit(state.copyWith(address: address, canContinue: state.isVisitDateValid));
  }

  void updateVisitDate(String value) {
    final date = JalaliDateParser.parse(value);
    final isValid =
        date != null &&
        TransferScheduleRules.isVisitDateValid(
          date,
          state.transferDate!,
          state.catalog!,
        );
    emit(
      state.copyWith(
        visitDateInput: value,
        visitDate: isValid ? date : null,
        isVisitDateValid: isValid,
        isVisitDateError: value.isNotEmpty && !isValid,
        canContinue: isValid && state.address != null,
      ),
    );
  }

  void requestAddressEditor() {
    emit(
      state.copyWith(effect: OnSiteTransferEffect.addressEditor, message: null),
    );
  }

  void applyAddressResult(DeliveryAddress? address) {
    switch (address) {
      case null:
        break;
      default:
        emit(
          state.copyWith(
            addresses: [...state.addresses, address],
            address: address,
            canContinue: state.isVisitDateValid,
          ),
        );
    }
  }

  void requestAddressDeletion() {
    emit(
      state.copyWith(effect: OnSiteTransferEffect.deleteAddress, message: null),
    );
  }

  void removeAddress() {
    emit(
      state.copyWith(
        addresses: state.addresses
            .where((a) => a.id != state.address!.id)
            .toList(),
        address: null,
        canContinue: false,
      ),
    );
  }

  void requestDestinationEditor() {
    emit(
      state.copyWith(
        amountInput: '',
        amountRial: 0,
        isAmountValid: false,
        isAmountError: false,
        method: null,
        ibanInput: '',
        isIbanValid: false,
        isIbanError: false,
        purpose: null,
        description: '',
        canAddDestination: false,
        destinationStatus: RequestStatus.initial,
        effect: OnSiteTransferEffect.destinationEditor,
        failure: null,
        message: null,
      ),
    );
  }

  void updateAmount(String value) {
    final amount = int.tryParse(value);
    final isValid = amount != null && amount > 0 && amount <= 9007199254740991;
    emit(
      state.copyWith(
        amountInput: value,
        amountRial: isValid ? amount : 0,
        isAmountValid: isValid,
        isAmountError: value.isNotEmpty && !isValid,
        canAddDestination:
            isValid &&
            state.isIbanValid &&
            state.purpose != null &&
            state.method != null,
      ),
    );
  }

  void selectMethod(TransferMethod method) {
    emit(
      state.copyWith(
        method: method,
        canAddDestination:
            state.isAmountValid && state.isIbanValid && state.purpose != null,
      ),
    );
  }

  void updateIban(String value) {
    final isValid = IbanValidator.isValid('IR$value');
    emit(
      state.copyWith(
        ibanInput: value,
        isIbanValid: isValid,
        isIbanError: value.isNotEmpty && !isValid,
        canAddDestination:
            isValid &&
            state.isAmountValid &&
            state.purpose != null &&
            state.method != null,
      ),
    );
  }

  void selectPurpose(TransferPurpose purpose) {
    emit(
      state.copyWith(
        purpose: purpose,
        canAddDestination:
            state.isAmountValid && state.isIbanValid && state.method != null,
      ),
    );
  }

  void updateDescription(String value) {
    emit(state.copyWith(description: value));
  }

  Future<void> submitDestination() {
    final requestId = ++_destinationRequestId;
    emit(
      state.copyWith(
        destinationStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return _repository
        .resolveDestination(
          iban: 'IR${state.ibanInput}',
          amountRial: state.amountRial,
          purpose: state.purpose!,
          description: state.description,
        )
        .then((result) {
          // A dismissed editor may be reopened while the old lookup is in flight.
          if (requestId != _destinationRequestId) return;
          switch (result) {
            case Success(:final data):
              emit(
                state.copyWith(
                  destinationStatus: RequestStatus.success,
                  destinations: [...state.destinations, data],
                  canContinue: true,
                  canAddDestination: false,
                  effect: OnSiteTransferEffect.closeDestination,
                  message: null,
                ),
              );
            case Err(:final failure):
              emit(
                state.copyWith(
                  destinationStatus: RequestStatus.failure,
                  failure: failure,
                  message: getRequestErrorMessage(failure),
                ),
              );
          }
        });
  }

  void cancelDestinationEditor() {
    _destinationRequestId++;
  }

  void removeDestination(TransferDestination destination) {
    final destinations = state.destinations
        .where((d) => d.id != destination.id)
        .toList();
    emit(
      state.copyWith(
        destinations: destinations,
        canContinue: destinations.isNotEmpty || state.attachment != null,
      ),
    );
  }

  void removeAttachment() {
    emit(
      state.copyWith(
        attachment: null,
        canContinue: state.destinations.isNotEmpty,
      ),
    );
  }

  void requestUploadSheet() {
    emit(
      state.copyWith(
        pendingAttachment: state.attachment,
        uploadName: state.attachment?.name ?? '',
        uploadSizeBytes: state.attachment?.sizeBytes ?? 0,
        uploadStatus: state.attachment == null
            ? RequestStatus.initial
            : RequestStatus.success,
        uploadProgress: state.attachment == null ? 0 : 1,
        canReviewFile: state.attachment != null,
        effect: OnSiteTransferEffect.uploadSheet,
        failure: null,
        message: null,
      ),
    );
  }

  void requestFilePicker() {
    emit(
      state.copyWith(
        uploadStatus: RequestStatus.initial,
        filePickerRequestId: ++_uploadRequestId,
        effect: OnSiteTransferEffect.pickFile,
        failure: null,
        message: null,
      ),
    );
  }

  Future<void> applyFileSelection(
    SelectedDocument? file, {
    required int requestId,
  }) {
    // The system picker can finish after its upload sheet was dismissed/reopened.
    if (requestId != _uploadRequestId) return Future.value();
    switch (file) {
      case null when state.pendingAttachment != null:
        emit(state.copyWith(uploadStatus: RequestStatus.success));
        return Future.value();
      case null:
        return Future.value();
      default:
        emit(
          state.copyWith(
            uploadStatus: RequestStatus.loading,
            uploadName: file.name,
            uploadSizeBytes: file.bytes.length,
            uploadProgress: 0,
            pendingAttachment: null,
            canReviewFile: false,
            failure: null,
            message: null,
          ),
        );
        return _upload(file, (progress) {
          if (requestId != _uploadRequestId) return;
          emit(state.copyWith(uploadProgress: progress));
        }).then((result) {
          // Cancelling/replacing a file can overlap its previous upload.
          if (requestId != _uploadRequestId) return;
          switch (result) {
            case Success(:final data):
              emit(
                state.copyWith(
                  uploadStatus: RequestStatus.success,
                  uploadProgress: 1,
                  pendingAttachment: data,
                  canReviewFile: true,
                ),
              );
            case Err(:final failure):
              emit(
                state.copyWith(
                  uploadStatus: RequestStatus.failure,
                  failure: failure,
                  message: getRequestErrorMessage(failure),
                ),
              );
          }
        });
    }
  }

  void applyFilePickerFailure(int requestId) {
    if (requestId != _uploadRequestId) return;
    emit(
      state.copyWith(
        uploadStatus: RequestStatus.failure,
        failure: const DataFailure('transfer.file.invalid'),
        message: getRequestErrorMessage(
          const DataFailure('transfer.file.invalid'),
        ),
      ),
    );
  }

  void removeUpload() {
    _uploadRequestId++;
    emit(
      state.copyWith(
        uploadStatus: RequestStatus.initial,
        uploadName: '',
        uploadSizeBytes: 0,
        uploadProgress: 0,
        pendingAttachment: null,
        canReviewFile: false,
        failure: null,
        message: null,
      ),
    );
  }

  void applyUploadSheetResult(bool? confirmed) {
    _uploadRequestId++;
    if (confirmed == true) {
      final attachment = state.pendingAttachment!;
      final request = _createRequest(
        attachment: attachment,
        idempotencyKey: state.confirmedRequest?.idempotencyKey ?? _flowKey!,
      );
      final confirmedRequest =
          state.confirmedRequest != null && request != state.confirmedRequest
          ? _createRequest(
              attachment: attachment,
              idempotencyKey: '$_flowKey-${++_payloadRevision}',
            )
          : request;
      emit(
        state.copyWith(
          attachment: attachment,
          step: OnSiteTransferStep.confirmation,
          stepNumber: 4,
          confirmedRequest: confirmedRequest,
          termsAccepted: false,
          canContinue: false,
          effect: OnSiteTransferEffect.reveal,
          message: null,
        ),
      );
    }
  }

  void requestUnavailable() {
    emit(
      state.copyWith(effect: OnSiteTransferEffect.unavailable, message: null),
    );
  }

  Future<void> continueFlow() {
    switch (state.step) {
      case OnSiteTransferStep.source:
        emit(
          state.copyWith(
            step: OnSiteTransferStep.visit,
            stepNumber: 2,
            canContinue: state.address != null && state.isVisitDateValid,
            effect: OnSiteTransferEffect.reveal,
            message: null,
          ),
        );
      case OnSiteTransferStep.visit:
        emit(
          state.copyWith(
            step: OnSiteTransferStep.destinations,
            stepNumber: 3,
            canContinue:
                state.destinations.isNotEmpty || state.attachment != null,
            effect: OnSiteTransferEffect.reveal,
            message: null,
          ),
        );
      case OnSiteTransferStep.destinations:
        final request = _createRequest(
          attachment: state.attachment,
          idempotencyKey: state.confirmedRequest?.idempotencyKey ?? _flowKey!,
        );
        final confirmedRequest =
            state.confirmedRequest != null && request != state.confirmedRequest
            ? _createRequest(
                attachment: state.attachment,
                idempotencyKey: '$_flowKey-${++_payloadRevision}',
              )
            : request;
        emit(
          state.copyWith(
            step: OnSiteTransferStep.confirmation,
            stepNumber: 4,
            confirmedRequest: confirmedRequest,
            termsAccepted: false,
            canContinue: false,
            effect: OnSiteTransferEffect.reveal,
            message: null,
          ),
        );
      case OnSiteTransferStep.confirmation:
        return submitTransfer();
    }
    return Future.value();
  }

  OnSiteTransferRequest _createRequest({
    required TransferAttachment? attachment,
    required String idempotencyKey,
  }) {
    return OnSiteTransferRequest(
      depositId: state.deposit!.id,
      transferDate: state.transferDate!,
      visitDate: state.visitDate!,
      address: state.address!,
      destinations: state.destinations,
      attachment: attachment,
      feeRial: state.catalog!.feeRial,
      idempotencyKey: idempotencyKey,
    );
  }

  void updateTerms(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canContinue: accepted && state.isWalletSufficient,
      ),
    );
  }

  void updateSummaryExpanded(bool expanded) {
    emit(state.copyWith(isSummaryExpanded: expanded));
  }

  void updateInvoiceExpanded(bool expanded) {
    emit(state.copyWith(isInvoiceExpanded: expanded));
  }

  Future<void> submitTransfer() {
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return _repository.submit(state.confirmedRequest!).then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
              canContinue: false,
              effect: OnSiteTransferEffect.receipt,
              message: null,
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
    switch (state.step) {
      case OnSiteTransferStep.source:
        emit(
          state.copyWith(
            effect: OnSiteTransferEffect.confirmExit,
            message: null,
          ),
        );
      case OnSiteTransferStep.visit:
        emit(
          state.copyWith(
            step: OnSiteTransferStep.source,
            stepNumber: 1,
            canContinue: state.deposit != null && state.isTransferDateValid,
            effect: OnSiteTransferEffect.reveal,
            message: null,
          ),
        );
      case OnSiteTransferStep.destinations:
        emit(
          state.copyWith(
            step: OnSiteTransferStep.visit,
            stepNumber: 2,
            canContinue: state.address != null && state.isVisitDateValid,
            effect: OnSiteTransferEffect.reveal,
            message: null,
          ),
        );
      case OnSiteTransferStep.confirmation:
        emit(
          state.copyWith(
            step: OnSiteTransferStep.destinations,
            stepNumber: 3,
            canContinue:
                state.destinations.isNotEmpty || state.attachment != null,
            effect: OnSiteTransferEffect.reveal,
            message: null,
          ),
        );
    }
  }

  void applyExitConfirmation(bool? confirmed) {
    if (confirmed == true) {
      emit(state.copyWith(effect: OnSiteTransferEffect.back, message: null));
    }
  }

  void requestAssistant() {
    emit(state.copyWith(effect: OnSiteTransferEffect.assistant, message: null));
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: OnSiteTransferEffect.home, message: null));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeOnSiteTransferInteraction() {
    emit(state.copyWith(effect: null));
  }
}
