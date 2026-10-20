import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/personal_information.dart';

abstract interface class PersonalInformationRepository {
  Future<Result<PhoneSettings>> fetchPhoneSettings();
  Future<Result<PhoneChallenge>> requestPhoneOtp(String phoneNumber);
  Future<Result<void>> changePhone({
    required String phoneNumber,
    required String otp,
    required String challengeId,
    required String idempotencyKey,
  });
  Future<Result<List<ProfileAddress>>> fetchAddresses();
  Future<Result<ProfileAddress>> saveAddress(DeliveryAddress address);
  Future<Result<void>> deleteAddress(String id);
  Future<Result<ResidenceStatus>> reviewAddress(DeliveryAddress address);
  Future<Result<List<ProfileOccupation>>> fetchOccupations();
  Future<Result<void>> saveOccupation(
    ProfileOccupation occupation, {
    required String idempotencyKey,
  });
  Future<Result<void>> deleteOccupation(String id);
}
