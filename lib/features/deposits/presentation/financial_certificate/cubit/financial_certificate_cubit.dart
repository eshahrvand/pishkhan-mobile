import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/code_validator.dart';
import 'package:pishkhan_mobile/core/validators/passport_validator.dart';
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';

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
  int _generation = 0, _localAddress = 0;
  String? _key;

  FinancialCertificateState? _entryState;

  void requestAddAddress() {
    emit(
      state.copyWith(
        navigation: null,
        effect: const CertificateAddressRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void addressResult(CertificateAddress? address) {
    if (address == null) return;
    addAddress(address);
  }

  void requestDeleteAddress() {
    if (state.address == null) return;
    emit(
      state.copyWith(
        navigation: null,
        effect: CertificateAddressRemovalRequested(state.address!),
        effectId: state.effectId + 1,
      ),
    );
  }

  void addressRemovalResult(String id, bool? confirmed) {
    if (confirmed != true || state.address?.id != id) return;
    removeAddress();
  }

  void requestAgentLookup() {
    if (state.agentIdentifier.trim().isEmpty) return;
    emit(
      state.copyWith(
        navigation: null,
        effect: const CertificateAgentUnavailable(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestBack() {
    if (back()) return;
    if (state.navigation == FlowNavigation.confirmExit ||
        state.navigation == FlowNavigation.back) {
      return;
    }
    final needsConfirmation =
        state.submissionStatus != RequestStatus.success &&
        state.status == RequestStatus.success &&
        (state.deposit != _entryState?.deposit ||
            (state.conditions.length != (_entryState?.conditions.length ?? 0) ||
                !state.conditions.containsAll(
                  _entryState?.conditions ?? const {},
                )) ||
            state.recipient != _entryState?.recipient ||
            state.embassyId != _entryState?.embassyId ||
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
            state.includeAgent != (_entryState?.includeAgent ?? false) ||
            state.otherRecipient != (_entryState?.otherRecipient ?? false) ||
            state.agentIdentifier != (_entryState?.agentIdentifier ?? ''));
    emit(
      state.copyWith(
        navigation: needsConfirmation
            ? FlowNavigation.confirmExit
            : FlowNavigation.back,
        effect: null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void exitConfirmationResult(bool? confirmed) {
    if (state.navigation != FlowNavigation.confirmExit) return;
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        effect: null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void receiptPresentationClosed() {
    if (state.receipt == null ||
        state.submissionStatus != RequestStatus.success ||
        state.navigation == FlowNavigation.home) {
      return;
    }
    requestHome();
  }

  void requestHome() {
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        effect: null,
        effectId: state.effectId + 1,
      ),
    );
  }

  Future<void> continueFlow() {
    if (!state.canContinue ||
        state.status != RequestStatus.success ||
        state.submissionStatus == RequestStatus.loading ||
        state.submissionStatus == RequestStatus.success) {
      return Future.value();
    }
    if (state.step == FinancialCertificateStep.confirmation) {
      return submit();
    }
    next();
    return Future.value();
  }

  Future<void> load() {
    final generation = ++_generation;
    emit(state.copyWith(status: RequestStatus.loading, failure: null));
    return LoadCertificateCatalog(repository)().then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              status: RequestStatus.failure,
              failure: failure,
              canContinue: false,
            ),
          );
        case Success(:final data):
          final deposit = data.deposits
              .where(
                (d) =>
                    d.id == state.deposit?.id ||
                    (initialDepositNumber != null &&
                        DigitNormalizer.normalize(d.number)
                                .replaceAll(RegExp(r'[^0-9]'), '') ==
                            DigitNormalizer.normalize(initialDepositNumber!)
                                .replaceAll(RegExp(r'[^0-9]'), '')),
              )
              .firstOrNull;
          final total = data.printFeeRial + data.deliveryFeeRial;
          emit(
            _derive(
              state.copyWith(
                status: RequestStatus.success,
                catalog: data,
                deposit: deposit,
                addresses: data.addresses,
                totalRial: total,
                walletSufficient: data.walletBalanceRial >= total,
              ),
            ),
          );
          _entryState = state;
      }
    });
  }

  void selectDeposit(String id) {
    if (state.submissionStatus == RequestStatus.loading) return;
    final deposit =
        state.catalog?.deposits.where((d) => d.id == id).firstOrNull;
    if (deposit == null || deposit == state.deposit) return;
    _key = null;
    emit(
      _derive(
        state.copyWith(
          deposit: deposit,
          conditions: {},
          failure: null,
        ),
      ),
    );
  }

  void toggleConditionSelection(FinancialCertificateCondition condition) {
    toggleCondition(condition, !state.conditions.contains(condition));
  }

  void toggleCondition(FinancialCertificateCondition condition, bool selected) {
    if (state.submissionStatus == RequestStatus.loading ||
        state.deposit == null) {
      return;
    }
    final conditions = {...state.conditions};
    if (selected) {
      conditions.add(condition);
    } else {
      conditions.remove(condition);
    }
    _key = null;
    emit(
      _derive(
        state.copyWith(
          conditions: conditions,
          failure: null,
        ),
      ),
    );
  }

  void selectRecipient(FinancialCertificateRecipient value) {
    if (state.submissionStatus == RequestStatus.loading ||
        value == state.recipient) {
      return;
    }
    _key = null;
    emit(
      _derive(
        state.copyWith(
          recipient: value,
          embassyId: null,
          authorityName: '',
          currency: null,
          failure: null,
        ),
      ),
    );
  }

  void selectEmbassy(String id) {
    if (state.submissionStatus == RequestStatus.loading ||
        state.recipient != FinancialCertificateRecipient.embassy ||
        !(state.catalog?.embassies.any((e) => e.id == id) ?? false)) {
      return;
    }
    _key = null;
    emit(
      _derive(
        state.copyWith(
          embassyId: id,
          authorityName: '',
          failure: null,
        ),
      ),
    );
  }

  void authorityChanged(String value) {
    if (state.submissionStatus == RequestStatus.loading ||
        state.recipient != FinancialCertificateRecipient.otherAuthority) {
      return;
    }
    _key = null;
    emit(
      _derive(
        state.copyWith(
          authorityName: value,
          embassyId: null,
          failure: null,
        ),
      ),
    );
  }

  void selectCurrency(CertificateCurrency value) {
    if (state.submissionStatus == RequestStatus.loading ||
        !(state.catalog?.currencies.contains(value) ?? false)) {
      return;
    }
    _key = null;
    emit(
      _derive(
        state.copyWith(
          currency: value,
          failure: null,
        ),
      ),
    );
  }

  void updateLatinName(String value) => latinChanged(name: value);
  void updateLatinSurname(String value) => latinChanged(surname: value);
  void updateLatinFatherName(String value) => latinChanged(fatherName: value);
  void updatePassportNumber(String value) =>
      latinChanged(passportNumber: value);
  void updatePassportExpiry(String value) => latinChanged(expiry: value);
  void updateLatinAddress(String value) => latinChanged(address: value);

  void latinChanged({
    String? name,
    String? surname,
    String? fatherName,
    String? passportNumber,
    String? expiry,
    String? address,
  }) {
    if (state.submissionStatus == RequestStatus.loading) return;
    final nextName = name ?? state.name;
    final nextSurname = surname ?? state.surname;
    final nextFather = fatherName ?? state.fatherName;
    final nextPassport = DigitNormalizer.normalize(
      passportNumber ?? state.passportNumber,
    );
    final nextExpiry = DigitNormalizer.normalize(
      expiry ?? state.passportExpiryText,
    );
    final nextAddress = address ?? state.latinAddress;
    _key = null;
    emit(
      _derive(
        state.copyWith(
          name: nextName,
          surname: nextSurname,
          fatherName: nextFather,
          passportNumber: nextPassport,
          passportExpiryText: nextExpiry,
          latinAddress: nextAddress,
          failure: null,
        ),
      ),
    );
  }

  void selectAddress(String id) {
    if (state.submissionStatus == RequestStatus.loading) return;
    final address = state.addresses.where((a) => a.id == id).firstOrNull;
    if (address == null) return;
    _key = null;
    emit(
      _derive(
        state.copyWith(
          address: address,
          failure: null,
        ),
      ),
    );
  }

  bool addAddress(CertificateAddress address) {
    if (state.submissionStatus == RequestStatus.loading ||
        address.title.trim().isEmpty ||
        address.detail.trim().isEmpty ||
        !PostalCodeValidator.isValid(address.postalCode)) {
      return false;
    }
    final local = CertificateAddress(
      id: 'local-${++_localAddress}',
      title: address.title.trim(),
      detail: address.detail.trim(),
      postalCode: address.postalCode,
    );
    _key = null;
    emit(
      _derive(
        state.copyWith(
          addresses: [...state.addresses, local],
          address: local,
        ),
      ),
    );
    return true;
  }

  void removeAddress() {
    if (state.submissionStatus == RequestStatus.loading ||
        state.address == null) {
      return;
    }
    _key = null;
    emit(
      _derive(
        state.copyWith(
          addresses:
              state.addresses.where((a) => a.id != state.address!.id).toList(),
          address: null,
        ),
      ),
    );
  }

  void setOtherRecipient(bool value) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    emit(_derive(state.copyWith(otherRecipient: value)));
  }

  void updateRecipientName(String value) =>
      deliveryRecipientChanged(value, state.deliveryRecipientNationalId);

  void updateRecipientNationalId(String value) =>
      deliveryRecipientChanged(state.deliveryRecipientName, value);

  void deliveryRecipientChanged(String name, String nationalId) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    final normalized = DigitNormalizer.normalize(nationalId);
    emit(
      _derive(
        state.copyWith(
          deliveryRecipientName: name,
          deliveryRecipientNationalId: normalized,
        ),
      ),
    );
  }

  void setIncludeAgent(bool value) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    emit(_derive(state.copyWith(includeAgent: value)));
  }

  void agentChanged(String value) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    emit(
      _derive(
        state.copyWith(
          agentIdentifier: DigitNormalizer.normalize(value),
        ),
      ),
    );
  }

  void expandSummary(bool value) =>
      emit(state.copyWith(summaryExpanded: value));

  void expandInvoice(bool value) =>
      emit(state.copyWith(invoiceExpanded: value));

  void next() {
    if (!state.canContinue ||
        state.step == FinancialCertificateStep.confirmation) {
      return;
    }
    final nextStep = FinancialCertificateStep.values[state.step.index + 1];
    emit(_derive(state.copyWith(step: nextStep)));
  }

  bool back() {
    if (state.step == FinancialCertificateStep.conditions) return false;
    emit(
      _derive(
        state.copyWith(
          step: FinancialCertificateStep.values[state.step.index - 1],
          failure: null,
        ),
      ),
    );
    return true;
  }

  Future<void> submit() {
    if (state.step != FinancialCertificateStep.confirmation ||
        !state.canContinue ||
        !state.recipientComplete ||
        !state.latinComplete ||
        !state.walletSufficient ||
        state.submissionStatus == RequestStatus.loading ||
        state.submissionStatus == RequestStatus.success) {
      return Future.value();
    }
    _key ??= List.generate(
      16,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final request = FinancialCertificateRequest(
      depositId: state.deposit!.id,
      conditions: state.conditions,
      recipient: state.recipient!,
      embassyId: state.recipient == FinancialCertificateRecipient.embassy
          ? state.embassyId
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
      deliveryRecipientName: state.otherRecipient
          ? state.deliveryRecipientName.trim()
          : null,
      deliveryRecipientNationalId: state.otherRecipient
          ? state.deliveryRecipientNationalId
          : null,
      agentIdentifier:
          state.includeAgent && state.agentIdentifier.trim().isNotEmpty
              ? state.agentIdentifier
              : null,
      idempotencyKey: _key!,
    );
    final generation = ++_generation;
    emit(
      state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
    );
    return certificateBoundary(
      () => repository.submitFinancialCertificate(request),
    ).then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              failure: failure,
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

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }

  FinancialCertificateState _derive(FinancialCertificateState s) {
    final conditionsComplete = s.deposit != null && s.conditions.isNotEmpty;
    final recipientComplete = s.currency != null &&
        (s.catalog?.currencies.contains(s.currency) ?? false) &&
        (s.recipient == FinancialCertificateRecipient.embassy
            ? (s.catalog?.embassies.any((e) => e.id == s.embassyId) ?? false)
            : s.recipient == FinancialCertificateRecipient.otherAuthority &&
                s.authorityName.trim().isNotEmpty);
    final expiry = PassportValidator.expiry(s.passportExpiryText);
    final latinComplete = PassportValidator.latinName(s.name) &&
        PassportValidator.latinName(s.surname) &&
        PassportValidator.latinName(s.fatherName) &&
        PassportValidator.number(s.passportNumber) &&
        expiry != null &&
        PassportValidator.latinAddress(s.latinAddress);
    final deliveryComplete = s.address != null &&
        (!s.otherRecipient ||
            (s.deliveryRecipientName.trim().isNotEmpty &&
                CodeValidator.isValid(
                  s.deliveryRecipientNationalId,
                  length: 10,
                )));
    final canContinue = conditionsComplete &&
        switch (s.step) {
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
                s.walletSufficient,
        };

    return s.copyWith(
      canCheckAgent: s.agentIdentifier.trim().isNotEmpty,
      recipientComplete: recipientComplete,
      passportExpiry: expiry,
      latinComplete: latinComplete,
      canContinue: canContinue,
    );
  }
}
