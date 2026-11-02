import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/postal_office.dart';

abstract interface class PostalOfficesRepository {
  Future<Result<List<PostalProvince>>> fetchProvinces();
  Future<Result<List<PostalOffice>>> fetchPostalOffices(String cityId);
}
