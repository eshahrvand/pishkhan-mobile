import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';

import '../../../domain/entities/wallet.dart';
import '../../../domain/usecases/wallet_usecase.dart';

part 'overview_state.dart';

part 'overview_cubit.freezed.dart';

class WalletOverviewCubit extends Cubit<WalletOverviewState> {
  WalletOverviewCubit({
    WalletOverviewState initialState = const WalletOverviewState.initial(),
  }) : super(initialState);
  final fetchWalletCatalogUseCase = getIt<FetchWalletCatalogUseCase>();

  Future<void> fetchWallet() async {
    emit(state.copyWith(walletStatus: RequestStatus.loading));
    final result = await fetchWalletCatalogUseCase();
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            walletStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            walletStatus: RequestStatus.success,
            wallet: data.wallet,
          ),
        );
    }
  }

  void openCharge() {
    emit(state.copyWith(destination: WalletDestination.charge));
  }

  void openWithdraw() {
    emit(state.copyWith(destination: WalletDestination.withdraw));
  }

  void openTransfer() {
    emit(state.copyWith(destination: WalletDestination.transfer));
  }

  void openLinkedDeposit() {
    emit(state.copyWith(destination: WalletDestination.linkedDeposit));
  }

  void openTransactions() {
    emit(state.copyWith(destination: WalletDestination.transactions));
  }

  void consumeNavigation() {
    emit(state.copyWith(destination: null));
  }

  Future<void> applyFlowReturn(Object? result) async {
    await fetchWallet();
  }
}
