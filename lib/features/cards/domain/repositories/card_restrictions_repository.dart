import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/card_restriction.dart';
import '../entities/card_service_data.dart';

abstract interface class CardRestrictionsRepository {
  Future<Result<CardRestrictionCatalog>> fetchCatalog(
    CardRestrictionOperation operation,
  );
  Future<Result<CardServiceReceipt>> submitRestriction(
    CardRestrictionRequest request,
  );
}
