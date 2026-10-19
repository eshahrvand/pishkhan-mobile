import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/cheque_book.dart';

abstract interface class ChequeBookRepository {
  Future<Result<ChequeBookCatalog>> fetchCatalog();
  Future<Result<ChequeBookResidency>> checkResidency(String depositId);
  Future<Result<ChequeBookResidency>> deleteResidence(
    String depositId,
    DeliveryAddress address,
  );
  Future<Result<DeliveryAddress>> saveDeliveryAddress(DeliveryAddress address);
  Future<Result<ChequeBookQuote>> fetchQuote(ChequeBookDraft draft);
  Future<Result<ChequeBookReceipt>> submitIssuance(ChequeBookRequest request);
}
