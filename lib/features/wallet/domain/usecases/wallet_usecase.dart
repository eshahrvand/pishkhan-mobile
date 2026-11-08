import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class FetchWalletCatalogUseCase {
  const FetchWalletCatalogUseCase(this.repository);
  final WalletRepository repository;
  Future<Result<WalletCatalog>> call() async {
    try {
      return await repository.fetchCatalog();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class RequestWalletOtpUseCase {
  const RequestWalletOtpUseCase(this.repository);
  final WalletRepository repository;
  Future<Result<WalletOtpChallenge>> call(
    WalletTransactionType type,
    int amountRial,
  ) async {
    try {
      return await repository.requestOtp(type, amountRial);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class ChargeWalletUseCase {
  const ChargeWalletUseCase(this.repository);
  final WalletRepository repository;
  Future<Result<WalletReceipt>> call(WalletPaymentRequest request) async {
    try {
      return await repository.charge(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class WithdrawWalletUseCase {
  const WithdrawWalletUseCase(this.repository);
  final WalletRepository repository;
  Future<Result<WalletReceipt>> call(WalletPaymentRequest request) async {
    try {
      return await repository.withdraw(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class InquireWalletRecipientUseCase {
  const InquireWalletRecipientUseCase(this.repository);
  final WalletRepository repository;
  Future<Result<WalletRecipient>> call(String destination) async {
    try {
      return await repository.inquireRecipient(destination);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class TransferWalletUseCase {
  const TransferWalletUseCase(this.repository);
  final WalletRepository repository;
  Future<Result<WalletReceipt>> call(WalletTransferRequest request) async {
    try {
      return await repository.transfer(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class ChangeWalletLinkedDepositUseCase {
  const ChangeWalletLinkedDepositUseCase(this.repository);
  final WalletRepository repository;
  Future<Result<WalletSummary>> call(
    WalletDeposit deposit,
    String idempotencyKey,
  ) async {
    try {
      return await repository.changeLinkedDeposit(deposit, idempotencyKey);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class FetchWalletTransactionsUseCase {
  const FetchWalletTransactionsUseCase(this.repository);
  final WalletRepository repository;
  Future<Result<List<WalletReceipt>>> call(
    WalletTransactionFilter filter,
  ) async {
    try {
      return await repository.fetchTransactions(filter);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
