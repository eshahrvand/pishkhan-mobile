import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/validators.dart';

import '../../../domain/entities/cheque_book.dart';
import '../../../domain/repositories/cheque_book_repository.dart';
import '../../../domain/usecases/cheque_book.dart';

part 'cheque_book_state.dart';
part 'cheque_book_cubit.freezed.dart';

class ChequeBookCubit extends Cubit<ChequeBookState> {
  ChequeBookCubit({
    this.initialDepositNumber,
    ChequeBookState initialState = const ChequeBookState.initial(),
  }) : super(initialState);
  final String? initialDepositNumber;
  final _repository = getIt<ChequeBookRepository>();
  late final _fetchCatalog = FetchChequeBookCatalog(_repository);
  late final _checkResidency = CheckChequeBookResidency(_repository);
  late final _deleteResidence = DeleteChequeBookResidence(_repository);
  late final _saveDeliveryAddress = SaveChequeBookDeliveryAddress(_repository);
  late final _fetchQuote = FetchChequeBookQuote(_repository);
  late final _submitIssuance = SubmitChequeBook(_repository);
  int _residencyRequestId = 0;
  int _quoteRequestId = 0;

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return _fetchCatalog().then((result) {
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
          final number = DigitNormalizer.normalize(initialDepositNumber ?? '');
          final deposit = data.deposits
              .where((deposit) => deposit.number == number)
              .firstOrNull;
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              deposit: deposit,
              leafCounts: deposit?.leafCounts ?? [],
              isEditable: true,
              isRecipientRequired: data.applicant == ChequeBookApplicant.legal,
            ),
          );
      }
    });
  }

  void selectDeposit(ChequeBookDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        submissionStatus: RequestStatus.initial,
        quoteStatus: RequestStatus.initial,
        leafCount: null,
        leafCounts: deposit.leafCounts,
        canContinue: false,
        hasChanges: true,
        residency: null,
        quote: null,
        confirmedDraft: null,
        idempotencyKey: null,
        failure: null,
        message: null,
      ),
    );
  }

  void selectLeafCount(int count) {
    emit(
      state.copyWith(
        leafCount: count,
        canContinue: state.deposit != null,
        hasChanges: true,
        quote: null,
        confirmedDraft: null,
        idempotencyKey: null,
      ),
    );
  }

  Future<void> continueFlow() {
    switch (state.step) {
      case ChequeBookStep.selection:
      case ChequeBookStep.checking:
        return fetchResidency();
      case ChequeBookStep.residency:
        if (state.hasRegisteredResidence) {
          emit(
            state.copyWith(
              step: ChequeBookStep.delivery,
              stepNumber: 3,
              primaryAction: ChequeBookAction.next,
              canContinue: _isDeliveryComplete(
                state.address,
                state.isRecipientRequired,
                state.isRecipientNameValid,
                state.isRecipientNationalIdValid,
              ),
            ),
          );
        } else {
          emit(state.copyWith(effect: ChequeBookEffect.home, message: null));
        }
        return Future.value();
      case ChequeBookStep.delivery:
        return fetchQuote();
      case ChequeBookStep.confirmation:
        return submitIssuance();
    }
  }

  Future<void> fetchResidency() {
    final requestId = ++_residencyRequestId;
    emit(
      state.copyWith(
        step: ChequeBookStep.checking,
        stepNumber: 2,
        residencyStatus: RequestStatus.loading,
        canContinue: false,
        isEditable: false,
        failure: null,
        message: null,
      ),
    );
    return _checkResidency(state.deposit!.id).then((result) {
      // Returning to selection can start a new check for a different deposit.
      if (requestId != _residencyRequestId) return;
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              residencyStatus: RequestStatus.failure,
              isEditable: true,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          final registered = data.residences
              .where((residence) => residence.isRegistered)
              .map((residence) => residence.address)
              .toList();
          final requiresReview =
              registered.length != data.residences.length || registered.isEmpty;
          final address = state.catalog!.applicant == ChequeBookApplicant.legal
              ? registered.firstOrNull
              : null;
          emit(
            state.copyWith(
              residencyStatus: RequestStatus.success,
              residency: data,
              hasRegisteredResidence: registered.isNotEmpty,
              deliveryAddresses: registered,
              address: address,
              step: requiresReview
                  ? ChequeBookStep.residency
                  : ChequeBookStep.delivery,
              stepNumber: requiresReview ? 2 : 3,
              primaryAction:
                  requiresReview &&
                      (registered.isNotEmpty || data.residences.length <= 1)
                  ? ChequeBookAction.understood
                  : ChequeBookAction.next,
              isAddressDeletionAvailable: data.residences.length > 1,
              isEditable: true,
              canContinue: requiresReview
                  ? (registered.isNotEmpty || data.residences.length <= 1)
                  : _isDeliveryComplete(
                      address,
                      state.isRecipientRequired,
                      state.isRecipientNameValid,
                      state.isRecipientNationalIdValid,
                    ),
            ),
          );
      }
    });
  }

  void requestDeleteAddress(DeliveryAddress address) {
    emit(
      state.copyWith(
        pendingAddress: address,
        effect: ChequeBookEffect.deleteAddress,
        message: null,
      ),
    );
  }

  Future<void> deleteAddress(DeliveryAddress address) {
    if (state.step == ChequeBookStep.delivery) {
      emit(
        state.copyWith(
          address: null,
          deliveryAddresses: state.deliveryAddresses
              .where((candidate) => candidate.id != address.id)
              .toList(),
          canContinue: false,
          hasChanges: true,
        ),
      );
      return Future.value();
    }
    emit(
      state.copyWith(
        addressDeletionStatus: RequestStatus.loading,
        isEditable: false,
        failure: null,
        message: null,
      ),
    );
    return _deleteResidence(state.deposit!.id, address).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              addressDeletionStatus: RequestStatus.failure,
              isEditable: true,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          final registered = data.residences
              .where((residence) => residence.isRegistered)
              .map((residence) => residence.address)
              .toList();
          final requiresReview =
              registered.length != data.residences.length || registered.isEmpty;
          final selectedAddress =
              state.catalog!.applicant == ChequeBookApplicant.legal
              ? registered.firstOrNull
              : null;
          emit(
            state.copyWith(
              addressDeletionStatus: RequestStatus.success,
              residency: data,
              hasRegisteredResidence: registered.isNotEmpty,
              deliveryAddresses: registered,
              address: selectedAddress,
              pendingAddress: null,
              hasChanges: true,
              step: requiresReview
                  ? ChequeBookStep.residency
                  : ChequeBookStep.delivery,
              stepNumber: requiresReview ? 2 : 3,
              primaryAction:
                  requiresReview &&
                      (registered.isNotEmpty || data.residences.length <= 1)
                  ? ChequeBookAction.understood
                  : ChequeBookAction.next,
              isAddressDeletionAvailable: data.residences.length > 1,
              isEditable: true,
              canContinue: requiresReview
                  ? (registered.isNotEmpty || data.residences.length <= 1)
                  : _isDeliveryComplete(
                      selectedAddress,
                      state.isRecipientRequired,
                      state.isRecipientNameValid,
                      state.isRecipientNationalIdValid,
                    ),
            ),
          );
      }
    });
  }

  void selectAddress(DeliveryAddress address) {
    emit(
      state.copyWith(
        address: address,
        hasChanges: true,
        canContinue: _isDeliveryComplete(
          address,
          state.isRecipientRequired,
          state.isRecipientNameValid,
          state.isRecipientNationalIdValid,
        ),
      ),
    );
  }

  void requestAddAddress() {
    emit(state.copyWith(effect: ChequeBookEffect.addAddress, message: null));
  }

  Future<void> applyAddressResult(DeliveryAddress? address) {
    switch (address) {
      case null:
        return Future.value();
      case final address:
        emit(
          state.copyWith(
            addressSaveStatus: RequestStatus.loading,
            isEditable: false,
            failure: null,
            message: null,
          ),
        );
        return _saveDeliveryAddress(address).then((result) {
          switch (result) {
            case Err(:final failure):
              if (state.step == ChequeBookStep.delivery) {
                emit(
                  state.copyWith(
                    addressSaveStatus: RequestStatus.failure,
                    isEditable: true,
                    failure: failure,
                    message: getRequestErrorMessage(failure),
                  ),
                );
              } else {
                emit(
                  state.copyWith(
                    addressSaveStatus: RequestStatus.failure,
                    failure: failure,
                    message: getRequestErrorMessage(failure),
                  ),
                );
              }
            case Success(:final data):
              if (state.step == ChequeBookStep.delivery) {
                emit(
                  state.copyWith(
                    addressSaveStatus: RequestStatus.success,
                    deliveryAddresses: [...state.deliveryAddresses, data],
                    address: data,
                    isEditable: true,
                    hasChanges: true,
                    canContinue: _isDeliveryComplete(
                      data,
                      state.isRecipientRequired,
                      state.isRecipientNameValid,
                      state.isRecipientNationalIdValid,
                    ),
                  ),
                );
              } else {
                emit(
                  state.copyWith(
                    addressSaveStatus: RequestStatus.success,
                    deliveryAddresses: [...state.deliveryAddresses, data],
                  ),
                );
              }
          }
        });
    }
  }

  void updateOtherRecipient(bool value) {
    final required =
        state.catalog!.applicant == ChequeBookApplicant.legal || value;
    emit(
      state.copyWith(
        isOtherRecipient: value,
        isRecipientRequired: required,
        hasChanges: true,
        canContinue: _isDeliveryComplete(
          state.address,
          required,
          state.isRecipientNameValid,
          state.isRecipientNationalIdValid,
        ),
      ),
    );
  }

  void updateRecipientName(String value) {
    final valid = value.trim().isNotEmpty;
    emit(
      state.copyWith(
        recipientName: value,
        isRecipientNameValid: valid,
        isRecipientNameError: value.isNotEmpty && !valid,
        hasChanges: true,
        canContinue: _isDeliveryComplete(
          state.address,
          state.isRecipientRequired,
          valid,
          state.isRecipientNationalIdValid,
        ),
      ),
    );
  }

  void updateRecipientNationalId(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final valid = NationalCodeValidator.isValid(normalized);
    emit(
      state.copyWith(
        recipientNationalId: normalized,
        isRecipientNationalIdValid: valid,
        isRecipientNationalIdError: normalized.isNotEmpty && !valid,
        hasChanges: true,
        canContinue: _isDeliveryComplete(
          state.address,
          state.isRecipientRequired,
          state.isRecipientNameValid,
          valid,
        ),
      ),
    );
  }

  void updateAgentInclusion(bool value) {
    emit(state.copyWith(isAgentIncluded: value, hasChanges: true));
  }

  void updateAgentIdentifier(String value) {
    emit(
      state.copyWith(
        agentIdentifier: DigitNormalizer.normalize(value),
        hasChanges: true,
      ),
    );
  }

  Future<void> fetchQuote() {
    final requestId = ++_quoteRequestId;
    final draft = ChequeBookDraft(
      depositId: state.deposit!.id,
      leafCount: state.leafCount!,
      residencyToken: state.residency!.token,
      address: state.address!,
      recipientName: state.isRecipientRequired
          ? state.recipientName.trim()
          : null,
      recipientNationalId: state.isRecipientRequired
          ? state.recipientNationalId
          : null,
      agentIdentifier: state.isAgentIncluded && state.agentIdentifier.isNotEmpty
          ? state.agentIdentifier
          : null,
    );
    emit(
      state.copyWith(
        quoteStatus: RequestStatus.loading,
        isEditable: false,
        failure: null,
        message: null,
      ),
    );
    return _fetchQuote(draft).then((result) {
      // Back allows editing and starting a newer quote while this one is pending.
      if (requestId != _quoteRequestId) return;
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              quoteStatus: RequestStatus.failure,
              isEditable: true,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          final total = data.issueFeeRial + data.deliveryFeeRial;
          final sufficient = data.walletBalanceRial >= total;
          emit(
            state.copyWith(
              quoteStatus: RequestStatus.success,
              quote: data,
              confirmedDraft: draft,
              totalRial: total,
              isWalletSufficient: sufficient,
              step: ChequeBookStep.confirmation,
              stepNumber: 4,
              primaryAction: ChequeBookAction.submit,
              isEditable: true,
              canContinue: sufficient,
              idempotencyKey:
                  'chequebook-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
            ),
          );
      }
    });
  }

  Future<void> submitIssuance() {
    final request = ChequeBookRequest(
      draft: state.confirmedDraft!,
      quoteToken: state.quote!.token,
      idempotencyKey: state.idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
        failure: null,
        message: null,
      ),
    );
    return _submitIssuance(request).then((result) {
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
              hasChanges: false,
              canContinue: false,
              effect: ChequeBookEffect.receipt,
              message: null,
            ),
          );
      }
    });
  }

  void updateSummaryExpansion(bool value) =>
      emit(state.copyWith(isSummaryExpanded: value));
  void updateInvoiceExpansion(bool value) =>
      emit(state.copyWith(isInvoiceExpanded: value));

  void requestRegistry() {
    emit(state.copyWith(effect: ChequeBookEffect.registry, message: null));
  }

  void requestUnavailableContent() {
    emit(
      state.copyWith(
        effect: ChequeBookEffect.contentUnavailable,
        message: null,
      ),
    );
  }

  void requestBack() {
    switch (state.step) {
      case ChequeBookStep.selection:
        emit(
          state.copyWith(
            effect: state.hasChanges
                ? ChequeBookEffect.confirmExit
                : ChequeBookEffect.back,
            isExitToAssistant: false,
            message: null,
          ),
        );
      case ChequeBookStep.checking:
      case ChequeBookStep.residency:
        ++_residencyRequestId;
        emit(
          state.copyWith(
            step: ChequeBookStep.selection,
            stepNumber: 1,
            primaryAction: ChequeBookAction.next,
            isEditable: true,
            canContinue: state.deposit != null && state.leafCount != null,
          ),
        );
      case ChequeBookStep.delivery:
        ++_quoteRequestId;
        emit(
          state.copyWith(
            quoteStatus: RequestStatus.initial,
            step: ChequeBookStep.selection,
            stepNumber: 1,
            primaryAction: ChequeBookAction.next,
            isEditable: true,
            canContinue: state.deposit != null && state.leafCount != null,
            failure: null,
            message: null,
          ),
        );
      case ChequeBookStep.confirmation:
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.initial,
            step: ChequeBookStep.delivery,
            stepNumber: 3,
            primaryAction: ChequeBookAction.next,
            isEditable: true,
            canContinue: _isDeliveryComplete(
              state.address,
              state.isRecipientRequired,
              state.isRecipientNameValid,
              state.isRecipientNationalIdValid,
            ),
            failure: null,
            message: null,
          ),
        );
    }
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? ChequeBookEffect.confirmExit
            : ChequeBookEffect.assistant,
        isExitToAssistant: true,
        message: null,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToAssistant
                  ? ChequeBookEffect.assistant
                  : ChequeBookEffect.back)
            : null,
        message: null,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: ChequeBookEffect.home, message: null));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeChequeBookInteraction() {
    emit(state.copyWith(effect: null));
  }
}

bool _isDeliveryComplete(
  DeliveryAddress? address,
  bool recipientRequired,
  bool nameValid,
  bool nationalIdValid,
) => address != null && (!recipientRequired || (nameValid && nationalIdValid));
