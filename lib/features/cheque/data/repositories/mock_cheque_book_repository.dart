import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/cheque_book.dart';
import '../../domain/repositories/cheque_book_repository.dart';

/// Prototype data only; no bank request, payment or official registry is changed.
class MockChequeBookRepository implements ChequeBookRepository {
  static const _scenario = String.fromEnvironment(
    'CHEQUEBOOK_SCENARIO',
    defaultValue: 'individual-verified',
  );
  final _catalog = ChequeBookCatalog(
    applicant: _scenario == 'legal-verified'
        ? ChequeBookApplicant.legal
        : ChequeBookApplicant.individual,
    deposits: [
      ChequeBookDeposit(
        id: 'deposit-1',
        number: '10.1234567.1',
        openedAt: DateTime.utc(2023, 9, 3),
        leafCounts: [10, 25, 50],
      ),
      ChequeBookDeposit(
        id: 'deposit-2',
        number: '10.1234567.2',
        openedAt: DateTime.utc(2022, 6, 12),
        leafCounts: [10, 25, 50],
      ),
      ChequeBookDeposit(
        id: 'deposit-3',
        number: '10.1234567.3',
        openedAt: DateTime.utc(2026, 9, 3),
        leafCounts: [10, 25],
      ),
    ],
  );
  final _residences = <ChequeBookResidence>[
    if (_scenario == 'mixed-addresses' || _scenario == 'multiple-unverified')
      const ChequeBookResidence(
        address: DeliveryAddress(
          id: 'home-2',
          title: 'خانه دوم',
          detail:
              'تهران - تجریش - ابتدای شریعتی - کوچه پروین - پلاک ۲۰ - واحد ۳',
          postalCode: '1944692133',
        ),
        isRegistered: false,
      ),
    const ChequeBookResidence(
      address: DeliveryAddress(
        id: 'home-1',
        title: 'خانه',
        detail: 'تهران - خیابان شریعتی - روبروی خیابان یخچال - بن بست شریف - پلاک ۴ - واحد ۱',
        postalCode: '1944692133',
      ),
      isRegistered:
          _scenario != 'single-unverified' &&
          _scenario != 'multiple-unverified',
    ),
  ];
  final _deliveryAddresses = <DeliveryAddress>[];
  final _residencyTokens = <String, String>{};
  final _quotes = <String, ({ChequeBookDraft draft, ChequeBookQuote quote})>{};
  final _requests = <String, ChequeBookRequest>{};
  final _receipts = <String, ChequeBookReceipt>{};
  int _sequence = 0;

  ChequeBookResidency _residency(String depositId) {
    final token = 'demo-residency-${++_sequence}';
    _residencyTokens[token] = depositId;
    return ChequeBookResidency(token: token, residences: _residences);
  }

  @override
  Future<Result<ChequeBookCatalog>> fetchCatalog() async => Success(_catalog);

  @override
  Future<Result<ChequeBookResidency>> checkResidency(String depositId) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!_catalog.deposits.any((deposit) => deposit.id == depositId)) {
      return const Err(DataFailure('chequebook.deposit.unavailable'));
    }
    return Success(_residency(depositId));
  }

  @override
  Future<Result<ChequeBookResidency>> deleteResidence(
    String depositId,
    DeliveryAddress address,
  ) async {
    if (_residences.length <= 1 ||
        !_residences.any((residence) => residence.address.id == address.id)) {
      return const Err(DataFailure('chequebook.address.last-or-unavailable'));
    }
    _residences.removeWhere((residence) => residence.address.id == address.id);
    return Success(_residency(depositId));
  }

  @override
  Future<Result<DeliveryAddress>> saveDeliveryAddress(
    DeliveryAddress address,
  ) async {
    final saved = DeliveryAddress(
      id: 'delivery-${++_sequence}',
      title: address.title,
      detail: address.detail,
      postalCode: address.postalCode,
    );
    _deliveryAddresses.add(saved);
    return Success(saved);
  }

  @override
  Future<Result<ChequeBookQuote>> fetchQuote(ChequeBookDraft draft) async {
    final deposit = _catalog.deposits
        .where((deposit) => deposit.id == draft.depositId)
        .firstOrNull;
    if (deposit == null ||
        !deposit.leafCounts.contains(draft.leafCount) ||
        _residencyTokens[draft.residencyToken] != draft.depositId ||
        !_residences.any((residence) => residence.isRegistered) ||
        !(_residences.any(
              (residence) =>
                  residence.isRegistered && residence.address == draft.address,
            ) ||
            _deliveryAddresses.contains(draft.address))) {
      return const Err(DataFailure('chequebook.quote.unavailable'));
    }
    final quote = ChequeBookQuote(
      token: 'demo-quote-${++_sequence}',
      issueFeeRial: 300000,
      deliveryFeeRial: 1000000,
      walletBalanceRial: 2000000,
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
    );
    _quotes[quote.token] = (draft: draft, quote: quote);
    return Success(quote);
  }

  @override
  Future<Result<ChequeBookReceipt>> submitIssuance(
    ChequeBookRequest request,
  ) async {
    if (_requests.containsKey(request.idempotencyKey)) {
      return _requests[request.idempotencyKey] == request
          ? Success(_receipts[request.idempotencyKey]!)
          : const Err(DataFailure('chequebook.idempotency.conflict'));
    }
    final quoted = _quotes[request.quoteToken];
    if (quoted == null ||
        quoted.draft != request.draft ||
        !DateTime.now().toUtc().isBefore(quoted.quote.expiresAt) ||
        quoted.quote.walletBalanceRial <
            quoted.quote.issueFeeRial + quoted.quote.deliveryFeeRial ||
        !_residences.any((residence) => residence.isRegistered)) {
      return const Err(DataFailure('chequebook.quote.invalid'));
    }
    final receipt = ChequeBookReceipt(
      reference: 'DEMO-CHEQUEBOOK-${_receipts.length + 1}',
      isMock: true,
    );
    _requests[request.idempotencyKey] = request;
    _receipts[request.idempotencyKey] = receipt;
    return Success(receipt);
  }
}
