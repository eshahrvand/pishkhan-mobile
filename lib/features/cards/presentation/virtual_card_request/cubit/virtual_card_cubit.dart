import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
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
    this.initialDepositNumber,
  }) : super(initialState);
  final repository = getIt<VirtualCardRepository>();
  final String? initialDepositNumber;
  int _generation = 0;
  String? _key;
  // Loaded entry snapshot, retained only to detect discardable user edits.
  VirtualCardState? _entryState;

  void requestBack() {
    if (state.navigation == FlowNavigation.confirmExit ||
        state.navigation == FlowNavigation.back) {
      return;
    }
    final needsConfirmation =
        state.submissionStatus != RequestStatus.success &&
        state.status == RequestStatus.success &&
        (state.depositId != _entryState?.depositId ||
            state.countText.isNotEmpty ||
            state.terms);
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
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        navigationId: state.navigationId + 1,
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
        navigationId: state.navigationId + 1,
      ),
    );
  }

  Future<void> load() {
    final generation = ++_generation;
    _key = null;
    emit(
      _derive(
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
      ),
    );
    return LoadVirtualCardCatalog(repository)().then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            _derive(
              VirtualCardState.initial(
                status: RequestStatus.failure,
                failure: failure,
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
            _derive(
              VirtualCardState.initial(
                status: RequestStatus.success,
                catalog: data,
                depositId: selected,
              ),
            ),
          );
      }
      if (!isClosed && state.status == RequestStatus.success) {
        _entryState = state;
      }
    });
  }

  Future<void> selectDeposit(String id) {
    if (!state.editable || id == state.depositId) return Future.value();
    _key = null;
    emit(
      _derive(
        state.copyWith(
          depositId: id,
          quote: null,
          terms: false,
          failure: null,
        ),
      ),
    );
    return refreshQuote();
  }

  Future<void> countChanged(String text) {
    if (!state.editable) return Future.value();
    final normalized = DigitNormalizer.normalize(text).trim();
    if (normalized == state.countText) return Future.value();
    _key = null;
    emit(
      _derive(
        state.copyWith(
          countText: normalized,
          quote: null,
          terms: false,
          failure: null,
        ),
      ),
    );
    return refreshQuote();
  }

  Future<void> refreshQuote() {
    final generation = ++_generation;
    _key = null;
    if (state.depositId == null || !state.validCount) {
      emit(
        _derive(
          state.copyWith(
            quoteStatus: RequestStatus.initial,
            quote: null,
            terms: false,
          ),
        ),
      );
      return Future.value();
    }
    emit(
      _derive(
        state.copyWith(
          quoteStatus: RequestStatus.loading,
          quote: null,
          terms: false,
          failure: null,
        ),
      ),
    );
    return QuoteVirtualCards(repository)(
      state.depositId!,
      state.count!,
    ).then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            _derive(
              state.copyWith(
                quoteStatus: RequestStatus.failure,
                failure: failure,
              ),
            ),
          );
        case Success(:final data):
          emit(
            _derive(
              state.copyWith(
                quoteStatus: RequestStatus.success,
                quote: data,
              ),
            ),
          );
      }
    });
  }

  void acceptTerms(bool value) {
    emit(_derive(state.copyWith(terms: value)));
  }

  void setExpanded(bool value) {
    emit(_derive(state.copyWith(expanded: value)));
  }

  Future<void> submit() {
    if (!state.canSubmit) return Future.value();
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
      _derive(
        state.copyWith(
          submissionStatus: RequestStatus.loading,
          failure: null,
        ),
      ),
    );
    return virtualCardBoundary(() => repository.submit(request)).then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            _derive(
              state.copyWith(
                submissionStatus: RequestStatus.failure,
                failure: failure,
              ),
            ),
          );
        case Success(:final data):
          emit(
            _derive(
              state.copyWith(
                submissionStatus: RequestStatus.success,
                receipt: data,
              ),
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

  VirtualCardState _derive(VirtualCardState s) {
    final count = int.tryParse(s.countText);
    final validCount = checkCountValid(s.countText, s.catalog);
    final editable = checkEditable(s.status, s.submissionStatus, s.catalog);
    final canSubmit = checkCanSubmit(
      s.status,
      s.submissionStatus,
      s.catalog,
      s.quoteStatus,
      s.terms,
      s.countText,
      s.quote,
      s.depositId,
    );
    return s.copyWith(
      count: count,
      validCount: validCount,
      editable: editable,
      canSubmit: canSubmit,
    );
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
