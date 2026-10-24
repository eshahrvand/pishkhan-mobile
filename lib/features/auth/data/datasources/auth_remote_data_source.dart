import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../models/auth_requests.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio, {String? baseUrl}) =
      _AuthRemoteDataSource;

  // The live endpoint labels its Base64 text as image/jpeg.
  @GET('/captcha')
  @DioResponseType(ResponseType.plain)
  Future<HttpResponse<String>> fetchCaptcha();

  @POST('/check-cif')
  @Headers({'version': 'ng-1'})
  Future<AuthResponseDto> checkCif(@Body() CheckCifRequestDto request);

  @POST('/check-sms')
  Future<AuthResponseDto> checkSms(
    @Body() CheckSmsRequestDto request,
    @Header('token') String token,
  );
}
