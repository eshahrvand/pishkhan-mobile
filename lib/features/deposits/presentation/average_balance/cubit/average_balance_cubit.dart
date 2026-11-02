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

import '../../../domain/entities/certificate_data.dart';
import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/usecases/average_balance_usecase.dart';
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

  final loadCertificateCatalogUseCase = getIt<LoadCertificateCatalogUseCase>(
    instanceName: 'average-balance',
  );
  final submitAverageBalanceUseCase = getIt<SubmitAverageBalanceUseCase>();
  final String? initialDepositNumber;
  int _localAddress = 0;
  // The last sent payload owns its key; editing the form does not create a request.
  AverageBalanceRequest? _submittedRequest;

  AverageBalanceState? _entryState;

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

  void requestBack() {
    switch (state.step) {
      case AverageBalanceStep.confirmation:
        emit(
          state.copyWith(
            step: AverageBalanceStep.delivery,
            stepNumber: 2,
            progress: .6,
            canContinue: _canContinueDelivery(state.address),
          ),
        );
      case AverageBalanceStep.delivery:
        emit(
          state.copyWith(
            step: AverageBalanceStep.conditions,
            stepNumber: 1,
            progress: .3,
            canContinue: _areConditionsComplete(state.deposit),
          ),
        );
      case AverageBalanceStep.conditions:
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

  Future<void> continueFlow() async {
    switch (state.step) {
      case AverageBalanceStep.conditions:
        emit(
          state.copyWith(
            step: AverageBalanceStep.delivery,
            stepNumber: 2,
            progress: .6,
            canContinue: _canContinueDelivery(state.address),
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
        final total = data.printFeeRial + data.deliveryFeeRial;
        final nameValid = RequiredTextValidator.isValid(state.recipientName);
        final nationalIdValid = NationalCodeValidator.isValid(
          state.recipientNationalId,
        );
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            deposit: deposit,
            addresses: data.addresses,
            totalRial: total,
            isWalletSufficient: _isWalletSufficient(data, total),
            isRecipientNameValid: nameValid,
            isRecipientNationalIdValid: nationalIdValid,
            canCheckAgent: RequiredTextValidator.isValid(state.agentIdentifier),
            stepNumber: state.step.index + 1,
            progress: switch (state.step) {
              AverageBalanceStep.conditions => .3,
              AverageBalanceStep.delivery => .6,
              AverageBalanceStep.confirmation => 1,
            },
            canContinue: _canContinueAfterCatalog(
              deposit,
              nameValid,
              nationalIdValid,
              _isWalletSufficient(data, total),
            ),
          ),
        );
        _entryState = state;
    }
  }

  void selectDeposit(ListedDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        language: null,
        turnover: null,
        fromDate: null,
        toDate: null,
        canContinue: false,
      ),
    );
  }

  void selectLanguage(CertificateLanguage language) {
    emit(
      state.copyWith(language: language, canContinue: state.turnover != null),
    );
  }

  void selectTurnover(StatementTurnover turnover) {
    emit(
      state.copyWith(turnover: turnover, canContinue: state.language != null),
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
        recipientName: value,
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
        recipientNationalId: normalized,
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
    final result = await submitAverageBalanceUseCase(request);
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

  AverageBalanceRequest _createRequest(String? idempotencyKey) {
    return AverageBalanceRequest(
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

  bool _areConditionsComplete(ListedDeposit? deposit) =>
      deposit != null && state.language != null && state.turnover != null;

  bool _canContinueAfterCatalog(
    ListedDeposit? deposit,
    bool nameValid,
    bool nationalIdValid,
    bool isWalletSufficient,
  ) {
    return _areConditionsComplete(deposit) &&
        switch (state.step) {
          AverageBalanceStep.conditions => true,
          AverageBalanceStep.delivery => _canContinueDelivery(
            state.address,
            isRecipientNameValid: nameValid,
            isRecipientNationalIdValid: nationalIdValid,
          ),
          AverageBalanceStep.confirmation =>
            _canContinueDelivery(
                  state.address,
                  isRecipientNameValid: nameValid,
                  isRecipientNationalIdValid: nationalIdValid,
                ) &&
                isWalletSufficient,
        };
  }

  bool _isWalletSufficient(CertificateCatalog catalog, int totalRial) =>
      catalog.walletBalanceRial >= totalRial;

  bool _requiresExitConfirmation() {
    return state.submissionStatus != RequestStatus.success &&
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
            state.isIncludeAgent != (_entryState?.isIncludeAgent ?? false) ||
            state.isOtherRecipient !=
                (_entryState?.isOtherRecipient ?? false) ||
            state.agentIdentifier != (_entryState?.agentIdentifier ?? ''));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeAverageBalanceInteraction() {
    emit(state.copyWith(navigation: null, effect: null));
  }
}
