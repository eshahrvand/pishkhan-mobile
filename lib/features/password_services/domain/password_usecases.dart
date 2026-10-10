import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import 'password_data.dart';

Future<Result<T>> _boundary<T>(Future<Result<T>> Function() call) async {
  try {
    return await call();
  } catch (_) {
    return const Err(UnexpectedFailure());
  }
}

class LoadPasswordCatalog {
  const LoadPasswordCatalog(this.repository);
  final PasswordServicesRepository repository;
  Future<Result<PasswordCatalog>> call() async {
    final result = await _boundary(repository.load);
    if (result is Err<PasswordCatalog>) return result;
    final data = (result as Success<PasswordCatalog>).data;
    final ids = data.cards.map((card) => card.id).toSet();
    if (ids.length != data.cards.length ||
        ids.any((id) => id.trim().isEmpty) ||
        data.feeRial < 0 ||
        data.walletBalanceRial < 0) {
      return const Err(DataFailure('password.catalog.invalid'));
    }
    return Success(data);
  }
}

class CheckPasswordRequest {
  const CheckPasswordRequest(this.repository);
  final PasswordServicesRepository repository;
  Future<Result<PasswordRequestRecord>> call(String cardId) =>
      _boundary(() => repository.status(cardId));
}

class SubmitSecondPassword {
  const SubmitSecondPassword(this.repository);
  final PasswordServicesRepository repository;
  Future<Result<PasswordRequestRecord>> call(
    SetSecondPasswordRequest request,
  ) => _boundary(() => repository.submit(request));
}
