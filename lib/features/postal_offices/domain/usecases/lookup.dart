import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/postal_office.dart';
import '../repositories/postal_offices_repository.dart';

class FetchPostalProvinces {
  const FetchPostalProvinces(this.repository);
  final PostalOfficesRepository repository;
  Future<Result<List<PostalProvince>>> call() async {
    try {
      return await repository.fetchProvinces();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class FetchPostalOffices {
  const FetchPostalOffices(this.repository);
  final PostalOfficesRepository repository;
  Future<Result<List<PostalOffice>>> call(String cityId) async {
    try {
      return await repository.fetchPostalOffices(cityId);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
