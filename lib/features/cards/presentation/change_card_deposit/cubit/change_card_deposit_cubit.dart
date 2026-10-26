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

import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../../../domain/usecases/card_services.dart';

export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';

part 'change_card_deposit_state.dart';
part 'change_card_deposit_cubit.freezed.dart';

class ChangeCardDepositCubit extends Cubit<ChangeCardDepositState> {
  ChangeCardDepositCubit({
    ChangeCardDepositState initialState =
        const ChangeCardDepositState.initial(),
    this.initialCardNumber,
  }) : super(initialState);

  final _repository = getIt<CardServicesRepository>();
  final String? initialCardNumber;
  String? _idempotencyKey;

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return LoadCardServiceCatalog(_repository)().then((result) {
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
          final card = _findInitialCard(data);
          final source = data.deposits
              .where((deposit) => deposit.id == card?.depositId)
              .firstOrNull;
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              card: card,
              source: source,
              destinations: _destinationDeposits(data.deposits, source),
              isCatalogEmpty: data.cards.isEmpty || data.deposits.isEmpty,
              isEditable: true,
              isWalletSufficient:
                  data.walletBalanceRial >= data.changeDepositFeeRial,
            ),
          );
      }
    });
  }

  void selectCard(ServiceBankCard card) {
    final source = state.catalog!.deposits.firstWhere(
      (deposit) => deposit.id == card.depositId,
    );
    _idempotencyKey = null;
    emit(
      state.copyWith(
        card: card,
        source: source,
        destinations: _destinationDeposits(state.catalog!.deposits, source),
        destination: null,
        termsAccepted: false,
        canSubmit: false,
        submissionStatus: RequestStatus.initial,
        failure: null,
        message: null,
      ),
    );
  }

  void selectDestination(CardServiceDeposit destination) {
    _idempotencyKey = null;
    emit(
      state.copyWith(
        destination: destination,
        termsAccepted: false,
        canSubmit: false,
        submissionStatus: RequestStatus.initial,
        failure: null,
        message: null,
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit: _canSubmitDepositChange(termsAccepted: accepted),
      ),
    );
  }

  Future<void> submitDepositChange() {
    _idempotencyKey ??= List.generate(
      16,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final request = ChangeCardDepositRequest(
      cardId: state.card!.id,
      sourceDepositId: state.source!.id,
      destinationDepositId: state.destination!.id,
      idempotencyKey: _idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
        canSubmit: false,
        failure: null,
        message: null,
      ),
    );
    return cardServiceBoundary(() => _repository.changeDeposit(request))
        .then((result) {
          switch (result) {
            case Err(:final failure):
              emit(
                state.copyWith(
                  submissionStatus: RequestStatus.failure,
                  isEditable: true,
                  canSubmit: _canSubmitDepositChange(
                    termsAccepted: state.termsAccepted,
                  ),
                  failure: failure,
                  message: getRequestErrorMessage(failure),
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
        });
  }

  void requestBack() {
    emit(
      state.copyWith(
        navigation: _needsExitConfirmation()
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

  bool _canSubmitDepositChange({required bool termsAccepted}) {
    return state.card != null &&
        state.destination != null &&
        termsAccepted &&
        state.isWalletSufficient;
  }

  bool _needsExitConfirmation() {
    return state.submissionStatus != RequestStatus.success &&
        state.catalogStatus == RequestStatus.success &&
        (state.card != _findInitialCard(state.catalog!) ||
            state.destination != null ||
            state.termsAccepted);
  }

  List<CardServiceDeposit> _destinationDeposits(
    List<CardServiceDeposit> deposits,
    CardServiceDeposit? source,
  ) {
    return deposits.where((deposit) => deposit.id != source?.id).toList();
  }

  ServiceBankCard? _findInitialCard(CardServiceCatalog catalog) {
    final number = _normalizeCardNumber(initialCardNumber ?? '');
    return catalog.cards
        .where((card) => _normalizeCardNumber(card.number) == number)
        .firstOrNull;
  }

  String _normalizeCardNumber(String value) =>
      DigitNormalizer.normalize(value).replaceAll(RegExp(r'[^0-9]'), '');

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeChangeCardDepositInteraction() {
    emit(state.copyWith(navigation: null));
  }
}
