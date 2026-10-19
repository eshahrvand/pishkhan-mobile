// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fa locale. All the
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
  String get localeName => 'fa';

  static String m0(percentage) => "${percentage}٪";

  static String m1(number) => "حذف کارت ${number}";

  static String m2(count) => "لیست کارت‌های انتخاب شده (${count})";

  static String m3(current, total, title) =>
      "مرحله ${current} از ${total}، ${title}";

  static String m4(phone) =>
      "رمز پویای ارسال شده به شماره ${phone} را وارد کنید.";

  static String m5(amount) => "${amount} تومان";

  static String m6(max) => "تعداد کارت باید بین ۱ و ${max} باشد.";

  static String m7(amount) => "کارمزد صدور هر کارت ${amount} است";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "agentAddNext": MessageLookupByLibrary.simpleMessage("افزودن نماینده بعدی"),
    "agentCancel": MessageLookupByLibrary.simpleMessage("انصراف"),
    "agentChequeBook": MessageLookupByLibrary.simpleMessage("صدور دسته چک"),
    "agentDeposit": MessageLookupByLibrary.simpleMessage("انتخاب سپرده"),
    "agentDepositHint": MessageLookupByLibrary.simpleMessage(
      "سپرده مورد نظر خود را انتخاب کنید",
    ),
    "agentDepositShort": MessageLookupByLibrary.simpleMessage("سپرده"),
    "agentKind": MessageLookupByLibrary.simpleMessage("نوع نمایندگی"),
    "agentMockComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست آزمایشی ثبت شد؛ هیچ نمایندگی بانکی ایجاد نشده است.",
    ),
    "agentNationalId": MessageLookupByLibrary.simpleMessage("کد ملی نماینده"),
    "agentNationalIdHint": MessageLookupByLibrary.simpleMessage(
      "کد ملی نماینده را وارد کنید",
    ),
    "agentNewPerson": MessageLookupByLibrary.simpleMessage("نماینده جدید"),
    "agentOperation": MessageLookupByLibrary.simpleMessage("نوع عملیات"),
    "agentOperationHint": MessageLookupByLibrary.simpleMessage(
      "عملیات مجاز نماینده را انتخاب کنید",
    ),
    "agentPreliminarySave": MessageLookupByLibrary.simpleMessage("ثبت اولیه"),
    "agentRemove": MessageLookupByLibrary.simpleMessage("حذف نماینده"),
    "agentSave": MessageLookupByLibrary.simpleMessage("ثبت"),
    "agentSettingsActive": MessageLookupByLibrary.simpleMessage("فعال"),
    "agentSettingsAdd": MessageLookupByLibrary.simpleMessage("افزودن نماینده"),
    "agentSettingsCancel": MessageLookupByLibrary.simpleMessage("لغو نمایندگی"),
    "agentSettingsClearChequeRecord": MessageLookupByLibrary.simpleMessage(
      "رفع سوء اثر چک",
    ),
    "agentSettingsConfirmers": MessageLookupByLibrary.simpleMessage(
      "مشخصات تایید کنندگان",
    ),
    "agentSettingsDelegated": MessageLookupByLibrary.simpleMessage(
      "من به عنوان نماینده",
    ),
    "agentSettingsDepositLabel": MessageLookupByLibrary.simpleMessage(
      "شماره سپرده:",
    ),
    "agentSettingsDepositRelation": MessageLookupByLibrary.simpleMessage(
      "صاحب سپرده و امضا",
    ),
    "agentSettingsDetails": MessageLookupByLibrary.simpleMessage(
      "جزئیات نمایندگی",
    ),
    "agentSettingsEmpty": MessageLookupByLibrary.simpleMessage(
      "نمایندگی با این مشخصات وجود ندارد.",
    ),
    "agentSettingsExpired": MessageLookupByLibrary.simpleMessage("منقضی شده"),
    "agentSettingsExpiryLabel": MessageLookupByLibrary.simpleMessage(
      "تاریخ انقضا:",
    ),
    "agentSettingsIntroducedLabel": MessageLookupByLibrary.simpleMessage(
      "تاریخ معرفی:",
    ),
    "agentSettingsIntroducer": MessageLookupByLibrary.simpleMessage("معرف"),
    "agentSettingsKindLabel": MessageLookupByLibrary.simpleMessage(
      "نوع نمایندگی:",
    ),
    "agentSettingsLoanReferral": MessageLookupByLibrary.simpleMessage(
      "معرفی وام",
    ),
    "agentSettingsMine": MessageLookupByLibrary.simpleMessage("نماینده‌های من"),
    "agentSettingsNameLabel": MessageLookupByLibrary.simpleMessage(
      "نام نماینده:",
    ),
    "agentSettingsNationalIdLabel": MessageLookupByLibrary.simpleMessage(
      "کد ملی:",
    ),
    "agentSettingsSelectAll": MessageLookupByLibrary.simpleMessage(
      "(انتخاب همه)",
    ),
    "agentSettingsShare": m0,
    "agentSettingsWaiting": MessageLookupByLibrary.simpleMessage(
      "در انتظار تایید",
    ),
    "agentTitle": MessageLookupByLibrary.simpleMessage("معرفی نماینده جدید"),
    "agentValidity": MessageLookupByLibrary.simpleMessage("تاریخ اعتبار"),
    "agentValidityError": MessageLookupByLibrary.simpleMessage(
      "تاریخ معتبر از امروز به بعد با قالب ۱۴۰۵/۰۶/۳۰ وارد کنید.",
    ),
    "agentValidityHint": MessageLookupByLibrary.simpleMessage(
      "تاریخ انقضا را تعیین کنید",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("پیشخوان مجازی رسالت"),
    "assetReport": MessageLookupByLibrary.simpleMessage("گزارش تمکن"),
    "authInvalidCaptcha": MessageLookupByLibrary.simpleMessage(
      "کد امنیتی ۶ رقمی را وارد کنید",
    ),
    "authInvalidNationalId": MessageLookupByLibrary.simpleMessage(
      "کد ملی ۱۰ رقمی را وارد کنید",
    ),
    "authInvalidPhone": MessageLookupByLibrary.simpleMessage(
      "شماره همراه ۱۱ رقمی با ۰۹ را وارد کنید",
    ),
    "automaticCompleted": MessageLookupByLibrary.simpleMessage(
      "انجام شده خودکار",
    ),
    "backLabel": MessageLookupByLibrary.simpleMessage("بازگشت"),
    "balanceAverageStatement": MessageLookupByLibrary.simpleMessage(
      "صورتحساب، معدل موجودی",
    ),
    "blockCard": MessageLookupByLibrary.simpleMessage("مسدودی کارت"),
    "captchaHint": MessageLookupByLibrary.simpleMessage(
      "کد روبرو را وارد کنید",
    ),
    "cardFeatureActive": MessageLookupByLibrary.simpleMessage("فعال"),
    "cardFeatureAll": MessageLookupByLibrary.simpleMessage("همه"),
    "cardFeatureApplyFilter": MessageLookupByLibrary.simpleMessage(
      "اعمال فیلتر",
    ),
    "cardFeatureBlocked": MessageLookupByLibrary.simpleMessage("مسدود"),
    "cardFeatureCardStatus": MessageLookupByLibrary.simpleMessage("وضعیت کارت"),
    "cardFeatureCoupon": MessageLookupByLibrary.simpleMessage("بن کارت"),
    "cardFeatureDeposit": MessageLookupByLibrary.simpleMessage("سپرده متصل"),
    "cardFeatureDepositType": MessageLookupByLibrary.simpleMessage("نوع سپرده"),
    "cardFeatureDetails": MessageLookupByLibrary.simpleMessage("جزئیات کارت"),
    "cardFeatureExpired": MessageLookupByLibrary.simpleMessage("منقضی"),
    "cardFeatureExpiry": MessageLookupByLibrary.simpleMessage("تاریخ انقضا"),
    "cardFeatureFamily": MessageLookupByLibrary.simpleMessage("کارت خانواده"),
    "cardFeatureFilter": MessageLookupByLibrary.simpleMessage("فیلتر"),
    "cardFeatureGift": MessageLookupByLibrary.simpleMessage("کارت هدیه"),
    "cardFeatureGiftTransfer": MessageLookupByLibrary.simpleMessage(
      "واریز مانده کارت هدیه منقضی",
    ),
    "cardFeatureIban": MessageLookupByLibrary.simpleMessage("شماره شبا"),
    "cardFeatureNoResults": MessageLookupByLibrary.simpleMessage(
      "کارتی با این مشخصات پیدا نشد",
    ),
    "cardFeatureNumber": MessageLookupByLibrary.simpleMessage("شماره کارت"),
    "cardFeatureQarz": MessageLookupByLibrary.simpleMessage("قرض الحسنه"),
    "cardFeatureRemoveFilter": MessageLookupByLibrary.simpleMessage(
      "حذف فیلتر",
    ),
    "cardFeatureResalat": MessageLookupByLibrary.simpleMessage("رسالت کارت"),
    "cardFeatureStatus": MessageLookupByLibrary.simpleMessage("وضعیت"),
    "cardFeatureUnavailable": MessageLookupByLibrary.simpleMessage(
      "این خدمت در حال حاضر در دسترس نیست.",
    ),
    "cardFeatureVirtualRequest": MessageLookupByLibrary.simpleMessage(
      "درخواست کارت مجازی",
    ),
    "cardPasswordIssue": MessageLookupByLibrary.simpleMessage(
      "صدور رمز اول /دوم کارت",
    ),
    "cardServiceCard": MessageLookupByLibrary.simpleMessage("کارت"),
    "cardServiceCardHint": MessageLookupByLibrary.simpleMessage(
      "کارت مورد نظر خود را انتخاب کنید",
    ),
    "cardServiceComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست با موفقیت ثبت شد.",
    ),
    "cardServiceCurrentDeposit": MessageLookupByLibrary.simpleMessage(
      "سپرده جاری",
    ),
    "cardServiceEmpty": MessageLookupByLibrary.simpleMessage(
      "موردی برای نمایش وجود ندارد.",
    ),
    "cardServiceFromDeposit": MessageLookupByLibrary.simpleMessage("از سپرده"),
    "cardServiceMockComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست آزمایشی ثبت شد؛ عملیات بانکی انجام نشده است.",
    ),
    "cardServiceQarzDeposit": MessageLookupByLibrary.simpleMessage(
      "سپرده قرض الحسنه",
    ),
    "cardServiceSubmit": MessageLookupByLibrary.simpleMessage(
      "تایید و ثبت درخواست",
    ),
    "cardServiceSubmitError": MessageLookupByLibrary.simpleMessage(
      "ثبت درخواست انجام نشد. دوباره تلاش کنید.",
    ),
    "cardServiceToDeposit": MessageLookupByLibrary.simpleMessage("به سپرده"),
    "cardServiceToDepositHint": MessageLookupByLibrary.simpleMessage(
      "سپرده‌ای که مایل هستید متصل به کارت باشد",
    ),
    "cardServices": MessageLookupByLibrary.simpleMessage("خدمات کارت"),
    "cardsBuyGift": MessageLookupByLibrary.simpleMessage("خرید کارت هدیه"),
    "cardsChangeFirst": MessageLookupByLibrary.simpleMessage("تغییر رمز اول"),
    "cardsCopyIban": MessageLookupByLibrary.simpleMessage("کپی شماره شبا"),
    "cardsCopyNumber": MessageLookupByLibrary.simpleMessage("کپی شماره کارت"),
    "cardsCurrent": MessageLookupByLibrary.simpleMessage("رسالت کارت (جاری)"),
    "cardsEmpty": MessageLookupByLibrary.simpleMessage("هنوز کارتی ندارید"),
    "cardsExpiry": MessageLookupByLibrary.simpleMessage(": انقضا"),
    "cardsForgotFirst": MessageLookupByLibrary.simpleMessage("فراموشی رمز اول"),
    "cardsForgotSecond": MessageLookupByLibrary.simpleMessage(
      "فراموشی رمز دوم",
    ),
    "cardsGiftBalance": MessageLookupByLibrary.simpleMessage(
      "واریز مانده کارت هدیه",
    ),
    "cardsHideDetails": MessageLookupByLibrary.simpleMessage(
      "پنهان کردن اطلاعات کارت",
    ),
    "cardsMore": MessageLookupByLibrary.simpleMessage("گزینه‌های کارت"),
    "cardsMyTitle": MessageLookupByLibrary.simpleMessage("کارت‌های من"),
    "cardsOperations": MessageLookupByLibrary.simpleMessage("عملیات کارت"),
    "cardsPinOperations": MessageLookupByLibrary.simpleMessage("عملیات رمز"),
    "cardsQarz": MessageLookupByLibrary.simpleMessage(
      "رسالت کارت (قرض الحسنه)",
    ),
    "cardsQuickAccess": MessageLookupByLibrary.simpleMessage("دسترسی سریع"),
    "cardsReissue": MessageLookupByLibrary.simpleMessage("صدور مجدد کارت"),
    "cardsSetSecond": MessageLookupByLibrary.simpleMessage("تعیین رمز دوم"),
    "cardsShowDetails": MessageLookupByLibrary.simpleMessage(
      "نمایش اطلاعات کارت",
    ),
    "cardsVirtual": MessageLookupByLibrary.simpleMessage("کارت مجازی"),
    "certificateAddressHint": MessageLookupByLibrary.simpleMessage(
      "آدرس ارسال گواهی را انتخاب کنید",
    ),
    "certificateAgentIdentifier": MessageLookupByLibrary.simpleMessage(
      "کد ملی یا تلفن کارشناس",
    ),
    "certificateAgentNotice": MessageLookupByLibrary.simpleMessage(
      "چنانچه کارشناس بانکی جهت احراز می‌شناسید، با وارد کردن کد ملی یا شماره تلفن کارشناس مد نظر خود را انتخاب کنید.",
    ),
    "certificateAgentUnavailable": MessageLookupByLibrary.simpleMessage(
      "استعلام کارشناس پس از اتصال به سامانه بانک فعال می‌شود.",
    ),
    "certificateAverageBalance": MessageLookupByLibrary.simpleMessage(
      "معدل موجودی",
    ),
    "certificateAverageTitle": MessageLookupByLibrary.simpleMessage(
      "درخواست صورت‌حساب | معدل موجودی",
    ),
    "certificateBothTurnovers": MessageLookupByLibrary.simpleMessage(
      "واریز | برداشت",
    ),
    "certificateCheckAgent": MessageLookupByLibrary.simpleMessage("بررسی"),
    "certificateConditionsPrompt": MessageLookupByLibrary.simpleMessage(
      "شرایط درخواست جهت درج روی گواهی را انتخاب کنید.",
    ),
    "certificateConditionsStep": MessageLookupByLibrary.simpleMessage(
      "انتخاب سپرده و شرایط درخواست",
    ),
    "certificateDeleteAddressPrompt": MessageLookupByLibrary.simpleMessage(
      "از حذف این آدرس مطمئن هستید؟",
    ),
    "certificateDeliveryStep": MessageLookupByLibrary.simpleMessage(
      "اطلاعات نحوه دریافت گواهی",
    ),
    "certificateDepositsOnly": MessageLookupByLibrary.simpleMessage("واریز"),
    "certificateEnglish": MessageLookupByLibrary.simpleMessage("انگلیسی"),
    "certificateFromDate": MessageLookupByLibrary.simpleMessage("از تاریخ"),
    "certificateFromDateHint": MessageLookupByLibrary.simpleMessage(
      "تاریخ شروع را مشخص کنید",
    ),
    "certificateLanguage": MessageLookupByLibrary.simpleMessage("زبان"),
    "certificateMockComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست آزمایشی ثبت شد؛ گواهی صادر نشده و مبلغی برداشت نشده است.",
    ),
    "certificateNextPrefix": MessageLookupByLibrary.simpleMessage("بعدی:"),
    "certificateOptional": MessageLookupByLibrary.simpleMessage("اختیاری"),
    "certificatePersian": MessageLookupByLibrary.simpleMessage("فارسی"),
    "certificatePrintingNotice": MessageLookupByLibrary.simpleMessage(
      "هزینه چاپ گزارش بر اساس تعداد صفحات محاسبه می‌شود.",
    ),
    "certificateRecipientName": MessageLookupByLibrary.simpleMessage(
      "نام و نام خانوادگی",
    ),
    "certificateRecipientNameHint": MessageLookupByLibrary.simpleMessage(
      "نام و نام خانوادگی گیرنده را وارد کنید",
    ),
    "certificateRecipientNationalIdHint": MessageLookupByLibrary.simpleMessage(
      "کد ملی گیرنده را وارد کنید",
    ),
    "certificateRecipientNotice": MessageLookupByLibrary.simpleMessage(
      "بسته فقط به شما تحویل داده می‌شود. در صورت عدم حضور، مشخصات تحویل گیرنده دوم را وارد کنید.",
    ),
    "certificateStatementLanguageHint": MessageLookupByLibrary.simpleMessage(
      "زبان صورتحساب را انتخاب کنید",
    ),
    "certificateToDate": MessageLookupByLibrary.simpleMessage("تا تاریخ"),
    "certificateToDateHint": MessageLookupByLibrary.simpleMessage(
      "تاریخ پایان را مشخص کنید",
    ),
    "certificateTurnover": MessageLookupByLibrary.simpleMessage("نوع گردش"),
    "certificateTurnoverHint": MessageLookupByLibrary.simpleMessage(
      "نوع گردش سپرده را انتخاب نمایید",
    ),
    "certificateWithdrawalsOnly": MessageLookupByLibrary.simpleMessage(
      "برداشت",
    ),
    "changeCardDeposit": MessageLookupByLibrary.simpleMessage(
      "تغییر سپرده متصل به کارت",
    ),
    "changeCardDepositIntro": MessageLookupByLibrary.simpleMessage(
      "ابتدا کارت را انتخاب کنید، سپس سپرده‌ای که می‌خواهید به آن وصل شود را انتخاب کنید.",
    ),
    "changeCardDepositTitle": MessageLookupByLibrary.simpleMessage(
      "تغییر سپرده متصل به کارت",
    ),
    "changeInstallmentDeposit": MessageLookupByLibrary.simpleMessage(
      "تغییر سپرده جهت کسر اقساط",
    ),
    "changeMobileDescription": MessageLookupByLibrary.simpleMessage(
      "برای تغییر شماره همراه ورود به پیشخوان اطلاعات زیر را وارد کنید",
    ),
    "changeMobileService": MessageLookupByLibrary.simpleMessage(
      "تغییر تلفن همراه",
    ),
    "changeMobileTitle": MessageLookupByLibrary.simpleMessage(
      "تغییر شماره همراه",
    ),
    "changeNationalIdHint": MessageLookupByLibrary.simpleMessage(
      "کد ملی | شماره ملی خود را وارد کنید",
    ),
    "changePhoneAction": MessageLookupByLibrary.simpleMessage(
      "تغییر شماره همراه",
    ),
    "changePhoneHint": MessageLookupByLibrary.simpleMessage(
      "شماره همراه جدید خود را وارد کنید",
    ),
    "chequeBookAddressesNoticeEnd": MessageLookupByLibrary.simpleMessage(
      " اقدام نمایید.",
    ),
    "chequeBookAddressesNoticeStart": MessageLookupByLibrary.simpleMessage(
      "در صورت نیاز به تغییر آدرس، از بخش اطلاعات کاربری، ",
    ),
    "chequeBookChecking": MessageLookupByLibrary.simpleMessage(
      "بررسی سامانه اسکان و املاک...",
    ),
    "chequeBookDeleteContinue": MessageLookupByLibrary.simpleMessage(
      "حذف و ادامه فرآیند",
    ),
    "chequeBookDeletePrompt": MessageLookupByLibrary.simpleMessage(
      "مطمئنید می‌خواهید آدرس زیر را حذف کنید؟",
    ),
    "chequeBookDeliveryStep": MessageLookupByLibrary.simpleMessage(
      "اطلاعات دریافت",
    ),
    "chequeBookDepositHint": MessageLookupByLibrary.simpleMessage(
      "سپرده مورد نظر خود را انتخاب کنید",
    ),
    "chequeBookFiftyLeavesNotice": MessageLookupByLibrary.simpleMessage(
      "برای کاربران حقیقی، صدور دسته‌چک ۵۰ برگی پس از پایان سال سوم امکان‌پذیر است.",
    ),
    "chequeBookIssueFee": MessageLookupByLibrary.simpleMessage(
      "هزینه صدور دسته چک",
    ),
    "chequeBookLeafCount": MessageLookupByLibrary.simpleMessage("تعداد برگ"),
    "chequeBookLeafCountHint": MessageLookupByLibrary.simpleMessage(
      "تعداد برگ دسته چک را انتخاب کنید",
    ),
    "chequeBookLegalRecipientPrompt": MessageLookupByLibrary.simpleMessage(
      "مشخصات تحویل گیرنده دسته چک را وارد نمایید",
    ),
    "chequeBookLinkUnavailable": MessageLookupByLibrary.simpleMessage(
      "باز کردن مرورگر در این دستگاه امکان‌پذیر نیست.",
    ),
    "chequeBookMissingNotice": MessageLookupByLibrary.simpleMessage(
      "در صورت صحت آدرس، ابتدا آن را در سامانه اسکان و املاک ثبت کرده و سپس برای صدور دسته‌چک اقدام نمایید.",
    ),
    "chequeBookMockComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست به‌صورت آزمایشی ثبت شد؛ دسته‌چک واقعی صادر و مبلغی برداشت نشده است.",
    ),
    "chequeBookMultipleMissingNotice": MessageLookupByLibrary.simpleMessage(
      "شما می‌توانید، آدرس مورد نظر را در سامانه‌ی اسکان و املاک کشور ثبت نموده و یا آدرس‌های اضافه خود را حذف نمایید.",
    ),
    "chequeBookMyAddresses": MessageLookupByLibrary.simpleMessage(
      "آدرس‌های من",
    ),
    "chequeBookNextConfirmation": MessageLookupByLibrary.simpleMessage(
      "بعدی: تایید اطلاعات و پرداخت کارمزد",
    ),
    "chequeBookNextDelivery": MessageLookupByLibrary.simpleMessage(
      "بعدی: اطلاعات دریافت",
    ),
    "chequeBookNextResidency": MessageLookupByLibrary.simpleMessage(
      "بعدی: بررسی اسکان و املاک",
    ),
    "chequeBookNotRegistered": MessageLookupByLibrary.simpleMessage(
      "فاقد اسکان و املاک",
    ),
    "chequeBookOpenedAt": MessageLookupByLibrary.simpleMessage(
      "تاریخ افتتاح حساب:",
    ),
    "chequeBookRecipientName": MessageLookupByLibrary.simpleMessage(
      "نام و نام خانوادگی",
    ),
    "chequeBookRecipientNameHint": MessageLookupByLibrary.simpleMessage(
      "نام و نام خانوادگی تحویل گیرنده را وارد کنید",
    ),
    "chequeBookRecipientNameInvalid": MessageLookupByLibrary.simpleMessage(
      "نام و نام خانوادگی را وارد کنید.",
    ),
    "chequeBookRecipientNationalId": MessageLookupByLibrary.simpleMessage(
      "کد ملی",
    ),
    "chequeBookRecipientNationalIdHint": MessageLookupByLibrary.simpleMessage(
      "کد ملی تحویل گیرنده را وارد کنید",
    ),
    "chequeBookRegistered": MessageLookupByLibrary.simpleMessage(
      "دارای اسکان و املاک",
    ),
    "chequeBookRegistryHost": MessageLookupByLibrary.simpleMessage(
      "amlak.mrud.ir",
    ),
    "chequeBookRegistryName": MessageLookupByLibrary.simpleMessage(
      "سامانه اسکان و املاک",
    ),
    "chequeBookRegistryUrlLabel": MessageLookupByLibrary.simpleMessage(
      "آدرس سامانه اسکان و املاک:",
    ),
    "chequeBookResidence": MessageLookupByLibrary.simpleMessage(
      "آدرس محل سکونت شما:",
    ),
    "chequeBookResidences": MessageLookupByLibrary.simpleMessage(
      "آدرس‌های محل سکونت شما:",
    ),
    "chequeBookResidencyStep": MessageLookupByLibrary.simpleMessage(
      "بررسی اسکان و املاک",
    ),
    "chequeBookResidencyWarningEnd": MessageLookupByLibrary.simpleMessage(
      " تأیید نشده است.",
    ),
    "chequeBookResidencyWarningStart": MessageLookupByLibrary.simpleMessage(
      "آدرس محل سکونت شما در ",
    ),
    "chequeBookSelectionPrompt": MessageLookupByLibrary.simpleMessage(
      "شماره حساب جاری و تعداد برگ دسته چک را انتخاب کنید.",
    ),
    "chequeBookSelectionStep": MessageLookupByLibrary.simpleMessage(
      "مشخصات دسته چک",
    ),
    "chequeBookTitle": MessageLookupByLibrary.simpleMessage(
      "درخواست صدور دسته چک",
    ),
    "chequeBookUsedLeavesNotice": MessageLookupByLibrary.simpleMessage(
      "برای صدور دسته‌چک جدید، لازم است حداقل ۸۰٪ برگ‌های دسته چک قبلی به بانک برگشته باشند.",
    ),
    "chequeCityHint": MessageLookupByLibrary.simpleMessage(
      "شهر مورد نظر را انتخاب کنید",
    ),
    "chequeCityLabel": MessageLookupByLibrary.simpleMessage("شهر*"),
    "chequeCitySummary": MessageLookupByLibrary.simpleMessage("شهر"),
    "chequeClearanceIntro": MessageLookupByLibrary.simpleMessage(
      "شماره چک، سپرده متصل به آن و علت درخواست را وارد کنید.",
    ),
    "chequeClearanceTitle": MessageLookupByLibrary.simpleMessage(
      "رفع سوء اثر چک",
    ),
    "chequeConsentConditions": MessageLookupByLibrary.simpleMessage(
      "مشاهده شرایط",
    ),
    "chequeConsentNotes": MessageLookupByLibrary.simpleMessage("نکات"),
    "chequeConsentNotice": MessageLookupByLibrary.simpleMessage(
      "متن تنظیمی جهت رضایت نامه محضری در دفترخانه باید کاملاً مطابق با شرایط پیوست شده باشد در غیر این صورت قابل پذیرش نمی‌باشد.",
    ),
    "chequeConsentSample": MessageLookupByLibrary.simpleMessage(
      "نمونه متن رضایت نامه محضری:",
    ),
    "chequeContentUnavailable": MessageLookupByLibrary.simpleMessage(
      "محتوا هنوز آماده نشده است.",
    ),
    "chequeDepositHint": MessageLookupByLibrary.simpleMessage(
      "سپرده پشت چک را انتخاب کنید",
    ),
    "chequeDepositLabel": MessageLookupByLibrary.simpleMessage("سپرده"),
    "chequeDocumentConsent": MessageLookupByLibrary.simpleMessage(
      "اصل رضایت نامه محضری",
    ),
    "chequeDocumentJudicial": MessageLookupByLibrary.simpleMessage(
      "اصل نامه قضایی",
    ),
    "chequeDocumentOriginal": MessageLookupByLibrary.simpleMessage("لاشه چک"),
    "chequeDocumentsTitle": MessageLookupByLibrary.simpleMessage(
      "مدارک لازم جهت تحویل به پست:",
    ),
    "chequeDownloadSample": MessageLookupByLibrary.simpleMessage(
      "دانلود نمونه",
    ),
    "chequeJudicialNumber": MessageLookupByLibrary.simpleMessage(
      "شماره نامه قضایی",
    ),
    "chequeJudicialNumberHint": MessageLookupByLibrary.simpleMessage(
      "شماره نامه قضایی را وارد کنید",
    ),
    "chequeJudicialNumberInvalid": MessageLookupByLibrary.simpleMessage(
      "شماره نامه قضایی را با ارقام وارد کنید.",
    ),
    "chequeMailingAddressTitle": MessageLookupByLibrary.simpleMessage(
      "آدرس ارسالی روی پاکت جهت تحویل به پست:",
    ),
    "chequeMailingInstruction": MessageLookupByLibrary.simpleMessage(
      "هنگام تحویل مدارک پاکت گذاری توسط اداره پست انجام خواهد شد",
    ),
    "chequeMockComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست به صورت آزمایشی ثبت شد؛ سوءاثر هیچ چک واقعی رفع نشده است.",
    ),
    "chequeNoPostRequired": MessageLookupByLibrary.simpleMessage(
      "نیاز به ارسال پست نیست.",
    ),
    "chequeNumberHint": MessageLookupByLibrary.simpleMessage(
      "شماره چک را انتخاب کنید",
    ),
    "chequeNumberInvalid": MessageLookupByLibrary.simpleMessage(
      "شماره چک را با ارقام و در صورت نیاز / وارد کنید.",
    ),
    "chequeNumberLabel": MessageLookupByLibrary.simpleMessage("شماره چک"),
    "chequeNumberNotFound": MessageLookupByLibrary.simpleMessage(
      "شماره وارد شده در لیست چک‌های شما نیست",
    ),
    "chequePostalAction": MessageLookupByLibrary.simpleMessage(
      "معرفی نزدیک‌ترین دفتر پستی مجاز",
    ),
    "chequePostalEmpty": MessageLookupByLibrary.simpleMessage(
      "دفتر پستی برای این شهر در داده‌های آزمایشی ثبت نشده است.",
    ),
    "chequePostalFailure": MessageLookupByLibrary.simpleMessage(
      "دریافت لیست دفاتر پستی انجام نشد. دوباره تلاش کنید.",
    ),
    "chequePostalSearch": MessageLookupByLibrary.simpleMessage("جستجو"),
    "chequePostalSearchAgain": MessageLookupByLibrary.simpleMessage(
      "جستجوی دوباره",
    ),
    "chequePostalShare": MessageLookupByLibrary.simpleMessage("اشتراک‌گذاری"),
    "chequePostalTitle": MessageLookupByLibrary.simpleMessage(
      "نزدیک‌ترین دفتر پستی مجاز",
    ),
    "chequeProvinceHint": MessageLookupByLibrary.simpleMessage(
      "استان مورد نظر را انتخاب کنید",
    ),
    "chequeProvinceLabel": MessageLookupByLibrary.simpleMessage("استان*"),
    "chequeProvinceSummary": MessageLookupByLibrary.simpleMessage("استان"),
    "chequeReasonConsent": MessageLookupByLibrary.simpleMessage(
      "رضایت نامه محضری",
    ),
    "chequeReasonDepositAndBlock": MessageLookupByLibrary.simpleMessage(
      "واریز مبلغ و مسدودی",
    ),
    "chequeReasonHint": MessageLookupByLibrary.simpleMessage(
      "علت درخواست را انتخاب کنید",
    ),
    "chequeReasonJudicial": MessageLookupByLibrary.simpleMessage("نامه قضایی"),
    "chequeReasonLabel": MessageLookupByLibrary.simpleMessage("علت درخواست"),
    "chequeReasonOlderThanThreeYears": MessageLookupByLibrary.simpleMessage(
      "رفع سوءاثر چک بیش از ۳ سال",
    ),
    "chequeReasonOriginal": MessageLookupByLibrary.simpleMessage(
      "ارائه لاشه چک",
    ),
    "chequeReasonPartialPayment": MessageLookupByLibrary.simpleMessage(
      "گواهی عدم پرداخت قسمتی از وجه چک",
    ),
    "chequeRequestComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست ثبت شد.",
    ),
    "chequeShareUnavailable": MessageLookupByLibrary.simpleMessage(
      "اشتراک‌گذاری در این دستگاه در دسترس نیست.",
    ),
    "chequeSubmit": MessageLookupByLibrary.simpleMessage("تایید و ثبت درخواست"),
    "chequeSubmitFailure": MessageLookupByLibrary.simpleMessage(
      "ثبت درخواست انجام نشد. دوباره تلاش کنید.",
    ),
    "chequeTerms": MessageLookupByLibrary.simpleMessage("قوانین و مقررات"),
    "chequeTermsPrompt": MessageLookupByLibrary.simpleMessage(
      "درخواست را مطالعه و تایید می‌نمایم.",
    ),
    "closeLabel": MessageLookupByLibrary.simpleMessage("بستن"),
    "consolidateDepositCredit": MessageLookupByLibrary.simpleMessage(
      "تجمیع اعتبار سپرده",
    ),
    "dashboardAddFavorites": MessageLookupByLibrary.simpleMessage(
      "افزودن خدمات منتخب",
    ),
    "dashboardAddService": MessageLookupByLibrary.simpleMessage(
      "افزودن مورد جدید",
    ),
    "dashboardAddresses": MessageLookupByLibrary.simpleMessage("مدیریت آدرس"),
    "dashboardAgentSettings": MessageLookupByLibrary.simpleMessage(
      "تنظیمات نمایندگی",
    ),
    "dashboardAllServices": MessageLookupByLibrary.simpleMessage("همه خدمات"),
    "dashboardAssistant": MessageLookupByLibrary.simpleMessage("دستیار هوشمند"),
    "dashboardBankServices": MessageLookupByLibrary.simpleMessage(
      "خدمات بانک رسالت",
    ),
    "dashboardBlockDeposit": MessageLookupByLibrary.simpleMessage(
      "مسدودی سپرده",
    ),
    "dashboardCancel": MessageLookupByLibrary.simpleMessage("انصراف"),
    "dashboardCancelCheque": MessageLookupByLibrary.simpleMessage("ابطال چک"),
    "dashboardCardsList": MessageLookupByLibrary.simpleMessage("لیست کارت‌ها"),
    "dashboardCardsTab": MessageLookupByLibrary.simpleMessage("کارت"),
    "dashboardChangeIdentity": MessageLookupByLibrary.simpleMessage(
      "تغییر مشخصات هویتی",
    ),
    "dashboardChangePhone": MessageLookupByLibrary.simpleMessage(
      "تغییر شماره تلفن همراه",
    ),
    "dashboardChequeServices": MessageLookupByLibrary.simpleMessage("چک"),
    "dashboardClearCheque": MessageLookupByLibrary.simpleMessage(
      "رفع سوء اثر چک",
    ),
    "dashboardCloseExtras": MessageLookupByLibrary.simpleMessage(
      "بستن سپرده‌های مازاد",
    ),
    "dashboardConfirm": MessageLookupByLibrary.simpleMessage("تایید"),
    "dashboardCorrectInstallments": MessageLookupByLibrary.simpleMessage(
      "اصلاح اقساط پرداختی",
    ),
    "dashboardCustomize": MessageLookupByLibrary.simpleMessage(
      "تنظیم خدمات منتخب",
    ),
    "dashboardDeferLoan": MessageLookupByLibrary.simpleMessage("امهال وام"),
    "dashboardDepositsList": MessageLookupByLibrary.simpleMessage(
      "لیست سپرده‌ها",
    ),
    "dashboardDepositsTab": MessageLookupByLibrary.simpleMessage("سپرده"),
    "dashboardEdit": MessageLookupByLibrary.simpleMessage("ویرایش"),
    "dashboardEmpty": MessageLookupByLibrary.simpleMessage(
      "اطلاعاتی برای نمایش وجود ندارد",
    ),
    "dashboardEstimateCredit": MessageLookupByLibrary.simpleMessage(
      "برآورد اعتبار وام",
    ),
    "dashboardExpiredGift": MessageLookupByLibrary.simpleMessage(
      "واریز مانده کارت هدیه منقضی",
    ),
    "dashboardFavoritesLimit": MessageLookupByLibrary.simpleMessage(
      "حداکثر ۸ تا مورد رو می‌تونی انتخاب کنی.",
    ),
    "dashboardGreeting": MessageLookupByLibrary.simpleMessage(
      "مانی عزیز، صبح بخیر",
    ),
    "dashboardIdentityServices": MessageLookupByLibrary.simpleMessage(
      "اطلاعات فردی",
    ),
    "dashboardLoadError": MessageLookupByLibrary.simpleMessage(
      "دریافت اطلاعات انجام نشد",
    ),
    "dashboardLoading": MessageLookupByLibrary.simpleMessage(
      "در حال دریافت اطلاعات…",
    ),
    "dashboardLoanReport": MessageLookupByLibrary.simpleMessage(
      "گزارش معرفی وام",
    ),
    "dashboardLoansTab": MessageLookupByLibrary.simpleMessage("وام"),
    "dashboardLocalTransfer": MessageLookupByLibrary.simpleMessage(
      "انتقال وجه خدمت در محل",
    ),
    "dashboardManageInstallments": MessageLookupByLibrary.simpleMessage(
      "مدیریت کسر اقساط",
    ),
    "dashboardModernBanking": MessageLookupByLibrary.simpleMessage(
      "بانکداری مدرن",
    ),
    "dashboardMyLoans": MessageLookupByLibrary.simpleMessage("وام‌های من"),
    "dashboardNoServices": MessageLookupByLibrary.simpleMessage(
      "خدمتی پیدا نشد",
    ),
    "dashboardOccupation": MessageLookupByLibrary.simpleMessage("مدیریت شغل"),
    "dashboardOpenCurrent": MessageLookupByLibrary.simpleMessage(
      "افتتاح سپرده جاری",
    ),
    "dashboardPhoneBank": MessageLookupByLibrary.simpleMessage("تلفن بانک"),
    "dashboardPromptCard": MessageLookupByLibrary.simpleMessage(
      "چطور کارت رسالت بگیرم؟",
    ),
    "dashboardPromptCertificate": MessageLookupByLibrary.simpleMessage(
      "گواهی تمکن مالی می‌خوام...",
    ),
    "dashboardPromptHint": MessageLookupByLibrary.simpleMessage(
      "سوالت رو بنویس...",
    ),
    "dashboardRemoveService": MessageLookupByLibrary.simpleMessage("حذف"),
    "dashboardRequestDate": MessageLookupByLibrary.simpleMessage(
      "2024/09/16 | ۱۲:۴۵",
    ),
    "dashboardRequestNumber": MessageLookupByLibrary.simpleMessage(
      "۱۳۷/۴۸۷۵۶۷",
    ),
    "dashboardRequestServices": MessageLookupByLibrary.simpleMessage(
      "درخواست‌های من",
    ),
    "dashboardRequestTitle": MessageLookupByLibrary.simpleMessage(
      "درخواست تغییر سپرده جهت کسر اقساط",
    ),
    "dashboardRequests": MessageLookupByLibrary.simpleMessage("درخواست‌های من"),
    "dashboardResetConfirm": MessageLookupByLibrary.simpleMessage(
      "بازنشانی تنظیمات",
    ),
    "dashboardResetDescription": MessageLookupByLibrary.simpleMessage(
      "با بازنشانی تنظیمات، همه تغییراتت از بین می‌ره و به حالت اولیه برمی‌گرده.\nمطمئنی می‌خوای به تنظیمات اولیه برگردی؟",
    ),
    "dashboardResetTitle": MessageLookupByLibrary.simpleMessage(
      "بازنشانی تنظیمات",
    ),
    "dashboardResoDescription": MessageLookupByLibrary.simpleMessage(
      "رِسو فقط جواب نمی‌ده؛ خودش دست‌به‌کار می‌شه.",
    ),
    "dashboardResoTitle": MessageLookupByLibrary.simpleMessage(
      "به رِسو بسپار!",
    ),
    "dashboardRetry": MessageLookupByLibrary.simpleMessage("تلاش دوباره"),
    "dashboardSearchHint": MessageLookupByLibrary.simpleMessage("جستجو"),
    "dashboardSendPrompt": MessageLookupByLibrary.simpleMessage("ارسال سوال"),
    "dashboardTab": MessageLookupByLibrary.simpleMessage("داشبورد"),
    "dashboardTransferServices": MessageLookupByLibrary.simpleMessage(
      "انتقال وجه",
    ),
    "dashboardUnblockCard": MessageLookupByLibrary.simpleMessage(
      "رفع مسدودی کارت",
    ),
    "dashboardUnblockDeposit": MessageLookupByLibrary.simpleMessage(
      "رفع مسدودی سپرده",
    ),
    "dashboardViewAll": MessageLookupByLibrary.simpleMessage("مشاهده همه"),
    "dashboardVirtualCard": MessageLookupByLibrary.simpleMessage(
      "درخواست کارت مجازی",
    ),
    "dashboardWalletBalance": MessageLookupByLibrary.simpleMessage("۱٬۲۰۰٬۰۰۰"),
    "dashboardWalletCharge": MessageLookupByLibrary.simpleMessage(
      "افزایش موجودی",
    ),
    "dashboardWalletDeposit": MessageLookupByLibrary.simpleMessage(
      "تغییر سپرده متصل به کیف",
    ),
    "dashboardWalletHistory": MessageLookupByLibrary.simpleMessage(
      "گردش کیف پول",
    ),
    "dashboardWalletInfo": MessageLookupByLibrary.simpleMessage(
      "اطلاعات کیف پول",
    ),
    "dashboardWalletServices": MessageLookupByLibrary.simpleMessage("کیف پول"),
    "dashboardWalletTransfer": MessageLookupByLibrary.simpleMessage(
      "واریز کیف به کیف",
    ),
    "dashboardWalletWithdraw": MessageLookupByLibrary.simpleMessage(
      "برداشت موجودی",
    ),
    "dashboardWelcomeMessage": MessageLookupByLibrary.simpleMessage(
      "به پیشخوان مجازی رسالت خوش آمدید",
    ),
    "dashboardYourFavorites": MessageLookupByLibrary.simpleMessage("منتخب شما"),
    "depositBlockIntro": MessageLookupByLibrary.simpleMessage(
      "سپرده مورد نظر و علت مسدودی را انتخاب کنید",
    ),
    "depositBlockTitle": MessageLookupByLibrary.simpleMessage("مسدودی سپرده"),
    "depositBlockedDate": MessageLookupByLibrary.simpleMessage("تاریخ مسدودی"),
    "depositBlockedReason": MessageLookupByLibrary.simpleMessage("علت مسدودی"),
    "depositListAccountDetails": MessageLookupByLibrary.simpleMessage(
      "جزئیات حساب",
    ),
    "depositListAccountType": MessageLookupByLibrary.simpleMessage("نوع حساب"),
    "depositListBlock": MessageLookupByLibrary.simpleMessage("مسدودی سپرده"),
    "depositListBlocked": MessageLookupByLibrary.simpleMessage("مسدود"),
    "depositListClosed": MessageLookupByLibrary.simpleMessage("بسته"),
    "depositListCurrent": MessageLookupByLibrary.simpleMessage("جاری حقیقی"),
    "depositListCustomerInformation": MessageLookupByLibrary.simpleMessage(
      "اطلاعات مشتری",
    ),
    "depositListLinkedCards": MessageLookupByLibrary.simpleMessage(
      "کارت‌های متصل به حساب",
    ),
    "depositListNationalId": MessageLookupByLibrary.simpleMessage("کدملی"),
    "depositListNoMatches": MessageLookupByLibrary.simpleMessage(
      "سپرده‌ای با این فیلترها پیدا نشد.",
    ),
    "depositListNoOwners": MessageLookupByLibrary.simpleMessage(
      "اطلاعات صاحبان حساب در دسترس نیست.",
    ),
    "depositListNumber": MessageLookupByLibrary.simpleMessage("شماره سپرده"),
    "depositListOpen": MessageLookupByLibrary.simpleMessage("باز"),
    "depositListOwner": MessageLookupByLibrary.simpleMessage("صاحب سپرده"),
    "depositListOwnerAndSignatory": MessageLookupByLibrary.simpleMessage(
      "صاحب سپرده و امضا",
    ),
    "depositListOwnerName": MessageLookupByLibrary.simpleMessage("نام"),
    "depositListOwnerPercent": MessageLookupByLibrary.simpleMessage("درصد"),
    "depositListOwnerRole": MessageLookupByLibrary.simpleMessage("نقش"),
    "depositListSavings": MessageLookupByLibrary.simpleMessage(
      "پس انداز حقیقی",
    ),
    "depositListServiceUnavailable": MessageLookupByLibrary.simpleMessage(
      "این خدمت پس از اتصال به سامانه بانک در دسترس خواهد بود.",
    ),
    "depositListSignatory": MessageLookupByLibrary.simpleMessage("صاحب امضا"),
    "depositListSms": MessageLookupByLibrary.simpleMessage(
      "تنظیمات ارسال پیامک",
    ),
    "depositListStatement": MessageLookupByLibrary.simpleMessage(
      "صورت حساب | معدل موجودی",
    ),
    "depositListStatus": MessageLookupByLibrary.simpleMessage("وضعیت"),
    "depositRestrictionDescription": MessageLookupByLibrary.simpleMessage(
      "توضیحات",
    ),
    "depositRestrictionDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "در صورت نیاز توضیحات را وارد کنید",
    ),
    "depositRestrictionManagement": MessageLookupByLibrary.simpleMessage(
      "مدیریت سپرده",
    ),
    "depositRestrictionMockComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست به صورت آزمایشی ثبت شد. هیچ سپرده یا کیف پول واقعی تغییر نکرده است.",
    ),
    "depositRestrictionReason": MessageLookupByLibrary.simpleMessage(
      "علت درخواست",
    ),
    "depositRestrictionReasonHint": MessageLookupByLibrary.simpleMessage(
      "علت درخواست را انتخاب کنید",
    ),
    "depositServices": MessageLookupByLibrary.simpleMessage("خدمات سپرده"),
    "depositUnblockIntro": MessageLookupByLibrary.simpleMessage(
      "سپرده مورد نظر و علت رفع مسدودی را انتخاب کنید",
    ),
    "depositUnblockReason": MessageLookupByLibrary.simpleMessage(
      "علت رفع مسدودی",
    ),
    "depositUnblockTitle": MessageLookupByLibrary.simpleMessage(
      "رفع مسدودی سپرده",
    ),
    "depositsAgent": MessageLookupByLibrary.simpleMessage("تنظیمات نماینده"),
    "depositsChequeOperations": MessageLookupByLibrary.simpleMessage(
      "عملیات چک",
    ),
    "depositsCopyNumber": MessageLookupByLibrary.simpleMessage(
      "کپی شماره سپرده",
    ),
    "depositsEmpty": MessageLookupByLibrary.simpleMessage(
      "هنوز سپرده‌ای ندارید",
    ),
    "depositsLinkedCards": MessageLookupByLibrary.simpleMessage(
      "کارت‌های متصل به سپرده",
    ),
    "depositsLinkedLoans": MessageLookupByLibrary.simpleMessage(
      "وضعیت وام‌های متصل",
    ),
    "depositsLocalTransfer": MessageLookupByLibrary.simpleMessage(
      "انتقال وجه خدمت در محل",
    ),
    "depositsMobileBank": MessageLookupByLibrary.simpleMessage("موبایل بانک"),
    "depositsMyTitle": MessageLookupByLibrary.simpleMessage("سپرده‌های من"),
    "depositsOperations": MessageLookupByLibrary.simpleMessage("عملیات سپرده"),
    "enterDashboard": MessageLookupByLibrary.simpleMessage("ورود به پیشخوان"),
    "financialAuthority": MessageLookupByLibrary.simpleMessage("مرجع"),
    "financialAuthorityHint": MessageLookupByLibrary.simpleMessage(
      "نام دقیق مرجع را بنویسید",
    ),
    "financialAverageBalanceCondition": MessageLookupByLibrary.simpleMessage(
      "درج میانگین موجودی",
    ),
    "financialCertificate": MessageLookupByLibrary.simpleMessage(
      "گواهی تمکن مالی",
    ),
    "financialCertificateTitle": MessageLookupByLibrary.simpleMessage(
      "درخواست گواهی تمکن مالی",
    ),
    "financialCurrency": MessageLookupByLibrary.simpleMessage("ارز معادل"),
    "financialCurrencyHint": MessageLookupByLibrary.simpleMessage(
      "نوع ارز را جهت ارائه تمکن مالی انتخاب کنید",
    ),
    "financialDebitCredit": MessageLookupByLibrary.simpleMessage(
      "درج مبلغ گردش بدهکار بستانکار",
    ),
    "financialDeliveryStep": MessageLookupByLibrary.simpleMessage(
      "اطلاعات دریافت گواهی",
    ),
    "financialEmbassy": MessageLookupByLibrary.simpleMessage("سفارت"),
    "financialEmbassyHint": MessageLookupByLibrary.simpleMessage(
      "سفارت مورد نظر را انتخاب کنید",
    ),
    "financialEur": MessageLookupByLibrary.simpleMessage("یورو"),
    "financialExchangeRate": MessageLookupByLibrary.simpleMessage(
      "درج نرخ برابری روز",
    ),
    "financialExpiryHint": MessageLookupByLibrary.simpleMessage(
      "تاریخ لاتین انقضای گذرنامه، درج شده در گذرنامه",
    ),
    "financialFatherHint": MessageLookupByLibrary.simpleMessage(
      "نام پدر به انگلیسی مطابق گذرنامه",
    ),
    "financialHomeAddress": MessageLookupByLibrary.simpleMessage(
      "آدرس محل سکونت",
    ),
    "financialIrr": MessageLookupByLibrary.simpleMessage("ریال ایران"),
    "financialLatinAddress": MessageLookupByLibrary.simpleMessage("Address"),
    "financialLatinAddressHint": MessageLookupByLibrary.simpleMessage(
      "Unit, No, Alley, St, City, Province, Country, Postal code",
    ),
    "financialLatinAddressPrompt": MessageLookupByLibrary.simpleMessage(
      "آدرس انگلیسی جهت درج در گواهی تمکن مالی را طبق فرمت نمونه وارد نمایید.",
    ),
    "financialLatinExpiry": MessageLookupByLibrary.simpleMessage(
      "Date of Expiry",
    ),
    "financialLatinFather": MessageLookupByLibrary.simpleMessage(
      "Father\'s name",
    ),
    "financialLatinName": MessageLookupByLibrary.simpleMessage("Name"),
    "financialLatinPassport": MessageLookupByLibrary.simpleMessage(
      "Passport No",
    ),
    "financialLatinStep": MessageLookupByLibrary.simpleMessage(
      "اطلاعات فردی لاتین",
    ),
    "financialLatinSurname": MessageLookupByLibrary.simpleMessage("Surname"),
    "financialMaturityDate": MessageLookupByLibrary.simpleMessage(
      "تاریخ سررسید سپرده",
    ),
    "financialNameHint": MessageLookupByLibrary.simpleMessage(
      "نام به انگلیسی مطابق گذرنامه",
    ),
    "financialOpenedAt": MessageLookupByLibrary.simpleMessage(
      "درج تاریخ اولیه افتتاح سپرده",
    ),
    "financialOtherAuthority": MessageLookupByLibrary.simpleMessage(
      "دیگر مراجع",
    ),
    "financialPassportHint": MessageLookupByLibrary.simpleMessage(
      "شماره گذرنامه به انگلیسی",
    ),
    "financialPassportNumberCondition": MessageLookupByLibrary.simpleMessage(
      "شماره گذرنامه / شماره ثبت",
    ),
    "financialPassportPrompt": MessageLookupByLibrary.simpleMessage(
      "اطلاعات زیر را مطابق با گذرنامه خود وارد نمایید.",
    ),
    "financialRecipient": MessageLookupByLibrary.simpleMessage("گیرنده"),
    "financialRecipientHint": MessageLookupByLibrary.simpleMessage(
      "گیرنده گواهی را انتخاب کنید",
    ),
    "financialRecipientPrompt": MessageLookupByLibrary.simpleMessage(
      "گیرنده گواهی و ارز معادل را انتخاب کنید",
    ),
    "financialRecipientStep": MessageLookupByLibrary.simpleMessage(
      "گیرنده گواهی و نوع ارز",
    ),
    "financialSurnameHint": MessageLookupByLibrary.simpleMessage(
      "نام خانوادگی به انگلیسی مطابق گذرنامه",
    ),
    "financialUsd": MessageLookupByLibrary.simpleMessage("دلار آمریکا"),
    "financialWithdrawalRules": MessageLookupByLibrary.simpleMessage(
      "شرایط برداشت از سپرده‌های مشترک / حقوقی",
    ),
    "flowExitTitle": MessageLookupByLibrary.simpleMessage("خروج از عملیات؟"),
    "giftBalanceCount": MessageLookupByLibrary.simpleMessage(
      "تعداد کارت هدیه منقضی",
    ),
    "giftBalanceDepositHint": MessageLookupByLibrary.simpleMessage(
      "سپرده مورد نظر خود را انتخاب کنید",
    ),
    "giftBalanceDestination": MessageLookupByLibrary.simpleMessage(
      "انتخاب سپرده جهت واریز",
    ),
    "giftBalanceEnd": MessageLookupByLibrary.simpleMessage("پایان"),
    "giftBalanceIntro": MessageLookupByLibrary.simpleMessage(
      "کارت‌های هدیه منقضی شده را انتخاب کنید",
    ),
    "giftBalanceNext": MessageLookupByLibrary.simpleMessage("مرحله بعد"),
    "giftBalanceNextDestination": MessageLookupByLibrary.simpleMessage(
      "بعدی: انتخاب سپرده جهت واریز",
    ),
    "giftBalanceRemaining": MessageLookupByLibrary.simpleMessage(
      "مانده موجودی (ریال)",
    ),
    "giftBalanceRemoveCard": m1,
    "giftBalanceSearch": MessageLookupByLibrary.simpleMessage(
      "جستجو بر اساس شماره کارت",
    ),
    "giftBalanceSelectAll": MessageLookupByLibrary.simpleMessage("انتخاب همه"),
    "giftBalanceSelectedList": m2,
    "giftBalanceSelection": MessageLookupByLibrary.simpleMessage(
      "انتخاب کارت‌ها",
    ),
    "giftBalanceSubmit": MessageLookupByLibrary.simpleMessage("ثبت درخواست"),
    "giftBalanceTitle": MessageLookupByLibrary.simpleMessage(
      "واریز مانده کارت هدیه منقضی",
    ),
    "giftBalanceTotal": MessageLookupByLibrary.simpleMessage(
      "مجموع مبلغ (ریال)",
    ),
    "giftBalanceTransferTo": MessageLookupByLibrary.simpleMessage("انتقال به"),
    "guestServices": MessageLookupByLibrary.simpleMessage(
      "خدمات بدون نیاز به لاگین",
    ),
    "inheritance": MessageLookupByLibrary.simpleMessage("انحصار وراثت"),
    "internetBank": MessageLookupByLibrary.simpleMessage("اینترنت بانک"),
    "internetBankSettings": MessageLookupByLibrary.simpleMessage(
      "تنظیمات اینترنت بانک",
    ),
    "introduceAgent": MessageLookupByLibrary.simpleMessage("معرفی نماینده"),
    "introduceLoan": MessageLookupByLibrary.simpleMessage("معرفی وام"),
    "issuanceAddAddress": MessageLookupByLibrary.simpleMessage(
      "افزودن آدرس جدید",
    ),
    "issuanceAddress": MessageLookupByLibrary.simpleMessage("آدرس"),
    "issuanceAddressDetail": MessageLookupByLibrary.simpleMessage("نشانی کامل"),
    "issuanceAddressHint": MessageLookupByLibrary.simpleMessage(
      "آدرس دریافت کارت را انتخاب کنید",
    ),
    "issuanceAddressInvalid": MessageLookupByLibrary.simpleMessage(
      "عنوان، نشانی کامل و کد پستی ۱۰ رقمی را وارد کنید.",
    ),
    "issuanceAddressTitle": MessageLookupByLibrary.simpleMessage("عنوان آدرس"),
    "issuanceAgentCode": MessageLookupByLibrary.simpleMessage("کد کارشناس"),
    "issuanceAgentName": MessageLookupByLibrary.simpleMessage(
      "نام و نام خانوادگی کارشناس",
    ),
    "issuanceComplete": MessageLookupByLibrary.simpleMessage("درخواست ثبت شد."),
    "issuanceConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "تایید اطلاعات و پرداخت کارمزد",
    ),
    "issuanceCurrentCard": MessageLookupByLibrary.simpleMessage(
      "شماره کارت فعلی",
    ),
    "issuanceDeleteAddress": MessageLookupByLibrary.simpleMessage("حذف آدرس"),
    "issuanceDeliveryFee": MessageLookupByLibrary.simpleMessage("هزینه ارسال"),
    "issuanceDeliveryTitle": MessageLookupByLibrary.simpleMessage(
      "اطلاعات دریافت کارت",
    ),
    "issuanceDeposit": MessageLookupByLibrary.simpleMessage("انتخاب سپرده"),
    "issuanceDepositHint": MessageLookupByLibrary.simpleMessage(
      "سپرده مورد نظر خود را انتخاب کنید",
    ),
    "issuanceDepositNumber": MessageLookupByLibrary.simpleMessage(
      "شماره سپرده",
    ),
    "issuanceDone": MessageLookupByLibrary.simpleMessage("بازگشت"),
    "issuanceEmpty": MessageLookupByLibrary.simpleMessage(
      "سپرده‌ای برای صدور کارت در دسترس نیست.",
    ),
    "issuanceEnd": MessageLookupByLibrary.simpleMessage("پایان"),
    "issuanceExistingNumber": MessageLookupByLibrary.simpleMessage(
      "صدور کارت با شماره فعلی",
    ),
    "issuanceExpiry": MessageLookupByLibrary.simpleMessage("تاریخ انقضا"),
    "issuanceIdentityFee": MessageLookupByLibrary.simpleMessage(
      "کارمزد احراز هویت",
    ),
    "issuanceIncludeAgent": MessageLookupByLibrary.simpleMessage(
      "وارد کردن مشخصات کارشناس بانکی",
    ),
    "issuanceMockComplete": MessageLookupByLibrary.simpleMessage(
      "پیش‌نمایش درخواست تکمیل شد؛ پرداخت یا صدور واقعی انجام نشده است.",
    ),
    "issuanceNationalId": MessageLookupByLibrary.simpleMessage("کد ملی گیرنده"),
    "issuanceNewNumber": MessageLookupByLibrary.simpleMessage(
      "صدور کارت با شماره جدید",
    ),
    "issuanceNext": MessageLookupByLibrary.simpleMessage("مرحله بعد"),
    "issuanceNextConfirm": MessageLookupByLibrary.simpleMessage(
      "بعدی: تایید اطلاعات و پرداخت کارمزد",
    ),
    "issuanceNextDelivery": MessageLookupByLibrary.simpleMessage(
      "بعدی: اطلاعات دریافت کارت",
    ),
    "issuanceNoPhysical": MessageLookupByLibrary.simpleMessage(
      "نیازی به دریافت کارت فیزیکی ندارم",
    ),
    "issuanceOperation": MessageLookupByLibrary.simpleMessage("نوع عملیات"),
    "issuanceOtherRecipient": MessageLookupByLibrary.simpleMessage(
      "دریافت توسط شخص دیگر",
    ),
    "issuancePayable": MessageLookupByLibrary.simpleMessage(
      "هزینه قابل پرداخت",
    ),
    "issuancePostalCode": MessageLookupByLibrary.simpleMessage("کد پستی"),
    "issuancePrintFee": MessageLookupByLibrary.simpleMessage("هزینه چاپ گزارش"),
    "issuanceRecipientMobile": MessageLookupByLibrary.simpleMessage(
      "شماره همراه گیرنده",
    ),
    "issuanceRecipientName": MessageLookupByLibrary.simpleMessage(
      "نام و نام خانوادگی گیرنده",
    ),
    "issuanceSaveAddress": MessageLookupByLibrary.simpleMessage("ثبت آدرس"),
    "issuanceSelectAddress": MessageLookupByLibrary.simpleMessage(
      "انتخاب آدرس",
    ),
    "issuanceSelectionTitle": MessageLookupByLibrary.simpleMessage(
      "انتخاب سپرده و نوع صدور کارت",
    ),
    "issuanceStepSemantic": m3,
    "issuanceSubmit": MessageLookupByLibrary.simpleMessage(
      "تایید و ثبت درخواست",
    ),
    "issuanceSubmitError": MessageLookupByLibrary.simpleMessage(
      "ثبت درخواست انجام نشد. دوباره تلاش کنید.",
    ),
    "issuanceSummary": MessageLookupByLibrary.simpleMessage("خلاصه اطلاعات"),
    "issuanceTerms": MessageLookupByLibrary.simpleMessage("قوانین و مقررات"),
    "issuanceTermsPrompt": MessageLookupByLibrary.simpleMessage(
      "درخواست را مطالعه و تایید می‌نمایم.",
    ),
    "issuanceTermsUnavailable": MessageLookupByLibrary.simpleMessage(
      "متن رسمی قوانین پس از اتصال به سرویس نمایش داده می‌شود.",
    ),
    "issuanceTitle": MessageLookupByLibrary.simpleMessage("صدور رسالت کارت"),
    "issuanceType": MessageLookupByLibrary.simpleMessage("نوع صدور کارت"),
    "issuanceTypeHint": MessageLookupByLibrary.simpleMessage(
      "نوع صدور کارت را مشخص کنید",
    ),
    "issuanceWallet": MessageLookupByLibrary.simpleMessage("موجودی کیف پول"),
    "issuanceWalletInsufficient": MessageLookupByLibrary.simpleMessage(
      "موجودی کیف پول کافی نیست",
    ),
    "issuanceWalletSufficient": MessageLookupByLibrary.simpleMessage(
      "موجودی کیف پول کافی است",
    ),
    "issueChequeBook": MessageLookupByLibrary.simpleMessage("صدور دسته چک"),
    "issueResalatCard": MessageLookupByLibrary.simpleMessage("صدور رسالت کارت"),
    "latestUpdatedRequests": MessageLookupByLibrary.simpleMessage(
      "آخرین درخواست‌های بروز شده",
    ),
    "loanEstimate": MessageLookupByLibrary.simpleMessage("برآورد وام"),
    "loanServices": MessageLookupByLibrary.simpleMessage("خدمات وام"),
    "loansChangeDeposit": MessageLookupByLibrary.simpleMessage(
      "تغییر سپرده کسر اقساط",
    ),
    "loansDefaultName": MessageLookupByLibrary.simpleMessage(
      "تسهیلات قرض الحسنه عادی (بدون کارمزد)",
    ),
    "loansEmpty": MessageLookupByLibrary.simpleMessage("هنوز وامی ندارید"),
    "loansOperations": MessageLookupByLibrary.simpleMessage("عملیات وام"),
    "loansPayInstallments": MessageLookupByLibrary.simpleMessage(
      "پرداخت اقساط",
    ),
    "loansRelationships": MessageLookupByLibrary.simpleMessage(
      "روابط سببی نسبی",
    ),
    "loginDescription": MessageLookupByLibrary.simpleMessage(
      "برای ورود به حساب کاربری اطلاعات زیر را وارد کنید",
    ),
    "loginNationalIdHint": MessageLookupByLibrary.simpleMessage(
      "کد ملی | شماره ملی | کد اتباع",
    ),
    "loginPhoneHint": MessageLookupByLibrary.simpleMessage(
      "شماره همراه خود را وارد کنید",
    ),
    "loginTitle": MessageLookupByLibrary.simpleMessage("ورود با کد ملی"),
    "memberContactCenter": MessageLookupByLibrary.simpleMessage(
      "مرکز ارتباط با اعضاء",
    ),
    "mobileBank": MessageLookupByLibrary.simpleMessage("همراه بانک"),
    "mobileBankSettings": MessageLookupByLibrary.simpleMessage(
      "تنظیمات موبایل بانک",
    ),
    "notificationEmpty": MessageLookupByLibrary.simpleMessage("پیامی ندارید"),
    "notificationFiveDays": MessageLookupByLibrary.simpleMessage("۵ روز پیش"),
    "notificationInvestmentSubtitle": MessageLookupByLibrary.simpleMessage(
      "معامله راحت و سریع طلا با تسویه آنی",
    ),
    "notificationInvestmentTitle": MessageLookupByLibrary.simpleMessage(
      "سرمایه گداری تمام عیار",
    ),
    "notificationLoanSubtitle": MessageLookupByLibrary.simpleMessage(
      "وام با وثیقه",
    ),
    "notificationLoanTitle": MessageLookupByLibrary.simpleMessage(
      "با سرمایه خودت وام بگیر",
    ),
    "notificationNew": MessageLookupByLibrary.simpleMessage("پیام‌های جدید"),
    "notificationRead": MessageLookupByLibrary.simpleMessage(
      "پیام‌های خوانده شده",
    ),
    "notificationReadAll": MessageLookupByLibrary.simpleMessage("خواندن همه"),
    "notificationSampleDate": MessageLookupByLibrary.simpleMessage(
      "۱۶ شهريور ۱۴۰۵",
    ),
    "notificationSecurityAdvice": MessageLookupByLibrary.simpleMessage(
      "برای اینکه گیر کلاهبردارها نیفتی و حسابت همیشه امن بمونه، حواست به این چند تا مورد باشه:",
    ),
    "notificationSecurityClosing": MessageLookupByLibrary.simpleMessage(
      "اگه با مورد مشکوکی برخورد کردی، همون لحظه به ما خبر بده تا سریع چکش کنیم.",
    ),
    "notificationSecurityCode": MessageLookupByLibrary.simpleMessage(
      "کد ورودت رو به کسی نده: ما تو تیم پشتیبانی هیچ‌وقت رمز یا کد تاییدی که برات پیامک می‌شه رو ازت نمی‌خوایم.",
    ),
    "notificationSecurityIntro": MessageLookupByLibrary.simpleMessage(
      "سلام! این روزا ممکنه پیام‌هایی از طرف آدمای سودجو به دستتون برسه که خودشون رو جای تیم پشتیبانی جا می‌زنن. برای اینکه حسابتون همیشه امن بمونه، حواستون به این چند تا نکته باشه:",
    ),
    "notificationSecurityLinks": MessageLookupByLibrary.simpleMessage(
      "لینک‌های مشکوک رو باز نکن: اگه پیامی با یه لینک ناشناس برات اومد که می‌گفت «حسابت مسدود شده» یا «برنده شدی»، اصلاً روش کلیک نکن.",
    ),
    "notificationSecurityOfficial": MessageLookupByLibrary.simpleMessage(
      "فقط از راه‌های رسمی در ارتباط باش: همیشه مطمئن شو پیامی که می‌گیری از طرف شماره‌ها یا اکانت‌های رسمی خودمون باشه.",
    ),
    "notificationSecuritySubtitle": MessageLookupByLibrary.simpleMessage(
      "نکاتی برای افزایش امنیت حساب",
    ),
    "notificationSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "مراقب کلاهبرداران باشید⚠️",
    ),
    "notificationSevenDays": MessageLookupByLibrary.simpleMessage("۷ روز پیش"),
    "notificationSubject": MessageLookupByLibrary.simpleMessage("عنوان"),
    "notificationTitle": MessageLookupByLibrary.simpleMessage("اعلانات"),
    "notificationToday": MessageLookupByLibrary.simpleMessage("امروز"),
    "notificationYesterday": MessageLookupByLibrary.simpleMessage("دیروز"),
    "notificationsLabel": MessageLookupByLibrary.simpleMessage("اعلان‌ها"),
    "otpHint": MessageLookupByLibrary.simpleMessage("وارد کردن رمز"),
    "otpSentMessage": m4,
    "otpSentTitle": MessageLookupByLibrary.simpleMessage("کد ارسال شد."),
    "passwordApprovedBody": MessageLookupByLibrary.simpleMessage(
      "پیامک حاوی نام کاربری و رمز ورود به موبایل بانک برای شما ارسال می‌شود. پس از دریافت پیامک شما قادر خواهید بود با نام کاربری و رمزی دریافتی در پیامک به موبایل بانک خود وارد شوید.",
    ),
    "passwordApprovedTitle": MessageLookupByLibrary.simpleMessage(
      "درخواست شما با موفقیت انجام شد",
    ),
    "passwordCameraNotice": MessageLookupByLibrary.simpleMessage(
      "این مرحله نیازمند دوربین و میکروفون است.",
    ),
    "passwordCardNumber": MessageLookupByLibrary.simpleMessage("شماره کارت"),
    "passwordCardNumberHint": MessageLookupByLibrary.simpleMessage(
      "شماره کارت مورد نظر خود را انتخاب کنید",
    ),
    "passwordCardType": MessageLookupByLibrary.simpleMessage("نوع کارت"),
    "passwordCardTypeHint": MessageLookupByLibrary.simpleMessage(
      "نوع کارت خود را انتخاب کنید",
    ),
    "passwordChange": MessageLookupByLibrary.simpleMessage("تغییر رمز عبور"),
    "passwordChangePrompt": MessageLookupByLibrary.simpleMessage(
      "رمز عبور فعلی و رمز جدید دلخواه خود را وارد کنید.",
    ),
    "passwordChangeSubmit": MessageLookupByLibrary.simpleMessage("ثبت درخواست"),
    "passwordChangeSuccessBody": MessageLookupByLibrary.simpleMessage(
      "تغییر رمز شما با موفقیت انجام شد.",
    ),
    "passwordConfirmMock": MessageLookupByLibrary.simpleMessage(
      "تایید نمونه آزمایشی",
    ),
    "passwordConfirmationHint": MessageLookupByLibrary.simpleMessage(
      "تکرار رمز عبور",
    ),
    "passwordCurrentHint": MessageLookupByLibrary.simpleMessage(
      "رمز عبور فعلی",
    ),
    "passwordDateRule": MessageLookupByLibrary.simpleMessage(
      "تاریخ معنادار نباشد (تاریخ تولد، تاریخ انقضای کارت)",
    ),
    "passwordDemoVideo": MessageLookupByLibrary.simpleMessage(
      "ویدئوی نمونه: Big Buck Bunny — Blender Foundation (CC BY 3.0)",
    ),
    "passwordExit": MessageLookupByLibrary.simpleMessage("خروج"),
    "passwordExitBody": MessageLookupByLibrary.simpleMessage(
      "اطلاعات واردشده پاک می‌شود.",
    ),
    "passwordExitTitle": MessageLookupByLibrary.simpleMessage(
      "خروج از عملیات رمز؟",
    ),
    "passwordFirst": MessageLookupByLibrary.simpleMessage("رمز اول"),
    "passwordFirstDescription": MessageLookupByLibrary.simpleMessage(
      "این رمز برای انجام تراکنش‌های حضوری مانند برداشت وجه از خودپرداز و خرید از فروشگاه‌ها با دستگاه پوز استفاده می‌شود.",
    ),
    "passwordForgot": MessageLookupByLibrary.simpleMessage("فراموشی رمز عبور"),
    "passwordHide": MessageLookupByLibrary.simpleMessage("پنهان کردن رمز"),
    "passwordInstructionPrompt": MessageLookupByLibrary.simpleMessage(
      "پس از دیدن ویدئو آموزشی مراحل احراز هویت شما شروع می‌شود.",
    ),
    "passwordLengthRule": MessageLookupByLibrary.simpleMessage(
      "شامل ۴ تا ۶ عدد باشد",
    ),
    "passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "رمز عبور و تکرار آن یکسان نیست.",
    ),
    "passwordMockKyc": MessageLookupByLibrary.simpleMessage(
      "ضبط و احراز هویت آزمایشی است؛ هیچ ویدئویی از شما ثبت نمی‌شود.",
    ),
    "passwordMockReceipt": MessageLookupByLibrary.simpleMessage(
      "این نتیجه آزمایشی است؛ رمز بانکی تنظیم نشده و پیامکی ارسال نمی‌شود.",
    ),
    "passwordNewConfirmationHint": MessageLookupByLibrary.simpleMessage(
      "تکرار رمز عبور جدید",
    ),
    "passwordNewHint": MessageLookupByLibrary.simpleMessage("رمز عبور جدید"),
    "passwordOperation": MessageLookupByLibrary.simpleMessage("نوع عملیات"),
    "passwordOperationHint": MessageLookupByLibrary.simpleMessage(
      "نوع عملیات را مشخص کنید",
    ),
    "passwordPatternRule": MessageLookupByLibrary.simpleMessage(
      "شامل اعداد متوالی یا تکراری نباشد",
    ),
    "passwordPause": MessageLookupByLibrary.simpleMessage("توقف ویدئو"),
    "passwordPendingBody": MessageLookupByLibrary.simpleMessage(
      "• پس از مشخص شدن نتیجه اعتبارسنجی، در صورت تایید هویت پیامک حاوی اطلاعات رمز برای شما ارسال می‌شود.\n• در صورت تایید اعتبارسنجی شما می‌توانید در همین مدت، از سایر خدمات پیشخوان که مستلزم احراز هویت هستند بدون پرداخت مجدد استفاده کنید.",
    ),
    "passwordPendingTitle": MessageLookupByLibrary.simpleMessage(
      "شما یک درخواست اعتبارسنجی باز دارید",
    ),
    "passwordPlay": MessageLookupByLibrary.simpleMessage("پخش ویدئو"),
    "passwordPrompt": MessageLookupByLibrary.simpleMessage(
      "رمز دوم دلخواه خود را وارد کنید.",
    ),
    "passwordRecordAgain": MessageLookupByLibrary.simpleMessage("ضبط مجدد"),
    "passwordRecordingPrompt": MessageLookupByLibrary.simpleMessage(
      "در صورت تایید ویدئو درخواست خود را ثبت کنید.",
    ),
    "passwordSecond": MessageLookupByLibrary.simpleMessage("رمز دوم"),
    "passwordSecondDescription": MessageLookupByLibrary.simpleMessage(
      "این رمز برای انجام تراکنش‌های آنلاین و اینترنتی زیر ۱۰۰ هزار تومان به کار می‌رود.",
    ),
    "passwordSeek": MessageLookupByLibrary.simpleMessage("موقعیت پخش"),
    "passwordSelectionPrompt": MessageLookupByLibrary.simpleMessage(
      "کارت مورد نظر و نوع رمز را انتخاب کنید",
    ),
    "passwordSerialError": MessageLookupByLibrary.simpleMessage(
      "سریال معتبر شامل عدد و یک حرف لاتین وارد کنید.",
    ),
    "passwordSerialHelper": MessageLookupByLibrary.simpleMessage(
      "شامل عدد و یک حرف لاتین می‌باشد",
    ),
    "passwordSerialHint": MessageLookupByLibrary.simpleMessage(
      "سریال پشت کارت ملی | کد پیگیری رسید کارت ملی",
    ),
    "passwordSerialPrompt": MessageLookupByLibrary.simpleMessage(
      "سریال درج شده پشت کارت ملی یا کد پیگیری رسید کارت ملی خود را وارد کنید.",
    ),
    "passwordSetSecond": MessageLookupByLibrary.simpleMessage("تعیین رمز دوم"),
    "passwordShow": MessageLookupByLibrary.simpleMessage("نمایش رمز"),
    "passwordStartKyc": MessageLookupByLibrary.simpleMessage("شروع احراز هویت"),
    "passwordStatusRegisteredTitle": MessageLookupByLibrary.simpleMessage(
      "درخواست شما با موفقیت ثبت شد.",
    ),
    "passwordStay": MessageLookupByLibrary.simpleMessage("ادامه عملیات"),
    "passwordSubmit": MessageLookupByLibrary.simpleMessage(
      "ارسال و ثبت درخواست",
    ),
    "passwordSubmittedBody": MessageLookupByLibrary.simpleMessage(
      "پس از مشخص شدن نتیجه اعتبارسنجی، در صورت تایید هویت پیامک حاوی نام کاربری و رمز ورود به موبایل بانک برای شما ارسال می‌شود. پس از دریافت پیامک شما قادر خواهید بود با نام کاربری و رمزی دریافتی در پیامک به موبایل بانک خود وارد شوید.",
    ),
    "passwordSubmittedTitle": MessageLookupByLibrary.simpleMessage(
      "درخواست شما ارسال شد",
    ),
    "passwordTitle": MessageLookupByLibrary.simpleMessage("عملیات رمز"),
    "passwordTracking": MessageLookupByLibrary.simpleMessage("کد پیگیری"),
    "passwordType": MessageLookupByLibrary.simpleMessage("نوع رمز"),
    "passwordTypeHint": MessageLookupByLibrary.simpleMessage(
      "نوع رمز را انتخاب کنید",
    ),
    "passwordUnderstood": MessageLookupByLibrary.simpleMessage("متوجه شدم"),
    "passwordUnsupported": MessageLookupByLibrary.simpleMessage(
      "این عملیات برای کارت انتخاب‌شده در دسترس نیست.",
    ),
    "passwordValueHint": MessageLookupByLibrary.simpleMessage("رمز عبور"),
    "passwordVideoUnavailable": MessageLookupByLibrary.simpleMessage(
      "ویدئو در دسترس نیست",
    ),
    "phoneOwnershipNotice": MessageLookupByLibrary.simpleMessage(
      "شماره باید با کد ملی دارنده حساب مطابقت داشته باشد",
    ),
    "profileLabel": MessageLookupByLibrary.simpleMessage("پروفایل"),
    "proxyAmount": MessageLookupByLibrary.simpleMessage("مبلغ"),
    "proxyAmountToman": m5,
    "proxyBroker": MessageLookupByLibrary.simpleMessage("کارگزار"),
    "proxyCompany": MessageLookupByLibrary.simpleMessage("شرکت"),
    "proxyCompanyHint": MessageLookupByLibrary.simpleMessage(
      "شرکت مورد نظر را انتخاب کنید",
    ),
    "proxyDeposit": MessageLookupByLibrary.simpleMessage("سپرده وکالتی"),
    "proxyDepositHint": MessageLookupByLibrary.simpleMessage(
      "سپرده خود را انتخاب کنید",
    ),
    "proxyDepositMockComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست سپرده وکالتی به صورت آزمایشی ثبت شد. هیچ وکالت یا مسدودی مبلغ واقعی ایجاد نشده است.",
    ),
    "proxySubject": MessageLookupByLibrary.simpleMessage("موضوع"),
    "proxySubjectHint": MessageLookupByLibrary.simpleMessage(
      "موضوع سپرده وکالتی را انتخاب کنید",
    ),
    "refreshCaptcha": MessageLookupByLibrary.simpleMessage(
      "تازه‌سازی کد امنیتی",
    ),
    "relatedLinks": MessageLookupByLibrary.simpleMessage("لینک‌های مرتبط"),
    "requestIdentifier": MessageLookupByLibrary.simpleMessage("شناسه درخواست"),
    "requestOtp": MessageLookupByLibrary.simpleMessage("درخواست ارسال رمز"),
    "requestStatus": MessageLookupByLibrary.simpleMessage("وضعیت درخواست"),
    "requestTwoFactorCode": MessageLookupByLibrary.simpleMessage(
      "درخواست کد دو عاملی",
    ),
    "resalatApp": MessageLookupByLibrary.simpleMessage("ام رسالت"),
    "resendOtp": MessageLookupByLibrary.simpleMessage("ارسال مجدد"),
    "rialCurrency": MessageLookupByLibrary.simpleMessage("ریال"),
    "securityTips": MessageLookupByLibrary.simpleMessage("نکات امنیتی"),
    "selectedServices": MessageLookupByLibrary.simpleMessage("خدمات منتخب"),
    "servicesList": MessageLookupByLibrary.simpleMessage("لیست خدمات"),
    "servicesMenuLabel": MessageLookupByLibrary.simpleMessage("فهرست خدمات"),
    "smsSettings": MessageLookupByLibrary.simpleMessage("تنظیمات ارسال پیامک"),
    "submitRequest": MessageLookupByLibrary.simpleMessage("ثبت درخواست"),
    "surplusDepositsDescription": MessageLookupByLibrary.simpleMessage(
      "سپرده‌ای که می‌خواهید به عنوان سپرده اصلی شما باقی بماند را انتخاب کنید. سپرده‌های مازاد شما بسته و موجودی و سایر موارد مرتبط با آن‌ها به سپرده منتخب شما منتقل می‌گردد.",
    ),
    "surplusDepositsEmptyBody": MessageLookupByLibrary.simpleMessage(
      "شما دارای سپرده قرض الحسنه پس‌انداز حقیقی انفرادی مازاد نمی‌باشید",
    ),
    "surplusDepositsEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "نتیجه‌ای یافت نشد",
    ),
    "surplusDepositsMockComplete": MessageLookupByLibrary.simpleMessage(
      "درخواست بستن سپرده‌ها به صورت آزمایشی ثبت شد. هیچ سپرده یا موجودی واقعی تغییر نکرده است.",
    ),
    "surplusDepositsReviewTitle": MessageLookupByLibrary.simpleMessage(
      "سپرده‌های مازاد شما",
    ),
    "surplusDepositsSubmit": MessageLookupByLibrary.simpleMessage(
      "تایید و ثبت درخواست",
    ),
    "surplusDepositsTitle": MessageLookupByLibrary.simpleMessage(
      "بستن سپرده مازاد",
    ),
    "surplusPrimaryDeposit": MessageLookupByLibrary.simpleMessage("سپرده اصلی"),
    "surplusPrimaryDepositHint": MessageLookupByLibrary.simpleMessage(
      "سپرده اصلی خود را انتخاب کنید",
    ),
    "updateGuide": MessageLookupByLibrary.simpleMessage("راهنمای بروزرسانی"),
    "virtualRequestCount": MessageLookupByLibrary.simpleMessage(
      "تعداد کارت مجازی",
    ),
    "virtualRequestCountError": m6,
    "virtualRequestCountHint": MessageLookupByLibrary.simpleMessage(
      "تعداد کارت مجازی مورد نیاز خود را وارد کنید",
    ),
    "virtualRequestDepositHint": MessageLookupByLibrary.simpleMessage(
      "سپرده مورد نظر خود را انتخاب کنید",
    ),
    "virtualRequestDepositLabel": MessageLookupByLibrary.simpleMessage("سپرده"),
    "virtualRequestEmpty": MessageLookupByLibrary.simpleMessage(
      "هیچ سپرده‌ای برای صدور کارت مجازی موجود نیست.",
    ),
    "virtualRequestFeeNotice": m7,
    "virtualRequestMockReceipt": MessageLookupByLibrary.simpleMessage(
      "درخواست آزمایشی ثبت شد؛ کارت مجازی ایجاد نشده و مبلغی پرداخت نمی‌شود.",
    ),
    "virtualRequestNotice": MessageLookupByLibrary.simpleMessage(
      "کارت مجازی فاقد فیزیک بوده و تنها یک شماره می باشد که می توان به آن شماره فقط واریز وجه انجام داد و برداشت یا خرید با این کارت امکان پذیر نمیباشد.",
    ),
    "virtualRequestPrompt": MessageLookupByLibrary.simpleMessage(
      "سپرده‌ی موردنظر برای صدور کارت مجازی و تعداد کارت مجازی را انتخاب کنید و مراحل را ادامه دهید.",
    ),
    "virtualRequestQuoting": MessageLookupByLibrary.simpleMessage(
      "در حال دریافت هزینه درخواست…",
    ),
    "virtualRequestReceipt": MessageLookupByLibrary.simpleMessage(
      "کد پیگیری درخواست:",
    ),
    "virtualRequestSubmit": MessageLookupByLibrary.simpleMessage(
      "تایید و ثبت درخواست",
    ),
    "virtualRequestSubmitted": MessageLookupByLibrary.simpleMessage(
      "درخواست ثبت شد",
    ),
    "virtualRequestTitle": MessageLookupByLibrary.simpleMessage(
      "درخواست کارت مجازی",
    ),
    "virtualRequestUnitFee": MessageLookupByLibrary.simpleMessage(
      "کارمزد صدور هر کارت",
    ),
    "walletBalanceTitle": MessageLookupByLibrary.simpleMessage(
      "موجودی کیف پول",
    ),
  };
}
