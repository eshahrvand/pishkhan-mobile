// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(percentage) => "${percentage}٪";

  static String m1(amount) => "${amount} تومان";

  static String m2(number) => "إزالة البطاقة ${number}";

  static String m3(count) => "البطاقات المختارة (${count})";

  static String m4(current, total, title) =>
      "الخطوة ${current} من ${total}، ${title}";

  static String m5(amount) =>
      "برای دریافت این مبلغ به ضامن نیاز دارید. شما و ضامن هر کدام باید یک فقره سفته الکترونیک به مبلغ ۱۲۰٪ مبلغ وام درخواستی، به ارزش ${amount} از سامانه آی‌کاپ خریداری یا چک الکترونیک در وجه بانک قرض‌الحسنه رسالت ثبت نمایید.";

  static String m6(amount) =>
      "برای ضمانت وام خود، لازم است سفته یا چک الکترونیک معادل ۱۲۰٪ مبلغ وام به ارزش ${amount} تهیه کنید.";

  static String m7(phone) => "کد OTP ارسال شده به شماره ${phone} را وارد کنید.";

  static String m8(amount) =>
      "برای دریافت این مبلغ به ضامن نیاز ندارید. کافیست یک فقره سفته الکترونیک به مبلغ ۱۲۰٪ مبلغ وام خود به ارزش ${amount} از سامانه آی‌کاپ خریداری یا چک الکترونیک در وجه بانک قرض‌الحسنه رسالت ثبت نمایید.";

  static String m9(page) => "الخطوة ${page} من 4";

  static String m10(amount) => "الحد الأقصى للتحويل اليومي: ${amount} ريال";

  static String m11(amount) => "${amount} تومان";

  static String m12(phone) => "أدخل الرمز الديناميكي المرسل إلى ${phone}.";

  static String m13(occupation) => "هل أنت متأكد من حذف مهنتك (${occupation})؟";

  static String m14(selected, existing) =>
      "المهنة المختارة (${selected}) غير متوافقة مع مهنتك الحالية (${existing}).";

  static String m15(previous, selected) =>
      "يتطلب التغيير من ${previous} إلى ${selected} مراجعة الموظف وستظهر التغييرات بعد الموافقة.";

  static String m16(max) => "يجب أن يكون عدد البطاقات بين 1 و${max}.";

  static String m17(amount) => "رسوم إصدار كل بطاقة هي ${amount}";

  static String m18(amount) => "${amount} تومان";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "agentSettingsActive": MessageLookupByLibrary.simpleMessage("نشط"),
        "agentSettingsAdd": MessageLookupByLibrary.simpleMessage("إضافة ممثل"),
        "agentSettingsCancel":
            MessageLookupByLibrary.simpleMessage("إلغاء التمثيل"),
        "agentSettingsClearChequeRecord":
            MessageLookupByLibrary.simpleMessage("إزالة أثر الشيك"),
        "agentSettingsConfirmers":
            MessageLookupByLibrary.simpleMessage("بيانات الموافقين"),
        "agentSettingsDelegated":
            MessageLookupByLibrary.simpleMessage("أنا كممثل"),
        "agentSettingsDepositLabel":
            MessageLookupByLibrary.simpleMessage("رقم الوديعة:"),
        "agentSettingsDepositRelation":
            MessageLookupByLibrary.simpleMessage("صاحب الوديعة والموقّع"),
        "agentSettingsDetails":
            MessageLookupByLibrary.simpleMessage("تفاصيل التمثيل"),
        "agentSettingsEmpty": MessageLookupByLibrary.simpleMessage(
            "لا توجد نتائج مطابقة لهذه المرشحات."),
        "agentSettingsExpired":
            MessageLookupByLibrary.simpleMessage("منتهي الصلاحية"),
        "agentSettingsExpiryLabel":
            MessageLookupByLibrary.simpleMessage("تاريخ الانتهاء:"),
        "agentSettingsIntroducedLabel":
            MessageLookupByLibrary.simpleMessage("تاريخ التعريف:"),
        "agentSettingsIntroducer":
            MessageLookupByLibrary.simpleMessage("المعرّف"),
        "agentSettingsKindLabel":
            MessageLookupByLibrary.simpleMessage("نوع التمثيل:"),
        "agentSettingsLoanReferral":
            MessageLookupByLibrary.simpleMessage("إحالة قرض"),
        "agentSettingsMine": MessageLookupByLibrary.simpleMessage("ممثلوني"),
        "agentSettingsNameLabel":
            MessageLookupByLibrary.simpleMessage("اسم الممثل:"),
        "agentSettingsNationalIdLabel":
            MessageLookupByLibrary.simpleMessage("الرقم الوطني:"),
        "agentSettingsSelectAll":
            MessageLookupByLibrary.simpleMessage("(تحديد الكل)"),
        "agentSettingsShare": m0,
        "agentSettingsWaiting":
            MessageLookupByLibrary.simpleMessage("بانتظار الموافقة"),
        "appTitle":
            MessageLookupByLibrary.simpleMessage("شباك رسالت الافتراضي"),
        "assetReport":
            MessageLookupByLibrary.simpleMessage("تقرير الملاءة المالية"),
        "authChangePhoneUnavailable": MessageLookupByLibrary.simpleMessage(
            "خدمة تغيير رقم الهاتف غير متصلة بعد."),
        "authInvalidCaptcha": MessageLookupByLibrary.simpleMessage(
            "أدخل رمز الأمان المكون من 6 أرقام"),
        "authInvalidNationalId": MessageLookupByLibrary.simpleMessage(
            "أدخل رقم الهوية المكون من 10 أرقام"),
        "authInvalidPhone": MessageLookupByLibrary.simpleMessage(
            "أدخل رقم الهاتف المكون من 11 رقماً ويبدأ بـ 09"),
        "authNetworkError": MessageLookupByLibrary.simpleMessage(
            "تعذر الاتصال بالخادم. حاول مجدداً."),
        "authOtpRejected": MessageLookupByLibrary.simpleMessage(
            "رمز التحقق غير صحيح أو انتهت صلاحيته."),
        "authRequestFailed": MessageLookupByLibrary.simpleMessage(
            "تعذر إتمام الطلب. تحقق من المعلومات وحاول مجدداً."),
        "automaticCompleted":
            MessageLookupByLibrary.simpleMessage("اكتمل تلقائياً"),
        "backLabel": MessageLookupByLibrary.simpleMessage("رجوع"),
        "balanceAverageStatement":
            MessageLookupByLibrary.simpleMessage("كشف متوسط الرصيد"),
        "blockCard": MessageLookupByLibrary.simpleMessage("حظر البطاقة"),
        "captchaHint": MessageLookupByLibrary.simpleMessage("أدخل الرمز"),
        "cardBlockConfirm":
            MessageLookupByLibrary.simpleMessage("نعم، احظر البطاقة"),
        "cardBlockConfirmation": MessageLookupByLibrary.simpleMessage(
            "بعد حظر البطاقة لا يمكن استخدامها حتى إلغاء الحظر. هل أنت متأكد من حظرها؟"),
        "cardBlockIntro":
            MessageLookupByLibrary.simpleMessage("اختر البطاقة وسبب حظرها"),
        "cardFeatureActive": MessageLookupByLibrary.simpleMessage("نشطة"),
        "cardFeatureAll": MessageLookupByLibrary.simpleMessage("الكل"),
        "cardFeatureApplyFilter":
            MessageLookupByLibrary.simpleMessage("تطبيق التصفية"),
        "cardFeatureBlocked": MessageLookupByLibrary.simpleMessage("محظورة"),
        "cardFeatureCardStatus":
            MessageLookupByLibrary.simpleMessage("حالة البطاقة"),
        "cardFeatureCoupon":
            MessageLookupByLibrary.simpleMessage("بطاقة قسيمة"),
        "cardFeatureDeposit":
            MessageLookupByLibrary.simpleMessage("الوديعة المرتبطة"),
        "cardFeatureDepositType":
            MessageLookupByLibrary.simpleMessage("نوع الوديعة"),
        "cardFeatureDetails":
            MessageLookupByLibrary.simpleMessage("تفاصيل البطاقة"),
        "cardFeatureExpired": MessageLookupByLibrary.simpleMessage("منتهية"),
        "cardFeatureExpiry":
            MessageLookupByLibrary.simpleMessage("تاريخ الانتهاء"),
        "cardFeatureFamily":
            MessageLookupByLibrary.simpleMessage("بطاقة العائلة"),
        "cardFeatureFilter": MessageLookupByLibrary.simpleMessage("تصفية"),
        "cardFeatureGift": MessageLookupByLibrary.simpleMessage("بطاقة هدية"),
        "cardFeatureGiftTransfer": MessageLookupByLibrary.simpleMessage(
            "تحويل رصيد بطاقة الهدية المنتهية"),
        "cardFeatureIban": MessageLookupByLibrary.simpleMessage("رقم الآيبان"),
        "cardFeatureNoResults":
            MessageLookupByLibrary.simpleMessage("لا توجد بطاقات مطابقة"),
        "cardFeatureNumber":
            MessageLookupByLibrary.simpleMessage("رقم البطاقة"),
        "cardFeatureQarz": MessageLookupByLibrary.simpleMessage("قرض حسن"),
        "cardFeatureRemoveFilter":
            MessageLookupByLibrary.simpleMessage("إزالة التصفية"),
        "cardFeatureResalat":
            MessageLookupByLibrary.simpleMessage("بطاقة رسالت"),
        "cardFeatureStatus": MessageLookupByLibrary.simpleMessage("الحالة"),
        "cardFeatureUnavailable": MessageLookupByLibrary.simpleMessage(
            "هذه الخدمة غير متاحة حالياً."),
        "cardFeatureVirtualRequest":
            MessageLookupByLibrary.simpleMessage("طلب بطاقة افتراضية"),
        "cardPasswordIssue": MessageLookupByLibrary.simpleMessage(
            "إصدار الرقم السري الأول / الثاني"),
        "cardRestrictionFound":
            MessageLookupByLibrary.simpleMessage("العثور على البطاقة"),
        "cardRestrictionLinkedDeposit":
            MessageLookupByLibrary.simpleMessage("الوديعة المرتبطة بالبطاقة"),
        "cardRestrictionLost":
            MessageLookupByLibrary.simpleMessage("فقدان البطاقة"),
        "cardRestrictionOther":
            MessageLookupByLibrary.simpleMessage("أسباب أخرى"),
        "cardRestrictionRefresh":
            MessageLookupByLibrary.simpleMessage("تحديث البيانات والرسوم"),
        "cardRestrictionStolen":
            MessageLookupByLibrary.simpleMessage("سرقة البطاقة"),
        "cardServiceCard": MessageLookupByLibrary.simpleMessage("البطاقة"),
        "cardServiceCardHint":
            MessageLookupByLibrary.simpleMessage("اختر البطاقة"),
        "cardServiceComplete":
            MessageLookupByLibrary.simpleMessage("تم إرسال الطلب بنجاح."),
        "cardServiceCurrentDeposit":
            MessageLookupByLibrary.simpleMessage("حساب جاري"),
        "cardServiceEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد عناصر متاحة."),
        "cardServiceFromDeposit":
            MessageLookupByLibrary.simpleMessage("من الحساب"),
        "cardServiceMockComplete": MessageLookupByLibrary.simpleMessage(
            "تم تسجيل الطلب التجريبي؛ لم تُنفذ أي عملية مصرفية."),
        "cardServiceQarzDeposit":
            MessageLookupByLibrary.simpleMessage("حساب قرض حسن"),
        "cardServiceSubmit":
            MessageLookupByLibrary.simpleMessage("تأكيد وإرسال الطلب"),
        "cardServiceSubmitError": MessageLookupByLibrary.simpleMessage(
            "تعذر إرسال الطلب. حاول مرة أخرى."),
        "cardServiceToDeposit":
            MessageLookupByLibrary.simpleMessage("إلى الحساب"),
        "cardServiceToDepositHint": MessageLookupByLibrary.simpleMessage(
            "اختر الحساب الذي تريد ربطه بالبطاقة"),
        "cardServices": MessageLookupByLibrary.simpleMessage("خدمات البطاقة"),
        "cardUnblockIntro": MessageLookupByLibrary.simpleMessage(
            "اختر البطاقة وسبب إلغاء حظرها"),
        "cardsBuyGift": MessageLookupByLibrary.simpleMessage("شراء بطاقة هدية"),
        "cardsChangeFirst":
            MessageLookupByLibrary.simpleMessage("تغيير الرقم السري الأول"),
        "cardsCopyIban":
            MessageLookupByLibrary.simpleMessage("نسخ رقم الآيبان"),
        "cardsCopyNumber":
            MessageLookupByLibrary.simpleMessage("نسخ رقم البطاقة"),
        "cardsCurrent":
            MessageLookupByLibrary.simpleMessage("بطاقة رسالت (جارية)"),
        "cardsEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد بطاقات بعد"),
        "cardsExpiry": MessageLookupByLibrary.simpleMessage("الانتهاء:"),
        "cardsForgotFirst":
            MessageLookupByLibrary.simpleMessage("نسيت الرقم السري الأول"),
        "cardsForgotSecond":
            MessageLookupByLibrary.simpleMessage("نسيت الرقم السري الثاني"),
        "cardsGiftBalance":
            MessageLookupByLibrary.simpleMessage("تحويل رصيد بطاقة الهدية"),
        "cardsHideDetails":
            MessageLookupByLibrary.simpleMessage("إخفاء بيانات البطاقة"),
        "cardsMore": MessageLookupByLibrary.simpleMessage("خيارات البطاقة"),
        "cardsMyTitle": MessageLookupByLibrary.simpleMessage("بطاقاتي"),
        "cardsOperations":
            MessageLookupByLibrary.simpleMessage("عمليات البطاقة"),
        "cardsPinOperations":
            MessageLookupByLibrary.simpleMessage("عمليات الرقم السري"),
        "cardsQarz":
            MessageLookupByLibrary.simpleMessage("بطاقة رسالت (قرض حسن)"),
        "cardsQuickAccess":
            MessageLookupByLibrary.simpleMessage("الوصول السريع"),
        "cardsReissue":
            MessageLookupByLibrary.simpleMessage("إعادة إصدار البطاقة"),
        "cardsSetSecond":
            MessageLookupByLibrary.simpleMessage("تعيين الرقم السري الثاني"),
        "cardsShowDetails":
            MessageLookupByLibrary.simpleMessage("عرض بيانات البطاقة"),
        "cardsVirtual": MessageLookupByLibrary.simpleMessage("بطاقة افتراضية"),
        "certificateAddressHint":
            MessageLookupByLibrary.simpleMessage("اختر عنوان إرسال الشهادة"),
        "certificateAgentIdentifier":
            MessageLookupByLibrary.simpleMessage("الرقم الوطني أو هاتف الخبير"),
        "certificateAgentNotice": MessageLookupByLibrary.simpleMessage(
            "إذا كنت تعرف خبيراً بنكياً، أدخل رقمه الوطني أو رقم هاتفه."),
        "certificateAgentUnavailable": MessageLookupByLibrary.simpleMessage(
            "يتطلب التحقق من الخبير الربط بنظام البنك."),
        "certificateAverageBalance":
            MessageLookupByLibrary.simpleMessage("متوسط الرصيد"),
        "certificateAverageTitle": MessageLookupByLibrary.simpleMessage(
            "طلب كشف الحساب | متوسط الرصيد"),
        "certificateBothTurnovers":
            MessageLookupByLibrary.simpleMessage("إيداع | سحب"),
        "certificateCheckAgent": MessageLookupByLibrary.simpleMessage("تحقق"),
        "certificateConditionsPrompt": MessageLookupByLibrary.simpleMessage(
            "حدد شروط الطلب لإدراجها في الشهادة."),
        "certificateConditionsStep":
            MessageLookupByLibrary.simpleMessage("اختيار الوديعة وشروط الطلب"),
        "certificateDeleteAddressPrompt":
            MessageLookupByLibrary.simpleMessage("هل تريد حذف هذا العنوان؟"),
        "certificateDeliveryStep":
            MessageLookupByLibrary.simpleMessage("معلومات استلام الشهادة"),
        "certificateDepositsOnly":
            MessageLookupByLibrary.simpleMessage("إيداع"),
        "certificateEnglish":
            MessageLookupByLibrary.simpleMessage("الإنجليزية"),
        "certificateFromDate": MessageLookupByLibrary.simpleMessage("من تاريخ"),
        "certificateFromDateHint":
            MessageLookupByLibrary.simpleMessage("حدد تاريخ البداية"),
        "certificateLanguage": MessageLookupByLibrary.simpleMessage("اللغة"),
        "certificateMockComplete": MessageLookupByLibrary.simpleMessage(
            "تم تسجيل طلب تجريبي؛ لم تصدر شهادة ولم يُخصم أي مبلغ."),
        "certificateNextPrefix":
            MessageLookupByLibrary.simpleMessage("التالي:"),
        "certificateOptional": MessageLookupByLibrary.simpleMessage("اختياري"),
        "certificatePersian": MessageLookupByLibrary.simpleMessage("الفارسية"),
        "certificatePrintingNotice": MessageLookupByLibrary.simpleMessage(
            "تُحسب رسوم الطباعة بناءً على عدد الصفحات."),
        "certificateRecipientName":
            MessageLookupByLibrary.simpleMessage("الاسم الكامل"),
        "certificateRecipientNameHint":
            MessageLookupByLibrary.simpleMessage("أدخل الاسم الكامل للمستلم"),
        "certificateRecipientNationalIdHint":
            MessageLookupByLibrary.simpleMessage("أدخل الرقم الوطني للمستلم"),
        "certificateRecipientNotice": MessageLookupByLibrary.simpleMessage(
            "تُسلّم الحزمة لك. إذا كنت غائباً، أدخل بيانات المستلم البديل."),
        "certificateStatementLanguageHint":
            MessageLookupByLibrary.simpleMessage("اختر لغة كشف الحساب"),
        "certificateToDate": MessageLookupByLibrary.simpleMessage("إلى تاريخ"),
        "certificateToDateHint":
            MessageLookupByLibrary.simpleMessage("حدد تاريخ النهاية"),
        "certificateTurnover":
            MessageLookupByLibrary.simpleMessage("نوع الحركة"),
        "certificateTurnoverHint":
            MessageLookupByLibrary.simpleMessage("اختر نوع حركة الوديعة"),
        "certificateWithdrawalsOnly":
            MessageLookupByLibrary.simpleMessage("سحب"),
        "changeCardDeposit":
            MessageLookupByLibrary.simpleMessage("تغيير الوديعة المرتبطة"),
        "changeCardDepositIntro": MessageLookupByLibrary.simpleMessage(
            "اختر البطاقة ثم الحساب الذي تريد ربطها به."),
        "changeCardDepositTitle": MessageLookupByLibrary.simpleMessage(
            "تغيير الحساب المرتبط بالبطاقة"),
        "changeInstallmentDeposit":
            MessageLookupByLibrary.simpleMessage("تغيير وديعة خصم الأقساط"),
        "changeMobileDescription": MessageLookupByLibrary.simpleMessage(
            "أدخل المعلومات التالية للدخول إلى الشباك وتغيير رقم الهاتف المحمول"),
        "changeMobileService":
            MessageLookupByLibrary.simpleMessage("تغيير رقم الهاتف المحمول"),
        "changeMobileTitle":
            MessageLookupByLibrary.simpleMessage("تغيير رقم الهاتف المحمول"),
        "changeNationalIdHint": MessageLookupByLibrary.simpleMessage(
            "أدخل الرقم الوطني أو رقم الهوية"),
        "changePhoneAction":
            MessageLookupByLibrary.simpleMessage("تغيير رقم الهاتف المحمول"),
        "changePhoneHint": MessageLookupByLibrary.simpleMessage(
            "أدخل رقم هاتفك المحمول الجديد"),
        "chequeBookAddressesNoticeEnd":
            MessageLookupByLibrary.simpleMessage("."),
        "chequeBookAddressesNoticeStart": MessageLookupByLibrary.simpleMessage(
            "لتغيير العنوان، انتقل إلى معلومات المستخدم، "),
        "chequeBookChecking":
            MessageLookupByLibrary.simpleMessage("جارٍ التحقق من سجل السكن…"),
        "chequeBookDeleteContinue":
            MessageLookupByLibrary.simpleMessage("حذف ومتابعة"),
        "chequeBookDeletePrompt":
            MessageLookupByLibrary.simpleMessage("هل تريد حذف هذا العنوان؟"),
        "chequeBookDeliveryStep":
            MessageLookupByLibrary.simpleMessage("معلومات الاستلام"),
        "chequeBookDepositHint":
            MessageLookupByLibrary.simpleMessage("اختر الوديعة"),
        "chequeBookFiftyLeavesNotice": MessageLookupByLibrary.simpleMessage(
            "للأفراد، يتاح دفتر من ٥٠ ورقة بعد نهاية السنة الثالثة."),
        "chequeBookIssueFee":
            MessageLookupByLibrary.simpleMessage("رسوم إصدار دفتر الشيكات"),
        "chequeBookLeafCount":
            MessageLookupByLibrary.simpleMessage("عدد الأوراق"),
        "chequeBookLeafCountHint":
            MessageLookupByLibrary.simpleMessage("اختر عدد أوراق دفتر الشيكات"),
        "chequeBookLegalRecipientPrompt": MessageLookupByLibrary.simpleMessage(
            "أدخل بيانات مستلم دفتر الشيكات"),
        "chequeBookLinkUnavailable": MessageLookupByLibrary.simpleMessage(
            "تعذر فتح المتصفح على هذا الجهاز."),
        "chequeBookMissingNotice": MessageLookupByLibrary.simpleMessage(
            "إذا كان العنوان صحيحاً، سجله في نظام السكن والعقارات قبل طلب دفتر شيكات."),
        "chequeBookMockComplete": MessageLookupByLibrary.simpleMessage(
            "تم تسجيل طلب تجريبي؛ لم يتم إصدار دفتر شيكات حقيقي أو خصم أي مبلغ."),
        "chequeBookMultipleMissingNotice": MessageLookupByLibrary.simpleMessage(
            "يمكنك تسجيل العنوان المطلوب في نظام السكن والعقارات أو حذف العناوين الإضافية."),
        "chequeBookMyAddresses":
            MessageLookupByLibrary.simpleMessage("عناويني"),
        "chequeBookNextConfirmation": MessageLookupByLibrary.simpleMessage(
            "التالي: تأكيد المعلومات ودفع الرسوم"),
        "chequeBookNextDelivery":
            MessageLookupByLibrary.simpleMessage("التالي: معلومات الاستلام"),
        "chequeBookNextResidency":
            MessageLookupByLibrary.simpleMessage("التالي: التحقق من سجل السكن"),
        "chequeBookNotRegistered":
            MessageLookupByLibrary.simpleMessage("غير مسجل في نظام السكن"),
        "chequeBookOpenedAt":
            MessageLookupByLibrary.simpleMessage("تاريخ فتح الحساب:"),
        "chequeBookRecipientName":
            MessageLookupByLibrary.simpleMessage("الاسم الكامل"),
        "chequeBookRecipientNameHint":
            MessageLookupByLibrary.simpleMessage("أدخل الاسم الكامل للمستلم"),
        "chequeBookRecipientNameInvalid":
            MessageLookupByLibrary.simpleMessage("أدخل الاسم الكامل."),
        "chequeBookRecipientNationalId":
            MessageLookupByLibrary.simpleMessage("الرقم الوطني"),
        "chequeBookRecipientNationalIdHint":
            MessageLookupByLibrary.simpleMessage("أدخل الرقم الوطني للمستلم"),
        "chequeBookRegistered":
            MessageLookupByLibrary.simpleMessage("مسجل في نظام السكن"),
        "chequeBookRegistryHost":
            MessageLookupByLibrary.simpleMessage("amlak.mrud.ir"),
        "chequeBookRegistryName":
            MessageLookupByLibrary.simpleMessage("نظام السكن والعقارات"),
        "chequeBookRegistryUrlLabel":
            MessageLookupByLibrary.simpleMessage("موقع نظام السكن والعقارات:"),
        "chequeBookResidence":
            MessageLookupByLibrary.simpleMessage("عنوان إقامتك:"),
        "chequeBookResidences":
            MessageLookupByLibrary.simpleMessage("عناوين إقامتك:"),
        "chequeBookResidencyStep":
            MessageLookupByLibrary.simpleMessage("التحقق من سجل السكن"),
        "chequeBookResidencyWarningEnd":
            MessageLookupByLibrary.simpleMessage("."),
        "chequeBookResidencyWarningStart":
            MessageLookupByLibrary.simpleMessage("عنوان إقامتك غير موثق في "),
        "chequeBookSelectionPrompt": MessageLookupByLibrary.simpleMessage(
            "اختر الحساب الجاري وعدد أوراق دفتر الشيكات."),
        "chequeBookSelectionStep":
            MessageLookupByLibrary.simpleMessage("تفاصيل دفتر الشيكات"),
        "chequeBookTitle":
            MessageLookupByLibrary.simpleMessage("طلب إصدار دفتر شيكات"),
        "chequeBookUsedLeavesNotice": MessageLookupByLibrary.simpleMessage(
            "يجب إعادة ٨٠٪ على الأقل من أوراق دفتر الشيكات السابق إلى البنك."),
        "chequeCancelAllReasons":
            MessageLookupByLibrary.simpleMessage("تطبيق سبب واحد على الجميع"),
        "chequeCancelAllReasonsTitle":
            MessageLookupByLibrary.simpleMessage("اختيار سبب للجميع"),
        "chequeCancelChequesPrompt":
            MessageLookupByLibrary.simpleMessage("اختر الشيكات المراد إلغاؤها"),
        "chequeCancelChequesStep":
            MessageLookupByLibrary.simpleMessage("اختيار الشيكات"),
        "chequeCancelChoose": MessageLookupByLibrary.simpleMessage("اختيار"),
        "chequeCancelConfirmationStep":
            MessageLookupByLibrary.simpleMessage("تنزيل الخطاب وتقديم الطلب"),
        "chequeCancelDamaged":
            MessageLookupByLibrary.simpleMessage("تالف - غير مستخدم"),
        "chequeCancelDepositHint":
            MessageLookupByLibrary.simpleMessage("اختر الوديعة"),
        "chequeCancelDigital": MessageLookupByLibrary.simpleMessage("رقمي"),
        "chequeCancelDownload": MessageLookupByLibrary.simpleMessage(
            "حفظ الخطاب لتسليمه إلى البريد"),
        "chequeCancelEmpty":
            MessageLookupByLibrary.simpleMessage("لم يتم العثور على نتائج"),
        "chequeCancelJudicial":
            MessageLookupByLibrary.simpleMessage("أمر جهة قضائية"),
        "chequeCancelLetterPrompt": MessageLookupByLibrary.simpleMessage(
            "لإلغاء الشيكات، نزّل الخطاب أدناه ثم قدّم طلبك."),
        "chequeCancelMailInstruction": MessageLookupByLibrary.simpleMessage(
            "اطبع الخطاب المنزّل وسلّمه مع الشيكات المذكورة فيه إلى مكتب بريد معتمد للإلغاء."),
        "chequeCancelMockComplete": MessageLookupByLibrary.simpleMessage(
            "تم تسجيل طلب إلغاء تجريبي؛ لم يتم إلغاء أي شيك في البنك."),
        "chequeCancelNumber": MessageLookupByLibrary.simpleMessage("رقم الشيك"),
        "chequeCancelPaper": MessageLookupByLibrary.simpleMessage("ورقي"),
        "chequeCancelReason":
            MessageLookupByLibrary.simpleMessage("سبب إلغاء الشيك"),
        "chequeCancelReasonHint":
            MessageLookupByLibrary.simpleMessage("اختر سبب الإلغاء"),
        "chequeCancelReasonsPrompt":
            MessageLookupByLibrary.simpleMessage("اختر أسباب إلغاء الشيكات"),
        "chequeCancelReasonsStep":
            MessageLookupByLibrary.simpleMessage("اختيار أسباب الإلغاء"),
        "chequeCancelRemove":
            MessageLookupByLibrary.simpleMessage("نعم، إزالة"),
        "chequeCancelRemovePrompt": MessageLookupByLibrary.simpleMessage(
            "هل تريد إزالة هذا الشيك من قائمة الإلغاء؟"),
        "chequeCancelReview":
            MessageLookupByLibrary.simpleMessage("الشيكات المختارة"),
        "chequeCancelSayad": MessageLookupByLibrary.simpleMessage("معرف صياد"),
        "chequeCancelSearchHint": MessageLookupByLibrary.simpleMessage(
            "ابحث برقم الشيك أو معرف صياد"),
        "chequeCancelSelectionNotice": MessageLookupByLibrary.simpleMessage(
            "يمكن لكل طلب أن يتضمن شيكات من وديعة واحدة ونوع واحد (رقمي أو ورقي)."),
        "chequeCancelSelectionPrompt": MessageLookupByLibrary.simpleMessage(
            "اختر الوديعة ونوع الشيكات المراد إلغاؤها."),
        "chequeCancelSelectionStep":
            MessageLookupByLibrary.simpleMessage("اختيار الوديعة ونوع الشيك"),
        "chequeCancelTitle":
            MessageLookupByLibrary.simpleMessage("إلغاء الشيكات"),
        "chequeCancelType": MessageLookupByLibrary.simpleMessage("نوع الشيك"),
        "chequeCancelTypeHint":
            MessageLookupByLibrary.simpleMessage("اختر نوع الشيك"),
        "closeLabel": MessageLookupByLibrary.simpleMessage("إغلاق"),
        "consolidateDepositCredit":
            MessageLookupByLibrary.simpleMessage("دمج رصيد الوديعة"),
        "dashboardAddFavorites":
            MessageLookupByLibrary.simpleMessage("إضافة خدمات مفضلة"),
        "dashboardAddService":
            MessageLookupByLibrary.simpleMessage("إضافة خدمة جديدة"),
        "dashboardAddresses":
            MessageLookupByLibrary.simpleMessage("إدارة العناوين"),
        "dashboardAgentSettings":
            MessageLookupByLibrary.simpleMessage("إعدادات التمثيل"),
        "dashboardAllServices":
            MessageLookupByLibrary.simpleMessage("جميع الخدمات"),
        "dashboardAssistant":
            MessageLookupByLibrary.simpleMessage("المساعد الذكي"),
        "dashboardBankServices":
            MessageLookupByLibrary.simpleMessage("خدمات بنك رسالت"),
        "dashboardBlockDeposit":
            MessageLookupByLibrary.simpleMessage("حظر الوديعة"),
        "dashboardCancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "dashboardCancelCheque":
            MessageLookupByLibrary.simpleMessage("إلغاء شيك"),
        "dashboardCardsList":
            MessageLookupByLibrary.simpleMessage("قائمة البطاقات"),
        "dashboardCardsTab": MessageLookupByLibrary.simpleMessage("البطاقات"),
        "dashboardChangeIdentity":
            MessageLookupByLibrary.simpleMessage("تغيير بيانات الهوية"),
        "dashboardChangePhone":
            MessageLookupByLibrary.simpleMessage("تغيير رقم الهاتف"),
        "dashboardChequeServices":
            MessageLookupByLibrary.simpleMessage("الشيكات"),
        "dashboardClearCheque":
            MessageLookupByLibrary.simpleMessage("تسوية سجل الشيك"),
        "dashboardCloseExtras":
            MessageLookupByLibrary.simpleMessage("إغلاق الودائع الزائدة"),
        "dashboardConfirm": MessageLookupByLibrary.simpleMessage("تأكيد"),
        "dashboardCorrectInstallments":
            MessageLookupByLibrary.simpleMessage("تصحيح الأقساط المدفوعة"),
        "dashboardCustomize":
            MessageLookupByLibrary.simpleMessage("تخصيص الخدمات"),
        "dashboardDeferLoan":
            MessageLookupByLibrary.simpleMessage("تأجيل القرض"),
        "dashboardDepositsList":
            MessageLookupByLibrary.simpleMessage("قائمة الودائع"),
        "dashboardDepositsTab": MessageLookupByLibrary.simpleMessage("الودائع"),
        "dashboardEdit": MessageLookupByLibrary.simpleMessage("تعديل"),
        "dashboardEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد معلومات للعرض"),
        "dashboardEstimateCredit":
            MessageLookupByLibrary.simpleMessage("تقدير رصيد القرض"),
        "dashboardExpiredGift": MessageLookupByLibrary.simpleMessage(
            "تحويل رصيد بطاقة هدية منتهية"),
        "dashboardFavoritesLimit": MessageLookupByLibrary.simpleMessage(
            "يمكنك اختيار ٨ خدمات كحد أقصى."),
        "dashboardGreeting":
            MessageLookupByLibrary.simpleMessage("صباح الخير، ماني"),
        "dashboardIdentityServices":
            MessageLookupByLibrary.simpleMessage("المعلومات الشخصية"),
        "dashboardJobInformation":
            MessageLookupByLibrary.simpleMessage("إدارة الوظيفة"),
        "dashboardLoadError":
            MessageLookupByLibrary.simpleMessage("تعذر تحميل المعلومات"),
        "dashboardLoading":
            MessageLookupByLibrary.simpleMessage("جارٍ تحميل المعلومات…"),
        "dashboardLoanReport":
            MessageLookupByLibrary.simpleMessage("تقرير إحالة القرض"),
        "dashboardLoansTab": MessageLookupByLibrary.simpleMessage("القروض"),
        "dashboardLocalTransfer":
            MessageLookupByLibrary.simpleMessage("تحويل في الموقع"),
        "dashboardManageInstallments":
            MessageLookupByLibrary.simpleMessage("إدارة خصم الأقساط"),
        "dashboardModernBanking":
            MessageLookupByLibrary.simpleMessage("الخدمات المصرفية الحديثة"),
        "dashboardMyLoans": MessageLookupByLibrary.simpleMessage("قروضي"),
        "dashboardNoServices":
            MessageLookupByLibrary.simpleMessage("لم يتم العثور على خدمات"),
        "dashboardOpenCurrent":
            MessageLookupByLibrary.simpleMessage("فتح حساب جارٍ"),
        "dashboardPhoneBank":
            MessageLookupByLibrary.simpleMessage("الخدمات المصرفية الهاتفية"),
        "dashboardPromptCard":
            MessageLookupByLibrary.simpleMessage("كيف أحصل على بطاقة رسالت؟"),
        "dashboardPromptCertificate":
            MessageLookupByLibrary.simpleMessage("أحتاج إلى شهادة مالية…"),
        "dashboardPromptHint":
            MessageLookupByLibrary.simpleMessage("اكتب سؤالك..."),
        "dashboardRemoveService": MessageLookupByLibrary.simpleMessage("حذف"),
        "dashboardRequestDate":
            MessageLookupByLibrary.simpleMessage("2024/09/16 | ١٢:٤٥"),
        "dashboardRequestNumber":
            MessageLookupByLibrary.simpleMessage("١٣٧/٤٨٧٥٦٧"),
        "dashboardRequestServices":
            MessageLookupByLibrary.simpleMessage("طلباتي"),
        "dashboardRequestTitle":
            MessageLookupByLibrary.simpleMessage("طلب تغيير وديعة خصم الأقساط"),
        "dashboardRequests": MessageLookupByLibrary.simpleMessage("طلباتي"),
        "dashboardResetConfirm":
            MessageLookupByLibrary.simpleMessage("إعادة ضبط الإعدادات"),
        "dashboardResetDescription": MessageLookupByLibrary.simpleMessage(
            "ستؤدي إعادة الضبط إلى إزالة تغييراتك واستعادة الإعدادات الأصلية.\nهل تريد إعادة الضبط؟"),
        "dashboardResetTitle":
            MessageLookupByLibrary.simpleMessage("إعادة ضبط الإعدادات"),
        "dashboardResoDescription": MessageLookupByLibrary.simpleMessage(
            "رِسو لا يجيب فقط؛ بل يتولى العمل بنفسه."),
        "dashboardResoTitle":
            MessageLookupByLibrary.simpleMessage("اتركها لرِسو!"),
        "dashboardRetry": MessageLookupByLibrary.simpleMessage("حاول مرة أخرى"),
        "dashboardSearchHint": MessageLookupByLibrary.simpleMessage("بحث"),
        "dashboardSendPrompt":
            MessageLookupByLibrary.simpleMessage("إرسال السؤال"),
        "dashboardTab": MessageLookupByLibrary.simpleMessage("الرئيسية"),
        "dashboardTransferServices":
            MessageLookupByLibrary.simpleMessage("التحويلات"),
        "dashboardUnblockCard":
            MessageLookupByLibrary.simpleMessage("إلغاء حظر البطاقة"),
        "dashboardUnblockDeposit":
            MessageLookupByLibrary.simpleMessage("إلغاء حظر الوديعة"),
        "dashboardViewAll": MessageLookupByLibrary.simpleMessage("عرض الكل"),
        "dashboardVirtualCard":
            MessageLookupByLibrary.simpleMessage("طلب بطاقة افتراضية"),
        "dashboardWalletBalance":
            MessageLookupByLibrary.simpleMessage("١٬٢٠٠٬٠٠٠"),
        "dashboardWalletCharge":
            MessageLookupByLibrary.simpleMessage("إضافة رصيد"),
        "dashboardWalletDeposit": MessageLookupByLibrary.simpleMessage(
            "تغيير الوديعة المرتبطة بالمحفظة"),
        "dashboardWalletHistory":
            MessageLookupByLibrary.simpleMessage("سجل المحفظة"),
        "dashboardWalletInfo":
            MessageLookupByLibrary.simpleMessage("معلومات المحفظة"),
        "dashboardWalletServices":
            MessageLookupByLibrary.simpleMessage("المحفظة"),
        "dashboardWalletTransfer":
            MessageLookupByLibrary.simpleMessage("تحويل بين المحافظ"),
        "dashboardWalletWithdraw":
            MessageLookupByLibrary.simpleMessage("سحب الرصيد"),
        "dashboardWelcomeMessage": MessageLookupByLibrary.simpleMessage(
            "مرحباً بك في شباك رسالت الافتراضي"),
        "dashboardYourFavorites":
            MessageLookupByLibrary.simpleMessage("خدماتك المفضلة"),
        "depositBlockIntro":
            MessageLookupByLibrary.simpleMessage("اختر الوديعة وسبب حظرها"),
        "depositBlockTitle":
            MessageLookupByLibrary.simpleMessage("حظر الوديعة"),
        "depositBlockedDate":
            MessageLookupByLibrary.simpleMessage("تاريخ الحظر"),
        "depositBlockedReason":
            MessageLookupByLibrary.simpleMessage("سبب الحظر"),
        "depositListAccountDetails":
            MessageLookupByLibrary.simpleMessage("تفاصيل الحساب"),
        "depositListAccountType":
            MessageLookupByLibrary.simpleMessage("نوع الحساب"),
        "depositListBlock": MessageLookupByLibrary.simpleMessage("حظر الوديعة"),
        "depositListBlocked": MessageLookupByLibrary.simpleMessage("محظور"),
        "depositListClosed": MessageLookupByLibrary.simpleMessage("مغلق"),
        "depositListCurrent":
            MessageLookupByLibrary.simpleMessage("حساب جاري شخصي"),
        "depositListCustomerInformation":
            MessageLookupByLibrary.simpleMessage("معلومات العميل"),
        "depositListLinkedCards":
            MessageLookupByLibrary.simpleMessage("البطاقات المرتبطة بالحساب"),
        "depositListNationalId":
            MessageLookupByLibrary.simpleMessage("الرقم الوطني"),
        "depositListNoMatches": MessageLookupByLibrary.simpleMessage(
            "لا توجد ودائع تطابق هذه المرشحات."),
        "depositListNoOwners": MessageLookupByLibrary.simpleMessage(
            "معلومات أصحاب الحساب غير متوفرة."),
        "depositListNumber":
            MessageLookupByLibrary.simpleMessage("رقم الوديعة"),
        "depositListOpen": MessageLookupByLibrary.simpleMessage("مفتوح"),
        "depositListOwner":
            MessageLookupByLibrary.simpleMessage("صاحب الوديعة"),
        "depositListOwnerAndSignatory":
            MessageLookupByLibrary.simpleMessage("صاحب الوديعة والموقّع"),
        "depositListOwnerName": MessageLookupByLibrary.simpleMessage("الاسم"),
        "depositListOwnerPercent":
            MessageLookupByLibrary.simpleMessage("النسبة"),
        "depositListOwnerRole": MessageLookupByLibrary.simpleMessage("الدور"),
        "depositListSavings":
            MessageLookupByLibrary.simpleMessage("ادخار شخصي"),
        "depositListServiceUnavailable": MessageLookupByLibrary.simpleMessage(
            "ستتوفر هذه الخدمة بعد الربط بنظام البنك."),
        "depositListSignatory": MessageLookupByLibrary.simpleMessage("الموقّع"),
        "depositListSms":
            MessageLookupByLibrary.simpleMessage("إعدادات إرسال الرسائل"),
        "depositListStatement":
            MessageLookupByLibrary.simpleMessage("كشف الحساب | متوسط الرصيد"),
        "depositListStatus": MessageLookupByLibrary.simpleMessage("الحالة"),
        "depositMandate":
            MessageLookupByLibrary.simpleMessage("الوديعة بالوكالة"),
        "depositMandateAmount": MessageLookupByLibrary.simpleMessage("المبلغ"),
        "depositMandateAmountToman": m1,
        "depositMandateBroker": MessageLookupByLibrary.simpleMessage("الوسيط"),
        "depositMandateCompany": MessageLookupByLibrary.simpleMessage("الشركة"),
        "depositMandateCompanyHint":
            MessageLookupByLibrary.simpleMessage("اختر الشركة المطلوبة"),
        "depositMandateHint":
            MessageLookupByLibrary.simpleMessage("اختر وديعتك"),
        "depositMandateMockComplete": MessageLookupByLibrary.simpleMessage(
            "تمت محاكاة طلب الوديعة بالتوكيل. لم يتم إنشاء توكيل أو حجز رصيد حقيقي."),
        "depositMandateSubject":
            MessageLookupByLibrary.simpleMessage("الموضوع"),
        "depositMandateSubjectHint":
            MessageLookupByLibrary.simpleMessage("اختر موضوع الوديعة بالتوكيل"),
        "depositRestrictionDescription":
            MessageLookupByLibrary.simpleMessage("الوصف"),
        "depositRestrictionDescriptionHint":
            MessageLookupByLibrary.simpleMessage("أدخل الوصف عند الحاجة"),
        "depositRestrictionManagement":
            MessageLookupByLibrary.simpleMessage("إدارة الوديعة"),
        "depositRestrictionMockComplete": MessageLookupByLibrary.simpleMessage(
            "تمت محاكاة الطلب. لم تتغير أي وديعة أو محفظة حقيقية."),
        "depositRestrictionReason":
            MessageLookupByLibrary.simpleMessage("سبب الطلب"),
        "depositRestrictionReasonHint":
            MessageLookupByLibrary.simpleMessage("اختر سبب الطلب"),
        "depositServices":
            MessageLookupByLibrary.simpleMessage("خدمات الودائع"),
        "depositUnblockIntro":
            MessageLookupByLibrary.simpleMessage("اختر الوديعة وسبب رفع حظرها"),
        "depositUnblockReason":
            MessageLookupByLibrary.simpleMessage("سبب رفع الحظر"),
        "depositUnblockTitle":
            MessageLookupByLibrary.simpleMessage("رفع حظر الوديعة"),
        "depositsAgent": MessageLookupByLibrary.simpleMessage("إعدادات الممثل"),
        "depositsChequeOperations":
            MessageLookupByLibrary.simpleMessage("عمليات الشيكات"),
        "depositsCopyNumber":
            MessageLookupByLibrary.simpleMessage("نسخ رقم الوديعة"),
        "depositsEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد ودائع بعد"),
        "depositsLinkedCards":
            MessageLookupByLibrary.simpleMessage("البطاقات المرتبطة بالوديعة"),
        "depositsLinkedLoans":
            MessageLookupByLibrary.simpleMessage("حالة القروض المرتبطة"),
        "depositsLocalTransfer":
            MessageLookupByLibrary.simpleMessage("تحويل الأموال في الموقع"),
        "depositsMobileBank": MessageLookupByLibrary.simpleMessage(
            "الخدمات المصرفية عبر الهاتف المحمول"),
        "depositsMyTitle": MessageLookupByLibrary.simpleMessage("ودائعي"),
        "depositsOperations":
            MessageLookupByLibrary.simpleMessage("عمليات الودائع"),
        "enterDashboard":
            MessageLookupByLibrary.simpleMessage("الدخول إلى الشباك"),
        "financialAuthority": MessageLookupByLibrary.simpleMessage("الجهة"),
        "financialAuthorityHint":
            MessageLookupByLibrary.simpleMessage("اكتب الاسم الدقيق للجهة"),
        "financialAverageBalanceCondition":
            MessageLookupByLibrary.simpleMessage("إدراج متوسط الرصيد"),
        "financialCertificate":
            MessageLookupByLibrary.simpleMessage("شهادة الملاءة المالية"),
        "financialCertificateTitle":
            MessageLookupByLibrary.simpleMessage("طلب شهادة الملاءة المالية"),
        "financialCurrency":
            MessageLookupByLibrary.simpleMessage("العملة المعادلة"),
        "financialCurrencyHint": MessageLookupByLibrary.simpleMessage(
            "اختر عملة شهادة الملاءة المالية"),
        "financialDebitCredit":
            MessageLookupByLibrary.simpleMessage("إدراج حركة المدين والدائن"),
        "financialDeliveryStep":
            MessageLookupByLibrary.simpleMessage("معلومات استلام الشهادة"),
        "financialEmbassy": MessageLookupByLibrary.simpleMessage("السفارة"),
        "financialEmbassyHint":
            MessageLookupByLibrary.simpleMessage("اختر السفارة"),
        "financialEur": MessageLookupByLibrary.simpleMessage("يورو"),
        "financialExchangeRate":
            MessageLookupByLibrary.simpleMessage("إدراج سعر الصرف اليومي"),
        "financialExpiryHint": MessageLookupByLibrary.simpleMessage(
            "تاريخ انتهاء جواز السفر (YYYY/MM/DD)"),
        "financialFatherHint": MessageLookupByLibrary.simpleMessage(
            "اسم الأب بالإنجليزية كما في جواز السفر"),
        "financialHomeAddress":
            MessageLookupByLibrary.simpleMessage("عنوان السكن"),
        "financialIrr": MessageLookupByLibrary.simpleMessage("ريال إيراني"),
        "financialLatinAddress":
            MessageLookupByLibrary.simpleMessage("Address"),
        "financialLatinAddressHint": MessageLookupByLibrary.simpleMessage(
            "Unit, No, Alley, St, City, Province, Country, Postal code"),
        "financialLatinAddressPrompt": MessageLookupByLibrary.simpleMessage(
            "أدخل عنوانك بالإنجليزية لشهادة الملاءة المالية وفق تنسيق المثال."),
        "financialLatinExpiry":
            MessageLookupByLibrary.simpleMessage("Date of Expiry"),
        "financialLatinFather":
            MessageLookupByLibrary.simpleMessage("Father\'s name"),
        "financialLatinName": MessageLookupByLibrary.simpleMessage("Name"),
        "financialLatinPassport":
            MessageLookupByLibrary.simpleMessage("Passport No"),
        "financialLatinStep": MessageLookupByLibrary.simpleMessage(
            "المعلومات الشخصية بالأحرف اللاتينية"),
        "financialLatinSurname":
            MessageLookupByLibrary.simpleMessage("Surname"),
        "financialMaturityDate":
            MessageLookupByLibrary.simpleMessage("تاريخ استحقاق الوديعة"),
        "financialNameHint": MessageLookupByLibrary.simpleMessage(
            "الاسم بالإنجليزية كما في جواز السفر"),
        "financialOpenedAt":
            MessageLookupByLibrary.simpleMessage("إدراج تاريخ فتح الوديعة"),
        "financialOtherAuthority":
            MessageLookupByLibrary.simpleMessage("جهات أخرى"),
        "financialPassportHint":
            MessageLookupByLibrary.simpleMessage("رقم جواز السفر بالإنجليزية"),
        "financialPassportNumberCondition":
            MessageLookupByLibrary.simpleMessage(
                "رقم جواز السفر / رقم التسجيل"),
        "financialPassportPrompt": MessageLookupByLibrary.simpleMessage(
            "أدخل المعلومات التالية كما في جواز السفر."),
        "financialRecipient": MessageLookupByLibrary.simpleMessage("المستلم"),
        "financialRecipientHint":
            MessageLookupByLibrary.simpleMessage("اختر مستلم الشهادة"),
        "financialRecipientPrompt": MessageLookupByLibrary.simpleMessage(
            "اختر مستلم الشهادة والعملة المعادلة"),
        "financialRecipientStep":
            MessageLookupByLibrary.simpleMessage("مستلم الشهادة ونوع العملة"),
        "financialSurnameHint": MessageLookupByLibrary.simpleMessage(
            "اسم العائلة بالإنجليزية كما في جواز السفر"),
        "financialUsd": MessageLookupByLibrary.simpleMessage("دولار أمريكي"),
        "financialWithdrawalRules": MessageLookupByLibrary.simpleMessage(
            "شروط السحب من الودائع المشتركة / المؤسسية"),
        "flowExitTitle":
            MessageLookupByLibrary.simpleMessage("الخروج من العملية؟"),
        "giftBalanceCount":
            MessageLookupByLibrary.simpleMessage("عدد بطاقات الهدايا المنتهية"),
        "giftBalanceDepositHint":
            MessageLookupByLibrary.simpleMessage("اختر حساب الإيداع"),
        "giftBalanceDestination":
            MessageLookupByLibrary.simpleMessage("اختيار حساب الإيداع"),
        "giftBalanceEnd": MessageLookupByLibrary.simpleMessage("النهاية"),
        "giftBalanceIntro": MessageLookupByLibrary.simpleMessage(
            "اختر بطاقات الهدايا المنتهية"),
        "giftBalanceNext":
            MessageLookupByLibrary.simpleMessage("الخطوة التالية"),
        "giftBalanceNextDestination":
            MessageLookupByLibrary.simpleMessage("التالي: اختيار حساب الإيداع"),
        "giftBalanceRemaining":
            MessageLookupByLibrary.simpleMessage("الرصيد المتبقي (ريال)"),
        "giftBalanceRemoveCard": m2,
        "giftBalanceSearch":
            MessageLookupByLibrary.simpleMessage("البحث برقم البطاقة"),
        "giftBalanceSelectAll":
            MessageLookupByLibrary.simpleMessage("اختيار الكل"),
        "giftBalanceSelectedList": m3,
        "giftBalanceSelection":
            MessageLookupByLibrary.simpleMessage("اختيار البطاقات"),
        "giftBalanceSubmit":
            MessageLookupByLibrary.simpleMessage("إرسال الطلب"),
        "giftBalanceTitle": MessageLookupByLibrary.simpleMessage(
            "تحويل رصيد بطاقات الهدايا المنتهية"),
        "giftBalanceTotal":
            MessageLookupByLibrary.simpleMessage("المبلغ الإجمالي (ريال)"),
        "giftBalanceTransferTo":
            MessageLookupByLibrary.simpleMessage("التحويل إلى"),
        "guestServices":
            MessageLookupByLibrary.simpleMessage("خدمات لا تتطلب تسجيل الدخول"),
        "inheritance": MessageLookupByLibrary.simpleMessage("حصر الإرث"),
        "internetBank": MessageLookupByLibrary.simpleMessage(
            "الخدمات المصرفية عبر الإنترنت"),
        "internetBankSettings": MessageLookupByLibrary.simpleMessage(
            "إعدادات الخدمات المصرفية عبر الإنترنت"),
        "introduceAgent": MessageLookupByLibrary.simpleMessage("تعريف ممثل"),
        "introduceLoan": MessageLookupByLibrary.simpleMessage("تعريف القرض"),
        "issuanceAddAddress":
            MessageLookupByLibrary.simpleMessage("إضافة عنوان جديد"),
        "issuanceAddress": MessageLookupByLibrary.simpleMessage("العنوان"),
        "issuanceAddressDetail":
            MessageLookupByLibrary.simpleMessage("العنوان الكامل"),
        "issuanceAddressHint":
            MessageLookupByLibrary.simpleMessage("اختر عنوان استلام البطاقة"),
        "issuanceAddressInvalid": MessageLookupByLibrary.simpleMessage(
            "أدخل اسم العنوان والعنوان الكامل ورمزاً بريدياً من ١٠ أرقام."),
        "issuanceAddressTitle":
            MessageLookupByLibrary.simpleMessage("اسم العنوان"),
        "issuanceAgentCode": MessageLookupByLibrary.simpleMessage("رمز الموظف"),
        "issuanceAgentName":
            MessageLookupByLibrary.simpleMessage("الاسم الكامل للموظف"),
        "issuanceComplete":
            MessageLookupByLibrary.simpleMessage("تم إرسال الطلب."),
        "issuanceConfirmTitle":
            MessageLookupByLibrary.simpleMessage("تأكيد المعلومات ودفع الرسوم"),
        "issuanceCurrentCard":
            MessageLookupByLibrary.simpleMessage("رقم البطاقة الحالي"),
        "issuanceDeleteAddress":
            MessageLookupByLibrary.simpleMessage("حذف العنوان"),
        "issuanceDeliveryFee":
            MessageLookupByLibrary.simpleMessage("رسوم التوصيل"),
        "issuanceDeliveryTitle":
            MessageLookupByLibrary.simpleMessage("معلومات استلام البطاقة"),
        "issuanceDeposit":
            MessageLookupByLibrary.simpleMessage("اختيار الحساب"),
        "issuanceDepositHint":
            MessageLookupByLibrary.simpleMessage("اختر الحساب المطلوب"),
        "issuanceDepositNumber":
            MessageLookupByLibrary.simpleMessage("رقم الحساب"),
        "issuanceDone": MessageLookupByLibrary.simpleMessage("رجوع"),
        "issuanceEmpty": MessageLookupByLibrary.simpleMessage(
            "لا يوجد حساب مؤهل لإصدار البطاقة."),
        "issuanceEnd": MessageLookupByLibrary.simpleMessage("النهاية"),
        "issuanceExistingNumber":
            MessageLookupByLibrary.simpleMessage("إصدار بطاقة بالرقم الحالي"),
        "issuanceExpiry":
            MessageLookupByLibrary.simpleMessage("تاريخ انتهاء الصلاحية"),
        "issuanceIdentityFee":
            MessageLookupByLibrary.simpleMessage("رسوم التحقق من الهوية"),
        "issuanceIncludeAgent":
            MessageLookupByLibrary.simpleMessage("إدخال بيانات الموظف المصرفي"),
        "issuanceMockComplete": MessageLookupByLibrary.simpleMessage(
            "اكتملت معاينة الطلب؛ لم يتم دفع رسوم أو إصدار بطاقة فعلية."),
        "issuanceNationalId":
            MessageLookupByLibrary.simpleMessage("الرقم الوطني للمستلم"),
        "issuanceNewNumber":
            MessageLookupByLibrary.simpleMessage("إصدار بطاقة برقم جديد"),
        "issuanceNext": MessageLookupByLibrary.simpleMessage("الخطوة التالية"),
        "issuanceNextConfirm":
            MessageLookupByLibrary.simpleMessage("التالي: التأكيد والرسوم"),
        "issuanceNextDelivery": MessageLookupByLibrary.simpleMessage(
            "التالي: معلومات استلام البطاقة"),
        "issuanceNoPhysical":
            MessageLookupByLibrary.simpleMessage("لا أحتاج إلى بطاقة فعلية"),
        "issuanceOperation":
            MessageLookupByLibrary.simpleMessage("نوع العملية"),
        "issuanceOtherRecipient":
            MessageLookupByLibrary.simpleMessage("الاستلام بواسطة شخص آخر"),
        "issuancePayable":
            MessageLookupByLibrary.simpleMessage("المبلغ المستحق"),
        "issuancePostalCode":
            MessageLookupByLibrary.simpleMessage("الرمز البريدي"),
        "issuancePrintFee":
            MessageLookupByLibrary.simpleMessage("رسوم طباعة التقرير"),
        "issuanceRecipientMobile":
            MessageLookupByLibrary.simpleMessage("رقم جوال المستلم"),
        "issuanceRecipientName":
            MessageLookupByLibrary.simpleMessage("الاسم الكامل للمستلم"),
        "issuanceSaveAddress":
            MessageLookupByLibrary.simpleMessage("حفظ العنوان"),
        "issuanceSelectAddress":
            MessageLookupByLibrary.simpleMessage("اختيار العنوان"),
        "issuanceSelectionTitle":
            MessageLookupByLibrary.simpleMessage("اختيار الحساب ونوع الإصدار"),
        "issuanceStepSemantic": m4,
        "issuanceSubmit":
            MessageLookupByLibrary.simpleMessage("تأكيد الطلب وإرساله"),
        "issuanceSubmitError": MessageLookupByLibrary.simpleMessage(
            "تعذر إرسال الطلب. حاول مرة أخرى."),
        "issuanceSummary":
            MessageLookupByLibrary.simpleMessage("ملخص المعلومات"),
        "issuanceTerms":
            MessageLookupByLibrary.simpleMessage("الشروط والأحكام"),
        "issuanceTermsPrompt": MessageLookupByLibrary.simpleMessage(
            "لقد قرأت شروط الطلب وأوافق عليها."),
        "issuanceTermsUnavailable": MessageLookupByLibrary.simpleMessage(
            "سيتم عرض الشروط الرسمية بعد ربط الخدمة."),
        "issuanceTitle":
            MessageLookupByLibrary.simpleMessage("إصدار بطاقة رسالت"),
        "issuanceType":
            MessageLookupByLibrary.simpleMessage("نوع إصدار البطاقة"),
        "issuanceTypeHint":
            MessageLookupByLibrary.simpleMessage("حدد نوع الإصدار"),
        "issuanceWallet": MessageLookupByLibrary.simpleMessage("رصيد المحفظة"),
        "issuanceWalletInsufficient":
            MessageLookupByLibrary.simpleMessage("رصيد المحفظة غير كافٍ"),
        "issuanceWalletSufficient":
            MessageLookupByLibrary.simpleMessage("رصيد المحفظة كافٍ"),
        "issueChequeBook":
            MessageLookupByLibrary.simpleMessage("إصدار دفتر شيكات"),
        "issueResalatCard":
            MessageLookupByLibrary.simpleMessage("إصدار بطاقة رسالت"),
        "latestUpdatedRequests":
            MessageLookupByLibrary.simpleMessage("آخر الطلبات المحدثة"),
        "loanEstimate": MessageLookupByLibrary.simpleMessage("تقدير القرض"),
        "loanRequestAmount": MessageLookupByLibrary.simpleMessage("مبلغ وام"),
        "loanRequestApproved":
            MessageLookupByLibrary.simpleMessage("تایید شد."),
        "loanRequestAssessment":
            MessageLookupByLibrary.simpleMessage("اعتبارسنجی و تعیین مبلغ وام"),
        "loanRequestAvailability": MessageLookupByLibrary.simpleMessage(
            "مانده وام قابل دریافت مجاز می‌باشد."),
        "loanRequestAwaitingCollateral":
            MessageLookupByLibrary.simpleMessage("در انتظار سفته"),
        "loanRequestAwaitingSignature":
            MessageLookupByLibrary.simpleMessage("در انتظار امضا"),
        "loanRequestBankDebt":
            MessageLookupByLibrary.simpleMessage("بدهی بانکی"),
        "loanRequestBothAssessmentHint": m5,
        "loanRequestCancel": MessageLookupByLibrary.simpleMessage("انصراف"),
        "loanRequestCancelPrompt": MessageLookupByLibrary.simpleMessage(
            "از انصراف از درخواست جاری مطمئن هستید؟"),
        "loanRequestCapacityDeficit":
            MessageLookupByLibrary.simpleMessage("کسری توان بازپرداخت:"),
        "loanRequestCheck": MessageLookupByLibrary.simpleMessage("بررسی"),
        "loanRequestCheque":
            MessageLookupByLibrary.simpleMessage("چک الکترونیک"),
        "loanRequestChequeHint": MessageLookupByLibrary.simpleMessage(
            "شناسه چک الکترونیک را وارد کنید"),
        "loanRequestChequeNumber":
            MessageLookupByLibrary.simpleMessage("شناسه چک الکترونیک"),
        "loanRequestCollateral":
            MessageLookupByLibrary.simpleMessage("چک / سفته الکترونیک"),
        "loanRequestCollateralAfter":
            MessageLookupByLibrary.simpleMessage(" تهیه کنید."),
        "loanRequestCollateralAmount":
            MessageLookupByLibrary.simpleMessage("مبلغ تضمین مورد نیاز:"),
        "loanRequestCollateralBefore": MessageLookupByLibrary.simpleMessage(
            "برای ضمانت وام خود، لازم است سند الکترونیک معادل ۱۲۰٪ مبلغ وام، به ارزش "),
        "loanRequestCollateralDetails": m6,
        "loanRequestContinue":
            MessageLookupByLibrary.simpleMessage("ادامه فرآیند"),
        "loanRequestContract":
            MessageLookupByLibrary.simpleMessage("امضاء قرارداد"),
        "loanRequestContractAccept":
            MessageLookupByLibrary.simpleMessage("تایید قوانین و مقررات"),
        "loanRequestContractContinue":
            MessageLookupByLibrary.simpleMessage("مشاهده قرارداد و ادامه"),
        "loanRequestCreditEnough":
            MessageLookupByLibrary.simpleMessage("اعتبار مورد نیاز کافی است."),
        "loanRequestCreditInfo": MessageLookupByLibrary.simpleMessage(
            "طبقه اعتباری از ارزیابی توان مالی مرآت شما به دست می‌آید و مشخص‌کننده توان بازپرداخت اقساط وام توسط شماست. این طبقه اعتباری شامل سه بازه است.\n\n• ممتاز: در این بازه شما نیاز به ضامن ندارید و می‌توانید بدون گذاشتن چک یا سفته الکترونیک درخواست وام نمایید.\n\n• کاملاً متناسب: در این بازه شما نیاز به ضامن ندارید و خودتان می‌توانید با گذاشتن چک یا سفته الکترونیک درخواست وام نمایید.\n\n• متناسب: در این بازه شما نیاز به ضامن دارید و هم شما و هم ضامن باید معادل ۱۲۰٪ مبلغ وام درخواستی چک یا سفته الکترونیک تهیه کنید."),
        "loanRequestCurrent":
            MessageLookupByLibrary.simpleMessage("درخواست جاری"),
        "loanRequestCurrentHeader":
            MessageLookupByLibrary.simpleMessage("درخواست جاری"),
        "loanRequestCurrentStage":
            MessageLookupByLibrary.simpleMessage("مرحله جاری:"),
        "loanRequestCurrentTotal":
            MessageLookupByLibrary.simpleMessage("مجموع وام‌های جاری"),
        "loanRequestDeposit": MessageLookupByLibrary.simpleMessage("سپرده*"),
        "loanRequestDepositHint":
            MessageLookupByLibrary.simpleMessage("سپرده خود را انتخاب کنید"),
        "loanRequestDetails":
            MessageLookupByLibrary.simpleMessage("مشاهده جزئیات"),
        "loanRequestDownloadContract":
            MessageLookupByLibrary.simpleMessage("دانلود قرارداد"),
        "loanRequestEnd": MessageLookupByLibrary.simpleMessage("پایان"),
        "loanRequestEnterBoth": MessageLookupByLibrary.simpleMessage(
            "کد خزانه‌داری سفته خود و سفته ضامن را وارد کنید."),
        "loanRequestExcellent": MessageLookupByLibrary.simpleMessage("ممتاز"),
        "loanRequestFee": MessageLookupByLibrary.simpleMessage("کارمزد"),
        "loanRequestFullySuitable":
            MessageLookupByLibrary.simpleMessage("کاملاً متناسب"),
        "loanRequestGuarantorCollateralHint": MessageLookupByLibrary.simpleMessage(
            "شما و ضامن هر کدام باید چک یا سفته الکترونیک معادل ۱۲۰٪ مبلغ وام تهیه و شناسه آن را وارد کنید."),
        "loanRequestGuarantorDetails": MessageLookupByLibrary.simpleMessage(
            "همچنین ضامن شما باید همین مبلغ سند ضمانت تهیه کند. سفته را از سامانه آی‌کاپ خریداری و شماره خزانه‌داری آن را وارد کنید."),
        "loanRequestGuarantorFull": MessageLookupByLibrary.simpleMessage(
            "ضامن معرفی‌شده سقف ضمانت کافی ندارد. لطفاً فرد دیگری معرفی کنید."),
        "loanRequestGuarantorId":
            MessageLookupByLibrary.simpleMessage("کد ملی ضامن"),
        "loanRequestGuarantorIdHint":
            MessageLookupByLibrary.simpleMessage("کد ملی ضامن را وارد کنید"),
        "loanRequestGuarantorInfo":
            MessageLookupByLibrary.simpleMessage("اطلاعات ضامن:"),
        "loanRequestGuarantorName":
            MessageLookupByLibrary.simpleMessage("نام ضامن"),
        "loanRequestGuarantorNotCustomer": MessageLookupByLibrary.simpleMessage(
            "ضامن معرفی‌شده مشتری بانک قرض‌الحسنه رسالت نیست. لطفاً فرد دیگری معرفی کنید."),
        "loanRequestIcup":
            MessageLookupByLibrary.simpleMessage("سامانه آی‌کاپ"),
        "loanRequestIcupAfter": MessageLookupByLibrary.simpleMessage(
            " أو سجّل شيكاً إلكترونياً لأمر بنك رسالت، ثم أدخل معرّفه."),
        "loanRequestIcupBefore":
            MessageLookupByLibrary.simpleMessage("اشترِ السند الإلكتروني عبر "),
        "loanRequestIncomeExplanation": MessageLookupByLibrary.simpleMessage(
            "در صورت داشتن شرایط، با ارائه اسناد شغلی در سامانه مرآت می‌توانید درخواست افزایش توان مالی ثبت کنید."),
        "loanRequestIncomeSolution": MessageLookupByLibrary.simpleMessage(
            "بالا بردن توان بازپرداخت با ارائه اسناد درآمدی در مرآت"),
        "loanRequestInquiries":
            MessageLookupByLibrary.simpleMessage("استعلامات"),
        "loanRequestInstallment": MessageLookupByLibrary.simpleMessage("قسط"),
        "loanRequestInstallments": MessageLookupByLibrary.simpleMessage("قسطی"),
        "loanRequestInstrumentInvalid":
            MessageLookupByLibrary.simpleMessage("شماره واردشده صحیح نیست."),
        "loanRequestInsurance":
            MessageLookupByLibrary.simpleMessage("پوشش بیمه عمر وام"),
        "loanRequestInsuranceAmount":
            MessageLookupByLibrary.simpleMessage("مبلغ بیمه"),
        "loanRequestInsuranceDetails":
            MessageLookupByLibrary.simpleMessage("جزئیات بیمه عمر وام"),
        "loanRequestInsuranceHint": MessageLookupByLibrary.simpleMessage(
            "این تسهیلات دارای پوشش بیمه عمر است."),
        "loanRequestInsuranceOptional":
            MessageLookupByLibrary.simpleMessage("بیمه عمر وام"),
        "loanRequestInsuranceOptionalHint":
            MessageLookupByLibrary.simpleMessage(
                "با انتخاب این گزینه، وام شما تحت پوشش بیمه عمر قرار می‌گیرد."),
        "loanRequestLumpSum": MessageLookupByLibrary.simpleMessage("یکجا"),
        "loanRequestMerat":
            MessageLookupByLibrary.simpleMessage("اعتبارسنجی مرآت"),
        "loanRequestMeratLink": MessageLookupByLibrary.simpleMessage("مرآت"),
        "loanRequestMilitary":
            MessageLookupByLibrary.simpleMessage("نظام وظیفه"),
        "loanRequestMissingInsurance": MessageLookupByLibrary.simpleMessage(
            "متن نهایی پوشش و قرارداد بیمه باید توسط بانک ارائه شود. این صفحه صرفاً نمونه آزمایشی است."),
        "loanRequestMockContract": MessageLookupByLibrary.simpleMessage(
            "پیش‌نمایش آزمایشی قرارداد درخواست تسهیلات. متن نهایی قرارداد مورد تایید بانک هنوز ارائه نشده است. تایید این نمونه فقط برای آزمایش جریان برنامه است و امضای بانکی ایجاد نمی‌کند."),
        "loanRequestMockContractBody": MessageLookupByLibrary.simpleMessage(
            "پیش‌نمایش آزمایشی — طرفین قرارداد\nاطلاعات متقاضی، بانک و مشخصات سپرده در این قسمت از قرارداد نهایی قرار می‌گیرد. این متن نمونه جایگزین قرارداد بانک نیست.\n\nپیش‌نمایش آزمایشی — مبلغ و شرایط تسهیلات\nمبلغ تسهیلات، روش بازپرداخت، تعداد اقساط و سررسیدها باید از قرارداد رسمی و نتیجه بررسی درخواست دریافت شوند. مبالغ و تاریخ‌های نسخه Mock صرفاً برای آزمون رابط هستند.\n\nپیش‌نمایش آزمایشی — تضامین\nمشخصات اسناد ضمانت و ضامن، در صورت نیاز، پس از بررسی و تطبیق توسط بانک به قرارداد افزوده می‌شود. نمایش این بخش به معنی تأیید ضمانت نیست.\n\nپیش‌نمایش آزمایشی — پوشش بیمه\nشرح پوشش، شرایط و مبلغ بیمه باید از متن مصوب بانک دریافت شود. تغییر انتخاب بیمه در این نسخه فقط یک سناریوی آزمایشی است و خرید بیمه انجام نمی‌دهد.\n\nپیش‌نمایش آزمایشی — تعهدات و مقررات\nحقوق و تعهدات طرفین، مقررات بازپرداخت و سایر شرایط در متن نهایی مصوب بانک درج خواهد شد. برای نمایش و آزمون اسکرول، این قسمت نمونه‌ای از فضای متن قرارداد است.\n\nپیش‌نمایش آزمایشی — تأیید و امضا\nانتخاب تأیید و واردکردن کد آزمایشی صرفاً مسیر رابط را آزمایش می‌کند. این نسخه امضای الکترونیک یا قرارداد لازم‌الاجرا ایجاد نمی‌کند."),
        "loanRequestMonthUnit": MessageLookupByLibrary.simpleMessage("ماه"),
        "loanRequestMonthly":
            MessageLookupByLibrary.simpleMessage("مبلغ قسط ماهانه"),
        "loanRequestMonths":
            MessageLookupByLibrary.simpleMessage("مدت زمان بازپرداخت"),
        "loanRequestNeededCapacity": MessageLookupByLibrary.simpleMessage(
            "توان بازپرداخت ماهانه مورد نیاز:"),
        "loanRequestNext": MessageLookupByLibrary.simpleMessage("مرحله بعد"),
        "loanRequestNextPrefix": MessageLookupByLibrary.simpleMessage("بعدی: "),
        "loanRequestNoCollateral": MessageLookupByLibrary.simpleMessage(
            "برای دریافت این مبلغ وام به ضامن و اسناد ضمانتی نیاز ندارید."),
        "loanRequestNote":
            MessageLookupByLibrary.simpleMessage("سفته الکترونیک"),
        "loanRequestNoteAmount":
            MessageLookupByLibrary.simpleMessage("مبلغ سفته مورد نیاز:"),
        "loanRequestNoteHint": MessageLookupByLibrary.simpleMessage(
            "شماره خزانه‌داری سفته را وارد کنید"),
        "loanRequestNoteNumber": MessageLookupByLibrary.simpleMessage(
            "شماره خزانه‌داری سفته الکترونیک"),
        "loanRequestOtpHint": MessageLookupByLibrary.simpleMessage(
            "کد تایید ارسال‌شده به شماره زیر را وارد کنید."),
        "loanRequestOtpInvalid": MessageLookupByLibrary.simpleMessage(
            "کد تایید صحیح نیست یا منقضی شده است."),
        "loanRequestOtpMessage": m7,
        "loanRequestOtpTitle":
            MessageLookupByLibrary.simpleMessage("کد تایید را وارد کنید"),
        "loanRequestOutstandingDebt":
            MessageLookupByLibrary.simpleMessage("مانده بدهی"),
        "loanRequestOwnAssessmentHint": m8,
        "loanRequestOwnCollateralHint": MessageLookupByLibrary.simpleMessage(
            "برای ضمانت وام خود، چک یا سفته الکترونیک معادل ۱۲۰٪ مبلغ وام در وجه بانک تهیه و شناسه آن را وارد کنید."),
        "loanRequestOwnDetails": MessageLookupByLibrary.simpleMessage(
            "سفته را از سامانه آی‌کاپ خریداری کنید یا چک الکترونیک در وجه بانک قرض‌الحسنه رسالت ثبت نمایید و شناسه آن را وارد کنید."),
        "loanRequestOwnInfo":
            MessageLookupByLibrary.simpleMessage("اطلاعات شما:"),
        "loanRequestProcessing":
            MessageLookupByLibrary.simpleMessage("در حال بررسی ..."),
        "loanRequestRaiseCollateral": MessageLookupByLibrary.simpleMessage(
            "برای دریافت این مبلغ به ضامن نیاز دارید. شما و ضامن هر کدام باید اسناد ضمانت معادل ۱۲۰٪ مبلغ وام تهیه کنید."),
        "loanRequestReady": MessageLookupByLibrary.simpleMessage("آماده واریز"),
        "loanRequestRejected": MessageLookupByLibrary.simpleMessage(
            "استعلام تایید نشد. پس از رفع مشکل تلاش مجدد کنید."),
        "loanRequestRepayment":
            MessageLookupByLibrary.simpleMessage("نوع بازپرداخت:"),
        "loanRequestReports":
            MessageLookupByLibrary.simpleMessage("گزارش درخواست‌ها"),
        "loanRequestRequestDate":
            MessageLookupByLibrary.simpleMessage("تاریخ درخواست:"),
        "loanRequestRequestNumber":
            MessageLookupByLibrary.simpleMessage("شماره درخواست:"),
        "loanRequestRequestedAmount":
            MessageLookupByLibrary.simpleMessage("مبلغ وام درخواستی:"),
        "loanRequestResend": MessageLookupByLibrary.simpleMessage("ارسال مجدد"),
        "loanRequestReturnedCheque":
            MessageLookupByLibrary.simpleMessage("چک برگشتی"),
        "loanRequestReviewed": MessageLookupByLibrary.simpleMessage(
            "استعلام‌ها توسط سیستم بررسی شد."),
        "loanRequestReviewing":
            MessageLookupByLibrary.simpleMessage("سیستم درحال بررسی استعلامات"),
        "loanRequestScheduleTitle":
            MessageLookupByLibrary.simpleMessage("جدول اقساط"),
        "loanRequestScore":
            MessageLookupByLibrary.simpleMessage("امتیاز ۱۰ ماهه"),
        "loanRequestSettle":
            MessageLookupByLibrary.simpleMessage("تسویه وام‌های قبلی"),
        "loanRequestSettleExplanation": MessageLookupByLibrary.simpleMessage(
            "با تسویه وام‌های جاری می‌توانید برای ارزیابی مجدد توان بازپرداخت خود اقدام کنید."),
        "loanRequestSocialCore":
            MessageLookupByLibrary.simpleMessage("هسته اعتماد اجتماعی"),
        "loanRequestSolution": MessageLookupByLibrary.simpleMessage("راهکارها"),
        "loanRequestStatusCheck":
            MessageLookupByLibrary.simpleMessage("بررسی وضعیت:"),
        "loanRequestSubmit": MessageLookupByLibrary.simpleMessage("ثبت"),
        "loanRequestSuccess": MessageLookupByLibrary.simpleMessage(
            "درخواست تسهیلات شما با موفقیت ثبت شد. پرونده شما جهت بررسی در صف پردازش قرار دارد. نتیجه نهایی متعاقباً اعلام خواهد شد."),
        "loanRequestSuitable": MessageLookupByLibrary.simpleMessage("متناسب"),
        "loanRequestTable":
            MessageLookupByLibrary.simpleMessage("مشاهده جدول اقساط"),
        "loanRequestTerms": MessageLookupByLibrary.simpleMessage(
            "قوانین و مقررات درخواست را مطالعه و تایید می‌نمایم."),
        "loanRequestTier": MessageLookupByLibrary.simpleMessage("طبقه اعتباری"),
        "loanRequestTitle": MessageLookupByLibrary.simpleMessage("درخواست وام"),
        "loanRequestTracking":
            MessageLookupByLibrary.simpleMessage("کد پیگیری عملیات:"),
        "loanRequestUnavailable": MessageLookupByLibrary.simpleMessage(
            "محتوا یا سرویس مورد تایید بانک هنوز متصل نشده است."),
        "loanRequestUnknown": MessageLookupByLibrary.simpleMessage("نامشخص"),
        "loanRequestUnknownHint": MessageLookupByLibrary.simpleMessage(
            "ارزیابی توان مالی شما در سامانه مرآت انجام نشده است. تا تعیین توان بازپرداخت ماهانه، امکان درخواست وام وجود ندارد."),
        "loanRequestUnsuitable":
            MessageLookupByLibrary.simpleMessage("نامتناسب"),
        "loanRequestUnsuitableHint": MessageLookupByLibrary.simpleMessage(
            "توان بازپرداخت برای مبلغ انتخاب‌شده کافی نیست. مبلغ وام را کاهش دهید یا مدت بازپرداخت را افزایش دهید."),
        "loanRequestVideoHint": MessageLookupByLibrary.simpleMessage(
            "پیشنهاد می‌کنیم پیش از درخواست وام ویدئوی راهنما را تماشا کنید."),
        "loanRequestViewContract":
            MessageLookupByLibrary.simpleMessage("مشاهده قرارداد"),
        "loanRequestYourCapacity":
            MessageLookupByLibrary.simpleMessage("توان بازپرداخت ماهانه شما:"),
        "loanServices": MessageLookupByLibrary.simpleMessage("خدمات القروض"),
        "loansChangeDeposit":
            MessageLookupByLibrary.simpleMessage("تغيير وديعة خصم الأقساط"),
        "loansDefaultName":
            MessageLookupByLibrary.simpleMessage("قرض حسن عادي (بدون رسوم)"),
        "loansEmpty": MessageLookupByLibrary.simpleMessage("لا توجد قروض بعد"),
        "loansOperations":
            MessageLookupByLibrary.simpleMessage("عمليات القروض"),
        "loansPayInstallments":
            MessageLookupByLibrary.simpleMessage("دفع الأقساط"),
        "loansRelationships":
            MessageLookupByLibrary.simpleMessage("علاقات القرابة والمصاهرة"),
        "loginDescription": MessageLookupByLibrary.simpleMessage(
            "أدخل المعلومات التالية للدخول إلى حسابك"),
        "loginNationalIdHint": MessageLookupByLibrary.simpleMessage(
            "الرقم الوطني | رقم الهوية | رمز الأجانب"),
        "loginPhoneHint":
            MessageLookupByLibrary.simpleMessage("أدخل رقم هاتفك المحمول"),
        "loginTitle":
            MessageLookupByLibrary.simpleMessage("الدخول برقم الهوية"),
        "memberContactCenter":
            MessageLookupByLibrary.simpleMessage("مركز اتصال الأعضاء"),
        "mobileBank":
            MessageLookupByLibrary.simpleMessage("الخدمات المصرفية عبر الهاتف"),
        "mobileBankSettings": MessageLookupByLibrary.simpleMessage(
            "إعدادات الخدمات المصرفية عبر الهاتف"),
        "modernActivate": MessageLookupByLibrary.simpleMessage(
            "تفعيل الخدمات المصرفية عبر الهاتف"),
        "modernActivationIntro": MessageLookupByLibrary.simpleMessage(
            "يلزم تفعيل الخدمات المصرفية عبر الهاتف قبل تسجيل الدخول."),
        "modernAwaitingIdentity": MessageLookupByLibrary.simpleMessage(
            "بانتظار نتيجة التحقق من الهوية"),
        "modernCompromised":
            MessageLookupByLibrary.simpleMessage("اشتباه اختراق"),
        "modernDeactivate":
            MessageLookupByLibrary.simpleMessage("إلغاء التفعيل"),
        "modernDeactivationIntro": MessageLookupByLibrary.simpleMessage(
            "اختر سبب إلغاء تفعيل المصرف عبر الهاتف."),
        "modernDeactivationSaved": MessageLookupByLibrary.simpleMessage(
            "تم تسجيل إلغاء التفعيل في النسخة التجريبية. لم تتغير أي خدمة مصرفية فعلية."),
        "modernDeactivationTitle": MessageLookupByLibrary.simpleMessage(
            "إلغاء تفعيل المصرف عبر الهاتف"),
        "modernEdit": MessageLookupByLibrary.simpleMessage("تعديل"),
        "modernGuideLogin": MessageLookupByLibrary.simpleMessage(
            "لتغيير كلمة المرور، سجل الدخول أولاً إلى المصرف عبر الهاتف."),
        "modernGuideOther": MessageLookupByLibrary.simpleMessage(
            "اختر تغيير كلمة المرور من قسم أخرى."),
        "modernGuidePage": m9,
        "modernGuidePassword": MessageLookupByLibrary.simpleMessage(
            "أدخل كلمة المرور الحالية، ثم أدخل كلمة المرور الجديدة وكررها."),
        "modernIdentityNotice": MessageLookupByLibrary.simpleMessage(
            "يتطلب التحقق تطابق الرقم الوطني ورقم الهاتف."),
        "modernInternal": MessageLookupByLibrary.simpleMessage("داخل البنك"),
        "modernKycStep":
            MessageLookupByLibrary.simpleMessage("التحقق من الهوية"),
        "modernLimitError": MessageLookupByLibrary.simpleMessage(
            "أدخل مبلغاً أكبر من صفر وضمن الحد المسموح."),
        "modernLimitsEditIntro": MessageLookupByLibrary.simpleMessage(
            "حدد الحدود اليومية لكل نوع من التحويلات."),
        "modernLimitsIntro": MessageLookupByLibrary.simpleMessage(
            "حدود التحويل اليومية الحالية في المصرف عبر الهاتف موضحة أدناه."),
        "modernLimitsSaved": MessageLookupByLibrary.simpleMessage(
            "تم حفظ حدود التحويل في النسخة التجريبية. لم يتم تغيير الحساب المصرفي."),
        "modernLimitsTitle":
            MessageLookupByLibrary.simpleMessage("تغيير حدود التحويل"),
        "modernMaximumLimit": m10,
        "modernOperations":
            MessageLookupByLibrary.simpleMessage("خدمات المصرف عبر الهاتف"),
        "modernOtherReason": MessageLookupByLibrary.simpleMessage("أخرى"),
        "modernPasswordFee":
            MessageLookupByLibrary.simpleMessage("رسوم إصدار كلمة المرور"),
        "modernPaya":
            MessageLookupByLibrary.simpleMessage("تحويل بايا بين البنوك"),
        "modernPaymentStep": MessageLookupByLibrary.simpleMessage("دفع الرسوم"),
        "modernPreviewNotice": MessageLookupByLibrary.simpleMessage(
            "هذه معاينة لمرحلة ما بعد التسجيل. لا يتم حالياً تسجيل أي فيديو أو رفعه."),
        "modernReason": MessageLookupByLibrary.simpleMessage("سبب الطلب"),
        "modernReasonHint": MessageLookupByLibrary.simpleMessage("اختر السبب"),
        "modernRecoveryTitle": MessageLookupByLibrary.simpleMessage(
            "استعادة كلمة مرور المصرف عبر الهاتف"),
        "modernRefundNotice": MessageLookupByLibrary.simpleMessage(
            "إذا فشل التحقق من الهوية، تُعاد الرسوم المخصومة إلى محفظتك خلال 72 ساعة."),
        "modernRegistryFee":
            MessageLookupByLibrary.simpleMessage("رسوم السجل المدني"),
        "modernRejected": MessageLookupByLibrary.simpleMessage(
            "لم تتم الموافقة على التحقق. يمكنك تقديم طلب جديد."),
        "modernRequestStatus":
            MessageLookupByLibrary.simpleMessage("حالة الطلب"),
        "modernSatna": MessageLookupByLibrary.simpleMessage("ساتنا بين البنوك"),
        "modernSerialStep": MessageLookupByLibrary.simpleMessage(
            "الرقم التسلسلي للبطاقة الوطنية"),
        "modernTermsUnavailable": MessageLookupByLibrary.simpleMessage(
            "لم يتم توفير شروط هذه الخدمة بعد."),
        "modernToman": m11,
        "modernUsername": MessageLookupByLibrary.simpleMessage("اسم المستخدم"),
        "modernUsernameNotice": MessageLookupByLibrary.simpleMessage(
            "اسم المستخدم الافتراضي هو رقم العميل المطبوع أعلى رقم بطاقتك المصرفية."),
        "notificationEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد رسائل"),
        "notificationFiveDays":
            MessageLookupByLibrary.simpleMessage("قبل ٥ أيام"),
        "notificationInvestmentSubtitle": MessageLookupByLibrary.simpleMessage(
            "تداول الذهب بسهولة وسرعة مع تسوية فورية"),
        "notificationInvestmentTitle":
            MessageLookupByLibrary.simpleMessage("استثمر في الذهب"),
        "notificationLoanSubtitle":
            MessageLookupByLibrary.simpleMessage("قرض بضمان"),
        "notificationLoanTitle":
            MessageLookupByLibrary.simpleMessage("اقترض بضمان مدخراتك"),
        "notificationNew":
            MessageLookupByLibrary.simpleMessage("الرسائل الجديدة"),
        "notificationRead":
            MessageLookupByLibrary.simpleMessage("الرسائل المقروءة"),
        "notificationReadAll":
            MessageLookupByLibrary.simpleMessage("قراءة الكل"),
        "notificationSampleDate":
            MessageLookupByLibrary.simpleMessage("١٦ شهريور ١٤٠٥"),
        "notificationSecurityAdvice": MessageLookupByLibrary.simpleMessage(
            "لتجنب الاحتيال والحفاظ على أمان حسابك، تذكر:"),
        "notificationSecurityClosing": MessageLookupByLibrary.simpleMessage(
            "إذا لاحظت أمراً مشبوهاً، أخبرنا فوراً للتحقق منه."),
        "notificationSecurityCode": MessageLookupByLibrary.simpleMessage(
            "لا تشارك رمز الدخول: لن يطلب فريق الدعم كلمة المرور أو رمز التحقق منك أبداً."),
        "notificationSecurityIntro": MessageLookupByLibrary.simpleMessage(
            "مرحباً! قد تصلك رسائل من محتالين ينتحلون صفة فريق الدعم. لحماية حسابك، انتبه للنصائح التالية:"),
        "notificationSecurityLinks": MessageLookupByLibrary.simpleMessage(
            "لا تفتح روابط مشبوهة: تجنب الروابط المجهولة التي تدعي حظر حسابك أو فوزك بجائزة."),
        "notificationSecurityOfficial": MessageLookupByLibrary.simpleMessage(
            "استخدم القنوات الرسمية: تأكد من أن الرسائل تأتي من أرقامنا أو حساباتنا الرسمية."),
        "notificationSecuritySubtitle":
            MessageLookupByLibrary.simpleMessage("نصائح لحماية حسابك"),
        "notificationSecurityTitle":
            MessageLookupByLibrary.simpleMessage("احذر المحتالين ⚠️"),
        "notificationSevenDays":
            MessageLookupByLibrary.simpleMessage("قبل ٧ أيام"),
        "notificationSubject": MessageLookupByLibrary.simpleMessage("العنوان"),
        "notificationTitle": MessageLookupByLibrary.simpleMessage("الإشعارات"),
        "notificationToday": MessageLookupByLibrary.simpleMessage("اليوم"),
        "notificationYesterday": MessageLookupByLibrary.simpleMessage("أمس"),
        "notificationsLabel": MessageLookupByLibrary.simpleMessage("الإشعارات"),
        "otpHint": MessageLookupByLibrary.simpleMessage("أدخل الرمز"),
        "otpSentMessage": m12,
        "otpSentTitle": MessageLookupByLibrary.simpleMessage("تم إرسال الرمز."),
        "passwordApprovedBody": MessageLookupByLibrary.simpleMessage(
            "ستصلك رسالة ببيانات الدخول إلى البنك عبر الهاتف، ويمكنك تسجيل الدخول باستخدامها."),
        "passwordApprovedTitle":
            MessageLookupByLibrary.simpleMessage("تم إنجاز طلبك بنجاح"),
        "passwordCameraNotice": MessageLookupByLibrary.simpleMessage(
            "تتطلب هذه الخطوة الكاميرا والميكروفون."),
        "passwordCardNumber":
            MessageLookupByLibrary.simpleMessage("رقم البطاقة"),
        "passwordCardNumberHint":
            MessageLookupByLibrary.simpleMessage("اختر رقم البطاقة"),
        "passwordCardType": MessageLookupByLibrary.simpleMessage("نوع البطاقة"),
        "passwordCardTypeHint":
            MessageLookupByLibrary.simpleMessage("اختر نوع بطاقتك"),
        "passwordChange":
            MessageLookupByLibrary.simpleMessage("تغيير كلمة المرور"),
        "passwordChangePrompt": MessageLookupByLibrary.simpleMessage(
            "أدخل كلمة المرور الحالية وكلمة المرور الجديدة التي تريدها."),
        "passwordChangeSubmit":
            MessageLookupByLibrary.simpleMessage("تسجيل الطلب"),
        "passwordChangeSuccessBody":
            MessageLookupByLibrary.simpleMessage("تم تغيير كلمة المرور بنجاح."),
        "passwordConfirmMock":
            MessageLookupByLibrary.simpleMessage("تأكيد المعاينة التجريبية"),
        "passwordConfirmationHint":
            MessageLookupByLibrary.simpleMessage("تأكيد كلمة المرور"),
        "passwordCurrentHint":
            MessageLookupByLibrary.simpleMessage("كلمة المرور الحالية"),
        "passwordDateRule": MessageLookupByLibrary.simpleMessage(
            "تجنب التواريخ المهمة (الميلاد، انتهاء البطاقة)"),
        "passwordDemoVideo": MessageLookupByLibrary.simpleMessage(
            "فيديو تجريبي: Big Buck Bunny — Blender Foundation (CC BY 3.0)"),
        "passwordExit": MessageLookupByLibrary.simpleMessage("خروج"),
        "passwordExitBody":
            MessageLookupByLibrary.simpleMessage("سيتم حذف المعلومات المدخلة."),
        "passwordExitTitle": MessageLookupByLibrary.simpleMessage(
            "الخروج من إعداد كلمة المرور؟"),
        "passwordFirst":
            MessageLookupByLibrary.simpleMessage("الرقم السري الأول"),
        "passwordFirstDescription": MessageLookupByLibrary.simpleMessage(
            "للمعاملات الحضورية في الصراف الآلي وأجهزة نقاط البيع."),
        "passwordForgot":
            MessageLookupByLibrary.simpleMessage("نسيت كلمة المرور"),
        "passwordHide":
            MessageLookupByLibrary.simpleMessage("إخفاء كلمة المرور"),
        "passwordInstructionPrompt": MessageLookupByLibrary.simpleMessage(
            "بعد مشاهدة الفيديو التعليمي تبدأ خطوات التحقق من الهوية."),
        "passwordLengthRule":
            MessageLookupByLibrary.simpleMessage("استخدم من ٤ إلى ٦ أرقام"),
        "passwordMismatch":
            MessageLookupByLibrary.simpleMessage("كلمتا المرور غير متطابقتين."),
        "passwordMockKyc": MessageLookupByLibrary.simpleMessage(
            "التسجيل والتحقق تجريبيان؛ لن يُسجّل أي فيديو لك."),
        "passwordMockReceipt": MessageLookupByLibrary.simpleMessage(
            "نتيجة تجريبية: لم تُعيّن كلمة مرور مصرفية ولم تُرسل رسالة."),
        "passwordNewConfirmationHint":
            MessageLookupByLibrary.simpleMessage("تأكيد كلمة المرور الجديدة"),
        "passwordNewHint":
            MessageLookupByLibrary.simpleMessage("كلمة المرور الجديدة"),
        "passwordOperation":
            MessageLookupByLibrary.simpleMessage("نوع العملية"),
        "passwordOperationHint":
            MessageLookupByLibrary.simpleMessage("حدد نوع العملية"),
        "passwordPatternRule": MessageLookupByLibrary.simpleMessage(
            "تجنب الأرقام المتتابعة أو المكررة"),
        "passwordPause":
            MessageLookupByLibrary.simpleMessage("إيقاف الفيديو مؤقتاً"),
        "passwordPendingBody": MessageLookupByLibrary.simpleMessage(
            "• بعد التحقق وتأكيد الهوية تصلك رسالة بمعلومات كلمة المرور.\n• خلال مدة صلاحية التحقق يمكن استخدام الخدمات الأخرى دون دفع رسوم التحقق مجدداً."),
        "passwordPendingTitle":
            MessageLookupByLibrary.simpleMessage("لديك طلب تحقق قيد المعالجة"),
        "passwordPlay": MessageLookupByLibrary.simpleMessage("تشغيل الفيديو"),
        "passwordPrompt": MessageLookupByLibrary.simpleMessage(
            "أدخل كلمة المرور الثانية المطلوبة."),
        "passwordRecordAgain":
            MessageLookupByLibrary.simpleMessage("إعادة التسجيل"),
        "passwordRecordingPrompt":
            MessageLookupByLibrary.simpleMessage("أكد الفيديو ثم أرسل طلبك."),
        "passwordSecond":
            MessageLookupByLibrary.simpleMessage("كلمة المرور الثانية"),
        "passwordSecondDescription": MessageLookupByLibrary.simpleMessage(
            "للمعاملات عبر الإنترنت دون ١٠٠ ألف تومان."),
        "passwordSeek": MessageLookupByLibrary.simpleMessage("موضع التشغيل"),
        "passwordSelectionPrompt": MessageLookupByLibrary.simpleMessage(
            "اختر البطاقة ونوع كلمة المرور"),
        "passwordSerialError": MessageLookupByLibrary.simpleMessage(
            "أدخل أرقاماً وحرفاً لاتينياً واحداً فقط."),
        "passwordSerialHelper": MessageLookupByLibrary.simpleMessage(
            "يتضمن أرقاماً وحرفاً لاتينياً واحداً"),
        "passwordSerialHint": MessageLookupByLibrary.simpleMessage(
            "الرقم التسلسلي للهوية | رمز تتبع الإيصال"),
        "passwordSerialPrompt": MessageLookupByLibrary.simpleMessage(
            "أدخل الرقم التسلسلي خلف بطاقة الهوية أو رمز تتبع إيصالها."),
        "passwordSetSecond":
            MessageLookupByLibrary.simpleMessage("تعيين كلمة المرور الثانية"),
        "passwordShow":
            MessageLookupByLibrary.simpleMessage("إظهار كلمة المرور"),
        "passwordStartKyc":
            MessageLookupByLibrary.simpleMessage("بدء التحقق من الهوية"),
        "passwordStatusRegisteredTitle":
            MessageLookupByLibrary.simpleMessage("تم تسجيل طلبك بنجاح."),
        "passwordStay": MessageLookupByLibrary.simpleMessage("متابعة الإعداد"),
        "passwordSubmit":
            MessageLookupByLibrary.simpleMessage("إرسال وتسجيل الطلب"),
        "passwordSubmittedBody": MessageLookupByLibrary.simpleMessage(
            "بعد التحقق وتأكيد الهوية تصلك رسالة ببيانات الدخول إلى البنك عبر الهاتف، ويمكنك تسجيل الدخول باستخدامها."),
        "passwordSubmittedTitle":
            MessageLookupByLibrary.simpleMessage("تم إرسال طلبك"),
        "passwordTitle":
            MessageLookupByLibrary.simpleMessage("خدمات كلمة المرور"),
        "passwordTracking": MessageLookupByLibrary.simpleMessage("رمز التتبع"),
        "passwordType": MessageLookupByLibrary.simpleMessage("نوع كلمة المرور"),
        "passwordTypeHint":
            MessageLookupByLibrary.simpleMessage("اختر نوع كلمة المرور"),
        "passwordUnderstood": MessageLookupByLibrary.simpleMessage("فهمت"),
        "passwordUnsupported": MessageLookupByLibrary.simpleMessage(
            "هذه العملية غير متاحة للبطاقة المحددة."),
        "passwordValueHint":
            MessageLookupByLibrary.simpleMessage("كلمة المرور"),
        "passwordVideoUnavailable":
            MessageLookupByLibrary.simpleMessage("الفيديو غير متاح"),
        "phoneOwnershipNotice": MessageLookupByLibrary.simpleMessage(
            "يجب أن يتطابق الرقم مع الرقم الوطني لصاحب الحساب"),
        "profileAddAddress":
            MessageLookupByLibrary.simpleMessage("إضافة عنوان جديد"),
        "profileAddJobInformation":
            MessageLookupByLibrary.simpleMessage("إضافة مهنة جديدة"),
        "profileAddressType":
            MessageLookupByLibrary.simpleMessage("نوع العنوان"),
        "profileAddressesEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد عناوين"),
        "profileChangePhone":
            MessageLookupByLibrary.simpleMessage("تغيير رقم الهاتف المحمول"),
        "profileCurrentPhone":
            MessageLookupByLibrary.simpleMessage("الرقم الحالي"),
        "profileDeleteAddress":
            MessageLookupByLibrary.simpleMessage("حذف العنوان"),
        "profileDeleteJobInformation":
            MessageLookupByLibrary.simpleMessage("حذف المهنة"),
        "profileDeleteJobInformationPrompt": m13,
        "profileDescription": MessageLookupByLibrary.simpleMessage("الوصف"),
        "profileDescriptionRequired":
            MessageLookupByLibrary.simpleMessage("أدخل وصف المهنة"),
        "profileDesigner": MessageLookupByLibrary.simpleMessage("مصمم"),
        "profileEditAddress":
            MessageLookupByLibrary.simpleMessage("تعديل العنوان"),
        "profileEditJobInformation":
            MessageLookupByLibrary.simpleMessage("تعديل المهنة"),
        "profileHome": MessageLookupByLibrary.simpleMessage("المنزل"),
        "profileHomemaker": MessageLookupByLibrary.simpleMessage("ربة منزل"),
        "profileJobInformation": MessageLookupByLibrary.simpleMessage("المهنة"),
        "profileJobInformationConflict": m14,
        "profileJobInformationDescription":
            MessageLookupByLibrary.simpleMessage("وصف المهنة"),
        "profileJobInformationDescriptionHint":
            MessageLookupByLibrary.simpleMessage("أدخل وصف مهنتك"),
        "profileJobInformationEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد مهن مسجلة"),
        "profileJobInformationHint":
            MessageLookupByLibrary.simpleMessage("اختر مهنتك"),
        "profileJobInformationNotice": MessageLookupByLibrary.simpleMessage(
            "ستظهر المهنة الجديدة خلال ٣ ساعات من تسجيل الطلب."),
        "profileJobInformationQueued": MessageLookupByLibrary.simpleMessage(
            "تم تسجيل طلب المهنة وسيظهر بعد المراجعة."),
        "profileJobInformationReview": m15,
        "profileLabel": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
        "profileMinimumAddress": MessageLookupByLibrary.simpleMessage(
            "يجب وجود عنوان منزل واحد على الأقل. سجّل عنوان منزل آخر قبل تغيير هذا العنوان إلى عنوان عمل أو حذفه."),
        "profileMinimumJobInformation": MessageLookupByLibrary.simpleMessage(
            "يجب وجود مهنة مسجلة واحدة على الأقل. يمكنك تعديل هذه المهنة بدلاً من حذفها."),
        "profileMissingResidence":
            MessageLookupByLibrary.simpleMessage("غير مسجل في سجل الإقامة"),
        "profileNewPhone": MessageLookupByLibrary.simpleMessage("الرقم الجديد"),
        "profileNewPhoneHint":
            MessageLookupByLibrary.simpleMessage("أدخل رقم الهاتف الجديد"),
        "profileOperationError":
            MessageLookupByLibrary.simpleMessage("تعذرت العملية؛ حاول مجدداً"),
        "profileOtpExpired": MessageLookupByLibrary.simpleMessage(
            "انتهت صلاحية الرمز؛ اطلب رمزاً آخر"),
        "profileOtpHint": MessageLookupByLibrary.simpleMessage("أدخل الرمز"),
        "profileOtpInvalid":
            MessageLookupByLibrary.simpleMessage("الرمز غير صحيح"),
        "profilePhoneNotice": MessageLookupByLibrary.simpleMessage(
            "يجب أن يتطابق الرقم مع الهوية الوطنية لصاحب الحساب"),
        "profilePhoneSubmitted": MessageLookupByLibrary.simpleMessage(
            "تم تسجيل طلب تغيير رقم الهاتف"),
        "profilePostalAddress":
            MessageLookupByLibrary.simpleMessage("الرمز البريدي:"),
        "profileProfessor": MessageLookupByLibrary.simpleMessage("أستاذ"),
        "profileQuerying":
            MessageLookupByLibrary.simpleMessage("جارٍ الاستعلام..."),
        "profileRequestOtp":
            MessageLookupByLibrary.simpleMessage("طلب رمز مؤقت"),
        "profileResidenceNotice": MessageLookupByLibrary.simpleMessage(
            "لطلب خدمات مثل دفتر الشيكات أو الحساب الجاري، يجب تسجيل عنوان السكن في"),
        "profileResidenceRegistered": MessageLookupByLibrary.simpleMessage("."),
        "profileResidenceRegistry":
            MessageLookupByLibrary.simpleMessage(" نظام الإقامة والعقارات"),
        "profileResidenceStatus":
            MessageLookupByLibrary.simpleMessage("حالة سجل الإقامة والعقارات"),
        "profileReview": MessageLookupByLibrary.simpleMessage("تحقق"),
        "profileReviewError":
            MessageLookupByLibrary.simpleMessage("تعذر الاستعلام؛ حاول مجدداً"),
        "profileSecondPassword":
            MessageLookupByLibrary.simpleMessage("كلمة المرور الثانية"),
        "profileShahkarFee":
            MessageLookupByLibrary.simpleMessage("رسوم استعلام شاهكار"),
        "profileSubmit": MessageLookupByLibrary.simpleMessage("تسجيل الطلب"),
        "profileTeacher": MessageLookupByLibrary.simpleMessage("مدرس"),
        "profileTelephone": MessageLookupByLibrary.simpleMessage("رقم الهاتف:"),
        "profileTitle": MessageLookupByLibrary.simpleMessage("العنوان"),
        "profileValid": MessageLookupByLibrary.simpleMessage("صالح"),
        "profileWork": MessageLookupByLibrary.simpleMessage("العمل"),
        "refreshCaptcha":
            MessageLookupByLibrary.simpleMessage("تحديث رمز الأمان"),
        "relatedLinks": MessageLookupByLibrary.simpleMessage("روابط ذات صلة"),
        "reportApplyFilter":
            MessageLookupByLibrary.simpleMessage("تطبيق التصفية"),
        "reportCancelError": MessageLookupByLibrary.simpleMessage(
            "تعذر إلغاء الطلب. أعد المحاولة أو حدّث التقارير."),
        "reportCancelPrompt": MessageLookupByLibrary.simpleMessage(
            "هل أنت متأكد من إلغاء هذا الطلب؟"),
        "reportCancelRequest":
            MessageLookupByLibrary.simpleMessage("إلغاء الطلب"),
        "reportConfirmCancel":
            MessageLookupByLibrary.simpleMessage("نعم، إلغاء"),
        "reportDate": MessageLookupByLibrary.simpleMessage("التاريخ"),
        "reportDateLastMonth":
            MessageLookupByLibrary.simpleMessage("الشهر الماضي"),
        "reportDateLastThreeMonths":
            MessageLookupByLibrary.simpleMessage("آخر ٣ أشهر"),
        "reportDateLastWeek":
            MessageLookupByLibrary.simpleMessage("الأسبوع الماضي"),
        "reportDateToday": MessageLookupByLibrary.simpleMessage("اليوم"),
        "reportDetails": MessageLookupByLibrary.simpleMessage("التفاصيل"),
        "reportDetailsTitle":
            MessageLookupByLibrary.simpleMessage("تفاصيل الطلب"),
        "reportIdentifier": MessageLookupByLibrary.simpleMessage("المعرّف"),
        "reportLoadError":
            MessageLookupByLibrary.simpleMessage("تعذر تحميل تقارير الطلبات."),
        "reportNoResults": MessageLookupByLibrary.simpleMessage(
            "لم يتم العثور على طلبات مطابقة."),
        "reportNoTypes": MessageLookupByLibrary.simpleMessage(
            "لم يتم العثور على أنواع طلبات."),
        "reportRequestDate":
            MessageLookupByLibrary.simpleMessage("تاريخ الطلب"),
        "reportRequestStatus":
            MessageLookupByLibrary.simpleMessage("حالة الطلب"),
        "reportRequestType": MessageLookupByLibrary.simpleMessage("نوع الطلب"),
        "reportSearchIdentifier":
            MessageLookupByLibrary.simpleMessage("معرّف الدفع"),
        "reportSearchTypes":
            MessageLookupByLibrary.simpleMessage("البحث عن نوع الطلب"),
        "reportSelectAll": MessageLookupByLibrary.simpleMessage("(تحديد الكل)"),
        "reportStatus": MessageLookupByLibrary.simpleMessage("الحالة"),
        "reportStatusAwaitingApproval":
            MessageLookupByLibrary.simpleMessage("بانتظار الموافقة"),
        "reportStatusAwaitingReview":
            MessageLookupByLibrary.simpleMessage("بانتظار المراجعة"),
        "reportStatusCancelled": MessageLookupByLibrary.simpleMessage("ملغى"),
        "reportStatusCompleted":
            MessageLookupByLibrary.simpleMessage("تم التنفيذ تلقائيًا"),
        "reportStatusProcessingError":
            MessageLookupByLibrary.simpleMessage("خطأ في المعالجة"),
        "reportStatusRejected": MessageLookupByLibrary.simpleMessage("مرفوض"),
        "reportStatusSystemError":
            MessageLookupByLibrary.simpleMessage("خطأ في النظام"),
        "reportTitle": MessageLookupByLibrary.simpleMessage("تقارير الطلبات"),
        "reportTypeBlockDeposit":
            MessageLookupByLibrary.simpleMessage("حظر الوديعة"),
        "reportTypeChequeBook":
            MessageLookupByLibrary.simpleMessage("إصدار دفتر شيكات"),
        "reportTypeChequeClearance":
            MessageLookupByLibrary.simpleMessage("إزالة أثر الشيك"),
        "reportTypeCurrentDeposit":
            MessageLookupByLibrary.simpleMessage("فتح حساب جاري"),
        "reportTypeInstallmentDeposit":
            MessageLookupByLibrary.simpleMessage("تغيير وديعة سداد الأقساط"),
        "reportTypeInternetPassword": MessageLookupByLibrary.simpleMessage(
            "تغيير كلمة مرور الخدمات المصرفية عبر الإنترنت"),
        "reportTypeMobilePassword": MessageLookupByLibrary.simpleMessage(
            "تغيير كلمة مرور الهاتف المصرفي"),
        "reportTypeOnSiteTransfer":
            MessageLookupByLibrary.simpleMessage("تحويل الأموال في الموقع"),
        "reportTypeUnblockDeposit":
            MessageLookupByLibrary.simpleMessage("إلغاء حظر الوديعة"),
        "requestIdentifier": MessageLookupByLibrary.simpleMessage("معرف الطلب"),
        "requestOtp": MessageLookupByLibrary.simpleMessage("طلب رمز التحقق"),
        "requestStatus": MessageLookupByLibrary.simpleMessage("حالة الطلب"),
        "requestTwoFactorCode":
            MessageLookupByLibrary.simpleMessage("طلب رمز المصادقة الثنائية"),
        "resalatApp": MessageLookupByLibrary.simpleMessage("تطبيق رسالت"),
        "resendOtp": MessageLookupByLibrary.simpleMessage("إعادة الإرسال"),
        "rialCurrency": MessageLookupByLibrary.simpleMessage("ريال"),
        "securityTips": MessageLookupByLibrary.simpleMessage("نصائح أمنية"),
        "selectedServices":
            MessageLookupByLibrary.simpleMessage("الخدمات المختارة"),
        "servicesList": MessageLookupByLibrary.simpleMessage("قائمة الخدمات"),
        "servicesMenuLabel":
            MessageLookupByLibrary.simpleMessage("قائمة الخدمات"),
        "smsSettings":
            MessageLookupByLibrary.simpleMessage("إعدادات الرسائل النصية"),
        "submitRequest": MessageLookupByLibrary.simpleMessage("إرسال الطلب"),
        "surplusDepositsDescription": MessageLookupByLibrary.simpleMessage(
            "اختر الوديعة التي تريد الاحتفاظ بها كوديعتك الرئيسية. سيتم إغلاق ودائعك الفائضة وتحويل أرصدتها والعناصر المرتبطة بها إلى الوديعة المختارة."),
        "surplusDepositsEmptyBody": MessageLookupByLibrary.simpleMessage(
            "ليس لديك ودائع توفير قرض حسن فردية فائضة."),
        "surplusDepositsEmptyTitle":
            MessageLookupByLibrary.simpleMessage("لم يتم العثور على نتائج"),
        "surplusDepositsMockComplete": MessageLookupByLibrary.simpleMessage(
            "تمت محاكاة طلب إغلاق الودائع. لم تتغير أي وديعة أو رصيد حقيقي."),
        "surplusDepositsReviewTitle":
            MessageLookupByLibrary.simpleMessage("ودائعك الفائضة"),
        "surplusDepositsSubmit":
            MessageLookupByLibrary.simpleMessage("تأكيد وتقديم الطلب"),
        "surplusDepositsTitle":
            MessageLookupByLibrary.simpleMessage("إغلاق الودائع الفائضة"),
        "surplusPrimaryDeposit":
            MessageLookupByLibrary.simpleMessage("الوديعة الرئيسية"),
        "surplusPrimaryDepositHint":
            MessageLookupByLibrary.simpleMessage("اختر وديعتك الرئيسية"),
        "transferAddDestination":
            MessageLookupByLibrary.simpleMessage("إضافة وجهة"),
        "transferAddManual":
            MessageLookupByLibrary.simpleMessage("إضافة وجهة يدوياً"),
        "transferAddNext":
            MessageLookupByLibrary.simpleMessage("إضافة وجهة أخرى"),
        "transferAddressHint":
            MessageLookupByLibrary.simpleMessage("اختر عنوان زيارة المختص"),
        "transferAmount": MessageLookupByLibrary.simpleMessage("المبلغ"),
        "transferAmountError": MessageLookupByLibrary.simpleMessage(
            "أدخل مبلغاً صالحاً أكبر من الصفر."),
        "transferAmountHint":
            MessageLookupByLibrary.simpleMessage("أدخل المبلغ"),
        "transferAmountRial":
            MessageLookupByLibrary.simpleMessage("المبلغ (ريال)"),
        "transferConfirmNext":
            MessageLookupByLibrary.simpleMessage("تأكيد ومتابعة"),
        "transferConfirmationStep": MessageLookupByLibrary.simpleMessage(
            "التأكيد النهائي ورسوم الخدمة"),
        "transferCutoffNotice": MessageLookupByLibrary.simpleMessage(
            "يمكن اختيار اليوم الحالي قبل الساعة ١٠ صباحاً فقط."),
        "transferDate": MessageLookupByLibrary.simpleMessage("تاريخ التحويل"),
        "transferDateError": MessageLookupByLibrary.simpleMessage(
            "أدخل تاريخاً صالحاً؛ اليوم متاح قبل الساعة ١٠ صباحاً."),
        "transferDateHint": MessageLookupByLibrary.simpleMessage(
            "أدخل التاريخ الشمسي: YYYY/MM/DD"),
        "transferDeleteDestination":
            MessageLookupByLibrary.simpleMessage("حذف الوجهة"),
        "transferDeleteFile": MessageLookupByLibrary.simpleMessage("حذف الملف"),
        "transferDescription":
            MessageLookupByLibrary.simpleMessage("مرجع الإيداع / الوصف"),
        "transferDescriptionHint":
            MessageLookupByLibrary.simpleMessage("أدخل المرجع أو الوصف"),
        "transferDestinationPrompt":
            MessageLookupByLibrary.simpleMessage("أدخل معلومات الوجهة."),
        "transferDestinationsStep":
            MessageLookupByLibrary.simpleMessage("إدخال الوجهات"),
        "transferFileAccepted": MessageLookupByLibrary.simpleMessage(
            "تم قبول ملف الوجهات؛ مراجعة المحتوى مؤجلة."),
        "transferFileInvalid": MessageLookupByLibrary.simpleMessage(
            "اختر ملف XLS غير فارغ بحجم أقصى ١٠٠ كيلوبايت."),
        "transferFileRequirements": MessageLookupByLibrary.simpleMessage(
            "الصيغة: XLS  |  الحجم الأقصى: ١٠٠ كيلوبايت"),
        "transferHolidayNotice": MessageLookupByLibrary.simpleMessage(
            "يجب ألا يكون التاريخ المحدد عطلة رسمية."),
        "transferIbanError":
            MessageLookupByLibrary.simpleMessage("أدخل رقم آيبان إيراني صالح."),
        "transferIbanHint":
            MessageLookupByLibrary.simpleMessage("أدخل أرقام الآيبان"),
        "transferIdentifier":
            MessageLookupByLibrary.simpleMessage("مرجع الإيداع"),
        "transferInternal": MessageLookupByLibrary.simpleMessage("داخلي"),
        "transferMethod": MessageLookupByLibrary.simpleMessage("نوع التحويل"),
        "transferMethodHint":
            MessageLookupByLibrary.simpleMessage("اختر نوع التحويل"),
        "transferMethodRow":
            MessageLookupByLibrary.simpleMessage("طريقة التحويل"),
        "transferMockComplete": MessageLookupByLibrary.simpleMessage(
            "تم تسجيل طلب تجريبي. لم يُحوّل أي مبلغ أو رسوم في البنك."),
        "transferPaya": MessageLookupByLibrary.simpleMessage("بايا"),
        "transferPurpose": MessageLookupByLibrary.simpleMessage("الغرض"),
        "transferPurposeHint":
            MessageLookupByLibrary.simpleMessage("اختر سبب التحويل"),
        "transferReview": MessageLookupByLibrary.simpleMessage("مراجعة"),
        "transferSalary": MessageLookupByLibrary.simpleMessage("دفع الراتب"),
        "transferSampleLink": MessageLookupByLibrary.simpleMessage("النموذج"),
        "transferSamplePrefix":
            MessageLookupByLibrary.simpleMessage("يجب أن يطابق ملف إكسل "),
        "transferSampleSuffix": MessageLookupByLibrary.simpleMessage("."),
        "transferSatna": MessageLookupByLibrary.simpleMessage("ساتنا"),
        "transferSave": MessageLookupByLibrary.simpleMessage("حفظ"),
        "transferServiceFee":
            MessageLookupByLibrary.simpleMessage("رسوم الخدمة في الموقع"),
        "transferSourcePrompt":
            MessageLookupByLibrary.simpleMessage("اختر الحساب وتاريخ التحويل"),
        "transferSourceStep":
            MessageLookupByLibrary.simpleMessage("الحساب وشروط الطلب"),
        "transferUploadAction":
            MessageLookupByLibrary.simpleMessage("رفع ملف، انقر هنا"),
        "transferUploadAfter": MessageLookupByLibrary.simpleMessage(""),
        "transferUploadBefore": MessageLookupByLibrary.simpleMessage("من أجل"),
        "transferUploadExcel":
            MessageLookupByLibrary.simpleMessage("رفع ملف إكسل"),
        "transferVisitDate":
            MessageLookupByLibrary.simpleMessage("تاريخ الزيارة"),
        "transferVisitDateError": MessageLookupByLibrary.simpleMessage(
            "يجب أن تكون الزيارة في يوم عمل بين اليوم وتاريخ التحويل."),
        "transferVisitDateHint": MessageLookupByLibrary.simpleMessage(
            "أدخل تاريخ الزيارة: YYYY/MM/DD"),
        "transferVisitPrompt": MessageLookupByLibrary.simpleMessage(
            "اختر عنوان وتاريخ زيارة المختص."),
        "transferVisitStep":
            MessageLookupByLibrary.simpleMessage("عنوان وتاريخ زيارة المختص"),
        "updateGuide": MessageLookupByLibrary.simpleMessage("دليل التحديث"),
        "virtualRequestCount":
            MessageLookupByLibrary.simpleMessage("عدد البطاقات الافتراضية"),
        "virtualRequestCountError": m16,
        "virtualRequestCountHint": MessageLookupByLibrary.simpleMessage(
            "أدخل عدد البطاقات الافتراضية المطلوبة"),
        "virtualRequestDepositHint":
            MessageLookupByLibrary.simpleMessage("اختر الوديعة"),
        "virtualRequestDepositLabel":
            MessageLookupByLibrary.simpleMessage("الوديعة"),
        "virtualRequestEmpty": MessageLookupByLibrary.simpleMessage(
            "لا توجد ودائع متاحة لإصدار بطاقة افتراضية."),
        "virtualRequestFeeNotice": m17,
        "virtualRequestMockReceipt": MessageLookupByLibrary.simpleMessage(
            "تم تسجيل طلب تجريبي. لم تُنشأ بطاقات افتراضية ولم تُدفع أي مبالغ."),
        "virtualRequestNotice": MessageLookupByLibrary.simpleMessage(
            "البطاقة الافتراضية ليس لها شكل مادي. هي مجرد رقم يستقبل تحويلات الأموال؛ ولا يمكن السحب أو الشراء باستخدامها."),
        "virtualRequestPrompt": MessageLookupByLibrary.simpleMessage(
            "اختر الوديعة وعدد البطاقات الافتراضية، ثم تابع."),
        "virtualRequestQuoting": MessageLookupByLibrary.simpleMessage(
            "جارٍ الحصول على تكلفة الطلب…"),
        "virtualRequestReceipt":
            MessageLookupByLibrary.simpleMessage("مرجع الطلب:"),
        "virtualRequestSubmit":
            MessageLookupByLibrary.simpleMessage("تأكيد وتسجيل الطلب"),
        "virtualRequestSubmitted":
            MessageLookupByLibrary.simpleMessage("تم تسجيل الطلب"),
        "virtualRequestTitle":
            MessageLookupByLibrary.simpleMessage("طلب بطاقة افتراضية"),
        "virtualRequestUnitFee":
            MessageLookupByLibrary.simpleMessage("رسوم إصدار كل بطاقة"),
        "walletAmount": MessageLookupByLibrary.simpleMessage("المبلغ"),
        "walletAmountFilter": MessageLookupByLibrary.simpleMessage("المبلغ"),
        "walletAmountHint": MessageLookupByLibrary.simpleMessage("أدخل المبلغ"),
        "walletAmountInvalid": MessageLookupByLibrary.simpleMessage(
            "أدخل مبلغاً صالحاً ضمن الرصيد المتاح."),
        "walletApplyFilter":
            MessageLookupByLibrary.simpleMessage("تطبيق التصفية"),
        "walletBalanceAfter":
            MessageLookupByLibrary.simpleMessage("الرصيد بعد العملية"),
        "walletBalanceTitle":
            MessageLookupByLibrary.simpleMessage("رصيد المحفظة"),
        "walletCancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "walletCharge": MessageLookupByLibrary.simpleMessage("شحن"),
        "walletChargeAmount":
            MessageLookupByLibrary.simpleMessage("مبلغ الشحن"),
        "walletChargeComplete":
            MessageLookupByLibrary.simpleMessage("تم شحن المحفظة بنجاح."),
        "walletChargeSuccess": MessageLookupByLibrary.simpleMessage("تم الشحن"),
        "walletChargeTitle":
            MessageLookupByLibrary.simpleMessage("شحن المحفظة"),
        "walletConfirmPayment":
            MessageLookupByLibrary.simpleMessage("تأكيد ودفع"),
        "walletConfirmTransfer":
            MessageLookupByLibrary.simpleMessage("تأكيد التحويل"),
        "walletCopied":
            MessageLookupByLibrary.simpleMessage("تم نسخ رقم التتبع."),
        "walletCurrentBalance":
            MessageLookupByLibrary.simpleMessage("رصيد المحفظة الحالي"),
        "walletCustomDate": MessageLookupByLibrary.simpleMessage("تاريخ مخصص"),
        "walletDateFilter": MessageLookupByLibrary.simpleMessage("التاريخ"),
        "walletDateInvalid": MessageLookupByLibrary.simpleMessage(
            "أدخل تاريخاً شمسياً صالحاً بصيغة YYYY/MM/DD."),
        "walletDateSelection":
            MessageLookupByLibrary.simpleMessage("اختيار التاريخ"),
        "walletDepositChanged":
            MessageLookupByLibrary.simpleMessage("تم تغيير الحساب المرتبط."),
        "walletDepositHint":
            MessageLookupByLibrary.simpleMessage("اختر الحساب"),
        "walletDestination":
            MessageLookupByLibrary.simpleMessage("المحفظة المستلمة"),
        "walletDestinationHint":
            MessageLookupByLibrary.simpleMessage("رقم المحفظة أو هاتف صاحبها"),
        "walletEmptyTransactions":
            MessageLookupByLibrary.simpleMessage("لا توجد عمليات مطابقة."),
        "walletEndDate": MessageLookupByLibrary.simpleMessage("تاريخ النهاية"),
        "walletFromDate": MessageLookupByLibrary.simpleMessage("من تاريخ"),
        "walletFromDeposit": MessageLookupByLibrary.simpleMessage("من الحساب"),
        "walletInquiryRetry":
            MessageLookupByLibrary.simpleMessage("إعادة الاستعلام"),
        "walletLastMonth": MessageLookupByLibrary.simpleMessage("الشهر الماضي"),
        "walletLastThreeMonths":
            MessageLookupByLibrary.simpleMessage("آخر ثلاثة أشهر"),
        "walletLastWeek":
            MessageLookupByLibrary.simpleMessage("الأسبوع الماضي"),
        "walletLinkedDepositIntro":
            MessageLookupByLibrary.simpleMessage("اختر الحساب لربطه بالمحفظة."),
        "walletLinkedDepositShort":
            MessageLookupByLibrary.simpleMessage("تغيير الحساب المرتبط"),
        "walletLinkedDepositTitle":
            MessageLookupByLibrary.simpleMessage("تغيير الحساب المرتبط"),
        "walletMaxAmount":
            MessageLookupByLibrary.simpleMessage("الحد الأقصى للمبلغ"),
        "walletMinAmount":
            MessageLookupByLibrary.simpleMessage("الحد الأدنى للمبلغ"),
        "walletOperations":
            MessageLookupByLibrary.simpleMessage("عمليات المحفظة"),
        "walletOtpHint": MessageLookupByLibrary.simpleMessage("أدخل الرمز"),
        "walletRangeInvalid": MessageLookupByLibrary.simpleMessage(
            "يجب ألا تتجاوز البداية نهاية النطاق."),
        "walletReceiptDestination": MessageLookupByLibrary.simpleMessage("إلى"),
        "walletReceiptSource": MessageLookupByLibrary.simpleMessage("من"),
        "walletReceiptTitle":
            MessageLookupByLibrary.simpleMessage("إيصال العملية"),
        "walletRecipientInvalid": MessageLookupByLibrary.simpleMessage(
            "أدخل رقم محفظة أو هاتف صالحاً."),
        "walletRecipientName":
            MessageLookupByLibrary.simpleMessage("اسم صاحب المحفظة"),
        "walletRequestOtp":
            MessageLookupByLibrary.simpleMessage("طلب رمز التحقق"),
        "walletResendOtp":
            MessageLookupByLibrary.simpleMessage("إعادة إرسال الرمز"),
        "walletRetry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
        "walletSecondPassword":
            MessageLookupByLibrary.simpleMessage("رمز التحقق"),
        "walletSelectAll": MessageLookupByLibrary.simpleMessage("اختيار الكل"),
        "walletShareReceipt":
            MessageLookupByLibrary.simpleMessage("مشاركة الإيصال"),
        "walletShopping": MessageLookupByLibrary.simpleMessage("شراء"),
        "walletStartDate":
            MessageLookupByLibrary.simpleMessage("تاريخ البداية"),
        "walletTerms": MessageLookupByLibrary.simpleMessage("الشروط والأحكام"),
        "walletTermsAcceptance":
            MessageLookupByLibrary.simpleMessage("قرأت الطلب وأوافق عليه."),
        "walletTitle": MessageLookupByLibrary.simpleMessage("المحفظة"),
        "walletToDate": MessageLookupByLibrary.simpleMessage("إلى تاريخ"),
        "walletToDeposit": MessageLookupByLibrary.simpleMessage("إلى الحساب"),
        "walletToday": MessageLookupByLibrary.simpleMessage("اليوم"),
        "walletTomanAmount": m18,
        "walletTrackingId": MessageLookupByLibrary.simpleMessage("رقم التتبع"),
        "walletTransactionDate":
            MessageLookupByLibrary.simpleMessage("تاريخ العملية"),
        "walletTransactionType":
            MessageLookupByLibrary.simpleMessage("نوع العملية"),
        "walletTransactionsTitle":
            MessageLookupByLibrary.simpleMessage("حركات المحفظة"),
        "walletTransfer":
            MessageLookupByLibrary.simpleMessage("تحويل بين المحافظ"),
        "walletTransferAmount":
            MessageLookupByLibrary.simpleMessage("مبلغ التحويل"),
        "walletTransferComplete": MessageLookupByLibrary.simpleMessage(
            "تم التحويل إلى المحفظة المستلمة بنجاح."),
        "walletTransferSuccess":
            MessageLookupByLibrary.simpleMessage("تم التحويل"),
        "walletTransferTitle":
            MessageLookupByLibrary.simpleMessage("تحويل بين المحافظ"),
        "walletViewTransactions":
            MessageLookupByLibrary.simpleMessage("عرض حركات المحفظة"),
        "walletWithdraw": MessageLookupByLibrary.simpleMessage("سحب"),
        "walletWithdrawAmount":
            MessageLookupByLibrary.simpleMessage("مبلغ السحب"),
        "walletWithdrawComplete":
            MessageLookupByLibrary.simpleMessage("تم السحب من المحفظة بنجاح."),
        "walletWithdrawSuccess":
            MessageLookupByLibrary.simpleMessage("تم السحب"),
        "walletWithdrawTitle":
            MessageLookupByLibrary.simpleMessage("السحب من المحفظة")
      };
}
