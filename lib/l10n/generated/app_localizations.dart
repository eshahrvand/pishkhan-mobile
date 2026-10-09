import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fa, this message translates to:
  /// **'پیشخوان مجازی رسالت'**
  String get appTitle;

  /// No description provided for @changeMobileTitle.
  ///
  /// In fa, this message translates to:
  /// **'تغییر شماره همراه'**
  String get changeMobileTitle;

  /// No description provided for @backLabel.
  ///
  /// In fa, this message translates to:
  /// **'بازگشت'**
  String get backLabel;

  /// No description provided for @closeLabel.
  ///
  /// In fa, this message translates to:
  /// **'بستن'**
  String get closeLabel;

  /// No description provided for @servicesMenuLabel.
  ///
  /// In fa, this message translates to:
  /// **'فهرست خدمات'**
  String get servicesMenuLabel;

  /// No description provided for @changeMobileDescription.
  ///
  /// In fa, this message translates to:
  /// **'برای تغییر شماره همراه ورود به پیشخوان اطلاعات زیر را وارد کنید'**
  String get changeMobileDescription;

  /// No description provided for @loginTitle.
  ///
  /// In fa, this message translates to:
  /// **'ورود با کد ملی'**
  String get loginTitle;

  /// No description provided for @loginNationalIdHint.
  ///
  /// In fa, this message translates to:
  /// **'کد ملی | شماره ملی | کد اتباع'**
  String get loginNationalIdHint;

  /// No description provided for @changeNationalIdHint.
  ///
  /// In fa, this message translates to:
  /// **'کد ملی | شماره ملی خود را وارد کنید'**
  String get changeNationalIdHint;

  /// No description provided for @loginPhoneHint.
  ///
  /// In fa, this message translates to:
  /// **'شماره همراه خود را وارد کنید'**
  String get loginPhoneHint;

  /// No description provided for @changePhoneHint.
  ///
  /// In fa, this message translates to:
  /// **'شماره همراه جدید خود را وارد کنید'**
  String get changePhoneHint;

  /// No description provided for @changePhoneAction.
  ///
  /// In fa, this message translates to:
  /// **'تغییر شماره همراه'**
  String get changePhoneAction;

  /// No description provided for @requestTwoFactorCode.
  ///
  /// In fa, this message translates to:
  /// **'درخواست کد دو عاملی'**
  String get requestTwoFactorCode;

  /// No description provided for @requestOtp.
  ///
  /// In fa, this message translates to:
  /// **'درخواست ارسال رمز'**
  String get requestOtp;

  /// No description provided for @phoneOwnershipNotice.
  ///
  /// In fa, this message translates to:
  /// **'شماره باید با کد ملی دارنده حساب مطابقت داشته باشد'**
  String get phoneOwnershipNotice;

  /// No description provided for @captchaHint.
  ///
  /// In fa, this message translates to:
  /// **'کد روبرو را وارد کنید'**
  String get captchaHint;

  /// No description provided for @otpSentMessage.
  ///
  /// In fa, this message translates to:
  /// **'رمز پویای ارسال شده به شماره {phone} را وارد کنید.'**
  String otpSentMessage(String phone);

  /// No description provided for @otpHint.
  ///
  /// In fa, this message translates to:
  /// **'وارد کردن رمز'**
  String get otpHint;

  /// No description provided for @submitRequest.
  ///
  /// In fa, this message translates to:
  /// **'ثبت درخواست'**
  String get submitRequest;

  /// No description provided for @enterDashboard.
  ///
  /// In fa, this message translates to:
  /// **'ورود به پیشخوان'**
  String get enterDashboard;

  /// No description provided for @resendOtp.
  ///
  /// In fa, this message translates to:
  /// **'ارسال مجدد'**
  String get resendOtp;

  /// No description provided for @servicesList.
  ///
  /// In fa, this message translates to:
  /// **'لیست خدمات'**
  String get servicesList;

  /// No description provided for @guestServices.
  ///
  /// In fa, this message translates to:
  /// **'خدمات بدون نیاز به لاگین'**
  String get guestServices;

  /// No description provided for @assetReport.
  ///
  /// In fa, this message translates to:
  /// **'گزارش تمکن'**
  String get assetReport;

  /// No description provided for @changeMobileService.
  ///
  /// In fa, this message translates to:
  /// **'تغییر تلفن همراه'**
  String get changeMobileService;

  /// No description provided for @requestStatus.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت درخواست'**
  String get requestStatus;

  /// No description provided for @inheritance.
  ///
  /// In fa, this message translates to:
  /// **'انحصار وراثت'**
  String get inheritance;

  /// No description provided for @relatedLinks.
  ///
  /// In fa, this message translates to:
  /// **'لینک‌های مرتبط'**
  String get relatedLinks;

  /// No description provided for @mobileBank.
  ///
  /// In fa, this message translates to:
  /// **'همراه بانک'**
  String get mobileBank;

  /// No description provided for @internetBank.
  ///
  /// In fa, this message translates to:
  /// **'اینترنت بانک'**
  String get internetBank;

  /// No description provided for @memberContactCenter.
  ///
  /// In fa, this message translates to:
  /// **'مرکز ارتباط با اعضاء'**
  String get memberContactCenter;

  /// No description provided for @resalatApp.
  ///
  /// In fa, this message translates to:
  /// **'ام رسالت'**
  String get resalatApp;

  /// No description provided for @securityTips.
  ///
  /// In fa, this message translates to:
  /// **'نکات امنیتی'**
  String get securityTips;

  /// No description provided for @updateGuide.
  ///
  /// In fa, this message translates to:
  /// **'راهنمای بروزرسانی'**
  String get updateGuide;

  /// No description provided for @dashboardGreeting.
  ///
  /// In fa, this message translates to:
  /// **'مانی عزیز، صبح بخیر'**
  String get dashboardGreeting;

  /// No description provided for @dashboardWelcomeMessage.
  ///
  /// In fa, this message translates to:
  /// **'به پیشخوان مجازی رسالت خوش آمدید'**
  String get dashboardWelcomeMessage;

  /// No description provided for @walletBalanceTitle.
  ///
  /// In fa, this message translates to:
  /// **'موجودی کیف پول'**
  String get walletBalanceTitle;

  /// No description provided for @rialCurrency.
  ///
  /// In fa, this message translates to:
  /// **'ریال'**
  String get rialCurrency;

  /// No description provided for @dashboardWalletBalance.
  ///
  /// In fa, this message translates to:
  /// **'۱٬۲۰۰٬۰۰۰'**
  String get dashboardWalletBalance;

  /// No description provided for @depositServices.
  ///
  /// In fa, this message translates to:
  /// **'خدمات سپرده'**
  String get depositServices;

  /// No description provided for @smsSettings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات ارسال پیامک'**
  String get smsSettings;

  /// No description provided for @introduceRepresentative.
  ///
  /// In fa, this message translates to:
  /// **'معرفی نماینده'**
  String get introduceRepresentative;

  /// No description provided for @financialCertificate.
  ///
  /// In fa, this message translates to:
  /// **'گواهی تمکن مالی'**
  String get financialCertificate;

  /// No description provided for @balanceAverageStatement.
  ///
  /// In fa, this message translates to:
  /// **'صورتحساب، معدل موجودی'**
  String get balanceAverageStatement;

  /// No description provided for @cardServices.
  ///
  /// In fa, this message translates to:
  /// **'خدمات کارت'**
  String get cardServices;

  /// No description provided for @blockCard.
  ///
  /// In fa, this message translates to:
  /// **'مسدودی کارت'**
  String get blockCard;

  /// No description provided for @changeCardDeposit.
  ///
  /// In fa, this message translates to:
  /// **'تغییر سپرده متصل به کارت'**
  String get changeCardDeposit;

  /// No description provided for @cardPasswordIssue.
  ///
  /// In fa, this message translates to:
  /// **'صدور رمز اول /دوم کارت'**
  String get cardPasswordIssue;

  /// No description provided for @issueResalatCard.
  ///
  /// In fa, this message translates to:
  /// **'صدور رسالت کارت'**
  String get issueResalatCard;

  /// No description provided for @loanServices.
  ///
  /// In fa, this message translates to:
  /// **'خدمات وام'**
  String get loanServices;

  /// No description provided for @changeInstallmentDeposit.
  ///
  /// In fa, this message translates to:
  /// **'تغییر سپرده جهت کسر اقساط'**
  String get changeInstallmentDeposit;

  /// No description provided for @consolidateDepositCredit.
  ///
  /// In fa, this message translates to:
  /// **'تجمیع اعتبار سپرده'**
  String get consolidateDepositCredit;

  /// No description provided for @introduceLoan.
  ///
  /// In fa, this message translates to:
  /// **'معرفی وام'**
  String get introduceLoan;

  /// No description provided for @loanEstimate.
  ///
  /// In fa, this message translates to:
  /// **'برآورد وام'**
  String get loanEstimate;

  /// No description provided for @selectedServices.
  ///
  /// In fa, this message translates to:
  /// **'خدمات منتخب'**
  String get selectedServices;

  /// No description provided for @proxyDeposit.
  ///
  /// In fa, this message translates to:
  /// **'سپرده وکالتی'**
  String get proxyDeposit;

  /// No description provided for @issueChequeBook.
  ///
  /// In fa, this message translates to:
  /// **'صدور دسته چک'**
  String get issueChequeBook;

  /// No description provided for @internetBankSettings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات اینترنت بانک'**
  String get internetBankSettings;

  /// No description provided for @mobileBankSettings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات موبایل بانک'**
  String get mobileBankSettings;

  /// No description provided for @latestUpdatedRequests.
  ///
  /// In fa, this message translates to:
  /// **'آخرین درخواست‌های بروز شده'**
  String get latestUpdatedRequests;

  /// No description provided for @dashboardRequestTitle.
  ///
  /// In fa, this message translates to:
  /// **'درخواست تغییر سپرده جهت کسر اقساط'**
  String get dashboardRequestTitle;

  /// No description provided for @requestIdentifier.
  ///
  /// In fa, this message translates to:
  /// **'شناسه درخواست'**
  String get requestIdentifier;

  /// No description provided for @automaticCompleted.
  ///
  /// In fa, this message translates to:
  /// **'انجام شده خودکار'**
  String get automaticCompleted;

  /// No description provided for @dashboardRequestNumber.
  ///
  /// In fa, this message translates to:
  /// **'۱۳۷/۴۸۷۵۶۷'**
  String get dashboardRequestNumber;

  /// No description provided for @dashboardRequestDate.
  ///
  /// In fa, this message translates to:
  /// **'2024/09/16 | ۱۲:۴۵'**
  String get dashboardRequestDate;

  /// No description provided for @profileLabel.
  ///
  /// In fa, this message translates to:
  /// **'پروفایل'**
  String get profileLabel;

  /// No description provided for @notificationsLabel.
  ///
  /// In fa, this message translates to:
  /// **'اعلان‌ها'**
  String get notificationsLabel;

  /// No description provided for @dashboardAssistant.
  ///
  /// In fa, this message translates to:
  /// **'دستیار هوشمند'**
  String get dashboardAssistant;

  /// No description provided for @dashboardResoTitle.
  ///
  /// In fa, this message translates to:
  /// **'به رِسو بسپار!'**
  String get dashboardResoTitle;

  /// No description provided for @dashboardResoDescription.
  ///
  /// In fa, this message translates to:
  /// **'رِسو فقط جواب نمی‌ده؛ خودش دست‌به‌کار می‌شه.'**
  String get dashboardResoDescription;

  /// No description provided for @dashboardPromptHint.
  ///
  /// In fa, this message translates to:
  /// **'سوالت رو بنویس...'**
  String get dashboardPromptHint;

  /// No description provided for @dashboardSendPrompt.
  ///
  /// In fa, this message translates to:
  /// **'ارسال سوال'**
  String get dashboardSendPrompt;

  /// No description provided for @dashboardBankServices.
  ///
  /// In fa, this message translates to:
  /// **'خدمات بانک رسالت'**
  String get dashboardBankServices;

  /// No description provided for @dashboardCustomize.
  ///
  /// In fa, this message translates to:
  /// **'تنظیم خدمات منتخب'**
  String get dashboardCustomize;

  /// No description provided for @dashboardYourFavorites.
  ///
  /// In fa, this message translates to:
  /// **'منتخب شما'**
  String get dashboardYourFavorites;

  /// No description provided for @dashboardFavoritesLimit.
  ///
  /// In fa, this message translates to:
  /// **'حداکثر ۸ تا مورد رو می‌تونی انتخاب کنی.'**
  String get dashboardFavoritesLimit;

  /// No description provided for @dashboardAddService.
  ///
  /// In fa, this message translates to:
  /// **'افزودن مورد جدید'**
  String get dashboardAddService;

  /// No description provided for @dashboardRemoveService.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get dashboardRemoveService;

  /// No description provided for @dashboardConfirm.
  ///
  /// In fa, this message translates to:
  /// **'تایید'**
  String get dashboardConfirm;

  /// No description provided for @dashboardCancel.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get dashboardCancel;

  /// No description provided for @dashboardResetTitle.
  ///
  /// In fa, this message translates to:
  /// **'بازنشانی تنظیمات'**
  String get dashboardResetTitle;

  /// No description provided for @dashboardResetDescription.
  ///
  /// In fa, this message translates to:
  /// **'با بازنشانی تنظیمات، همه تغییراتت از بین می‌ره و به حالت اولیه برمی‌گرده.\nمطمئنی می‌خوای به تنظیمات اولیه برگردی؟'**
  String get dashboardResetDescription;

  /// No description provided for @dashboardResetConfirm.
  ///
  /// In fa, this message translates to:
  /// **'بازنشانی تنظیمات'**
  String get dashboardResetConfirm;

  /// No description provided for @dashboardSearchHint.
  ///
  /// In fa, this message translates to:
  /// **'جستجو'**
  String get dashboardSearchHint;

  /// No description provided for @dashboardNoServices.
  ///
  /// In fa, this message translates to:
  /// **'خدمتی پیدا نشد'**
  String get dashboardNoServices;

  /// No description provided for @dashboardTab.
  ///
  /// In fa, this message translates to:
  /// **'داشبورد'**
  String get dashboardTab;

  /// No description provided for @dashboardCardsTab.
  ///
  /// In fa, this message translates to:
  /// **'کارت'**
  String get dashboardCardsTab;

  /// No description provided for @dashboardDepositsTab.
  ///
  /// In fa, this message translates to:
  /// **'سپرده'**
  String get dashboardDepositsTab;

  /// No description provided for @dashboardLoansTab.
  ///
  /// In fa, this message translates to:
  /// **'وام'**
  String get dashboardLoansTab;

  /// No description provided for @notificationTitle.
  ///
  /// In fa, this message translates to:
  /// **'اعلانات'**
  String get notificationTitle;

  /// No description provided for @notificationReadAll.
  ///
  /// In fa, this message translates to:
  /// **'خواندن همه'**
  String get notificationReadAll;

  /// No description provided for @notificationNew.
  ///
  /// In fa, this message translates to:
  /// **'پیام‌های جدید'**
  String get notificationNew;

  /// No description provided for @notificationRead.
  ///
  /// In fa, this message translates to:
  /// **'پیام‌های خوانده شده'**
  String get notificationRead;

  /// No description provided for @notificationSubject.
  ///
  /// In fa, this message translates to:
  /// **'عنوان'**
  String get notificationSubject;

  /// No description provided for @notificationEmpty.
  ///
  /// In fa, this message translates to:
  /// **'پیامی ندارید'**
  String get notificationEmpty;

  /// No description provided for @notificationToday.
  ///
  /// In fa, this message translates to:
  /// **'امروز'**
  String get notificationToday;

  /// No description provided for @notificationYesterday.
  ///
  /// In fa, this message translates to:
  /// **'دیروز'**
  String get notificationYesterday;

  /// No description provided for @notificationFiveDays.
  ///
  /// In fa, this message translates to:
  /// **'۵ روز پیش'**
  String get notificationFiveDays;

  /// No description provided for @notificationSevenDays.
  ///
  /// In fa, this message translates to:
  /// **'۷ روز پیش'**
  String get notificationSevenDays;

  /// No description provided for @notificationSampleDate.
  ///
  /// In fa, this message translates to:
  /// **'۱۶ شهريور ۱۴۰۵'**
  String get notificationSampleDate;

  /// No description provided for @notificationLoanTitle.
  ///
  /// In fa, this message translates to:
  /// **'با سرمایه خودت وام بگیر'**
  String get notificationLoanTitle;

  /// No description provided for @notificationLoanSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'وام با وثیقه'**
  String get notificationLoanSubtitle;

  /// No description provided for @notificationInvestmentTitle.
  ///
  /// In fa, this message translates to:
  /// **'سرمایه گداری تمام عیار'**
  String get notificationInvestmentTitle;

  /// No description provided for @notificationInvestmentSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'معامله راحت و سریع طلا با تسویه آنی'**
  String get notificationInvestmentSubtitle;

  /// No description provided for @notificationSecurityTitle.
  ///
  /// In fa, this message translates to:
  /// **'مراقب کلاهبرداران باشید⚠️'**
  String get notificationSecurityTitle;

  /// No description provided for @notificationSecuritySubtitle.
  ///
  /// In fa, this message translates to:
  /// **'نکاتی برای افزایش امنیت حساب'**
  String get notificationSecuritySubtitle;

  /// No description provided for @notificationSecurityIntro.
  ///
  /// In fa, this message translates to:
  /// **'سلام! این روزا ممکنه پیام‌هایی از طرف آدمای سودجو به دستتون برسه که خودشون رو جای تیم پشتیبانی جا می‌زنن. برای اینکه حسابتون همیشه امن بمونه، حواستون به این چند تا نکته باشه:'**
  String get notificationSecurityIntro;

  /// No description provided for @notificationSecurityAdvice.
  ///
  /// In fa, this message translates to:
  /// **'برای اینکه گیر کلاهبردارها نیفتی و حسابت همیشه امن بمونه، حواست به این چند تا مورد باشه:'**
  String get notificationSecurityAdvice;

  /// No description provided for @notificationSecurityCode.
  ///
  /// In fa, this message translates to:
  /// **'کد ورودت رو به کسی نده: ما تو تیم پشتیبانی هیچ‌وقت رمز یا کد تاییدی که برات پیامک می‌شه رو ازت نمی‌خوایم.'**
  String get notificationSecurityCode;

  /// No description provided for @notificationSecurityLinks.
  ///
  /// In fa, this message translates to:
  /// **'لینک‌های مشکوک رو باز نکن: اگه پیامی با یه لینک ناشناس برات اومد که می‌گفت «حسابت مسدود شده» یا «برنده شدی»، اصلاً روش کلیک نکن.'**
  String get notificationSecurityLinks;

  /// No description provided for @notificationSecurityOfficial.
  ///
  /// In fa, this message translates to:
  /// **'فقط از راه‌های رسمی در ارتباط باش: همیشه مطمئن شو پیامی که می‌گیری از طرف شماره‌ها یا اکانت‌های رسمی خودمون باشه.'**
  String get notificationSecurityOfficial;

  /// No description provided for @notificationSecurityClosing.
  ///
  /// In fa, this message translates to:
  /// **'اگه با مورد مشکوکی برخورد کردی، همون لحظه به ما خبر بده تا سریع چکش کنیم.'**
  String get notificationSecurityClosing;

  /// No description provided for @loginDescription.
  ///
  /// In fa, this message translates to:
  /// **'برای ورود به حساب کاربری اطلاعات زیر را وارد کنید'**
  String get loginDescription;

  /// No description provided for @otpSentTitle.
  ///
  /// In fa, this message translates to:
  /// **'کد ارسال شد.'**
  String get otpSentTitle;

  /// No description provided for @refreshCaptcha.
  ///
  /// In fa, this message translates to:
  /// **'تازه‌سازی کد امنیتی'**
  String get refreshCaptcha;

  /// No description provided for @authInvalidNationalId.
  ///
  /// In fa, this message translates to:
  /// **'کد ملی ۱۰ رقمی را وارد کنید'**
  String get authInvalidNationalId;

  /// No description provided for @authInvalidPhone.
  ///
  /// In fa, this message translates to:
  /// **'شماره همراه ۱۱ رقمی با ۰۹ را وارد کنید'**
  String get authInvalidPhone;

  /// No description provided for @authInvalidCaptcha.
  ///
  /// In fa, this message translates to:
  /// **'کد امنیتی ۶ رقمی را وارد کنید'**
  String get authInvalidCaptcha;

  /// No description provided for @dashboardModernBanking.
  ///
  /// In fa, this message translates to:
  /// **'بانکداری مدرن'**
  String get dashboardModernBanking;

  /// No description provided for @dashboardChequeServices.
  ///
  /// In fa, this message translates to:
  /// **'چک'**
  String get dashboardChequeServices;

  /// No description provided for @dashboardTransferServices.
  ///
  /// In fa, this message translates to:
  /// **'انتقال وجه'**
  String get dashboardTransferServices;

  /// No description provided for @dashboardWalletServices.
  ///
  /// In fa, this message translates to:
  /// **'کیف پول'**
  String get dashboardWalletServices;

  /// No description provided for @dashboardIdentityServices.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات فردی'**
  String get dashboardIdentityServices;

  /// No description provided for @dashboardRequestServices.
  ///
  /// In fa, this message translates to:
  /// **'درخواست‌های من'**
  String get dashboardRequestServices;

  /// No description provided for @dashboardAllServices.
  ///
  /// In fa, this message translates to:
  /// **'همه خدمات'**
  String get dashboardAllServices;

  /// No description provided for @dashboardViewAll.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده همه'**
  String get dashboardViewAll;

  /// No description provided for @dashboardEdit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش'**
  String get dashboardEdit;

  /// No description provided for @dashboardAddFavorites.
  ///
  /// In fa, this message translates to:
  /// **'افزودن خدمات منتخب'**
  String get dashboardAddFavorites;

  /// No description provided for @dashboardManageInstallments.
  ///
  /// In fa, this message translates to:
  /// **'مدیریت کسر اقساط'**
  String get dashboardManageInstallments;

  /// No description provided for @dashboardEstimateCredit.
  ///
  /// In fa, this message translates to:
  /// **'برآورد اعتبار وام'**
  String get dashboardEstimateCredit;

  /// No description provided for @dashboardPromptCertificate.
  ///
  /// In fa, this message translates to:
  /// **'گواهی تمکن مالی می‌خوام...'**
  String get dashboardPromptCertificate;

  /// No description provided for @dashboardPromptCard.
  ///
  /// In fa, this message translates to:
  /// **'چطور کارت رسالت بگیرم؟'**
  String get dashboardPromptCard;

  /// No description provided for @dashboardPhoneBank.
  ///
  /// In fa, this message translates to:
  /// **'تلفن بانک'**
  String get dashboardPhoneBank;

  /// No description provided for @dashboardCardsList.
  ///
  /// In fa, this message translates to:
  /// **'لیست کارت‌ها'**
  String get dashboardCardsList;

  /// No description provided for @dashboardVirtualCard.
  ///
  /// In fa, this message translates to:
  /// **'درخواست کارت مجازی'**
  String get dashboardVirtualCard;

  /// No description provided for @dashboardUnblockCard.
  ///
  /// In fa, this message translates to:
  /// **'رفع مسدودی کارت'**
  String get dashboardUnblockCard;

  /// No description provided for @dashboardExpiredGift.
  ///
  /// In fa, this message translates to:
  /// **'واریز مانده کارت هدیه منقضی'**
  String get dashboardExpiredGift;

  /// No description provided for @dashboardClearCheque.
  ///
  /// In fa, this message translates to:
  /// **'رفع سوء اثر چک'**
  String get dashboardClearCheque;

  /// No description provided for @dashboardCancelCheque.
  ///
  /// In fa, this message translates to:
  /// **'ابطال چک'**
  String get dashboardCancelCheque;

  /// No description provided for @dashboardLocalTransfer.
  ///
  /// In fa, this message translates to:
  /// **'انتقال وجه خدمت در محل'**
  String get dashboardLocalTransfer;

  /// No description provided for @dashboardMyLoans.
  ///
  /// In fa, this message translates to:
  /// **'وام‌های من'**
  String get dashboardMyLoans;

  /// No description provided for @dashboardLoanReport.
  ///
  /// In fa, this message translates to:
  /// **'گزارش معرفی وام'**
  String get dashboardLoanReport;

  /// No description provided for @dashboardCorrectInstallments.
  ///
  /// In fa, this message translates to:
  /// **'اصلاح اقساط پرداختی'**
  String get dashboardCorrectInstallments;

  /// No description provided for @dashboardDeferLoan.
  ///
  /// In fa, this message translates to:
  /// **'امهال وام'**
  String get dashboardDeferLoan;

  /// No description provided for @dashboardDepositsList.
  ///
  /// In fa, this message translates to:
  /// **'لیست سپرده‌ها'**
  String get dashboardDepositsList;

  /// No description provided for @dashboardOpenCurrent.
  ///
  /// In fa, this message translates to:
  /// **'افتتاح سپرده جاری'**
  String get dashboardOpenCurrent;

  /// No description provided for @dashboardCloseExtras.
  ///
  /// In fa, this message translates to:
  /// **'بستن سپرده‌های مازاد'**
  String get dashboardCloseExtras;

  /// No description provided for @dashboardRepresentationSettings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات نمایندگی'**
  String get dashboardRepresentationSettings;

  /// No description provided for @dashboardUnblockDeposit.
  ///
  /// In fa, this message translates to:
  /// **'رفع مسدودی سپرده'**
  String get dashboardUnblockDeposit;

  /// No description provided for @dashboardBlockDeposit.
  ///
  /// In fa, this message translates to:
  /// **'مسدودی سپرده'**
  String get dashboardBlockDeposit;

  /// No description provided for @dashboardWalletInfo.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات کیف پول'**
  String get dashboardWalletInfo;

  /// No description provided for @dashboardWalletCharge.
  ///
  /// In fa, this message translates to:
  /// **'افزایش موجودی'**
  String get dashboardWalletCharge;

  /// No description provided for @dashboardWalletWithdraw.
  ///
  /// In fa, this message translates to:
  /// **'برداشت موجودی'**
  String get dashboardWalletWithdraw;

  /// No description provided for @dashboardWalletTransfer.
  ///
  /// In fa, this message translates to:
  /// **'واریز کیف به کیف'**
  String get dashboardWalletTransfer;

  /// No description provided for @dashboardWalletHistory.
  ///
  /// In fa, this message translates to:
  /// **'گردش کیف پول'**
  String get dashboardWalletHistory;

  /// No description provided for @dashboardWalletDeposit.
  ///
  /// In fa, this message translates to:
  /// **'تغییر سپرده متصل به کیف'**
  String get dashboardWalletDeposit;

  /// No description provided for @dashboardChangeIdentity.
  ///
  /// In fa, this message translates to:
  /// **'تغییر مشخصات هویتی'**
  String get dashboardChangeIdentity;

  /// No description provided for @dashboardOccupation.
  ///
  /// In fa, this message translates to:
  /// **'مدیریت شغل'**
  String get dashboardOccupation;

  /// No description provided for @dashboardAddresses.
  ///
  /// In fa, this message translates to:
  /// **'مدیریت آدرس'**
  String get dashboardAddresses;

  /// No description provided for @dashboardChangePhone.
  ///
  /// In fa, this message translates to:
  /// **'تغییر شماره تلفن همراه'**
  String get dashboardChangePhone;

  /// No description provided for @dashboardRequests.
  ///
  /// In fa, this message translates to:
  /// **'درخواست‌های من'**
  String get dashboardRequests;

  /// No description provided for @cardsMyTitle.
  ///
  /// In fa, this message translates to:
  /// **'کارت‌های من'**
  String get cardsMyTitle;

  /// No description provided for @cardsOperations.
  ///
  /// In fa, this message translates to:
  /// **'عملیات کارت'**
  String get cardsOperations;

  /// No description provided for @cardsPinOperations.
  ///
  /// In fa, this message translates to:
  /// **'عملیات رمز'**
  String get cardsPinOperations;

  /// No description provided for @cardsQuickAccess.
  ///
  /// In fa, this message translates to:
  /// **'دسترسی سریع'**
  String get cardsQuickAccess;

  /// No description provided for @cardsReissue.
  ///
  /// In fa, this message translates to:
  /// **'صدور مجدد کارت'**
  String get cardsReissue;

  /// No description provided for @cardsForgotFirst.
  ///
  /// In fa, this message translates to:
  /// **'فراموشی رمز اول'**
  String get cardsForgotFirst;

  /// No description provided for @cardsSetSecond.
  ///
  /// In fa, this message translates to:
  /// **'تعیین رمز دوم'**
  String get cardsSetSecond;

  /// No description provided for @cardsForgotSecond.
  ///
  /// In fa, this message translates to:
  /// **'فراموشی رمز دوم'**
  String get cardsForgotSecond;

  /// No description provided for @cardsChangeFirst.
  ///
  /// In fa, this message translates to:
  /// **'تغییر رمز اول'**
  String get cardsChangeFirst;

  /// No description provided for @cardsGiftBalance.
  ///
  /// In fa, this message translates to:
  /// **'واریز مانده کارت هدیه'**
  String get cardsGiftBalance;

  /// No description provided for @cardsBuyGift.
  ///
  /// In fa, this message translates to:
  /// **'خرید کارت هدیه'**
  String get cardsBuyGift;

  /// No description provided for @cardsVirtual.
  ///
  /// In fa, this message translates to:
  /// **'کارت مجازی'**
  String get cardsVirtual;

  /// No description provided for @cardsCurrent.
  ///
  /// In fa, this message translates to:
  /// **'رسالت کارت (جاری)'**
  String get cardsCurrent;

  /// No description provided for @cardsQarz.
  ///
  /// In fa, this message translates to:
  /// **'رسالت کارت (قرض الحسنه)'**
  String get cardsQarz;

  /// No description provided for @cardsExpiry.
  ///
  /// In fa, this message translates to:
  /// **': انقضا'**
  String get cardsExpiry;

  /// No description provided for @cardsCopyNumber.
  ///
  /// In fa, this message translates to:
  /// **'کپی شماره کارت'**
  String get cardsCopyNumber;

  /// No description provided for @cardsCopyIban.
  ///
  /// In fa, this message translates to:
  /// **'کپی شماره شبا'**
  String get cardsCopyIban;

  /// No description provided for @cardsShowDetails.
  ///
  /// In fa, this message translates to:
  /// **'نمایش اطلاعات کارت'**
  String get cardsShowDetails;

  /// No description provided for @cardsHideDetails.
  ///
  /// In fa, this message translates to:
  /// **'پنهان کردن اطلاعات کارت'**
  String get cardsHideDetails;

  /// No description provided for @cardsMore.
  ///
  /// In fa, this message translates to:
  /// **'گزینه‌های کارت'**
  String get cardsMore;

  /// No description provided for @cardsEmpty.
  ///
  /// In fa, this message translates to:
  /// **'هنوز کارتی ندارید'**
  String get cardsEmpty;

  /// No description provided for @depositsMyTitle.
  ///
  /// In fa, this message translates to:
  /// **'سپرده‌های من'**
  String get depositsMyTitle;

  /// No description provided for @depositsOperations.
  ///
  /// In fa, this message translates to:
  /// **'عملیات سپرده'**
  String get depositsOperations;

  /// No description provided for @depositsChequeOperations.
  ///
  /// In fa, this message translates to:
  /// **'عملیات چک'**
  String get depositsChequeOperations;

  /// No description provided for @depositsEmpty.
  ///
  /// In fa, this message translates to:
  /// **'هنوز سپرده‌ای ندارید'**
  String get depositsEmpty;

  /// No description provided for @depositsRepresentative.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات نماینده'**
  String get depositsRepresentative;

  /// No description provided for @depositsLinkedCards.
  ///
  /// In fa, this message translates to:
  /// **'کارت‌های متصل به سپرده'**
  String get depositsLinkedCards;

  /// No description provided for @depositsLinkedLoans.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت وام‌های متصل'**
  String get depositsLinkedLoans;

  /// No description provided for @depositsLocalTransfer.
  ///
  /// In fa, this message translates to:
  /// **'انتقال وجه خدمت در محل'**
  String get depositsLocalTransfer;

  /// No description provided for @depositsMobileBank.
  ///
  /// In fa, this message translates to:
  /// **'موبایل بانک'**
  String get depositsMobileBank;

  /// No description provided for @depositsCopyNumber.
  ///
  /// In fa, this message translates to:
  /// **'کپی شماره سپرده'**
  String get depositsCopyNumber;

  /// No description provided for @loansOperations.
  ///
  /// In fa, this message translates to:
  /// **'عملیات وام'**
  String get loansOperations;

  /// No description provided for @loansEmpty.
  ///
  /// In fa, this message translates to:
  /// **'هنوز وامی ندارید'**
  String get loansEmpty;

  /// No description provided for @loansPayInstallments.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت اقساط'**
  String get loansPayInstallments;

  /// No description provided for @loansRelationships.
  ///
  /// In fa, this message translates to:
  /// **'روابط سببی نسبی'**
  String get loansRelationships;

  /// No description provided for @loansDefaultName.
  ///
  /// In fa, this message translates to:
  /// **'تسهیلات قرض الحسنه عادی (بدون کارمزد)'**
  String get loansDefaultName;

  /// No description provided for @loansChangeDeposit.
  ///
  /// In fa, this message translates to:
  /// **'تغییر سپرده کسر اقساط'**
  String get loansChangeDeposit;

  /// No description provided for @dashboardLoading.
  ///
  /// In fa, this message translates to:
  /// **'در حال دریافت اطلاعات…'**
  String get dashboardLoading;

  /// No description provided for @dashboardLoadError.
  ///
  /// In fa, this message translates to:
  /// **'دریافت اطلاعات انجام نشد'**
  String get dashboardLoadError;

  /// No description provided for @dashboardRetry.
  ///
  /// In fa, this message translates to:
  /// **'تلاش دوباره'**
  String get dashboardRetry;

  /// No description provided for @dashboardEmpty.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعاتی برای نمایش وجود ندارد'**
  String get dashboardEmpty;

  /// No description provided for @cardFeatureResalat.
  ///
  /// In fa, this message translates to:
  /// **'رسالت کارت'**
  String get cardFeatureResalat;

  /// No description provided for @cardFeatureGift.
  ///
  /// In fa, this message translates to:
  /// **'کارت هدیه'**
  String get cardFeatureGift;

  /// No description provided for @cardFeatureCoupon.
  ///
  /// In fa, this message translates to:
  /// **'بن کارت'**
  String get cardFeatureCoupon;

  /// No description provided for @cardFeatureFamily.
  ///
  /// In fa, this message translates to:
  /// **'کارت خانواده'**
  String get cardFeatureFamily;

  /// No description provided for @cardFeatureDetails.
  ///
  /// In fa, this message translates to:
  /// **'جزئیات کارت'**
  String get cardFeatureDetails;

  /// No description provided for @cardFeatureNumber.
  ///
  /// In fa, this message translates to:
  /// **'شماره کارت'**
  String get cardFeatureNumber;

  /// No description provided for @cardFeatureDeposit.
  ///
  /// In fa, this message translates to:
  /// **'سپرده متصل'**
  String get cardFeatureDeposit;

  /// No description provided for @cardFeatureIban.
  ///
  /// In fa, this message translates to:
  /// **'شماره شبا'**
  String get cardFeatureIban;

  /// No description provided for @cardFeatureDepositType.
  ///
  /// In fa, this message translates to:
  /// **'نوع سپرده'**
  String get cardFeatureDepositType;

  /// No description provided for @cardFeatureExpiry.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ انقضا'**
  String get cardFeatureExpiry;

  /// No description provided for @cardFeatureStatus.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت'**
  String get cardFeatureStatus;

  /// No description provided for @cardFeatureActive.
  ///
  /// In fa, this message translates to:
  /// **'فعال'**
  String get cardFeatureActive;

  /// No description provided for @cardFeatureBlocked.
  ///
  /// In fa, this message translates to:
  /// **'مسدود'**
  String get cardFeatureBlocked;

  /// No description provided for @cardFeatureExpired.
  ///
  /// In fa, this message translates to:
  /// **'منقضی'**
  String get cardFeatureExpired;

  /// No description provided for @cardFeatureQarz.
  ///
  /// In fa, this message translates to:
  /// **'قرض الحسنه'**
  String get cardFeatureQarz;

  /// No description provided for @cardFeatureFilter.
  ///
  /// In fa, this message translates to:
  /// **'فیلتر'**
  String get cardFeatureFilter;

  /// No description provided for @cardFeatureRemoveFilter.
  ///
  /// In fa, this message translates to:
  /// **'حذف فیلتر'**
  String get cardFeatureRemoveFilter;

  /// No description provided for @cardFeatureApplyFilter.
  ///
  /// In fa, this message translates to:
  /// **'اعمال فیلتر'**
  String get cardFeatureApplyFilter;

  /// No description provided for @cardFeatureAll.
  ///
  /// In fa, this message translates to:
  /// **'همه'**
  String get cardFeatureAll;

  /// No description provided for @cardFeatureNoResults.
  ///
  /// In fa, this message translates to:
  /// **'کارتی با این مشخصات پیدا نشد'**
  String get cardFeatureNoResults;

  /// No description provided for @cardFeatureCardStatus.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت کارت'**
  String get cardFeatureCardStatus;

  /// No description provided for @cardFeatureGiftTransfer.
  ///
  /// In fa, this message translates to:
  /// **'واریز مانده کارت هدیه منقضی'**
  String get cardFeatureGiftTransfer;

  /// No description provided for @cardFeatureVirtualRequest.
  ///
  /// In fa, this message translates to:
  /// **'درخواست کارت مجازی'**
  String get cardFeatureVirtualRequest;

  /// No description provided for @cardFeatureUnavailable.
  ///
  /// In fa, this message translates to:
  /// **'این خدمت در حال حاضر در دسترس نیست.'**
  String get cardFeatureUnavailable;

  /// No description provided for @issuanceTitle.
  ///
  /// In fa, this message translates to:
  /// **'صدور رسالت کارت'**
  String get issuanceTitle;

  /// No description provided for @issuanceSelectionTitle.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب سپرده و نوع صدور کارت'**
  String get issuanceSelectionTitle;

  /// No description provided for @issuanceDeliveryTitle.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات دریافت کارت'**
  String get issuanceDeliveryTitle;

  /// No description provided for @issuanceConfirmTitle.
  ///
  /// In fa, this message translates to:
  /// **'تایید اطلاعات و پرداخت کارمزد'**
  String get issuanceConfirmTitle;

  /// No description provided for @issuanceNextDelivery.
  ///
  /// In fa, this message translates to:
  /// **'بعدی: اطلاعات دریافت کارت'**
  String get issuanceNextDelivery;

  /// No description provided for @issuanceNextConfirm.
  ///
  /// In fa, this message translates to:
  /// **'بعدی: تایید اطلاعات و پرداخت کارمزد'**
  String get issuanceNextConfirm;

  /// No description provided for @issuanceEnd.
  ///
  /// In fa, this message translates to:
  /// **'پایان'**
  String get issuanceEnd;

  /// No description provided for @issuanceDeposit.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب سپرده'**
  String get issuanceDeposit;

  /// No description provided for @issuanceDepositHint.
  ///
  /// In fa, this message translates to:
  /// **'سپرده مورد نظر خود را انتخاب کنید'**
  String get issuanceDepositHint;

  /// No description provided for @issuanceType.
  ///
  /// In fa, this message translates to:
  /// **'نوع صدور کارت'**
  String get issuanceType;

  /// No description provided for @issuanceTypeHint.
  ///
  /// In fa, this message translates to:
  /// **'نوع صدور کارت را مشخص کنید'**
  String get issuanceTypeHint;

  /// No description provided for @issuanceNewNumber.
  ///
  /// In fa, this message translates to:
  /// **'صدور کارت با شماره جدید'**
  String get issuanceNewNumber;

  /// No description provided for @issuanceExistingNumber.
  ///
  /// In fa, this message translates to:
  /// **'صدور کارت با شماره فعلی'**
  String get issuanceExistingNumber;

  /// No description provided for @issuanceCurrentCard.
  ///
  /// In fa, this message translates to:
  /// **'شماره کارت فعلی'**
  String get issuanceCurrentCard;

  /// No description provided for @issuanceExpiry.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ انقضا'**
  String get issuanceExpiry;

  /// No description provided for @issuanceNoPhysical.
  ///
  /// In fa, this message translates to:
  /// **'نیازی به دریافت کارت فیزیکی ندارم'**
  String get issuanceNoPhysical;

  /// No description provided for @issuanceNext.
  ///
  /// In fa, this message translates to:
  /// **'مرحله بعد'**
  String get issuanceNext;

  /// No description provided for @issuanceAddress.
  ///
  /// In fa, this message translates to:
  /// **'آدرس'**
  String get issuanceAddress;

  /// No description provided for @issuanceSelectAddress.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب آدرس'**
  String get issuanceSelectAddress;

  /// No description provided for @issuanceAddressHint.
  ///
  /// In fa, this message translates to:
  /// **'آدرس دریافت کارت را انتخاب کنید'**
  String get issuanceAddressHint;

  /// No description provided for @issuanceAddAddress.
  ///
  /// In fa, this message translates to:
  /// **'افزودن آدرس جدید'**
  String get issuanceAddAddress;

  /// No description provided for @issuanceDeleteAddress.
  ///
  /// In fa, this message translates to:
  /// **'حذف آدرس'**
  String get issuanceDeleteAddress;

  /// No description provided for @issuanceOtherRecipient.
  ///
  /// In fa, this message translates to:
  /// **'دریافت توسط شخص دیگر'**
  String get issuanceOtherRecipient;

  /// No description provided for @issuanceIncludeAgent.
  ///
  /// In fa, this message translates to:
  /// **'وارد کردن مشخصات کارشناس بانکی'**
  String get issuanceIncludeAgent;

  /// No description provided for @issuanceRecipientName.
  ///
  /// In fa, this message translates to:
  /// **'نام و نام خانوادگی گیرنده'**
  String get issuanceRecipientName;

  /// No description provided for @issuanceNationalId.
  ///
  /// In fa, this message translates to:
  /// **'کد ملی گیرنده'**
  String get issuanceNationalId;

  /// No description provided for @issuanceRecipientMobile.
  ///
  /// In fa, this message translates to:
  /// **'شماره همراه گیرنده'**
  String get issuanceRecipientMobile;

  /// No description provided for @issuanceAgentName.
  ///
  /// In fa, this message translates to:
  /// **'نام و نام خانوادگی کارشناس'**
  String get issuanceAgentName;

  /// No description provided for @issuanceAgentCode.
  ///
  /// In fa, this message translates to:
  /// **'کد کارشناس'**
  String get issuanceAgentCode;

  /// No description provided for @issuanceAddressTitle.
  ///
  /// In fa, this message translates to:
  /// **'عنوان آدرس'**
  String get issuanceAddressTitle;

  /// No description provided for @issuanceAddressDetail.
  ///
  /// In fa, this message translates to:
  /// **'نشانی کامل'**
  String get issuanceAddressDetail;

  /// No description provided for @issuancePostalCode.
  ///
  /// In fa, this message translates to:
  /// **'کد پستی'**
  String get issuancePostalCode;

  /// No description provided for @issuanceSaveAddress.
  ///
  /// In fa, this message translates to:
  /// **'ثبت آدرس'**
  String get issuanceSaveAddress;

  /// No description provided for @issuanceAddressInvalid.
  ///
  /// In fa, this message translates to:
  /// **'عنوان، نشانی کامل و کد پستی ۱۰ رقمی را وارد کنید.'**
  String get issuanceAddressInvalid;

  /// No description provided for @issuanceSummary.
  ///
  /// In fa, this message translates to:
  /// **'خلاصه اطلاعات'**
  String get issuanceSummary;

  /// No description provided for @issuanceDepositNumber.
  ///
  /// In fa, this message translates to:
  /// **'شماره سپرده'**
  String get issuanceDepositNumber;

  /// No description provided for @issuanceOperation.
  ///
  /// In fa, this message translates to:
  /// **'نوع عملیات'**
  String get issuanceOperation;

  /// No description provided for @issuancePayable.
  ///
  /// In fa, this message translates to:
  /// **'هزینه قابل پرداخت'**
  String get issuancePayable;

  /// No description provided for @issuanceWallet.
  ///
  /// In fa, this message translates to:
  /// **'موجودی کیف پول'**
  String get issuanceWallet;

  /// No description provided for @issuancePrintFee.
  ///
  /// In fa, this message translates to:
  /// **'هزینه چاپ گزارش'**
  String get issuancePrintFee;

  /// No description provided for @issuanceIdentityFee.
  ///
  /// In fa, this message translates to:
  /// **'کارمزد احراز هویت'**
  String get issuanceIdentityFee;

  /// No description provided for @issuanceDeliveryFee.
  ///
  /// In fa, this message translates to:
  /// **'هزینه ارسال'**
  String get issuanceDeliveryFee;

  /// No description provided for @issuanceTerms.
  ///
  /// In fa, this message translates to:
  /// **'قوانین و مقررات'**
  String get issuanceTerms;

  /// No description provided for @issuanceTermsPrompt.
  ///
  /// In fa, this message translates to:
  /// **'درخواست را مطالعه و تایید می‌نمایم.'**
  String get issuanceTermsPrompt;

  /// No description provided for @issuanceTermsUnavailable.
  ///
  /// In fa, this message translates to:
  /// **'متن رسمی قوانین پس از اتصال به سرویس نمایش داده می‌شود.'**
  String get issuanceTermsUnavailable;

  /// No description provided for @issuanceSubmit.
  ///
  /// In fa, this message translates to:
  /// **'تایید و ثبت درخواست'**
  String get issuanceSubmit;

  /// No description provided for @issuanceSubmitError.
  ///
  /// In fa, this message translates to:
  /// **'ثبت درخواست انجام نشد. دوباره تلاش کنید.'**
  String get issuanceSubmitError;

  /// No description provided for @issuanceEmpty.
  ///
  /// In fa, this message translates to:
  /// **'سپرده‌ای برای صدور کارت در دسترس نیست.'**
  String get issuanceEmpty;

  /// No description provided for @issuanceMockComplete.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌نمایش درخواست تکمیل شد؛ پرداخت یا صدور واقعی انجام نشده است.'**
  String get issuanceMockComplete;

  /// No description provided for @issuanceComplete.
  ///
  /// In fa, this message translates to:
  /// **'درخواست ثبت شد.'**
  String get issuanceComplete;

  /// No description provided for @issuanceDone.
  ///
  /// In fa, this message translates to:
  /// **'بازگشت'**
  String get issuanceDone;

  /// No description provided for @issuanceWalletSufficient.
  ///
  /// In fa, this message translates to:
  /// **'موجودی کیف پول کافی است'**
  String get issuanceWalletSufficient;

  /// No description provided for @issuanceWalletInsufficient.
  ///
  /// In fa, this message translates to:
  /// **'موجودی کیف پول کافی نیست'**
  String get issuanceWalletInsufficient;

  /// No description provided for @issuanceStepSemantic.
  ///
  /// In fa, this message translates to:
  /// **'مرحله {current} از {total}، {title}'**
  String issuanceStepSemantic(int current, int total, String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
