import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/personal_information.dart';
import '../repositories/personal_information_repository.dart';

class FetchProfileAddressesUseCase {
  const FetchProfileAddressesUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<List<ProfileAddress>>> call() async {
    try {
      return await repository.fetchAddresses();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SaveProfileAddressUseCase {
  const SaveProfileAddressUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<ProfileAddress>> call(DeliveryAddress address) async {
    try {
      return await repository.saveAddress(address);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class DeleteProfileAddressUseCase {
  const DeleteProfileAddressUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<void>> call(String id) async {
    try {
      return await repository.deleteAddress(id);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class ReviewProfileAddressUseCase {
  const ReviewProfileAddressUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<ResidenceStatus>> call(DeliveryAddress address) async {
    try {
      return await repository.reviewAddress(address);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class FetchPhoneSettingsUseCase {
  const FetchPhoneSettingsUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<PhoneSettings>> call() async {
    try {
      return await repository.fetchPhoneSettings();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class RequestPhoneChangeOtpUseCase {
  const RequestPhoneChangeOtpUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<PhoneChallenge>> call(String phoneNumber) async {
    try {
      return await repository.requestPhoneOtp(phoneNumber);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class ChangePhoneUseCase {
  const ChangePhoneUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<void>> call({
    required String phoneNumber,
    required String otp,
    required String challengeId,
    required String idempotencyKey,
  }) async {
    try {
      return await repository.changePhone(
        phoneNumber: phoneNumber,
        otp: otp,
        challengeId: challengeId,
        idempotencyKey: idempotencyKey,
      );
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class FetchJobInformationUseCase {
  const FetchJobInformationUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<List<ProfileJobInformation>>> call() async {
    try {
      return await repository.fetchJobInformation();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SaveJobInformationUseCase {
  const SaveJobInformationUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<void>> call(
    ProfileJobInformation jobInformation, {
    required String idempotencyKey,
  }) async {
    try {
      return await repository.saveJobInformation(
        jobInformation,
        idempotencyKey: idempotencyKey,
      );
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class DeleteJobInformationUseCase {
  const DeleteJobInformationUseCase(this.repository);
  final PersonalInformationRepository repository;

  Future<Result<void>> call(String id) async {
    try {
      return await repository.deleteJobInformation(id);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
