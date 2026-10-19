import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cheque/data/repositories/mock_cheque_cancellation_repository.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_cancellation.dart';

void main() {
  test(
    'mock validates ownership, type, reasons, duplicates and request identity',
    () async {
      final repository = MockChequeCancellationRepository();
      final catalog =
          (await repository.fetchCatalog()
                  as Success<ChequeCancellationCatalog>)
              .data;
      final deposit = catalog.deposits.first;
      final cheques = (await repository.fetchCheques(
        deposit.id,
        CancellationChequeType.paper,
      ) as Success<List<CancellableCheque>>).data;
      ChequeCancellationRequest request({
        String? depositId,
        CancellationChequeType type = CancellationChequeType.paper,
        List<ChequeCancellationEntry>? entries,
        String key = 'one',
      }) => ChequeCancellationRequest(
        depositId: depositId ?? deposit.id,
        type: type,
        entries:
            entries ??
            [
              ChequeCancellationEntry(
                cheque: cheques.first,
                reason: ChequeCancellationReason.damagedUnused,
              ),
            ],
        idempotencyKey: key,
      );
      expect(
        await repository.submitCancellation(
          request(depositId: catalog.deposits.last.id),
        ),
        isA<Err>(),
      );
      expect(
        await repository.submitCancellation(
          request(type: CancellationChequeType.digital),
        ),
        isA<Err>(),
      );
      expect(
        await repository.submitCancellation(request(entries: [])),
        isA<Err>(),
      );
      expect(
        await repository.submitCancellation(
          request(entries: [ChequeCancellationEntry(cheque: cheques.first)]),
        ),
        isA<Err>(),
      );
      final duplicate = ChequeCancellationEntry(
        cheque: cheques.first,
        reason: ChequeCancellationReason.damagedUnused,
      );
      expect(
        await repository.submitCancellation(
          request(entries: [duplicate, duplicate]),
        ),
        isA<Err>(),
      );
      final first = (await repository.submitCancellation(
        request(),
      ) as Success<ChequeCancellationReceipt>).data;
      final retry = (await repository.submitCancellation(
        request(),
      ) as Success<ChequeCancellationReceipt>).data;
      expect(retry, first);
      expect(first.isMock, isTrue);
      expect(
        await repository.submitCancellation(
          request(
            entries: [
              ChequeCancellationEntry(
                cheque: cheques.last,
                reason: ChequeCancellationReason.judicialOrder,
              ),
            ],
          ),
        ),
        isA<Err>(),
      );
      expect(
        (await repository.fetchCheques(
          catalog.deposits.last.id,
          CancellationChequeType.digital,
        ) as Success<List<CancellableCheque>>).data,
        isEmpty,
      );
    },
  );
}
