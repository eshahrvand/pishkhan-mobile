import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/wallet.dart';

abstract interface class WalletRepository {
  Future<Result<WalletCatalog>> fetchCatalog();
  Future<Result<WalletOtpChallenge>> requestOtp(
    WalletTransactionType type,
    int amountRial,
  );
  Future<Result<WalletReceipt>> charge(WalletPaymentRequest request);
  Future<Result<WalletReceipt>> withdraw(WalletPaymentRequest request);
  Future<Result<WalletRecipient>> inquireRecipient(String destination);
  Future<Result<WalletReceipt>> transfer(WalletTransferRequest request);
  Future<Result<WalletSummary>> changeLinkedDeposit(
    WalletDeposit deposit,
    String idempotencyKey,
  );
  Future<Result<List<WalletReceipt>>> fetchTransactions(
    WalletTransactionFilter filter,
  );
}
