import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:pishkhan_mobile/features/wallet/domain/entities/wallet.dart';

void main() {
  for (final entry in const {
    '09126024179': 'مهسا جوانمرد',
    '10000001': 'مهسا جوانمرد',
    '09121111111': 'علی رضایی',
    '10000002': 'علی رضایی',
  }.entries) {
    test('inquiry resolves the documented owner of ${entry.key}', () async {
      final result = await MockWalletRepository().inquireRecipient(entry.key);
      expect(result, isA<Success<WalletRecipient>>());
      expect((result as Success<WalletRecipient>).data.name, entry.value);
    });
  }

  for (final destination in [
    '09128888888',
    '10000003',
    '09129999999',
    '09121234567',
  ]) {
    test(
      'unresolved/self destination $destination cannot debit the ledger',
      () async {
        final repository = MockWalletRepository();
        expect(await repository.inquireRecipient(destination), isA<Err>());
        expect(
          await repository.transfer(
            WalletTransferRequest(
              recipientId: destination,
              amountRial: 100000,
              idempotencyKey: 'unknown',
            ),
          ),
          isA<Err>(),
        );
        final catalog =
            await repository.fetchCatalog() as Success<WalletCatalog>;
        expect(catalog.data.wallet.balanceRial, 600000);
        final transactions = await repository.fetchTransactions(
          const WalletTransactionFilter(),
        ) as Success<List<WalletReceipt>>;
        expect(transactions.data, hasLength(12));
      },
    );
  }

  for (final type in [
    WalletTransactionType.charge,
    WalletTransactionType.withdraw,
  ]) {
    test(
      '$type rejects arbitrary wrong OTP without consuming the valid challenge',
      () async {
        final repository = MockWalletRepository();
        final challenge = await repository.requestOtp(
          type,
          100000,
        ) as Success<WalletOtpChallenge>;
        Future<Result<WalletReceipt>> pay(String otp) {
          final request = WalletPaymentRequest(
            amountRial: 100000,
            challengeId: challenge.data.id,
            otp: otp,
            idempotencyKey: 'payment',
          );
          return type == WalletTransactionType.charge
              ? repository.charge(request)
              : repository.withdraw(request);
        }

        expect(await pay('9876'), isA<Err>());
        final before =
            await repository.fetchCatalog() as Success<WalletCatalog>;
        expect(before.data.wallet.balanceRial, 600000);
        expect(
          await pay(MockWalletRepository.demoOtp),
          isA<Success<WalletReceipt>>(),
        );
        final after = await repository.fetchCatalog() as Success<WalletCatalog>;
        expect(
          after.data.wallet.balanceRial,
          type == WalletTransactionType.charge ? 700000 : 500000,
        );
        expect(
          await pay(MockWalletRepository.demoOtp),
          isA<Success<WalletReceipt>>(),
        );
        final retried =
            await repository.fetchCatalog() as Success<WalletCatalog>;
        expect(retried.data.wallet.balanceRial, after.data.wallet.balanceRial);
      },
    );
  }
}
