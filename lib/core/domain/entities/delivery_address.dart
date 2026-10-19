import 'package:equatable/equatable.dart';

class DeliveryAddress extends Equatable {
  const DeliveryAddress({
    required this.id,
    required this.title,
    required this.detail,
    required this.postalCode,
  });
  final String id;
  final String title;
  final String detail;
  final String postalCode;
  @override
  List<Object?> get props => [id, title, detail, postalCode];
}
