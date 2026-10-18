import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/validators.dart';

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
        catalogFailure: null,
        catalog: null,
        isCatalogEmpty: false,
      ),
    );
    return _loadIssuanceCatalog().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.failure,
              catalogFailure: failure,
              scrollId: state.scrollId + 1,
            ),
          );
        case Success(:final data):
          final draft = _initialDraft(data);
          final fees = _issuanceFees(data, draft.noPhysicalCard);
          final total = _totalRial(fees);
          final isSelectionComplete = _selectionComplete(draft);
          final isDeliveryComplete = _deliveryComplete(draft, false, false);
          final isCatalogEmpty = data.deposits.isEmpty || data.types.isEmpty;
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
              isSelectionComplete: isSelectionComplete,
              isDeliveryComplete: isDeliveryComplete,
              isCatalogEmpty: isCatalogEmpty,
              isEditable: !isCatalogEmpty,
              canContinue: isSelectionComplete,
              scrollId: state.scrollId + 1,
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
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestDeleteAddress(IssuanceAddress address) {
    emit(
      state.copyWith(
        effect: IssuanceAddressRemovalRequested(address),
        effectId: state.effectId + 1,
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
      final needsConfirmation =
          state.submissionStatus != RequestStatus.success &&
          state.catalogStatus == RequestStatus.success &&
          state.draft != _initialDraft(state.catalog!);
      emit(
        state.copyWith(
          navigation: needsConfirmation
              ? FlowNavigation.confirmExit
              : FlowNavigation.back,
          navigationId: state.navigationId + 1,
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
    final canContinue = _canContinue(
      previousStep,
      state.isSelectionComplete,
      state.isDeliveryComplete,
      state.draft.termsAccepted,
      state.isWalletSufficient,
    );
    if (state.submissionStatus == RequestStatus.loading) {
      emit(
        state.copyWith(
          step: previousStep,
          stepNumber: previousStep.index + 1,
          canContinue: canContinue,
          submissionFailure: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          step: previousStep,
          stepNumber: previousStep.index + 1,
          canContinue: canContinue,
          submissionFailure: null,
          scrollId: state.scrollId + 1,
        ),
      );
    }
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  void requestHome() {
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  void selectDeposit(IssuanceDeposit deposit) {
    final draft = state.draft.copyWith(deposit: deposit, termsAccepted: false);
    final isSelectionComplete = _selectionComplete(draft);
    emit(
      state.copyWith(
        draft: draft,
        isSelectionComplete: isSelectionComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          isSelectionComplete,
          state.isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void selectIssuanceType(IssuanceType type) {
    final draft = state.draft.copyWith(type: type, termsAccepted: false);
    final isSelectionComplete = _selectionComplete(draft);
    emit(
      state.copyWith(
        draft: draft,
        isSelectionComplete: isSelectionComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          isSelectionComplete,
          state.isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updatePhysicalCardOmission(bool value) {
    final draft = state.draft.copyWith(
      noPhysicalCard: value,
      termsAccepted: false,
    );
    final fees = _issuanceFees(state.catalog!, value);
    final total = _totalRial(fees);
    final isWalletSufficient = state.catalog!.walletBalanceRial >= total;
    final isDeliveryComplete = _deliveryComplete(
      draft,
      state.isRecipientValid,
      state.isAgentValid,
    );
    emit(
      state.copyWith(
        draft: draft,
        fees: fees,
        totalRial: total,
        isWalletSufficient: isWalletSufficient,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          isWalletSufficient,
        ),
      ),
    );
  }

  void selectAddress(IssuanceAddress address) {
    final draft = state.draft.copyWith(address: address, termsAccepted: false);
    final isDeliveryComplete = _deliveryComplete(
      draft,
      state.isRecipientValid,
      state.isAgentValid,
    );
    emit(
      state.copyWith(
        draft: draft,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateOtherRecipient(bool value) {
    final draft = state.draft.copyWith(
      otherRecipient: value,
      termsAccepted: false,
    );
    final isDeliveryComplete = _deliveryComplete(
      draft,
      state.isRecipientValid,
      state.isAgentValid,
    );
    emit(
      state.copyWith(
        draft: draft,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateAgentInclusion(bool value) {
    final draft = state.draft.copyWith(
      includeAgent: value,
      termsAccepted: false,
    );
    final isDeliveryComplete = _deliveryComplete(
      draft,
      state.isRecipientValid,
      state.isAgentValid,
    );
    emit(
      state.copyWith(
        draft: draft,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateRecipientName(String value) {
    final isValid = value.trim().isNotEmpty;
    final isRecipientValid =
        isValid &&
        state.isRecipientNationalIdValid &&
        state.isRecipientMobileValid;
    final draft = state.draft.copyWith(
      recipient: state.draft.recipient.copyWith(name: value),
      termsAccepted: false,
    );
    final isDeliveryComplete = _deliveryComplete(
      draft,
      isRecipientValid,
      state.isAgentValid,
    );
    emit(
      state.copyWith(
        draft: draft,
        isRecipientNameValid: isValid,
        isRecipientValid: isRecipientValid,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateRecipientNationalId(String value) {
    final isValid = NationalCodeValidator.isValid(value);
    final isRecipientValid =
        isValid && state.isRecipientNameValid && state.isRecipientMobileValid;
    final draft = state.draft.copyWith(
      recipient: state.draft.recipient.copyWith(nationalId: value),
      termsAccepted: false,
    );
    final isDeliveryComplete = _deliveryComplete(
      draft,
      isRecipientValid,
      state.isAgentValid,
    );
    emit(
      state.copyWith(
        draft: draft,
        isRecipientNationalIdValid: isValid,
        isRecipientValid: isRecipientValid,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateRecipientMobile(String value) {
    final isValid = PhoneNumberValidator.isValid(value);
    final isRecipientValid =
        isValid &&
        state.isRecipientNameValid &&
        state.isRecipientNationalIdValid;
    final draft = state.draft.copyWith(
      recipient: state.draft.recipient.copyWith(mobile: value),
      termsAccepted: false,
    );
    final isDeliveryComplete = _deliveryComplete(
      draft,
      isRecipientValid,
      state.isAgentValid,
    );
    emit(
      state.copyWith(
        draft: draft,
        isRecipientMobileValid: isValid,
        isRecipientValid: isRecipientValid,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateAgentName(String value) {
    final isValid = value.trim().isNotEmpty;
    final isAgentValid = isValid && state.isAgentCodeValid;
    final draft = state.draft.copyWith(
      agent: state.draft.agent.copyWith(name: value),
      termsAccepted: false,
    );
    final isDeliveryComplete = _deliveryComplete(
      draft,
      state.isRecipientValid,
      isAgentValid,
    );
    emit(
      state.copyWith(
        draft: draft,
        isAgentNameValid: isValid,
        isAgentValid: isAgentValid,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateAgentCode(String value) {
    final isValid = value.trim().isNotEmpty;
    final isAgentValid = isValid && state.isAgentNameValid;
    final draft = state.draft.copyWith(
      agent: state.draft.agent.copyWith(code: value),
      termsAccepted: false,
    );
    final isDeliveryComplete = _deliveryComplete(
      draft,
      state.isRecipientValid,
      isAgentValid,
    );
    emit(
      state.copyWith(
        draft: draft,
        isAgentCodeValid: isValid,
        isAgentValid: isAgentValid,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateAddressTitle(String value) {
    final isValid = value.trim().isNotEmpty;
    emit(state.copyWith(addressTitle: value, isAddressTitleValid: isValid));
  }

  void updateAddressDetail(String value) {
    final isValid = value.trim().isNotEmpty;
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
    if (state.isAddressTitleValid &&
        state.isAddressDetailValid &&
        state.isAddressPostalCodeValid) {
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
        address: address,
        termsAccepted: false,
      );
      final isDeliveryComplete = _deliveryComplete(
        draft,
        state.isRecipientValid,
        state.isAgentValid,
      );
      emit(
        state.copyWith(
          catalog: catalog,
          draft: draft,
          addressSavedId: state.addressSavedId + 1,
          isAddressFormError: false,
          isDeliveryComplete: isDeliveryComplete,
          confirmedRequest: null,
          submissionFailure: null,
          canContinue: _canContinue(
            state.step,
            state.isSelectionComplete,
            isDeliveryComplete,
            false,
            state.isWalletSufficient,
          ),
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
      clearAddress: state.draft.address?.id == addressId,
      termsAccepted: false,
    );
    final isDeliveryComplete = _deliveryComplete(
      draft,
      state.isRecipientValid,
      state.isAgentValid,
    );
    emit(
      state.copyWith(
        catalog: catalog,
        draft: draft,
        isDeliveryComplete: isDeliveryComplete,
        confirmedRequest: null,
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          isDeliveryComplete,
          false,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateTermsAcceptance(bool value) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(termsAccepted: value),
        submissionFailure: null,
        canContinue: _canContinue(
          state.step,
          state.isSelectionComplete,
          state.isDeliveryComplete,
          value,
          state.isWalletSufficient,
        ),
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
        scrollId: state.scrollId + 1,
        canContinue: _canContinue(
          nextStep,
          state.isSelectionComplete,
          state.isDeliveryComplete,
          state.draft.termsAccepted,
          state.isWalletSufficient,
        ),
      ),
    );
  }

  Future<void> submitCardIssuance() {
    final request =
        state.confirmedRequest ?? _createIssuanceRequest(state.draft);
    if (state.confirmedRequest == null) {
      emit(
        state.copyWith(
          confirmedRequest: request,
          submissionStatus: RequestStatus.loading,
          submissionFailure: null,
          isEditable: false,
          canContinue: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          submissionStatus: RequestStatus.loading,
          submissionFailure: null,
          isEditable: false,
          canContinue: false,
        ),
      );
    }
    return _submitCardIssuance(request).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              submissionFailure: failure,
              isEditable: !state.isCatalogEmpty,
              scrollId: state.scrollId + 1,
              canContinue: _canContinue(
                state.step,
                state.isSelectionComplete,
                state.isDeliveryComplete,
                state.draft.termsAccepted,
                state.isWalletSufficient,
              ),
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
              canContinue: false,
              scrollId: state.scrollId + 1,
            ),
          );
      }
    });
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
    return IssuanceDraft(
      deposit: initialDepositNumber == null
          ? null
          : catalog.deposits
                .where(
                  (deposit) =>
                      _normalizeDigits(deposit.number) ==
                      _normalizeDigits(initialDepositNumber!),
                )
                .lastOrNull,
    );
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
    bool isSelectionComplete,
    bool isDeliveryComplete,
    bool termsAccepted,
    bool isWalletSufficient,
  ) {
    return isSelectionComplete &&
        switch (step) {
          IssuanceStep.selection => true,
          IssuanceStep.delivery => isDeliveryComplete,
          IssuanceStep.confirmation =>
            isDeliveryComplete && termsAccepted && isWalletSufficient,
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
}
