import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/card_service_data.dart';

abstract interface class CardServicesRepository {
  Future<Result<CardServiceCatalog>> load();
  Future<Result<CardServiceReceipt>> changeDeposit(
    ChangeCardDepositRequest request,
  );
  Future<Result<CardServiceReceipt>> transferGiftBalance(
    GiftBalanceRequest request,
  );
}
