import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/postal_office.dart';
import '../../domain/repositories/postal_offices_repository.dart';

/// Session-only postal fixtures, independent of any cheque service.
class MockPostalOfficesRepository implements PostalOfficesRepository {
  static final _provinces = [
    PostalProvince(
      id: 'tehran',
      name: 'تهران',
      cities: const [
        PostalCity(id: 'tehran-north-east', name: 'منطقه پستی شمال شرق'),
        PostalCity(id: 'tehran-central', name: 'تهران مرکزی'),
      ],
    ),
    PostalProvince(
      id: 'isfahan',
      name: 'اصفهان',
      cities: const [PostalCity(id: 'isfahan-city', name: 'اصفهان')],
    ),
  ];
  static const _offices = {
    'tehran-north-east': [
      PostalOffice(
        id: 'niavaran',
        address: 'سه راه یاسر، خیابان شهید باهنر، روبروی ساختمان سروش، کارگاه نیاوران',
      ),
      PostalOffice(
        id: 'iranshahr',
        address: 'ایرانشهر جنوبی، نرسیده به انقلاب، کارگاه ایرانشهر',
      ),
    ],
    'tehran-central': [
      PostalOffice(
        id: 'iranshahr',
        address: 'ایرانشهر جنوبی، نرسیده به انقلاب، کارگاه ایرانشهر',
      ),
    ],
    'isfahan-city': <PostalOffice>[],
  };

  @override
  Future<Result<List<PostalProvince>>> fetchProvinces() async =>
      Success(List.unmodifiable(_provinces));

  @override
  Future<Result<List<PostalOffice>>> fetchPostalOffices(String cityId) async {
    final offices = _offices[cityId];
    return offices == null
        ? const Err(DataFailure('postal.city.invalid'))
        : Success(List.unmodifiable(offices));
  }
}
