import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/cheque_clearance.dart';
import '../../domain/repositories/cheque_clearance_repository.dart';

/// Session-only fixtures. No real cheque, account or banking status is changed.
class MockChequeClearanceRepository implements ChequeClearanceRepository {
  final _requests = <String, ChequeClearanceRequest>{};
  final _receipts = <String, ChequeClearanceReceipt>{};
  static const _cheques = {
    'cheque-deposit-1': ['123/123457', '123/123458'],
    'cheque-deposit-2': ['123/123456', '123/123459'],
  };
  static final _catalog = ChequeClearanceCatalog(
    deposits: const [
      ChequeDeposit(id: 'cheque-deposit-2', number: '10.1234567.2'),
      ChequeDeposit(id: 'cheque-deposit-1', number: '10.1234567.1'),
    ],
    reasons: ChequeClearanceReason.values,
    provinces: [
      PostalProvince(
        id: 'tehran',
        name: 'تهران',
        cities: const [
          PostalCity(id: 'tehran-north-east', name: 'منطقه پستی شمال شرق'),
          PostalCity(id: 'tehran-central', name: 'تهران مرکزی'),
        ],
      ),
      PostalProvince(
        id: 'isfahan',
        name: 'اصفهان',
        cities: const [PostalCity(id: 'isfahan-city', name: 'اصفهان')],
      ),
    ],
    mailingAddress: 'صندوق پستی ۱۶۶۳-۱۳۱۸۵ ، به نام مرکز خزانه داری و مبادلات بانک قرض الحسنه رسالت',
  );
  static const _offices = {
    'tehran-north-east': [
      PostalOffice(
        id: 'niavaran',
        address: 'سه راه یاسر، خیابان شهید باهنر، روبروی ساختمان سروش، کارگاه نیاوران',
      ),
      PostalOffice(
        id: 'iranshahr',
        address: 'ایرانشهر جنوبی، نرسیده به انقلاب، کارگاه ایرانشهر',
      ),
    ],
    'tehran-central': [
      PostalOffice(
        id: 'iranshahr',
        address: 'ایرانشهر جنوبی، نرسیده به انقلاب، کارگاه ایرانشهر',
      ),
    ],
    'isfahan-city': <PostalOffice>[],
  };

  @override
  Future<Result<ChequeClearanceCatalog>> fetchCatalog() async =>
      Success(_catalog);

  @override
  Future<Result<List<PostalOffice>>> fetchPostalOffices(String cityId) async {
    final offices = _offices[cityId];
    return offices == null
        ? const Err(DataFailure('cheque.postal-city-invalid'))
        : Success(List.unmodifiable(offices));
  }

  @override
  Future<Result<ChequeClearanceReceipt>> submitClearance(
    ChequeClearanceRequest request,
  ) async {
    final previous = _requests[request.idempotencyKey];
    if (previous != null) {
      return previous == request
          ? Success(_receipts[request.idempotencyKey]!)
          : const Err(DataFailure('cheque.idempotency-conflict'));
    }
    if (!(_cheques[request.depositId]?.contains(request.chequeNumber) ??
        false)) {
      return const Err(DataFailure('cheque.not-found'));
    }
    if (!_catalog.reasons.contains(request.reason)) {
      return const Err(DataFailure('cheque.reason-unavailable'));
    }
    final receipt = ChequeClearanceReceipt(
      reference: 'DEMO-CHEQUE-${_receipts.length + 1}',
      isMock: true,
    );
    _requests[request.idempotencyKey] = request;
    _receipts[request.idempotencyKey] = receipt;
    return Success(receipt);
  }
}
