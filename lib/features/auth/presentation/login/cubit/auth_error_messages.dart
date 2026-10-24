import 'package:pishkhan_mobile/core/result/failure.dart';

/// Login's owner-approved Persian request messages, independent of Flutter.
String getAuthErrorMessage(Failure failure) {
  switch (failure.code) {
    case 'auth.wrong_captcha':
      return 'کد امنیتی اشتباه است.';
    case 'auth.captcha_invalid_response':
      return 'دریافت تصویر کد امنیتی کامل نشد. دوباره تلاش کنید.';
    case 'auth.otp_rejected':
      return 'رمز تأیید صحیح نیست یا اعتبار آن تمام شده است.';
    case final code when code.startsWith('network.'):
      return 'ارتباط با سرور برقرار نشد. دوباره تلاش کنید.';
    default:
      return 'درخواست انجام نشد. اطلاعات را بررسی و دوباره تلاش کنید.';
  }
}
