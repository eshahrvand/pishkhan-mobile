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

  @override
  String get dashboardGreeting => 'صباح الخير، ماني';

  @override
  String get dashboardWelcomeMessage => 'مرحباً بك في شباك رسالت الافتراضي';

  @override
  String get walletBalanceTitle => 'رصيد المحفظة';

  @override
  String get rialCurrency => 'ريال';

  @override
  String get dashboardWalletBalance => '١٬٢٠٠٬٠٠٠';

  @override
  String get depositServices => 'خدمات الودائع';

  @override
  String get smsSettings => 'إعدادات الرسائل النصية';

  @override
  String get introduceRepresentative => 'تعريف ممثل';

  @override
  String get financialCertificate => 'شهادة الملاءة المالية';

  @override
  String get balanceAverageStatement => 'كشف متوسط الرصيد';

  @override
  String get cardServices => 'خدمات البطاقة';

  @override
  String get blockCard => 'حظر البطاقة';

  @override
  String get changeCardDeposit => 'تغيير الوديعة المرتبطة';

  @override
  String get cardPasswordIssue => 'إصدار الرقم السري الأول / الثاني';

  @override
  String get issueResalatCard => 'إصدار بطاقة رسالت';

  @override
  String get loanServices => 'خدمات القروض';

  @override
  String get changeInstallmentDeposit => 'تغيير وديعة خصم الأقساط';

  @override
  String get consolidateDepositCredit => 'دمج رصيد الوديعة';

  @override
  String get introduceLoan => 'تعريف القرض';

  @override
  String get loanEstimate => 'تقدير القرض';

  @override
  String get selectedServices => 'الخدمات المختارة';

  @override
  String get proxyDeposit => 'الوديعة بالوكالة';

  @override
  String get issueChequeBook => 'إصدار دفتر شيكات';

  @override
  String get internetBankSettings => 'إعدادات الخدمات المصرفية عبر الإنترنت';

  @override
  String get mobileBankSettings => 'إعدادات الخدمات المصرفية عبر الهاتف';

  @override
  String get latestUpdatedRequests => 'آخر الطلبات المحدثة';

  @override
  String get dashboardRequestTitle => 'طلب تغيير وديعة خصم الأقساط';

  @override
  String get requestIdentifier => 'معرف الطلب';

  @override
  String get automaticCompleted => 'اكتمل تلقائياً';

  @override
  String get dashboardRequestNumber => '١٣٧/٤٨٧٥٦٧';

  @override
  String get dashboardRequestDate => '2024/09/16 | ١٢:٤٥';

  @override
  String get profileLabel => 'الملف الشخصي';

  @override
  String get notificationsLabel => 'الإشعارات';

  @override
  String get dashboardAssistant => 'المساعد الذكي';

  @override
  String get dashboardResoTitle => 'اتركها لرِسو!';

  @override
  String get dashboardResoDescription =>
      'رِسو لا يجيب فقط؛ بل يتولى العمل بنفسه.';

  @override
  String get dashboardPromptHint => 'اكتب سؤالك...';

  @override
  String get dashboardSendPrompt => 'إرسال السؤال';

  @override
  String get dashboardBankServices => 'خدمات بنك رسالت';

  @override
  String get dashboardCustomize => 'تخصيص الخدمات';

  @override
  String get dashboardYourFavorites => 'خدماتك المفضلة';

  @override
  String get dashboardFavoritesLimit => 'يمكنك اختيار ٤ خدمات كحد أقصى.';

  @override
  String get dashboardAddService => 'إضافة خدمة جديدة';

  @override
  String get dashboardRemoveService => 'حذف';

  @override
  String get dashboardConfirm => 'تأكيد';

  @override
  String get dashboardCancel => 'إلغاء';

  @override
  String get dashboardResetTitle => 'إعادة ضبط الإعدادات';

  @override
  String get dashboardResetDescription =>
      'ستؤدي إعادة الضبط إلى إزالة تغييراتك واستعادة الإعدادات الأصلية.\nهل تريد إعادة الضبط؟';

  @override
  String get dashboardResetConfirm => 'إرسال التقييم';

  @override
  String get dashboardSearchHint => 'بحث';

  @override
  String get dashboardNoServices => 'لم يتم العثور على خدمات';

  @override
  String get dashboardTab => 'الرئيسية';

  @override
  String get dashboardCardsTab => 'البطاقات';

  @override
  String get dashboardDepositsTab => 'الودائع';

  @override
  String get dashboardLoansTab => 'القروض';
}
