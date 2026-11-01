import 'package:pishkhan_mobile/core/validators/required_text_validator.dart';

import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/national_code_validator.dart';
import 'package:pishkhan_mobile/core/validators/passport_validator.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../../domain/entities/financial_certificate_data.dart';
import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/repositories/financial_certificate_repository.dart';
import '../../../domain/usecases/average_balance_usecase.dart';
import '../../shared/certificate_effect.dart';

export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';

export '../../shared/certificate_effect.dart';

part 'financial_certificate_state.dart';
part 'financial_certificate_cubit.freezed.dart';

class FinancialCertificateCubit extends Cubit<FinancialCertificateState> {
  FinancialCertificateCubit({
    this.initialDepositNumber,
    FinancialCertificateState initialState =
        const FinancialCertificateState.initial(),
  }) : super(initialState);

  final repository = getIt<FinancialCertificateRepository>();
  final loadCertificateCatalogUseCase = getIt<LoadCertificateCatalogUseCase>(
    instanceName: 'financial-certificate',
  );
  final String? initialDepositNumber;
  int _localAddress = 0;
  // The last sent payload owns its key; editing the form does not create a request.
  FinancialCertificateRequest? _submittedRequest;

  FinancialCertificateState? _entryState;

  void requestAddAddress() {
    emit(state.copyWith(effect: const CertificateAddressRequested()));
  }

  void applyAddressSelection(CertificateAddress? address) {
    if (address != null) addAddress(address);
  }

  void requestDeleteAddress() {
    emit(
      state.copyWith(
        effect: CertificateAddressRemovalRequested(state.address!),
      ),
    );
  }

  void requestAgentLookup() {
    emit(state.copyWith(effect: const CertificateAgentUnavailable()));
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        effect: null,
      ),
    );
  }

  void requestHome() {
    emit(state.copyWith(navigation: FlowNavigation.home, effect: null));
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(navigation: FlowNavigation.home, effect: null));
  }

  void requestBack() {
    switch (state.step) {
      case FinancialCertificateStep.confirmation:
        emit(
          state.copyWith(
            step: FinancialCertificateStep.delivery,
            stepNumber: 4,
            canContinue: _canContinueDelivery(state.address),
          ),
        );
      case FinancialCertificateStep.delivery:
        emit(
          state.copyWith(
            step: FinancialCertificateStep.latinIdentity,
            stepNumber: 3,
            canContinue: state.isLatinComplete,
          ),
        );
      case FinancialCertificateStep.latinIdentity:
        emit(
          state.copyWith(
            step: FinancialCertificateStep.recipient,
            stepNumber: 2,
            canContinue: state.isRecipientComplete,
          ),
        );
      case FinancialCertificateStep.recipient:
        emit(
          state.copyWith(
            step: FinancialCertificateStep.conditions,
            stepNumber: 1,
            canContinue: _areConditionsComplete(state.deposit),
          ),
        );
      case FinancialCertificateStep.conditions:
        emit(
          state.copyWith(
            navigation: _requiresExitConfirmation()
                ? FlowNavigation.confirmExit
                : FlowNavigation.back,
            effect: null,
          ),
        );
    }
  }

  Future<void> continueFlow() async {
    switch (state.step) {
      case FinancialCertificateStep.conditions:
        emit(
          state.copyWith(
            step: FinancialCertificateStep.recipient,
            stepNumber: 2,
            canContinue: state.isRecipientComplete,
          ),
        );
      case FinancialCertificateStep.recipient:
        emit(
          state.copyWith(
            step: FinancialCertificateStep.latinIdentity,
            stepNumber: 3,
            canContinue: state.isLatinComplete,
          ),
        );
      case FinancialCertificateStep.latinIdentity:
        emit(
          state.copyWith(
            step: FinancialCertificateStep.delivery,
            stepNumber: 4,
            canContinue: _canContinueDelivery(state.address),
          ),
        );
      case FinancialCertificateStep.delivery:
        emit(
          state.copyWith(
            step: FinancialCertificateStep.confirmation,
            stepNumber: 5,
            canContinue: state.isWalletSufficient,
          ),
        );
      case FinancialCertificateStep.confirmation:
        await submitCertificate();
    }
  }

  Future<void> fetchCatalog() async {
    emit(
      state.copyWith(catalogStatus: RequestStatus.loading, canContinue: false),
    );
    final result = await loadCertificateCatalogUseCase();
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
        final deposit = _resolveDeposit(data.deposits);
        final nameValid = PassportValidator.latinName(state.name);
        final surnameValid = PassportValidator.latinName(state.surname);
        final fatherValid = PassportValidator.latinName(state.fatherName);
        final passportValid = PassportValidator.number(state.passportNumber);
        final expiry = PassportValidator.expiry(state.passportExpiryText);
        final addressValid = PassportValidator.latinAddress(state.latinAddress);
        final authorityValid = RequiredTextValidator.isValid(
          state.authorityName,
        );
        final deliveryNameValid = RequiredTextValidator.isValid(
          state.deliveryRecipientName,
        );
        final nationalIdValid = NationalCodeValidator.isValid(
          state.deliveryRecipientNationalId,
        );
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            deposit: deposit,
            addresses: data.addresses,
            totalRial: _calculateTotalFee(data),
            isWalletSufficient: _isWalletSufficient(data),
            isLatinNameValid: nameValid,
            isLatinSurnameValid: surnameValid,
            isLatinFatherNameValid: fatherValid,
            isPassportNumberValid: passportValid,
            passportExpiry: expiry,
            isLatinAddressValid: addressValid,
            isLatinComplete: _isLatinComplete(
              namesValid: _areLatinNamesValid(
                nameValid: nameValid,
                surnameValid: surnameValid,
                fatherNameValid: fatherValid,
              ),
              passportValid: _isPassportComplete(passportValid, expiry),
              addressValid: addressValid,
            ),
            isAuthorityNameValid: authorityValid,
            isRecipientComplete: _isRecipientComplete(
              state.recipient,
              state.embassy,
              authorityValid,
              state.currency,
            ),
            isRecipientNameValid: deliveryNameValid,
            isRecipientNationalIdValid: nationalIdValid,
            canCheckAgent: RequiredTextValidator.isValid(state.agentIdentifier),
            stepNumber: state.step.index + 1,
            canContinue: _canContinueAfterCatalog(
              catalog: data,
              deposit: deposit,
              recipientComplete: _isRecipientComplete(
                state.recipient,
                state.embassy,
                authorityValid,
                state.currency,
              ),
              latinComplete: _isLatinComplete(
                namesValid: _areLatinNamesValid(
                  nameValid: nameValid,
                  surnameValid: surnameValid,
                  fatherNameValid: fatherValid,
                ),
                passportValid: _isPassportComplete(passportValid, expiry),
                addressValid: addressValid,
              ),
              deliveryComplete: _canContinueDelivery(
                state.address,
                isRecipientNameValid: deliveryNameValid,
                isRecipientNationalIdValid: nationalIdValid,
              ),
            ),
          ),
        );
        _entryState = state;
    }
  }

  void selectDeposit(ListedDeposit deposit) {
    emit(state.copyWith(deposit: deposit, conditions: {}, canContinue: false));
  }

  void toggleCondition(FinancialCertificateCondition condition) {
    final conditions = {...state.conditions};
    if (!conditions.remove(condition)) conditions.add(condition);
    emit(
      state.copyWith(
        conditions: conditions,
        canContinue: conditions.isNotEmpty,
      ),
    );
  }

  void selectRecipient(FinancialCertificateRecipient recipient) {
    emit(
      state.copyWith(
        recipient: recipient,
        embassy: null,
        authorityName: '',
        currency: null,
        isAuthorityNameValid: false,
        isRecipientComplete: false,
        canContinue: false,
      ),
    );
  }

  void selectEmbassy(CertificateEmbassy embassy) {
    emit(
      state.copyWith(
        embassy: embassy,
        isRecipientComplete: _isRecipientComplete(
          FinancialCertificateRecipient.embassy,
          embassy,
          state.isAuthorityNameValid,
          state.currency,
        ),
        canContinue: _isRecipientComplete(
          FinancialCertificateRecipient.embassy,
          embassy,
          state.isAuthorityNameValid,
          state.currency,
        ),
      ),
    );
  }

  void updateAuthorityName(String value) {
    final valid = RequiredTextValidator.isValid(value);
    emit(
      state.copyWith(
        authorityName: value,
        isAuthorityNameValid: valid,
        isRecipientComplete: _isRecipientComplete(
          FinancialCertificateRecipient.otherAuthority,
          state.embassy,
          valid,
          state.currency,
        ),
        canContinue: _isRecipientComplete(
          FinancialCertificateRecipient.otherAuthority,
          state.embassy,
          valid,
          state.currency,
        ),
      ),
    );
  }

  void selectCurrency(CertificateCurrency currency) {
    emit(
      state.copyWith(
        currency: currency,
        isRecipientComplete: _isRecipientComplete(
          state.recipient,
          state.embassy,
          state.isAuthorityNameValid,
          currency,
        ),
        canContinue: _isRecipientComplete(
          state.recipient,
          state.embassy,
          state.isAuthorityNameValid,
          currency,
        ),
      ),
    );
  }

  void updateLatinName(String value) {
    final valid = PassportValidator.latinName(value);
    emit(
      state.copyWith(
        name: value,
        isLatinNameValid: valid,
        isLatinComplete: _isLatinComplete(
          namesValid: _areLatinNamesValid(nameValid: valid),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            state.passportExpiry,
          ),
          addressValid: state.isLatinAddressValid,
        ),
        canContinue: _isLatinComplete(
          namesValid: _areLatinNamesValid(nameValid: valid),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            state.passportExpiry,
          ),
          addressValid: state.isLatinAddressValid,
        ),
      ),
    );
  }

  void updateLatinSurname(String value) {
    final valid = PassportValidator.latinName(value);
    emit(
      state.copyWith(
        surname: value,
        isLatinSurnameValid: valid,
        isLatinComplete: _isLatinComplete(
          namesValid: _areLatinNamesValid(surnameValid: valid),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            state.passportExpiry,
          ),
          addressValid: state.isLatinAddressValid,
        ),
        canContinue: _isLatinComplete(
          namesValid: _areLatinNamesValid(surnameValid: valid),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            state.passportExpiry,
          ),
          addressValid: state.isLatinAddressValid,
        ),
      ),
    );
  }

  void updateLatinFatherName(String value) {
    final valid = PassportValidator.latinName(value);
    emit(
      state.copyWith(
        fatherName: value,
        isLatinFatherNameValid: valid,
        isLatinComplete: _isLatinComplete(
          namesValid: _areLatinNamesValid(fatherNameValid: valid),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            state.passportExpiry,
          ),
          addressValid: state.isLatinAddressValid,
        ),
        canContinue: _isLatinComplete(
          namesValid: _areLatinNamesValid(fatherNameValid: valid),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            state.passportExpiry,
          ),
          addressValid: state.isLatinAddressValid,
        ),
      ),
    );
  }

  void updatePassportNumber(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final valid = PassportValidator.number(normalized);
    emit(
      state.copyWith(
        passportNumber: normalized,
        isPassportNumberValid: valid,
        isLatinComplete: _isLatinComplete(
          namesValid: _areLatinNamesValid(),
          passportValid: _isPassportComplete(valid, state.passportExpiry),
          addressValid: state.isLatinAddressValid,
        ),
        canContinue: _isLatinComplete(
          namesValid: _areLatinNamesValid(),
          passportValid: _isPassportComplete(valid, state.passportExpiry),
          addressValid: state.isLatinAddressValid,
        ),
      ),
    );
  }

  void updatePassportExpiry(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final expiry = PassportValidator.expiry(normalized);
    emit(
      state.copyWith(
        passportExpiryText: normalized,
        passportExpiry: expiry,
        isLatinComplete: _isLatinComplete(
          namesValid: _areLatinNamesValid(),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            expiry,
          ),
          addressValid: state.isLatinAddressValid,
        ),
        canContinue: _isLatinComplete(
          namesValid: _areLatinNamesValid(),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            expiry,
          ),
          addressValid: state.isLatinAddressValid,
        ),
      ),
    );
  }

  void updateLatinAddress(String value) {
    final valid = PassportValidator.latinAddress(value);
    emit(
      state.copyWith(
        latinAddress: value,
        isLatinAddressValid: valid,
        isLatinComplete: _isLatinComplete(
          namesValid: _areLatinNamesValid(),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            state.passportExpiry,
          ),
          addressValid: valid,
        ),
        canContinue: _isLatinComplete(
          namesValid: _areLatinNamesValid(),
          passportValid: _isPassportComplete(
            state.isPassportNumberValid,
            state.passportExpiry,
          ),
          addressValid: valid,
        ),
      ),
    );
  }

  void selectAddress(CertificateAddress address) {
    emit(
      state.copyWith(
        address: address,
        canContinue: _canContinueDelivery(address),
      ),
    );
  }

  void addAddress(CertificateAddress address) {
    final local = CertificateAddress(
      id: 'local-${++_localAddress}',
      title: address.title,
      detail: address.detail,
      postalCode: address.postalCode,
    );
    emit(
      state.copyWith(
        addresses: [...state.addresses, local],
        address: local,
        canContinue: _canContinueDelivery(local),
      ),
    );
  }

  void removeAddress(CertificateAddress address) {
    emit(
      state.copyWith(
        addresses: state.addresses
            .where((item) => item.id != address.id)
            .toList(),
        address: null,
        canContinue: false,
      ),
    );
  }

  void updateOtherRecipient(bool value) {
    emit(
      state.copyWith(
        isOtherRecipient: value,
        canContinue: _canContinueDelivery(
          state.address,
          isOtherRecipient: value,
        ),
      ),
    );
  }

  void updateRecipientName(String value) {
    final valid = RequiredTextValidator.isValid(value);
    emit(
      state.copyWith(
        deliveryRecipientName: value,
        isRecipientNameValid: valid,
        canContinue: _canContinueDelivery(
          state.address,
          isRecipientNameValid: valid,
        ),
      ),
    );
  }

  void updateRecipientNationalId(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final valid = NationalCodeValidator.isValid(normalized);
    emit(
      state.copyWith(
        deliveryRecipientNationalId: normalized,
        isRecipientNationalIdValid: valid,
        canContinue: _canContinueDelivery(
          state.address,
          isRecipientNationalIdValid: valid,
        ),
      ),
    );
  }

  void updateIncludeAgent(bool value) {
    emit(state.copyWith(isIncludeAgent: value));
  }

  void updateAgentIdentifier(String value) {
    final normalized = DigitNormalizer.normalize(value);
    emit(
      state.copyWith(
        agentIdentifier: normalized,
        canCheckAgent: RequiredTextValidator.isValid(normalized),
      ),
    );
  }

  void updateSummaryExpanded(bool value) {
    emit(state.copyWith(isSummaryExpanded: value));
  }

  void updateInvoiceExpanded(bool value) {
    emit(state.copyWith(isInvoiceExpanded: value));
  }

  Future<void> submitCertificate() async {
    var request = _createRequest(_submittedRequest?.idempotencyKey);
    if (_submittedRequest != null && request != _submittedRequest) {
      request = _createRequest(null);
    }
    _submittedRequest = request;
    emit(state.copyWith(submissionStatus: RequestStatus.loading));
    final result = await certificateBoundary(
      () => repository.submitFinancialCertificate(request),
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            canContinue: false,
          ),
        );
    }
  }

  FinancialCertificateRequest _createRequest(String? idempotencyKey) {
    return FinancialCertificateRequest(
      depositId: state.deposit!.id,
      conditions: state.conditions,
      recipient: state.recipient!,
      embassyId: state.recipient == FinancialCertificateRecipient.embassy
          ? state.embassy!.id
          : null,
      authorityName:
          state.recipient == FinancialCertificateRecipient.otherAuthority
          ? state.authorityName.trim()
          : null,
      currency: state.currency!,
      identity: FinancialLatinIdentity(
        name: state.name.trim(),
        surname: state.surname.trim(),
        fatherName: state.fatherName.trim(),
        passportNumber: state.passportNumber.trim(),
        passportExpiry: state.passportExpiry!,
        address: state.latinAddress.trim(),
      ),
      address: state.address!,
      deliveryRecipientName: state.isOtherRecipient
          ? state.deliveryRecipientName.trim()
          : null,
      deliveryRecipientNationalId: state.isOtherRecipient
          ? state.deliveryRecipientNationalId
          : null,
      agentIdentifier:
          state.isIncludeAgent &&
              RequiredTextValidator.isValid(state.agentIdentifier)
          ? state.agentIdentifier
          : null,
      idempotencyKey:
          idempotencyKey ??
          List.generate(
            16,
            (_) =>
                Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
          ).join(),
    );
  }

  ListedDeposit? _resolveDeposit(List<ListedDeposit> deposits) {
    final number = _normalizeDepositNumber(initialDepositNumber ?? '');
    return deposits
        .where(
          (deposit) =>
              deposit.id == state.deposit?.id ||
              (number.isNotEmpty &&
                  _normalizeDepositNumber(deposit.number) == number),
        )
        .firstOrNull;
  }

  String _normalizeDepositNumber(String number) =>
      DigitNormalizer.normalize(number).replaceAll(RegExp(r'[^0-9]'), '');

  bool _canContinueDelivery(
    CertificateAddress? address, {
    bool? isOtherRecipient,
    bool? isRecipientNameValid,
    bool? isRecipientNationalIdValid,
  }) {
    return address != null &&
        (!(isOtherRecipient ?? state.isOtherRecipient) ||
            ((isRecipientNameValid ?? state.isRecipientNameValid) &&
                (isRecipientNationalIdValid ??
                    state.isRecipientNationalIdValid)));
  }

  bool _areLatinNamesValid({
    bool? nameValid,
    bool? surnameValid,
    bool? fatherNameValid,
  }) {
    return (nameValid ?? state.isLatinNameValid) &&
        (surnameValid ?? state.isLatinSurnameValid) &&
        (fatherNameValid ?? state.isLatinFatherNameValid);
  }

  bool _isPassportComplete(bool isNumberValid, DateTime? expiry) =>
      isNumberValid && expiry != null;

  bool _isLatinComplete({
    required bool namesValid,
    required bool passportValid,
    required bool addressValid,
  }) => namesValid && passportValid && addressValid;

  bool _isRecipientComplete(
    FinancialCertificateRecipient? recipient,
    CertificateEmbassy? embassy,
    bool authorityNameValid,
    CertificateCurrency? currency,
  ) {
    return currency != null &&
        switch (recipient) {
          FinancialCertificateRecipient.embassy => embassy != null,
          FinancialCertificateRecipient.otherAuthority => authorityNameValid,
          null => false,
        };
  }

  bool _areConditionsComplete(ListedDeposit? deposit) =>
      deposit != null && state.conditions.isNotEmpty;

  int _calculateTotalFee(CertificateCatalog catalog) =>
      catalog.printFeeRial + catalog.deliveryFeeRial;

  bool _isWalletSufficient(CertificateCatalog catalog) =>
      catalog.walletBalanceRial >= _calculateTotalFee(catalog);

  bool _canContinueAfterCatalog({
    required CertificateCatalog catalog,
    required ListedDeposit? deposit,
    required bool recipientComplete,
    required bool latinComplete,
    required bool deliveryComplete,
  }) {
    return _areConditionsComplete(deposit) &&
        switch (state.step) {
          FinancialCertificateStep.conditions => true,
          FinancialCertificateStep.recipient => recipientComplete,
          FinancialCertificateStep.latinIdentity =>
            recipientComplete && latinComplete,
          FinancialCertificateStep.delivery =>
            recipientComplete && latinComplete && deliveryComplete,
          FinancialCertificateStep.confirmation =>
            recipientComplete &&
                latinComplete &&
                deliveryComplete &&
                _isWalletSufficient(catalog),
        };
  }

  bool _requiresExitConfirmation() {
    return state.submissionStatus != RequestStatus.success &&
        state.catalogStatus == RequestStatus.success &&
        (state.deposit != _entryState?.deposit ||
            (state.conditions.length != (_entryState?.conditions.length ?? 0) ||
                !state.conditions.containsAll(
                  _entryState?.conditions ?? const {},
                )) ||
            state.recipient != _entryState?.recipient ||
            state.embassy != _entryState?.embassy ||
            state.authorityName != (_entryState?.authorityName ?? '') ||
            state.currency != _entryState?.currency ||
            state.name != (_entryState?.name ?? '') ||
            state.surname != (_entryState?.surname ?? '') ||
            state.fatherName != (_entryState?.fatherName ?? '') ||
            state.passportNumber != (_entryState?.passportNumber ?? '') ||
            state.passportExpiryText !=
                (_entryState?.passportExpiryText ?? '') ||
            state.latinAddress != (_entryState?.latinAddress ?? '') ||
            state.address != _entryState?.address ||
            state.deliveryRecipientName !=
                (_entryState?.deliveryRecipientName ?? '') ||
            state.deliveryRecipientNationalId !=
                (_entryState?.deliveryRecipientNationalId ?? '') ||
            state.isIncludeAgent != (_entryState?.isIncludeAgent ?? false) ||
            state.isOtherRecipient !=
                (_entryState?.isOtherRecipient ?? false) ||
            state.agentIdentifier != (_entryState?.agentIdentifier ?? ''));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeFinancialCertificateInteraction() {
    emit(state.copyWith(navigation: null, effect: null));
  }
}
