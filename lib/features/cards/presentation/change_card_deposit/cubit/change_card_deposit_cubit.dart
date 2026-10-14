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
    required this.repository,
    this.initialCardNumber,
  }) : super(initialState);
  final CardServicesRepository repository;
  final String? initialCardNumber;
  int _generation = 0;
  String? _key;

  Future<void> load() async {
    if (state.submissionStatus == RequestStatus.loading) return;
    final generation = ++_generation;
    _key = null;
    {
      final nextCard = getCard(
        (null as CardServiceCatalog?),
        (null as String?),
      );
      final nextSource = getSource((null as CardServiceCatalog?), nextCard);
      final nextDestinations = getDestinations(
        (null as CardServiceCatalog?),
        nextSource,
      );
      final nextDestination = getDestination(
        (null as String?),
        nextDestinations,
      );
      final nextEditable = checkEditable(
        (RequestStatus.loading),
        (RequestStatus.initial),
      );
      final nextWalletSufficient = checkWalletSufficient(
        (null as CardServiceCatalog?),
      );
      emit(
        ChangeCardDepositState.initial(
          status: RequestStatus.loading,
          card: nextCard,
          source: nextSource,
          destinations: nextDestinations,
          destination: nextDestination,
          isEmpty:
              (null as CardServiceCatalog?)?.cards.isEmpty == true ||
              (null as CardServiceCatalog?)?.deposits.isEmpty == true,
          editable: nextEditable,
          walletSufficient: nextWalletSufficient,
          canSubmit: false,
        ),
      );
    }
    final result = await LoadCardServiceCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        {
          final nextCard = getCard(
            (null as CardServiceCatalog?),
            (null as String?),
          );
          final nextSource = getSource((null as CardServiceCatalog?), nextCard);
          final nextDestinations = getDestinations(
            (null as CardServiceCatalog?),
            nextSource,
          );
          final nextDestination = getDestination(
            (null as String?),
            nextDestinations,
          );
          final nextEditable = checkEditable(
            (RequestStatus.failure),
            (RequestStatus.initial),
          );
          final nextWalletSufficient = checkWalletSufficient(
            (null as CardServiceCatalog?),
          );
          emit(
            ChangeCardDepositState.initial(
              status: RequestStatus.failure,
              failure: failure,
              card: nextCard,
              source: nextSource,
              destinations: nextDestinations,
              destination: nextDestination,
              isEmpty:
                  (null as CardServiceCatalog?)?.cards.isEmpty == true ||
                  (null as CardServiceCatalog?)?.deposits.isEmpty == true,
              editable: nextEditable,
              walletSufficient: nextWalletSufficient,
              canSubmit: false,
            ),
          );
        }
      case Success(:final data):
        final number = _number(initialCardNumber ?? '');
        final card = data.cards
            .where((c) => _number(c.number) == number)
            .firstOrNull;
        {
          final nextCard = getCard((data), (card?.id));
          final nextSource = getSource((data), nextCard);
          final nextDestinations = getDestinations((data), nextSource);
          final nextDestination = getDestination(
            (null as String?),
            nextDestinations,
          );
          final nextEditable = checkEditable(
            (RequestStatus.success),
            (RequestStatus.initial),
          );
          final nextWalletSufficient = checkWalletSufficient((data));
          emit(
            ChangeCardDepositState.initial(
              status: RequestStatus.success,
              catalog: data,
              cardId: card?.id,
              card: nextCard,
              source: nextSource,
              destinations: nextDestinations,
              destination: nextDestination,
              isEmpty:
                  (data).cards.isEmpty == true ||
                  (data).deposits.isEmpty == true,
              editable: nextEditable,
              walletSufficient: nextWalletSufficient,
              canSubmit: false,
            ),
          );
        }
    }
  }

  String _number(String value) =>
      DigitNormalizer.normalize(value).replaceAll(RegExp(r'[^0-9]'), '');

  void selectCard(String id) {
    if (!state.editable ||
        id == state.cardId ||
        !state.catalog!.cards.any((c) => c.id == id)) {
      return;
    }
    _key = null;
    {
      final nextCard = getCard(state.catalog, (id));
      final nextSource = getSource(state.catalog, nextCard);
      final nextDestinations = getDestinations(state.catalog, nextSource);
      final nextDestination = getDestination((null), nextDestinations);
      final nextEditable = checkEditable(state.status, (RequestStatus.initial));
      emit(
        state.copyWith(
          cardId: id,
          destinationId: null,
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
          card: nextCard,
          source: nextSource,
          destinations: nextDestinations,
          destination: nextDestination,
          editable: nextEditable,
          canSubmit: false,
        ),
      );
    }
  }

  void selectDestination(String id) {
    if (!state.editable ||
        id == state.destinationId ||
        !state.destinations.any((d) => d.id == id)) {
      return;
    }
    _key = null;
    {
      final nextDestination = getDestination((id), state.destinations);
      final nextEditable = checkEditable(state.status, (RequestStatus.initial));
      emit(
        state.copyWith(
          destinationId: id,
          termsAccepted: false,
          submissionStatus: RequestStatus.initial,
          failure: null,
          destination: nextDestination,
          editable: nextEditable,
          canSubmit: false,
        ),
      );
    }
  }

  void acceptTerms(bool value) {
    if (state.editable) {
      emit(
        state.copyWith(
          termsAccepted: value,
          canSubmit:
              state.editable &&
              state.card != null &&
              state.source != null &&
              state.destination != null &&
              (value) &&
              state.walletSufficient,
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
    final request = ChangeCardDepositRequest(
      cardId: state.cardId!,
      sourceDepositId: state.source!.id,
      destinationDepositId: state.destinationId!,
      idempotencyKey: _key!,
    );
    final generation = ++_generation;
    {
      final nextEditable = checkEditable(state.status, (RequestStatus.loading));
      emit(
        state.copyWith(
          submissionStatus: RequestStatus.loading,
          failure: null,
          editable: nextEditable,
          canSubmit:
              nextEditable &&
              state.card != null &&
              state.source != null &&
              state.destination != null &&
              state.termsAccepted &&
              state.walletSufficient,
        ),
      );
    }
    final result = await cardServiceBoundary(
      () => repository.changeDeposit(request),
    );
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        {
          final nextEditable = checkEditable(
            state.status,
            (RequestStatus.failure),
          );
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              failure: failure,
              editable: nextEditable,
              canSubmit:
                  nextEditable &&
                  state.card != null &&
                  state.source != null &&
                  state.destination != null &&
                  state.termsAccepted &&
                  state.walletSufficient,
            ),
          );
        }
      case Success(:final data):
        {
          final nextEditable = checkEditable(
            state.status,
            (RequestStatus.success),
          );
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
              editable: nextEditable,
              canSubmit:
                  nextEditable &&
                  state.card != null &&
                  state.source != null &&
                  state.destination != null &&
                  state.termsAccepted &&
                  state.walletSufficient,
            ),
          );
        }
    }
  }

  // Calculate dependent data once, before emitting a consistent snapshot.

  @override
  Future<void> close() {
    _generation++;
    return super.close();
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
