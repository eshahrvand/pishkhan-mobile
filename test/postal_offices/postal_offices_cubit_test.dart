import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/postal_offices/domain/entities/postal_office.dart';
import 'package:pishkhan_mobile/features/postal_offices/domain/repositories/postal_offices_repository.dart';
import 'package:pishkhan_mobile/features/postal_offices/data/repositories/mock_postal_offices_repository.dart';
import 'package:pishkhan_mobile/features/postal_offices/presentation/lookup/cubit/postal_offices_cubit.dart';

class ControlledPostalRepository extends MockPostalOfficesRepository {
  final postalRequests = <Completer<Result<List<PostalOffice>>>>[];
  @override
  Future<Result<List<PostalOffice>>> fetchPostalOffices(String cityId) {
    final result = Completer<Result<List<PostalOffice>>>();
    postalRequests.add(result);
    return result.future;
  }
}

void main() {
  late ControlledPostalRepository repository;
  setUp(() {
    repository = ControlledPostalRepository();
    getIt.registerSingleton<PostalOfficesRepository>(repository);
  });
  tearDown(getIt.reset);
  test(
    'postal search resets dependent city and publishes service results',
    () async {
      final postal = PostalOfficesCubit();
      addTearDown(postal.close);
      await postal.fetchProvinces();
      postal.selectProvince(postal.state.provinces.first);
      postal.selectCity(postal.state.cities.first);
      postal.selectProvince(postal.state.provinces.last);
      expect(postal.state.city, isNull);
      expect(postal.state.canSearchPostalOffices, isFalse);
      postal.selectCity(postal.state.cities.single);
      final lookup = postal.searchPostalOffices();
      repository.postalRequests.single.complete(const Success([]));
      await lookup;
      expect(postal.state.postalOffices, isEmpty);
      expect(postal.state.postalStep, PostalOfficesStep.results);
      expect(postal.state.city!.id, 'isfahan-city');
    },
  );

  test(
    'postal failure retries; sharing uses the actual retrieved offices',
    () async {
      final postal = PostalOfficesCubit();
      addTearDown(postal.close);
      await postal.fetchProvinces();
      postal.selectProvince(postal.state.provinces.first);
      postal.selectCity(postal.state.cities.first);
      var lookup = postal.searchPostalOffices();
      repository.postalRequests.last.complete(
        const Err(DataFailure('offline')),
      );
      await lookup;
      expect(postal.state.postalOfficesStatus, RequestStatus.failure);
      expect(postal.state.postalStep, PostalOfficesStep.location);
      lookup = postal.searchPostalOffices();
      repository.postalRequests.last.complete(
        const Success([
          PostalOffice(id: 'office', address: 'address from service'),
        ]),
      );
      await lookup;
      postal.requestPostalShare();
      expect(postal.state.effect, PostalOfficesEffect.share);
      expect(postal.state.postalShareText, contains('address from service'));
      expect(postal.state.postalShareText, contains(postal.state.city!.name));
      final shareText = postal.state.postalShareText;
      postal.consumePostalOfficesInteraction();
      expect(postal.state.effect, isNull);
      postal.requestPostalShare();
      expect(postal.state.effect, PostalOfficesEffect.share);
      expect(postal.state.postalShareText, shareText);
      postal.requestPostalSearch();
      expect(postal.state.postalStep, PostalOfficesStep.location);
    },
  );
}
