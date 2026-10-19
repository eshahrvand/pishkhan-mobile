import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cheque/data/repositories/mock_cheque_book_repository.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_book.dart';

void main() {
  test('mock binds quote to checked account, leaf eligibility, address and exact draft; retries return one receipt', () async {
    final repository = MockChequeBookRepository();
    final catalog =
        (await repository.fetchCatalog() as Success<ChequeBookCatalog>).data;
    final deposit = catalog.deposits.first;
    final residency = (await repository.checkResidency(
      deposit.id,
    ) as Success<ChequeBookResidency>).data;
    final draft = ChequeBookDraft(
      depositId: deposit.id,
      leafCount: 50,
      residencyToken: residency.token,
      address: residency.residences.first.address,
    );
    final quote =
        (await repository.fetchQuote(draft) as Success<ChequeBookQuote>).data;
    final request = ChequeBookRequest(
      draft: draft,
      quoteToken: quote.token,
      idempotencyKey: 'one-request',
    );
    final first = await repository.submitIssuance(request);
    expect(first, isA<Success<ChequeBookReceipt>>());
    final repeated = await repository.submitIssuance(request) as Success<ChequeBookReceipt>;
    expect(repeated.data, (first as Success<ChequeBookReceipt>).data);
    final changed = ChequeBookDraft(
      depositId: deposit.id,
      leafCount: 25,
      residencyToken: residency.token,
      address: draft.address,
    );
    expect(
      await repository.submitIssuance(
        ChequeBookRequest(
          draft: changed,
          quoteToken: quote.token,
          idempotencyKey: 'changed-payload',
        ),
      ),
      isA<Err<ChequeBookReceipt>>(),
    );
    expect(
      await repository.submitIssuance(
        ChequeBookRequest(
          draft: changed,
          quoteToken: quote.token,
          idempotencyKey: 'one-request',
        ),
      ),
      isA<Err<ChequeBookReceipt>>(),
    );
    expect(
      await repository.fetchQuote(
        ChequeBookDraft(
          depositId: 'unowned',
          leafCount: 50,
          residencyToken: residency.token,
          address: draft.address,
        ),
      ),
      isA<Err<ChequeBookQuote>>(),
    );
    expect(
      await repository.fetchQuote(
        ChequeBookDraft(
          depositId: catalog.deposits.last.id,
          leafCount: 50,
          residencyToken: residency.token,
          address: draft.address,
        ),
      ),
      isA<Err<ChequeBookQuote>>(),
    );
    expect(
      await repository.deleteResidence(deposit.id, draft.address),
      isA<Err<ChequeBookResidency>>(),
    );
  });
}
