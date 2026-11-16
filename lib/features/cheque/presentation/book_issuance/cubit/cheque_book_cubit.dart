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
import '../../../domain/usecases/cheque_book_usecase.dart';

part 'cheque_book_state.dart';
part 'cheque_book_cubit.freezed.dart';

class ChequeBookCubit extends Cubit<ChequeBookState> {
  ChequeBookCubit({
    this.initialDepositNumber,
    ChequeBookState initialState = const ChequeBookState.initial(),
  }) : super(initialState);
  final fetchChequeBookCatalogUseCase = getIt<FetchChequeBookCatalogUseCase>();
  final checkChequeBookResidencyUseCase =
      getIt<CheckChequeBookResidencyUseCase>();
  final deleteChequeBookResidenceUseCase =
      getIt<DeleteChequeBookResidenceUseCase>();
  final saveChequeBookDeliveryAddressUseCase =
      getIt<SaveChequeBookDeliveryAddressUseCase>();
  final fetchChequeBookQuoteUseCase = getIt<FetchChequeBookQuoteUseCase>();
  final submitChequeBookUseCase = getIt<SubmitChequeBookUseCase>();

  final String? initialDepositNumber;
  int _residencyRequestId = 0;
  int _quoteRequestId = 0;

  Future<void> fetchCatalog() async {
    emit(state.copyWith(catalogStatus: RequestStatus.loading));
    final result = await fetchChequeBookCatalogUseCase();
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
      ),
    );
  }

  void selectLeafCount(int count) {
    emit(
      state.copyWith(
        leafCount: count,
        canContinue: _canContinueSelection(count),
        hasChanges: true,
        quote: null,
        confirmedDraft: null,
        idempotencyKey: null,
      ),
    );
  }

  Future<void> continueFlow() async {
    switch (state.step) {
      case ChequeBookStep.selection:
      case ChequeBookStep.checking:
        await fetchResidency();
      case ChequeBookStep.residency:
        if (state.hasRegisteredResidence) {
          emit(
            state.copyWith(
              step: ChequeBookStep.delivery,
              stepNumber: 3,
              primaryAction: ChequeBookAction.next,
              canContinue: _canContinueDelivery(state.address),
            ),
          );
        } else {
          emit(state.copyWith(effect: ChequeBookEffect.home));
        }
        return;
      case ChequeBookStep.delivery:
        await fetchQuote();
      case ChequeBookStep.confirmation:
        await submitIssuance();
    }
  }

  Future<void> fetchResidency() async {
    final requestId = ++_residencyRequestId;
    emit(
      state.copyWith(
        step: ChequeBookStep.checking,
        stepNumber: 2,
        residencyStatus: RequestStatus.loading,
        canContinue: false,
        isEditable: false,
      ),
    );
    final result = await checkChequeBookResidencyUseCase(state.deposit!.id);
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
        final registered = _registeredAddresses(data);
        final address = _initialDeliveryAddress(registered);
        emit(
          state.copyWith(
            residencyStatus: RequestStatus.success,
            residency: data,
            hasRegisteredResidence: _hasRegisteredResidence(registered),
            deliveryAddresses: registered,
            address: address,
            step: _requiresResidencyReview(data, registered)
                ? ChequeBookStep.residency
                : ChequeBookStep.delivery,
            stepNumber: _requiresResidencyReview(data, registered) ? 2 : 3,
            primaryAction: _residencyPrimaryAction(data, registered),
            isAddressDeletionAvailable: _canDeleteResidence(data),
            isEditable: true,
            canContinue: _canContinueAfterResidency(data, registered, address),
          ),
        );
    }
  }

  void requestDeleteAddress(DeliveryAddress address) {
    emit(
      state.copyWith(
        pendingAddress: address,
        effect: ChequeBookEffect.deleteAddress,
      ),
    );
  }

  Future<void> deleteAddress(DeliveryAddress address) async {
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
      return;
    }
    emit(
      state.copyWith(
        addressDeletionStatus: RequestStatus.loading,
        isEditable: false,
      ),
    );
    final result = await deleteChequeBookResidenceUseCase(
      state.deposit!.id,
      address,
    );
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
        final registered = _registeredAddresses(data);
        final selectedAddress = _initialDeliveryAddress(registered);
        emit(
          state.copyWith(
            addressDeletionStatus: RequestStatus.success,
            residency: data,
            hasRegisteredResidence: _hasRegisteredResidence(registered),
            deliveryAddresses: registered,
            address: selectedAddress,
            pendingAddress: null,
            hasChanges: true,
            step: _requiresResidencyReview(data, registered)
                ? ChequeBookStep.residency
                : ChequeBookStep.delivery,
            stepNumber: _requiresResidencyReview(data, registered) ? 2 : 3,
            primaryAction: _residencyPrimaryAction(data, registered),
            isAddressDeletionAvailable: _canDeleteResidence(data),
            isEditable: true,
            canContinue: _canContinueAfterResidency(
              data,
              registered,
              selectedAddress,
            ),
          ),
        );
    }
  }

  void selectAddress(DeliveryAddress address) {
    emit(
      state.copyWith(
        address: address,
        hasChanges: true,
        canContinue: _canContinueDelivery(address),
      ),
    );
  }

  void requestAddAddress() {
    emit(state.copyWith(effect: ChequeBookEffect.addAddress));
  }

  Future<void> applyAddressResult(DeliveryAddress? address) async {
    switch (address) {
      case null:
        return;
      case final address:
        emit(
          state.copyWith(
            addressSaveStatus: RequestStatus.loading,
            isEditable: false,
          ),
        );
        final result = await saveChequeBookDeliveryAddressUseCase(address);
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
                  canContinue: _canContinueDelivery(data),
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
        canContinue: _canContinueDelivery(
          state.address,
          recipientRequired: required,
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
        canContinue: _canContinueDelivery(state.address, nameValid: valid),
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
        canContinue: _canContinueDelivery(
          state.address,
          nationalIdValid: valid,
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

  Future<void> fetchQuote() async {
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
    emit(state.copyWith(quoteStatus: RequestStatus.loading, isEditable: false));
    final result = await fetchChequeBookQuoteUseCase(draft);
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
  }

  Future<void> submitIssuance() async {
    final request = ChequeBookRequest(
      draft: state.confirmedDraft!,
      quoteToken: state.quote!.token,
      idempotencyKey: state.idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
      ),
    );
    final result = await submitChequeBookUseCase(request);
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
          ),
        );
    }
  }

  void updateSummaryExpansion(bool value) =>
      emit(state.copyWith(isSummaryExpanded: value));
  void updateInvoiceExpansion(bool value) =>
      emit(state.copyWith(isInvoiceExpanded: value));

  void applyRegistryResult(Result<void> result) {
    switch (result) {
      case Success():
        emit(state.copyWith(registryStatus: RequestStatus.success));
      case Err(:final failure):
        emit(
          state.copyWith(
            registryStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void requestRegistry() {
    emit(
      state.copyWith(
        registryStatus: RequestStatus.loading,
        effect: ChequeBookEffect.registry,
      ),
    );
  }

  void requestUnavailableContent() {
    emit(state.copyWith(effect: ChequeBookEffect.contentUnavailable));
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
            canContinue: _canContinueSelection(state.leafCount),
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
            canContinue: _canContinueSelection(state.leafCount),
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
            canContinue: _canContinueDelivery(state.address),
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
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: ChequeBookEffect.home));
  }

  List<DeliveryAddress> _registeredAddresses(ChequeBookResidency residency) =>
      residency.residences
          .where((residence) => residence.isRegistered)
          .map((residence) => residence.address)
          .toList();

  bool _requiresResidencyReview(
    ChequeBookResidency residency,
    List<DeliveryAddress> registered,
  ) => registered.length != residency.residences.length || registered.isEmpty;

  bool _canAcknowledgeResidency(
    ChequeBookResidency residency,
    List<DeliveryAddress> registered,
  ) => _hasRegisteredResidence(registered) || residency.residences.length <= 1;

  bool _hasRegisteredResidence(List<DeliveryAddress> registered) =>
      registered.isNotEmpty;

  bool _canDeleteResidence(ChequeBookResidency residency) =>
      residency.residences.length > 1;

  ChequeBookAction _residencyPrimaryAction(
    ChequeBookResidency residency,
    List<DeliveryAddress> registered,
  ) =>
      _requiresResidencyReview(residency, registered) &&
          _canAcknowledgeResidency(residency, registered)
      ? ChequeBookAction.understood
      : ChequeBookAction.next;

  bool _canContinueAfterResidency(
    ChequeBookResidency residency,
    List<DeliveryAddress> registered,
    DeliveryAddress? address,
  ) => _requiresResidencyReview(residency, registered)
      ? _canAcknowledgeResidency(residency, registered)
      : _canContinueDelivery(address);

  DeliveryAddress? _initialDeliveryAddress(List<DeliveryAddress> registered) =>
      state.catalog!.applicant == ChequeBookApplicant.legal
      ? registered.firstOrNull
      : null;

  bool _canContinueSelection(int? leafCount) =>
      state.deposit != null && leafCount != null;

  bool _canContinueDelivery(
    DeliveryAddress? address, {
    bool? recipientRequired,
    bool? nameValid,
    bool? nationalIdValid,
  }) =>
      address != null &&
      (!(recipientRequired ?? state.isRecipientRequired) ||
          ((nameValid ?? state.isRecipientNameValid) &&
              (nationalIdValid ?? state.isRecipientNationalIdValid)));

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeChequeBookInteraction() {
    emit(state.copyWith(effect: null));
  }
}
