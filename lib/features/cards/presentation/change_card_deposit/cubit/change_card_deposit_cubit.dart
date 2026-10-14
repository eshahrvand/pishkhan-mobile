import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../../../domain/usecases/card_services.dart';
import 'change_card_deposit_state.dart';
export 'change_card_deposit_state.dart';

class ChangeCardDepositCubit extends Cubit<ChangeCardDepositState> {
  ChangeCardDepositCubit({
    ChangeCardDepositState initialState = const ChangeCardDepositState(),
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
    _updateState(const ChangeCardDepositState(status: RequestStatus.loading));
    final result = await LoadCardServiceCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        _updateState(
          ChangeCardDepositState(
            status: RequestStatus.failure,
            failure: failure,
          ),
        );
      case Success(:final data):
        final number = _number(initialCardNumber ?? '');
        final card = data.cards
            .where((c) => _number(c.number) == number)
            .firstOrNull;
        _updateState(
          ChangeCardDepositState(
            status: RequestStatus.success,
            catalog: data,
            cardId: card?.id,
          ),
        );
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
    _updateState(
      state.copyWith(
        cardId: id,
        destinationId: null,
        termsAccepted: false,
        submissionStatus: RequestStatus.initial,
        failure: null,
      ),
    );
  }

  void selectDestination(String id) {
    if (!state.editable ||
        id == state.destinationId ||
        !state.destinations.any((d) => d.id == id)) {
      return;
    }
    _key = null;
    _updateState(
      state.copyWith(
        destinationId: id,
        termsAccepted: false,
        submissionStatus: RequestStatus.initial,
        failure: null,
      ),
    );
  }

  void acceptTerms(bool value) {
    if (state.editable) _updateState(state.copyWith(termsAccepted: value));
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
    _updateState(
      state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
    );
    final result = await cardServiceBoundary(
      () => repository.changeDeposit(request),
    );
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        _updateState(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
          ),
        );
      case Success(:final data):
        _updateState(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
          ),
        );
    }
  }

  // Calculate dependent data once, before emitting a consistent snapshot.
  void _updateState(ChangeCardDepositState next) {
    final card = next.catalog?.cards
        .where((c) => c.id == next.cardId)
        .firstOrNull;
    final source = next.catalog?.deposits
        .where((d) => d.id == card?.depositId)
        .firstOrNull;
    final destinations =
        next.catalog?.deposits.where((d) => d.id != source?.id).toList() ??
        <CardServiceDeposit>[];
    final destination = destinations
        .where((d) => d.id == next.destinationId)
        .firstOrNull;
    final editable =
        next.status == RequestStatus.success &&
        next.submissionStatus != RequestStatus.loading &&
        next.submissionStatus != RequestStatus.success;
    final walletSufficient =
        next.catalog != null &&
        next.catalog!.walletBalanceRial >= next.catalog!.changeDepositFeeRial;
    emit(
      next.copyWith(
        card: card,
        source: source,
        destinations: destinations,
        destination: destination,
        isEmpty:
            next.catalog?.cards.isEmpty == true ||
            next.catalog?.deposits.isEmpty == true,
        editable: editable,
        walletSufficient: walletSufficient,
        canSubmit:
            editable &&
            card != null &&
            source != null &&
            destination != null &&
            next.termsAccepted &&
            walletSufficient,
      ),
    );
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
