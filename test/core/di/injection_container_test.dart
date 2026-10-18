import '../../support/registered_dependency.dart';

import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/cubit/deposit_restriction_cubit.dart';

import 'package:pishkhan_mobile/features/deposits/domain/repositories/surplus_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/cubit/close_surplus_deposits_cubit.dart';

import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_certificates_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/financial_certificate_repository.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/cubit/card_features_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_issuance/cubit/card_issuance_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/cubit/virtual_card_cubit.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/cards_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/password_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/virtual_card_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/listed_card.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_list/cubit/deposit_list_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/cubit/average_balance_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/cubit/financial_certificate_cubit.dart';
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
  tearDown(() async {
    await container.reset();
    await getIt.reset();
  });

  test('locator does not register presentation Cubits', () {
    expect(container.isRegistered<DepositRestrictionCubit>(), isFalse);
    expect(
      container<DepositRestrictionsRepository>(),
      same(container<DepositRestrictionsRepository>()),
    );
    expect(container.isRegistered<CloseSurplusDepositsCubit>(), isFalse);
    expect(
      container<SurplusDepositsRepository>(),
      same(container<SurplusDepositsRepository>()),
    );
    expect(container.isRegistered<AuthCubit>(), isFalse);
    expect(container.isRegistered<HomeCubit>(), isFalse);
    expect(container.isRegistered<CardFeaturesCubit>(), isFalse);
    expect(container.isRegistered<CardIssuanceCubit>(), isFalse);
    expect(container.isRegistered<DepositListCubit>(), isFalse);
    expect(container.isRegistered<AverageBalanceCubit>(), isFalse);
    expect(container.isRegistered<FinancialCertificateCubit>(), isFalse);
  });

  test(
    'provider-created feature scopes start independently and can be reopened',
    () async {
      final auth = AuthCubit();
      auth.openChangePhone();
      final nextAuth = AuthCubit();
      expect(nextAuth.state, const AuthState.initial());
      await auth.close();
      await nextAuth.close();
      final first =
          withRegisteredDependency<DepositsRepository, DepositListCubit>(
            container<DepositsRepository>(),
            () => DepositListCubit(),
          );
      await first.fetchDeposits();
      first.selectStatusFilter(null);
      final second =
          withRegisteredDependency<DepositsRepository, DepositListCubit>(
            container<DepositsRepository>(),
            () => DepositListCubit(),
          );
      expect(second.state, const DepositListState.initial());
      await first.close();
      await second.fetchDeposits();
      expect(second.state.visibleDeposits, isNotEmpty);
      await second.close();
      final average =
          withRegisteredDependency<
            DepositCertificatesRepository,
            AverageBalanceCubit
          >(
            container<DepositCertificatesRepository>(),
            () => AverageBalanceCubit(),
          );
      final financial =
          withRegisteredDependency<
            FinancialCertificateRepository,
            FinancialCertificateCubit
          >(
            container<FinancialCertificateRepository>(),
            () => FinancialCertificateCubit(),
          );
      expect(average.state, const AverageBalanceState.initial());
      expect(financial.state, const FinancialCertificateState.initial());
      await average.close();
      await financial.close();
    },
  );

  test(
    'constructors preserve supplied snapshots until explicit initialization',
    () async {
      const cardsSeed = CardFeaturesState.initial(searchQuery: '123');
      final cards =
          withRegisteredDependency<CardsRepository, CardFeaturesCubit>(
            container<CardsRepository>(),
            () => CardFeaturesCubit(
              initialState: cardsSeed,
              initialCategory: CardCategory.gift,
            ),
          );
      const issuanceSeed = CardIssuanceState.initial(totalRial: 123);
      final issuance =
          withRegisteredDependency<CardIssuanceRepository, CardIssuanceCubit>(
            container<CardIssuanceRepository>(),
            () => CardIssuanceCubit(initialState: issuanceSeed),
          );
      const passwordSeed = SecondPasswordState.initial(isPasswordVisible: true);
      final password =
          withRegisteredDependency<
            PasswordServicesRepository,
            SecondPasswordCubit
          >(
            container<PasswordServicesRepository>(),
            () => SecondPasswordCubit(initialState: passwordSeed),
          );
      const virtualSeed = VirtualCardState.initial(countText: '2');
      final virtual =
          withRegisteredDependency<VirtualCardRepository, VirtualCardCubit>(
            container<VirtualCardRepository>(),
            () => VirtualCardCubit(initialState: virtualSeed),
          );
      expect(cards.state, cardsSeed);
      expect(issuance.state, issuanceSeed);
      expect(password.state, passwordSeed);
      expect(virtual.state, virtualSeed);
      await cards.fetchCards();
      expect(cards.state.category, CardCategory.gift);
      expect(cards.state.footerAction, isNotNull);
      await cards.close();
      await issuance.close();
      await password.close();
      await virtual.close();
    },
  );

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

  test('Direct Home construction creates independent state and does not reuse a closed Cubit', () async {
    final first = withRegisteredDependency<DashboardRepositories, HomeCubit>(
      container<DashboardRepositories>(),
      () => HomeCubit(),
    );
    final second = withRegisteredDependency<DashboardRepositories, HomeCubit>(
      container<DashboardRepositories>(),
      () => HomeCubit(),
    );
    addTearDown(second.close);
    first.selectTab(AppPrimaryTab.cards);
    expect(second.state.selectedTab, AppPrimaryTab.dashboard);
    await first.close();
    final next = withRegisteredDependency<DashboardRepositories, HomeCubit>(
      container<DashboardRepositories>(),
      () => HomeCubit(),
    );
    addTearDown(next.close);
    expect(next.isClosed, isFalse);
    expect(next.state.selectedTab, AppPrimaryTab.dashboard);
    await next.fetchDashboard();
    expect(next.state.visibleCards, isNotEmpty);
  });

  test(
    'a replacement interface registration supplies the Cubit data',
    () async {
      await container.unregister<DashboardHomeRepository>();
      container.registerSingleton<DashboardHomeRepository>(
        const MockDashboardHomeRepository(favorites: ['card-issue']),
      );
      final cubit = withRegisteredDependency<DashboardRepositories, HomeCubit>(
        container<DashboardRepositories>(),
        () => HomeCubit(),
      );
      addTearDown(cubit.close);
      await cubit.fetchHome();
      expect(cubit.state.homeData!.favorites, ['card-issue']);
    },
  );
}
