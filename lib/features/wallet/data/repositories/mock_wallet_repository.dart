import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

/// In-memory demo ledger. No bank account or real funds are accessed.
class MockWalletRepository implements WalletRepository {
  static const demoOtp = '2345';
  static const deposits = [
    WalletDeposit('d1', '10.12003456.1'),
    WalletDeposit('d2', '10.12003456.2'),
    WalletDeposit('d3', '10.12003456.3'),
  ];
  WalletSummary _wallet = const WalletSummary(
    id: '09121234567',
    balanceRial: 600000,
    linkedDeposit: WalletDeposit('d1', '10.12003456.1'),
  );
  final Map<String, (WalletOtpChallenge, WalletTransactionType, int)>
  _challenges = {};
  final Map<String, WalletReceipt> _receipts = {};
  final Map<String, WalletSummary> _depositChanges = {};
  final List<WalletReceipt> _transactions = List.generate(
    12,
    (i) => WalletReceipt(
      trackingId: 'DEMO-${1000 + i}',
      type: WalletTransactionType.values[i % 4],
      amountRial: (i + 1) * 100000,
      createdAt: DateTime.now().subtract(Duration(days: i * 5)),
      source: '09121234567',
      destination: '09126024179',
      balanceRial: 600000,
    ),
  );

  @override
  Future<Result<WalletCatalog>> fetchCatalog() async => Success(
    WalletCatalog(wallet: _wallet, deposits: deposits, terms: demoTerms),
  );
  @override
  Future<Result<WalletOtpChallenge>> requestOtp(
    WalletTransactionType type,
    int amountRial,
  ) async {
    if (amountRial <= 0) return const Err(DataFailure('wallet.amount.invalid'));
    if (type == WalletTransactionType.withdraw &&
        amountRial > _wallet.balanceRial) {
      return const Err(DataFailure('wallet.balance.insufficient'));
    }
    final challenge = WalletOtpChallenge(
      id: 'demo-${DateTime.now().microsecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(seconds: 60)),
      codeLength: 4,
    );
    _challenges.removeWhere((_, entry) => entry.$2 == type);
    _challenges[challenge.id] = (challenge, type, amountRial);
    return Success(challenge);
  }

  @override
  Future<Result<WalletReceipt>> charge(WalletPaymentRequest request) async =>
      _pay(request, WalletTransactionType.charge);
  @override
  Future<Result<WalletReceipt>> withdraw(WalletPaymentRequest request) async =>
      _pay(request, WalletTransactionType.withdraw);
  Result<WalletReceipt> _pay(
    WalletPaymentRequest request,
    WalletTransactionType type,
  ) {
    final existing = _receipts[request.idempotencyKey];
    if (existing != null) return Success(existing);
    final challenge = _challenges[request.challengeId];
    if (challenge == null ||
        challenge.$2 != type ||
        challenge.$3 != request.amountRial) {
      return const Err(DataFailure('wallet.otp.invalid'));
    }
    if (!challenge.$1.expiresAt.isAfter(DateTime.now())) {
      return const Err(DataFailure('wallet.otp.expired'));
    }
    if (request.otp != demoOtp) {
      return const Err(DataFailure('wallet.otp.invalid'));
    }
    if (request.amountRial <= 0) {
      return const Err(DataFailure('wallet.amount.invalid'));
    }
    if (type == WalletTransactionType.withdraw &&
        request.amountRial > _wallet.balanceRial) {
      return const Err(DataFailure('wallet.balance.insufficient'));
    }
    final receipt = _record(
      type,
      request.amountRial,
      type == WalletTransactionType.charge
          ? _wallet.linkedDeposit.number
          : _wallet.id,
      type == WalletTransactionType.charge
          ? _wallet.id
          : _wallet.linkedDeposit.number,
      request.idempotencyKey,
    );
    _challenges.remove(request.challengeId);
    return Success(receipt);
  }

  @override
  Future<Result<WalletRecipient>> inquireRecipient(String destination) async {
    if (destination == _wallet.id) {
      return const Err(DataFailure('wallet.recipient.self'));
    }
    // Only known demo recipients resolve; arbitrary identifiers never acquire a fabricated owner.
    return switch (destination) {
      '09126024179' || '10000001' => const Success(
        WalletRecipient(id: '09126024179', name: 'مهسا جوانمرد'),
      ),
      '09121111111' || '10000002' => const Success(
        WalletRecipient(id: '09121111111', name: 'علی رضایی'),
      ),
      _ => const Err(DataFailure('wallet.recipient.not-found')),
    };
  }

  @override
  Future<Result<WalletReceipt>> transfer(WalletTransferRequest request) async {
    final existing = _receipts[request.idempotencyKey];
    if (existing != null) return Success(existing);
    if (!const {'09126024179', '09121111111'}.contains(request.recipientId)) {
      return const Err(DataFailure('wallet.recipient.not-found'));
    }
    if (request.amountRial <= 0) {
      return const Err(DataFailure('wallet.amount.invalid'));
    }
    if (request.amountRial > _wallet.balanceRial) {
      return const Err(DataFailure('wallet.balance.insufficient'));
    }
    return Success(
      _record(
        WalletTransactionType.transfer,
        request.amountRial,
        _wallet.id,
        request.recipientId,
        request.idempotencyKey,
      ),
    );
  }

  WalletReceipt _record(
    WalletTransactionType type,
    int amount,
    String source,
    String destination,
    String key,
  ) {
    final balance =
        _wallet.balanceRial +
        (type == WalletTransactionType.charge ? amount : -amount);
    _wallet = WalletSummary(
      id: _wallet.id,
      balanceRial: balance,
      linkedDeposit: _wallet.linkedDeposit,
    );
    final receipt = WalletReceipt(
      trackingId: 'DEMO-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      amountRial: amount,
      createdAt: DateTime.now(),
      source: source,
      destination: destination,
      balanceRial: balance,
    );
    _receipts[key] = receipt;
    _transactions.insert(0, receipt);
    return receipt;
  }

  @override
  Future<Result<WalletSummary>> changeLinkedDeposit(
    WalletDeposit deposit,
    String idempotencyKey,
  ) async {
    final previous = _depositChanges[idempotencyKey];
    if (previous != null) return Success(previous);
    if (!deposits.contains(deposit) || deposit == _wallet.linkedDeposit) {
      return const Err(DataFailure('wallet.deposit.invalid'));
    }
    _wallet = WalletSummary(
      id: _wallet.id,
      balanceRial: _wallet.balanceRial,
      linkedDeposit: deposit,
    );
    _depositChanges[idempotencyKey] = _wallet;
    return Success(_wallet);
  }

  @override
  Future<Result<List<WalletReceipt>>> fetchTransactions(
    WalletTransactionFilter filter,
  ) async {
    return Success(
      List.unmodifiable(
        _transactions.where(
          (t) =>
              (filter.types.isEmpty || filter.types.contains(t.type)) &&
              (filter.from == null || !t.createdAt.isBefore(filter.from!)) &&
              (filter.to == null ||
                  t.createdAt.isBefore(
                    filter.to!.add(const Duration(days: 1)),
                  )) &&
              (filter.minRial == null || t.amountRial >= filter.minRial!) &&
              (filter.maxRial == null || t.amountRial <= filter.maxRial!),
        ),
      ),
    );
  }

  static const demoTerms =
      'ضوابط و شرایط کیف پول الکترونیک\n\nکیف الکترونیکی پول: ابزاری است که توسط بانک صادر می‌شود و امکان پرداخت وجه از دارنده آن به پذیرنده را فراهم می‌سازد.\n\nسقف تراکنش کیف پول در هر تراکنش ۲۰,۰۰۰,۰۰۰ ریال، سقف شارژ و خرید روزانه ۵۰,۰۰۰,۰۰۰ ریال و حداکثر مانده ۳۰۰,۰۰۰,۰۰۰ ریال است.\n\nدر تراکنش کاهش موجودی کیف، مبلغ صرفاً به حساب بانکی مبدأ انجام تراکنش قابل واریز است. در صورت مشاهده بهره‌برداری از خدمت کیف جهت انجام اعمال مجرمانه، بانک می‌تواند نسبت به توقف ارائه خدمت اقدام و مراتب را به مراجع ذی‌صلاح اعلام نماید.\n\nاین متن و مقادیر، نمونه نمایشی برگرفته از طراحی هستند؛ سیاست‌های نهایی باید از سرویس بانک دریافت شوند.';
}
