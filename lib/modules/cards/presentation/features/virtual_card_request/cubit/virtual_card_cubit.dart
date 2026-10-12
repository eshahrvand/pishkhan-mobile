import 'package:pishkhan_mobile/modules/cards/domain/repositories/virtual_card_repository.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/modules/cards/presentation/features/virtual_card_request/cubit/virtual_card_rules.dart';

import 'dart:math';

import 'package:avp_ui/avp_ui.dart';

import 'virtual_card_state.dart';
export 'virtual_card_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../../domain/entities/virtual_card_data.dart';
import '../../../../domain/usecases/virtual_card_request/virtual_card_usecases.dart';

class VirtualCardCubit extends Cubit<VirtualCardState> {
  VirtualCardCubit({required this.repository, this.initialDepositNumber})
    : super(const VirtualCardState());
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
      ),
    );
    final result = await LoadVirtualCardCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(VirtualCardState(status: RequestStatus.failure, failure: failure));
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
          VirtualCardState(
            status: RequestStatus.success,
            catalog: data,
            depositId: selected,
          ),
        );
    }
  }

  Future<void> selectDeposit(String id) async {
    if (!virtualCardEditable(state) ||
        id == state.depositId ||
        !(state.catalog?.deposits.any((d) => d.id == id) ?? false)) {
      return;
    }
    _key = null;
    emit(
      state.copyWith(depositId: id, quote: null, terms: false, failure: null),
    );
    await refreshQuote();
  }

  Future<void> countChanged(String text) async {
    if (!virtualCardEditable(state)) return;
    final normalized = DigitNormalizer.normalize(text).trim();
    if (normalized == state.countText) return;
    _key = null;
    emit(
      state.copyWith(
        countText: normalized,
        quote: null,
        terms: false,
        failure: null,
      ),
    );
    await refreshQuote();
  }

  Future<void> refreshQuote() async {
    if (!virtualCardEditable(state)) return;
    final generation = ++_generation;
    _key = null;
    if (state.depositId == null || !virtualCardValidCount(state)) {
      emit(
        state.copyWith(
          quoteStatus: RequestStatus.initial,
          quote: null,
          terms: false,
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
      ),
    );
    final result = await QuoteVirtualCards(repository)(
      state.depositId!,
      virtualCardCount(state)!,
    );
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(quoteStatus: RequestStatus.failure, failure: failure),
        );
      case Success(:final data):
        emit(state.copyWith(quoteStatus: RequestStatus.success, quote: data));
    }
  }

  void acceptTerms(bool value) {
    if ((virtualCardEditable(state) &&
        state.quoteStatus != RequestStatus.loading)) {
      emit(state.copyWith(terms: value));
    }
  }

  void setExpanded(bool value) {
    if (virtualCardEditable(state)) emit(state.copyWith(expanded: value));
  }

  Future<void> submit() async {
    if (!virtualCardCanSubmit(state)) return;
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
      state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
    );
    final result = await virtualCardBoundary(() => repository.submit(request));
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
