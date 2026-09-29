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
  /// **'ورود به پیشخوان مجازی'**
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
  /// **'کد را وارد کنید'**
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
