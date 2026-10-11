import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/cards/presentation/flows/card_issuance/cubit/issuance_rules.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../../domain/entities/issuance_data.dart';
import '../../../../domain/repositories/card_issuance_repository.dart';
import '../../../../domain/usecases/card_issuance/issuance_usecases.dart';
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
      ),
    );
    Result<IssuanceCatalog> result;
    try {
      result = await _loader();
    } catch (_) {
      result = const Err(UnexpectedFailure());
    }
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          CardIssuanceState(status: RequestStatus.failure, failure: failure),
        );
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
            status: RequestStatus.success,
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
    if (!issuanceIsEditable(state)) return;
    emit(
      state.copyWith(
        draft: draft.copyWith(termsAccepted: false),
        failure: null,
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
    if (!issuanceIsEditable(state) ||
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
        failure: null,
      ),
    );
    return true;
  }

  void removeAddress(String id) {
    if (!issuanceIsEditable(state) || state.catalog == null) return;
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
    if (issuanceIsEditable(state)) {
      emit(
        state.copyWith(
          draft: state.draft.copyWith(termsAccepted: value),
          failure: null,
        ),
      );
    }
  }

  void expandInvoice(bool value) {
    if (issuanceIsEditable(state)) emit(state.copyWith(invoiceExpanded: value));
  }

  void expandSummary(bool value) {
    if (issuanceIsEditable(state)) emit(state.copyWith(summaryExpanded: value));
  }

  void next() {
    if (!issuanceCanContinue(state) ||
        state.step == IssuanceStep.confirmation) {
      return;
    }
    emit(
      state.copyWith(
        step: state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
            ? IssuanceStep.confirmation
            : IssuanceStep.delivery,
      ),
    );
  }

  bool back() {
    if (!issuanceIsEditable(state) || state.step == IssuanceStep.selection) {
      return false;
    }
    emit(
      state.copyWith(
        step: state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
            ? IssuanceStep.selection
            : IssuanceStep.delivery,
        failure: null,
      ),
    );
    return true;
  }

  Future<void> submit() async {
    if (state.step != IssuanceStep.confirmation ||
        !issuanceCanContinue(state)) {
      return;
    }
    final request = issuanceRequest(state)!;
    final generation = _generation;
    emit(
      state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
    );
    Result<IssuanceReceipt> result;
    try {
      result = await _submitter(request);
    } catch (_) {
      result = const Err(UnexpectedFailure());
    }
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
