import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/personal_information.dart';
import '../../domain/rules/profile_address_rules.dart';
import '../../domain/repositories/personal_information_repository.dart';

/// Session-local UI prototype. No real Shahkar, residence inquiry, OTP or payment.
class MockPersonalInformationRepository
    implements PersonalInformationRepository {
  String _phone = '09121123454';
  int _walletBalance = 2000000;
  final Map<String, ({String phone, PhoneChallenge challenge})> _challenges =
      {};
  final Set<String> _completedRequests = {};
  final Map<String, ProfileOccupation> _occupationRequests = {};
  List<ProfileAddress> _addresses = const [
    ProfileAddress(
      address: DeliveryAddress(
        id: 'work',
        title: 'محل کار',
        type: DeliveryAddressType.work,
        phoneNumber: '02188261914',
        detail: 'تهران - خیابان آزادی - خیابان دکتر هوشیار - نبش خیابان گرانمایه - پلاک ۱ - واحد ۳',
        postalCode: '1912134564',
      ),
    ),
    ProfileAddress(
      address: DeliveryAddress(
        id: 'home',
        title: 'خانه',
        phoneNumber: '02122261914',
        detail: 'تهران - تجریش - ابتدای خیابان شریعتی - کوچه پروین - پلاک ۲۰ - طبقه ۱ - واحد ۱',
        postalCode: '1912134564',
      ),
    ),
  ];
  List<ProfileOccupation> _occupations = const [
    ProfileOccupation(
      id: 'designer',
      kind: OccupationKind.designer,
      description: 'UI / UX Designer',
    ),
    ProfileOccupation(
      id: 'teacher',
      kind: OccupationKind.teacher,
      description: 'مدرس تجربه کاربری',
    ),
  ];

  Future<Result<T>> _respond<T>(
    T Function() operation, {
    int delay = 250,
  }) async {
    try {
      await Future<void>.delayed(Duration(milliseconds: delay));
      return Success(operation());
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }

  @override
  Future<Result<PhoneSettings>> fetchPhoneSettings() => _respond(
    () => PhoneSettings(
      phoneNumber: _phone,
      feeRial: 1300000,
      walletBalanceRial: _walletBalance,
    ),
  );
  @override
  Future<Result<PhoneChallenge>> requestPhoneOtp(String phoneNumber) =>
      _respond(() {
        final challenge = PhoneChallenge(
          id: 'phone-${DateTime.now().microsecondsSinceEpoch}',
          expiresAt: DateTime.now().toUtc().add(const Duration(seconds: 60)),
        );
        _challenges[challenge.id] = (phone: phoneNumber, challenge: challenge);
        return challenge;
      });
  @override
  Future<Result<void>> changePhone({
    required String phoneNumber,
    required String otp,
    required String challengeId,
    required String idempotencyKey,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (_completedRequests.contains(idempotencyKey)) {
        return const Success(null);
      }
      final entry = _challenges[challengeId];
      if (entry == null ||
          entry.phone != phoneNumber ||
          !entry.challenge.expiresAt.isAfter(DateTime.now().toUtc())) {
        return const Err(DataFailure('profile.otp.expired'));
      }
      // Explicit demo code; never used by a live adapter.
      if (otp != '2345') {
        return const Err(DataFailure('profile.otp.invalid'));
      }
      if (_walletBalance < 1300000) {
        return const Err(DataFailure('profile.wallet.insufficient'));
      }
      _phone = phoneNumber;
      _walletBalance -= 1300000;
      _completedRequests.add(idempotencyKey);
      return const Success(null);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }

  @override
  Future<Result<List<ProfileAddress>>> fetchAddresses() =>
      _respond(() => List.unmodifiable(_addresses));
  @override
  Future<Result<ProfileAddress>> saveAddress(DeliveryAddress address) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!canSaveProfileAddress(_addresses, address)) {
        return const Err(DataFailure('profile.address.required'));
      }
      final saved = ProfileAddress(address: address);
      final exists = _addresses.any((item) => item.address.id == address.id);
      _addresses = [
        for (final item in _addresses)
          if (item.address.id == address.id) saved else item,
        if (!exists) saved,
      ];
      return Success(saved);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> deleteAddress(String id) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final remaining = _addresses
          .where((item) => item.address.id != id)
          .toList();
      if (!remaining.any(
        (item) => item.address.type == DeliveryAddressType.home,
      )) {
        return const Err(DataFailure('profile.address.required'));
      }
      _addresses = remaining;
      return const Success(null);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }

  @override
  Future<Result<ResidenceStatus>> reviewAddress(DeliveryAddress address) =>
      _respond(() {
        final status = address.postalCode.endsWith('0')
            ? ResidenceStatus.missing
            : ResidenceStatus.valid;
        _addresses = [
          for (final item in _addresses)
            if (item.address.id == address.id)
              item.withStatus(status)
            else
              item,
        ];
        return status;
      }, delay: 1400);
  @override
  Future<Result<List<ProfileOccupation>>> fetchOccupations() =>
      _respond(() => List.unmodifiable(_occupations));
  @override
  Future<Result<void>> saveOccupation(
    ProfileOccupation occupation, {
    required String idempotencyKey,
  }) => _respond(() {
    if (!_completedRequests.contains(idempotencyKey)) {
      // The request is queued for review; the approved list remains unchanged.
      _occupationRequests[idempotencyKey] = occupation;
      _completedRequests.add(idempotencyKey);
    }
  });
  @override
  Future<Result<void>> deleteOccupation(String id) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final remaining = _occupations.where((item) => item.id != id).toList();
      if (remaining.isEmpty) {
        return const Err(DataFailure('profile.occupation.required'));
      }
      _occupations = remaining;
      return const Success(null);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
