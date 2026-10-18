import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/listed_deposit.dart';
import '../../domain/repositories/deposits_repository.dart';

/// Figma examples only; no bank operation or persistent storage.
class MockDepositsRepository implements DepositsRepository {
  MockDepositsRepository({Iterable<ListedDeposit>? deposits})
    : deposits = List.unmodifiable(deposits ?? examples);
  final List<ListedDeposit> deposits;
  static const owners = [
    DepositOwner(name: 'بهار مبارک', nationalId: '0081234567', percent: 50),
    DepositOwner(name: 'الهام غریبی', nationalId: '0081234567', percent: 50),
  ];
  static final examples = [
    ListedDeposit(id: 'savings-1', number: '10-122-1234567-1', owners: owners),
    ListedDeposit(id: 'savings-2', number: '10-122-1234567-1', owners: owners),
    ListedDeposit(
      id: 'current-1',
      number: '10-122-1234567-2',
      kind: DepositKind.current,
      owners: owners,
    ),
  ];
  @override
  Future<Result<List<ListedDeposit>>> getDeposits() async => Success(deposits);
}
