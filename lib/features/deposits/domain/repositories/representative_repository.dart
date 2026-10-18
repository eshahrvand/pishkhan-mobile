import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/representative_request.dart';

abstract interface class RepresentativeRepository {
  Future<Result<RepresentativeReceipt>> submit(RepresentativeRequest request);
}
