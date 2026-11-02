import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/validators.dart';
import 'package:pishkhan_mobile/core/validators/required_text_validator.dart';

import '../../../domain/entities/issuance_data.dart';
import '../../../domain/entities/issuance_draft.dart';
import '../../../domain/usecases/card_issuance_usecase.dart';
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
  final loadIssuanceCatalogUseCase = getIt<LoadIssuanceCatalogUseCase>();
  final submitCardIssuanceUseCase = getIt<SubmitCardIssuanceUseCase>();
  int _addressCounter = 0;

  Future<void> fetchIssuanceCatalog() async {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        catalog: null,
        isCatalogEmpty: false,
      ),
    );
    final result = await loadIssuanceCatalogUseCase();
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
        final draft = _initialDraft(data);
        final fees = _issuanceFees(data, draft.noPhysicalCard);
        final total = _totalRial(fees);
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            draft: draft,
            step: IssuanceStep.selection,
            stepNumber: 1,
            isRecipientNameValid: false,
            isRecipientNationalIdValid: false,
            isRecipientMobileValid: false,
            isRecipientValid: false,
            isAgentNameValid: false,
            isAgentCodeValid: false,
            isAgentValid: false,
            confirmedRequest: null,
            fees: fees,
            totalRial: total,
            isWalletSufficient: data.walletBalanceRial >= total,
            isSelectionComplete: _selectionComplete(draft),
            isDeliveryComplete: _deliveryComplete(draft, false, false),
            isCatalogEmpty: _isCatalogEmpty(data),
            isEditable: !_isCatalogEmpty(data),
            canContinue: _selectionComplete(draft),
          ),
        );
    }
  }

  void requestTerms() {
    emit(state.copyWith(effect: const IssuanceTermsRequested()));
  }

  void requestAddAddress() {
    emit(
      state.copyWith(
        addressTitle: '',
        addressDetail: '',
        addressPostalCode: '',
        isAddressTitleValid: false,
        isAddressDetailValid: false,
        isAddressPostalCodeValid: false,
        isAddressFormError: false,
        effect: const IssuanceAddressRequested(),
      ),
    );
  }

  void requestDeleteAddress(IssuanceAddress address) {
    emit(state.copyWith(effect: IssuanceAddressRemovalRequested(address)));
  }

  Future<void> continueFlow() async {
    if (state.step == IssuanceStep.confirmation) {
      await submitCardIssuance();
      return;
    }
    selectNextStep();
  }

  void requestBack() {
    if (state.submissionStatus == RequestStatus.success ||
        state.step == IssuanceStep.selection) {
      emit(
        state.copyWith(
          navigation: _needsExitConfirmation()
              ? FlowNavigation.confirmExit
              : FlowNavigation.back,
        ),
      );
    } else {
      selectPreviousStep();
    }
  }

  void selectPreviousStep() {
    final previousStep = _isDeliveryStepOrOmitted()
        ? IssuanceStep.selection
        : IssuanceStep.delivery;
    emit(
      state.copyWith(
        step: previousStep,
        stepNumber: previousStep.index + 1,
        canContinue: _canContinue(previousStep, state.draft),
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

  void selectDeposit(IssuanceDeposit deposit) {
    final draft = state.draft.copyWith(termsAccepted: false, deposit: deposit);
    emit(
      state.copyWith(
        draft: draft,
        isSelectionComplete: _selectionComplete(draft),
        canContinue: _canContinue(state.step, draft),
        confirmedRequest: null,
      ),
    );
  }

  void selectIssuanceType(IssuanceType type) {
    final draft = state.draft.copyWith(termsAccepted: false, type: type);
    emit(
      state.copyWith(
        draft: draft,
        isSelectionComplete: _selectionComplete(draft),
        canContinue: _canContinue(state.step, draft),
        confirmedRequest: null,
      ),
    );
  }

  void updatePhysicalCardOmission(bool value) {
    final draft = state.draft.copyWith(
      termsAccepted: false,
      noPhysicalCard: value,
    );
    final fees = _issuanceFees(state.catalog!, value);
    final total = _totalRial(fees);
    emit(
      state.copyWith(
        draft: draft,
        fees: fees,
        totalRial: total,
        isWalletSufficient: state.catalog!.walletBalanceRial >= total,
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          state.isAgentValid,
        ),
        canContinue: _canContinue(state.step, draft),
        confirmedRequest: null,
      ),
    );
  }

  void selectAddress(IssuanceAddress address) {
    final draft = state.draft.copyWith(termsAccepted: false, address: address);
    emit(
      state.copyWith(
        draft: draft,
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          state.isAgentValid,
        ),
        canContinue: _canContinue(state.step, draft),
        confirmedRequest: null,
      ),
    );
  }

  void updateOtherRecipient(bool value) {
    final draft = state.draft.copyWith(
      termsAccepted: false,
      otherRecipient: value,
    );
    emit(
      state.copyWith(
        draft: draft,
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          state.isAgentValid,
        ),
        canContinue: _canContinue(state.step, draft),
        confirmedRequest: null,
      ),
    );
  }

  void updateAgentInclusion(bool value) {
    final draft = state.draft.copyWith(
      termsAccepted: false,
      includeAgent: value,
    );
    emit(
      state.copyWith(
        draft: draft,
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          state.isAgentValid,
        ),
        canContinue: _canContinue(state.step, draft),
        confirmedRequest: null,
      ),
    );
  }

  void updateRecipientName(String value) {
    final isValid = RequiredTextValidator.isValid(value);
    final draft = state.draft.copyWith(
      termsAccepted: false,
      recipient: state.draft.recipient.copyWith(name: value),
    );
    emit(
      state.copyWith(
        draft: draft,
        isRecipientNameValid: isValid,
        isRecipientValid: _isRecipientComplete(isNameValid: isValid),
        isDeliveryComplete: _deliveryComplete(
          draft,
          _isRecipientComplete(isNameValid: isValid),
          state.isAgentValid,
        ),
        canContinue: _canContinue(
          state.step,
          draft,
          isRecipientValid: _isRecipientComplete(isNameValid: isValid),
        ),
        confirmedRequest: null,
      ),
    );
  }

  void updateRecipientNationalId(String value) {
    final isValid = NationalCodeValidator.isValid(value);
    final draft = state.draft.copyWith(
      termsAccepted: false,
      recipient: state.draft.recipient.copyWith(nationalId: value),
    );
    emit(
      state.copyWith(
        draft: draft,
        isRecipientNationalIdValid: isValid,
        isRecipientValid: _isRecipientComplete(isNationalIdValid: isValid),
        isDeliveryComplete: _deliveryComplete(
          draft,
          _isRecipientComplete(isNationalIdValid: isValid),
          state.isAgentValid,
        ),
        canContinue: _canContinue(
          state.step,
          draft,
          isRecipientValid: _isRecipientComplete(isNationalIdValid: isValid),
        ),
        confirmedRequest: null,
      ),
    );
  }

  void updateRecipientMobile(String value) {
    final isValid = PhoneNumberValidator.isValid(value);
    final draft = state.draft.copyWith(
      termsAccepted: false,
      recipient: state.draft.recipient.copyWith(mobile: value),
    );
    emit(
      state.copyWith(
        draft: draft,
        isRecipientMobileValid: isValid,
        isRecipientValid: _isRecipientComplete(isMobileValid: isValid),
        isDeliveryComplete: _deliveryComplete(
          draft,
          _isRecipientComplete(isMobileValid: isValid),
          state.isAgentValid,
        ),
        canContinue: _canContinue(
          state.step,
          draft,
          isRecipientValid: _isRecipientComplete(isMobileValid: isValid),
        ),
        confirmedRequest: null,
      ),
    );
  }

  void updateAgentName(String value) {
    final isValid = RequiredTextValidator.isValid(value);
    final draft = state.draft.copyWith(
      termsAccepted: false,
      agent: state.draft.agent.copyWith(name: value),
    );
    emit(
      state.copyWith(
        draft: draft,
        isAgentNameValid: isValid,
        isAgentValid: _isAgentComplete(isNameValid: isValid),
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          _isAgentComplete(isNameValid: isValid),
        ),
        canContinue: _canContinue(
          state.step,
          draft,
          isAgentValid: _isAgentComplete(isNameValid: isValid),
        ),
        confirmedRequest: null,
      ),
    );
  }

  void updateAgentCode(String value) {
    final isValid = RequiredTextValidator.isValid(value);
    final draft = state.draft.copyWith(
      termsAccepted: false,
      agent: state.draft.agent.copyWith(code: value),
    );
    emit(
      state.copyWith(
        draft: draft,
        isAgentCodeValid: isValid,
        isAgentValid: _isAgentComplete(isCodeValid: isValid),
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          _isAgentComplete(isCodeValid: isValid),
        ),
        canContinue: _canContinue(
          state.step,
          draft,
          isAgentValid: _isAgentComplete(isCodeValid: isValid),
        ),
        confirmedRequest: null,
      ),
    );
  }

  void updateAddressTitle(String value) {
    final isValid = RequiredTextValidator.isValid(value);
    emit(state.copyWith(addressTitle: value, isAddressTitleValid: isValid));
  }

  void updateAddressDetail(String value) {
    final isValid = RequiredTextValidator.isValid(value);
    emit(state.copyWith(addressDetail: value, isAddressDetailValid: isValid));
  }

  void updateAddressPostalCode(String value) {
    final isValid = PostalCodeValidator.isValid(value.trim());
    emit(
      state.copyWith(
        addressPostalCode: value,
        isAddressPostalCodeValid: isValid,
      ),
    );
  }

  void submitAddress() {
    if (_isAddressComplete()) {
      final address = IssuanceAddress(
        id: 'local-address-${++_addressCounter}',
        title: state.addressTitle.trim(),
        detail: state.addressDetail.trim(),
        postalCode: state.addressPostalCode.trim(),
      );
      final catalog = state.catalog!.withAddresses([
        ...state.catalog!.addresses,
        address,
      ]);
      final draft = state.draft.copyWith(
        termsAccepted: false,
        address: address,
      );
      emit(
        state.copyWith(
          catalog: catalog,
          draft: draft,
          isAddressFormError: false,
          isDeliveryComplete: _deliveryComplete(
            draft,
            state.isRecipientValid,
            state.isAgentValid,
          ),
          canContinue: _canContinue(state.step, draft),
          confirmedRequest: null,
        ),
      );
    } else {
      emit(state.copyWith(isAddressFormError: true));
    }
  }

  void removeAddress(String addressId) {
    final catalog = state.catalog!.withAddresses(
      state.catalog!.addresses.where((address) => address.id != addressId),
    );
    final draft = state.draft.copyWith(
      termsAccepted: false,
      clearAddress: state.draft.address?.id == addressId,
    );
    emit(
      state.copyWith(
        catalog: catalog,
        draft: draft,
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          state.isAgentValid,
        ),
        canContinue: _canContinue(state.step, draft),
        confirmedRequest: null,
      ),
    );
  }

  void updateTermsAcceptance(bool value) {
    final draft = state.draft.copyWith(termsAccepted: value);
    emit(
      state.copyWith(
        draft: draft,
        canContinue: _canContinue(state.step, draft),
      ),
    );
  }

  void updateInvoiceExpansion(bool value) {
    emit(state.copyWith(isInvoiceExpanded: value));
  }

  void toggleSummaryExpansion() {
    emit(state.copyWith(isSummaryExpanded: !state.isSummaryExpanded));
  }

  void selectNextStep() {
    final nextStep = _isDeliveryStepOrOmitted()
        ? IssuanceStep.confirmation
        : IssuanceStep.delivery;
    emit(
      state.copyWith(
        step: nextStep,
        stepNumber: nextStep.index + 1,
        canContinue: _canContinue(nextStep, state.draft),
      ),
    );
  }

  Future<void> submitCardIssuance() async {
    final request =
        state.confirmedRequest ?? _createIssuanceRequest(state.draft);
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        confirmedRequest: request,
        isEditable: false,
        canContinue: false,
      ),
    );
    final result = await submitCardIssuanceUseCase(request);
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            isEditable: !state.isCatalogEmpty,
            canContinue: _canContinue(state.step, state.draft),
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
          ),
        );
    }
  }

  bool _isDeliveryStepOrOmitted() {
    return state.step == IssuanceStep.delivery || state.draft.noPhysicalCard;
  }

  bool _needsExitConfirmation() {
    return state.submissionStatus != RequestStatus.success &&
        state.catalogStatus == RequestStatus.success &&
        state.draft != _initialDraft(state.catalog!);
  }

  IssuanceRequest _createIssuanceRequest(IssuanceDraft draft) {
    return IssuanceRequest(
      depositId: draft.deposit!.id,
      type: draft.type!,
      noPhysicalCard: draft.noPhysicalCard,
      address: draft.noPhysicalCard ? null : draft.address!,
      recipient: !draft.noPhysicalCard && draft.otherRecipient
          ? draft.recipient
          : null,
      agent: !draft.noPhysicalCard && draft.includeAgent ? draft.agent : null,
    );
  }

  IssuanceDraft _initialDraft(IssuanceCatalog catalog) {
    final depositNumber = _normalizeDigits(initialDepositNumber ?? '');
    return IssuanceDraft(
      deposit: initialDepositNumber == null
          ? null
          : catalog.deposits
                .where(
                  (deposit) =>
                      _normalizeDigits(deposit.number) == depositNumber,
                )
                .lastOrNull,
    );
  }

  bool _isRecipientComplete({
    bool? isNameValid,
    bool? isNationalIdValid,
    bool? isMobileValid,
  }) {
    return (isNameValid ?? state.isRecipientNameValid) &&
        (isNationalIdValid ?? state.isRecipientNationalIdValid) &&
        (isMobileValid ?? state.isRecipientMobileValid);
  }

  bool _isAgentComplete({bool? isNameValid, bool? isCodeValid}) {
    return (isNameValid ?? state.isAgentNameValid) &&
        (isCodeValid ?? state.isAgentCodeValid);
  }

  bool _isAddressComplete() {
    return state.isAddressTitleValid &&
        state.isAddressDetailValid &&
        state.isAddressPostalCodeValid;
  }

  bool _isCatalogEmpty(IssuanceCatalog catalog) {
    return catalog.deposits.isEmpty || catalog.types.isEmpty;
  }

  bool _selectionComplete(IssuanceDraft draft) {
    return draft.deposit != null && draft.type != null;
  }

  bool _deliveryComplete(
    IssuanceDraft draft,
    bool isRecipientValid,
    bool isAgentValid,
  ) {
    return draft.noPhysicalCard ||
        (draft.address != null &&
            (!draft.otherRecipient || isRecipientValid) &&
            (!draft.includeAgent || isAgentValid));
  }

  bool _canContinue(
    IssuanceStep step,
    IssuanceDraft draft, {
    bool? isRecipientValid,
    bool? isAgentValid,
  }) {
    final isDeliveryComplete = _deliveryComplete(
      draft,
      isRecipientValid ?? state.isRecipientValid,
      isAgentValid ?? state.isAgentValid,
    );
    return _selectionComplete(draft) &&
        switch (step) {
          IssuanceStep.selection => true,
          IssuanceStep.delivery => isDeliveryComplete,
          IssuanceStep.confirmation =>
            isDeliveryComplete &&
                draft.termsAccepted &&
                state.isWalletSufficient,
        };
  }

  List<IssuanceFee> _issuanceFees(
    IssuanceCatalog catalog,
    bool noPhysicalCard,
  ) {
    return catalog.fees
        .where((fee) => !noPhysicalCard || fee.kind != IssuanceFeeKind.delivery)
        .toList();
  }

  int _totalRial(List<IssuanceFee> fees) {
    return fees.fold(0, (total, fee) => total + fee.amountRial);
  }

  String _normalizeDigits(String input) {
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var value = input;
    for (var digit = 0; digit < 10; digit++) {
      value = value
          .replaceAll(persian[digit], '$digit')
          .replaceAll(arabic[digit], '$digit');
    }
    return value;
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeCardIssuanceInteraction() {
    emit(state.copyWith(effect: null, navigation: null));
  }
}
