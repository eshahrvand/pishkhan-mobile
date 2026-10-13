import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../../domain/entities/issuance_data.dart';
import '../../../domain/repositories/card_issuance_repository.dart';
import '../../../domain/usecases/card_issuance.dart';
import 'card_issuance_state.dart';
export 'card_issuance_state.dart';

class CardIssuanceCubit extends Cubit<CardIssuanceState> {
  CardIssuanceCubit({
    CardIssuanceState initialState = const CardIssuanceState(),
    required CardIssuanceRepository repository,
    this.initialDepositNumber,
  }) : _loader = LoadIssuanceCatalog(repository),
       _submitter = SubmitCardIssuance(repository),
       super(_prepareState(initialState));
  LoadIssuanceCatalog _loader;
  SubmitCardIssuance _submitter;
  final String? initialDepositNumber;
  int _generation = 0, _addressCounter = 0;
  Future<void> load() async {
    final generation = ++_generation;
    emit(
      _prepareState(
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
          _prepareState(
            CardIssuanceState(status: RequestStatus.failure, failure: failure),
          ),
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
          _prepareState(
            CardIssuanceState(
              status: RequestStatus.success,
              catalog: data,
              draft: IssuanceDraft(depositId: selected),
            ),
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
    if (!state.editable) return;
    emit(
      _prepareState(
        state.copyWith(
          draft: draft.copyWith(termsAccepted: false),
          failure: null,
        ),
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
    if (!state.editable ||
        title.trim().isEmpty ||
        detail.trim().isEmpty ||
        !PostalCodeValidator.isValid(postal)) {
      return false;
    }
    final address = IssuanceAddress(
      id: 'local-address-${++_addressCounter}',
      title: title.trim(),
      detail: detail.trim(),
      postalCode: postal,
    );
    emit(
      _prepareState(
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
      ),
    );
    return true;
  }

  void removeAddress(String id) {
    if (!state.editable || state.catalog == null) return;
    emit(
      _prepareState(
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
    if (state.editable) {
      emit(
        _prepareState(
          state.copyWith(
            draft: state.draft.copyWith(termsAccepted: value),
            failure: null,
          ),
        ),
      );
    }
  }

  void expandInvoice(bool value) {
    if (state.editable)
      emit(_prepareState(state.copyWith(invoiceExpanded: value)));
  }

  void expandSummary(bool value) {
    if (state.editable)
      emit(_prepareState(state.copyWith(summaryExpanded: value)));
  }

  void next() {
    if (!state.canContinue || state.step == IssuanceStep.confirmation) {
      return;
    }
    emit(
      _prepareState(
        state.copyWith(
          step:
              state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
              ? IssuanceStep.confirmation
              : IssuanceStep.delivery,
        ),
      ),
    );
  }

  bool back() {
    if (!state.editable || state.step == IssuanceStep.selection) {
      return false;
    }
    emit(
      _prepareState(
        state.copyWith(
          step:
              state.step == IssuanceStep.delivery || state.draft.noPhysicalCard
              ? IssuanceStep.selection
              : IssuanceStep.delivery,
          failure: null,
        ),
      ),
    );
    return true;
  }

  Future<void> submit() async {
    if (state.step != IssuanceStep.confirmation || !state.canContinue) {
      return;
    }
    final request = state.request!;
    final generation = _generation;
    emit(
      _prepareState(
        state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
      ),
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
          _prepareState(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              failure: failure,
            ),
          ),
        );
      case Success(:final data):
        emit(
          _prepareState(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
            ),
          ),
        );
    }
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }

  static CardIssuanceState _prepareState(CardIssuanceState next) {
    final draft = next.draft;
    final deposit = next.catalog?.deposits
        .where((d) => d.id == draft.depositId)
        .firstOrNull;
    final address = next.catalog?.addresses
        .where((a) => a.id == draft.addressId)
        .firstOrNull;
    final selection =
        deposit != null &&
        draft.type != null &&
        (next.catalog?.types.contains(draft.type) ?? false);
    final delivery =
        draft.noPhysicalCard ||
        (address != null &&
            (!draft.otherRecipient || draft.recipient.isComplete) &&
            (!draft.includeAgent || draft.agent.isComplete));
    final fees =
        next.catalog?.fees
            .where(
              (fee) =>
                  !draft.noPhysicalCard || fee.kind != IssuanceFeeKind.delivery,
            )
            .toList() ??
        <IssuanceFee>[];
    final total = fees.fold<int>(0, (sum, fee) => sum + fee.amountRial);
    final wallet =
        next.catalog != null && next.catalog!.walletBalanceRial >= total;
    final editable =
        next.status == RequestStatus.success &&
        next.submissionStatus != RequestStatus.loading &&
        next.submissionStatus != RequestStatus.success &&
        next.catalog?.deposits.isNotEmpty == true &&
        next.catalog?.types.isNotEmpty == true;
    return next.copyWith(
      deposit: deposit,
      address: address,
      selectionComplete: selection,
      deliveryComplete: delivery,
      fees: fees,
      totalRial: total,
      walletSufficient: wallet,
      editable: editable,
      canContinue:
          editable &&
          switch (next.step) {
            IssuanceStep.selection => selection,
            IssuanceStep.delivery => selection && delivery,
            IssuanceStep.confirmation =>
              selection && delivery && draft.termsAccepted && wallet,
          },
      request: selection && delivery
          ? IssuanceRequest(
              depositId: deposit.id,
              type: draft.type!,
              noPhysicalCard: draft.noPhysicalCard,
              address: draft.noPhysicalCard ? null : address,
              recipient: !draft.noPhysicalCard && draft.otherRecipient
                  ? draft.recipient
                  : null,
              agent: !draft.noPhysicalCard && draft.includeAgent
                  ? draft.agent
                  : null,
            )
          : null,
    );
  }
}
