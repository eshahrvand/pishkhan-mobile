import 'package:equatable/equatable.dart';

enum DeliveryAddressType { home, work }

class DeliveryAddress extends Equatable {
  const DeliveryAddress({
    required this.id,
    required this.title,
    required this.detail,
    required this.postalCode,
    this.phoneNumber = '',
    this.type = DeliveryAddressType.home,
  });
  final String id;
  final String title;
  final String detail;
  final String postalCode;
  final String phoneNumber;
  final DeliveryAddressType type;
  @override
  List<Object?> get props => [id, title, detail, postalCode, phoneNumber, type];
}
