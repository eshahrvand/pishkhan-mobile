import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';

import '../../../domain/entities/issuance_data.dart';
import '../../../domain/entities/issuance_draft.dart';
import '../../../domain/repositories/card_issuance_repository.dart';
import '../../../domain/usecases/card_issuance.dart';
import 'issuance_effect.dart';

export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';

export '../../../domain/entities/issuance_draft.dart';
export 'issuance_effect.dart';

part 'card_issuance_state.dart';
part 'card_issuance_cubit.freezed.dart';

class CardIssuanceCubit extends Cubit<CardIssuanceState> {
  CardIssuanceCubit({
    CardIssuanceState initialState = const CardIssuanceState.initial(),
    this.initialDepositNumber,
  }) : super(initialState);

  final String? initialDepositNumber;
  final _repository = getIt<CardIssuanceRepository>();
  late final _loadIssuanceCatalog = LoadIssuanceCatalog(_repository);
  late final _submitCardIssuance = SubmitCardIssuance(_repository);
  int _catalogRequestId = 0;
  int _submissionRequestId = 0;
  int _addressCounter = 0;

  Future<void> fetchIssuanceCatalog() {
    if (state.submissionStatus == RequestStatus.loading ||
        state.submissionStatus == RequestStatus.success) {
      return Future.value();
    }
    final requestId = ++_catalogRequestId;

    emit(
      state.copyWith(
        status: RequestStatus.loading,
        submissionStatus: RequestStatus.initial,
        catalog: null,
        draft: const IssuanceDraft(),
        step: IssuanceStep.selection,
        invoiceExpanded: true,
        summaryExpanded: true,
        receipt: null,
        failure: null,
        deposit: null,
        address: null,
        selectionComplete: false,
        deliveryComplete: false,
        fees: const [],
        totalRial: 0,
        walletSufficient: false,
        editable: false,
        canContinue: false,
        request: null,
        effect: null,
        navigation: null,
        isAddressFormError: false,
      ),
    );

    return _loadIssuanceCatalog().then((result) {
      if (isClosed || requestId != _catalogRequestId) return;

      switch (result) {
        case Err(:final failure):
          emit(state.copyWith(status: RequestStatus.failure, failure: failure));
        case Success(:final data):
          final draft = _createInitialDraft(data, initialDepositNumber);
          final fees = _getIssuanceFees(data, draft);
          final totalRial = _calculateTotalRial(fees);

          emit(
            state.copyWith(
              status: RequestStatus.success,
              catalog: data,
              draft: draft,
              deposit: _findDeposit(data, draft.depositId),
              address: _findAddress(data, draft.addressId),
              selectionComplete: _isSelectionComplete(data, draft),
              deliveryComplete: _isDeliveryComplete(data, draft),
              fees: fees,
              totalRial: totalRial,
              walletSufficient: data.walletBalanceRial >= totalRial,
              editable: _isCatalogEditable(data),
              canContinue:
                  _isCatalogEditable(data) &&
                  _canContinue(IssuanceStep.selection, data, draft),
              request: _createIssuanceRequest(data, draft),
            ),
          );
      }
    });
  }

  void requestTerms() {
    emit(
      state.copyWith(
        effect: const IssuanceTermsRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestAddAddress() {
    if (!state.editable) return;
    emit(
      state.copyWith(
        isAddressFormError: false,
        effect: const IssuanceAddressRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestDeleteAddress(IssuanceAddress address) {
    if (!state.editable || state.address?.id != address.id) return;
    emit(
      state.copyWith(
        effect: IssuanceAddressRemovalRequested(address),
        effectId: state.effectId + 1,
      ),
    );
  }

  void handleAddressRemovalResult(String addressId, bool? confirmed) {
    if (confirmed != true || state.address?.id != addressId) return;
    removeAddress(addressId);
  }

  Future<void> continueFlow() {
    if (!state.canContinue) return Future.value();
    if (state.step == IssuanceStep.confirmation) {
      return submitCardIssuance();
    }
    advanceStep();
    return Future.value();
  }

  void requestBack() {
    if (state.submissionStatus == RequestStatus.loading) return;
    if (_goToPreviousStep()) return;
    if (state.navigation == FlowNavigation.confirmExit ||
        state.navigation == FlowNavigation.back) {
      return;
    }
    final needsConfirmation =
        state.submissionStatus != RequestStatus.success &&
        state.status == RequestStatus.success &&
        state.draft != _createInitialDraft(state.catalog, initialDepositNumber);
    emit(
      state.copyWith(
        navigation: needsConfirmation
            ? FlowNavigation.confirmExit
            : FlowNavigation.back,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  void handleExitConfirmationResult(bool? confirmed) {
    if (state.navigation != FlowNavigation.confirmExit ||
        state.submissionStatus == RequestStatus.loading) {
      return;
    }
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  void requestHome() {
    if (state.submissionStatus == RequestStatus.loading) return;
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  void selectDeposit(String depositId) {
    if (!state.editable || _findDeposit(state.catalog, depositId) == null) {
      return;
    }
    final draft = state.draft.copyWith(
      depositId: depositId,
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        draft: draft,
        deposit: _findDeposit(state.catalog, depositId),
        selectionComplete: _isSelectionComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void selectIssuanceType(IssuanceType? type) {
    if (!state.editable ||
        type == null ||
        !(state.catalog?.types.contains(type) ?? false)) {
      return;
    }
    final draft = state.draft.copyWith(type: type, termsAccepted: false);
    emit(
      state.copyWith(
        draft: draft,
        selectionComplete: _isSelectionComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void updatePhysicalCardOmission(bool value) {
    if (!state.editable) return;
    final draft = state.draft.copyWith(
      noPhysicalCard: value,
      termsAccepted: false,
    );
    final fees = _getIssuanceFees(state.catalog, draft);
    final totalRial = _calculateTotalRial(fees);
    emit(
      state.copyWith(
        draft: draft,
        deliveryComplete: _isDeliveryComplete(state.catalog, draft),
        fees: fees,
        totalRial: totalRial,
        walletSufficient: state.catalog!.walletBalanceRial >= totalRial,
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void selectAddress(String addressId) {
    if (!state.editable || _findAddress(state.catalog, addressId) == null) {
      return;
    }
    final draft = state.draft.copyWith(
      addressId: addressId,
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        draft: draft,
        address: _findAddress(state.catalog, addressId),
        deliveryComplete: _isDeliveryComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  bool addAddress({
    required String title,
    required String detail,
    required String postalCode,
  }) {
    if (!state.editable) return false;
    final normalizedPostalCode = DigitNormalizer.normalize(postalCode).trim();
    if (title.trim().isEmpty ||
        detail.trim().isEmpty ||
        !PostalCodeValidator.isValid(normalizedPostalCode)) {
      emit(state.copyWith(isAddressFormError: true));
      return false;
    }
    final address = IssuanceAddress(
      id: 'local-address-${++_addressCounter}',
      title: title.trim(),
      detail: detail.trim(),
      postalCode: normalizedPostalCode,
    );
    final catalog = state.catalog!.withAddresses([
      ...state.catalog!.addresses,
      address,
    ]);
    final draft = state.draft.copyWith(
      addressId: address.id,
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        addressSavedId: state.addressSavedId + 1,
        isAddressFormError: false,
        catalog: catalog,
        draft: draft,
        address: address,
        deliveryComplete: _isDeliveryComplete(catalog, draft),
        request: _createIssuanceRequest(catalog, draft),
        canContinue: _canContinue(state.step, catalog, draft),
        failure: null,
      ),
    );
    return true;
  }

  void removeAddress(String addressId) {
    if (!state.editable || state.catalog == null) return;
    final catalog = state.catalog!.withAddresses(
      state.catalog!.addresses.where((address) => address.id != addressId),
    );
    final draft = state.draft.copyWith(
      clearAddress: state.draft.addressId == addressId,
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        catalog: catalog,
        draft: draft,
        address: _findAddress(catalog, draft.addressId),
        deliveryComplete: _isDeliveryComplete(catalog, draft),
        request: _createIssuanceRequest(catalog, draft),
        canContinue: _canContinue(state.step, catalog, draft),
        failure: null,
      ),
    );
  }

  void updateOtherRecipient(bool value) {
    if (!state.editable) return;
    final draft = state.draft.copyWith(
      otherRecipient: value,
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        draft: draft,
        deliveryComplete: _isDeliveryComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void updateAgentInclusion(bool value) {
    if (!state.editable) return;
    final draft = state.draft.copyWith(
      includeAgent: value,
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        draft: draft,
        deliveryComplete: _isDeliveryComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void updateRecipientName(String value) {
    if (!state.editable) return;
    final draft = state.draft.copyWith(
      recipient: state.draft.recipient.copyWith(name: value),
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        draft: draft,
        deliveryComplete: _isDeliveryComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void updateRecipientNationalId(String value) {
    if (!state.editable) return;
    final draft = state.draft.copyWith(
      recipient: state.draft.recipient.copyWith(
        nationalId: DigitNormalizer.normalize(value),
      ),
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        draft: draft,
        deliveryComplete: _isDeliveryComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void updateRecipientMobile(String value) {
    if (!state.editable) return;
    final draft = state.draft.copyWith(
      recipient: state.draft.recipient.copyWith(
        mobile: DigitNormalizer.normalize(value),
      ),
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        draft: draft,
        deliveryComplete: _isDeliveryComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void updateAgentName(String value) {
    if (!state.editable) return;
    final draft = state.draft.copyWith(
      agent: state.draft.agent.copyWith(name: value),
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        draft: draft,
        deliveryComplete: _isDeliveryComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void updateAgentCode(String value) {
    if (!state.editable) return;
    final draft = state.draft.copyWith(
      agent: state.draft.agent.copyWith(code: DigitNormalizer.normalize(value)),
      termsAccepted: false,
    );
    emit(
      state.copyWith(
        draft: draft,
        deliveryComplete: _isDeliveryComplete(state.catalog, draft),
        request: _createIssuanceRequest(state.catalog, draft),
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void updateTermsAcceptance(bool value) {
    if (!state.editable) return;
    final draft = state.draft.copyWith(termsAccepted: value);
    emit(
      state.copyWith(
        draft: draft,
        canContinue: _canContinue(state.step, state.catalog, draft),
        failure: null,
      ),
    );
  }

  void updateInvoiceExpansion(bool value) {
    if (!state.editable) return;
    emit(state.copyWith(invoiceExpanded: value));
  }

  void updateSummaryExpansion(bool value) {
    if (!state.editable) return;
    emit(state.copyWith(summaryExpanded: value));
  }

  void advanceStep() {
    if (!state.editable ||
        !state.canContinue ||
        state.step == IssuanceStep.confirmation) {
      return;
    }
    final nextStep =
        state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
        ? IssuanceStep.confirmation
        : IssuanceStep.delivery;
    emit(
      state.copyWith(
        step: nextStep,
        canContinue: _canContinue(nextStep, state.catalog, state.draft),
      ),
    );
  }

  bool _goToPreviousStep() {
    if (!state.editable || state.step == IssuanceStep.selection) return false;
    final previousStep =
        state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
        ? IssuanceStep.selection
        : IssuanceStep.delivery;
    emit(
      state.copyWith(
        step: previousStep,
        failure: null,
        canContinue: _canContinue(previousStep, state.catalog, state.draft),
      ),
    );
    return true;
  }

  Future<void> submitCardIssuance() {
    if (state.step != IssuanceStep.confirmation ||
        !state.canContinue ||
        !state.editable ||
        state.request == null ||
        state.submissionStatus == RequestStatus.loading ||
        state.submissionStatus == RequestStatus.success) {
      return Future.value();
    }
    final request = state.request!;
    final requestId = ++_submissionRequestId;
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        failure: null,
        editable: false,
        canContinue: false,
      ),
    );

    return _submitCardIssuance(request).then((result) {
      if (isClosed || requestId != _submissionRequestId) return;

      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              failure: failure,
              editable: _isCatalogEditable(state.catalog),
              canContinue:
                  _isCatalogEditable(state.catalog) &&
                  _canContinue(state.step, state.catalog, state.draft),
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
              editable: false,
              canContinue: false,
            ),
          );
      }
    });
  }

  IssuanceDraft _createInitialDraft(
    IssuanceCatalog? catalog,
    String? depositNumber,
  ) {
    return IssuanceDraft(
      depositId: _findInitialDepositId(catalog, depositNumber),
    );
  }

  String? _findInitialDepositId(
    IssuanceCatalog? catalog,
    String? depositNumber,
  ) {
    if (depositNumber == null) return null;
    final normalizedNumber = DigitNormalizer.normalize(depositNumber);
    return catalog?.deposits
        .where(
          (deposit) =>
              DigitNormalizer.normalize(deposit.number) == normalizedNumber,
        )
        .lastOrNull
        ?.id;
  }

  IssuanceDeposit? _findDeposit(IssuanceCatalog? catalog, String? depositId) {
    return catalog?.deposits
        .where((deposit) => deposit.id == depositId)
        .firstOrNull;
  }

  IssuanceAddress? _findAddress(IssuanceCatalog? catalog, String? addressId) {
    return catalog?.addresses
        .where((address) => address.id == addressId)
        .firstOrNull;
  }

  bool _isSelectionComplete(IssuanceCatalog? catalog, IssuanceDraft draft) {
    return _findDeposit(catalog, draft.depositId) != null &&
        draft.type != null &&
        (catalog?.types.contains(draft.type) ?? false);
  }

  bool _isDeliveryComplete(IssuanceCatalog? catalog, IssuanceDraft draft) {
    return draft.noPhysicalCard ||
        (_findAddress(catalog, draft.addressId) != null &&
            (!draft.otherRecipient || draft.recipient.isComplete) &&
            (!draft.includeAgent || draft.agent.isComplete));
  }

  List<IssuanceFee> _getIssuanceFees(
    IssuanceCatalog? catalog,
    IssuanceDraft draft,
  ) {
    return catalog?.fees
            .where(
              (fee) =>
                  !draft.noPhysicalCard || fee.kind != IssuanceFeeKind.delivery,
            )
            .toList() ??
        const [];
  }

  int _calculateTotalRial(List<IssuanceFee> fees) {
    return fees.fold<int>(0, (total, fee) => total + fee.amountRial);
  }

  bool _isCatalogEditable(IssuanceCatalog? catalog) {
    return catalog?.deposits.isNotEmpty == true &&
        catalog?.types.isNotEmpty == true;
  }

  bool _canContinue(
    IssuanceStep step,
    IssuanceCatalog? catalog,
    IssuanceDraft draft,
  ) {
    if (!_isSelectionComplete(catalog, draft)) return false;
    return switch (step) {
      IssuanceStep.selection => true,
      IssuanceStep.delivery => _isDeliveryComplete(catalog, draft),
      IssuanceStep.confirmation =>
        _isDeliveryComplete(catalog, draft) &&
            draft.termsAccepted &&
            catalog != null &&
            catalog.walletBalanceRial >=
                _calculateTotalRial(_getIssuanceFees(catalog, draft)),
    };
  }

  IssuanceRequest? _createIssuanceRequest(
    IssuanceCatalog? catalog,
    IssuanceDraft draft,
  ) {
    if (!_isSelectionComplete(catalog, draft) ||
        !_isDeliveryComplete(catalog, draft)) {
      return null;
    }
    return IssuanceRequest(
      depositId: draft.depositId!,
      type: draft.type!,
      noPhysicalCard: draft.noPhysicalCard,
      address: draft.noPhysicalCard
          ? null
          : _findAddress(catalog, draft.addressId),
      recipient: !draft.noPhysicalCard && draft.otherRecipient
          ? draft.recipient
          : null,
      agent: !draft.noPhysicalCard && draft.includeAgent ? draft.agent : null,
    );
  }

  @override
  Future<void> close() {
    _catalogRequestId++;
    _submissionRequestId++;
    return super.close();
  }
}
