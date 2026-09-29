// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'شباك رسالت الافتراضي';

  @override
  String get changeMobileTitle => 'تغيير رقم الهاتف المحمول';

  @override
  String get backLabel => 'رجوع';

  @override
  String get closeLabel => 'إغلاق';

  @override
  String get servicesMenuLabel => 'قائمة الخدمات';

  @override
  String get changeMobileDescription =>
      'أدخل المعلومات التالية للدخول إلى الشباك وتغيير رقم الهاتف المحمول';

  @override
  String get loginTitle => 'الدخول إلى الشباك الافتراضي';

  @override
  String get loginNationalIdHint => 'الرقم الوطني | رقم الهوية | رمز الأجانب';

  @override
  String get changeNationalIdHint => 'أدخل الرقم الوطني أو رقم الهوية';

  @override
  String get loginPhoneHint => 'أدخل رقم هاتفك المحمول';

  @override
  String get changePhoneHint => 'أدخل رقم هاتفك المحمول الجديد';

  @override
  String get changePhoneAction => 'تغيير رقم الهاتف المحمول';

  @override
  String get requestTwoFactorCode => 'طلب رمز المصادقة الثنائية';

  @override
  String get requestOtp => 'طلب رمز التحقق';

  @override
  String get phoneOwnershipNotice =>
      'يجب أن يتطابق الرقم مع الرقم الوطني لصاحب الحساب';

  @override
  String get captchaHint => 'أدخل الرمز';

  @override
  String otpSentMessage(String phone) {
    return 'أدخل الرمز الديناميكي المرسل إلى $phone.';
  }

  @override
  String get otpHint => 'أدخل الرمز';

  @override
  String get submitRequest => 'إرسال الطلب';

  @override
  String get enterDashboard => 'الدخول إلى الشباك';

  @override
  String get resendOtp => 'إعادة الإرسال';

  @override
  String get servicesList => 'قائمة الخدمات';

  @override
  String get guestServices => 'خدمات لا تتطلب تسجيل الدخول';

  @override
  String get assetReport => 'تقرير الملاءة المالية';

  @override
  String get changeMobileService => 'تغيير رقم الهاتف المحمول';

  @override
  String get requestStatus => 'حالة الطلب';

  @override
  String get inheritance => 'حصر الإرث';

  @override
  String get relatedLinks => 'روابط ذات صلة';

  @override
  String get mobileBank => 'الخدمات المصرفية عبر الهاتف';

  @override
  String get internetBank => 'الخدمات المصرفية عبر الإنترنت';

  @override
  String get memberContactCenter => 'مركز اتصال الأعضاء';

  @override
  String get resalatApp => 'تطبيق رسالت';

  @override
  String get securityTips => 'نصائح أمنية';

  @override
  String get updateGuide => 'دليل التحديث';
}
