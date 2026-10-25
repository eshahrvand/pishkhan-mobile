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
import 'package:pishkhan_mobile/core/validators/virtual_card_count_validator.dart';

import '../../../domain/entities/virtual_card_data.dart';
import '../../../domain/repositories/virtual_card_repository.dart';
import '../../../domain/usecases/virtual_card_request.dart';

export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';

part 'virtual_card_state.dart';
part 'virtual_card_cubit.freezed.dart';

class VirtualCardCubit extends Cubit<VirtualCardState> {
  VirtualCardCubit({
    VirtualCardState initialState = const VirtualCardState.initial(),
    this.initialDepositNumber,
  }) : super(initialState);

  final _repository = getIt<VirtualCardRepository>();
  final String? initialDepositNumber;
  // Count and deposit controls stay available during quoting. Only the latest
  // quote may describe the current form, including when a new count is invalid.
  int _quoteRequestId = 0;
  // The last sent payload owns its key; editing the form does not create a request.
  VirtualCardRequest? _submittedRequest;

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        catalog: null,
        isEditable: false,
        canSubmit: false,
        canRetry: false,
        failure: null,
        message: null,
      ),
    );
    return LoadVirtualCardCatalog(_repository)().then((result) {
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
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              deposit: _entryDeposit(data),
              isEditable: data.deposits.isNotEmpty,
            ),
          );
      }
    });
  }

  Future<void> selectDeposit(VirtualCardDeposit deposit) {
    final requestId = ++_quoteRequestId;
    emit(
      state.copyWith(
        deposit: deposit,
        quoteStatus: state.isCountValid
            ? RequestStatus.loading
            : RequestStatus.initial,
        quote: null,
        termsAccepted: false,
        canSubmit: false,
        retryAction: null,
        canRetry: false,
        failure: null,
        message: null,
      ),
    );
    return state.isCountValid
        ? QuoteVirtualCards(_repository)(deposit.id, state.count!).then((
            result,
          ) {
            if (requestId != _quoteRequestId) return;
            switch (result) {
              case Err(:final failure):
                emit(
                  state.copyWith(
                    quoteStatus: RequestStatus.failure,
                    retryAction: VirtualCardRetryAction.quote,
                    canRetry: true,
                    failure: failure,
                    message: getRequestErrorMessage(failure),
                  ),
                );
              case Success(:final data):
                emit(
                  state.copyWith(
                    quoteStatus: RequestStatus.success,
                    quote: data,
                  ),
                );
            }
          })
        : Future.value();
  }

  Future<void> updateCount(String text) {
    final normalized = DigitNormalizer.normalize(text).trim();
    final count = VirtualCardCountValidator.parseValidCount(
      normalized,
      maxCount: state.catalog!.maxCount,
    );
    final canQuote = state.deposit != null && count != null;
    final requestId = ++_quoteRequestId;
    emit(
      state.copyWith(
        countText: normalized,
        count: count,
        isCountValid: count != null,
        isCountError: normalized.isNotEmpty && count == null,
        quoteStatus: canQuote ? RequestStatus.loading : RequestStatus.initial,
        quote: null,
        termsAccepted: false,
        canSubmit: false,
        retryAction: null,
        canRetry: false,
        failure: null,
        message: null,
      ),
    );
    return canQuote
        ? QuoteVirtualCards(_repository)(state.deposit!.id, count).then((
            result,
          ) {
            if (requestId != _quoteRequestId) return;
            switch (result) {
              case Err(:final failure):
                emit(
                  state.copyWith(
                    quoteStatus: RequestStatus.failure,
                    retryAction: VirtualCardRetryAction.quote,
                    canRetry: true,
                    failure: failure,
                    message: getRequestErrorMessage(failure),
                  ),
                );
              case Success(:final data):
                emit(
                  state.copyWith(
                    quoteStatus: RequestStatus.success,
                    quote: data,
                  ),
                );
            }
          })
        : Future.value();
  }

  Future<void> fetchQuote() {
    final requestId = ++_quoteRequestId;
    emit(
      state.copyWith(
        quoteStatus: RequestStatus.loading,
        quote: null,
        termsAccepted: false,
        canSubmit: false,
        retryAction: null,
        canRetry: false,
        failure: null,
        message: null,
      ),
    );
    return QuoteVirtualCards(_repository)(
      state.deposit!.id,
      state.count!,
    ).then((result) {
      if (requestId != _quoteRequestId) return;
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              quoteStatus: RequestStatus.failure,
              retryAction: VirtualCardRetryAction.quote,
              canRetry: true,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          emit(state.copyWith(quoteStatus: RequestStatus.success, quote: data));
      }
    });
  }

  void updateTermsAcceptance(bool accepted) {
    final canSubmit = accepted && state.quote?.walletSufficient == true;
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit: canSubmit,
        canRetry:
            state.retryAction == VirtualCardRetryAction.quote ||
            state.retryAction == VirtualCardRetryAction.submission && canSubmit,
      ),
    );
  }

  void updateInvoiceExpansion(bool expanded) {
    emit(state.copyWith(isInvoiceExpanded: expanded));
  }

  Future<void> submitRetry() {
    return switch (state.retryAction!) {
      VirtualCardRetryAction.quote => fetchQuote(),
      VirtualCardRetryAction.submission => submitVirtualCards(),
    };
  }

  Future<void> submitVirtualCards() {
    var request = _createRequest(_submittedRequest?.idempotencyKey);
    if (_submittedRequest != null && request != _submittedRequest) {
      request = _createRequest(null);
    }
    _submittedRequest = request;
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
        canSubmit: false,
        canRetry: false,
        failure: null,
        message: null,
      ),
    );
    return virtualCardBoundary(() => _repository.submit(request)).then((
      result,
    ) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              isEditable: true,
              canSubmit: state.termsAccepted && state.quote!.walletSufficient,
              retryAction: VirtualCardRetryAction.submission,
              canRetry: state.termsAccepted && state.quote!.walletSufficient,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
              retryAction: null,
              navigation: FlowNavigation.home,
              message: null,
            ),
          );
      }
    });
  }

  void requestBack() {
    final needsConfirmation =
        state.submissionStatus != RequestStatus.success &&
        state.catalogStatus == RequestStatus.success &&
        (state.deposit != _entryDeposit(state.catalog!) ||
            state.countText.isNotEmpty ||
            state.termsAccepted);
    emit(
      state.copyWith(
        navigation: needsConfirmation
            ? FlowNavigation.confirmExit
            : FlowNavigation.back,
        message: null,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        message: null,
      ),
    );
  }

  VirtualCardDeposit? _entryDeposit(VirtualCardCatalog catalog) {
    final number = DigitNormalizer.normalize(initialDepositNumber ?? '').trim();
    return catalog.deposits
        .where((deposit) => DigitNormalizer.normalize(deposit.number) == number)
        .lastOrNull;
  }

  VirtualCardRequest _createRequest(String? idempotencyKey) {
    return VirtualCardRequest(
      quote: state.quote!,
      idempotencyKey:
          idempotencyKey ??
          List.generate(
            16,
            (_) =>
                Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
          ).join(),
    );
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeVirtualCardInteraction() {
    emit(state.copyWith(navigation: null));
  }
}
