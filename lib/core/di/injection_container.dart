import 'package:pishkhan_mobile/features/cheque/data/repositories/mock_cheque_book_repository.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_book_repository.dart';
import 'package:pishkhan_mobile/features/cheque/data/repositories/mock_cheque_clearance_repository.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_clearance_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposit_certificates_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_financial_certificate_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_certificates_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/financial_certificate_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_proxy_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/proxy_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposit_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_surplus_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/surplus_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_agent_settings_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/agent_settings_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_agent_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/agent_repository.dart';
import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_cards_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_card_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_password_repository.dart';
import 'package:pishkhan_mobile/features/cards/data/repositories/mock_virtual_card_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/cards_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/password_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/virtual_card_repository.dart';

final getIt = GetIt.instance;

/// Register once before runApp. Tests may supply an isolated container.
void configureDependencies({GetIt? container}) {
  final dependencies = container ?? getIt;
  dependencies.registerLazySingleton<ChequeBookRepository>(
    MockChequeBookRepository.new,
  );
  dependencies.registerLazySingleton<ChequeClearanceRepository>(
    MockChequeClearanceRepository.new,
  );
  dependencies.registerLazySingleton<ProxyDepositsRepository>(
    MockProxyDepositsRepository.new,
  );
  dependencies.registerLazySingleton<DepositRestrictionsRepository>(
    MockDepositRestrictionsRepository.new,
  );
  dependencies.registerLazySingleton<SurplusDepositsRepository>(
    MockSurplusDepositsRepository.new,
  );
  dependencies.registerLazySingleton<AgentSettingsRepository>(
    MockAgentSettingsRepository.new,
  );
  dependencies.registerLazySingleton<DepositsRepository>(
    MockDepositsRepository.new,
  );
  dependencies.registerLazySingleton<AgentRepository>(MockAgentRepository.new);
  dependencies.registerLazySingleton<DepositCertificatesRepository>(
    MockDepositCertificatesRepository.new,
  );
  dependencies.registerLazySingleton<FinancialCertificateRepository>(
    MockFinancialCertificateRepository.new,
  );
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
}
