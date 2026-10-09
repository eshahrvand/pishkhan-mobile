import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/issuance_data.dart';
import '../../domain/repositories/card_issuance_repository.dart';

class MockCardIssuanceRepository implements CardIssuanceRepository {
  MockCardIssuanceRepository({IssuanceCatalog? catalog})
    : catalog = catalog ?? sampleCatalog;
  final IssuanceCatalog catalog;
  static final sampleCatalog = IssuanceCatalog(
    deposits: const [
      IssuanceDeposit(
        id: 'deposit-1',
        number: '۱۰.۱۲۳۴۵۶۷.۱',
        cardNumber: '۵۰۴۱ ۷۲۱۲ ۲۳۴۵ ۶۷۸۷',
        expiry: '۱۴۰۵/۱۱/۱۷',
      ),
      IssuanceDeposit(
        id: 'deposit-2',
        number: '۱۰.۱۲۰۰۷۰۰.۲۰',
        cardNumber: '۵۰۴۱ ۷۲۱۲ ۳۴۵۶ ۱۲۳۴',
        expiry: '۱۴۰۵/۰۸/۲۰',
      ),
    ],
    addresses: const [
      IssuanceAddress(
        id: 'home',
        title: 'خانه',
        detail: 'تهران - خیابان شریعتی - روبروی خیابان یخچال - بن بست شریف - پلاک ۴ - واحد ۱',
        postalCode: '1912134564',
      ),
    ],
    fees: const [
      IssuanceFee(IssuanceFeeKind.print, 300000),
      IssuanceFee(IssuanceFeeKind.identity, 300000),
      IssuanceFee(IssuanceFeeKind.delivery, 1000000),
    ],
    walletBalanceRial: 2000000,
  );
  @override
  Future<Result<IssuanceCatalog>> load() async => Success(catalog);
  @override
  Future<Result<IssuanceReceipt>> submit(IssuanceRequest request) async =>
      const Success(IssuanceReceipt(reference: 'UI-MOCK-001', isMock: true));
}
