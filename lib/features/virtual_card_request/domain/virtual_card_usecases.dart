import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import 'virtual_card_data.dart';

Future<Result<T>> virtualCardBoundary<T>(
  Future<Result<T>> Function() call,
) async {
  try {
    return await call();
  } catch (_) {
    return const Err(UnexpectedFailure());
  }
}

class LoadVirtualCardCatalog {
  const LoadVirtualCardCatalog(this.repository);
  final VirtualCardRepository repository;
  Future<Result<VirtualCardCatalog>> call() async {
    final result = await virtualCardBoundary(repository.load);
    if (result is Err<VirtualCardCatalog>) return result;
    final data = (result as Success<VirtualCardCatalog>).data;
    final ids = data.deposits.map((d) => d.id).toSet();
    if (ids.length != data.deposits.length ||
        ids.any((id) => id.trim().isEmpty) ||
        data.deposits.any((d) => d.number.trim().isEmpty) ||
        data.indicativePerCardFeeRial < 0 ||
        data.maxCount < 1 ||
        data.maxCount > 999999) {
      return const Err(DataFailure('virtual.catalog.invalid'));
    }
    return Success(data);
  }
}

class QuoteVirtualCards {
  const QuoteVirtualCards(this.repository);
  final VirtualCardRepository repository;
  Future<Result<VirtualCardQuote>> call(String depositId, int count) async {
    final result = await virtualCardBoundary(
      () => repository.quote(depositId, count),
    );
    if (result is Err<VirtualCardQuote>) return result;
    final data = (result as Success<VirtualCardQuote>).data;
    if (data.id.trim().isEmpty ||
        data.depositId != depositId ||
        data.count != count ||
        data.perCardFeeRial < 0 ||
        data.totalRial < 0 ||
        data.walletBalanceRial < 0) {
      return const Err(DataFailure('virtual.quote.invalid'));
    }
    return Success(data);
  }
}
