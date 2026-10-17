import 'package:pishkhan_mobile/core/di/injection_container.dart';

import 'issuance_effect.dart';
export 'issuance_effect.dart';

import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/issuance_draft.dart';
export '../../../domain/entities/issuance_draft.dart';

import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/issuance_data.dart';
import '../../../domain/repositories/card_issuance_repository.dart';
import '../../../domain/usecases/card_issuance.dart';

part 'card_issuance_state.dart';
part 'card_issuance_cubit.freezed.dart';

class CardIssuanceCubit extends Cubit<CardIssuanceState> {
  CardIssuanceCubit({
    CardIssuanceState initialState = const CardIssuanceState.initial(),
    this.initialDepositNumber,
  }) : super(initialState);
  final _repository = getIt<CardIssuanceRepository>();
  late LoadIssuanceCatalog _loader = LoadIssuanceCatalog(_repository);
  late SubmitCardIssuance _submitter = SubmitCardIssuance(_repository);
  final String? initialDepositNumber;
  int _generation = 0, _addressCounter = 0;
  void requestTerms() {
    if (isClosed) return;
    emit(
      state.copyWith(
        effect: const IssuanceTermsRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestAddAddress() {
    if (isClosed || !state.editable) return;
    emit(
      state.copyWith(
        isAddressFormError: false,
        effect: const IssuanceAddressRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestDeleteAddress(IssuanceAddress address) {
    if (isClosed || !state.editable || state.address?.id != address.id) return;
    emit(
      state.copyWith(
        effect: IssuanceAddressRemovalRequested(address),
        effectId: state.effectId + 1,
      ),
    );
  }

  void addressRemovalResult(String id, bool? confirmed) {
    if (isClosed || confirmed != true || state.address?.id != id) return;
    removeAddress(id);
  }

  Future<void> continueFlow() async {
    if (isClosed || !state.canContinue) return;
    if (state.step == IssuanceStep.confirmation) {
      await submit();
    } else {
      next();
    }
  }

  void updateRecipientName(String value) =>
      setRecipient(state.draft.recipient.copyWith(name: value));
  void updateRecipientNationalId(String value) =>
      setRecipient(state.draft.recipient.copyWith(nationalId: value));
  void updateRecipientMobile(String value) =>
      setRecipient(state.draft.recipient.copyWith(mobile: value));
  void updateAgentName(String value) =>
      setAgent(BankAgent(name: value, code: state.draft.agent.code));
  void updateAgentCode(String value) =>
      setAgent(BankAgent(name: state.draft.agent.name, code: value));

  // Loaded entry snapshot, retained only to detect discardable user edits.
  CardIssuanceState? _entryState;

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
        (state.draft != _entryState?.draft);
    emit(
      state.copyWith(
        navigation: needsConfirmation
            ? FlowNavigation.confirmExit
            : FlowNavigation.back,
        navigationId: state.navigationId + 1,
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

        navigationId: state.navigationId + 1,
      ),
    );
  }

  void requestHome() {
    if (isClosed || state.submissionStatus == RequestStatus.loading) return;
    emit(
      state.copyWith(
        navigation: FlowNavigation.home,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  Future<void> load() async {
    final generation = ++_generation;
    {
      final nextDraft = (const IssuanceDraft());
      final nextDeposit = getDeposit((null), nextDraft);
      final nextAddress = getAddress((null), nextDraft);
      final nextSelection = checkSelection((null), nextDraft, nextDeposit);
      final nextDelivery = checkDelivery(nextDraft, nextAddress);
      final nextFees = getFees((null), nextDraft);
      final nextTotal = nextFees.fold<int>(
        0,
        (sum, fee) => sum + fee.amountRial,
      );
      final nextWallet = false;
      final nextEditable = checkEditable(
        (RequestStatus.loading),
        (RequestStatus.initial),
        (null),
      );
      emit(
        state.copyWith(
          status: RequestStatus.loading,
          submissionStatus: RequestStatus.initial,
          catalog: null,
          draft: const IssuanceDraft(),
          step: IssuanceStep.selection,
          invoiceExpanded: true,
          summaryExpanded: true,
          receipt: null,
          failure: null,
          deposit: nextDeposit,
          address: nextAddress,
          selectionComplete: nextSelection,
          deliveryComplete: nextDelivery,
          fees: nextFees,
          totalRial: nextTotal,
          walletSufficient: nextWallet,
          editable: nextEditable,
          canContinue: nextEditable && nextSelection,
          request: nextSelection && nextDelivery
              ? IssuanceRequest(
                  depositId: nextDeposit!.id,
                  type: nextDraft.type!,
                  noPhysicalCard: nextDraft.noPhysicalCard,
                  address: nextDraft.noPhysicalCard ? null : nextAddress,
                  recipient:
                      !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                      ? nextDraft.recipient
                      : null,
                  agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                      ? nextDraft.agent
                      : null,
                )
              : null,
        ),
      );
    }
    Result<IssuanceCatalog> result;
    try {
      result = await _loader();
    } catch (_) {
      result = const Err(UnexpectedFailure());
    }
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        {
          final nextDraft = (IssuanceDraft());
          final nextDeposit = getDeposit((null as IssuanceCatalog?), nextDraft);
          final nextAddress = getAddress((null as IssuanceCatalog?), nextDraft);
          final nextSelection = checkSelection(
            (null as IssuanceCatalog?),
            nextDraft,
            nextDeposit,
          );
          final nextDelivery = checkDelivery(nextDraft, nextAddress);
          final nextFees = getFees((null as IssuanceCatalog?), nextDraft);
          final nextTotal = nextFees.fold<int>(
            0,
            (sum, fee) => sum + fee.amountRial,
          );
          final nextWallet =
              (null as IssuanceCatalog?) != null &&
              (null as IssuanceCatalog?)!.walletBalanceRial >= nextTotal;
          final nextEditable = checkEditable(
            (RequestStatus.failure),
            (RequestStatus.initial),
            (null as IssuanceCatalog?),
          );
          emit(
            CardIssuanceState.initial(
              status: RequestStatus.failure,
              failure: failure,
              deposit: nextDeposit,
              address: nextAddress,
              selectionComplete: nextSelection,
              deliveryComplete: nextDelivery,
              fees: nextFees,
              totalRial: nextTotal,
              walletSufficient: nextWallet,
              editable: nextEditable,
              canContinue: nextEditable && nextSelection,
              request: nextSelection && nextDelivery
                  ? IssuanceRequest(
                      depositId: nextDeposit!.id,
                      type: nextDraft.type!,
                      noPhysicalCard: nextDraft.noPhysicalCard,
                      address: nextDraft.noPhysicalCard ? null : nextAddress,
                      recipient:
                          !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                          ? nextDraft.recipient
                          : null,
                      agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                          ? nextDraft.agent
                          : null,
                    )
                  : null,
            ),
          );
        }
      case Success(:final data):
        String? selected;
        for (final d in data.deposits) {
          if (initialDepositNumber != null &&
              DigitNormalizer.normalize(d.number) ==
                  DigitNormalizer.normalize(initialDepositNumber!)) {
            selected = d.id;
          }
        }
        {
          final nextDraft = (IssuanceDraft(depositId: selected));
          final nextDeposit = getDeposit((data), nextDraft);
          final nextAddress = getAddress((data), nextDraft);
          final nextSelection = checkSelection((data), nextDraft, nextDeposit);
          final nextDelivery = checkDelivery(nextDraft, nextAddress);
          final nextFees = getFees((data), nextDraft);
          final nextTotal = nextFees.fold<int>(
            0,
            (sum, fee) => sum + fee.amountRial,
          );
          final nextWallet = (data).walletBalanceRial >= nextTotal;
          final nextEditable = checkEditable(
            (RequestStatus.success),
            (RequestStatus.initial),
            (data),
          );
          emit(
            CardIssuanceState.initial(
              status: RequestStatus.success,
              catalog: data,
              draft: IssuanceDraft(depositId: selected),
              deposit: nextDeposit,
              address: nextAddress,
              selectionComplete: nextSelection,
              deliveryComplete: nextDelivery,
              fees: nextFees,
              totalRial: nextTotal,
              walletSufficient: nextWallet,
              editable: nextEditable,
              canContinue: nextEditable && nextSelection,
              request: nextSelection && nextDelivery
                  ? IssuanceRequest(
                      depositId: nextDeposit!.id,
                      type: nextDraft.type!,
                      noPhysicalCard: nextDraft.noPhysicalCard,
                      address: nextDraft.noPhysicalCard ? null : nextAddress,
                      recipient:
                          !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                          ? nextDraft.recipient
                          : null,
                      agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                          ? nextDraft.agent
                          : null,
                    )
                  : null,
            ),
          );
        }
    }
    if (!isClosed && state.status == RequestStatus.success) _entryState = state;
  }

  Future<void> changeRepository(CardIssuanceRepository repository) {
    _loader = LoadIssuanceCatalog(repository);
    _submitter = SubmitCardIssuance(repository);
    return load();
  }

  void selectDeposit(String id) {
    if (state.catalog?.deposits.any((d) => d.id == id) ?? false) {
      {
        final draft = state.draft.copyWith(depositId: id);

        if (!state.editable) return;
        {
          final nextDraft = (draft.copyWith(termsAccepted: false));
          final nextDeposit = getDeposit(state.catalog, nextDraft);
          final nextAddress = getAddress(state.catalog, nextDraft);
          final nextSelection = checkSelection(
            state.catalog,
            nextDraft,
            nextDeposit,
          );
          final nextDelivery = checkDelivery(nextDraft, nextAddress);
          final nextFees = getFees(state.catalog, nextDraft);
          final nextTotal = nextFees.fold<int>(
            0,
            (sum, fee) => sum + fee.amountRial,
          );
          final nextWallet =
              state.catalog != null &&
              state.catalog!.walletBalanceRial >= nextTotal;
          emit(
            state.copyWith(
              draft: draft.copyWith(termsAccepted: false),
              failure: null,
              deposit: nextDeposit,
              address: nextAddress,
              selectionComplete: nextSelection,
              deliveryComplete: nextDelivery,
              fees: nextFees,
              totalRial: nextTotal,
              walletSufficient: nextWallet,
              canContinue:
                  state.editable &&
                  switch (state.step) {
                    IssuanceStep.selection => nextSelection,
                    IssuanceStep.delivery => nextSelection && nextDelivery,
                    IssuanceStep.confirmation =>
                      nextSelection &&
                          nextDelivery &&
                          nextDraft.termsAccepted &&
                          nextWallet,
                  },
              request: nextSelection && nextDelivery
                  ? IssuanceRequest(
                      depositId: nextDeposit!.id,
                      type: nextDraft.type!,
                      noPhysicalCard: nextDraft.noPhysicalCard,
                      address: nextDraft.noPhysicalCard ? null : nextAddress,
                      recipient:
                          !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                          ? nextDraft.recipient
                          : null,
                      agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                          ? nextDraft.agent
                          : null,
                    )
                  : null,
            ),
          );
        }
      }
    }
  }

  void selectType(IssuanceType type) {
    if (state.catalog?.types.contains(type) ?? false) {
      {
        final draft = state.draft.copyWith(type: type);

        if (!state.editable) return;
        {
          final nextDraft = (draft.copyWith(termsAccepted: false));
          final nextDeposit = getDeposit(state.catalog, nextDraft);
          final nextAddress = getAddress(state.catalog, nextDraft);
          final nextSelection = checkSelection(
            state.catalog,
            nextDraft,
            nextDeposit,
          );
          final nextDelivery = checkDelivery(nextDraft, nextAddress);
          final nextFees = getFees(state.catalog, nextDraft);
          final nextTotal = nextFees.fold<int>(
            0,
            (sum, fee) => sum + fee.amountRial,
          );
          final nextWallet =
              state.catalog != null &&
              state.catalog!.walletBalanceRial >= nextTotal;
          emit(
            state.copyWith(
              draft: draft.copyWith(termsAccepted: false),
              failure: null,
              deposit: nextDeposit,
              address: nextAddress,
              selectionComplete: nextSelection,
              deliveryComplete: nextDelivery,
              fees: nextFees,
              totalRial: nextTotal,
              walletSufficient: nextWallet,
              canContinue:
                  state.editable &&
                  switch (state.step) {
                    IssuanceStep.selection => nextSelection,
                    IssuanceStep.delivery => nextSelection && nextDelivery,
                    IssuanceStep.confirmation =>
                      nextSelection &&
                          nextDelivery &&
                          nextDraft.termsAccepted &&
                          nextWallet,
                  },
              request: nextSelection && nextDelivery
                  ? IssuanceRequest(
                      depositId: nextDeposit!.id,
                      type: nextDraft.type!,
                      noPhysicalCard: nextDraft.noPhysicalCard,
                      address: nextDraft.noPhysicalCard ? null : nextAddress,
                      recipient:
                          !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                          ? nextDraft.recipient
                          : null,
                      agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                          ? nextDraft.agent
                          : null,
                    )
                  : null,
            ),
          );
        }
      }
    }
  }

  void setNoPhysicalCard(bool value) {
    final draft = state.draft.copyWith(noPhysicalCard: value);

    if (!state.editable) return;
    {
      final nextDraft = (draft.copyWith(termsAccepted: false));
      final nextDeposit = getDeposit(state.catalog, nextDraft);
      final nextAddress = getAddress(state.catalog, nextDraft);
      final nextSelection = checkSelection(
        state.catalog,
        nextDraft,
        nextDeposit,
      );
      final nextDelivery = checkDelivery(nextDraft, nextAddress);
      final nextFees = getFees(state.catalog, nextDraft);
      final nextTotal = nextFees.fold<int>(
        0,
        (sum, fee) => sum + fee.amountRial,
      );
      final nextWallet =
          state.catalog != null &&
          state.catalog!.walletBalanceRial >= nextTotal;
      emit(
        state.copyWith(
          draft: draft.copyWith(termsAccepted: false),
          failure: null,
          deposit: nextDeposit,
          address: nextAddress,
          selectionComplete: nextSelection,
          deliveryComplete: nextDelivery,
          fees: nextFees,
          totalRial: nextTotal,
          walletSufficient: nextWallet,
          canContinue:
              state.editable &&
              switch (state.step) {
                IssuanceStep.selection => nextSelection,
                IssuanceStep.delivery => nextSelection && nextDelivery,
                IssuanceStep.confirmation =>
                  nextSelection &&
                      nextDelivery &&
                      nextDraft.termsAccepted &&
                      nextWallet,
              },
          request: nextSelection && nextDelivery
              ? IssuanceRequest(
                  depositId: nextDeposit!.id,
                  type: nextDraft.type!,
                  noPhysicalCard: nextDraft.noPhysicalCard,
                  address: nextDraft.noPhysicalCard ? null : nextAddress,
                  recipient:
                      !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                      ? nextDraft.recipient
                      : null,
                  agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                      ? nextDraft.agent
                      : null,
                )
              : null,
        ),
      );
    }
  }

  void selectAddress(String id) {
    if (state.catalog?.addresses.any((a) => a.id == id) ?? false) {
      {
        final draft = state.draft.copyWith(addressId: id);

        if (!state.editable) return;
        {
          final nextDraft = (draft.copyWith(termsAccepted: false));
          final nextDeposit = getDeposit(state.catalog, nextDraft);
          final nextAddress = getAddress(state.catalog, nextDraft);
          final nextSelection = checkSelection(
            state.catalog,
            nextDraft,
            nextDeposit,
          );
          final nextDelivery = checkDelivery(nextDraft, nextAddress);
          final nextFees = getFees(state.catalog, nextDraft);
          final nextTotal = nextFees.fold<int>(
            0,
            (sum, fee) => sum + fee.amountRial,
          );
          final nextWallet =
              state.catalog != null &&
              state.catalog!.walletBalanceRial >= nextTotal;
          emit(
            state.copyWith(
              draft: draft.copyWith(termsAccepted: false),
              failure: null,
              deposit: nextDeposit,
              address: nextAddress,
              selectionComplete: nextSelection,
              deliveryComplete: nextDelivery,
              fees: nextFees,
              totalRial: nextTotal,
              walletSufficient: nextWallet,
              canContinue:
                  state.editable &&
                  switch (state.step) {
                    IssuanceStep.selection => nextSelection,
                    IssuanceStep.delivery => nextSelection && nextDelivery,
                    IssuanceStep.confirmation =>
                      nextSelection &&
                          nextDelivery &&
                          nextDraft.termsAccepted &&
                          nextWallet,
                  },
              request: nextSelection && nextDelivery
                  ? IssuanceRequest(
                      depositId: nextDeposit!.id,
                      type: nextDraft.type!,
                      noPhysicalCard: nextDraft.noPhysicalCard,
                      address: nextDraft.noPhysicalCard ? null : nextAddress,
                      recipient:
                          !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                          ? nextDraft.recipient
                          : null,
                      agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                          ? nextDraft.agent
                          : null,
                    )
                  : null,
            ),
          );
        }
      }
    }
  }

  void resetAddressFormValidation() {
    emit(state.copyWith(isAddressFormError: false));
  }

  bool addAddress({
    required String title,
    required String detail,
    required String postalCode,
  }) {
    final postal = DigitNormalizer.normalize(postalCode).trim();
    if (!state.editable ||
        title.trim().isEmpty ||
        detail.trim().isEmpty ||
        !PostalCodeValidator.isValid(postal)) {
      emit(state.copyWith(isAddressFormError: true));
      return false;
    }
    final address = IssuanceAddress(
      id: 'local-address-${++_addressCounter}',
      title: title.trim(),
      detail: detail.trim(),
      postalCode: postal,
    );
    {
      final nextDraft = (state.draft.copyWith(
        addressId: address.id,
        termsAccepted: false,
      ));
      final nextDeposit = getDeposit(
        (state.catalog!.withAddresses([...state.catalog!.addresses, address])),
        nextDraft,
      );
      final nextAddress = getAddress(
        (state.catalog!.withAddresses([...state.catalog!.addresses, address])),
        nextDraft,
      );
      final nextSelection = checkSelection(
        (state.catalog!.withAddresses([...state.catalog!.addresses, address])),
        nextDraft,
        nextDeposit,
      );
      final nextDelivery = checkDelivery(nextDraft, nextAddress);
      final nextFees = getFees(
        (state.catalog!.withAddresses([...state.catalog!.addresses, address])),
        nextDraft,
      );
      final nextTotal = nextFees.fold<int>(
        0,
        (sum, fee) => sum + fee.amountRial,
      );
      final nextWallet =
          (state.catalog!.withAddresses([...state.catalog!.addresses, address]))
              .walletBalanceRial >=
          nextTotal;
      final nextEditable = checkEditable(
        state.status,
        state.submissionStatus,
        (state.catalog!.withAddresses([...state.catalog!.addresses, address])),
      );
      emit(
        state.copyWith(
          addressSavedId: state.addressSavedId + 1,
          catalog: state.catalog!.withAddresses([
            ...state.catalog!.addresses,
            address,
          ]),
          draft: state.draft.copyWith(
            addressId: address.id,
            termsAccepted: false,
          ),
          failure: null,
          deposit: nextDeposit,
          address: nextAddress,
          selectionComplete: nextSelection,
          deliveryComplete: nextDelivery,
          fees: nextFees,
          totalRial: nextTotal,
          walletSufficient: nextWallet,
          editable: nextEditable,
          canContinue:
              nextEditable &&
              switch (state.step) {
                IssuanceStep.selection => nextSelection,
                IssuanceStep.delivery => nextSelection && nextDelivery,
                IssuanceStep.confirmation =>
                  nextSelection &&
                      nextDelivery &&
                      nextDraft.termsAccepted &&
                      nextWallet,
              },
          request: nextSelection && nextDelivery
              ? IssuanceRequest(
                  depositId: nextDeposit!.id,
                  type: nextDraft.type!,
                  noPhysicalCard: nextDraft.noPhysicalCard,
                  address: nextDraft.noPhysicalCard ? null : nextAddress,
                  recipient:
                      !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                      ? nextDraft.recipient
                      : null,
                  agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                      ? nextDraft.agent
                      : null,
                )
              : null,
        ),
      );
    }
    return true;
  }

  void removeAddress(String id) {
    if (!state.editable || state.catalog == null) return;
    {
      final nextDraft = (state.draft.copyWith(
        clearAddress: state.draft.addressId == id,
        termsAccepted: false,
      ));
      final nextDeposit = getDeposit(
        (state.catalog!.withAddresses(
          state.catalog!.addresses.where((a) => a.id != id),
        )),
        nextDraft,
      );
      final nextAddress = getAddress(
        (state.catalog!.withAddresses(
          state.catalog!.addresses.where((a) => a.id != id),
        )),
        nextDraft,
      );
      final nextSelection = checkSelection(
        (state.catalog!.withAddresses(
          state.catalog!.addresses.where((a) => a.id != id),
        )),
        nextDraft,
        nextDeposit,
      );
      final nextDelivery = checkDelivery(nextDraft, nextAddress);
      final nextFees = getFees(
        (state.catalog!.withAddresses(
          state.catalog!.addresses.where((a) => a.id != id),
        )),
        nextDraft,
      );
      final nextTotal = nextFees.fold<int>(
        0,
        (sum, fee) => sum + fee.amountRial,
      );
      final nextWallet =
          (state.catalog!.withAddresses(
            state.catalog!.addresses.where((a) => a.id != id),
          )).walletBalanceRial >=
          nextTotal;
      final nextEditable = checkEditable(
        state.status,
        state.submissionStatus,
        (state.catalog!.withAddresses(
          state.catalog!.addresses.where((a) => a.id != id),
        )),
      );
      emit(
        state.copyWith(
          catalog: state.catalog!.withAddresses(
            state.catalog!.addresses.where((a) => a.id != id),
          ),
          draft: state.draft.copyWith(
            clearAddress: state.draft.addressId == id,
            termsAccepted: false,
          ),
          failure: null,
          deposit: nextDeposit,
          address: nextAddress,
          selectionComplete: nextSelection,
          deliveryComplete: nextDelivery,
          fees: nextFees,
          totalRial: nextTotal,
          walletSufficient: nextWallet,
          editable: nextEditable,
          canContinue:
              nextEditable &&
              switch (state.step) {
                IssuanceStep.selection => nextSelection,
                IssuanceStep.delivery => nextSelection && nextDelivery,
                IssuanceStep.confirmation =>
                  nextSelection &&
                      nextDelivery &&
                      nextDraft.termsAccepted &&
                      nextWallet,
              },
          request: nextSelection && nextDelivery
              ? IssuanceRequest(
                  depositId: nextDeposit!.id,
                  type: nextDraft.type!,
                  noPhysicalCard: nextDraft.noPhysicalCard,
                  address: nextDraft.noPhysicalCard ? null : nextAddress,
                  recipient:
                      !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                      ? nextDraft.recipient
                      : null,
                  agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                      ? nextDraft.agent
                      : null,
                )
              : null,
        ),
      );
    }
  }

  void setOtherRecipient(bool value) {
    final draft = state.draft.copyWith(otherRecipient: value);

    if (!state.editable) return;
    {
      final nextDraft = (draft.copyWith(termsAccepted: false));
      final nextDeposit = getDeposit(state.catalog, nextDraft);
      final nextAddress = getAddress(state.catalog, nextDraft);
      final nextSelection = checkSelection(
        state.catalog,
        nextDraft,
        nextDeposit,
      );
      final nextDelivery = checkDelivery(nextDraft, nextAddress);
      final nextFees = getFees(state.catalog, nextDraft);
      final nextTotal = nextFees.fold<int>(
        0,
        (sum, fee) => sum + fee.amountRial,
      );
      final nextWallet =
          state.catalog != null &&
          state.catalog!.walletBalanceRial >= nextTotal;
      emit(
        state.copyWith(
          draft: draft.copyWith(termsAccepted: false),
          failure: null,
          deposit: nextDeposit,
          address: nextAddress,
          selectionComplete: nextSelection,
          deliveryComplete: nextDelivery,
          fees: nextFees,
          totalRial: nextTotal,
          walletSufficient: nextWallet,
          canContinue:
              state.editable &&
              switch (state.step) {
                IssuanceStep.selection => nextSelection,
                IssuanceStep.delivery => nextSelection && nextDelivery,
                IssuanceStep.confirmation =>
                  nextSelection &&
                      nextDelivery &&
                      nextDraft.termsAccepted &&
                      nextWallet,
              },
          request: nextSelection && nextDelivery
              ? IssuanceRequest(
                  depositId: nextDeposit!.id,
                  type: nextDraft.type!,
                  noPhysicalCard: nextDraft.noPhysicalCard,
                  address: nextDraft.noPhysicalCard ? null : nextAddress,
                  recipient:
                      !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                      ? nextDraft.recipient
                      : null,
                  agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                      ? nextDraft.agent
                      : null,
                )
              : null,
        ),
      );
    }
  }

  void setIncludeAgent(bool value) {
    final draft = state.draft.copyWith(includeAgent: value);

    if (!state.editable) return;
    {
      final nextDraft = (draft.copyWith(termsAccepted: false));
      final nextDeposit = getDeposit(state.catalog, nextDraft);
      final nextAddress = getAddress(state.catalog, nextDraft);
      final nextSelection = checkSelection(
        state.catalog,
        nextDraft,
        nextDeposit,
      );
      final nextDelivery = checkDelivery(nextDraft, nextAddress);
      final nextFees = getFees(state.catalog, nextDraft);
      final nextTotal = nextFees.fold<int>(
        0,
        (sum, fee) => sum + fee.amountRial,
      );
      final nextWallet =
          state.catalog != null &&
          state.catalog!.walletBalanceRial >= nextTotal;
      emit(
        state.copyWith(
          draft: draft.copyWith(termsAccepted: false),
          failure: null,
          deposit: nextDeposit,
          address: nextAddress,
          selectionComplete: nextSelection,
          deliveryComplete: nextDelivery,
          fees: nextFees,
          totalRial: nextTotal,
          walletSufficient: nextWallet,
          canContinue:
              state.editable &&
              switch (state.step) {
                IssuanceStep.selection => nextSelection,
                IssuanceStep.delivery => nextSelection && nextDelivery,
                IssuanceStep.confirmation =>
                  nextSelection &&
                      nextDelivery &&
                      nextDraft.termsAccepted &&
                      nextWallet,
              },
          request: nextSelection && nextDelivery
              ? IssuanceRequest(
                  depositId: nextDeposit!.id,
                  type: nextDraft.type!,
                  noPhysicalCard: nextDraft.noPhysicalCard,
                  address: nextDraft.noPhysicalCard ? null : nextAddress,
                  recipient:
                      !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                      ? nextDraft.recipient
                      : null,
                  agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                      ? nextDraft.agent
                      : null,
                )
              : null,
        ),
      );
    }
  }

  void setRecipient(DeliveryPerson value) {
    final draft = state.draft.copyWith(
      recipient: value.copyWith(
        nationalId: DigitNormalizer.normalize(value.nationalId),
        mobile: DigitNormalizer.normalize(value.mobile),
      ),
    );

    if (!state.editable) return;
    {
      final nextDraft = (draft.copyWith(termsAccepted: false));
      final nextDeposit = getDeposit(state.catalog, nextDraft);
      final nextAddress = getAddress(state.catalog, nextDraft);
      final nextSelection = checkSelection(
        state.catalog,
        nextDraft,
        nextDeposit,
      );
      final nextDelivery = checkDelivery(nextDraft, nextAddress);
      final nextFees = getFees(state.catalog, nextDraft);
      final nextTotal = nextFees.fold<int>(
        0,
        (sum, fee) => sum + fee.amountRial,
      );
      final nextWallet =
          state.catalog != null &&
          state.catalog!.walletBalanceRial >= nextTotal;
      emit(
        state.copyWith(
          draft: draft.copyWith(termsAccepted: false),
          failure: null,
          deposit: nextDeposit,
          address: nextAddress,
          selectionComplete: nextSelection,
          deliveryComplete: nextDelivery,
          fees: nextFees,
          totalRial: nextTotal,
          walletSufficient: nextWallet,
          canContinue:
              state.editable &&
              switch (state.step) {
                IssuanceStep.selection => nextSelection,
                IssuanceStep.delivery => nextSelection && nextDelivery,
                IssuanceStep.confirmation =>
                  nextSelection &&
                      nextDelivery &&
                      nextDraft.termsAccepted &&
                      nextWallet,
              },
          request: nextSelection && nextDelivery
              ? IssuanceRequest(
                  depositId: nextDeposit!.id,
                  type: nextDraft.type!,
                  noPhysicalCard: nextDraft.noPhysicalCard,
                  address: nextDraft.noPhysicalCard ? null : nextAddress,
                  recipient:
                      !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                      ? nextDraft.recipient
                      : null,
                  agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                      ? nextDraft.agent
                      : null,
                )
              : null,
        ),
      );
    }
  }

  void setAgent(BankAgent value) {
    final draft = state.draft.copyWith(
      agent: value.copyWith(code: DigitNormalizer.normalize(value.code)),
    );

    if (!state.editable) return;
    {
      final nextDraft = (draft.copyWith(termsAccepted: false));
      final nextDeposit = getDeposit(state.catalog, nextDraft);
      final nextAddress = getAddress(state.catalog, nextDraft);
      final nextSelection = checkSelection(
        state.catalog,
        nextDraft,
        nextDeposit,
      );
      final nextDelivery = checkDelivery(nextDraft, nextAddress);
      final nextFees = getFees(state.catalog, nextDraft);
      final nextTotal = nextFees.fold<int>(
        0,
        (sum, fee) => sum + fee.amountRial,
      );
      final nextWallet =
          state.catalog != null &&
          state.catalog!.walletBalanceRial >= nextTotal;
      emit(
        state.copyWith(
          draft: draft.copyWith(termsAccepted: false),
          failure: null,
          deposit: nextDeposit,
          address: nextAddress,
          selectionComplete: nextSelection,
          deliveryComplete: nextDelivery,
          fees: nextFees,
          totalRial: nextTotal,
          walletSufficient: nextWallet,
          canContinue:
              state.editable &&
              switch (state.step) {
                IssuanceStep.selection => nextSelection,
                IssuanceStep.delivery => nextSelection && nextDelivery,
                IssuanceStep.confirmation =>
                  nextSelection &&
                      nextDelivery &&
                      nextDraft.termsAccepted &&
                      nextWallet,
              },
          request: nextSelection && nextDelivery
              ? IssuanceRequest(
                  depositId: nextDeposit!.id,
                  type: nextDraft.type!,
                  noPhysicalCard: nextDraft.noPhysicalCard,
                  address: nextDraft.noPhysicalCard ? null : nextAddress,
                  recipient:
                      !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                      ? nextDraft.recipient
                      : null,
                  agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                      ? nextDraft.agent
                      : null,
                )
              : null,
        ),
      );
    }
  }

  void acceptTerms(bool value) {
    if (state.editable) {
      {
        final nextDraft = (state.draft.copyWith(termsAccepted: value));
        final nextDeposit = getDeposit(state.catalog, nextDraft);
        final nextAddress = getAddress(state.catalog, nextDraft);
        final nextSelection = checkSelection(
          state.catalog,
          nextDraft,
          nextDeposit,
        );
        final nextDelivery = checkDelivery(nextDraft, nextAddress);
        final nextFees = getFees(state.catalog, nextDraft);
        final nextTotal = nextFees.fold<int>(
          0,
          (sum, fee) => sum + fee.amountRial,
        );
        final nextWallet =
            state.catalog != null &&
            state.catalog!.walletBalanceRial >= nextTotal;
        emit(
          state.copyWith(
            draft: state.draft.copyWith(termsAccepted: value),
            failure: null,
            deposit: nextDeposit,
            address: nextAddress,
            selectionComplete: nextSelection,
            deliveryComplete: nextDelivery,
            fees: nextFees,
            totalRial: nextTotal,
            walletSufficient: nextWallet,
            canContinue:
                state.editable &&
                switch (state.step) {
                  IssuanceStep.selection => nextSelection,
                  IssuanceStep.delivery => nextSelection && nextDelivery,
                  IssuanceStep.confirmation =>
                    nextSelection &&
                        nextDelivery &&
                        nextDraft.termsAccepted &&
                        nextWallet,
                },
            request: nextSelection && nextDelivery
                ? IssuanceRequest(
                    depositId: nextDeposit!.id,
                    type: nextDraft.type!,
                    noPhysicalCard: nextDraft.noPhysicalCard,
                    address: nextDraft.noPhysicalCard ? null : nextAddress,
                    recipient:
                        !nextDraft.noPhysicalCard && nextDraft.otherRecipient
                        ? nextDraft.recipient
                        : null,
                    agent: !nextDraft.noPhysicalCard && nextDraft.includeAgent
                        ? nextDraft.agent
                        : null,
                  )
                : null,
          ),
        );
      }
    }
  }

  void expandInvoice(bool value) {
    if (state.editable) {
      {
        emit(state.copyWith(invoiceExpanded: value));
      }
    }
  }

  void expandSummary(bool value) {
    if (state.editable) {
      {
        emit(state.copyWith(summaryExpanded: value));
      }
    }
  }

  void next() {
    if (!state.canContinue || state.step == IssuanceStep.confirmation) {
      return;
    }
    {
      final nextDraft = state.draft;
      emit(
        state.copyWith(
          step:
              state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
              ? IssuanceStep.confirmation
              : IssuanceStep.delivery,
          canContinue:
              state.editable &&
              switch ((state.step == IssuanceStep.delivery ||
                      state.draft.noPhysicalCard
                  ? IssuanceStep.confirmation
                  : IssuanceStep.delivery)) {
                IssuanceStep.selection => state.selectionComplete,
                IssuanceStep.delivery =>
                  state.selectionComplete && state.deliveryComplete,
                IssuanceStep.confirmation =>
                  state.selectionComplete &&
                      state.deliveryComplete &&
                      nextDraft.termsAccepted &&
                      state.walletSufficient,
              },
        ),
      );
    }
  }

  bool back() {
    if (!state.editable || state.step == IssuanceStep.selection) {
      return false;
    }
    {
      final nextDraft = state.draft;
      emit(
        state.copyWith(
          step:
              state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
              ? IssuanceStep.selection
              : IssuanceStep.delivery,
          failure: null,
          canContinue:
              state.editable &&
              switch ((state.step == IssuanceStep.delivery ||
                      state.draft.noPhysicalCard
                  ? IssuanceStep.selection
                  : IssuanceStep.delivery)) {
                IssuanceStep.selection => state.selectionComplete,
                IssuanceStep.delivery =>
                  state.selectionComplete && state.deliveryComplete,
                IssuanceStep.confirmation =>
                  state.selectionComplete &&
                      state.deliveryComplete &&
                      nextDraft.termsAccepted &&
                      state.walletSufficient,
              },
        ),
      );
    }
    return true;
  }

  Future<void> submit() async {
    if (state.step != IssuanceStep.confirmation || !state.canContinue) {
      return;
    }
    final request = state.request!;
    final generation = _generation;
    {
      final nextDraft = state.draft;
      final nextEditable = checkEditable(
        state.status,
        (RequestStatus.loading),
        state.catalog,
      );
      emit(
        state.copyWith(
          submissionStatus: RequestStatus.loading,
          failure: null,
          editable: nextEditable,
          canContinue:
              nextEditable &&
              switch (state.step) {
                IssuanceStep.selection => state.selectionComplete,
                IssuanceStep.delivery =>
                  state.selectionComplete && state.deliveryComplete,
                IssuanceStep.confirmation =>
                  state.selectionComplete &&
                      state.deliveryComplete &&
                      nextDraft.termsAccepted &&
                      state.walletSufficient,
              },
        ),
      );
    }
    Result<IssuanceReceipt> result;
    try {
      result = await _submitter(request);
    } catch (_) {
      result = const Err(UnexpectedFailure());
    }
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        {
          final nextDraft = state.draft;
          final nextEditable = checkEditable(
            state.status,
            (RequestStatus.failure),
            state.catalog,
          );
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              failure: failure,
              editable: nextEditable,
              canContinue:
                  nextEditable &&
                  switch (state.step) {
                    IssuanceStep.selection => state.selectionComplete,
                    IssuanceStep.delivery =>
                      state.selectionComplete && state.deliveryComplete,
                    IssuanceStep.confirmation =>
                      state.selectionComplete &&
                          state.deliveryComplete &&
                          nextDraft.termsAccepted &&
                          state.walletSufficient,
                  },
            ),
          );
        }
      case Success(:final data):
        {
          final nextDraft = state.draft;
          final nextEditable = checkEditable(
            state.status,
            (RequestStatus.success),
            state.catalog,
          );
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
              editable: nextEditable,
              canContinue:
                  nextEditable &&
                  switch (state.step) {
                    IssuanceStep.selection => state.selectionComplete,
                    IssuanceStep.delivery =>
                      state.selectionComplete && state.deliveryComplete,
                    IssuanceStep.confirmation =>
                      state.selectionComplete &&
                          state.deliveryComplete &&
                          nextDraft.termsAccepted &&
                          state.walletSufficient,
                  },
            ),
          );
        }
    }
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }

  IssuanceDeposit? getDeposit(IssuanceCatalog? catalog, IssuanceDraft draft) {
    return catalog?.deposits.where((d) => d.id == draft.depositId).firstOrNull;
  }

  IssuanceAddress? getAddress(IssuanceCatalog? catalog, IssuanceDraft draft) {
    return catalog?.addresses.where((a) => a.id == draft.addressId).firstOrNull;
  }

  bool checkSelection(
    IssuanceCatalog? catalog,
    IssuanceDraft draft,
    IssuanceDeposit? deposit,
  ) {
    return deposit != null &&
        draft.type != null &&
        (catalog?.types.contains(draft.type) ?? false);
  }

  bool checkDelivery(IssuanceDraft draft, IssuanceAddress? address) {
    return draft.noPhysicalCard ||
        (address != null &&
            (!draft.otherRecipient || draft.recipient.isComplete) &&
            (!draft.includeAgent || draft.agent.isComplete));
  }

  List<IssuanceFee> getFees(IssuanceCatalog? catalog, IssuanceDraft draft) {
    return catalog?.fees
            .where(
              (fee) =>
                  !draft.noPhysicalCard || fee.kind != IssuanceFeeKind.delivery,
            )
            .toList() ??
        <IssuanceFee>[];
  }

  bool checkEditable(
    RequestStatus status,
    RequestStatus submissionStatus,
    IssuanceCatalog? catalog,
  ) {
    return status == RequestStatus.success &&
        submissionStatus != RequestStatus.loading &&
        submissionStatus != RequestStatus.success &&
        catalog?.deposits.isNotEmpty == true &&
        catalog?.types.isNotEmpty == true;
  }
}
