import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_tab.dart';

void main() {
  late GetIt container;

  setUp(() {
    container = GetIt.asNewInstance();
    configureDependencies(container: container);
  });
  tearDown(() => container.reset());

  test('repository bundle resolves the registered interface instances', () {
    final repositories = container<DashboardRepositories>();
    expect(identical(repositories, container<DashboardRepositories>()), isTrue);
    expect(
      identical(repositories.home, container<DashboardHomeRepository>()),
      isTrue,
    );
    expect(
      identical(repositories.cards, container<DashboardCardsRepository>()),
      isTrue,
    );
    expect(
      identical(
        repositories.deposits,
        container<DashboardDepositsRepository>(),
      ),
      isTrue,
    );
    expect(
      identical(repositories.loans, container<DashboardLoansRepository>()),
      isTrue,
    );
  });

  test(
    'Home factory creates independent state and does not reuse a closed Cubit',
    () async {
      final first = container<HomeCubit>();
      final second = container<HomeCubit>();
      addTearDown(second.close);
      first.selectTab(AppPrimaryTab.cards);
      expect(second.state.selectedTab, AppPrimaryTab.dashboard);
      await first.close();
      final next = container<HomeCubit>();
      addTearDown(next.close);
      expect(next.isClosed, isFalse);
      expect(next.state.selectedTab, AppPrimaryTab.dashboard);
      await next.load();
      expect(next.state.cards, isNotEmpty);
    },
  );

  test(
    'a replacement interface registration supplies the Cubit data',
    () async {
      await container.unregister<DashboardHomeRepository>();
      container.registerSingleton<DashboardHomeRepository>(
        const MockDashboardHomeRepository(favorites: ['card-issue']),
      );
      final cubit = container<HomeCubit>();
      addTearDown(cubit.close);
      await cubit.loadHome();
      expect(cubit.state.homeData!.favorites, ['card-issue']);
    },
  );
}
