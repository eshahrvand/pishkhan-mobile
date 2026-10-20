import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/platform/selected_document.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/on_site_transfer.dart';
import '../../domain/repositories/on_site_transfer_repository.dart';

/// Demonstration adapter. Never executes a bank transfer or charges a wallet.
class MockOnSiteTransferRepository implements OnSiteTransferRepository {
  MockOnSiteTransferRepository({this.now});
  final DateTime Function()? now;
  final Map<String, TransferAttachment> _uploads = {};
  final Map<String, OnSiteTransferRequest> _requests = {};
  final Map<String, TransferReceipt> _receipts = {};
  int _sequence = 0;
  static const _deposits = [
    TransferDeposit(id: 'deposit-1', number: '10.10009753.8'),
    TransferDeposit(id: 'deposit-2', number: '10.1234567.2'),
    TransferDeposit(id: 'dashboard-deposit', number: '10.12003456.1'),
    TransferDeposit(id: 'listed-deposit-1', number: '10-122-1234567-1'),
    TransferDeposit(id: 'listed-deposit-2', number: '10-122-1234567-2'),
  ];
  @override
  Future<Result<TransferCatalog>> fetchCatalog() async {
    return Success(
      TransferCatalog(
        deposits: _deposits,
        addresses: const [
          DeliveryAddress(
            id: 'home',
            title: 'خانه',
            detail: 'تهران - خیابان شریعتی - روبروی خیابان یخچال - بن بست شریف - پلاک ۴ - واحد ۱',
            postalCode: '1944629123',
          ),
        ],
        bankTime:
            now?.call() ??
            DateTime.now().toUtc().add(const Duration(hours: 3, minutes: 30)),
      ),
    );
  }

  @override
  Future<Result<TransferDestination>> resolveDestination({
    required String iban,
    required int amountRial,
    required TransferPurpose purpose,
    required String description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return Success(
      TransferDestination(
        id: 'destination-${++_sequence}',
        recipientName: 'گیرنده آزمایشی',
        iban: iban,
        amountRial: amountRial,
        purpose: purpose,
        description: description,
      ),
    );
  }

  @override
  Future<Result<TransferAttachment>> uploadDestinations(
    SelectedDocument file,
    void Function(double) onProgress,
  ) async {
    onProgress(.4);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    final token = 'upload-${++_sequence}';
    final attachment = TransferAttachment(
      token: token,
      name: file.name,
      sizeBytes: file.bytes.length,
    );
    _uploads[token] = attachment;
    return Success(attachment);
  }

  @override
  Future<Result<TransferReceipt>> submit(OnSiteTransferRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final previous = _requests[request.idempotencyKey];
    if (previous != null) {
      return previous == request
          ? Success(_receipts[request.idempotencyKey]!)
          : const Err(DataFailure('transfer.request.changed'));
    }
    // Demo server boundary: identity, attachment ownership and fee authorization.
    if (!_deposits.any((deposit) => deposit.id == request.depositId) ||
        request.feeRial != 1300000 ||
        (request.destinations.isEmpty && request.attachment == null) ||
        (request.attachment != null &&
            _uploads[request.attachment!.token] != request.attachment)) {
      return const Err(DataFailure('transfer.request.invalid'));
    }
    final receipt = TransferReceipt(
      trackingId: 'DEMO-TRANSFER-${++_sequence}',
      feeRial: request.feeRial,
    );
    _requests[request.idempotencyKey] = request;
    _receipts[request.idempotencyKey] = receipt;
    return Success(receipt);
  }
}
