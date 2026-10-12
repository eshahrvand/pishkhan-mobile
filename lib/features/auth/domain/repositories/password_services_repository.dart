import 'package:pishkhan_mobile/core/result/result.dart';
import '../entities/password_data.dart';

abstract interface class PasswordServicesRepository {
  Future<Result<PasswordCatalog>> load();
  Future<Result<PasswordRequestRecord>> status(
    String cardId, {
    PasswordOperation operation = PasswordOperation.setSecondPassword,
  });
  Future<Result<PasswordRequestRecord>> submit(
    SetSecondPasswordRequest request,
  );
}
