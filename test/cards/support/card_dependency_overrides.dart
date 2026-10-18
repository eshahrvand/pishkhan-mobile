import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_issuance_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/card_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/cards_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/password_services_repository.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/virtual_card_repository.dart';

Future<void> useCardsRepository(CardsRepository repository) async {
  await getIt.unregister<CardsRepository>();
  getIt.registerSingleton<CardsRepository>(repository);
}

Future<void> useCardIssuanceRepository(
  CardIssuanceRepository repository,
) async {
  await getIt.unregister<CardIssuanceRepository>();
  getIt.registerSingleton<CardIssuanceRepository>(repository);
}

Future<void> useCardServicesRepository(
  CardServicesRepository repository,
) async {
  await getIt.unregister<CardServicesRepository>();
  getIt.registerSingleton<CardServicesRepository>(repository);
}

Future<void> usePasswordRepository(
  PasswordServicesRepository repository,
) async {
  await getIt.unregister<PasswordServicesRepository>();
  getIt.registerSingleton<PasswordServicesRepository>(repository);
}

Future<void> useVirtualCardRepository(VirtualCardRepository repository) async {
  await getIt.unregister<VirtualCardRepository>();
  getIt.registerSingleton<VirtualCardRepository>(repository);
}
