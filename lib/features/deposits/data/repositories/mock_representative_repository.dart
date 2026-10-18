import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/representative_request.dart';
import '../../domain/repositories/representative_repository.dart';

/// In-memory prototype only: grants no authority and makes no bank request.
class MockRepresentativeRepository implements RepresentativeRepository {
  final _requests = <String, RepresentativeRequest>{};
  final _receipts = <String, RepresentativeReceipt>{};

  @override
  Future<Result<RepresentativeReceipt>> submit(
    RepresentativeRequest request,
  ) async {
    final previous = _requests[request.idempotencyKey];
    if (previous != null && previous != request) {
      return const Err(DataFailure('representatives.idempotency.conflict'));
    }
    _requests[request.idempotencyKey] = request;
    final receipt = _receipts.putIfAbsent(
      request.idempotencyKey,
      () => RepresentativeReceipt(
        reference: 'DEMO-REP-${_receipts.length + 1}',
        isMock: true,
      ),
    );
    return Success(receipt);
  }
}
