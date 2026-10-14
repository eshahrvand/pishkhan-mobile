import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/virtual_card_data.dart';

abstract interface class VirtualCardRepository {
  Future<Result<VirtualCardCatalog>> load();
  Future<Result<VirtualCardQuote>> quote(String depositId, int count);
  Future<Result<VirtualCardReceipt>> submit(VirtualCardRequest request);
}
