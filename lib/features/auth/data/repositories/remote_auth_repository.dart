import 'package:pishkhan_mobile/core/network/data/network_failure_mapper.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/network/access_token_store.dart';

import '../../domain/entities/login_captcha.dart';
import '../../domain/entities/login_identity.dart';
import '../models/auth_requests.dart';
import '../mappers/login_response_mapper.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../mappers/login_captcha_mapper.dart';

class RemoteAuthRepository implements AuthRepository {
  const RemoteAuthRepository(this.remote, this.tokens);

  final AuthRemoteDataSource remote;
  final AccessTokenStore tokens;

  @override
  Future<Result<LoginCaptcha>> fetchCaptcha() async {
    try {
      final response = await remote.fetchCaptcha();
      return Success(
        await mapLoginCaptcha(
          response.data,
          response.response.headers.value('SessionId'),
        ),
      );
    } on FormatException {
      return const Err(DataFailure('auth.captcha_invalid_response'));
    } catch (error) {
      return Err(mapNetworkFailure(error));
    }
  }

  @override
  Future<Result<LoginOtpChallenge>> requestOtp(LoginIdentity identity) async {
    try {
      final response = await remote.checkCif(
        CheckCifRequestDto(
          nationalCode: identity.nationalCode,
          ip: '192.168.0.1', // Owner-approved temporary value, not detected device IP.
          mobile: identity.mobile,
          captcha: identity.captcha,
          sessionId: identity.sessionId,
        ),
      );
      return mapOtpChallenge(response, identity);
    } catch (error) {
      return Err(mapNetworkFailure(error));
    }
  }

  @override
  Future<Result<AuthenticatedCustomer>> verifyOtp(
    LoginOtpChallenge challenge,
    String code,
  ) async {
    try {
      final response = await remote.checkSms(
        CheckSmsRequestDto(code: code),
        challenge.token,
      );
      final result = mapAuthenticatedCustomer(response, challenge);
      if (result is Success<AuthenticatedCustomer>) {
        tokens.replace(response.token!);
      }
      return result;
    } catch (error) {
      return Err(mapNetworkFailure(error));
    }
  }
}
