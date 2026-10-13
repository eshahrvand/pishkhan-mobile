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
  ChangeCardDepositCubit({required this.repository, this.initialCardNumber})
    : super(const ChangeCardDepositState());
  final CardServicesRepository repository;
  final String? initialCardNumber;
  int _generation = 0;
  String? _key;
  Future<void> load() async {
    if (state.submissionStatus == RequestStatus.loading) return;
    final generation = ++_generation;
    _key = null;
    emit(const ChangeCardDepositState(status: RequestStatus.loading));
    final result = await LoadCardServiceCatalog(repository)();
    if (isClosed || generation != _generation) return;
    switch (result) {
      case Err(:final failure):
        emit(
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
        emit(
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
    emit(
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
    emit(
      state.copyWith(
        destinationId: id,
        termsAccepted: false,
        submissionStatus: RequestStatus.initial,
        failure: null,
      ),
    );
  }

  void acceptTerms(bool value) {
    if (state.editable) emit(state.copyWith(termsAccepted: value));
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
    emit(
      state.copyWith(submissionStatus: RequestStatus.loading, failure: null),
    );
    final result = await cardServiceBoundary(
      () => repository.changeDeposit(request),
    );
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
