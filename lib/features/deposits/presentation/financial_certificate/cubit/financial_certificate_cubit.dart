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
import '../../../domain/usecases/average_balance.dart';
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
  final String? initialDepositNumber;
  int _localAddress = 0;
  // The last sent payload owns its key; editing the form does not create a request.
  FinancialCertificateRequest? _submittedRequest;

  FinancialCertificateState? _entryState;

  void requestAddAddress() {
    emit(
      state.copyWith(
        effect: const CertificateAddressRequested(),
        message: null,
      ),
    );
  }

  void applyAddressSelection(CertificateAddress? address) {
    if (address != null) addAddress(address);
  }

  void requestDeleteAddress() {
    emit(
      state.copyWith(
        effect: CertificateAddressRemovalRequested(state.address!),
        message: null,
      ),
    );
  }

  void requestAgentLookup() {
    emit(
      state.copyWith(
        effect: const CertificateAgentUnavailable(),
        message: null,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        effect: null,
        message: null,
      ),
    );
  }

  void requestHome() {
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        effect: null,
        message: null,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        effect: null,
        message: null,
      ),
    );
  }

  void requestBack() {
    switch (state.step) {
      case FinancialCertificateStep.confirmation:
        emit(
          state.copyWith(
            step: FinancialCertificateStep.delivery,
            stepNumber: 4,
            canContinue:
                state.address != null &&
                (!state.isOtherRecipient ||
                    (state.isRecipientNameValid &&
                        state.isRecipientNationalIdValid)),
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
            canContinue: state.deposit != null && state.conditions.isNotEmpty,
          ),
        );
      case FinancialCertificateStep.conditions:
        final needsConfirmation =
            state.submissionStatus != RequestStatus.success &&
            state.catalogStatus == RequestStatus.success &&
            (state.deposit != _entryState?.deposit ||
                (state.conditions.length !=
                        (_entryState?.conditions.length ?? 0) ||
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
                state.isIncludeAgent !=
                    (_entryState?.isIncludeAgent ?? false) ||
                state.isOtherRecipient !=
                    (_entryState?.isOtherRecipient ?? false) ||
                state.agentIdentifier != (_entryState?.agentIdentifier ?? ''));
        emit(
          state.copyWith(
            navigation: needsConfirmation
                ? FlowNavigation.confirmExit
                : FlowNavigation.back,
            effect: null,
            message: null,
          ),
        );
    }
  }

  Future<void> continueFlow() {
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
            canContinue:
                state.address != null &&
                (!state.isOtherRecipient ||
                    (state.isRecipientNameValid &&
                        state.isRecipientNationalIdValid)),
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
        return submitCertificate();
    }
    return Future.value();
  }

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        canContinue: false,
        failure: null,
        message: null,
      ),
    );
    return LoadCertificateCatalog(repository)().then((result) {
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
          final number = DigitNormalizer.normalize(initialDepositNumber ?? '')
              .replaceAll(RegExp(r'[^0-9]'), '');
          final deposit = data.deposits
              .where(
                (deposit) =>
                    deposit.id == state.deposit?.id ||
                    (number.isNotEmpty &&
                        DigitNormalizer.normalize(deposit.number)
                                .replaceAll(RegExp(r'[^0-9]'), '') ==
                            number),
              )
              .firstOrNull;
          final total = data.printFeeRial + data.deliveryFeeRial;
          final sufficient = data.walletBalanceRial >= total;
          final nameValid = PassportValidator.latinName(state.name);
          final surnameValid = PassportValidator.latinName(state.surname);
          final fatherValid = PassportValidator.latinName(state.fatherName);
          final passportValid = PassportValidator.number(state.passportNumber);
          final expiry = PassportValidator.expiry(state.passportExpiryText);
          final addressValid = PassportValidator.latinAddress(
            state.latinAddress,
          );
          final latinComplete =
              nameValid &&
              surnameValid &&
              fatherValid &&
              passportValid &&
              expiry != null &&
              addressValid;
          final authorityValid = state.authorityName.trim().isNotEmpty;
          final recipientComplete =
              state.currency != null &&
              switch (state.recipient) {
                FinancialCertificateRecipient.embassy => state.embassy != null,
                FinancialCertificateRecipient.otherAuthority => authorityValid,
                null => false,
              };
          final deliveryNameValid = state.deliveryRecipientName
              .trim()
              .isNotEmpty;
          final nationalIdValid = NationalCodeValidator.isValid(
            state.deliveryRecipientNationalId,
          );
          final conditionsComplete =
              deposit != null && state.conditions.isNotEmpty;
          final deliveryComplete =
              state.address != null &&
              (!state.isOtherRecipient ||
                  (deliveryNameValid && nationalIdValid));
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              deposit: deposit,
              addresses: data.addresses,
              totalRial: total,
              isWalletSufficient: sufficient,
              isLatinNameValid: nameValid,
              isLatinSurnameValid: surnameValid,
              isLatinFatherNameValid: fatherValid,
              isPassportNumberValid: passportValid,
              passportExpiry: expiry,
              isLatinAddressValid: addressValid,
              isLatinComplete: latinComplete,
              isAuthorityNameValid: authorityValid,
              isRecipientComplete: recipientComplete,
              isRecipientNameValid: deliveryNameValid,
              isRecipientNationalIdValid: nationalIdValid,
              canCheckAgent: state.agentIdentifier.trim().isNotEmpty,
              stepNumber: state.step.index + 1,
              canContinue:
                  conditionsComplete &&
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
                          sufficient,
                  },
            ),
          );
          _entryState = state;
      }
    });
  }

  void selectDeposit(ListedDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        conditions: {},
        canContinue: false,
        failure: null,
        message: null,
      ),
    );
  }

  void toggleCondition(FinancialCertificateCondition condition) {
    final conditions = {...state.conditions};
    if (!conditions.remove(condition)) conditions.add(condition);
    emit(
      state.copyWith(
        conditions: conditions,
        canContinue: conditions.isNotEmpty,
        failure: null,
        message: null,
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
        failure: null,
        message: null,
      ),
    );
  }

  void selectEmbassy(CertificateEmbassy embassy) {
    final complete = state.currency != null;
    emit(
      state.copyWith(
        embassy: embassy,
        isRecipientComplete: complete,
        canContinue: complete,
        failure: null,
        message: null,
      ),
    );
  }

  void updateAuthorityName(String value) {
    final valid = value.trim().isNotEmpty;
    final complete = valid && state.currency != null;
    emit(
      state.copyWith(
        authorityName: value,
        isAuthorityNameValid: valid,
        isRecipientComplete: complete,
        canContinue: complete,
        failure: null,
        message: null,
      ),
    );
  }

  void selectCurrency(CertificateCurrency currency) {
    final complete = switch (state.recipient) {
      FinancialCertificateRecipient.embassy => state.embassy != null,
      FinancialCertificateRecipient.otherAuthority =>
        state.isAuthorityNameValid,
      null => false,
    };
    emit(
      state.copyWith(
        currency: currency,
        isRecipientComplete: complete,
        canContinue: complete,
        failure: null,
        message: null,
      ),
    );
  }

  void updateLatinName(String value) {
    final valid = PassportValidator.latinName(value);
    final complete =
        valid &&
        state.isLatinSurnameValid &&
        state.isLatinFatherNameValid &&
        state.isPassportNumberValid &&
        state.passportExpiry != null &&
        state.isLatinAddressValid;
    emit(
      state.copyWith(
        name: value,
        isLatinNameValid: valid,
        isLatinComplete: complete,
        canContinue: complete,
        failure: null,
        message: null,
      ),
    );
  }

  void updateLatinSurname(String value) {
    final valid = PassportValidator.latinName(value);
    final complete =
        state.isLatinNameValid &&
        valid &&
        state.isLatinFatherNameValid &&
        state.isPassportNumberValid &&
        state.passportExpiry != null &&
        state.isLatinAddressValid;
    emit(
      state.copyWith(
        surname: value,
        isLatinSurnameValid: valid,
        isLatinComplete: complete,
        canContinue: complete,
        failure: null,
        message: null,
      ),
    );
  }

  void updateLatinFatherName(String value) {
    final valid = PassportValidator.latinName(value);
    final complete =
        state.isLatinNameValid &&
        state.isLatinSurnameValid &&
        valid &&
        state.isPassportNumberValid &&
        state.passportExpiry != null &&
        state.isLatinAddressValid;
    emit(
      state.copyWith(
        fatherName: value,
        isLatinFatherNameValid: valid,
        isLatinComplete: complete,
        canContinue: complete,
        failure: null,
        message: null,
      ),
    );
  }

  void updatePassportNumber(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final valid = PassportValidator.number(normalized);
    final complete =
        state.isLatinNameValid &&
        state.isLatinSurnameValid &&
        state.isLatinFatherNameValid &&
        valid &&
        state.passportExpiry != null &&
        state.isLatinAddressValid;
    emit(
      state.copyWith(
        passportNumber: normalized,
        isPassportNumberValid: valid,
        isLatinComplete: complete,
        canContinue: complete,
        failure: null,
        message: null,
      ),
    );
  }

  void updatePassportExpiry(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final expiry = PassportValidator.expiry(normalized);
    final complete =
        state.isLatinNameValid &&
        state.isLatinSurnameValid &&
        state.isLatinFatherNameValid &&
        state.isPassportNumberValid &&
        expiry != null &&
        state.isLatinAddressValid;
    emit(
      state.copyWith(
        passportExpiryText: normalized,
        passportExpiry: expiry,
        isLatinComplete: complete,
        canContinue: complete,
        failure: null,
        message: null,
      ),
    );
  }

  void updateLatinAddress(String value) {
    final valid = PassportValidator.latinAddress(value);
    final complete =
        state.isLatinNameValid &&
        state.isLatinSurnameValid &&
        state.isLatinFatherNameValid &&
        state.isPassportNumberValid &&
        state.passportExpiry != null &&
        valid;
    emit(
      state.copyWith(
        latinAddress: value,
        isLatinAddressValid: valid,
        isLatinComplete: complete,
        canContinue: complete,
        failure: null,
        message: null,
      ),
    );
  }

  void selectAddress(CertificateAddress address) {
    emit(
      state.copyWith(
        address: address,
        canContinue:
            !state.isOtherRecipient ||
            (state.isRecipientNameValid && state.isRecipientNationalIdValid),
        failure: null,
        message: null,
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
        canContinue:
            !state.isOtherRecipient ||
            (state.isRecipientNameValid && state.isRecipientNationalIdValid),
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
        canContinue:
            state.address != null &&
            (!value ||
                (state.isRecipientNameValid &&
                    state.isRecipientNationalIdValid)),
      ),
    );
  }

  void updateRecipientName(String value) {
    final valid = value.trim().isNotEmpty;
    emit(
      state.copyWith(
        deliveryRecipientName: value,
        isRecipientNameValid: valid,
        canContinue:
            state.address != null &&
            (!state.isOtherRecipient ||
                (valid && state.isRecipientNationalIdValid)),
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
        canContinue:
            state.address != null &&
            (!state.isOtherRecipient || (state.isRecipientNameValid && valid)),
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
        canCheckAgent: normalized.trim().isNotEmpty,
      ),
    );
  }

  void updateSummaryExpanded(bool value) {
    emit(state.copyWith(isSummaryExpanded: value));
  }

  void updateInvoiceExpanded(bool value) {
    emit(state.copyWith(isInvoiceExpanded: value));
  }

  Future<void> submitCertificate() {
    var request = _createRequest(_submittedRequest?.idempotencyKey);
    if (_submittedRequest != null && request != _submittedRequest) {
      request = _createRequest(null);
    }
    _submittedRequest = request;
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return certificateBoundary(
      () => repository.submitFinancialCertificate(request),
    ).then((result) {
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
    });
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
          state.isIncludeAgent && state.agentIdentifier.trim().isNotEmpty
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

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeFinancialCertificateInteraction() {
    emit(state.copyWith(navigation: null, effect: null));
  }
}
