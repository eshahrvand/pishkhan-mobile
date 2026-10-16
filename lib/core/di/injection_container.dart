import 'package:get_it/get_it.dart';
import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';

final getIt = GetIt.instance;

/// Register once before runApp. Tests may supply an isolated container.
void configureDependencies({GetIt? container}) {
  final dependencies = container ?? getIt;

  dependencies.registerLazySingleton<DashboardHomeRepository>(
    () => const MockDashboardHomeRepository(),
  );
  dependencies.registerLazySingleton<DashboardCardsRepository>(
    () => const MockDashboardCardsRepository(),
  );
  dependencies.registerLazySingleton<DashboardDepositsRepository>(
    () => const MockDashboardDepositsRepository(),
  );
  dependencies.registerLazySingleton<DashboardLoansRepository>(
    () => const MockDashboardLoansRepository(),
  );
  dependencies.registerLazySingleton<DashboardRepositories>(
    () => DashboardRepositories(
      home: dependencies<DashboardHomeRepository>(),
      cards: dependencies<DashboardCardsRepository>(),
      deposits: dependencies<DashboardDepositsRepository>(),
      loans: dependencies<DashboardLoansRepository>(),
    ),
  );

  // BlocProvider owns each factory-created Cubit and closes it with the route.
  dependencies.registerFactory<HomeCubit>(
    () => HomeCubit(repositories: dependencies<DashboardRepositories>()),
  );
}
