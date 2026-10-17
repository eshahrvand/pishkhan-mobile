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
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';

import '../../../domain/entities/certificate_data.dart';
import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/repositories/deposit_certificates_repository.dart';
import '../../../domain/usecases/average_balance.dart';
import '../../shared/certificate_effect.dart';

export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
export '../../shared/certificate_effect.dart';

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

  AverageBalanceState? _entryState;

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
    if (state.step == AverageBalanceStep.confirmation) {
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
          language: null,
          turnover: null,
          fromDate: null,
          toDate: null,
          failure: null,
        ),
      ),
    );
  }

  void selectLanguage(CertificateLanguage value) {
    if (state.submissionStatus == RequestStatus.loading ||
        state.deposit == null) {
      return;
    }
    _key = null;
    emit(_derive(state.copyWith(language: value, failure: null)));
  }

  void selectTurnover(StatementTurnover value) {
    if (state.submissionStatus == RequestStatus.loading ||
        state.deposit == null) {
      return;
    }
    _key = null;
    emit(_derive(state.copyWith(turnover: value, failure: null)));
  }

  void selectAddress(String id) {
    if (state.submissionStatus == RequestStatus.loading) return;
    final address = state.addresses.where((a) => a.id == id).firstOrNull;
    if (address == null) return;
    _key = null;
    emit(_derive(state.copyWith(address: address, failure: null)));
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
      recipientChanged(value, state.recipientNationalId);

  void updateRecipientNationalId(String value) =>
      recipientChanged(state.recipientName, value);

  void recipientChanged(String name, String nationalId) {
    if (state.submissionStatus == RequestStatus.loading) return;
    _key = null;
    final normalized = DigitNormalizer.normalize(nationalId);
    emit(
      _derive(
        state.copyWith(
          recipientName: name,
          recipientNationalId: normalized,
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
    if (!state.canContinue) return;
    if (state.step == AverageBalanceStep.conditions) {
      emit(_derive(state.copyWith(step: AverageBalanceStep.delivery)));
    } else if (state.step == AverageBalanceStep.delivery) {
      emit(_derive(state.copyWith(step: AverageBalanceStep.confirmation)));
    }
  }

  bool back() {
    if (state.step == AverageBalanceStep.conditions) return false;
    emit(
      _derive(
        state.copyWith(
          step: AverageBalanceStep.values[state.step.index - 1],
          failure: null,
        ),
      ),
    );
    return true;
  }

  Future<void> submit() {
    if (state.step != AverageBalanceStep.confirmation ||
        !state.canContinue ||
        state.submissionStatus == RequestStatus.loading ||
        state.submissionStatus == RequestStatus.success) {
      return Future.value();
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
      recipientNationalId:
          state.otherRecipient ? state.recipientNationalId : null,
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
      () => repository.submitAverageBalance(request),
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

  AverageBalanceState _derive(AverageBalanceState s) {
    final canCheckAgent = s.agentIdentifier.trim().isNotEmpty;
    final canContinue = s.deposit != null &&
        s.language != null &&
        s.turnover != null &&
        switch (s.step) {
          AverageBalanceStep.conditions => true,
          AverageBalanceStep.delivery =>
            s.address != null &&
                (!s.otherRecipient ||
                    (s.recipientName.trim().isNotEmpty &&
                        CodeValidator.isValid(
                          s.recipientNationalId,
                          length: 10,
                        ))),
          AverageBalanceStep.confirmation =>
            s.address != null &&
                (!s.otherRecipient ||
                    (s.recipientName.trim().isNotEmpty &&
                        CodeValidator.isValid(
                          s.recipientNationalId,
                          length: 10,
                        ))) &&
                s.walletSufficient,
        };

    return s.copyWith(
      canCheckAgent: canCheckAgent,
      canContinue: canContinue,
    );
  }
}
