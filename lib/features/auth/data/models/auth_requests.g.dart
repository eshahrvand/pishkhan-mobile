// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CheckCifRequestDtoToJson(CheckCifRequestDto instance) =>
    <String, dynamic>{
      'nationalCode': instance.nationalCode,
      'ip': instance.ip,
      'mobile': instance.mobile,
      'captcha': instance.captcha,
      'sessionId': instance.sessionId,
    };

Map<String, dynamic> _$CheckSmsRequestDtoToJson(CheckSmsRequestDto instance) =>
    <String, dynamic>{'code': instance.code};

AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) =>
    AuthResponseDto(
      status: (json['status'] as num?)?.toInt(),
      message: json['message'] as String?,
      token: json['token'] as String?,
      customer: json['customer'] == null
          ? null
          : AuthCustomerDto.fromJson(json['customer'] as Map<String, dynamic>),
    );

AuthCustomerDto _$AuthCustomerDtoFromJson(Map<String, dynamic> json) =>
    AuthCustomerDto(
      customerCode: json['customerCode'] as String,
      nationalCode: json['nationalCode'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
