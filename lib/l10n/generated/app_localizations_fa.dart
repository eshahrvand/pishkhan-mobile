// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'پیشخوان مجازی رسالت';

  @override
  String get changeMobileTitle => 'تغییر شماره همراه';

  @override
  String get backLabel => 'بازگشت';

  @override
  String get closeLabel => 'بستن';

  @override
  String get servicesMenuLabel => 'فهرست خدمات';

  @override
  String get changeMobileDescription =>
      'برای تغییر شماره همراه ورود به پیشخوان اطلاعات زیر را وارد کنید';

  @override
  String get loginTitle => 'ورود به پیشخوان مجازی';

  @override
  String get loginNationalIdHint => 'کد ملی | شماره ملی | کد اتباع';

  @override
  String get changeNationalIdHint => 'کد ملی | شماره ملی خود را وارد کنید';

  @override
  String get loginPhoneHint => 'شماره همراه خود را وارد کنید';

  @override
  String get changePhoneHint => 'شماره همراه جدید خود را وارد کنید';

  @override
  String get changePhoneAction => 'تغییر شماره همراه';

  @override
  String get requestTwoFactorCode => 'درخواست کد دو عاملی';

  @override
  String get requestOtp => 'درخواست ارسال رمز';

  @override
  String get phoneOwnershipNotice =>
      'شماره باید با کد ملی دارنده حساب مطابقت داشته باشد';

  @override
  String get captchaHint => 'کد را وارد کنید';

  @override
  String otpSentMessage(String phone) {
    return 'رمز پویای ارسال شده به شماره $phone را وارد کنید.';
  }

  @override
  String get otpHint => 'وارد کردن رمز';

  @override
  String get submitRequest => 'ثبت درخواست';

  @override
  String get enterDashboard => 'ورود به پیشخوان';

  @override
  String get resendOtp => 'ارسال مجدد';

  @override
  String get servicesList => 'لیست خدمات';

  @override
  String get guestServices => 'خدمات بدون نیاز به لاگین';

  @override
  String get assetReport => 'گزارش تمکن';

  @override
  String get changeMobileService => 'تغییر تلفن همراه';

  @override
  String get requestStatus => 'وضعیت درخواست';

  @override
  String get inheritance => 'انحصار وراثت';

  @override
  String get relatedLinks => 'لینک‌های مرتبط';

  @override
  String get mobileBank => 'همراه بانک';

  @override
  String get internetBank => 'اینترنت بانک';

  @override
  String get memberContactCenter => 'مرکز ارتباط با اعضاء';

  @override
  String get resalatApp => 'ام رسالت';

  @override
  String get securityTips => 'نکات امنیتی';

  @override
  String get updateGuide => 'راهنمای بروزرسانی';
}
