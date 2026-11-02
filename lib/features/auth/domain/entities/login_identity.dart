import 'package:equatable/equatable.dart';

class LoginIdentity extends Equatable {
  const LoginIdentity({
    required this.nationalCode,
    required this.mobile,
    required this.captcha,
    required this.sessionId,
  });

  final String nationalCode;
  final String mobile;
  final String captcha;
  final String sessionId;

  @override
  bool get stringify => false;

  @override
  List<Object?> get props => [nationalCode, mobile, captcha, sessionId];
}

class LoginOtpChallenge extends Equatable {
  const LoginOtpChallenge({required this.token, required this.identity});

  final String token;
  final LoginIdentity identity;

  @override
  bool get stringify => false;

  @override
  List<Object?> get props => [token, identity];
}

class AuthenticatedCustomer extends Equatable {
  const AuthenticatedCustomer({
    required this.customerCode,
    required this.nationalCode,
    required this.firstName,
    required this.lastName,
  });

  final String customerCode;
  final String nationalCode;
  final String firstName;
  final String lastName;

  @override
  bool get stringify => false;

  @override
  List<Object?> get props => [customerCode, nationalCode, firstName, lastName];
}
