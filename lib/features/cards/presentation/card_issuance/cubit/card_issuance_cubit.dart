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
  int _addressCounter = 0;

  Future<void> fetchIssuanceCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        catalog: null,
        isCatalogEmpty: false,
        failure: null,
        message: null,
      ),
    );
    return _loadIssuanceCatalog().then((result) {
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
    });
  }

  void requestTerms() {
    emit(state.copyWith(effect: const IssuanceTermsRequested(), message: null));
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
        message: null,
      ),
    );
  }

  void requestDeleteAddress(IssuanceAddress address) {
    emit(
      state.copyWith(
        effect: IssuanceAddressRemovalRequested(address),
        message: null,
      ),
    );
  }

  Future<void> continueFlow() {
    if (state.step == IssuanceStep.confirmation) {
      return submitCardIssuance();
    }
    selectNextStep();
    return Future.value();
  }

  void requestBack() {
    if (state.submissionStatus == RequestStatus.success ||
        state.step == IssuanceStep.selection) {
      emit(
        state.copyWith(
          navigation: _needsExitConfirmation()
              ? FlowNavigation.confirmExit
              : FlowNavigation.back,
          message: null,
        ),
      );
    } else {
      selectPreviousStep();
    }
  }

  void selectPreviousStep() {
    final previousStep =
        state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
        ? IssuanceStep.selection
        : IssuanceStep.delivery;
    emit(
      state.copyWith(
        step: previousStep,
        stepNumber: previousStep.index + 1,
        canContinue: _canContinue(
          previousStep,
          termsAccepted: state.draft.termsAccepted,
        ),
        failure: null,
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

  void selectDeposit(IssuanceDeposit deposit) {
    final draft = state.draft.copyWith(deposit: deposit);
    emit(
      state.copyWith(
        draft: draft,
        isSelectionComplete: _selectionComplete(draft),
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void selectIssuanceType(IssuanceType type) {
    final draft = state.draft.copyWith(type: type);
    emit(
      state.copyWith(
        draft: draft,
        isSelectionComplete: _selectionComplete(draft),
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void updatePhysicalCardOmission(bool value) {
    final draft = state.draft.copyWith(noPhysicalCard: value);
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
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void selectAddress(IssuanceAddress address) {
    final draft = state.draft.copyWith(address: address);
    emit(
      state.copyWith(
        draft: draft,
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          state.isAgentValid,
        ),
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void updateOtherRecipient(bool value) {
    final draft = state.draft.copyWith(otherRecipient: value);
    emit(
      state.copyWith(
        draft: draft,
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          state.isAgentValid,
        ),
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void updateAgentInclusion(bool value) {
    final draft = state.draft.copyWith(includeAgent: value);
    emit(
      state.copyWith(
        draft: draft,
        isDeliveryComplete: _deliveryComplete(
          draft,
          state.isRecipientValid,
          state.isAgentValid,
        ),
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void updateRecipientName(String value) {
    final isValid = RequiredTextValidator.isValid(value);
    final draft = state.draft.copyWith(
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
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void updateRecipientNationalId(String value) {
    final isValid = NationalCodeValidator.isValid(value);
    final draft = state.draft.copyWith(
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
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void updateRecipientMobile(String value) {
    final isValid = PhoneNumberValidator.isValid(value);
    final draft = state.draft.copyWith(
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
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void updateAgentName(String value) {
    final isValid = RequiredTextValidator.isValid(value);
    final draft = state.draft.copyWith(
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
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void updateAgentCode(String value) {
    final isValid = RequiredTextValidator.isValid(value);
    final draft = state.draft.copyWith(
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
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
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
      final draft = state.draft.copyWith(address: address);
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
          confirmedRequest: null,
        ),
      );
      updateTermsAcceptance(false);
    } else {
      emit(state.copyWith(isAddressFormError: true));
    }
  }

  void removeAddress(String addressId) {
    final catalog = state.catalog!.withAddresses(
      state.catalog!.addresses.where((address) => address.id != addressId),
    );
    final draft = state.draft.copyWith(
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
        confirmedRequest: null,
      ),
    );
    updateTermsAcceptance(false);
  }

  void updateTermsAcceptance(bool value) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(termsAccepted: value),
        canContinue: _canContinue(state.step, termsAccepted: value),
        failure: null,
        message: null,
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
    final nextStep =
        state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
        ? IssuanceStep.confirmation
        : IssuanceStep.delivery;
    emit(
      state.copyWith(
        step: nextStep,
        stepNumber: nextStep.index + 1,
        canContinue: _canContinue(
          nextStep,
          termsAccepted: state.draft.termsAccepted,
        ),
      ),
    );
  }

  Future<void> submitCardIssuance() {
    if (state.confirmedRequest == null) {
      emit(
        state.copyWith(confirmedRequest: _createIssuanceRequest(state.draft)),
      );
    }
    return _submitConfirmedIssuance();
  }

  Future<void> _submitConfirmedIssuance() {
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
        canContinue: false,
        failure: null,
        message: null,
      ),
    );
    return _submitCardIssuance(state.confirmedRequest!).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              isEditable: !state.isCatalogEmpty,
              canContinue: _canContinue(
                state.step,
                termsAccepted: state.draft.termsAccepted,
              ),
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
    });
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

  bool _canContinue(IssuanceStep step, {required bool termsAccepted}) {
    return state.isSelectionComplete &&
        switch (step) {
          IssuanceStep.selection => true,
          IssuanceStep.delivery => state.isDeliveryComplete,
          IssuanceStep.confirmation =>
            state.isDeliveryComplete &&
                termsAccepted &&
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
