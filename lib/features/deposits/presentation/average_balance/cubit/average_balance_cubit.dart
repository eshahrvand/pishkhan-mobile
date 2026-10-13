import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../../domain/repositories/deposit_certificates_repository.dart';
import '../../../domain/usecases/average_balance.dart';
import 'average_balance_state.dart';
export 'average_balance_state.dart';

class AverageBalanceCubit extends Cubit<AverageBalanceState> {
  AverageBalanceCubit({
    required this.repository,
    this.initialDepositNumber,
    AverageBalanceState initialState = const AverageBalanceState(),
  }) : super(initialState);
  final DepositCertificatesRepository repository;
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
        final total = data.printFeeRial + data.deliveryFeeRial;
        emit(
          state.copyWith(
            status: RequestStatus.success,
            catalog: data,
            deposit: deposit,
            addresses: data.addresses,
            totalRial: total,
            walletSufficient: data.walletBalanceRial >= total,
            canContinue:
                deposit != null &&
                state.language != null &&
                state.turnover != null &&
                switch (state.step) {
                  AverageBalanceStep.conditions => true,
                  AverageBalanceStep.delivery =>
                    state.address != null &&
                        (!state.otherRecipient ||
                            (state.recipientName.trim().isNotEmpty &&
                                RegExp(r'^[0-9]{10}$')
                                    .hasMatch(state.recipientNationalId))),
                  AverageBalanceStep.confirmation =>
                    state.address != null &&
                        (!state.otherRecipient ||
                            (state.recipientName.trim().isNotEmpty &&
                                RegExp(r'^[0-9]{10}$')
                                    .hasMatch(state.recipientNationalId))) &&
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
        language: null,
        turnover: null,
        fromDate: null,
        toDate: null,
        canContinue: false,
        failure: null,
      ),
    );
  }

  void selectLanguage(CertificateLanguage value) {
    if (state.submissionStatus == RequestStatus.loading ||
        state.deposit == null) {
      return;
    }
    _key = null;
    emit(
      state.copyWith(
        language: value,
        canContinue: state.turnover != null,
        failure: null,
      ),
    );
  }

  void selectTurnover(StatementTurnover value) {
    if (state.submissionStatus == RequestStatus.loading ||
        state.deposit == null) {
      return;
    }
    _key = null;
    emit(
      state.copyWith(
        turnover: value,
        canContinue: state.language != null,
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
            (state.recipientName.trim().isNotEmpty &&
                RegExp(r'^[0-9]{10}$').hasMatch(state.recipientNationalId)),
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
            (state.recipientName.trim().isNotEmpty &&
                RegExp(r'^[0-9]{10}$').hasMatch(state.recipientNationalId)),
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
                (state.recipientName.trim().isNotEmpty &&
                    RegExp(r'^[0-9]{10}$')
                        .hasMatch(state.recipientNationalId))),
      ),
    );
  }

  void recipientChanged(String name, String nationalId) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    final normalized = DigitNormalizer.normalize(nationalId);
    emit(
      state.copyWith(
        recipientName: name,
        recipientNationalId: normalized,
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
    if (!state.canContinue || state.submissionStatus == RequestStatus.loading) {
      return;
    }
    if (state.step == AverageBalanceStep.conditions) {
      emit(
        state.copyWith(
          step: AverageBalanceStep.delivery,
          canContinue:
              state.address != null &&
              (!state.otherRecipient ||
                  (state.recipientName.trim().isNotEmpty &&
                      RegExp(r'^[0-9]{10}$')
                          .hasMatch(state.recipientNationalId))),
        ),
      );
    } else if (state.step == AverageBalanceStep.delivery) {
      emit(
        state.copyWith(
          step: AverageBalanceStep.confirmation,
          canContinue: state.walletSufficient,
        ),
      );
    }
  }

  bool back() {
    if (state.submissionStatus == RequestStatus.loading) return true;
    if (state.step == AverageBalanceStep.conditions) return false;
    emit(
      state.copyWith(
        step: AverageBalanceStep.values[state.step.index - 1],
        canContinue: true,
        failure: null,
      ),
    );
    return true;
  }

  Future<void> submit() async {
    if (state.step != AverageBalanceStep.confirmation ||
        !state.canContinue ||
        state.submissionStatus == RequestStatus.loading ||
        state.submissionStatus == RequestStatus.success) {
      return;
    }
    _key ??= List.generate(
      16,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final request = AverageBalanceRequest(
      depositId: state.deposit!.id,
      language: state.language!,
      turnover: state.turnover!,
      address: state.address!,
      fromDate: state.fromDate?.toUtc(),
      toDate: state.toDate?.toUtc(),
      recipientName: state.otherRecipient ? state.recipientName.trim() : null,
      recipientNationalId: state.otherRecipient
          ? state.recipientNationalId
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
      () => repository.submitAverageBalance(request),
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
