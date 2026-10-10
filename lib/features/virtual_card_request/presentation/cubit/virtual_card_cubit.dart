import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/virtual_card_data.dart';
import '../../domain/virtual_card_usecases.dart';

enum VirtualCardStatus {
  initial,
  loading,
  ready,
  quoting,
  failed,
  empty,
  submitting,
  submitted,
}

class VirtualCardState extends Equatable {
  const VirtualCardState({
    this.status = VirtualCardStatus.initial,
    this.catalog,
    this.depositId,
    this.countText = '',
    this.quote,
    this.terms = false,
    this.expanded = true,
    this.failure,
    this.receipt,
  });
  final VirtualCardStatus status;
  final VirtualCardCatalog? catalog;
  final String? depositId;
  final String countText;
  final VirtualCardQuote? quote;
  final bool terms, expanded;
  final Failure? failure;
  final VirtualCardReceipt? receipt;
  int? get count => int.tryParse(countText);
  bool get validCount =>
      RegExp(r'^[0-9]+$').hasMatch(countText) &&
      count != null &&
      count! >= 1 &&
      count! <= (catalog?.maxCount ?? 0);
  bool get editable =>
      status == VirtualCardStatus.ready || status == VirtualCardStatus.quoting;
  bool get canSubmit =>
      status == VirtualCardStatus.ready &&
      terms &&
      validCount &&
      quote != null &&
      quote!.depositId == depositId &&
      quote!.count == count &&
      quote!.walletSufficient;
  VirtualCardState copyWith({
    VirtualCardStatus? status,
    VirtualCardCatalog? catalog,
    String? depositId,
    String? countText,
    VirtualCardQuote? quote,
    bool clearQuote = false,
    bool? terms,
    bool? expanded,
    Failure? failure,
    bool clearFailure = false,
    VirtualCardReceipt? receipt,
  }) => VirtualCardState(
    status: status ?? this.status,
    catalog: catalog ?? this.catalog,
    depositId: depositId ?? this.depositId,
    countText: countText ?? this.countText,
    quote: clearQuote ? null : quote ?? this.quote,
    terms: terms ?? this.terms,
    expanded: expanded ?? this.expanded,
    failure: clearFailure ? null : failure ?? this.failure,
    receipt: receipt ?? this.receipt,
  );
  @override
  List<Object?> get props => [
    status,
    catalog,
    depositId,
    countText,
    quote,
    terms,
    expanded,
    failure,
    receipt,
  ];
}

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
    emit(const VirtualCardState(status: VirtualCardStatus.loading));
    final result = await LoadVirtualCardCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
          VirtualCardState(status: VirtualCardStatus.failed, failure: failure),
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
          VirtualCardState(
            status: data.deposits.isEmpty
                ? VirtualCardStatus.empty
                : VirtualCardStatus.ready,
            catalog: data,
            depositId: selected,
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
        clearQuote: true,
        terms: false,
        clearFailure: true,
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
        clearQuote: true,
        terms: false,
        clearFailure: true,
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
          status: VirtualCardStatus.ready,
          clearQuote: true,
          terms: false,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: VirtualCardStatus.quoting,
        clearQuote: true,
        terms: false,
        clearFailure: true,
      ),
    );
    final result = await QuoteVirtualCards(repository)(
      state.depositId!,
      state.count!,
    );
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: VirtualCardStatus.ready, failure: failure));
      case Success(:final data):
        emit(state.copyWith(status: VirtualCardStatus.ready, quote: data));
    }
  }

  void acceptTerms(bool value) {
    if (state.status == VirtualCardStatus.ready) {
      emit(state.copyWith(terms: value));
    }
  }

  void setExpanded(bool value) {
    if (state.editable) emit(state.copyWith(expanded: value));
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
      state.copyWith(status: VirtualCardStatus.submitting, clearFailure: true),
    );
    final result = await virtualCardBoundary(() => repository.submit(request));
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(status: VirtualCardStatus.ready, failure: failure));
      case Success(:final data):
        emit(
          state.copyWith(status: VirtualCardStatus.submitted, receipt: data),
        );
    }
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
