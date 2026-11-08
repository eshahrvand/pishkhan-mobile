import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';

import '../../../domain/entities/wallet.dart';
import '../../../domain/usecases/wallet_usecase.dart';
import '../../../domain/wallet_rules.dart';

part 'linked_deposit_state.dart';
part 'linked_deposit_cubit.freezed.dart';

class WalletLinkedDepositCubit extends Cubit<WalletLinkedDepositState> {
  WalletLinkedDepositCubit({
    WalletLinkedDepositState initialState =
        const WalletLinkedDepositState.initial(),
  }) : super(initialState);
  final fetchWalletCatalogUseCase = getIt<FetchWalletCatalogUseCase>();
  final changeWalletLinkedDepositUseCase =
      getIt<ChangeWalletLinkedDepositUseCase>();
  Future<void> fetchCatalog() async {
    emit(state.copyWith(catalogStatus: RequestStatus.loading));
    final result = await fetchWalletCatalogUseCase();
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
            destinations: data.deposits
                .where((d) => d != data.wallet.linkedDeposit)
                .toList(),
            idempotencyKey: WalletRules.requestKey(),
          ),
        );
    }
  }

  void selectDeposit(WalletDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        canSubmit: state.termsAccepted,
        idempotencyKey: WalletRules.requestKey(),
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit: accepted && state.deposit != null,
      ),
    );
  }

  Future<void> submitChange() async {
    emit(state.copyWith(submissionStatus: RequestStatus.loading));
    final result = await changeWalletLinkedDepositUseCase(
      state.deposit!,
      state.idempotencyKey!,
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success():
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            canSubmit: false,
          ),
        );
    }
  }
}
