import 'package:json_annotation/json_annotation.dart';

part 'auth_requests.g.dart';

/// Provisional bank contract supplied by the owner; replace from bank OpenAPI.
@JsonSerializable(createFactory: false)
class CheckCifRequestDto {
  const CheckCifRequestDto({
    required this.nationalCode,
    required this.ip,
    required this.mobile,
    required this.captcha,
    required this.sessionId,
  });

  final String nationalCode;
  final String ip;
  final String mobile;
  final String captcha;
  final String sessionId;

  Map<String, dynamic> toJson() => _$CheckCifRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class CheckSmsRequestDto {
  const CheckSmsRequestDto({required this.code});

  final String code;

  Map<String, dynamic> toJson() => _$CheckSmsRequestDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class AuthResponseDto {
  const AuthResponseDto({this.status, this.message, this.token, this.customer});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  final int? status;
  final String? message;
  final String? token;
  final AuthCustomerDto? customer;
}

@JsonSerializable(createToJson: false)
class AuthCustomerDto {
  const AuthCustomerDto({
    required this.customerCode,
    required this.nationalCode,
    required this.firstName,
    required this.lastName,
  });

  factory AuthCustomerDto.fromJson(Map<String, dynamic> json) =>
      _$AuthCustomerDtoFromJson(json);

  final String customerCode;
  final String nationalCode;
  final String firstName;
  final String lastName;
}
