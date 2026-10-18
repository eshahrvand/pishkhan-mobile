import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/representative_request.dart';
import '../repositories/representative_repository.dart';

class SubmitRepresentatives {
  const SubmitRepresentatives(this.repository);
  final RepresentativeRepository repository;

  Future<Result<RepresentativeReceipt>> call(
    RepresentativeRequest request,
  ) async {
    try {
      return await repository.submit(request);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
