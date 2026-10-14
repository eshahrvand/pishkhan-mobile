import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/virtual_card_repository.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'dart:math';

import 'package:avp_ui/avp_ui.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/virtual_card_data.dart';
import '../../../domain/usecases/virtual_card_request.dart';

part 'virtual_card_state.dart';
part 'virtual_card_cubit.freezed.dart';

class VirtualCardCubit extends Cubit<VirtualCardState> {
  VirtualCardCubit({
    VirtualCardState initialState = const VirtualCardState.initial(),
    required this.repository,
    this.initialDepositNumber,
  }) : super(initialState) {
    emit(
      initialState.copyWith(
        count: int.tryParse(state.countText),
        validCount: checkCountValid(state.countText, state.catalog),
        editable: checkEditable(
          state.status,
          state.submissionStatus,
          state.catalog,
        ),
        canSubmit: checkCanSubmit(
          state.status,
          state.submissionStatus,
          state.catalog,
          state.quoteStatus,
          state.terms,
          state.countText,
          state.quote,
          state.depositId,
        ),
      ),
    );
  }
  final VirtualCardRepository repository;
  final String? initialDepositNumber;
  int _generation = 0;
  String? _key;
  Future<void> load() async {
    final generation = ++_generation;
    _key = null;
    emit(
      state.copyWith(
        status: RequestStatus.loading,
        quoteStatus: RequestStatus.initial,
        submissionStatus: RequestStatus.initial,
        catalog: null,
        depositId: null,
        countText: '',
        quote: null,
        terms: false,
        expanded: true,
        failure: null,
        receipt: null,
        count: int.tryParse(('')),
        validCount: checkCountValid((''), (null)),
        editable: checkEditable(
          (RequestStatus.loading),
          (RequestStatus.initial),
          (null),
        ),
        canSubmit: checkCanSubmit(
          (RequestStatus.loading),
          (RequestStatus.initial),
          (null),
          (RequestStatus.initial),
          (false),
          (''),
          (null),
          (null),
        ),
      ),
    );
    final result = await LoadVirtualCardCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          VirtualCardState.initial(
            status: RequestStatus.failure,
            failure: failure,
            count: int.tryParse(''),
            validCount: checkCountValid('', null),
            editable: checkEditable(
              (RequestStatus.failure),
              RequestStatus.initial,
              null,
            ),
            canSubmit: checkCanSubmit(
              (RequestStatus.failure),
              RequestStatus.initial,
              null,
              RequestStatus.initial,
              false,
              '',
              null,
              null,
            ),
          ),
        );
      case Success(:final data):
        String? selected;
        for (final d in data.deposits) {
          if (initialDepositNumber != null &&
              DigitNormalizer.normalize(d.number) ==
                  DigitNormalizer.normalize(initialDepositNumber!).trim()) {
            selected = d.id;
          }
        }
        emit(
          VirtualCardState.initial(
            status: RequestStatus.success,
            catalog: data,
            depositId: selected,
            count: int.tryParse(''),
            validCount: checkCountValid('', (data)),
            editable: checkEditable(
              (RequestStatus.success),
              RequestStatus.initial,
              (data),
            ),
            canSubmit: checkCanSubmit(
              (RequestStatus.success),
              RequestStatus.initial,
              (data),
              RequestStatus.initial,
              false,
              '',
              null,
              (selected),
            ),
          ),
        );
    }
  }

  Future<void> selectDeposit(String id) async {
    if (!state.editable ||
        id == state.depositId ||
        !(state.catalog?.deposits.any((d) => d.id == id) ?? false)) {
      return;
    }
    _key = null;
    emit(
      state.copyWith(
        depositId: id,
        quote: null,
        terms: false,
        failure: null,
        count: int.tryParse(state.countText),
        validCount: checkCountValid(state.countText, state.catalog),
        editable: checkEditable(
          state.status,
          state.submissionStatus,
          state.catalog,
        ),
        canSubmit: checkCanSubmit(
          state.status,
          state.submissionStatus,
          state.catalog,
          state.quoteStatus,
          (false),
          state.countText,
          (null),
          (id),
        ),
      ),
    );
    await refreshQuote();
  }

  Future<void> countChanged(String text) async {
    if (!state.editable) return;
    final normalized = DigitNormalizer.normalize(text).trim();
    if (normalized == state.countText) return;
    _key = null;
    emit(
      state.copyWith(
        countText: normalized,
        quote: null,
        terms: false,
        failure: null,
        count: int.tryParse((normalized)),
        validCount: checkCountValid((normalized), state.catalog),
        editable: checkEditable(
          state.status,
          state.submissionStatus,
          state.catalog,
        ),
        canSubmit: checkCanSubmit(
          state.status,
          state.submissionStatus,
          state.catalog,
          state.quoteStatus,
          (false),
          (normalized),
          (null),
          state.depositId,
        ),
      ),
    );
    await refreshQuote();
  }

  Future<void> refreshQuote() async {
    if (!state.editable) return;
    final generation = ++_generation;
    _key = null;
    if (state.depositId == null || !state.validCount) {
      emit(
        state.copyWith(
          quoteStatus: RequestStatus.initial,
          quote: null,
          terms: false,
          count: int.tryParse(state.countText),
          validCount: checkCountValid(state.countText, state.catalog),
          editable: checkEditable(
            state.status,
            state.submissionStatus,
            state.catalog,
          ),
          canSubmit: checkCanSubmit(
            state.status,
            state.submissionStatus,
            state.catalog,
            (RequestStatus.initial),
            (false),
            state.countText,
            (null),
            state.depositId,
          ),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        quoteStatus: RequestStatus.loading,
        quote: null,
        terms: false,
        failure: null,
        count: int.tryParse(state.countText),
        validCount: checkCountValid(state.countText, state.catalog),
        editable: checkEditable(
          state.status,
          state.submissionStatus,
          state.catalog,
        ),
        canSubmit: checkCanSubmit(
          state.status,
          state.submissionStatus,
          state.catalog,
          (RequestStatus.loading),
          (false),
          state.countText,
          (null),
          state.depositId,
        ),
      ),
    );
    final result = await QuoteVirtualCards(repository)(
      state.depositId!,
      state.count!,
    );
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            quoteStatus: RequestStatus.failure,
            failure: failure,
            count: int.tryParse(state.countText),
            validCount: checkCountValid(state.countText, state.catalog),
            editable: checkEditable(
              state.status,
              state.submissionStatus,
              state.catalog,
            ),
            canSubmit: checkCanSubmit(
              state.status,
              state.submissionStatus,
              state.catalog,
              (RequestStatus.failure),
              state.terms,
              state.countText,
              state.quote,
              state.depositId,
            ),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            quoteStatus: RequestStatus.success,
            quote: data,
            count: int.tryParse(state.countText),
            validCount: checkCountValid(state.countText, state.catalog),
            editable: checkEditable(
              state.status,
              state.submissionStatus,
              state.catalog,
            ),
            canSubmit: checkCanSubmit(
              state.status,
              state.submissionStatus,
              state.catalog,
              (RequestStatus.success),
              state.terms,
              state.countText,
              (data),
              state.depositId,
            ),
          ),
        );
    }
  }

  void acceptTerms(bool value) {
    if ((state.editable && state.quoteStatus != RequestStatus.loading)) {
      emit(
        state.copyWith(
          terms: value,
          count: int.tryParse(state.countText),
          validCount: checkCountValid(state.countText, state.catalog),
          editable: checkEditable(
            state.status,
            state.submissionStatus,
            state.catalog,
          ),
          canSubmit: checkCanSubmit(
            state.status,
            state.submissionStatus,
            state.catalog,
            state.quoteStatus,
            (value),
            state.countText,
            state.quote,
            state.depositId,
          ),
        ),
      );
    }
  }

  void setExpanded(bool value) {
    if (state.editable) {
      emit(
        state.copyWith(
          expanded: value,
          count: int.tryParse(state.countText),
          validCount: checkCountValid(state.countText, state.catalog),
          editable: checkEditable(
            state.status,
            state.submissionStatus,
            state.catalog,
          ),
          canSubmit: checkCanSubmit(
            state.status,
            state.submissionStatus,
            state.catalog,
            state.quoteStatus,
            state.terms,
            state.countText,
            state.quote,
            state.depositId,
          ),
        ),
      );
    }
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;
    _key ??= List.generate(
      16,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final request = VirtualCardRequest(
      quote: state.quote!,
      idempotencyKey: _key!,
    );
    final generation = ++_generation;
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        failure: null,
        count: int.tryParse(state.countText),
        validCount: checkCountValid(state.countText, state.catalog),
        editable: checkEditable(
          state.status,
          (RequestStatus.loading),
          state.catalog,
        ),
        canSubmit: checkCanSubmit(
          state.status,
          (RequestStatus.loading),
          state.catalog,
          state.quoteStatus,
          state.terms,
          state.countText,
          state.quote,
          state.depositId,
        ),
      ),
    );
    final result = await virtualCardBoundary(() => repository.submit(request));
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
            count: int.tryParse(state.countText),
            validCount: checkCountValid(state.countText, state.catalog),
            editable: checkEditable(
              state.status,
              (RequestStatus.failure),
              state.catalog,
            ),
            canSubmit: checkCanSubmit(
              state.status,
              (RequestStatus.failure),
              state.catalog,
              state.quoteStatus,
              state.terms,
              state.countText,
              state.quote,
              state.depositId,
            ),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            count: int.tryParse(state.countText),
            validCount: checkCountValid(state.countText, state.catalog),
            editable: checkEditable(
              state.status,
              (RequestStatus.success),
              state.catalog,
            ),
            canSubmit: checkCanSubmit(
              state.status,
              (RequestStatus.success),
              state.catalog,
              state.quoteStatus,
              state.terms,
              state.countText,
              state.quote,
              state.depositId,
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

  bool checkCountValid(String text, VirtualCardCatalog? catalog) {
    final count = int.tryParse(text);
    return RegExp(r'^[0-9]+$').hasMatch(text) &&
        count != null &&
        count >= 1 &&
        count <= (catalog?.maxCount ?? 0);
  }

  bool checkEditable(
    RequestStatus status,
    RequestStatus submissionStatus,
    VirtualCardCatalog? catalog,
  ) {
    return status == RequestStatus.success &&
        catalog?.deposits.isNotEmpty == true &&
        submissionStatus != RequestStatus.loading &&
        submissionStatus != RequestStatus.success;
  }

  bool checkCanSubmit(
    RequestStatus status,
    RequestStatus submissionStatus,
    VirtualCardCatalog? catalog,
    RequestStatus quoteStatus,
    bool terms,
    String countText,
    VirtualCardQuote? quote,
    String? depositId,
  ) {
    final count = int.tryParse(countText);
    return checkEditable(status, submissionStatus, catalog) &&
        quoteStatus == RequestStatus.success &&
        terms &&
        checkCountValid(countText, catalog) &&
        quote != null &&
        quote.depositId == depositId &&
        quote.count == count &&
        quote.walletSufficient;
  }
}
