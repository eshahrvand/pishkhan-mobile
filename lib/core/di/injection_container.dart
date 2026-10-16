import 'package:get_it/get_it.dart';
import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_cards_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_card_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_password_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_virtual_card_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/listed_card.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/cards_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/password_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/virtual_card_repository.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/cubit/card_features_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_issuance/cubit/card_issuance_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/change_card_deposit/cubit/change_card_deposit_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/expired_gift_balance/cubit/expired_gift_balance_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/cubit/virtual_card_cubit.dart';

final getIt = GetIt.instance;

/// Register once before runApp. Tests may supply an isolated container.
void configureDependencies({GetIt? container}) {
  final dependencies = container ?? getIt;

  dependencies.registerLazySingleton<CardsRepository>(MockCardsRepository.new);
  dependencies.registerLazySingleton<CardIssuanceRepository>(
    MockCardIssuanceRepository.new,
  );
  dependencies.registerLazySingleton<CardServicesRepository>(
    MockCardServicesRepository.new,
  );
  dependencies.registerLazySingleton<PasswordServicesRepository>(
    MockPasswordServicesRepository.new,
  );
  dependencies.registerLazySingleton<VirtualCardRepository>(
    MockVirtualCardRepository.new,
  );

  dependencies.registerFactoryParam<CardFeaturesCubit, CardCategory, void>(
    (category, _) => CardFeaturesCubit(
      repository: dependencies<CardsRepository>(),
      initialCategory: category,
    ),
  );
  dependencies.registerFactoryParam<CardIssuanceCubit, String?, void>(
    (depositNumber, _) => CardIssuanceCubit(
      repository: dependencies<CardIssuanceRepository>(),
      initialDepositNumber: depositNumber,
    ),
  );
  dependencies.registerFactoryParam<VirtualCardCubit, String?, void>(
    (depositNumber, _) => VirtualCardCubit(
      repository: dependencies<VirtualCardRepository>(),
      initialDepositNumber: depositNumber,
    ),
  );
  dependencies.registerFactoryParam<ChangeCardDepositCubit, String?, void>(
    (cardNumber, _) => ChangeCardDepositCubit(
      repository: dependencies<CardServicesRepository>(),
      initialCardNumber: cardNumber,
    ),
  );
  dependencies.registerFactoryParam<SecondPasswordCubit, (String?, bool), void>(
    (arguments, _) => SecondPasswordCubit(
      repository: dependencies<PasswordServicesRepository>(),
      initialCardNumber: arguments.$1,
      selectOperation: arguments.$2,
    ),
  );
  dependencies.registerFactory<ExpiredGiftBalanceCubit>(
    () => ExpiredGiftBalanceCubit(
      repository: dependencies<CardServicesRepository>(),
    ),
  );

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
