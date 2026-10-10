import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/validators/second_password_validator.dart';

import '../domain/password_data.dart';

/// Route-session mock status store. No banking operation or SMS is performed.
class MockPasswordServicesRepository implements PasswordServicesRepository {
  MockPasswordServicesRepository({
    PasswordCatalog? catalog,
    Map<String, PasswordRequestRecord> records = const {},
  }) : catalog = catalog ?? sampleCatalog,
       _records = {...records};
  final PasswordCatalog catalog;
  final Map<String, PasswordRequestRecord> _records;
  final Map<String, PasswordRequestRecord> _receipts = {};
  static final sampleCatalog = PasswordCatalog(
    cards: [
      PasswordCard(
        id: 'password-card-1',
        number: '5041721456783407',
        datePinCandidates: ['1405', '0511', '051117'],
      ),
      PasswordCard(id: 'password-card-2', number: '5041721456783415'),
      PasswordCard(id: 'password-card-3', number: '5041721456783423'),
      for (final kind in PasswordCardKind.values.skip(1))
        PasswordCard(
          id: 'password-${kind.name}',
          number: '5041721456783431',
          kind: kind,
        ),
    ],
  );
  @override
  Future<Result<PasswordCatalog>> load() async => Success(catalog);
  @override
  Future<Result<PasswordRequestRecord>> status(String cardId) async => Success(
    _records[cardId] ??
        const PasswordRequestRecord(
          status: PasswordRequestStatus.none,
          isMock: true,
        ),
  );
  @override
  Future<Result<PasswordRequestRecord>> submit(
    SetSecondPasswordRequest request,
  ) async {
    if (_receipts.containsKey(request.idempotencyKey)) {
      return Success(_receipts[request.idempotencyKey]!);
    }
    final cards = catalog.cards.where((c) => c.id == request.cardId);
    if (cards.isEmpty ||
        !cards.first.canSetSecondPassword ||
        !SecondPasswordValidator.isValid(
          request.password,
          cards.first.datePinCandidates,
        ) ||
        !SecondPasswordValidator.validSerial(request.nationalCardSerial) ||
        request.kycReference != 'mock-kyc' ||
        catalog.walletBalanceRial < catalog.feeRial) {
      return const Err(DataFailure('password.request.invalid'));
    }
    final receipt = PasswordRequestRecord(
      status: PasswordRequestStatus.pending,
      trackingCode: '98649466583',
      isMock: true,
    );
    _records[request.cardId] = receipt;
    _receipts[request.idempotencyKey] = receipt;
    return Success(receipt);
  }
}
