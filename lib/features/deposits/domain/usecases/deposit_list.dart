import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/listed_deposit.dart';
import '../repositories/deposits_repository.dart';

class LoadDeposits {
  const LoadDeposits(this.repository);
  final DepositsRepository repository;
  Future<Result<List<ListedDeposit>>> call() async {
    try {
      final result = await repository.getDeposits();
      if (result is Err<List<ListedDeposit>>) return result;
      final deposits = (result as Success<List<ListedDeposit>>).data;
      if (deposits.any(
            (d) =>
                d.id.trim().isEmpty ||
                d.number.trim().isEmpty ||
                d.owners.any(
                  (o) =>
                      o.name.trim().isEmpty ||
                      o.nationalId.trim().isEmpty ||
                      o.percent < 0 ||
                      o.percent > 100,
                ),
          ) ||
          deposits.map((d) => d.id).toSet().length != deposits.length) {
        return const Err(DataFailure('deposits.catalog.invalid'));
      }
      return Success(List.unmodifiable(deposits));
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
