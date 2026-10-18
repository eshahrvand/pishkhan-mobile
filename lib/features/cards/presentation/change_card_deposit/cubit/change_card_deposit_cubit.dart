import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
        catalogFailure: null,
      ),
    );
    return LoadCardServiceCatalog(_repository)().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.failure,
              catalogFailure: failure,
            ),
          );
        case Success(:final data):
          final card = _entryCard(data);
          final source = data.deposits
              .where((deposit) => deposit.id == card?.depositId)
              .firstOrNull;
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              card: card,
              source: source,
              destinations: data.deposits
                  .where((deposit) => deposit.id != source?.id)
                  .toList(),
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
        destinations: state.catalog!.deposits
            .where((deposit) => deposit.id != source.id)
            .toList(),
        destination: null,
        termsAccepted: false,
        canSubmit: false,
        submissionStatus: RequestStatus.initial,
        submissionFailure: null,
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
        submissionFailure: null,
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit:
            state.card != null &&
            state.destination != null &&
            accepted &&
            state.isWalletSufficient,
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
        submissionFailure: null,
        isEditable: false,
        canSubmit: false,
      ),
    );
    return cardServiceBoundary(() => _repository.changeDeposit(request))
        .then((result) {
          switch (result) {
            case Err(:final failure):
              emit(
                state.copyWith(
                  submissionStatus: RequestStatus.failure,
                  submissionFailure: failure,
                  isEditable: true,
                  canSubmit: state.termsAccepted && state.isWalletSufficient,
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
    final needsConfirmation =
        state.submissionStatus != RequestStatus.success &&
        state.catalogStatus == RequestStatus.success &&
        (state.card != _entryCard(state.catalog!) ||
            state.destination != null ||
            state.termsAccepted);
    emit(
      state.copyWith(
        navigation: needsConfirmation
            ? FlowNavigation.confirmExit
            : FlowNavigation.back,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        navigationId: state.navigationId + 1,
      ),
    );
  }

  ServiceBankCard? _entryCard(CardServiceCatalog catalog) {
    final number = _number(initialCardNumber ?? '');
    return catalog.cards
        .where((card) => _number(card.number) == number)
        .firstOrNull;
  }

  String _number(String value) =>
      DigitNormalizer.normalize(value).replaceAll(RegExp(r'[^0-9]'), '');
}
