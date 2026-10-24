import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/login_identity.dart';
import '../models/auth_requests.dart';

Result<LoginOtpChallenge> mapOtpChallenge(
  AuthResponseDto response,
  LoginIdentity identity,
) {
  if (response.status != 0) {
    return Err(
      DataFailure(switch (response.message) {
        'WRONG_CAPTCHA' => 'auth.wrong_captcha',
        _ => 'auth.request_rejected',
      }),
    );
  }
  final token = response.token;
  if (token == null || token.trim().isEmpty) {
    return const Err(DataFailure('auth.invalid_response'));
  }
  return Success(LoginOtpChallenge(token: token, identity: identity));
}

Result<AuthenticatedCustomer> mapAuthenticatedCustomer(
  AuthResponseDto response,
  LoginOtpChallenge challenge,
) {
  if (response.status != 0) {
    return const Err(DataFailure('auth.otp_rejected'));
  }
  final customer = response.customer;
  if (response.token == null ||
      response.token!.trim().isEmpty ||
      customer == null ||
      customer.customerCode.trim().isEmpty ||
      customer.nationalCode != challenge.identity.nationalCode) {
    return const Err(DataFailure('auth.invalid_response'));
  }
  return Success(
    AuthenticatedCustomer(
      customerCode: customer.customerCode,
      nationalCode: customer.nationalCode,
      firstName: customer.firstName,
      lastName: customer.lastName,
    ),
  );
}
