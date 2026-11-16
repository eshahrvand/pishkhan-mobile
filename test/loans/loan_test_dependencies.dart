import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/loans/domain/repositories/loan_application_repository.dart';

Future<void> installLoanDependencies(
  LoanApplicationRepository repository,
) async {
  await getIt.reset();
  configureDependencies();
  await getIt.unregister<LoanApplicationRepository>();
  getIt.registerSingleton<LoanApplicationRepository>(repository);
}
