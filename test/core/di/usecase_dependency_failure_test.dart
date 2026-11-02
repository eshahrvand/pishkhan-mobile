import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/profile/data/repositories/mock_personal_information_repository.dart';
import 'package:pishkhan_mobile/features/profile/domain/entities/personal_information.dart';
import 'package:pishkhan_mobile/features/profile/domain/repositories/personal_information_repository.dart';
import 'package:pishkhan_mobile/features/profile/presentation/change_phone/cubit/change_phone_cubit.dart';
import 'package:pishkhan_mobile/features/requests/data/repositories/mock_request_reports_repository.dart';
import 'package:pishkhan_mobile/features/requests/domain/entities/request_report.dart';
import 'package:pishkhan_mobile/features/requests/domain/repositories/request_reports_repository.dart';
import 'package:pishkhan_mobile/features/requests/presentation/reports/cubit/request_reports_cubit.dart';

class _FailingPhoneSettingsRepository
    extends MockPersonalInformationRepository {
  bool fail = true;

  @override
  Future<Result<PhoneSettings>> fetchPhoneSettings() => fail
      ? Future.error(StateError('unexpected asynchronous adapter error'))
      : super.fetchPhoneSettings();
}

class _FailingReportsRepository extends MockRequestReportsRepository {
  bool fail = true;

  @override
  Future<Result<RequestReportCatalog>> fetchReports() {
    if (fail) throw StateError('unexpected synchronous adapter error');
    return super.fetchReports();
  }
}

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  test('registered phone UseCase terminates loading after an async adapter exception and can recover', () async {
    final repository = _FailingPhoneSettingsRepository();
    await getIt.unregister<PersonalInformationRepository>();
    getIt.registerSingleton<PersonalInformationRepository>(repository);
    final cubit = ChangePhoneCubit();
    addTearDown(cubit.close);
    await cubit.fetchSettings();
    expect(cubit.state.settingsStatus, RequestStatus.failure);
    expect(cubit.state.failure, const UnexpectedFailure());
    expect(cubit.state.message, isNotEmpty);
    repository.fail = false;
    await cubit.fetchSettings();
    expect(cubit.state.settingsStatus, RequestStatus.success);
    expect(cubit.state.settings, isNotNull);
  });

  test('registered reports UseCase maps a synchronous exception and supports the same-owner retry', () async {
    final repository = _FailingReportsRepository();
    await getIt.unregister<RequestReportsRepository>();
    getIt.registerSingleton<RequestReportsRepository>(repository);
    final cubit = RequestReportsCubit();
    addTearDown(cubit.close);
    await cubit.fetchReports();
    expect(cubit.state.reportsStatus, RequestStatus.failure);
    expect(cubit.state.failure, const UnexpectedFailure());
    repository.fail = false;
    await cubit.fetchReports();
    expect(cubit.state.reportsStatus, RequestStatus.success);
    expect(cubit.state.bankTime, isNotNull);
    expect(cubit.state.failure, const UnexpectedFailure());
  });
}
