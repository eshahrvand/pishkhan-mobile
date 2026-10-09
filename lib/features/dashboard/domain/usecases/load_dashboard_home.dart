import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../entities/dashboard_home_data.dart';
import '../repositories/dashboard_repositories.dart';

class LoadDashboardHome {
  const LoadDashboardHome(this.repository);
  final DashboardHomeRepository repository;
  Future<Result<DashboardHomeData?>> call() async {
    try {
      return await repository.getHome();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
