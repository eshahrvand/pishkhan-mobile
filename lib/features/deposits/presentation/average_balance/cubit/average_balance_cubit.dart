import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/national_code_validator.dart';

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
  int _localAddress = 0;
  String? _key;

  AverageBalanceState? _entryState;

  void requestAddAddress() {
    emit(
      state.copyWith(
        effect: const CertificateAddressRequested(),
        effectId: state.effectId + 1,
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
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestAgentLookup() {
    emit(
      state.copyWith(
        effect: const CertificateAgentUnavailable(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestBack() {
    switch (state.step) {
      case AverageBalanceStep.confirmation:
        emit(
          state.copyWith(
            step: AverageBalanceStep.delivery,
            stepNumber: 2,
            progress: .6,
            canContinue:
                state.address != null &&
                (!state.isOtherRecipient ||
                    (state.isRecipientNameValid &&
                        state.isRecipientNationalIdValid)),
          ),
        );
      case AverageBalanceStep.delivery:
        emit(
          state.copyWith(
            step: AverageBalanceStep.conditions,
            stepNumber: 1,
            progress: .3,
            canContinue:
                state.deposit != null &&
                state.language != null &&
                state.turnover != null,
          ),
        );
      case AverageBalanceStep.conditions:
        final needsConfirmation =
            state.submissionStatus != RequestStatus.success &&
            state.catalogStatus == RequestStatus.success &&
            (state.deposit != _entryState?.deposit ||
                state.language != _entryState?.language ||
                state.turnover != _entryState?.turnover ||
                state.fromDate != _entryState?.fromDate ||
                state.toDate != _entryState?.toDate ||
                state.address != _entryState?.address ||
                state.recipientName != (_entryState?.recipientName ?? '') ||
                state.recipientNationalId !=
                    (_entryState?.recipientNationalId ?? '') ||
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
            effectId: state.effectId + 1,
          ),
        );
    }
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        effect: null,
        effectId: state.effectId + 1,
      ),
    );
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

  void applyReceiptDismissal() {
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        effect: null,
        effectId: state.effectId + 1,
      ),
    );
  }

  Future<void> continueFlow() {
    switch (state.step) {
      case AverageBalanceStep.conditions:
        emit(
          state.copyWith(
            step: AverageBalanceStep.delivery,
            stepNumber: 2,
            progress: .6,
            canContinue:
                state.address != null &&
                (!state.isOtherRecipient ||
                    (state.isRecipientNameValid &&
                        state.isRecipientNationalIdValid)),
          ),
        );
      case AverageBalanceStep.delivery:
        emit(
          state.copyWith(
            step: AverageBalanceStep.confirmation,
            stepNumber: 3,
            progress: 1,
            canContinue: state.isWalletSufficient,
          ),
        );
      case AverageBalanceStep.confirmation:
        return submitCertificate();
    }
    return Future.value();
  }

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        catalogFailure: null,
        canContinue: false,
      ),
    );
    return LoadCertificateCatalog(repository)().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.failure,
              catalogFailure: failure,
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
          final nameValid = state.recipientName.trim().isNotEmpty;
          final nationalIdValid = NationalCodeValidator.isValid(
            state.recipientNationalId,
          );
          final conditionsComplete =
              deposit != null &&
              state.language != null &&
              state.turnover != null;
          final deliveryComplete =
              state.address != null &&
              (!state.isOtherRecipient || (nameValid && nationalIdValid));
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              deposit: deposit,
              addresses: data.addresses,
              totalRial: total,
              isWalletSufficient: sufficient,
              isRecipientNameValid: nameValid,
              isRecipientNationalIdValid: nationalIdValid,
              canCheckAgent: state.agentIdentifier.trim().isNotEmpty,
              stepNumber: state.step.index + 1,
              progress: switch (state.step) {
                AverageBalanceStep.conditions => .3,
                AverageBalanceStep.delivery => .6,
                AverageBalanceStep.confirmation => 1,
              },
              canContinue:
                  conditionsComplete &&
                  switch (state.step) {
                    AverageBalanceStep.conditions => true,
                    AverageBalanceStep.delivery => deliveryComplete,
                    AverageBalanceStep.confirmation =>
                      deliveryComplete && sufficient,
                  },
            ),
          );
          _entryState = state;
      }
    });
  }

  void selectDeposit(ListedDeposit deposit) {
    _key = null;
    emit(
      state.copyWith(
        deposit: deposit,
        language: null,
        turnover: null,
        fromDate: null,
        toDate: null,
        submissionFailure: null,
        canContinue: false,
      ),
    );
  }

  void selectLanguage(CertificateLanguage language) {
    _key = null;
    emit(
      state.copyWith(
        language: language,
        submissionFailure: null,
        canContinue: state.turnover != null,
      ),
    );
  }

  void selectTurnover(StatementTurnover turnover) {
    _key = null;
    emit(
      state.copyWith(
        turnover: turnover,
        submissionFailure: null,
        canContinue: state.language != null,
      ),
    );
  }

  void selectAddress(CertificateAddress address) {
    _key = null;
    emit(
      state.copyWith(
        address: address,
        submissionFailure: null,
        canContinue:
            !state.isOtherRecipient ||
            (state.isRecipientNameValid && state.isRecipientNationalIdValid),
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
    _key = null;
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
    _key = null;
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
    _key = null;
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
    _key = null;
    emit(
      state.copyWith(
        recipientName: value,
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
    _key = null;
    emit(
      state.copyWith(
        recipientNationalId: normalized,
        isRecipientNationalIdValid: valid,
        canContinue:
            state.address != null &&
            (!state.isOtherRecipient || (state.isRecipientNameValid && valid)),
      ),
    );
  }

  void updateIncludeAgent(bool value) {
    _key = null;
    emit(state.copyWith(isIncludeAgent: value));
  }

  void updateAgentIdentifier(String value) {
    final normalized = DigitNormalizer.normalize(value);
    _key = null;
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
      recipientName: state.isOtherRecipient ? state.recipientName.trim() : null,
      recipientNationalId: state.isOtherRecipient
          ? state.recipientNationalId
          : null,
      agentIdentifier:
          state.isIncludeAgent && state.agentIdentifier.trim().isNotEmpty
          ? state.agentIdentifier
          : null,
      idempotencyKey: _key!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        submissionFailure: null,
      ),
    );
    return certificateBoundary(() => repository.submitAverageBalance(request))
        .then((result) {
          switch (result) {
            case Err(:final failure):
              emit(
                state.copyWith(
                  submissionStatus: RequestStatus.failure,
                  submissionFailure: failure,
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
}
