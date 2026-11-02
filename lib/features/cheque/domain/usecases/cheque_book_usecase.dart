import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/cheque_book.dart';
import '../repositories/cheque_book_repository.dart';

class FetchChequeBookCatalogUseCase {
  const FetchChequeBookCatalogUseCase(this.repository);
  final ChequeBookRepository repository;
  Future<Result<ChequeBookCatalog>> call() async {
    try {
      return await repository.fetchCatalog();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class CheckChequeBookResidencyUseCase {
  const CheckChequeBookResidencyUseCase(this.repository);
  final ChequeBookRepository repository;
  Future<Result<ChequeBookResidency>> call(String depositId) async {
    try {
      return await repository.checkResidency(depositId);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class DeleteChequeBookResidenceUseCase {
  const DeleteChequeBookResidenceUseCase(this.repository);
  final ChequeBookRepository repository;
  Future<Result<ChequeBookResidency>> call(
    String depositId,
    DeliveryAddress address,
  ) async {
    try {
      return await repository.deleteResidence(depositId, address);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SaveChequeBookDeliveryAddressUseCase {
  const SaveChequeBookDeliveryAddressUseCase(this.repository);
  final ChequeBookRepository repository;
  Future<Result<DeliveryAddress>> call(DeliveryAddress address) async {
    try {
      return await repository.saveDeliveryAddress(address);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class FetchChequeBookQuoteUseCase {
  const FetchChequeBookQuoteUseCase(this.repository);
  final ChequeBookRepository repository;
  Future<Result<ChequeBookQuote>> call(ChequeBookDraft draft) async {
    try {
      return await repository.fetchQuote(draft);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitChequeBookUseCase {
  const SubmitChequeBookUseCase(this.repository);
  final ChequeBookRepository repository;
  Future<Result<ChequeBookReceipt>> call(ChequeBookRequest request) async {
    try {
      return await repository.submitIssuance(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
