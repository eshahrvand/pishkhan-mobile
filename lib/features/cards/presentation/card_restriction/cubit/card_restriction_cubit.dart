import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';

import '../../../domain/entities/card_restriction.dart';
import '../../../domain/entities/card_service_data.dart';
import '../../../domain/usecases/card_restrictions_usecase.dart';

part 'card_restriction_state.dart';
part 'card_restriction_cubit.freezed.dart';

class CardRestrictionCubit extends Cubit<CardRestrictionState> {
  CardRestrictionCubit({
    required this.operation,
    this.initialCardNumber,
    CardRestrictionState initialState = const CardRestrictionState.initial(),
  }) : super(initialState);
  final CardRestrictionOperation operation;
  final String? initialCardNumber;
  final fetchCardRestrictionCatalogUseCase =
      getIt<FetchCardRestrictionCatalogUseCase>();
  final submitCardRestrictionUseCase = getIt<SubmitCardRestrictionUseCase>();

  Future<void> fetchCatalog() async {
    emit(
      state.copyWith(catalogStatus: RequestStatus.loading, isEditable: false),
    );
    final result = await fetchCardRestrictionCatalogUseCase(operation);
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
        final card = _resolveCard(
          data.cards,
          state.card?.number ?? initialCardNumber,
        );
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            card: card,
            isWalletSufficient: data.walletBalanceRial >= data.feeRial,
            isEditable: true,
            // Refreshing the fee/eligibility quote requires consent again.
            termsAccepted: false,
            canSubmit: false,
            idempotencyKey: data.quoteToken == state.catalog?.quoteToken
                ? state.idempotencyKey
                : _createRequestKey(),
          ),
        );
    }
  }

  void selectCard(RestrictionCard card) {
    emit(
      state.copyWith(
        card: card,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        idempotencyKey: card.id == state.card?.id
            ? state.idempotencyKey
            : _createRequestKey(),
      ),
    );
  }

  void selectReason(CardRestrictionReason reason) {
    emit(
      state.copyWith(
        reason: reason,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        idempotencyKey: reason == state.reason
            ? state.idempotencyKey
            : _createRequestKey(),
      ),
    );
  }

  void updateDescription(String description) {
    emit(
      state.copyWith(
        description: description,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        idempotencyKey: description.trim() == state.description.trim()
            ? state.idempotencyKey
            : _createRequestKey(),
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        hasChanges: true,
        canSubmit: _canSubmit(
          card: state.card,
          reason: state.reason,
          termsAccepted: accepted,
          isWalletSufficient: state.isWalletSufficient,
        ),
      ),
    );
  }

  void updateInvoiceExpanded(bool expanded) {
    emit(state.copyWith(isInvoiceExpanded: expanded));
  }

  Future<void> requestSubmission() async {
    switch (operation) {
      case CardRestrictionOperation.block:
        emit(state.copyWith(effect: CardRestrictionEffect.confirmBlock));
      case CardRestrictionOperation.unblock:
        await submitRestriction();
    }
  }

  Future<void> applyBlockConfirmation(bool? confirmed) async {
    if (confirmed == true) await submitRestriction();
  }

  Future<void> submitRestriction() async {
    final request = CardRestrictionRequest(
      operation: operation,
      cardId: state.card!.id,
      reason: state.reason!,
      description: state.description.trim(),
      quoteToken: state.catalog!.quoteToken,
      idempotencyKey: state.idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
      ),
    );
    final result = await submitCardRestrictionUseCase(request);
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            isEditable: true,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            canSubmit: false,
          ),
        );
    }
  }

  void requestTerms() {
    emit(state.copyWith(effect: CardRestrictionEffect.termsUnavailable));
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.receipt != null
            ? CardRestrictionEffect.home
            : state.hasChanges
            ? CardRestrictionEffect.confirmExit
            : CardRestrictionEffect.back,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    if (confirmed == true) {
      emit(state.copyWith(effect: CardRestrictionEffect.back));
    }
  }

  void consumeInteraction() {
    emit(state.copyWith(effect: null));
  }

  RestrictionCard? _resolveCard(List<RestrictionCard> cards, String? number) {
    final normalized = DigitNormalizer.normalize(number ?? '')
        .replaceAll(RegExp(r'[^0-9]'), '');
    return cards.where((card) => card.number == normalized).firstOrNull;
  }

  bool _canSubmit({
    required RestrictionCard? card,
    required CardRestrictionReason? reason,
    required bool termsAccepted,
    required bool isWalletSufficient,
  }) {
    return card != null &&
        reason != null &&
        termsAccepted &&
        isWalletSufficient;
  }

  String _createRequestKey() =>
      'card-restriction-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
}
