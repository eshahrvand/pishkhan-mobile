import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/card_service_data.dart';
import '../repositories/card_services_repository.dart';

Future<Result<T>> cardServiceBoundary<T>(
  Future<Result<T>> Function() call,
) async {
  try {
    return await call();
  } catch (_) {
    return const Err(UnexpectedFailure());
  }
}

class LoadCardServiceCatalog {
  const LoadCardServiceCatalog(this.repository);
  final CardServicesRepository repository;
  Future<Result<CardServiceCatalog>> call() async {
    final result = await cardServiceBoundary(repository.load);
    if (result is Err<CardServiceCatalog>) return result;
    final catalog = (result as Success<CardServiceCatalog>).data;
    final deposits = catalog.deposits.map((d) => d.id).toSet();
    bool validIds(Iterable<String> ids) {
      final list = ids.toList();
      return list.every((id) => id.trim().isNotEmpty) &&
          list.toSet().length == list.length;
    }

    if (!validIds(catalog.deposits.map((d) => d.id)) ||
        !validIds(catalog.cards.map((c) => c.id)) ||
        !validIds(catalog.gifts.map((c) => c.id)) ||
        catalog.deposits.any((d) => d.number.trim().isEmpty) ||
        catalog.cards.any(
          (c) => c.number.trim().isEmpty || !deposits.contains(c.depositId),
        ) ||
        catalog.gifts.any(
          (c) =>
              c.number.trim().isEmpty ||
              c.balanceRial < 0 ||
              !deposits.contains(c.depositId),
        ) ||
        catalog.changeDepositFeeRial < 0 ||
        catalog.walletBalanceRial < 0) {
      return const Err(DataFailure('card.services.catalog.invalid'));
    }
    return Success(catalog);
  }
}
