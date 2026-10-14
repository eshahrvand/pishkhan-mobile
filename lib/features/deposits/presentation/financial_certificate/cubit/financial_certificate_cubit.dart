import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/listed_deposit.dart';

import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/passport_validator.dart';
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../../domain/entities/financial_certificate_data.dart';
import '../../../domain/repositories/financial_certificate_repository.dart';
import '../../../domain/usecases/average_balance.dart';

part 'financial_certificate_state.dart';
part 'financial_certificate_cubit.freezed.dart';

class FinancialCertificateCubit extends Cubit<FinancialCertificateState> {
  FinancialCertificateCubit({
    required this.repository,
    this.initialDepositNumber,
    FinancialCertificateState initialState =
        const FinancialCertificateState.initial(),
  }) : super(initialState);
  final FinancialCertificateRepository repository;
  final String? initialDepositNumber;
  int _generation = 0, _localAddress = 0;
  String? _key;

  Future<void> load() async {
    if (isClosed || state.submissionStatus == RequestStatus.loading) return;
    final generation = ++_generation;
    emit(state.copyWith(status: RequestStatus.loading, failure: null));
    final result = await LoadCertificateCatalog(repository)();
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
        final recipientComplete =
            state.currency != null &&
            data.currencies.contains(state.currency) &&
            (state.recipient == FinancialCertificateRecipient.embassy
                ? data.embassies.any((e) => e.id == state.embassyId)
                : state.recipient ==
                          FinancialCertificateRecipient.otherAuthority &&
                      state.authorityName.trim().isNotEmpty);
        final expiry = PassportValidator.expiry(state.passportExpiryText);
        final latinComplete =
            PassportValidator.latinName(state.name) &&
            PassportValidator.latinName(state.surname) &&
            PassportValidator.latinName(state.fatherName) &&
            PassportValidator.number(state.passportNumber) &&
            expiry != null &&
            PassportValidator.latinAddress(state.latinAddress);
        final deliveryComplete =
            state.address != null &&
            (!state.otherRecipient ||
                (state.deliveryRecipientName.trim().isNotEmpty &&
                    RegExp(r'^[0-9]{10}$')
                        .hasMatch(state.deliveryRecipientNationalId)));
        final total = data.printFeeRial + data.deliveryFeeRial;
        emit(
          state.copyWith(
            status: RequestStatus.success,
            catalog: data,
            deposit: deposit,
            addresses: data.addresses,
            totalRial: total,
            walletSufficient: data.walletBalanceRial >= total,
            recipientComplete: recipientComplete,
            latinComplete: latinComplete,
            passportExpiry: expiry,
            canContinue:
                deposit != null &&
                state.conditions.isNotEmpty &&
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
                        data.walletBalanceRial >= total,
                },
          ),
        );
    }
  }

  void selectDeposit(String id) {
    if (state.status != RequestStatus.success ||
        state.submissionStatus == RequestStatus.loading) {
      return;
    }
    final deposit = state.catalog?.deposits
        .where((d) => d.id == id)
        .firstOrNull;
    if (deposit == null || deposit == state.deposit) return;
    _key = null;
    emit(
      state.copyWith(
        deposit: deposit,
        conditions: {},
        canContinue: false,
        failure: null,
      ),
    );
  }

  void toggleCondition(FinancialCertificateCondition condition, bool selected) {
    if (state.deposit == null ||
        state.submissionStatus == RequestStatus.loading) {
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
      state.copyWith(
        conditions: conditions,
        canContinue: conditions.isNotEmpty,
        failure: null,
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
      state.copyWith(
        recipient: value,
        embassyId: null,
        authorityName: '',
        currency: null,
        recipientComplete: false,
        canContinue: false,
        failure: null,
      ),
    );
  }

  void selectEmbassy(String id) {
    if (state.submissionStatus == RequestStatus.loading ||
        state.recipient != FinancialCertificateRecipient.embassy ||
        !state.catalog!.embassies.any((e) => e.id == id)) {
      return;
    }
    _key = null;
    emit(
      state.copyWith(
        embassyId: id,
        authorityName: '',
        recipientComplete: state.currency != null,
        canContinue: state.currency != null,
        failure: null,
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
      state.copyWith(
        authorityName: value,
        embassyId: null,
        recipientComplete: value.trim().isNotEmpty && state.currency != null,
        canContinue: value.trim().isNotEmpty && state.currency != null,
        failure: null,
      ),
    );
  }

  void selectCurrency(CertificateCurrency value) {
    if (state.submissionStatus == RequestStatus.loading ||
        !state.catalog!.currencies.contains(value)) {
      return;
    }
    final complete = state.recipient == FinancialCertificateRecipient.embassy
        ? state.embassyId != null
        : state.recipient == FinancialCertificateRecipient.otherAuthority &&
              state.authorityName.trim().isNotEmpty;
    _key = null;
    emit(
      state.copyWith(
        currency: value,
        recipientComplete: complete,
        canContinue: complete,
        failure: null,
      ),
    );
  }

  void latinChanged({
    String? name,
    String? surname,
    String? fatherName,
    String? passportNumber,
    String? expiry,
    String? address,
  }) {
    if (state.submissionStatus == RequestStatus.loading) return;
    final nextName = name ?? state.name,
        nextSurname = surname ?? state.surname,
        nextFather = fatherName ?? state.fatherName,
        nextPassport = DigitNormalizer.normalize(
          passportNumber ?? state.passportNumber,
        ),
        nextExpiry = DigitNormalizer.normalize(
          expiry ?? state.passportExpiryText,
        ),
        nextAddress = address ?? state.latinAddress;
    final parsedExpiry = PassportValidator.expiry(nextExpiry);
    final complete =
        PassportValidator.latinName(nextName) &&
        PassportValidator.latinName(nextSurname) &&
        PassportValidator.latinName(nextFather) &&
        PassportValidator.number(nextPassport) &&
        parsedExpiry != null &&
        PassportValidator.latinAddress(nextAddress);
    _key = null;
    emit(
      state.copyWith(
        name: nextName,
        surname: nextSurname,
        fatherName: nextFather,
        passportNumber: nextPassport,
        passportExpiryText: nextExpiry,
        passportExpiry: parsedExpiry,
        latinAddress: nextAddress,
        latinComplete: complete,
        canContinue: complete,
        failure: null,
      ),
    );
  }

  void selectAddress(String id) {
    if (state.submissionStatus == RequestStatus.loading) return;
    final address = state.addresses.where((a) => a.id == id).firstOrNull;
    if (address == null) return;
    _key = null;
    emit(
      state.copyWith(
        address: address,
        canContinue:
            !state.otherRecipient ||
            (state.deliveryRecipientName.trim().isNotEmpty &&
                RegExp(r'^[0-9]{10}$')
                    .hasMatch(state.deliveryRecipientNationalId)),
        failure: null,
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
      state.copyWith(
        addresses: [...state.addresses, local],
        address: local,
        canContinue:
            !state.otherRecipient ||
            (state.deliveryRecipientName.trim().isNotEmpty &&
                RegExp(r'^[0-9]{10}$')
                    .hasMatch(state.deliveryRecipientNationalId)),
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
      state.copyWith(
        addresses: state.addresses
            .where((a) => a.id != state.address!.id)
            .toList(),
        address: null,
        canContinue: false,
      ),
    );
  }

  void setOtherRecipient(bool value) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    emit(
      state.copyWith(
        otherRecipient: value,
        canContinue:
            state.address != null &&
            (!value ||
                (state.deliveryRecipientName.trim().isNotEmpty &&
                    RegExp(r'^[0-9]{10}$')
                        .hasMatch(state.deliveryRecipientNationalId))),
      ),
    );
  }

  void deliveryRecipientChanged(String name, String nationalId) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    final normalized = DigitNormalizer.normalize(nationalId);
    emit(
      state.copyWith(
        deliveryRecipientName: name,
        deliveryRecipientNationalId: normalized,
        canContinue:
            state.address != null &&
            (!state.otherRecipient ||
                (name.trim().isNotEmpty &&
                    RegExp(r'^[0-9]{10}$').hasMatch(normalized))),
      ),
    );
  }

  void setIncludeAgent(bool value) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    emit(state.copyWith(includeAgent: value));
  }

  void agentChanged(String value) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    emit(state.copyWith(agentIdentifier: DigitNormalizer.normalize(value)));
  }

  void expandSummary(bool value) =>
      emit(state.copyWith(summaryExpanded: value));
  void expandInvoice(bool value) =>
      emit(state.copyWith(invoiceExpanded: value));
  void next() {
    if (!state.canContinue ||
        state.submissionStatus == RequestStatus.loading ||
        state.step == FinancialCertificateStep.confirmation) {
      return;
    }
    final next = FinancialCertificateStep.values[state.step.index + 1];
    emit(
      state.copyWith(
        step: next,
        canContinue: switch (next) {
          FinancialCertificateStep.conditions =>
            state.deposit != null && state.conditions.isNotEmpty,
          FinancialCertificateStep.recipient => state.recipientComplete,
          FinancialCertificateStep.latinIdentity => state.latinComplete,
          FinancialCertificateStep.delivery =>
            state.address != null &&
                (!state.otherRecipient ||
                    (state.deliveryRecipientName.trim().isNotEmpty &&
                        RegExp(r'^[0-9]{10}$')
                            .hasMatch(state.deliveryRecipientNationalId))),
          FinancialCertificateStep.confirmation => state.walletSufficient,
        },
      ),
    );
  }

  bool back() {
    if (state.submissionStatus == RequestStatus.loading) return true;
    if (state.step == FinancialCertificateStep.conditions) return false;
    emit(
      state.copyWith(
        step: FinancialCertificateStep.values[state.step.index - 1],
        canContinue: true,
        failure: null,
      ),
    );
    return true;
  }

  Future<void> submit() async {
    if (state.step != FinancialCertificateStep.confirmation ||
        !state.canContinue ||
        !state.recipientComplete ||
        !state.latinComplete ||
        !state.walletSufficient ||
        state.submissionStatus == RequestStatus.loading ||
        state.submissionStatus == RequestStatus.success) {
      return;
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
    final result = await certificateBoundary(
      () => repository.submitFinancialCertificate(request),
    );
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
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
