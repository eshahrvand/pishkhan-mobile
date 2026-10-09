import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../entities/dashboard_item.dart';

/// Validates a dashboard snapshot without presentation or network dependencies.
class LoadDashboardItems<T extends DashboardItem> {
  const LoadDashboardItems(this.fetch);
  final Future<Result<List<T>>> Function() fetch;
  Future<Result<List<T>>> call() async {
    try {
      final result = await fetch();
      if (result is Err<List<T>>) return result;
      final items = (result as Success<List<T>>).data;
      final ids = items.map((item) => item.id).toSet();
      if (ids.length != items.length || ids.any((id) => id.trim().isEmpty)) {
        return const Err(DataFailure('dashboard.items.invalid'));
      }
      return Success(
        List.unmodifiable(items.map((item) => item.snapshot() as T)),
      );
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
