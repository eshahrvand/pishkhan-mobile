import 'package:pishkhan_mobile/core/di/injection_container.dart';

import '../../shared/certificate_effect.dart';
export '../../shared/certificate_effect.dart';

import 'package:pishkhan_mobile/core/validators/code_validator.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/listed_deposit.dart';

import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../../domain/repositories/deposit_certificates_repository.dart';
import '../../../domain/usecases/average_balance.dart';

part 'average_balance_state.dart';
part 'average_balance_cubit.freezed.dart';

class AverageBalanceCubit extends Cubit<AverageBalanceState> {
  AverageBalanceCubit({
    this.initialDepositNumber,
    AverageBalanceState initialState = const AverageBalanceState.initial(),
  }) : super(initialState);
  final repository = getIt<DepositCertificatesRepository>();
  final String? initialDepositNumber;
  int _generation = 0, _localAddress = 0;
  String? _key;

  void requestAddAddress() {
    if (isClosed || state.submissionStatus == RequestStatus.loading) return;
    emit(
      state.copyWith(
        navigation: null,
        effect: const CertificateAddressRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void addressResult(CertificateAddress? address) {
    if (isClosed || address == null) return;
    addAddress(address);
  }

  void requestDeleteAddress() {
    if (isClosed ||
        state.address == null ||
        state.submissionStatus == RequestStatus.loading) {
      return;
    }
    emit(
      state.copyWith(
        navigation: null,
        effect: CertificateAddressRemovalRequested(state.address!),
        effectId: state.effectId + 1,
      ),
    );
  }

  void addressRemovalResult(String id, bool? confirmed) {
    if (isClosed || confirmed != true || state.address?.id != id) return;
    removeAddress();
  }

  void requestAgentLookup() {
    if (isClosed ||
        state.agentIdentifier.trim().isEmpty ||
        state.submissionStatus == RequestStatus.loading) {
      return;
    }
    emit(
      state.copyWith(
        navigation: null,
        effect: const CertificateAgentUnavailable(),
        effectId: state.effectId + 1,
      ),
    );
  }

  // Loaded entry snapshot, retained only to detect discardable user edits.
  AverageBalanceState? _entryState;

  void requestBack() {
    if (isClosed || state.submissionStatus == RequestStatus.loading) return;
    if (back()) return;
    if (state.navigation == FlowNavigation.confirmExit ||
        state.navigation == FlowNavigation.back) {
      return;
    }
    final needsConfirmation =
        state.submissionStatus != RequestStatus.success &&
        state.status == RequestStatus.success &&
        (state.deposit != _entryState?.deposit ||
            state.language != _entryState?.language ||
            state.turnover != _entryState?.turnover ||
            state.fromDate != _entryState?.fromDate ||
            state.toDate != _entryState?.toDate ||
            state.address != _entryState?.address ||
            state.recipientName != (_entryState?.recipientName ?? '') ||
            state.recipientNationalId !=
                (_entryState?.recipientNationalId ?? '') ||
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
    if (isClosed ||
        state.navigation != FlowNavigation.confirmExit ||
        state.submissionStatus == RequestStatus.loading) {
      return;
    }
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        effect: null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void receiptPresentationClosed() {
    if (isClosed ||
        state.receipt == null ||
        state.submissionStatus != RequestStatus.success ||
        state.navigation == FlowNavigation.home) {
      return;
    }
    requestHome();
  }

  void requestHome() {
    if (isClosed || state.submissionStatus == RequestStatus.loading) return;
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        effect: null,
        effectId: state.effectId + 1,
      ),
    );
  }

  Future<void> continueFlow() async {
    if (isClosed ||
        !state.canContinue ||
        state.status != RequestStatus.success ||
        state.submissionStatus == RequestStatus.loading ||
        state.submissionStatus == RequestStatus.success) {
      return;
    }
    if (state.step == AverageBalanceStep.confirmation) {
      await submit();
    } else {
      next();
    }
  }

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
            canCheckAgent: state.agentIdentifier.trim().isNotEmpty,
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
                                CodeValidator.isValid(
                                  state.recipientNationalId,
                                  length: 10,
                                ))),
                  AverageBalanceStep.confirmation =>
                    state.address != null &&
                        (!state.otherRecipient ||
                            (state.recipientName.trim().isNotEmpty &&
                                CodeValidator.isValid(
                                  state.recipientNationalId,
                                  length: 10,
                                ))) &&
                        data.walletBalanceRial >= total,
                },
          ),
        );
    }
    if (!isClosed && state.status == RequestStatus.success) _entryState = state;
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
                CodeValidator.isValid(state.recipientNationalId, length: 10)),
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
                CodeValidator.isValid(state.recipientNationalId, length: 10)),
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
                    CodeValidator.isValid(
                      state.recipientNationalId,
                      length: 10,
                    ))),
      ),
    );
  }

  void updateRecipientName(String value) =>
      recipientChanged(value, state.recipientNationalId);
  void updateRecipientNationalId(String value) =>
      recipientChanged(state.recipientName, value);

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
                    CodeValidator.isValid(normalized, length: 10))),
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
    emit(
      state.copyWith(
        agentIdentifier: DigitNormalizer.normalize(value),
        canCheckAgent: value.trim().isNotEmpty,
      ),
    );
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
                      CodeValidator.isValid(
                        state.recipientNationalId,
                        length: 10,
                      ))),
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
