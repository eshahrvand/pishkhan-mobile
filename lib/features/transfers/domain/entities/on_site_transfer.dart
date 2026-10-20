import 'package:equatable/equatable.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';

enum TransferMethod { satna }

enum TransferPurpose { salary }

class TransferDeposit extends Equatable {
  const TransferDeposit({required this.id, required this.number});
  final String id;
  final String number;
  @override
  List<Object?> get props => [id, number];
}

class TransferCatalog extends Equatable {
  TransferCatalog({
    required List<TransferDeposit> deposits,
    required List<DeliveryAddress> addresses,
    required this.bankTime,
    this.feeRial = 1300000,
    this.walletBalanceRial = 2000000,
    List<DateTime> holidays = const [],
  }) : deposits = List.unmodifiable(deposits),
       addresses = List.unmodifiable(addresses),
       holidays = List.unmodifiable(holidays);
  final List<TransferDeposit> deposits;
  final List<DeliveryAddress> addresses;

  /// Tehran wall-clock values supplied by the adapter; not the device timezone.
  final DateTime bankTime;
  final List<DateTime> holidays;
  final int feeRial;
  final int walletBalanceRial;
  @override
  List<Object?> get props => [
    deposits,
    addresses,
    bankTime,
    holidays,
    feeRial,
    walletBalanceRial,
  ];
}

class TransferDestination extends Equatable {
  const TransferDestination({
    required this.id,
    required this.recipientName,
    required this.iban,
    required this.amountRial,
    required this.purpose,
    required this.description,
    this.method = TransferMethod.satna,
  });
  final String id;
  final String recipientName;
  final String iban;
  final int amountRial;
  final TransferPurpose purpose;
  final String description;
  final TransferMethod method;
  @override
  bool get stringify => false;
  @override
  List<Object?> get props => [
    id,
    recipientName,
    iban,
    amountRial,
    purpose,
    description,
    method,
  ];
}

class TransferAttachment extends Equatable {
  const TransferAttachment({
    required this.token,
    required this.name,
    required this.sizeBytes,
  });
  final String token;
  final String name;
  final int sizeBytes;
  @override
  bool get stringify => false;
  @override
  List<Object?> get props => [token, name, sizeBytes];
}

class OnSiteTransferRequest extends Equatable {
  OnSiteTransferRequest({
    required this.depositId,
    required this.transferDate,
    required this.visitDate,
    required this.address,
    required List<TransferDestination> destinations,
    required this.attachment,
    required this.feeRial,
    required this.idempotencyKey,
  }) : destinations = List.unmodifiable(destinations);
  final String depositId;
  final DateTime transferDate;
  final DateTime visitDate;
  final DeliveryAddress address;
  final List<TransferDestination> destinations;

  /// File is accepted as a whole. Parsing/review is deliberately deferred.
  final TransferAttachment? attachment;
  final int feeRial;
  final String idempotencyKey;
  @override
  bool get stringify => false;
  @override
  List<Object?> get props => [
    depositId,
    transferDate,
    visitDate,
    address,
    destinations,
    attachment,
    feeRial,
    idempotencyKey,
  ];
}

class TransferReceipt extends Equatable {
  const TransferReceipt({required this.trackingId, required this.feeRial});
  final String trackingId;
  final int feeRial;
  @override
  List<Object?> get props => [trackingId, feeRial];
}

abstract final class TransferScheduleRules {
  static bool isTransferDateValid(DateTime date, TransferCatalog catalog) {
    final today = DateTime.utc(
      catalog.bankTime.year,
      catalog.bankTime.month,
      catalog.bankTime.day,
    );
    return !date.isBefore(today) &&
        date.weekday != DateTime.friday &&
        !catalog.holidays.contains(date) &&
        (date != today || catalog.bankTime.hour < 10);
  }

  static bool isVisitDateValid(
    DateTime date,
    DateTime transferDate,
    TransferCatalog catalog,
  ) {
    final today = DateTime.utc(
      catalog.bankTime.year,
      catalog.bankTime.month,
      catalog.bankTime.day,
    );
    return !date.isBefore(today) &&
        !date.isAfter(transferDate) &&
        date.weekday != DateTime.friday &&
        !catalog.holidays.contains(date);
  }
}
