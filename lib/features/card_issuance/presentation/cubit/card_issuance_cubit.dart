import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../domain/entities/issuance_data.dart';
import '../../domain/repositories/card_issuance_repository.dart';
import '../../domain/usecases/issuance_usecases.dart';
import 'card_issuance_state.dart';
export 'card_issuance_state.dart';

class CardIssuanceCubit extends Cubit<CardIssuanceState> {
  CardIssuanceCubit({
    required CardIssuanceRepository repository,
    this.initialDepositNumber,
  }) : _loader = LoadIssuanceCatalog(repository),
       _submitter = SubmitCardIssuance(repository),
       super(const CardIssuanceState());
  LoadIssuanceCatalog _loader;
  SubmitCardIssuance _submitter;
  final String? initialDepositNumber;
  int _generation = 0, _addressCounter = 0;
  Future<void> load() async {
    final generation = ++_generation;
    emit(const CardIssuanceState(status: IssuanceStatus.loading));
    Result<IssuanceCatalog> result;
    try {
      result = await _loader();
    } catch (_) {
      result = const Err(UnexpectedFailure());
    }
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(CardIssuanceState(status: IssuanceStatus.error, failure: failure));
      case Success(:final data):
        String? selected;
        for (final d in data.deposits) {
          if (initialDepositNumber != null &&
              DigitNormalizer.normalize(d.number) ==
                  DigitNormalizer.normalize(initialDepositNumber!)) {
            selected = d.id;
          }
        }
        emit(
          CardIssuanceState(
            status: data.deposits.isEmpty || data.types.isEmpty
                ? IssuanceStatus.empty
                : IssuanceStatus.loaded,
            catalog: data,
            draft: IssuanceDraft(depositId: selected),
          ),
        );
    }
  }

  Future<void> changeRepository(CardIssuanceRepository repository) {
    _loader = LoadIssuanceCatalog(repository);
    _submitter = SubmitCardIssuance(repository);
    return load();
  }

  void _edit(IssuanceDraft draft) {
    if (!state.isEditable) return;
    emit(
      state.copyWith(
        draft: draft.copyWith(termsAccepted: false),
        clearFailure: true,
      ),
    );
  }

  void selectDeposit(String id) {
    if (state.catalog?.deposits.any((d) => d.id == id) ?? false) {
      _edit(state.draft.copyWith(depositId: id));
    }
  }

  void selectType(IssuanceType type) {
    if (state.catalog?.types.contains(type) ?? false) {
      _edit(state.draft.copyWith(type: type));
    }
  }

  void setNoPhysicalCard(bool value) =>
      _edit(state.draft.copyWith(noPhysicalCard: value));
  void selectAddress(String id) {
    if (state.catalog?.addresses.any((a) => a.id == id) ?? false) {
      _edit(state.draft.copyWith(addressId: id));
    }
  }

  bool addAddress({
    required String title,
    required String detail,
    required String postalCode,
  }) {
    final postal = DigitNormalizer.normalize(postalCode).trim();
    if (!state.isEditable ||
        title.trim().isEmpty ||
        detail.trim().isEmpty ||
        !RegExp(r'^[0-9]{10}$').hasMatch(postal)) {
      return false;
    }
    final address = IssuanceAddress(
      id: 'local-address-${++_addressCounter}',
      title: title.trim(),
      detail: detail.trim(),
      postalCode: postal,
    );
    emit(
      state.copyWith(
        catalog: state.catalog!.withAddresses([
          ...state.catalog!.addresses,
          address,
        ]),
        draft: state.draft.copyWith(
          addressId: address.id,
          termsAccepted: false,
        ),
        clearFailure: true,
      ),
    );
    return true;
  }

  void removeAddress(String id) {
    if (!state.isEditable || state.catalog == null) return;
    emit(
      state.copyWith(
        catalog: state.catalog!.withAddresses(
          state.catalog!.addresses.where((a) => a.id != id),
        ),
        draft: state.draft.copyWith(
          clearAddress: state.draft.addressId == id,
          termsAccepted: false,
        ),
        clearFailure: true,
      ),
    );
  }

  void setOtherRecipient(bool value) =>
      _edit(state.draft.copyWith(otherRecipient: value));
  void setIncludeAgent(bool value) =>
      _edit(state.draft.copyWith(includeAgent: value));
  void setRecipient(DeliveryPerson value) => _edit(
    state.draft.copyWith(
      recipient: value.copyWith(
        nationalId: DigitNormalizer.normalize(value.nationalId),
        mobile: DigitNormalizer.normalize(value.mobile),
      ),
    ),
  );
  void setAgent(BankAgent value) => _edit(
    state.draft.copyWith(
      agent: value.copyWith(code: DigitNormalizer.normalize(value.code)),
    ),
  );
  void acceptTerms(bool value) {
    if (state.isEditable) {
      emit(
        state.copyWith(
          draft: state.draft.copyWith(termsAccepted: value),
          clearFailure: true,
        ),
      );
    }
  }

  void expandInvoice(bool value) {
    if (state.isEditable) emit(state.copyWith(invoiceExpanded: value));
  }

  void expandSummary(bool value) {
    if (state.isEditable) emit(state.copyWith(summaryExpanded: value));
  }

  void next() {
    if (!state.canContinue || state.step == IssuanceStep.confirmation) return;
    emit(
      state.copyWith(
        step: state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
            ? IssuanceStep.confirmation
            : IssuanceStep.delivery,
      ),
    );
  }

  bool back() {
    if (!state.isEditable || state.step == IssuanceStep.selection) return false;
    emit(
      state.copyWith(
        step: state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
            ? IssuanceStep.selection
            : IssuanceStep.delivery,
        clearFailure: true,
      ),
    );
    return true;
  }

  Future<void> submit() async {
    if (state.step != IssuanceStep.confirmation || !state.canContinue) return;
    final request = state.request!;
    final generation = _generation;
    emit(state.copyWith(status: IssuanceStatus.submitting, clearFailure: true));
    Result<IssuanceReceipt> result;
    try {
      result = await _submitter(request);
    } catch (_) {
      result = const Err(UnexpectedFailure());
    }
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: IssuanceStatus.loaded, failure: failure));
      case Success(:final data):
        emit(state.copyWith(status: IssuanceStatus.submitted, receipt: data));
    }
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
