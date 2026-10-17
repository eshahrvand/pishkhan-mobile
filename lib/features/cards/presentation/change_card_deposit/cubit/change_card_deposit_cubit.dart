import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
export 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../../../domain/usecases/card_services.dart';

part 'change_card_deposit_state.dart';
part 'change_card_deposit_cubit.freezed.dart';

class ChangeCardDepositCubit extends Cubit<ChangeCardDepositState> {
  ChangeCardDepositCubit({
    ChangeCardDepositState initialState =
        const ChangeCardDepositState.initial(),
    this.initialCardNumber,
  }) : super(initialState);
  final repository = getIt<CardServicesRepository>();
  final String? initialCardNumber;
  int _generation = 0;
  String? _key;

  // Loaded entry snapshot, retained only to detect discardable user edits.
  ChangeCardDepositState? _entryState;

  void requestBack() {
    if (state.navigation == FlowNavigation.confirmExit ||
        state.navigation == FlowNavigation.back) {
      return;
    }
    final needsConfirmation =
        state.submissionStatus != RequestStatus.success &&
        state.status == RequestStatus.success &&
        (state.cardId != _entryState?.cardId ||
            state.destinationId != _entryState?.destinationId ||
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

  void exitConfirmationResult(bool? confirmed) {
    emit(
      state.copyWith(
        navigation: confirmed == true ? FlowNavigation.back : null,
        navigationId: state.navigationId + 1,
      ),
    );
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
    if (state.submissionStatus == RequestStatus.loading) return Future.value();
    final generation = ++_generation;
    _key = null;
    emit(
      _derive(
        const ChangeCardDepositState.initial(
          status: RequestStatus.loading,
        ),
      ),
    );
    return LoadCardServiceCatalog(repository)().then((result) {
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Err(:final failure):
          emit(
            _derive(
              ChangeCardDepositState.initial(
                status: RequestStatus.failure,
                failure: failure,
              ),
            ),
          );
        case Success(:final data):
          final number = _number(initialCardNumber ?? '');
          final card = data.cards
              .where((c) => _number(c.number) == number)
              .firstOrNull;
          emit(
            _derive(
              ChangeCardDepositState.initial(
                status: RequestStatus.success,
                catalog: data,
                cardId: card?.id,
              ),
            ),
          );
      }
      if (!isClosed && state.status == RequestStatus.success) {
        _entryState = state;
      }
    });
  }

  String _number(String value) =>
      DigitNormalizer.normalize(value).replaceAll(RegExp(r'[^0-9]'), '');

  void selectCard(String id) {
    if (state.catalog?.cards.any((c) => c.id == id) != true) return;
    if (!state.editable || id == state.cardId) return;
    _key = null;
    emit(
      _derive(
        state.copyWith(
          cardId: id,
          destinationId: null,
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
        ),
      ),
    );
  }

  void selectDestination(String id) {
    if (!state.destinations.any((d) => d.id == id)) return;
    if (!state.editable || id == state.destinationId) return;
    _key = null;
    emit(
      _derive(
        state.copyWith(
          destinationId: id,
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
        ),
      ),
    );
  }

  void acceptTerms(bool value) {
    emit(_derive(state.copyWith(termsAccepted: value)));
  }

  Future<void> submit() {
    if (!state.canSubmit) return Future.value();
    _key ??= List.generate(
      16,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final request = ChangeCardDepositRequest(
      cardId: state.cardId!,
      sourceDepositId: state.source!.id,
      destinationDepositId: state.destinationId!,
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
    return cardServiceBoundary(
      () => repository.changeDeposit(request),
    ).then((result) {
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

  ChangeCardDepositState _derive(ChangeCardDepositState s) {
    final card = getCard(s.catalog, s.cardId);
    final source = getSource(s.catalog, card);
    final destinations = getDestinations(s.catalog, source);
    final destination = getDestination(s.destinationId, destinations);
    final editable = checkEditable(s.status, s.submissionStatus);
    final walletSufficient = checkWalletSufficient(s.catalog);
    final canSubmit = editable &&
        card != null &&
        source != null &&
        destination != null &&
        s.termsAccepted &&
        walletSufficient;

    final isEmpty = s.catalog != null &&
        (s.catalog!.cards.isEmpty || s.catalog!.deposits.isEmpty);

    return s.copyWith(
      card: card,
      source: source,
      destinations: destinations,
      destination: destination,
      isEmpty: isEmpty,
      editable: editable,
      walletSufficient: walletSufficient,
      canSubmit: canSubmit,
    );
  }

  ServiceBankCard? getCard(CardServiceCatalog? catalog, String? cardId) {
    return catalog?.cards.where((c) => c.id == cardId).firstOrNull;
  }

  CardServiceDeposit? getSource(
    CardServiceCatalog? catalog,
    ServiceBankCard? card,
  ) {
    return catalog?.deposits.where((d) => d.id == card?.depositId).firstOrNull;
  }

  List<CardServiceDeposit> getDestinations(
    CardServiceCatalog? catalog,
    CardServiceDeposit? source,
  ) {
    return catalog?.deposits.where((d) => d.id != source?.id).toList() ??
        <CardServiceDeposit>[];
  }

  CardServiceDeposit? getDestination(
    String? destinationId,
    List<CardServiceDeposit> destinations,
  ) {
    return destinations.where((d) => d.id == destinationId).firstOrNull;
  }

  bool checkEditable(RequestStatus status, RequestStatus submissionStatus) {
    return status == RequestStatus.success &&
        submissionStatus != RequestStatus.loading &&
        submissionStatus != RequestStatus.success;
  }

  bool checkWalletSufficient(CardServiceCatalog? catalog) {
    return catalog != null &&
        catalog.walletBalanceRial >= catalog.changeDepositFeeRial;
  }
}
