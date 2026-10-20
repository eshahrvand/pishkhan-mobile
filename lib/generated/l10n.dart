// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `پیشخوان مجازی رسالت`
  String get appTitle {
    return Intl.message(
      'پیشخوان مجازی رسالت',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `تغییر شماره همراه`
  String get changeMobileTitle {
    return Intl.message(
      'تغییر شماره همراه',
      name: 'changeMobileTitle',
      desc: '',
      args: [],
    );
  }

  /// `بازگشت`
  String get backLabel {
    return Intl.message('بازگشت', name: 'backLabel', desc: '', args: []);
  }

  /// `بستن`
  String get closeLabel {
    return Intl.message('بستن', name: 'closeLabel', desc: '', args: []);
  }

  /// `فهرست خدمات`
  String get servicesMenuLabel {
    return Intl.message(
      'فهرست خدمات',
      name: 'servicesMenuLabel',
      desc: '',
      args: [],
    );
  }

  /// `برای تغییر شماره همراه ورود به پیشخوان اطلاعات زیر را وارد کنید`
  String get changeMobileDescription {
    return Intl.message(
      'برای تغییر شماره همراه ورود به پیشخوان اطلاعات زیر را وارد کنید',
      name: 'changeMobileDescription',
      desc: '',
      args: [],
    );
  }

  /// `ورود با کد ملی`
  String get loginTitle {
    return Intl.message(
      'ورود با کد ملی',
      name: 'loginTitle',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی | شماره ملی | کد اتباع`
  String get loginNationalIdHint {
    return Intl.message(
      'کد ملی | شماره ملی | کد اتباع',
      name: 'loginNationalIdHint',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی | شماره ملی خود را وارد کنید`
  String get changeNationalIdHint {
    return Intl.message(
      'کد ملی | شماره ملی خود را وارد کنید',
      name: 'changeNationalIdHint',
      desc: '',
      args: [],
    );
  }

  /// `شماره همراه خود را وارد کنید`
  String get loginPhoneHint {
    return Intl.message(
      'شماره همراه خود را وارد کنید',
      name: 'loginPhoneHint',
      desc: '',
      args: [],
    );
  }

  /// `شماره همراه جدید خود را وارد کنید`
  String get changePhoneHint {
    return Intl.message(
      'شماره همراه جدید خود را وارد کنید',
      name: 'changePhoneHint',
      desc: '',
      args: [],
    );
  }

  /// `تغییر شماره همراه`
  String get changePhoneAction {
    return Intl.message(
      'تغییر شماره همراه',
      name: 'changePhoneAction',
      desc: '',
      args: [],
    );
  }

  /// `درخواست کد دو عاملی`
  String get requestTwoFactorCode {
    return Intl.message(
      'درخواست کد دو عاملی',
      name: 'requestTwoFactorCode',
      desc: '',
      args: [],
    );
  }

  /// `درخواست ارسال رمز`
  String get requestOtp {
    return Intl.message(
      'درخواست ارسال رمز',
      name: 'requestOtp',
      desc: '',
      args: [],
    );
  }

  /// `شماره باید با کد ملی دارنده حساب مطابقت داشته باشد`
  String get phoneOwnershipNotice {
    return Intl.message(
      'شماره باید با کد ملی دارنده حساب مطابقت داشته باشد',
      name: 'phoneOwnershipNotice',
      desc: '',
      args: [],
    );
  }

  /// `کد روبرو را وارد کنید`
  String get captchaHint {
    return Intl.message(
      'کد روبرو را وارد کنید',
      name: 'captchaHint',
      desc: '',
      args: [],
    );
  }

  /// `رمز پویای ارسال شده به شماره {phone} را وارد کنید.`
  String otpSentMessage(String phone) {
    return Intl.message(
      'رمز پویای ارسال شده به شماره $phone را وارد کنید.',
      name: 'otpSentMessage',
      desc: '',
      args: [phone],
    );
  }

  /// `وارد کردن رمز`
  String get otpHint {
    return Intl.message('وارد کردن رمز', name: 'otpHint', desc: '', args: []);
  }

  /// `ثبت درخواست`
  String get submitRequest {
    return Intl.message(
      'ثبت درخواست',
      name: 'submitRequest',
      desc: '',
      args: [],
    );
  }

  /// `ورود به پیشخوان`
  String get enterDashboard {
    return Intl.message(
      'ورود به پیشخوان',
      name: 'enterDashboard',
      desc: '',
      args: [],
    );
  }

  /// `ارسال مجدد`
  String get resendOtp {
    return Intl.message('ارسال مجدد', name: 'resendOtp', desc: '', args: []);
  }

  /// `لیست خدمات`
  String get servicesList {
    return Intl.message('لیست خدمات', name: 'servicesList', desc: '', args: []);
  }

  /// `خدمات بدون نیاز به لاگین`
  String get guestServices {
    return Intl.message(
      'خدمات بدون نیاز به لاگین',
      name: 'guestServices',
      desc: '',
      args: [],
    );
  }

  /// `گزارش تمکن`
  String get assetReport {
    return Intl.message('گزارش تمکن', name: 'assetReport', desc: '', args: []);
  }

  /// `تغییر تلفن همراه`
  String get changeMobileService {
    return Intl.message(
      'تغییر تلفن همراه',
      name: 'changeMobileService',
      desc: '',
      args: [],
    );
  }

  /// `وضعیت درخواست`
  String get requestStatus {
    return Intl.message(
      'وضعیت درخواست',
      name: 'requestStatus',
      desc: '',
      args: [],
    );
  }

  /// `انحصار وراثت`
  String get inheritance {
    return Intl.message(
      'انحصار وراثت',
      name: 'inheritance',
      desc: '',
      args: [],
    );
  }

  /// `لینک‌های مرتبط`
  String get relatedLinks {
    return Intl.message(
      'لینک‌های مرتبط',
      name: 'relatedLinks',
      desc: '',
      args: [],
    );
  }

  /// `همراه بانک`
  String get mobileBank {
    return Intl.message('همراه بانک', name: 'mobileBank', desc: '', args: []);
  }

  /// `اینترنت بانک`
  String get internetBank {
    return Intl.message(
      'اینترنت بانک',
      name: 'internetBank',
      desc: '',
      args: [],
    );
  }

  /// `مرکز ارتباط با اعضاء`
  String get memberContactCenter {
    return Intl.message(
      'مرکز ارتباط با اعضاء',
      name: 'memberContactCenter',
      desc: '',
      args: [],
    );
  }

  /// `ام رسالت`
  String get resalatApp {
    return Intl.message('ام رسالت', name: 'resalatApp', desc: '', args: []);
  }

  /// `نکات امنیتی`
  String get securityTips {
    return Intl.message(
      'نکات امنیتی',
      name: 'securityTips',
      desc: '',
      args: [],
    );
  }

  /// `راهنمای بروزرسانی`
  String get updateGuide {
    return Intl.message(
      'راهنمای بروزرسانی',
      name: 'updateGuide',
      desc: '',
      args: [],
    );
  }

  /// `مانی عزیز، صبح بخیر`
  String get dashboardGreeting {
    return Intl.message(
      'مانی عزیز، صبح بخیر',
      name: 'dashboardGreeting',
      desc: '',
      args: [],
    );
  }

  /// `به پیشخوان مجازی رسالت خوش آمدید`
  String get dashboardWelcomeMessage {
    return Intl.message(
      'به پیشخوان مجازی رسالت خوش آمدید',
      name: 'dashboardWelcomeMessage',
      desc: '',
      args: [],
    );
  }

  /// `موجودی کیف پول`
  String get walletBalanceTitle {
    return Intl.message(
      'موجودی کیف پول',
      name: 'walletBalanceTitle',
      desc: '',
      args: [],
    );
  }

  /// `ریال`
  String get rialCurrency {
    return Intl.message('ریال', name: 'rialCurrency', desc: '', args: []);
  }

  /// `۱٬۲۰۰٬۰۰۰`
  String get dashboardWalletBalance {
    return Intl.message(
      '۱٬۲۰۰٬۰۰۰',
      name: 'dashboardWalletBalance',
      desc: '',
      args: [],
    );
  }

  /// `خدمات سپرده`
  String get depositServices {
    return Intl.message(
      'خدمات سپرده',
      name: 'depositServices',
      desc: '',
      args: [],
    );
  }

  /// `تنظیمات ارسال پیامک`
  String get smsSettings {
    return Intl.message(
      'تنظیمات ارسال پیامک',
      name: 'smsSettings',
      desc: '',
      args: [],
    );
  }

  /// `معرفی نماینده`
  String get introduceAgent {
    return Intl.message(
      'معرفی نماینده',
      name: 'introduceAgent',
      desc: '',
      args: [],
    );
  }

  /// `گواهی تمکن مالی`
  String get financialCertificate {
    return Intl.message(
      'گواهی تمکن مالی',
      name: 'financialCertificate',
      desc: '',
      args: [],
    );
  }

  /// `صورتحساب، معدل موجودی`
  String get balanceAverageStatement {
    return Intl.message(
      'صورتحساب، معدل موجودی',
      name: 'balanceAverageStatement',
      desc: '',
      args: [],
    );
  }

  /// `خدمات کارت`
  String get cardServices {
    return Intl.message('خدمات کارت', name: 'cardServices', desc: '', args: []);
  }

  /// `مسدودی کارت`
  String get blockCard {
    return Intl.message('مسدودی کارت', name: 'blockCard', desc: '', args: []);
  }

  /// `تغییر سپرده متصل به کارت`
  String get changeCardDeposit {
    return Intl.message(
      'تغییر سپرده متصل به کارت',
      name: 'changeCardDeposit',
      desc: '',
      args: [],
    );
  }

  /// `صدور رمز اول /دوم کارت`
  String get cardPasswordIssue {
    return Intl.message(
      'صدور رمز اول /دوم کارت',
      name: 'cardPasswordIssue',
      desc: '',
      args: [],
    );
  }

  /// `صدور رسالت کارت`
  String get issueResalatCard {
    return Intl.message(
      'صدور رسالت کارت',
      name: 'issueResalatCard',
      desc: '',
      args: [],
    );
  }

  /// `خدمات وام`
  String get loanServices {
    return Intl.message('خدمات وام', name: 'loanServices', desc: '', args: []);
  }

  /// `تغییر سپرده جهت کسر اقساط`
  String get changeInstallmentDeposit {
    return Intl.message(
      'تغییر سپرده جهت کسر اقساط',
      name: 'changeInstallmentDeposit',
      desc: '',
      args: [],
    );
  }

  /// `تجمیع اعتبار سپرده`
  String get consolidateDepositCredit {
    return Intl.message(
      'تجمیع اعتبار سپرده',
      name: 'consolidateDepositCredit',
      desc: '',
      args: [],
    );
  }

  /// `معرفی وام`
  String get introduceLoan {
    return Intl.message('معرفی وام', name: 'introduceLoan', desc: '', args: []);
  }

  /// `برآورد وام`
  String get loanEstimate {
    return Intl.message('برآورد وام', name: 'loanEstimate', desc: '', args: []);
  }

  /// `خدمات منتخب`
  String get selectedServices {
    return Intl.message(
      'خدمات منتخب',
      name: 'selectedServices',
      desc: '',
      args: [],
    );
  }

  /// `سپرده وکالتی`
  String get proxyDeposit {
    return Intl.message(
      'سپرده وکالتی',
      name: 'proxyDeposit',
      desc: '',
      args: [],
    );
  }

  /// `صدور دسته چک`
  String get issueChequeBook {
    return Intl.message(
      'صدور دسته چک',
      name: 'issueChequeBook',
      desc: '',
      args: [],
    );
  }

  /// `تنظیمات اینترنت بانک`
  String get internetBankSettings {
    return Intl.message(
      'تنظیمات اینترنت بانک',
      name: 'internetBankSettings',
      desc: '',
      args: [],
    );
  }

  /// `تنظیمات موبایل بانک`
  String get mobileBankSettings {
    return Intl.message(
      'تنظیمات موبایل بانک',
      name: 'mobileBankSettings',
      desc: '',
      args: [],
    );
  }

  /// `آخرین درخواست‌های بروز شده`
  String get latestUpdatedRequests {
    return Intl.message(
      'آخرین درخواست‌های بروز شده',
      name: 'latestUpdatedRequests',
      desc: '',
      args: [],
    );
  }

  /// `درخواست تغییر سپرده جهت کسر اقساط`
  String get dashboardRequestTitle {
    return Intl.message(
      'درخواست تغییر سپرده جهت کسر اقساط',
      name: 'dashboardRequestTitle',
      desc: '',
      args: [],
    );
  }

  /// `شناسه درخواست`
  String get requestIdentifier {
    return Intl.message(
      'شناسه درخواست',
      name: 'requestIdentifier',
      desc: '',
      args: [],
    );
  }

  /// `انجام شده خودکار`
  String get automaticCompleted {
    return Intl.message(
      'انجام شده خودکار',
      name: 'automaticCompleted',
      desc: '',
      args: [],
    );
  }

  /// `۱۳۷/۴۸۷۵۶۷`
  String get dashboardRequestNumber {
    return Intl.message(
      '۱۳۷/۴۸۷۵۶۷',
      name: 'dashboardRequestNumber',
      desc: '',
      args: [],
    );
  }

  /// `2024/09/16 | ۱۲:۴۵`
  String get dashboardRequestDate {
    return Intl.message(
      '2024/09/16 | ۱۲:۴۵',
      name: 'dashboardRequestDate',
      desc: '',
      args: [],
    );
  }

  /// `پروفایل`
  String get profileLabel {
    return Intl.message('پروفایل', name: 'profileLabel', desc: '', args: []);
  }

  /// `اعلان‌ها`
  String get notificationsLabel {
    return Intl.message(
      'اعلان‌ها',
      name: 'notificationsLabel',
      desc: '',
      args: [],
    );
  }

  /// `دستیار هوشمند`
  String get dashboardAssistant {
    return Intl.message(
      'دستیار هوشمند',
      name: 'dashboardAssistant',
      desc: '',
      args: [],
    );
  }

  /// `به رِسو بسپار!`
  String get dashboardResoTitle {
    return Intl.message(
      'به رِسو بسپار!',
      name: 'dashboardResoTitle',
      desc: '',
      args: [],
    );
  }

  /// `رِسو فقط جواب نمی‌ده؛ خودش دست‌به‌کار می‌شه.`
  String get dashboardResoDescription {
    return Intl.message(
      'رِسو فقط جواب نمی‌ده؛ خودش دست‌به‌کار می‌شه.',
      name: 'dashboardResoDescription',
      desc: '',
      args: [],
    );
  }

  /// `سوالت رو بنویس...`
  String get dashboardPromptHint {
    return Intl.message(
      'سوالت رو بنویس...',
      name: 'dashboardPromptHint',
      desc: '',
      args: [],
    );
  }

  /// `ارسال سوال`
  String get dashboardSendPrompt {
    return Intl.message(
      'ارسال سوال',
      name: 'dashboardSendPrompt',
      desc: '',
      args: [],
    );
  }

  /// `خدمات بانک رسالت`
  String get dashboardBankServices {
    return Intl.message(
      'خدمات بانک رسالت',
      name: 'dashboardBankServices',
      desc: '',
      args: [],
    );
  }

  /// `تنظیم خدمات منتخب`
  String get dashboardCustomize {
    return Intl.message(
      'تنظیم خدمات منتخب',
      name: 'dashboardCustomize',
      desc: '',
      args: [],
    );
  }

  /// `منتخب شما`
  String get dashboardYourFavorites {
    return Intl.message(
      'منتخب شما',
      name: 'dashboardYourFavorites',
      desc: '',
      args: [],
    );
  }

  /// `حداکثر ۸ تا مورد رو می‌تونی انتخاب کنی.`
  String get dashboardFavoritesLimit {
    return Intl.message(
      'حداکثر ۸ تا مورد رو می‌تونی انتخاب کنی.',
      name: 'dashboardFavoritesLimit',
      desc: '',
      args: [],
    );
  }

  /// `افزودن مورد جدید`
  String get dashboardAddService {
    return Intl.message(
      'افزودن مورد جدید',
      name: 'dashboardAddService',
      desc: '',
      args: [],
    );
  }

  /// `حذف`
  String get dashboardRemoveService {
    return Intl.message(
      'حذف',
      name: 'dashboardRemoveService',
      desc: '',
      args: [],
    );
  }

  /// `تایید`
  String get dashboardConfirm {
    return Intl.message('تایید', name: 'dashboardConfirm', desc: '', args: []);
  }

  /// `انصراف`
  String get dashboardCancel {
    return Intl.message('انصراف', name: 'dashboardCancel', desc: '', args: []);
  }

  /// `بازنشانی تنظیمات`
  String get dashboardResetTitle {
    return Intl.message(
      'بازنشانی تنظیمات',
      name: 'dashboardResetTitle',
      desc: '',
      args: [],
    );
  }

  /// `با بازنشانی تنظیمات، همه تغییراتت از بین می‌ره و به حالت اولیه برمی‌گرده.\nمطمئنی می‌خوای به تنظیمات اولیه برگردی؟`
  String get dashboardResetDescription {
    return Intl.message(
      'با بازنشانی تنظیمات، همه تغییراتت از بین می‌ره و به حالت اولیه برمی‌گرده.\nمطمئنی می‌خوای به تنظیمات اولیه برگردی؟',
      name: 'dashboardResetDescription',
      desc: '',
      args: [],
    );
  }

  /// `بازنشانی تنظیمات`
  String get dashboardResetConfirm {
    return Intl.message(
      'بازنشانی تنظیمات',
      name: 'dashboardResetConfirm',
      desc: '',
      args: [],
    );
  }

  /// `جستجو`
  String get dashboardSearchHint {
    return Intl.message(
      'جستجو',
      name: 'dashboardSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `خدمتی پیدا نشد`
  String get dashboardNoServices {
    return Intl.message(
      'خدمتی پیدا نشد',
      name: 'dashboardNoServices',
      desc: '',
      args: [],
    );
  }

  /// `داشبورد`
  String get dashboardTab {
    return Intl.message('داشبورد', name: 'dashboardTab', desc: '', args: []);
  }

  /// `کارت`
  String get dashboardCardsTab {
    return Intl.message('کارت', name: 'dashboardCardsTab', desc: '', args: []);
  }

  /// `سپرده`
  String get dashboardDepositsTab {
    return Intl.message(
      'سپرده',
      name: 'dashboardDepositsTab',
      desc: '',
      args: [],
    );
  }

  /// `وام`
  String get dashboardLoansTab {
    return Intl.message('وام', name: 'dashboardLoansTab', desc: '', args: []);
  }

  /// `اعلانات`
  String get notificationTitle {
    return Intl.message(
      'اعلانات',
      name: 'notificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `خواندن همه`
  String get notificationReadAll {
    return Intl.message(
      'خواندن همه',
      name: 'notificationReadAll',
      desc: '',
      args: [],
    );
  }

  /// `پیام‌های جدید`
  String get notificationNew {
    return Intl.message(
      'پیام‌های جدید',
      name: 'notificationNew',
      desc: '',
      args: [],
    );
  }

  /// `پیام‌های خوانده شده`
  String get notificationRead {
    return Intl.message(
      'پیام‌های خوانده شده',
      name: 'notificationRead',
      desc: '',
      args: [],
    );
  }

  /// `عنوان`
  String get notificationSubject {
    return Intl.message(
      'عنوان',
      name: 'notificationSubject',
      desc: '',
      args: [],
    );
  }

  /// `پیامی ندارید`
  String get notificationEmpty {
    return Intl.message(
      'پیامی ندارید',
      name: 'notificationEmpty',
      desc: '',
      args: [],
    );
  }

  /// `امروز`
  String get notificationToday {
    return Intl.message('امروز', name: 'notificationToday', desc: '', args: []);
  }

  /// `دیروز`
  String get notificationYesterday {
    return Intl.message(
      'دیروز',
      name: 'notificationYesterday',
      desc: '',
      args: [],
    );
  }

  /// `۵ روز پیش`
  String get notificationFiveDays {
    return Intl.message(
      '۵ روز پیش',
      name: 'notificationFiveDays',
      desc: '',
      args: [],
    );
  }

  /// `۷ روز پیش`
  String get notificationSevenDays {
    return Intl.message(
      '۷ روز پیش',
      name: 'notificationSevenDays',
      desc: '',
      args: [],
    );
  }

  /// `۱۶ شهريور ۱۴۰۵`
  String get notificationSampleDate {
    return Intl.message(
      '۱۶ شهريور ۱۴۰۵',
      name: 'notificationSampleDate',
      desc: '',
      args: [],
    );
  }

  /// `با سرمایه خودت وام بگیر`
  String get notificationLoanTitle {
    return Intl.message(
      'با سرمایه خودت وام بگیر',
      name: 'notificationLoanTitle',
      desc: '',
      args: [],
    );
  }

  /// `وام با وثیقه`
  String get notificationLoanSubtitle {
    return Intl.message(
      'وام با وثیقه',
      name: 'notificationLoanSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `سرمایه گداری تمام عیار`
  String get notificationInvestmentTitle {
    return Intl.message(
      'سرمایه گداری تمام عیار',
      name: 'notificationInvestmentTitle',
      desc: '',
      args: [],
    );
  }

  /// `معامله راحت و سریع طلا با تسویه آنی`
  String get notificationInvestmentSubtitle {
    return Intl.message(
      'معامله راحت و سریع طلا با تسویه آنی',
      name: 'notificationInvestmentSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `مراقب کلاهبرداران باشید⚠️`
  String get notificationSecurityTitle {
    return Intl.message(
      'مراقب کلاهبرداران باشید⚠️',
      name: 'notificationSecurityTitle',
      desc: '',
      args: [],
    );
  }

  /// `نکاتی برای افزایش امنیت حساب`
  String get notificationSecuritySubtitle {
    return Intl.message(
      'نکاتی برای افزایش امنیت حساب',
      name: 'notificationSecuritySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `سلام! این روزا ممکنه پیام‌هایی از طرف آدمای سودجو به دستتون برسه که خودشون رو جای تیم پشتیبانی جا می‌زنن. برای اینکه حسابتون همیشه امن بمونه، حواستون به این چند تا نکته باشه:`
  String get notificationSecurityIntro {
    return Intl.message(
      'سلام! این روزا ممکنه پیام‌هایی از طرف آدمای سودجو به دستتون برسه که خودشون رو جای تیم پشتیبانی جا می‌زنن. برای اینکه حسابتون همیشه امن بمونه، حواستون به این چند تا نکته باشه:',
      name: 'notificationSecurityIntro',
      desc: '',
      args: [],
    );
  }

  /// `برای اینکه گیر کلاهبردارها نیفتی و حسابت همیشه امن بمونه، حواست به این چند تا مورد باشه:`
  String get notificationSecurityAdvice {
    return Intl.message(
      'برای اینکه گیر کلاهبردارها نیفتی و حسابت همیشه امن بمونه، حواست به این چند تا مورد باشه:',
      name: 'notificationSecurityAdvice',
      desc: '',
      args: [],
    );
  }

  /// `کد ورودت رو به کسی نده: ما تو تیم پشتیبانی هیچ‌وقت رمز یا کد تاییدی که برات پیامک می‌شه رو ازت نمی‌خوایم.`
  String get notificationSecurityCode {
    return Intl.message(
      'کد ورودت رو به کسی نده: ما تو تیم پشتیبانی هیچ‌وقت رمز یا کد تاییدی که برات پیامک می‌شه رو ازت نمی‌خوایم.',
      name: 'notificationSecurityCode',
      desc: '',
      args: [],
    );
  }

  /// `لینک‌های مشکوک رو باز نکن: اگه پیامی با یه لینک ناشناس برات اومد که می‌گفت «حسابت مسدود شده» یا «برنده شدی»، اصلاً روش کلیک نکن.`
  String get notificationSecurityLinks {
    return Intl.message(
      'لینک‌های مشکوک رو باز نکن: اگه پیامی با یه لینک ناشناس برات اومد که می‌گفت «حسابت مسدود شده» یا «برنده شدی»، اصلاً روش کلیک نکن.',
      name: 'notificationSecurityLinks',
      desc: '',
      args: [],
    );
  }

  /// `فقط از راه‌های رسمی در ارتباط باش: همیشه مطمئن شو پیامی که می‌گیری از طرف شماره‌ها یا اکانت‌های رسمی خودمون باشه.`
  String get notificationSecurityOfficial {
    return Intl.message(
      'فقط از راه‌های رسمی در ارتباط باش: همیشه مطمئن شو پیامی که می‌گیری از طرف شماره‌ها یا اکانت‌های رسمی خودمون باشه.',
      name: 'notificationSecurityOfficial',
      desc: '',
      args: [],
    );
  }

  /// `اگه با مورد مشکوکی برخورد کردی، همون لحظه به ما خبر بده تا سریع چکش کنیم.`
  String get notificationSecurityClosing {
    return Intl.message(
      'اگه با مورد مشکوکی برخورد کردی، همون لحظه به ما خبر بده تا سریع چکش کنیم.',
      name: 'notificationSecurityClosing',
      desc: '',
      args: [],
    );
  }

  /// `برای ورود به حساب کاربری اطلاعات زیر را وارد کنید`
  String get loginDescription {
    return Intl.message(
      'برای ورود به حساب کاربری اطلاعات زیر را وارد کنید',
      name: 'loginDescription',
      desc: '',
      args: [],
    );
  }

  /// `کد ارسال شد.`
  String get otpSentTitle {
    return Intl.message(
      'کد ارسال شد.',
      name: 'otpSentTitle',
      desc: '',
      args: [],
    );
  }

  /// `تازه‌سازی کد امنیتی`
  String get refreshCaptcha {
    return Intl.message(
      'تازه‌سازی کد امنیتی',
      name: 'refreshCaptcha',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی ۱۰ رقمی را وارد کنید`
  String get authInvalidNationalId {
    return Intl.message(
      'کد ملی ۱۰ رقمی را وارد کنید',
      name: 'authInvalidNationalId',
      desc: '',
      args: [],
    );
  }

  /// `شماره همراه ۱۱ رقمی با ۰۹ را وارد کنید`
  String get authInvalidPhone {
    return Intl.message(
      'شماره همراه ۱۱ رقمی با ۰۹ را وارد کنید',
      name: 'authInvalidPhone',
      desc: '',
      args: [],
    );
  }

  /// `کد امنیتی ۶ رقمی را وارد کنید`
  String get authInvalidCaptcha {
    return Intl.message(
      'کد امنیتی ۶ رقمی را وارد کنید',
      name: 'authInvalidCaptcha',
      desc: '',
      args: [],
    );
  }

  /// `بانکداری مدرن`
  String get dashboardModernBanking {
    return Intl.message(
      'بانکداری مدرن',
      name: 'dashboardModernBanking',
      desc: '',
      args: [],
    );
  }

  /// `چک`
  String get dashboardChequeServices {
    return Intl.message(
      'چک',
      name: 'dashboardChequeServices',
      desc: '',
      args: [],
    );
  }

  /// `انتقال وجه`
  String get dashboardTransferServices {
    return Intl.message(
      'انتقال وجه',
      name: 'dashboardTransferServices',
      desc: '',
      args: [],
    );
  }

  /// `کیف پول`
  String get dashboardWalletServices {
    return Intl.message(
      'کیف پول',
      name: 'dashboardWalletServices',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات فردی`
  String get dashboardIdentityServices {
    return Intl.message(
      'اطلاعات فردی',
      name: 'dashboardIdentityServices',
      desc: '',
      args: [],
    );
  }

  /// `درخواست‌های من`
  String get dashboardRequestServices {
    return Intl.message(
      'درخواست‌های من',
      name: 'dashboardRequestServices',
      desc: '',
      args: [],
    );
  }

  /// `همه خدمات`
  String get dashboardAllServices {
    return Intl.message(
      'همه خدمات',
      name: 'dashboardAllServices',
      desc: '',
      args: [],
    );
  }

  /// `مشاهده همه`
  String get dashboardViewAll {
    return Intl.message(
      'مشاهده همه',
      name: 'dashboardViewAll',
      desc: '',
      args: [],
    );
  }

  /// `ویرایش`
  String get dashboardEdit {
    return Intl.message('ویرایش', name: 'dashboardEdit', desc: '', args: []);
  }

  /// `افزودن خدمات منتخب`
  String get dashboardAddFavorites {
    return Intl.message(
      'افزودن خدمات منتخب',
      name: 'dashboardAddFavorites',
      desc: '',
      args: [],
    );
  }

  /// `مدیریت کسر اقساط`
  String get dashboardManageInstallments {
    return Intl.message(
      'مدیریت کسر اقساط',
      name: 'dashboardManageInstallments',
      desc: '',
      args: [],
    );
  }

  /// `برآورد اعتبار وام`
  String get dashboardEstimateCredit {
    return Intl.message(
      'برآورد اعتبار وام',
      name: 'dashboardEstimateCredit',
      desc: '',
      args: [],
    );
  }

  /// `گواهی تمکن مالی می‌خوام...`
  String get dashboardPromptCertificate {
    return Intl.message(
      'گواهی تمکن مالی می‌خوام...',
      name: 'dashboardPromptCertificate',
      desc: '',
      args: [],
    );
  }

  /// `چطور کارت رسالت بگیرم؟`
  String get dashboardPromptCard {
    return Intl.message(
      'چطور کارت رسالت بگیرم؟',
      name: 'dashboardPromptCard',
      desc: '',
      args: [],
    );
  }

  /// `تلفن بانک`
  String get dashboardPhoneBank {
    return Intl.message(
      'تلفن بانک',
      name: 'dashboardPhoneBank',
      desc: '',
      args: [],
    );
  }

  /// `لیست کارت‌ها`
  String get dashboardCardsList {
    return Intl.message(
      'لیست کارت‌ها',
      name: 'dashboardCardsList',
      desc: '',
      args: [],
    );
  }

  /// `درخواست کارت مجازی`
  String get dashboardVirtualCard {
    return Intl.message(
      'درخواست کارت مجازی',
      name: 'dashboardVirtualCard',
      desc: '',
      args: [],
    );
  }

  /// `رفع مسدودی کارت`
  String get dashboardUnblockCard {
    return Intl.message(
      'رفع مسدودی کارت',
      name: 'dashboardUnblockCard',
      desc: '',
      args: [],
    );
  }

  /// `واریز مانده کارت هدیه منقضی`
  String get dashboardExpiredGift {
    return Intl.message(
      'واریز مانده کارت هدیه منقضی',
      name: 'dashboardExpiredGift',
      desc: '',
      args: [],
    );
  }

  /// `رفع سوء اثر چک`
  String get dashboardClearCheque {
    return Intl.message(
      'رفع سوء اثر چک',
      name: 'dashboardClearCheque',
      desc: '',
      args: [],
    );
  }

  /// `ابطال چک`
  String get dashboardCancelCheque {
    return Intl.message(
      'ابطال چک',
      name: 'dashboardCancelCheque',
      desc: '',
      args: [],
    );
  }

  /// `انتقال وجه خدمت در محل`
  String get dashboardLocalTransfer {
    return Intl.message(
      'انتقال وجه خدمت در محل',
      name: 'dashboardLocalTransfer',
      desc: '',
      args: [],
    );
  }

  /// `وام‌های من`
  String get dashboardMyLoans {
    return Intl.message(
      'وام‌های من',
      name: 'dashboardMyLoans',
      desc: '',
      args: [],
    );
  }

  /// `گزارش معرفی وام`
  String get dashboardLoanReport {
    return Intl.message(
      'گزارش معرفی وام',
      name: 'dashboardLoanReport',
      desc: '',
      args: [],
    );
  }

  /// `اصلاح اقساط پرداختی`
  String get dashboardCorrectInstallments {
    return Intl.message(
      'اصلاح اقساط پرداختی',
      name: 'dashboardCorrectInstallments',
      desc: '',
      args: [],
    );
  }

  /// `امهال وام`
  String get dashboardDeferLoan {
    return Intl.message(
      'امهال وام',
      name: 'dashboardDeferLoan',
      desc: '',
      args: [],
    );
  }

  /// `لیست سپرده‌ها`
  String get dashboardDepositsList {
    return Intl.message(
      'لیست سپرده‌ها',
      name: 'dashboardDepositsList',
      desc: '',
      args: [],
    );
  }

  /// `افتتاح سپرده جاری`
  String get dashboardOpenCurrent {
    return Intl.message(
      'افتتاح سپرده جاری',
      name: 'dashboardOpenCurrent',
      desc: '',
      args: [],
    );
  }

  /// `بستن سپرده‌های مازاد`
  String get dashboardCloseExtras {
    return Intl.message(
      'بستن سپرده‌های مازاد',
      name: 'dashboardCloseExtras',
      desc: '',
      args: [],
    );
  }

  /// `تنظیمات نمایندگی`
  String get dashboardAgentSettings {
    return Intl.message(
      'تنظیمات نمایندگی',
      name: 'dashboardAgentSettings',
      desc: '',
      args: [],
    );
  }

  /// `رفع مسدودی سپرده`
  String get dashboardUnblockDeposit {
    return Intl.message(
      'رفع مسدودی سپرده',
      name: 'dashboardUnblockDeposit',
      desc: '',
      args: [],
    );
  }

  /// `مسدودی سپرده`
  String get dashboardBlockDeposit {
    return Intl.message(
      'مسدودی سپرده',
      name: 'dashboardBlockDeposit',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات کیف پول`
  String get dashboardWalletInfo {
    return Intl.message(
      'اطلاعات کیف پول',
      name: 'dashboardWalletInfo',
      desc: '',
      args: [],
    );
  }

  /// `افزایش موجودی`
  String get dashboardWalletCharge {
    return Intl.message(
      'افزایش موجودی',
      name: 'dashboardWalletCharge',
      desc: '',
      args: [],
    );
  }

  /// `برداشت موجودی`
  String get dashboardWalletWithdraw {
    return Intl.message(
      'برداشت موجودی',
      name: 'dashboardWalletWithdraw',
      desc: '',
      args: [],
    );
  }

  /// `واریز کیف به کیف`
  String get dashboardWalletTransfer {
    return Intl.message(
      'واریز کیف به کیف',
      name: 'dashboardWalletTransfer',
      desc: '',
      args: [],
    );
  }

  /// `گردش کیف پول`
  String get dashboardWalletHistory {
    return Intl.message(
      'گردش کیف پول',
      name: 'dashboardWalletHistory',
      desc: '',
      args: [],
    );
  }

  /// `تغییر سپرده متصل به کیف`
  String get dashboardWalletDeposit {
    return Intl.message(
      'تغییر سپرده متصل به کیف',
      name: 'dashboardWalletDeposit',
      desc: '',
      args: [],
    );
  }

  /// `تغییر مشخصات هویتی`
  String get dashboardChangeIdentity {
    return Intl.message(
      'تغییر مشخصات هویتی',
      name: 'dashboardChangeIdentity',
      desc: '',
      args: [],
    );
  }

  /// `مدیریت شغل`
  String get dashboardOccupation {
    return Intl.message(
      'مدیریت شغل',
      name: 'dashboardOccupation',
      desc: '',
      args: [],
    );
  }

  /// `مدیریت آدرس`
  String get dashboardAddresses {
    return Intl.message(
      'مدیریت آدرس',
      name: 'dashboardAddresses',
      desc: '',
      args: [],
    );
  }

  /// `تغییر شماره تلفن همراه`
  String get dashboardChangePhone {
    return Intl.message(
      'تغییر شماره تلفن همراه',
      name: 'dashboardChangePhone',
      desc: '',
      args: [],
    );
  }

  /// `درخواست‌های من`
  String get dashboardRequests {
    return Intl.message(
      'درخواست‌های من',
      name: 'dashboardRequests',
      desc: '',
      args: [],
    );
  }

  /// `کارت‌های من`
  String get cardsMyTitle {
    return Intl.message(
      'کارت‌های من',
      name: 'cardsMyTitle',
      desc: '',
      args: [],
    );
  }

  /// `عملیات کارت`
  String get cardsOperations {
    return Intl.message(
      'عملیات کارت',
      name: 'cardsOperations',
      desc: '',
      args: [],
    );
  }

  /// `عملیات رمز`
  String get cardsPinOperations {
    return Intl.message(
      'عملیات رمز',
      name: 'cardsPinOperations',
      desc: '',
      args: [],
    );
  }

  /// `دسترسی سریع`
  String get cardsQuickAccess {
    return Intl.message(
      'دسترسی سریع',
      name: 'cardsQuickAccess',
      desc: '',
      args: [],
    );
  }

  /// `صدور مجدد کارت`
  String get cardsReissue {
    return Intl.message(
      'صدور مجدد کارت',
      name: 'cardsReissue',
      desc: '',
      args: [],
    );
  }

  /// `فراموشی رمز اول`
  String get cardsForgotFirst {
    return Intl.message(
      'فراموشی رمز اول',
      name: 'cardsForgotFirst',
      desc: '',
      args: [],
    );
  }

  /// `تعیین رمز دوم`
  String get cardsSetSecond {
    return Intl.message(
      'تعیین رمز دوم',
      name: 'cardsSetSecond',
      desc: '',
      args: [],
    );
  }

  /// `فراموشی رمز دوم`
  String get cardsForgotSecond {
    return Intl.message(
      'فراموشی رمز دوم',
      name: 'cardsForgotSecond',
      desc: '',
      args: [],
    );
  }

  /// `تغییر رمز اول`
  String get cardsChangeFirst {
    return Intl.message(
      'تغییر رمز اول',
      name: 'cardsChangeFirst',
      desc: '',
      args: [],
    );
  }

  /// `واریز مانده کارت هدیه`
  String get cardsGiftBalance {
    return Intl.message(
      'واریز مانده کارت هدیه',
      name: 'cardsGiftBalance',
      desc: '',
      args: [],
    );
  }

  /// `خرید کارت هدیه`
  String get cardsBuyGift {
    return Intl.message(
      'خرید کارت هدیه',
      name: 'cardsBuyGift',
      desc: '',
      args: [],
    );
  }

  /// `کارت مجازی`
  String get cardsVirtual {
    return Intl.message('کارت مجازی', name: 'cardsVirtual', desc: '', args: []);
  }

  /// `رسالت کارت (جاری)`
  String get cardsCurrent {
    return Intl.message(
      'رسالت کارت (جاری)',
      name: 'cardsCurrent',
      desc: '',
      args: [],
    );
  }

  /// `رسالت کارت (قرض الحسنه)`
  String get cardsQarz {
    return Intl.message(
      'رسالت کارت (قرض الحسنه)',
      name: 'cardsQarz',
      desc: '',
      args: [],
    );
  }

  /// `: انقضا`
  String get cardsExpiry {
    return Intl.message(': انقضا', name: 'cardsExpiry', desc: '', args: []);
  }

  /// `کپی شماره کارت`
  String get cardsCopyNumber {
    return Intl.message(
      'کپی شماره کارت',
      name: 'cardsCopyNumber',
      desc: '',
      args: [],
    );
  }

  /// `کپی شماره شبا`
  String get cardsCopyIban {
    return Intl.message(
      'کپی شماره شبا',
      name: 'cardsCopyIban',
      desc: '',
      args: [],
    );
  }

  /// `نمایش اطلاعات کارت`
  String get cardsShowDetails {
    return Intl.message(
      'نمایش اطلاعات کارت',
      name: 'cardsShowDetails',
      desc: '',
      args: [],
    );
  }

  /// `پنهان کردن اطلاعات کارت`
  String get cardsHideDetails {
    return Intl.message(
      'پنهان کردن اطلاعات کارت',
      name: 'cardsHideDetails',
      desc: '',
      args: [],
    );
  }

  /// `گزینه‌های کارت`
  String get cardsMore {
    return Intl.message(
      'گزینه‌های کارت',
      name: 'cardsMore',
      desc: '',
      args: [],
    );
  }

  /// `هنوز کارتی ندارید`
  String get cardsEmpty {
    return Intl.message(
      'هنوز کارتی ندارید',
      name: 'cardsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `سپرده‌های من`
  String get depositsMyTitle {
    return Intl.message(
      'سپرده‌های من',
      name: 'depositsMyTitle',
      desc: '',
      args: [],
    );
  }

  /// `عملیات سپرده`
  String get depositsOperations {
    return Intl.message(
      'عملیات سپرده',
      name: 'depositsOperations',
      desc: '',
      args: [],
    );
  }

  /// `عملیات چک`
  String get depositsChequeOperations {
    return Intl.message(
      'عملیات چک',
      name: 'depositsChequeOperations',
      desc: '',
      args: [],
    );
  }

  /// `هنوز سپرده‌ای ندارید`
  String get depositsEmpty {
    return Intl.message(
      'هنوز سپرده‌ای ندارید',
      name: 'depositsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `تنظیمات نماینده`
  String get depositsAgent {
    return Intl.message(
      'تنظیمات نماینده',
      name: 'depositsAgent',
      desc: '',
      args: [],
    );
  }

  /// `کارت‌های متصل به سپرده`
  String get depositsLinkedCards {
    return Intl.message(
      'کارت‌های متصل به سپرده',
      name: 'depositsLinkedCards',
      desc: '',
      args: [],
    );
  }

  /// `وضعیت وام‌های متصل`
  String get depositsLinkedLoans {
    return Intl.message(
      'وضعیت وام‌های متصل',
      name: 'depositsLinkedLoans',
      desc: '',
      args: [],
    );
  }

  /// `انتقال وجه خدمت در محل`
  String get depositsLocalTransfer {
    return Intl.message(
      'انتقال وجه خدمت در محل',
      name: 'depositsLocalTransfer',
      desc: '',
      args: [],
    );
  }

  /// `موبایل بانک`
  String get depositsMobileBank {
    return Intl.message(
      'موبایل بانک',
      name: 'depositsMobileBank',
      desc: '',
      args: [],
    );
  }

  /// `کپی شماره سپرده`
  String get depositsCopyNumber {
    return Intl.message(
      'کپی شماره سپرده',
      name: 'depositsCopyNumber',
      desc: '',
      args: [],
    );
  }

  /// `عملیات وام`
  String get loansOperations {
    return Intl.message(
      'عملیات وام',
      name: 'loansOperations',
      desc: '',
      args: [],
    );
  }

  /// `هنوز وامی ندارید`
  String get loansEmpty {
    return Intl.message(
      'هنوز وامی ندارید',
      name: 'loansEmpty',
      desc: '',
      args: [],
    );
  }

  /// `پرداخت اقساط`
  String get loansPayInstallments {
    return Intl.message(
      'پرداخت اقساط',
      name: 'loansPayInstallments',
      desc: '',
      args: [],
    );
  }

  /// `روابط سببی نسبی`
  String get loansRelationships {
    return Intl.message(
      'روابط سببی نسبی',
      name: 'loansRelationships',
      desc: '',
      args: [],
    );
  }

  /// `تسهیلات قرض الحسنه عادی (بدون کارمزد)`
  String get loansDefaultName {
    return Intl.message(
      'تسهیلات قرض الحسنه عادی (بدون کارمزد)',
      name: 'loansDefaultName',
      desc: '',
      args: [],
    );
  }

  /// `تغییر سپرده کسر اقساط`
  String get loansChangeDeposit {
    return Intl.message(
      'تغییر سپرده کسر اقساط',
      name: 'loansChangeDeposit',
      desc: '',
      args: [],
    );
  }

  /// `در حال دریافت اطلاعات…`
  String get dashboardLoading {
    return Intl.message(
      'در حال دریافت اطلاعات…',
      name: 'dashboardLoading',
      desc: '',
      args: [],
    );
  }

  /// `دریافت اطلاعات انجام نشد`
  String get dashboardLoadError {
    return Intl.message(
      'دریافت اطلاعات انجام نشد',
      name: 'dashboardLoadError',
      desc: '',
      args: [],
    );
  }

  /// `تلاش دوباره`
  String get dashboardRetry {
    return Intl.message(
      'تلاش دوباره',
      name: 'dashboardRetry',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعاتی برای نمایش وجود ندارد`
  String get dashboardEmpty {
    return Intl.message(
      'اطلاعاتی برای نمایش وجود ندارد',
      name: 'dashboardEmpty',
      desc: '',
      args: [],
    );
  }

  /// `رسالت کارت`
  String get cardFeatureResalat {
    return Intl.message(
      'رسالت کارت',
      name: 'cardFeatureResalat',
      desc: '',
      args: [],
    );
  }

  /// `کارت هدیه`
  String get cardFeatureGift {
    return Intl.message(
      'کارت هدیه',
      name: 'cardFeatureGift',
      desc: '',
      args: [],
    );
  }

  /// `بن کارت`
  String get cardFeatureCoupon {
    return Intl.message(
      'بن کارت',
      name: 'cardFeatureCoupon',
      desc: '',
      args: [],
    );
  }

  /// `کارت خانواده`
  String get cardFeatureFamily {
    return Intl.message(
      'کارت خانواده',
      name: 'cardFeatureFamily',
      desc: '',
      args: [],
    );
  }

  /// `جزئیات کارت`
  String get cardFeatureDetails {
    return Intl.message(
      'جزئیات کارت',
      name: 'cardFeatureDetails',
      desc: '',
      args: [],
    );
  }

  /// `شماره کارت`
  String get cardFeatureNumber {
    return Intl.message(
      'شماره کارت',
      name: 'cardFeatureNumber',
      desc: '',
      args: [],
    );
  }

  /// `سپرده متصل`
  String get cardFeatureDeposit {
    return Intl.message(
      'سپرده متصل',
      name: 'cardFeatureDeposit',
      desc: '',
      args: [],
    );
  }

  /// `شماره شبا`
  String get cardFeatureIban {
    return Intl.message(
      'شماره شبا',
      name: 'cardFeatureIban',
      desc: '',
      args: [],
    );
  }

  /// `نوع سپرده`
  String get cardFeatureDepositType {
    return Intl.message(
      'نوع سپرده',
      name: 'cardFeatureDepositType',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ انقضا`
  String get cardFeatureExpiry {
    return Intl.message(
      'تاریخ انقضا',
      name: 'cardFeatureExpiry',
      desc: '',
      args: [],
    );
  }

  /// `وضعیت`
  String get cardFeatureStatus {
    return Intl.message('وضعیت', name: 'cardFeatureStatus', desc: '', args: []);
  }

  /// `فعال`
  String get cardFeatureActive {
    return Intl.message('فعال', name: 'cardFeatureActive', desc: '', args: []);
  }

  /// `مسدود`
  String get cardFeatureBlocked {
    return Intl.message(
      'مسدود',
      name: 'cardFeatureBlocked',
      desc: '',
      args: [],
    );
  }

  /// `منقضی`
  String get cardFeatureExpired {
    return Intl.message(
      'منقضی',
      name: 'cardFeatureExpired',
      desc: '',
      args: [],
    );
  }

  /// `قرض الحسنه`
  String get cardFeatureQarz {
    return Intl.message(
      'قرض الحسنه',
      name: 'cardFeatureQarz',
      desc: '',
      args: [],
    );
  }

  /// `فیلتر`
  String get cardFeatureFilter {
    return Intl.message('فیلتر', name: 'cardFeatureFilter', desc: '', args: []);
  }

  /// `حذف فیلتر`
  String get cardFeatureRemoveFilter {
    return Intl.message(
      'حذف فیلتر',
      name: 'cardFeatureRemoveFilter',
      desc: '',
      args: [],
    );
  }

  /// `اعمال فیلتر`
  String get cardFeatureApplyFilter {
    return Intl.message(
      'اعمال فیلتر',
      name: 'cardFeatureApplyFilter',
      desc: '',
      args: [],
    );
  }

  /// `همه`
  String get cardFeatureAll {
    return Intl.message('همه', name: 'cardFeatureAll', desc: '', args: []);
  }

  /// `کارتی با این مشخصات پیدا نشد`
  String get cardFeatureNoResults {
    return Intl.message(
      'کارتی با این مشخصات پیدا نشد',
      name: 'cardFeatureNoResults',
      desc: '',
      args: [],
    );
  }

  /// `وضعیت کارت`
  String get cardFeatureCardStatus {
    return Intl.message(
      'وضعیت کارت',
      name: 'cardFeatureCardStatus',
      desc: '',
      args: [],
    );
  }

  /// `واریز مانده کارت هدیه منقضی`
  String get cardFeatureGiftTransfer {
    return Intl.message(
      'واریز مانده کارت هدیه منقضی',
      name: 'cardFeatureGiftTransfer',
      desc: '',
      args: [],
    );
  }

  /// `درخواست کارت مجازی`
  String get cardFeatureVirtualRequest {
    return Intl.message(
      'درخواست کارت مجازی',
      name: 'cardFeatureVirtualRequest',
      desc: '',
      args: [],
    );
  }

  /// `این خدمت در حال حاضر در دسترس نیست.`
  String get cardFeatureUnavailable {
    return Intl.message(
      'این خدمت در حال حاضر در دسترس نیست.',
      name: 'cardFeatureUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `صدور رسالت کارت`
  String get issuanceTitle {
    return Intl.message(
      'صدور رسالت کارت',
      name: 'issuanceTitle',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب سپرده و نوع صدور کارت`
  String get issuanceSelectionTitle {
    return Intl.message(
      'انتخاب سپرده و نوع صدور کارت',
      name: 'issuanceSelectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات دریافت کارت`
  String get issuanceDeliveryTitle {
    return Intl.message(
      'اطلاعات دریافت کارت',
      name: 'issuanceDeliveryTitle',
      desc: '',
      args: [],
    );
  }

  /// `تایید اطلاعات و پرداخت کارمزد`
  String get issuanceConfirmTitle {
    return Intl.message(
      'تایید اطلاعات و پرداخت کارمزد',
      name: 'issuanceConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `بعدی: اطلاعات دریافت کارت`
  String get issuanceNextDelivery {
    return Intl.message(
      'بعدی: اطلاعات دریافت کارت',
      name: 'issuanceNextDelivery',
      desc: '',
      args: [],
    );
  }

  /// `بعدی: تایید اطلاعات و پرداخت کارمزد`
  String get issuanceNextConfirm {
    return Intl.message(
      'بعدی: تایید اطلاعات و پرداخت کارمزد',
      name: 'issuanceNextConfirm',
      desc: '',
      args: [],
    );
  }

  /// `پایان`
  String get issuanceEnd {
    return Intl.message('پایان', name: 'issuanceEnd', desc: '', args: []);
  }

  /// `انتخاب سپرده`
  String get issuanceDeposit {
    return Intl.message(
      'انتخاب سپرده',
      name: 'issuanceDeposit',
      desc: '',
      args: [],
    );
  }

  /// `سپرده مورد نظر خود را انتخاب کنید`
  String get issuanceDepositHint {
    return Intl.message(
      'سپرده مورد نظر خود را انتخاب کنید',
      name: 'issuanceDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `نوع صدور کارت`
  String get issuanceType {
    return Intl.message(
      'نوع صدور کارت',
      name: 'issuanceType',
      desc: '',
      args: [],
    );
  }

  /// `نوع صدور کارت را مشخص کنید`
  String get issuanceTypeHint {
    return Intl.message(
      'نوع صدور کارت را مشخص کنید',
      name: 'issuanceTypeHint',
      desc: '',
      args: [],
    );
  }

  /// `صدور کارت با شماره جدید`
  String get issuanceNewNumber {
    return Intl.message(
      'صدور کارت با شماره جدید',
      name: 'issuanceNewNumber',
      desc: '',
      args: [],
    );
  }

  /// `صدور کارت با شماره فعلی`
  String get issuanceExistingNumber {
    return Intl.message(
      'صدور کارت با شماره فعلی',
      name: 'issuanceExistingNumber',
      desc: '',
      args: [],
    );
  }

  /// `شماره کارت فعلی`
  String get issuanceCurrentCard {
    return Intl.message(
      'شماره کارت فعلی',
      name: 'issuanceCurrentCard',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ انقضا`
  String get issuanceExpiry {
    return Intl.message(
      'تاریخ انقضا',
      name: 'issuanceExpiry',
      desc: '',
      args: [],
    );
  }

  /// `نیازی به دریافت کارت فیزیکی ندارم`
  String get issuanceNoPhysical {
    return Intl.message(
      'نیازی به دریافت کارت فیزیکی ندارم',
      name: 'issuanceNoPhysical',
      desc: '',
      args: [],
    );
  }

  /// `مرحله بعد`
  String get issuanceNext {
    return Intl.message('مرحله بعد', name: 'issuanceNext', desc: '', args: []);
  }

  /// `آدرس`
  String get issuanceAddress {
    return Intl.message('آدرس', name: 'issuanceAddress', desc: '', args: []);
  }

  /// `انتخاب آدرس`
  String get issuanceSelectAddress {
    return Intl.message(
      'انتخاب آدرس',
      name: 'issuanceSelectAddress',
      desc: '',
      args: [],
    );
  }

  /// `آدرس دریافت کارت را انتخاب کنید`
  String get issuanceAddressHint {
    return Intl.message(
      'آدرس دریافت کارت را انتخاب کنید',
      name: 'issuanceAddressHint',
      desc: '',
      args: [],
    );
  }

  /// `افزودن آدرس جدید`
  String get issuanceAddAddress {
    return Intl.message(
      'افزودن آدرس جدید',
      name: 'issuanceAddAddress',
      desc: '',
      args: [],
    );
  }

  /// `حذف آدرس`
  String get issuanceDeleteAddress {
    return Intl.message(
      'حذف آدرس',
      name: 'issuanceDeleteAddress',
      desc: '',
      args: [],
    );
  }

  /// `دریافت توسط شخص دیگر`
  String get issuanceOtherRecipient {
    return Intl.message(
      'دریافت توسط شخص دیگر',
      name: 'issuanceOtherRecipient',
      desc: '',
      args: [],
    );
  }

  /// `وارد کردن مشخصات کارشناس بانکی`
  String get issuanceIncludeAgent {
    return Intl.message(
      'وارد کردن مشخصات کارشناس بانکی',
      name: 'issuanceIncludeAgent',
      desc: '',
      args: [],
    );
  }

  /// `نام و نام خانوادگی گیرنده`
  String get issuanceRecipientName {
    return Intl.message(
      'نام و نام خانوادگی گیرنده',
      name: 'issuanceRecipientName',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی گیرنده`
  String get issuanceNationalId {
    return Intl.message(
      'کد ملی گیرنده',
      name: 'issuanceNationalId',
      desc: '',
      args: [],
    );
  }

  /// `شماره همراه گیرنده`
  String get issuanceRecipientMobile {
    return Intl.message(
      'شماره همراه گیرنده',
      name: 'issuanceRecipientMobile',
      desc: '',
      args: [],
    );
  }

  /// `نام و نام خانوادگی کارشناس`
  String get issuanceAgentName {
    return Intl.message(
      'نام و نام خانوادگی کارشناس',
      name: 'issuanceAgentName',
      desc: '',
      args: [],
    );
  }

  /// `کد کارشناس`
  String get issuanceAgentCode {
    return Intl.message(
      'کد کارشناس',
      name: 'issuanceAgentCode',
      desc: '',
      args: [],
    );
  }

  /// `عنوان آدرس`
  String get issuanceAddressTitle {
    return Intl.message(
      'عنوان آدرس',
      name: 'issuanceAddressTitle',
      desc: '',
      args: [],
    );
  }

  /// `نشانی کامل`
  String get issuanceAddressDetail {
    return Intl.message(
      'نشانی کامل',
      name: 'issuanceAddressDetail',
      desc: '',
      args: [],
    );
  }

  /// `کد پستی`
  String get issuancePostalCode {
    return Intl.message(
      'کد پستی',
      name: 'issuancePostalCode',
      desc: '',
      args: [],
    );
  }

  /// `ثبت آدرس`
  String get issuanceSaveAddress {
    return Intl.message(
      'ثبت آدرس',
      name: 'issuanceSaveAddress',
      desc: '',
      args: [],
    );
  }

  /// `عنوان، نشانی کامل و کد پستی ۱۰ رقمی را وارد کنید.`
  String get issuanceAddressInvalid {
    return Intl.message(
      'عنوان، نشانی کامل و کد پستی ۱۰ رقمی را وارد کنید.',
      name: 'issuanceAddressInvalid',
      desc: '',
      args: [],
    );
  }

  /// `خلاصه اطلاعات`
  String get issuanceSummary {
    return Intl.message(
      'خلاصه اطلاعات',
      name: 'issuanceSummary',
      desc: '',
      args: [],
    );
  }

  /// `شماره سپرده`
  String get issuanceDepositNumber {
    return Intl.message(
      'شماره سپرده',
      name: 'issuanceDepositNumber',
      desc: '',
      args: [],
    );
  }

  /// `نوع عملیات`
  String get issuanceOperation {
    return Intl.message(
      'نوع عملیات',
      name: 'issuanceOperation',
      desc: '',
      args: [],
    );
  }

  /// `هزینه قابل پرداخت`
  String get issuancePayable {
    return Intl.message(
      'هزینه قابل پرداخت',
      name: 'issuancePayable',
      desc: '',
      args: [],
    );
  }

  /// `موجودی کیف پول`
  String get issuanceWallet {
    return Intl.message(
      'موجودی کیف پول',
      name: 'issuanceWallet',
      desc: '',
      args: [],
    );
  }

  /// `هزینه چاپ گزارش`
  String get issuancePrintFee {
    return Intl.message(
      'هزینه چاپ گزارش',
      name: 'issuancePrintFee',
      desc: '',
      args: [],
    );
  }

  /// `کارمزد احراز هویت`
  String get issuanceIdentityFee {
    return Intl.message(
      'کارمزد احراز هویت',
      name: 'issuanceIdentityFee',
      desc: '',
      args: [],
    );
  }

  /// `هزینه ارسال`
  String get issuanceDeliveryFee {
    return Intl.message(
      'هزینه ارسال',
      name: 'issuanceDeliveryFee',
      desc: '',
      args: [],
    );
  }

  /// `قوانین و مقررات`
  String get issuanceTerms {
    return Intl.message(
      'قوانین و مقررات',
      name: 'issuanceTerms',
      desc: '',
      args: [],
    );
  }

  /// `درخواست را مطالعه و تایید می‌نمایم.`
  String get issuanceTermsPrompt {
    return Intl.message(
      'درخواست را مطالعه و تایید می‌نمایم.',
      name: 'issuanceTermsPrompt',
      desc: '',
      args: [],
    );
  }

  /// `متن رسمی قوانین پس از اتصال به سرویس نمایش داده می‌شود.`
  String get issuanceTermsUnavailable {
    return Intl.message(
      'متن رسمی قوانین پس از اتصال به سرویس نمایش داده می‌شود.',
      name: 'issuanceTermsUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `تایید و ثبت درخواست`
  String get issuanceSubmit {
    return Intl.message(
      'تایید و ثبت درخواست',
      name: 'issuanceSubmit',
      desc: '',
      args: [],
    );
  }

  /// `ثبت درخواست انجام نشد. دوباره تلاش کنید.`
  String get issuanceSubmitError {
    return Intl.message(
      'ثبت درخواست انجام نشد. دوباره تلاش کنید.',
      name: 'issuanceSubmitError',
      desc: '',
      args: [],
    );
  }

  /// `سپرده‌ای برای صدور کارت در دسترس نیست.`
  String get issuanceEmpty {
    return Intl.message(
      'سپرده‌ای برای صدور کارت در دسترس نیست.',
      name: 'issuanceEmpty',
      desc: '',
      args: [],
    );
  }

  /// `پیش‌نمایش درخواست تکمیل شد؛ پرداخت یا صدور واقعی انجام نشده است.`
  String get issuanceMockComplete {
    return Intl.message(
      'پیش‌نمایش درخواست تکمیل شد؛ پرداخت یا صدور واقعی انجام نشده است.',
      name: 'issuanceMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `درخواست ثبت شد.`
  String get issuanceComplete {
    return Intl.message(
      'درخواست ثبت شد.',
      name: 'issuanceComplete',
      desc: '',
      args: [],
    );
  }

  /// `بازگشت`
  String get issuanceDone {
    return Intl.message('بازگشت', name: 'issuanceDone', desc: '', args: []);
  }

  /// `موجودی کیف پول کافی است`
  String get issuanceWalletSufficient {
    return Intl.message(
      'موجودی کیف پول کافی است',
      name: 'issuanceWalletSufficient',
      desc: '',
      args: [],
    );
  }

  /// `موجودی کیف پول کافی نیست`
  String get issuanceWalletInsufficient {
    return Intl.message(
      'موجودی کیف پول کافی نیست',
      name: 'issuanceWalletInsufficient',
      desc: '',
      args: [],
    );
  }

  /// `مرحله {current} از {total}، {title}`
  String issuanceStepSemantic(int current, int total, String title) {
    return Intl.message(
      'مرحله $current از $total، $title',
      name: 'issuanceStepSemantic',
      desc: '',
      args: [current, total, title],
    );
  }

  /// `عملیات رمز`
  String get passwordTitle {
    return Intl.message(
      'عملیات رمز',
      name: 'passwordTitle',
      desc: '',
      args: [],
    );
  }

  /// `کارت مورد نظر و نوع رمز را انتخاب کنید`
  String get passwordSelectionPrompt {
    return Intl.message(
      'کارت مورد نظر و نوع رمز را انتخاب کنید',
      name: 'passwordSelectionPrompt',
      desc: '',
      args: [],
    );
  }

  /// `نوع کارت`
  String get passwordCardType {
    return Intl.message(
      'نوع کارت',
      name: 'passwordCardType',
      desc: '',
      args: [],
    );
  }

  /// `نوع کارت خود را انتخاب کنید`
  String get passwordCardTypeHint {
    return Intl.message(
      'نوع کارت خود را انتخاب کنید',
      name: 'passwordCardTypeHint',
      desc: '',
      args: [],
    );
  }

  /// `شماره کارت`
  String get passwordCardNumber {
    return Intl.message(
      'شماره کارت',
      name: 'passwordCardNumber',
      desc: '',
      args: [],
    );
  }

  /// `شماره کارت مورد نظر خود را انتخاب کنید`
  String get passwordCardNumberHint {
    return Intl.message(
      'شماره کارت مورد نظر خود را انتخاب کنید',
      name: 'passwordCardNumberHint',
      desc: '',
      args: [],
    );
  }

  /// `نوع رمز`
  String get passwordType {
    return Intl.message('نوع رمز', name: 'passwordType', desc: '', args: []);
  }

  /// `نوع رمز را انتخاب کنید`
  String get passwordTypeHint {
    return Intl.message(
      'نوع رمز را انتخاب کنید',
      name: 'passwordTypeHint',
      desc: '',
      args: [],
    );
  }

  /// `رمز اول`
  String get passwordFirst {
    return Intl.message('رمز اول', name: 'passwordFirst', desc: '', args: []);
  }

  /// `رمز دوم`
  String get passwordSecond {
    return Intl.message('رمز دوم', name: 'passwordSecond', desc: '', args: []);
  }

  /// `این رمز برای انجام تراکنش‌های حضوری مانند برداشت وجه از خودپرداز و خرید از فروشگاه‌ها با دستگاه پوز استفاده می‌شود.`
  String get passwordFirstDescription {
    return Intl.message(
      'این رمز برای انجام تراکنش‌های حضوری مانند برداشت وجه از خودپرداز و خرید از فروشگاه‌ها با دستگاه پوز استفاده می‌شود.',
      name: 'passwordFirstDescription',
      desc: '',
      args: [],
    );
  }

  /// `این رمز برای انجام تراکنش‌های آنلاین و اینترنتی زیر ۱۰۰ هزار تومان به کار می‌رود.`
  String get passwordSecondDescription {
    return Intl.message(
      'این رمز برای انجام تراکنش‌های آنلاین و اینترنتی زیر ۱۰۰ هزار تومان به کار می‌رود.',
      name: 'passwordSecondDescription',
      desc: '',
      args: [],
    );
  }

  /// `نوع عملیات`
  String get passwordOperation {
    return Intl.message(
      'نوع عملیات',
      name: 'passwordOperation',
      desc: '',
      args: [],
    );
  }

  /// `درخواست کارت مجازی`
  String get virtualRequestTitle {
    return Intl.message(
      'درخواست کارت مجازی',
      name: 'virtualRequestTitle',
      desc: '',
      args: [],
    );
  }

  /// `سپرده‌ی موردنظر برای صدور کارت مجازی و تعداد کارت مجازی را انتخاب کنید و مراحل را ادامه دهید.`
  String get virtualRequestPrompt {
    return Intl.message(
      'سپرده‌ی موردنظر برای صدور کارت مجازی و تعداد کارت مجازی را انتخاب کنید و مراحل را ادامه دهید.',
      name: 'virtualRequestPrompt',
      desc: '',
      args: [],
    );
  }

  /// `کارت مجازی فاقد فیزیک بوده و تنها یک شماره می باشد که می توان به آن شماره فقط واریز وجه انجام داد و برداشت یا خرید با این کارت امکان پذیر نمیباشد.`
  String get virtualRequestNotice {
    return Intl.message(
      'کارت مجازی فاقد فیزیک بوده و تنها یک شماره می باشد که می توان به آن شماره فقط واریز وجه انجام داد و برداشت یا خرید با این کارت امکان پذیر نمیباشد.',
      name: 'virtualRequestNotice',
      desc: '',
      args: [],
    );
  }

  /// `سپرده`
  String get virtualRequestDepositLabel {
    return Intl.message(
      'سپرده',
      name: 'virtualRequestDepositLabel',
      desc: '',
      args: [],
    );
  }

  /// `سپرده مورد نظر خود را انتخاب کنید`
  String get virtualRequestDepositHint {
    return Intl.message(
      'سپرده مورد نظر خود را انتخاب کنید',
      name: 'virtualRequestDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `تعداد کارت مجازی`
  String get virtualRequestCount {
    return Intl.message(
      'تعداد کارت مجازی',
      name: 'virtualRequestCount',
      desc: '',
      args: [],
    );
  }

  /// `تعداد کارت مجازی مورد نیاز خود را وارد کنید`
  String get virtualRequestCountHint {
    return Intl.message(
      'تعداد کارت مجازی مورد نیاز خود را وارد کنید',
      name: 'virtualRequestCountHint',
      desc: '',
      args: [],
    );
  }

  /// `کارمزد صدور هر کارت {amount} است`
  String virtualRequestFeeNotice(String amount) {
    return Intl.message(
      'کارمزد صدور هر کارت $amount است',
      name: 'virtualRequestFeeNotice',
      desc: '',
      args: [amount],
    );
  }

  /// `کارمزد صدور هر کارت`
  String get virtualRequestUnitFee {
    return Intl.message(
      'کارمزد صدور هر کارت',
      name: 'virtualRequestUnitFee',
      desc: '',
      args: [],
    );
  }

  /// `تایید و ثبت درخواست`
  String get virtualRequestSubmit {
    return Intl.message(
      'تایید و ثبت درخواست',
      name: 'virtualRequestSubmit',
      desc: '',
      args: [],
    );
  }

  /// `هیچ سپرده‌ای برای صدور کارت مجازی موجود نیست.`
  String get virtualRequestEmpty {
    return Intl.message(
      'هیچ سپرده‌ای برای صدور کارت مجازی موجود نیست.',
      name: 'virtualRequestEmpty',
      desc: '',
      args: [],
    );
  }

  /// `تعداد کارت باید بین ۱ و {max} باشد.`
  String virtualRequestCountError(int max) {
    return Intl.message(
      'تعداد کارت باید بین ۱ و $max باشد.',
      name: 'virtualRequestCountError',
      desc: '',
      args: [max],
    );
  }

  /// `در حال دریافت هزینه درخواست…`
  String get virtualRequestQuoting {
    return Intl.message(
      'در حال دریافت هزینه درخواست…',
      name: 'virtualRequestQuoting',
      desc: '',
      args: [],
    );
  }

  /// `درخواست ثبت شد`
  String get virtualRequestSubmitted {
    return Intl.message(
      'درخواست ثبت شد',
      name: 'virtualRequestSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `درخواست آزمایشی ثبت شد؛ کارت مجازی ایجاد نشده و مبلغی پرداخت نمی‌شود.`
  String get virtualRequestMockReceipt {
    return Intl.message(
      'درخواست آزمایشی ثبت شد؛ کارت مجازی ایجاد نشده و مبلغی پرداخت نمی‌شود.',
      name: 'virtualRequestMockReceipt',
      desc: '',
      args: [],
    );
  }

  /// `کد پیگیری درخواست:`
  String get virtualRequestReceipt {
    return Intl.message(
      'کد پیگیری درخواست:',
      name: 'virtualRequestReceipt',
      desc: '',
      args: [],
    );
  }

  /// `رمز عبور فعلی و رمز جدید دلخواه خود را وارد کنید.`
  String get passwordChangePrompt {
    return Intl.message(
      'رمز عبور فعلی و رمز جدید دلخواه خود را وارد کنید.',
      name: 'passwordChangePrompt',
      desc: '',
      args: [],
    );
  }

  /// `رمز عبور فعلی`
  String get passwordCurrentHint {
    return Intl.message(
      'رمز عبور فعلی',
      name: 'passwordCurrentHint',
      desc: '',
      args: [],
    );
  }

  /// `رمز عبور جدید`
  String get passwordNewHint {
    return Intl.message(
      'رمز عبور جدید',
      name: 'passwordNewHint',
      desc: '',
      args: [],
    );
  }

  /// `تکرار رمز عبور جدید`
  String get passwordNewConfirmationHint {
    return Intl.message(
      'تکرار رمز عبور جدید',
      name: 'passwordNewConfirmationHint',
      desc: '',
      args: [],
    );
  }

  /// `ثبت درخواست`
  String get passwordChangeSubmit {
    return Intl.message(
      'ثبت درخواست',
      name: 'passwordChangeSubmit',
      desc: '',
      args: [],
    );
  }

  /// `تغییر رمز شما با موفقیت انجام شد.`
  String get passwordChangeSuccessBody {
    return Intl.message(
      'تغییر رمز شما با موفقیت انجام شد.',
      name: 'passwordChangeSuccessBody',
      desc: '',
      args: [],
    );
  }

  /// `درخواست شما با موفقیت ثبت شد.`
  String get passwordStatusRegisteredTitle {
    return Intl.message(
      'درخواست شما با موفقیت ثبت شد.',
      name: 'passwordStatusRegisteredTitle',
      desc: '',
      args: [],
    );
  }

  /// `نوع عملیات را مشخص کنید`
  String get passwordOperationHint {
    return Intl.message(
      'نوع عملیات را مشخص کنید',
      name: 'passwordOperationHint',
      desc: '',
      args: [],
    );
  }

  /// `تغییر رمز عبور`
  String get passwordChange {
    return Intl.message(
      'تغییر رمز عبور',
      name: 'passwordChange',
      desc: '',
      args: [],
    );
  }

  /// `فراموشی رمز عبور`
  String get passwordForgot {
    return Intl.message(
      'فراموشی رمز عبور',
      name: 'passwordForgot',
      desc: '',
      args: [],
    );
  }

  /// `تعیین رمز دوم`
  String get passwordSetSecond {
    return Intl.message(
      'تعیین رمز دوم',
      name: 'passwordSetSecond',
      desc: '',
      args: [],
    );
  }

  /// `رمز دوم دلخواه خود را وارد کنید.`
  String get passwordPrompt {
    return Intl.message(
      'رمز دوم دلخواه خود را وارد کنید.',
      name: 'passwordPrompt',
      desc: '',
      args: [],
    );
  }

  /// `رمز عبور`
  String get passwordValueHint {
    return Intl.message(
      'رمز عبور',
      name: 'passwordValueHint',
      desc: '',
      args: [],
    );
  }

  /// `تکرار رمز عبور`
  String get passwordConfirmationHint {
    return Intl.message(
      'تکرار رمز عبور',
      name: 'passwordConfirmationHint',
      desc: '',
      args: [],
    );
  }

  /// `شامل ۴ تا ۶ عدد باشد`
  String get passwordLengthRule {
    return Intl.message(
      'شامل ۴ تا ۶ عدد باشد',
      name: 'passwordLengthRule',
      desc: '',
      args: [],
    );
  }

  /// `شامل اعداد متوالی یا تکراری نباشد`
  String get passwordPatternRule {
    return Intl.message(
      'شامل اعداد متوالی یا تکراری نباشد',
      name: 'passwordPatternRule',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ معنادار نباشد (تاریخ تولد، تاریخ انقضای کارت)`
  String get passwordDateRule {
    return Intl.message(
      'تاریخ معنادار نباشد (تاریخ تولد، تاریخ انقضای کارت)',
      name: 'passwordDateRule',
      desc: '',
      args: [],
    );
  }

  /// `رمز عبور و تکرار آن یکسان نیست.`
  String get passwordMismatch {
    return Intl.message(
      'رمز عبور و تکرار آن یکسان نیست.',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `نمایش رمز`
  String get passwordShow {
    return Intl.message('نمایش رمز', name: 'passwordShow', desc: '', args: []);
  }

  /// `پنهان کردن رمز`
  String get passwordHide {
    return Intl.message(
      'پنهان کردن رمز',
      name: 'passwordHide',
      desc: '',
      args: [],
    );
  }

  /// `سریال درج شده پشت کارت ملی یا کد پیگیری رسید کارت ملی خود را وارد کنید.`
  String get passwordSerialPrompt {
    return Intl.message(
      'سریال درج شده پشت کارت ملی یا کد پیگیری رسید کارت ملی خود را وارد کنید.',
      name: 'passwordSerialPrompt',
      desc: '',
      args: [],
    );
  }

  /// `سریال پشت کارت ملی | کد پیگیری رسید کارت ملی`
  String get passwordSerialHint {
    return Intl.message(
      'سریال پشت کارت ملی | کد پیگیری رسید کارت ملی',
      name: 'passwordSerialHint',
      desc: '',
      args: [],
    );
  }

  /// `شامل عدد و یک حرف لاتین می‌باشد`
  String get passwordSerialHelper {
    return Intl.message(
      'شامل عدد و یک حرف لاتین می‌باشد',
      name: 'passwordSerialHelper',
      desc: '',
      args: [],
    );
  }

  /// `سریال معتبر شامل عدد و یک حرف لاتین وارد کنید.`
  String get passwordSerialError {
    return Intl.message(
      'سریال معتبر شامل عدد و یک حرف لاتین وارد کنید.',
      name: 'passwordSerialError',
      desc: '',
      args: [],
    );
  }

  /// `پس از دیدن ویدئو آموزشی مراحل احراز هویت شما شروع می‌شود.`
  String get passwordInstructionPrompt {
    return Intl.message(
      'پس از دیدن ویدئو آموزشی مراحل احراز هویت شما شروع می‌شود.',
      name: 'passwordInstructionPrompt',
      desc: '',
      args: [],
    );
  }

  /// `این مرحله نیازمند دوربین و میکروفون است.`
  String get passwordCameraNotice {
    return Intl.message(
      'این مرحله نیازمند دوربین و میکروفون است.',
      name: 'passwordCameraNotice',
      desc: '',
      args: [],
    );
  }

  /// `شروع احراز هویت`
  String get passwordStartKyc {
    return Intl.message(
      'شروع احراز هویت',
      name: 'passwordStartKyc',
      desc: '',
      args: [],
    );
  }

  /// `در صورت تایید ویدئو درخواست خود را ثبت کنید.`
  String get passwordRecordingPrompt {
    return Intl.message(
      'در صورت تایید ویدئو درخواست خود را ثبت کنید.',
      name: 'passwordRecordingPrompt',
      desc: '',
      args: [],
    );
  }

  /// `ضبط مجدد`
  String get passwordRecordAgain {
    return Intl.message(
      'ضبط مجدد',
      name: 'passwordRecordAgain',
      desc: '',
      args: [],
    );
  }

  /// `ارسال و ثبت درخواست`
  String get passwordSubmit {
    return Intl.message(
      'ارسال و ثبت درخواست',
      name: 'passwordSubmit',
      desc: '',
      args: [],
    );
  }

  /// `ضبط و احراز هویت آزمایشی است؛ هیچ ویدئویی از شما ثبت نمی‌شود.`
  String get passwordMockKyc {
    return Intl.message(
      'ضبط و احراز هویت آزمایشی است؛ هیچ ویدئویی از شما ثبت نمی‌شود.',
      name: 'passwordMockKyc',
      desc: '',
      args: [],
    );
  }

  /// `تایید نمونه آزمایشی`
  String get passwordConfirmMock {
    return Intl.message(
      'تایید نمونه آزمایشی',
      name: 'passwordConfirmMock',
      desc: '',
      args: [],
    );
  }

  /// `شما یک درخواست اعتبارسنجی باز دارید`
  String get passwordPendingTitle {
    return Intl.message(
      'شما یک درخواست اعتبارسنجی باز دارید',
      name: 'passwordPendingTitle',
      desc: '',
      args: [],
    );
  }

  /// `• پس از مشخص شدن نتیجه اعتبارسنجی، در صورت تایید هویت پیامک حاوی اطلاعات رمز برای شما ارسال می‌شود.\n• در صورت تایید اعتبارسنجی شما می‌توانید در همین مدت، از سایر خدمات پیشخوان که مستلزم احراز هویت هستند بدون پرداخت مجدد استفاده کنید.`
  String get passwordPendingBody {
    return Intl.message(
      '• پس از مشخص شدن نتیجه اعتبارسنجی، در صورت تایید هویت پیامک حاوی اطلاعات رمز برای شما ارسال می‌شود.\n• در صورت تایید اعتبارسنجی شما می‌توانید در همین مدت، از سایر خدمات پیشخوان که مستلزم احراز هویت هستند بدون پرداخت مجدد استفاده کنید.',
      name: 'passwordPendingBody',
      desc: '',
      args: [],
    );
  }

  /// `درخواست شما ارسال شد`
  String get passwordSubmittedTitle {
    return Intl.message(
      'درخواست شما ارسال شد',
      name: 'passwordSubmittedTitle',
      desc: '',
      args: [],
    );
  }

  /// `پس از مشخص شدن نتیجه اعتبارسنجی، در صورت تایید هویت پیامک حاوی نام کاربری و رمز ورود به موبایل بانک برای شما ارسال می‌شود. پس از دریافت پیامک شما قادر خواهید بود با نام کاربری و رمزی دریافتی در پیامک به موبایل بانک خود وارد شوید.`
  String get passwordSubmittedBody {
    return Intl.message(
      'پس از مشخص شدن نتیجه اعتبارسنجی، در صورت تایید هویت پیامک حاوی نام کاربری و رمز ورود به موبایل بانک برای شما ارسال می‌شود. پس از دریافت پیامک شما قادر خواهید بود با نام کاربری و رمزی دریافتی در پیامک به موبایل بانک خود وارد شوید.',
      name: 'passwordSubmittedBody',
      desc: '',
      args: [],
    );
  }

  /// `درخواست شما با موفقیت انجام شد`
  String get passwordApprovedTitle {
    return Intl.message(
      'درخواست شما با موفقیت انجام شد',
      name: 'passwordApprovedTitle',
      desc: '',
      args: [],
    );
  }

  /// `پیامک حاوی نام کاربری و رمز ورود به موبایل بانک برای شما ارسال می‌شود. پس از دریافت پیامک شما قادر خواهید بود با نام کاربری و رمزی دریافتی در پیامک به موبایل بانک خود وارد شوید.`
  String get passwordApprovedBody {
    return Intl.message(
      'پیامک حاوی نام کاربری و رمز ورود به موبایل بانک برای شما ارسال می‌شود. پس از دریافت پیامک شما قادر خواهید بود با نام کاربری و رمزی دریافتی در پیامک به موبایل بانک خود وارد شوید.',
      name: 'passwordApprovedBody',
      desc: '',
      args: [],
    );
  }

  /// `کد پیگیری`
  String get passwordTracking {
    return Intl.message(
      'کد پیگیری',
      name: 'passwordTracking',
      desc: '',
      args: [],
    );
  }

  /// `متوجه شدم`
  String get passwordUnderstood {
    return Intl.message(
      'متوجه شدم',
      name: 'passwordUnderstood',
      desc: '',
      args: [],
    );
  }

  /// `این نتیجه آزمایشی است؛ رمز بانکی تنظیم نشده و پیامکی ارسال نمی‌شود.`
  String get passwordMockReceipt {
    return Intl.message(
      'این نتیجه آزمایشی است؛ رمز بانکی تنظیم نشده و پیامکی ارسال نمی‌شود.',
      name: 'passwordMockReceipt',
      desc: '',
      args: [],
    );
  }

  /// `ویدئوی نمونه: Big Buck Bunny — Blender Foundation (CC BY 3.0)`
  String get passwordDemoVideo {
    return Intl.message(
      'ویدئوی نمونه: Big Buck Bunny — Blender Foundation (CC BY 3.0)',
      name: 'passwordDemoVideo',
      desc: '',
      args: [],
    );
  }

  /// `پخش ویدئو`
  String get passwordPlay {
    return Intl.message('پخش ویدئو', name: 'passwordPlay', desc: '', args: []);
  }

  /// `توقف ویدئو`
  String get passwordPause {
    return Intl.message(
      'توقف ویدئو',
      name: 'passwordPause',
      desc: '',
      args: [],
    );
  }

  /// `موقعیت پخش`
  String get passwordSeek {
    return Intl.message('موقعیت پخش', name: 'passwordSeek', desc: '', args: []);
  }

  /// `ویدئو در دسترس نیست`
  String get passwordVideoUnavailable {
    return Intl.message(
      'ویدئو در دسترس نیست',
      name: 'passwordVideoUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `این عملیات برای کارت انتخاب‌شده در دسترس نیست.`
  String get passwordUnsupported {
    return Intl.message(
      'این عملیات برای کارت انتخاب‌شده در دسترس نیست.',
      name: 'passwordUnsupported',
      desc: '',
      args: [],
    );
  }

  /// `خروج از عملیات رمز؟`
  String get passwordExitTitle {
    return Intl.message(
      'خروج از عملیات رمز؟',
      name: 'passwordExitTitle',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات واردشده پاک می‌شود.`
  String get passwordExitBody {
    return Intl.message(
      'اطلاعات واردشده پاک می‌شود.',
      name: 'passwordExitBody',
      desc: '',
      args: [],
    );
  }

  /// `خروج`
  String get passwordExit {
    return Intl.message('خروج', name: 'passwordExit', desc: '', args: []);
  }

  /// `ادامه عملیات`
  String get passwordStay {
    return Intl.message(
      'ادامه عملیات',
      name: 'passwordStay',
      desc: '',
      args: [],
    );
  }

  /// `تغییر سپرده متصل به کارت`
  String get changeCardDepositTitle {
    return Intl.message(
      'تغییر سپرده متصل به کارت',
      name: 'changeCardDepositTitle',
      desc: '',
      args: [],
    );
  }

  /// `ابتدا کارت را انتخاب کنید، سپس سپرده‌ای که می‌خواهید به آن وصل شود را انتخاب کنید.`
  String get changeCardDepositIntro {
    return Intl.message(
      'ابتدا کارت را انتخاب کنید، سپس سپرده‌ای که می‌خواهید به آن وصل شود را انتخاب کنید.',
      name: 'changeCardDepositIntro',
      desc: '',
      args: [],
    );
  }

  /// `کارت`
  String get cardServiceCard {
    return Intl.message('کارت', name: 'cardServiceCard', desc: '', args: []);
  }

  /// `کارت مورد نظر خود را انتخاب کنید`
  String get cardServiceCardHint {
    return Intl.message(
      'کارت مورد نظر خود را انتخاب کنید',
      name: 'cardServiceCardHint',
      desc: '',
      args: [],
    );
  }

  /// `از سپرده`
  String get cardServiceFromDeposit {
    return Intl.message(
      'از سپرده',
      name: 'cardServiceFromDeposit',
      desc: '',
      args: [],
    );
  }

  /// `به سپرده`
  String get cardServiceToDeposit {
    return Intl.message(
      'به سپرده',
      name: 'cardServiceToDeposit',
      desc: '',
      args: [],
    );
  }

  /// `سپرده‌ای که مایل هستید متصل به کارت باشد`
  String get cardServiceToDepositHint {
    return Intl.message(
      'سپرده‌ای که مایل هستید متصل به کارت باشد',
      name: 'cardServiceToDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `سپرده قرض الحسنه`
  String get cardServiceQarzDeposit {
    return Intl.message(
      'سپرده قرض الحسنه',
      name: 'cardServiceQarzDeposit',
      desc: '',
      args: [],
    );
  }

  /// `سپرده جاری`
  String get cardServiceCurrentDeposit {
    return Intl.message(
      'سپرده جاری',
      name: 'cardServiceCurrentDeposit',
      desc: '',
      args: [],
    );
  }

  /// `موردی برای نمایش وجود ندارد.`
  String get cardServiceEmpty {
    return Intl.message(
      'موردی برای نمایش وجود ندارد.',
      name: 'cardServiceEmpty',
      desc: '',
      args: [],
    );
  }

  /// `تایید و ثبت درخواست`
  String get cardServiceSubmit {
    return Intl.message(
      'تایید و ثبت درخواست',
      name: 'cardServiceSubmit',
      desc: '',
      args: [],
    );
  }

  /// `ثبت درخواست انجام نشد. دوباره تلاش کنید.`
  String get cardServiceSubmitError {
    return Intl.message(
      'ثبت درخواست انجام نشد. دوباره تلاش کنید.',
      name: 'cardServiceSubmitError',
      desc: '',
      args: [],
    );
  }

  /// `درخواست آزمایشی ثبت شد؛ عملیات بانکی انجام نشده است.`
  String get cardServiceMockComplete {
    return Intl.message(
      'درخواست آزمایشی ثبت شد؛ عملیات بانکی انجام نشده است.',
      name: 'cardServiceMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `درخواست با موفقیت ثبت شد.`
  String get cardServiceComplete {
    return Intl.message(
      'درخواست با موفقیت ثبت شد.',
      name: 'cardServiceComplete',
      desc: '',
      args: [],
    );
  }

  /// `واریز مانده کارت هدیه منقضی`
  String get giftBalanceTitle {
    return Intl.message(
      'واریز مانده کارت هدیه منقضی',
      name: 'giftBalanceTitle',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب کارت‌ها`
  String get giftBalanceSelection {
    return Intl.message(
      'انتخاب کارت‌ها',
      name: 'giftBalanceSelection',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب سپرده جهت واریز`
  String get giftBalanceDestination {
    return Intl.message(
      'انتخاب سپرده جهت واریز',
      name: 'giftBalanceDestination',
      desc: '',
      args: [],
    );
  }

  /// `بعدی: انتخاب سپرده جهت واریز`
  String get giftBalanceNextDestination {
    return Intl.message(
      'بعدی: انتخاب سپرده جهت واریز',
      name: 'giftBalanceNextDestination',
      desc: '',
      args: [],
    );
  }

  /// `کارت‌های هدیه منقضی شده را انتخاب کنید`
  String get giftBalanceIntro {
    return Intl.message(
      'کارت‌های هدیه منقضی شده را انتخاب کنید',
      name: 'giftBalanceIntro',
      desc: '',
      args: [],
    );
  }

  /// `جستجو بر اساس شماره کارت`
  String get giftBalanceSearch {
    return Intl.message(
      'جستجو بر اساس شماره کارت',
      name: 'giftBalanceSearch',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب همه`
  String get giftBalanceSelectAll {
    return Intl.message(
      'انتخاب همه',
      name: 'giftBalanceSelectAll',
      desc: '',
      args: [],
    );
  }

  /// `مانده موجودی (ریال)`
  String get giftBalanceRemaining {
    return Intl.message(
      'مانده موجودی (ریال)',
      name: 'giftBalanceRemaining',
      desc: '',
      args: [],
    );
  }

  /// `تعداد کارت هدیه منقضی`
  String get giftBalanceCount {
    return Intl.message(
      'تعداد کارت هدیه منقضی',
      name: 'giftBalanceCount',
      desc: '',
      args: [],
    );
  }

  /// `مجموع مبلغ (ریال)`
  String get giftBalanceTotal {
    return Intl.message(
      'مجموع مبلغ (ریال)',
      name: 'giftBalanceTotal',
      desc: '',
      args: [],
    );
  }

  /// `انتقال به`
  String get giftBalanceTransferTo {
    return Intl.message(
      'انتقال به',
      name: 'giftBalanceTransferTo',
      desc: '',
      args: [],
    );
  }

  /// `سپرده مورد نظر خود را انتخاب کنید`
  String get giftBalanceDepositHint {
    return Intl.message(
      'سپرده مورد نظر خود را انتخاب کنید',
      name: 'giftBalanceDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `مرحله بعد`
  String get giftBalanceNext {
    return Intl.message(
      'مرحله بعد',
      name: 'giftBalanceNext',
      desc: '',
      args: [],
    );
  }

  /// `ثبت درخواست`
  String get giftBalanceSubmit {
    return Intl.message(
      'ثبت درخواست',
      name: 'giftBalanceSubmit',
      desc: '',
      args: [],
    );
  }

  /// `پایان`
  String get giftBalanceEnd {
    return Intl.message('پایان', name: 'giftBalanceEnd', desc: '', args: []);
  }

  /// `لیست کارت‌های انتخاب شده ({count})`
  String giftBalanceSelectedList(int count) {
    return Intl.message(
      'لیست کارت‌های انتخاب شده ($count)',
      name: 'giftBalanceSelectedList',
      desc: '',
      args: [count],
    );
  }

  /// `حذف کارت {number}`
  String giftBalanceRemoveCard(String number) {
    return Intl.message(
      'حذف کارت $number',
      name: 'giftBalanceRemoveCard',
      desc: '',
      args: [number],
    );
  }

  /// `جزئیات حساب`
  String get depositListAccountDetails {
    return Intl.message(
      'جزئیات حساب',
      name: 'depositListAccountDetails',
      desc: '',
      args: [],
    );
  }

  /// `نوع حساب`
  String get depositListAccountType {
    return Intl.message(
      'نوع حساب',
      name: 'depositListAccountType',
      desc: '',
      args: [],
    );
  }

  /// `مسدودی سپرده`
  String get depositListBlock {
    return Intl.message(
      'مسدودی سپرده',
      name: 'depositListBlock',
      desc: '',
      args: [],
    );
  }

  /// `مسدود`
  String get depositListBlocked {
    return Intl.message(
      'مسدود',
      name: 'depositListBlocked',
      desc: '',
      args: [],
    );
  }

  /// `بسته`
  String get depositListClosed {
    return Intl.message('بسته', name: 'depositListClosed', desc: '', args: []);
  }

  /// `جاری حقیقی`
  String get depositListCurrent {
    return Intl.message(
      'جاری حقیقی',
      name: 'depositListCurrent',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات مشتری`
  String get depositListCustomerInformation {
    return Intl.message(
      'اطلاعات مشتری',
      name: 'depositListCustomerInformation',
      desc: '',
      args: [],
    );
  }

  /// `کارت‌های متصل به حساب`
  String get depositListLinkedCards {
    return Intl.message(
      'کارت‌های متصل به حساب',
      name: 'depositListLinkedCards',
      desc: '',
      args: [],
    );
  }

  /// `کدملی`
  String get depositListNationalId {
    return Intl.message(
      'کدملی',
      name: 'depositListNationalId',
      desc: '',
      args: [],
    );
  }

  /// `سپرده‌ای با این فیلترها پیدا نشد.`
  String get depositListNoMatches {
    return Intl.message(
      'سپرده‌ای با این فیلترها پیدا نشد.',
      name: 'depositListNoMatches',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات صاحبان حساب در دسترس نیست.`
  String get depositListNoOwners {
    return Intl.message(
      'اطلاعات صاحبان حساب در دسترس نیست.',
      name: 'depositListNoOwners',
      desc: '',
      args: [],
    );
  }

  /// `شماره سپرده`
  String get depositListNumber {
    return Intl.message(
      'شماره سپرده',
      name: 'depositListNumber',
      desc: '',
      args: [],
    );
  }

  /// `باز`
  String get depositListOpen {
    return Intl.message('باز', name: 'depositListOpen', desc: '', args: []);
  }

  /// `صاحب سپرده`
  String get depositListOwner {
    return Intl.message(
      'صاحب سپرده',
      name: 'depositListOwner',
      desc: '',
      args: [],
    );
  }

  /// `صاحب سپرده و امضا`
  String get depositListOwnerAndSignatory {
    return Intl.message(
      'صاحب سپرده و امضا',
      name: 'depositListOwnerAndSignatory',
      desc: '',
      args: [],
    );
  }

  /// `نام`
  String get depositListOwnerName {
    return Intl.message(
      'نام',
      name: 'depositListOwnerName',
      desc: '',
      args: [],
    );
  }

  /// `درصد`
  String get depositListOwnerPercent {
    return Intl.message(
      'درصد',
      name: 'depositListOwnerPercent',
      desc: '',
      args: [],
    );
  }

  /// `نقش`
  String get depositListOwnerRole {
    return Intl.message(
      'نقش',
      name: 'depositListOwnerRole',
      desc: '',
      args: [],
    );
  }

  /// `پس انداز حقیقی`
  String get depositListSavings {
    return Intl.message(
      'پس انداز حقیقی',
      name: 'depositListSavings',
      desc: '',
      args: [],
    );
  }

  /// `این خدمت پس از اتصال به سامانه بانک در دسترس خواهد بود.`
  String get depositListServiceUnavailable {
    return Intl.message(
      'این خدمت پس از اتصال به سامانه بانک در دسترس خواهد بود.',
      name: 'depositListServiceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `صاحب امضا`
  String get depositListSignatory {
    return Intl.message(
      'صاحب امضا',
      name: 'depositListSignatory',
      desc: '',
      args: [],
    );
  }

  /// `تنظیمات ارسال پیامک`
  String get depositListSms {
    return Intl.message(
      'تنظیمات ارسال پیامک',
      name: 'depositListSms',
      desc: '',
      args: [],
    );
  }

  /// `صورت حساب | معدل موجودی`
  String get depositListStatement {
    return Intl.message(
      'صورت حساب | معدل موجودی',
      name: 'depositListStatement',
      desc: '',
      args: [],
    );
  }

  /// `وضعیت`
  String get depositListStatus {
    return Intl.message('وضعیت', name: 'depositListStatus', desc: '', args: []);
  }

  /// `آدرس ارسال گواهی را انتخاب کنید`
  String get certificateAddressHint {
    return Intl.message(
      'آدرس ارسال گواهی را انتخاب کنید',
      name: 'certificateAddressHint',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی یا تلفن کارشناس`
  String get certificateAgentIdentifier {
    return Intl.message(
      'کد ملی یا تلفن کارشناس',
      name: 'certificateAgentIdentifier',
      desc: '',
      args: [],
    );
  }

  /// `چنانچه کارشناس بانکی جهت احراز می‌شناسید، با وارد کردن کد ملی یا شماره تلفن کارشناس مد نظر خود را انتخاب کنید.`
  String get certificateAgentNotice {
    return Intl.message(
      'چنانچه کارشناس بانکی جهت احراز می‌شناسید، با وارد کردن کد ملی یا شماره تلفن کارشناس مد نظر خود را انتخاب کنید.',
      name: 'certificateAgentNotice',
      desc: '',
      args: [],
    );
  }

  /// `استعلام کارشناس پس از اتصال به سامانه بانک فعال می‌شود.`
  String get certificateAgentUnavailable {
    return Intl.message(
      'استعلام کارشناس پس از اتصال به سامانه بانک فعال می‌شود.',
      name: 'certificateAgentUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `معدل موجودی`
  String get certificateAverageBalance {
    return Intl.message(
      'معدل موجودی',
      name: 'certificateAverageBalance',
      desc: '',
      args: [],
    );
  }

  /// `درخواست صورت‌حساب | معدل موجودی`
  String get certificateAverageTitle {
    return Intl.message(
      'درخواست صورت‌حساب | معدل موجودی',
      name: 'certificateAverageTitle',
      desc: '',
      args: [],
    );
  }

  /// `واریز | برداشت`
  String get certificateBothTurnovers {
    return Intl.message(
      'واریز | برداشت',
      name: 'certificateBothTurnovers',
      desc: '',
      args: [],
    );
  }

  /// `بررسی`
  String get certificateCheckAgent {
    return Intl.message(
      'بررسی',
      name: 'certificateCheckAgent',
      desc: '',
      args: [],
    );
  }

  /// `شرایط درخواست جهت درج روی گواهی را انتخاب کنید.`
  String get certificateConditionsPrompt {
    return Intl.message(
      'شرایط درخواست جهت درج روی گواهی را انتخاب کنید.',
      name: 'certificateConditionsPrompt',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب سپرده و شرایط درخواست`
  String get certificateConditionsStep {
    return Intl.message(
      'انتخاب سپرده و شرایط درخواست',
      name: 'certificateConditionsStep',
      desc: '',
      args: [],
    );
  }

  /// `از حذف این آدرس مطمئن هستید؟`
  String get certificateDeleteAddressPrompt {
    return Intl.message(
      'از حذف این آدرس مطمئن هستید؟',
      name: 'certificateDeleteAddressPrompt',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات نحوه دریافت گواهی`
  String get certificateDeliveryStep {
    return Intl.message(
      'اطلاعات نحوه دریافت گواهی',
      name: 'certificateDeliveryStep',
      desc: '',
      args: [],
    );
  }

  /// `واریز`
  String get certificateDepositsOnly {
    return Intl.message(
      'واریز',
      name: 'certificateDepositsOnly',
      desc: '',
      args: [],
    );
  }

  /// `انگلیسی`
  String get certificateEnglish {
    return Intl.message(
      'انگلیسی',
      name: 'certificateEnglish',
      desc: '',
      args: [],
    );
  }

  /// `از تاریخ`
  String get certificateFromDate {
    return Intl.message(
      'از تاریخ',
      name: 'certificateFromDate',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ شروع را مشخص کنید`
  String get certificateFromDateHint {
    return Intl.message(
      'تاریخ شروع را مشخص کنید',
      name: 'certificateFromDateHint',
      desc: '',
      args: [],
    );
  }

  /// `زبان`
  String get certificateLanguage {
    return Intl.message(
      'زبان',
      name: 'certificateLanguage',
      desc: '',
      args: [],
    );
  }

  /// `درخواست آزمایشی ثبت شد؛ گواهی صادر نشده و مبلغی برداشت نشده است.`
  String get certificateMockComplete {
    return Intl.message(
      'درخواست آزمایشی ثبت شد؛ گواهی صادر نشده و مبلغی برداشت نشده است.',
      name: 'certificateMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `بعدی:`
  String get certificateNextPrefix {
    return Intl.message(
      'بعدی:',
      name: 'certificateNextPrefix',
      desc: '',
      args: [],
    );
  }

  /// `اختیاری`
  String get certificateOptional {
    return Intl.message(
      'اختیاری',
      name: 'certificateOptional',
      desc: '',
      args: [],
    );
  }

  /// `فارسی`
  String get certificatePersian {
    return Intl.message(
      'فارسی',
      name: 'certificatePersian',
      desc: '',
      args: [],
    );
  }

  /// `هزینه چاپ گزارش بر اساس تعداد صفحات محاسبه می‌شود.`
  String get certificatePrintingNotice {
    return Intl.message(
      'هزینه چاپ گزارش بر اساس تعداد صفحات محاسبه می‌شود.',
      name: 'certificatePrintingNotice',
      desc: '',
      args: [],
    );
  }

  /// `نام و نام خانوادگی`
  String get certificateRecipientName {
    return Intl.message(
      'نام و نام خانوادگی',
      name: 'certificateRecipientName',
      desc: '',
      args: [],
    );
  }

  /// `نام و نام خانوادگی گیرنده را وارد کنید`
  String get certificateRecipientNameHint {
    return Intl.message(
      'نام و نام خانوادگی گیرنده را وارد کنید',
      name: 'certificateRecipientNameHint',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی گیرنده را وارد کنید`
  String get certificateRecipientNationalIdHint {
    return Intl.message(
      'کد ملی گیرنده را وارد کنید',
      name: 'certificateRecipientNationalIdHint',
      desc: '',
      args: [],
    );
  }

  /// `بسته فقط به شما تحویل داده می‌شود. در صورت عدم حضور، مشخصات تحویل گیرنده دوم را وارد کنید.`
  String get certificateRecipientNotice {
    return Intl.message(
      'بسته فقط به شما تحویل داده می‌شود. در صورت عدم حضور، مشخصات تحویل گیرنده دوم را وارد کنید.',
      name: 'certificateRecipientNotice',
      desc: '',
      args: [],
    );
  }

  /// `زبان صورتحساب را انتخاب کنید`
  String get certificateStatementLanguageHint {
    return Intl.message(
      'زبان صورتحساب را انتخاب کنید',
      name: 'certificateStatementLanguageHint',
      desc: '',
      args: [],
    );
  }

  /// `تا تاریخ`
  String get certificateToDate {
    return Intl.message(
      'تا تاریخ',
      name: 'certificateToDate',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ پایان را مشخص کنید`
  String get certificateToDateHint {
    return Intl.message(
      'تاریخ پایان را مشخص کنید',
      name: 'certificateToDateHint',
      desc: '',
      args: [],
    );
  }

  /// `نوع گردش`
  String get certificateTurnover {
    return Intl.message(
      'نوع گردش',
      name: 'certificateTurnover',
      desc: '',
      args: [],
    );
  }

  /// `نوع گردش سپرده را انتخاب نمایید`
  String get certificateTurnoverHint {
    return Intl.message(
      'نوع گردش سپرده را انتخاب نمایید',
      name: 'certificateTurnoverHint',
      desc: '',
      args: [],
    );
  }

  /// `برداشت`
  String get certificateWithdrawalsOnly {
    return Intl.message(
      'برداشت',
      name: 'certificateWithdrawalsOnly',
      desc: '',
      args: [],
    );
  }

  /// `مرجع`
  String get financialAuthority {
    return Intl.message('مرجع', name: 'financialAuthority', desc: '', args: []);
  }

  /// `نام دقیق مرجع را بنویسید`
  String get financialAuthorityHint {
    return Intl.message(
      'نام دقیق مرجع را بنویسید',
      name: 'financialAuthorityHint',
      desc: '',
      args: [],
    );
  }

  /// `درج میانگین موجودی`
  String get financialAverageBalanceCondition {
    return Intl.message(
      'درج میانگین موجودی',
      name: 'financialAverageBalanceCondition',
      desc: '',
      args: [],
    );
  }

  /// `درخواست گواهی تمکن مالی`
  String get financialCertificateTitle {
    return Intl.message(
      'درخواست گواهی تمکن مالی',
      name: 'financialCertificateTitle',
      desc: '',
      args: [],
    );
  }

  /// `ارز معادل`
  String get financialCurrency {
    return Intl.message(
      'ارز معادل',
      name: 'financialCurrency',
      desc: '',
      args: [],
    );
  }

  /// `نوع ارز را جهت ارائه تمکن مالی انتخاب کنید`
  String get financialCurrencyHint {
    return Intl.message(
      'نوع ارز را جهت ارائه تمکن مالی انتخاب کنید',
      name: 'financialCurrencyHint',
      desc: '',
      args: [],
    );
  }

  /// `درج مبلغ گردش بدهکار بستانکار`
  String get financialDebitCredit {
    return Intl.message(
      'درج مبلغ گردش بدهکار بستانکار',
      name: 'financialDebitCredit',
      desc: '',
      args: [],
    );
  }

  /// `سفارت`
  String get financialEmbassy {
    return Intl.message('سفارت', name: 'financialEmbassy', desc: '', args: []);
  }

  /// `سفارت مورد نظر را انتخاب کنید`
  String get financialEmbassyHint {
    return Intl.message(
      'سفارت مورد نظر را انتخاب کنید',
      name: 'financialEmbassyHint',
      desc: '',
      args: [],
    );
  }

  /// `یورو`
  String get financialEur {
    return Intl.message('یورو', name: 'financialEur', desc: '', args: []);
  }

  /// `درج نرخ برابری روز`
  String get financialExchangeRate {
    return Intl.message(
      'درج نرخ برابری روز',
      name: 'financialExchangeRate',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ لاتین انقضای گذرنامه، درج شده در گذرنامه`
  String get financialExpiryHint {
    return Intl.message(
      'تاریخ لاتین انقضای گذرنامه، درج شده در گذرنامه',
      name: 'financialExpiryHint',
      desc: '',
      args: [],
    );
  }

  /// `نام پدر به انگلیسی مطابق گذرنامه`
  String get financialFatherHint {
    return Intl.message(
      'نام پدر به انگلیسی مطابق گذرنامه',
      name: 'financialFatherHint',
      desc: '',
      args: [],
    );
  }

  /// `آدرس محل سکونت`
  String get financialHomeAddress {
    return Intl.message(
      'آدرس محل سکونت',
      name: 'financialHomeAddress',
      desc: '',
      args: [],
    );
  }

  /// `ریال ایران`
  String get financialIrr {
    return Intl.message('ریال ایران', name: 'financialIrr', desc: '', args: []);
  }

  /// `Address`
  String get financialLatinAddress {
    return Intl.message(
      'Address',
      name: 'financialLatinAddress',
      desc: '',
      args: [],
    );
  }

  /// `Unit, No, Alley, St, City, Province, Country, Postal code`
  String get financialLatinAddressHint {
    return Intl.message(
      'Unit, No, Alley, St, City, Province, Country, Postal code',
      name: 'financialLatinAddressHint',
      desc: '',
      args: [],
    );
  }

  /// `آدرس انگلیسی جهت درج در گواهی تمکن مالی را طبق فرمت نمونه وارد نمایید.`
  String get financialLatinAddressPrompt {
    return Intl.message(
      'آدرس انگلیسی جهت درج در گواهی تمکن مالی را طبق فرمت نمونه وارد نمایید.',
      name: 'financialLatinAddressPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Date of Expiry`
  String get financialLatinExpiry {
    return Intl.message(
      'Date of Expiry',
      name: 'financialLatinExpiry',
      desc: '',
      args: [],
    );
  }

  /// `Father's name`
  String get financialLatinFather {
    return Intl.message(
      'Father\'s name',
      name: 'financialLatinFather',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get financialLatinName {
    return Intl.message('Name', name: 'financialLatinName', desc: '', args: []);
  }

  /// `Passport No`
  String get financialLatinPassport {
    return Intl.message(
      'Passport No',
      name: 'financialLatinPassport',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات فردی لاتین`
  String get financialLatinStep {
    return Intl.message(
      'اطلاعات فردی لاتین',
      name: 'financialLatinStep',
      desc: '',
      args: [],
    );
  }

  /// `Surname`
  String get financialLatinSurname {
    return Intl.message(
      'Surname',
      name: 'financialLatinSurname',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ سررسید سپرده`
  String get financialMaturityDate {
    return Intl.message(
      'تاریخ سررسید سپرده',
      name: 'financialMaturityDate',
      desc: '',
      args: [],
    );
  }

  /// `نام به انگلیسی مطابق گذرنامه`
  String get financialNameHint {
    return Intl.message(
      'نام به انگلیسی مطابق گذرنامه',
      name: 'financialNameHint',
      desc: '',
      args: [],
    );
  }

  /// `درج تاریخ اولیه افتتاح سپرده`
  String get financialOpenedAt {
    return Intl.message(
      'درج تاریخ اولیه افتتاح سپرده',
      name: 'financialOpenedAt',
      desc: '',
      args: [],
    );
  }

  /// `دیگر مراجع`
  String get financialOtherAuthority {
    return Intl.message(
      'دیگر مراجع',
      name: 'financialOtherAuthority',
      desc: '',
      args: [],
    );
  }

  /// `شماره گذرنامه به انگلیسی`
  String get financialPassportHint {
    return Intl.message(
      'شماره گذرنامه به انگلیسی',
      name: 'financialPassportHint',
      desc: '',
      args: [],
    );
  }

  /// `شماره گذرنامه / شماره ثبت`
  String get financialPassportNumberCondition {
    return Intl.message(
      'شماره گذرنامه / شماره ثبت',
      name: 'financialPassportNumberCondition',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات زیر را مطابق با گذرنامه خود وارد نمایید.`
  String get financialPassportPrompt {
    return Intl.message(
      'اطلاعات زیر را مطابق با گذرنامه خود وارد نمایید.',
      name: 'financialPassportPrompt',
      desc: '',
      args: [],
    );
  }

  /// `گیرنده`
  String get financialRecipient {
    return Intl.message(
      'گیرنده',
      name: 'financialRecipient',
      desc: '',
      args: [],
    );
  }

  /// `گیرنده گواهی را انتخاب کنید`
  String get financialRecipientHint {
    return Intl.message(
      'گیرنده گواهی را انتخاب کنید',
      name: 'financialRecipientHint',
      desc: '',
      args: [],
    );
  }

  /// `گیرنده گواهی و ارز معادل را انتخاب کنید`
  String get financialRecipientPrompt {
    return Intl.message(
      'گیرنده گواهی و ارز معادل را انتخاب کنید',
      name: 'financialRecipientPrompt',
      desc: '',
      args: [],
    );
  }

  /// `گیرنده گواهی و نوع ارز`
  String get financialRecipientStep {
    return Intl.message(
      'گیرنده گواهی و نوع ارز',
      name: 'financialRecipientStep',
      desc: '',
      args: [],
    );
  }

  /// `نام خانوادگی به انگلیسی مطابق گذرنامه`
  String get financialSurnameHint {
    return Intl.message(
      'نام خانوادگی به انگلیسی مطابق گذرنامه',
      name: 'financialSurnameHint',
      desc: '',
      args: [],
    );
  }

  /// `دلار آمریکا`
  String get financialUsd {
    return Intl.message(
      'دلار آمریکا',
      name: 'financialUsd',
      desc: '',
      args: [],
    );
  }

  /// `شرایط برداشت از سپرده‌های مشترک / حقوقی`
  String get financialWithdrawalRules {
    return Intl.message(
      'شرایط برداشت از سپرده‌های مشترک / حقوقی',
      name: 'financialWithdrawalRules',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات دریافت گواهی`
  String get financialDeliveryStep {
    return Intl.message(
      'اطلاعات دریافت گواهی',
      name: 'financialDeliveryStep',
      desc: '',
      args: [],
    );
  }

  /// `خروج از عملیات؟`
  String get flowExitTitle {
    return Intl.message(
      'خروج از عملیات؟',
      name: 'flowExitTitle',
      desc: '',
      args: [],
    );
  }

  /// `معرفی نماینده جدید`
  String get agentTitle {
    return Intl.message(
      'معرفی نماینده جدید',
      name: 'agentTitle',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب سپرده`
  String get agentDeposit {
    return Intl.message(
      'انتخاب سپرده',
      name: 'agentDeposit',
      desc: '',
      args: [],
    );
  }

  /// `سپرده مورد نظر خود را انتخاب کنید`
  String get agentDepositHint {
    return Intl.message(
      'سپرده مورد نظر خود را انتخاب کنید',
      name: 'agentDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `نوع عملیات`
  String get agentOperation {
    return Intl.message(
      'نوع عملیات',
      name: 'agentOperation',
      desc: '',
      args: [],
    );
  }

  /// `عملیات مجاز نماینده را انتخاب کنید`
  String get agentOperationHint {
    return Intl.message(
      'عملیات مجاز نماینده را انتخاب کنید',
      name: 'agentOperationHint',
      desc: '',
      args: [],
    );
  }

  /// `صدور دسته چک`
  String get agentChequeBook {
    return Intl.message(
      'صدور دسته چک',
      name: 'agentChequeBook',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی نماینده`
  String get agentNationalId {
    return Intl.message(
      'کد ملی نماینده',
      name: 'agentNationalId',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی نماینده را وارد کنید`
  String get agentNationalIdHint {
    return Intl.message(
      'کد ملی نماینده را وارد کنید',
      name: 'agentNationalIdHint',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ اعتبار`
  String get agentValidity {
    return Intl.message(
      'تاریخ اعتبار',
      name: 'agentValidity',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ انقضا را تعیین کنید`
  String get agentValidityHint {
    return Intl.message(
      'تاریخ انقضا را تعیین کنید',
      name: 'agentValidityHint',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ معتبر از امروز به بعد با قالب ۱۴۰۵/۰۶/۳۰ وارد کنید.`
  String get agentValidityError {
    return Intl.message(
      'تاریخ معتبر از امروز به بعد با قالب ۱۴۰۵/۰۶/۳۰ وارد کنید.',
      name: 'agentValidityError',
      desc: '',
      args: [],
    );
  }

  /// `ثبت اولیه`
  String get agentPreliminarySave {
    return Intl.message(
      'ثبت اولیه',
      name: 'agentPreliminarySave',
      desc: '',
      args: [],
    );
  }

  /// `افزودن نماینده بعدی`
  String get agentAddNext {
    return Intl.message(
      'افزودن نماینده بعدی',
      name: 'agentAddNext',
      desc: '',
      args: [],
    );
  }

  /// `نماینده جدید`
  String get agentNewPerson {
    return Intl.message(
      'نماینده جدید',
      name: 'agentNewPerson',
      desc: '',
      args: [],
    );
  }

  /// `حذف نماینده`
  String get agentRemove {
    return Intl.message('حذف نماینده', name: 'agentRemove', desc: '', args: []);
  }

  /// `نوع نمایندگی`
  String get agentKind {
    return Intl.message('نوع نمایندگی', name: 'agentKind', desc: '', args: []);
  }

  /// `سپرده`
  String get agentDepositShort {
    return Intl.message('سپرده', name: 'agentDepositShort', desc: '', args: []);
  }

  /// `انصراف`
  String get agentCancel {
    return Intl.message('انصراف', name: 'agentCancel', desc: '', args: []);
  }

  /// `ثبت`
  String get agentSave {
    return Intl.message('ثبت', name: 'agentSave', desc: '', args: []);
  }

  /// `درخواست آزمایشی ثبت شد؛ هیچ نمایندگی بانکی ایجاد نشده است.`
  String get agentMockComplete {
    return Intl.message(
      'درخواست آزمایشی ثبت شد؛ هیچ نمایندگی بانکی ایجاد نشده است.',
      name: 'agentMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `نماینده‌های من`
  String get agentSettingsMine {
    return Intl.message(
      'نماینده‌های من',
      name: 'agentSettingsMine',
      desc: '',
      args: [],
    );
  }

  /// `من به عنوان نماینده`
  String get agentSettingsDelegated {
    return Intl.message(
      'من به عنوان نماینده',
      name: 'agentSettingsDelegated',
      desc: '',
      args: [],
    );
  }

  /// `افزودن نماینده`
  String get agentSettingsAdd {
    return Intl.message(
      'افزودن نماینده',
      name: 'agentSettingsAdd',
      desc: '',
      args: [],
    );
  }

  /// `جزئیات نمایندگی`
  String get agentSettingsDetails {
    return Intl.message(
      'جزئیات نمایندگی',
      name: 'agentSettingsDetails',
      desc: '',
      args: [],
    );
  }

  /// `لغو نمایندگی`
  String get agentSettingsCancel {
    return Intl.message(
      'لغو نمایندگی',
      name: 'agentSettingsCancel',
      desc: '',
      args: [],
    );
  }

  /// `(انتخاب همه)`
  String get agentSettingsSelectAll {
    return Intl.message(
      '(انتخاب همه)',
      name: 'agentSettingsSelectAll',
      desc: '',
      args: [],
    );
  }

  /// `معرفی وام`
  String get agentSettingsLoanReferral {
    return Intl.message(
      'معرفی وام',
      name: 'agentSettingsLoanReferral',
      desc: '',
      args: [],
    );
  }

  /// `رفع سوء اثر چک`
  String get agentSettingsClearChequeRecord {
    return Intl.message(
      'رفع سوء اثر چک',
      name: 'agentSettingsClearChequeRecord',
      desc: '',
      args: [],
    );
  }

  /// `فعال`
  String get agentSettingsActive {
    return Intl.message(
      'فعال',
      name: 'agentSettingsActive',
      desc: '',
      args: [],
    );
  }

  /// `در انتظار تایید`
  String get agentSettingsWaiting {
    return Intl.message(
      'در انتظار تایید',
      name: 'agentSettingsWaiting',
      desc: '',
      args: [],
    );
  }

  /// `منقضی شده`
  String get agentSettingsExpired {
    return Intl.message(
      'منقضی شده',
      name: 'agentSettingsExpired',
      desc: '',
      args: [],
    );
  }

  /// `نمایندگی با این مشخصات وجود ندارد.`
  String get agentSettingsEmpty {
    return Intl.message(
      'نمایندگی با این مشخصات وجود ندارد.',
      name: 'agentSettingsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `نام نماینده:`
  String get agentSettingsNameLabel {
    return Intl.message(
      'نام نماینده:',
      name: 'agentSettingsNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی:`
  String get agentSettingsNationalIdLabel {
    return Intl.message(
      'کد ملی:',
      name: 'agentSettingsNationalIdLabel',
      desc: '',
      args: [],
    );
  }

  /// `شماره سپرده:`
  String get agentSettingsDepositLabel {
    return Intl.message(
      'شماره سپرده:',
      name: 'agentSettingsDepositLabel',
      desc: '',
      args: [],
    );
  }

  /// `نوع نمایندگی:`
  String get agentSettingsKindLabel {
    return Intl.message(
      'نوع نمایندگی:',
      name: 'agentSettingsKindLabel',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ معرفی:`
  String get agentSettingsIntroducedLabel {
    return Intl.message(
      'تاریخ معرفی:',
      name: 'agentSettingsIntroducedLabel',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ انقضا:`
  String get agentSettingsExpiryLabel {
    return Intl.message(
      'تاریخ انقضا:',
      name: 'agentSettingsExpiryLabel',
      desc: '',
      args: [],
    );
  }

  /// `مشخصات تایید کنندگان`
  String get agentSettingsConfirmers {
    return Intl.message(
      'مشخصات تایید کنندگان',
      name: 'agentSettingsConfirmers',
      desc: '',
      args: [],
    );
  }

  /// `معرف`
  String get agentSettingsIntroducer {
    return Intl.message(
      'معرف',
      name: 'agentSettingsIntroducer',
      desc: '',
      args: [],
    );
  }

  /// `صاحب سپرده و امضا`
  String get agentSettingsDepositRelation {
    return Intl.message(
      'صاحب سپرده و امضا',
      name: 'agentSettingsDepositRelation',
      desc: '',
      args: [],
    );
  }

  /// `{percentage}٪`
  String agentSettingsShare(String percentage) {
    return Intl.message(
      '$percentage٪',
      name: 'agentSettingsShare',
      desc: '',
      args: [percentage],
    );
  }

  /// `بستن سپرده مازاد`
  String get surplusDepositsTitle {
    return Intl.message(
      'بستن سپرده مازاد',
      name: 'surplusDepositsTitle',
      desc: '',
      args: [],
    );
  }

  /// `سپرده‌ای که می‌خواهید به عنوان سپرده اصلی شما باقی بماند را انتخاب کنید. سپرده‌های مازاد شما بسته و موجودی و سایر موارد مرتبط با آن‌ها به سپرده منتخب شما منتقل می‌گردد.`
  String get surplusDepositsDescription {
    return Intl.message(
      'سپرده‌ای که می‌خواهید به عنوان سپرده اصلی شما باقی بماند را انتخاب کنید. سپرده‌های مازاد شما بسته و موجودی و سایر موارد مرتبط با آن‌ها به سپرده منتخب شما منتقل می‌گردد.',
      name: 'surplusDepositsDescription',
      desc: '',
      args: [],
    );
  }

  /// `سپرده اصلی`
  String get surplusPrimaryDeposit {
    return Intl.message(
      'سپرده اصلی',
      name: 'surplusPrimaryDeposit',
      desc: '',
      args: [],
    );
  }

  /// `سپرده اصلی خود را انتخاب کنید`
  String get surplusPrimaryDepositHint {
    return Intl.message(
      'سپرده اصلی خود را انتخاب کنید',
      name: 'surplusPrimaryDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `تایید و ثبت درخواست`
  String get surplusDepositsSubmit {
    return Intl.message(
      'تایید و ثبت درخواست',
      name: 'surplusDepositsSubmit',
      desc: '',
      args: [],
    );
  }

  /// `نتیجه‌ای یافت نشد`
  String get surplusDepositsEmptyTitle {
    return Intl.message(
      'نتیجه‌ای یافت نشد',
      name: 'surplusDepositsEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `شما دارای سپرده قرض الحسنه پس‌انداز حقیقی انفرادی مازاد نمی‌باشید`
  String get surplusDepositsEmptyBody {
    return Intl.message(
      'شما دارای سپرده قرض الحسنه پس‌انداز حقیقی انفرادی مازاد نمی‌باشید',
      name: 'surplusDepositsEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `سپرده‌های مازاد شما`
  String get surplusDepositsReviewTitle {
    return Intl.message(
      'سپرده‌های مازاد شما',
      name: 'surplusDepositsReviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `درخواست بستن سپرده‌ها به صورت آزمایشی ثبت شد. هیچ سپرده یا موجودی واقعی تغییر نکرده است.`
  String get surplusDepositsMockComplete {
    return Intl.message(
      'درخواست بستن سپرده‌ها به صورت آزمایشی ثبت شد. هیچ سپرده یا موجودی واقعی تغییر نکرده است.',
      name: 'surplusDepositsMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `مسدودی سپرده`
  String get depositBlockTitle {
    return Intl.message(
      'مسدودی سپرده',
      name: 'depositBlockTitle',
      desc: '',
      args: [],
    );
  }

  /// `رفع مسدودی سپرده`
  String get depositUnblockTitle {
    return Intl.message(
      'رفع مسدودی سپرده',
      name: 'depositUnblockTitle',
      desc: '',
      args: [],
    );
  }

  /// `سپرده مورد نظر و علت مسدودی را انتخاب کنید`
  String get depositBlockIntro {
    return Intl.message(
      'سپرده مورد نظر و علت مسدودی را انتخاب کنید',
      name: 'depositBlockIntro',
      desc: '',
      args: [],
    );
  }

  /// `سپرده مورد نظر و علت رفع مسدودی را انتخاب کنید`
  String get depositUnblockIntro {
    return Intl.message(
      'سپرده مورد نظر و علت رفع مسدودی را انتخاب کنید',
      name: 'depositUnblockIntro',
      desc: '',
      args: [],
    );
  }

  /// `علت درخواست`
  String get depositRestrictionReason {
    return Intl.message(
      'علت درخواست',
      name: 'depositRestrictionReason',
      desc: '',
      args: [],
    );
  }

  /// `علت رفع مسدودی`
  String get depositUnblockReason {
    return Intl.message(
      'علت رفع مسدودی',
      name: 'depositUnblockReason',
      desc: '',
      args: [],
    );
  }

  /// `علت درخواست را انتخاب کنید`
  String get depositRestrictionReasonHint {
    return Intl.message(
      'علت درخواست را انتخاب کنید',
      name: 'depositRestrictionReasonHint',
      desc: '',
      args: [],
    );
  }

  /// `توضیحات`
  String get depositRestrictionDescription {
    return Intl.message(
      'توضیحات',
      name: 'depositRestrictionDescription',
      desc: '',
      args: [],
    );
  }

  /// `در صورت نیاز توضیحات را وارد کنید`
  String get depositRestrictionDescriptionHint {
    return Intl.message(
      'در صورت نیاز توضیحات را وارد کنید',
      name: 'depositRestrictionDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `مدیریت سپرده`
  String get depositRestrictionManagement {
    return Intl.message(
      'مدیریت سپرده',
      name: 'depositRestrictionManagement',
      desc: '',
      args: [],
    );
  }

  /// `علت مسدودی`
  String get depositBlockedReason {
    return Intl.message(
      'علت مسدودی',
      name: 'depositBlockedReason',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ مسدودی`
  String get depositBlockedDate {
    return Intl.message(
      'تاریخ مسدودی',
      name: 'depositBlockedDate',
      desc: '',
      args: [],
    );
  }

  /// `درخواست به صورت آزمایشی ثبت شد. هیچ سپرده یا کیف پول واقعی تغییر نکرده است.`
  String get depositRestrictionMockComplete {
    return Intl.message(
      'درخواست به صورت آزمایشی ثبت شد. هیچ سپرده یا کیف پول واقعی تغییر نکرده است.',
      name: 'depositRestrictionMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `شرکت`
  String get proxyCompany {
    return Intl.message('شرکت', name: 'proxyCompany', desc: '', args: []);
  }

  /// `شرکت مورد نظر را انتخاب کنید`
  String get proxyCompanyHint {
    return Intl.message(
      'شرکت مورد نظر را انتخاب کنید',
      name: 'proxyCompanyHint',
      desc: '',
      args: [],
    );
  }

  /// `موضوع`
  String get proxySubject {
    return Intl.message('موضوع', name: 'proxySubject', desc: '', args: []);
  }

  /// `موضوع سپرده وکالتی را انتخاب کنید`
  String get proxySubjectHint {
    return Intl.message(
      'موضوع سپرده وکالتی را انتخاب کنید',
      name: 'proxySubjectHint',
      desc: '',
      args: [],
    );
  }

  /// `سپرده خود را انتخاب کنید`
  String get proxyDepositHint {
    return Intl.message(
      'سپرده خود را انتخاب کنید',
      name: 'proxyDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `کارگزار`
  String get proxyBroker {
    return Intl.message('کارگزار', name: 'proxyBroker', desc: '', args: []);
  }

  /// `مبلغ`
  String get proxyAmount {
    return Intl.message('مبلغ', name: 'proxyAmount', desc: '', args: []);
  }

  /// `{amount} تومان`
  String proxyAmountToman(String amount) {
    return Intl.message(
      '$amount تومان',
      name: 'proxyAmountToman',
      desc: '',
      args: [amount],
    );
  }

  /// `درخواست سپرده وکالتی به صورت آزمایشی ثبت شد. هیچ وکالت یا مسدودی مبلغ واقعی ایجاد نشده است.`
  String get proxyDepositMockComplete {
    return Intl.message(
      'درخواست سپرده وکالتی به صورت آزمایشی ثبت شد. هیچ وکالت یا مسدودی مبلغ واقعی ایجاد نشده است.',
      name: 'proxyDepositMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `رفع سوء اثر چک`
  String get chequeClearanceTitle {
    return Intl.message(
      'رفع سوء اثر چک',
      name: 'chequeClearanceTitle',
      desc: '',
      args: [],
    );
  }

  /// `شماره چک، سپرده متصل به آن و علت درخواست را وارد کنید.`
  String get chequeClearanceIntro {
    return Intl.message(
      'شماره چک، سپرده متصل به آن و علت درخواست را وارد کنید.',
      name: 'chequeClearanceIntro',
      desc: '',
      args: [],
    );
  }

  /// `سپرده`
  String get chequeDepositLabel {
    return Intl.message(
      'سپرده',
      name: 'chequeDepositLabel',
      desc: '',
      args: [],
    );
  }

  /// `سپرده پشت چک را انتخاب کنید`
  String get chequeDepositHint {
    return Intl.message(
      'سپرده پشت چک را انتخاب کنید',
      name: 'chequeDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `شماره چک`
  String get chequeNumberLabel {
    return Intl.message(
      'شماره چک',
      name: 'chequeNumberLabel',
      desc: '',
      args: [],
    );
  }

  /// `شماره چک را انتخاب کنید`
  String get chequeNumberHint {
    return Intl.message(
      'شماره چک را انتخاب کنید',
      name: 'chequeNumberHint',
      desc: '',
      args: [],
    );
  }

  /// `علت درخواست`
  String get chequeReasonLabel {
    return Intl.message(
      'علت درخواست',
      name: 'chequeReasonLabel',
      desc: '',
      args: [],
    );
  }

  /// `علت درخواست را انتخاب کنید`
  String get chequeReasonHint {
    return Intl.message(
      'علت درخواست را انتخاب کنید',
      name: 'chequeReasonHint',
      desc: '',
      args: [],
    );
  }

  /// `واریز مبلغ و مسدودی`
  String get chequeReasonDepositAndBlock {
    return Intl.message(
      'واریز مبلغ و مسدودی',
      name: 'chequeReasonDepositAndBlock',
      desc: '',
      args: [],
    );
  }

  /// `رفع سوءاثر چک بیش از ۳ سال`
  String get chequeReasonOlderThanThreeYears {
    return Intl.message(
      'رفع سوءاثر چک بیش از ۳ سال',
      name: 'chequeReasonOlderThanThreeYears',
      desc: '',
      args: [],
    );
  }

  /// `ارائه لاشه چک`
  String get chequeReasonOriginal {
    return Intl.message(
      'ارائه لاشه چک',
      name: 'chequeReasonOriginal',
      desc: '',
      args: [],
    );
  }

  /// `گواهی عدم پرداخت قسمتی از وجه چک`
  String get chequeReasonPartialPayment {
    return Intl.message(
      'گواهی عدم پرداخت قسمتی از وجه چک',
      name: 'chequeReasonPartialPayment',
      desc: '',
      args: [],
    );
  }

  /// `رضایت نامه محضری`
  String get chequeReasonConsent {
    return Intl.message(
      'رضایت نامه محضری',
      name: 'chequeReasonConsent',
      desc: '',
      args: [],
    );
  }

  /// `نامه قضایی`
  String get chequeReasonJudicial {
    return Intl.message(
      'نامه قضایی',
      name: 'chequeReasonJudicial',
      desc: '',
      args: [],
    );
  }

  /// `نیاز به ارسال پست نیست.`
  String get chequeNoPostRequired {
    return Intl.message(
      'نیاز به ارسال پست نیست.',
      name: 'chequeNoPostRequired',
      desc: '',
      args: [],
    );
  }

  /// `مدارک لازم جهت تحویل به پست:`
  String get chequeDocumentsTitle {
    return Intl.message(
      'مدارک لازم جهت تحویل به پست:',
      name: 'chequeDocumentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `لاشه چک`
  String get chequeDocumentOriginal {
    return Intl.message(
      'لاشه چک',
      name: 'chequeDocumentOriginal',
      desc: '',
      args: [],
    );
  }

  /// `اصل رضایت نامه محضری`
  String get chequeDocumentConsent {
    return Intl.message(
      'اصل رضایت نامه محضری',
      name: 'chequeDocumentConsent',
      desc: '',
      args: [],
    );
  }

  /// `اصل نامه قضایی`
  String get chequeDocumentJudicial {
    return Intl.message(
      'اصل نامه قضایی',
      name: 'chequeDocumentJudicial',
      desc: '',
      args: [],
    );
  }

  /// `شماره نامه قضایی`
  String get chequeJudicialNumber {
    return Intl.message(
      'شماره نامه قضایی',
      name: 'chequeJudicialNumber',
      desc: '',
      args: [],
    );
  }

  /// `شماره نامه قضایی را وارد کنید`
  String get chequeJudicialNumberHint {
    return Intl.message(
      'شماره نامه قضایی را وارد کنید',
      name: 'chequeJudicialNumberHint',
      desc: '',
      args: [],
    );
  }

  /// `شماره نامه قضایی را با ارقام وارد کنید.`
  String get chequeJudicialNumberInvalid {
    return Intl.message(
      'شماره نامه قضایی را با ارقام وارد کنید.',
      name: 'chequeJudicialNumberInvalid',
      desc: '',
      args: [],
    );
  }

  /// `نکات`
  String get chequeConsentNotes {
    return Intl.message('نکات', name: 'chequeConsentNotes', desc: '', args: []);
  }

  /// `متن تنظیمی جهت رضایت نامه محضری در دفترخانه باید کاملاً مطابق با شرایط پیوست شده باشد در غیر این صورت قابل پذیرش نمی‌باشد.`
  String get chequeConsentNotice {
    return Intl.message(
      'متن تنظیمی جهت رضایت نامه محضری در دفترخانه باید کاملاً مطابق با شرایط پیوست شده باشد در غیر این صورت قابل پذیرش نمی‌باشد.',
      name: 'chequeConsentNotice',
      desc: '',
      args: [],
    );
  }

  /// `مشاهده شرایط`
  String get chequeConsentConditions {
    return Intl.message(
      'مشاهده شرایط',
      name: 'chequeConsentConditions',
      desc: '',
      args: [],
    );
  }

  /// `نمونه متن رضایت نامه محضری:`
  String get chequeConsentSample {
    return Intl.message(
      'نمونه متن رضایت نامه محضری:',
      name: 'chequeConsentSample',
      desc: '',
      args: [],
    );
  }

  /// `دانلود نمونه`
  String get chequeDownloadSample {
    return Intl.message(
      'دانلود نمونه',
      name: 'chequeDownloadSample',
      desc: '',
      args: [],
    );
  }

  /// `آدرس ارسالی روی پاکت جهت تحویل به پست:`
  String get chequeMailingAddressTitle {
    return Intl.message(
      'آدرس ارسالی روی پاکت جهت تحویل به پست:',
      name: 'chequeMailingAddressTitle',
      desc: '',
      args: [],
    );
  }

  /// `هنگام تحویل مدارک پاکت گذاری توسط اداره پست انجام خواهد شد`
  String get chequeMailingInstruction {
    return Intl.message(
      'هنگام تحویل مدارک پاکت گذاری توسط اداره پست انجام خواهد شد',
      name: 'chequeMailingInstruction',
      desc: '',
      args: [],
    );
  }

  /// `معرفی نزدیک‌ترین دفتر پستی مجاز`
  String get chequePostalAction {
    return Intl.message(
      'معرفی نزدیک‌ترین دفتر پستی مجاز',
      name: 'chequePostalAction',
      desc: '',
      args: [],
    );
  }

  /// `نزدیک‌ترین دفتر پستی مجاز`
  String get chequePostalTitle {
    return Intl.message(
      'نزدیک‌ترین دفتر پستی مجاز',
      name: 'chequePostalTitle',
      desc: '',
      args: [],
    );
  }

  /// `استان*`
  String get chequeProvinceLabel {
    return Intl.message(
      'استان*',
      name: 'chequeProvinceLabel',
      desc: '',
      args: [],
    );
  }

  /// `استان مورد نظر را انتخاب کنید`
  String get chequeProvinceHint {
    return Intl.message(
      'استان مورد نظر را انتخاب کنید',
      name: 'chequeProvinceHint',
      desc: '',
      args: [],
    );
  }

  /// `شهر*`
  String get chequeCityLabel {
    return Intl.message('شهر*', name: 'chequeCityLabel', desc: '', args: []);
  }

  /// `شهر مورد نظر را انتخاب کنید`
  String get chequeCityHint {
    return Intl.message(
      'شهر مورد نظر را انتخاب کنید',
      name: 'chequeCityHint',
      desc: '',
      args: [],
    );
  }

  /// `استان`
  String get chequeProvinceSummary {
    return Intl.message(
      'استان',
      name: 'chequeProvinceSummary',
      desc: '',
      args: [],
    );
  }

  /// `شهر`
  String get chequeCitySummary {
    return Intl.message('شهر', name: 'chequeCitySummary', desc: '', args: []);
  }

  /// `جستجو`
  String get chequePostalSearch {
    return Intl.message(
      'جستجو',
      name: 'chequePostalSearch',
      desc: '',
      args: [],
    );
  }

  /// `اشتراک‌گذاری`
  String get chequePostalShare {
    return Intl.message(
      'اشتراک‌گذاری',
      name: 'chequePostalShare',
      desc: '',
      args: [],
    );
  }

  /// `دفتر پستی برای این شهر در داده‌های آزمایشی ثبت نشده است.`
  String get chequePostalEmpty {
    return Intl.message(
      'دفتر پستی برای این شهر در داده‌های آزمایشی ثبت نشده است.',
      name: 'chequePostalEmpty',
      desc: '',
      args: [],
    );
  }

  /// `جستجوی دوباره`
  String get chequePostalSearchAgain {
    return Intl.message(
      'جستجوی دوباره',
      name: 'chequePostalSearchAgain',
      desc: '',
      args: [],
    );
  }

  /// `دریافت لیست دفاتر پستی انجام نشد. دوباره تلاش کنید.`
  String get chequePostalFailure {
    return Intl.message(
      'دریافت لیست دفاتر پستی انجام نشد. دوباره تلاش کنید.',
      name: 'chequePostalFailure',
      desc: '',
      args: [],
    );
  }

  /// `اشتراک‌گذاری در این دستگاه در دسترس نیست.`
  String get chequeShareUnavailable {
    return Intl.message(
      'اشتراک‌گذاری در این دستگاه در دسترس نیست.',
      name: 'chequeShareUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `شماره وارد شده در لیست چک‌های شما نیست`
  String get chequeNumberNotFound {
    return Intl.message(
      'شماره وارد شده در لیست چک‌های شما نیست',
      name: 'chequeNumberNotFound',
      desc: '',
      args: [],
    );
  }

  /// `شماره چک را با ارقام و در صورت نیاز / وارد کنید.`
  String get chequeNumberInvalid {
    return Intl.message(
      'شماره چک را با ارقام و در صورت نیاز / وارد کنید.',
      name: 'chequeNumberInvalid',
      desc: '',
      args: [],
    );
  }

  /// `محتوا هنوز آماده نشده است.`
  String get chequeContentUnavailable {
    return Intl.message(
      'محتوا هنوز آماده نشده است.',
      name: 'chequeContentUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `قوانین و مقررات`
  String get chequeTerms {
    return Intl.message(
      'قوانین و مقررات',
      name: 'chequeTerms',
      desc: '',
      args: [],
    );
  }

  /// `درخواست را مطالعه و تایید می‌نمایم.`
  String get chequeTermsPrompt {
    return Intl.message(
      'درخواست را مطالعه و تایید می‌نمایم.',
      name: 'chequeTermsPrompt',
      desc: '',
      args: [],
    );
  }

  /// `تایید و ثبت درخواست`
  String get chequeSubmit {
    return Intl.message(
      'تایید و ثبت درخواست',
      name: 'chequeSubmit',
      desc: '',
      args: [],
    );
  }

  /// `ثبت درخواست انجام نشد. دوباره تلاش کنید.`
  String get chequeSubmitFailure {
    return Intl.message(
      'ثبت درخواست انجام نشد. دوباره تلاش کنید.',
      name: 'chequeSubmitFailure',
      desc: '',
      args: [],
    );
  }

  /// `درخواست ثبت شد.`
  String get chequeRequestComplete {
    return Intl.message(
      'درخواست ثبت شد.',
      name: 'chequeRequestComplete',
      desc: '',
      args: [],
    );
  }

  /// `درخواست به صورت آزمایشی ثبت شد؛ سوءاثر هیچ چک واقعی رفع نشده است.`
  String get chequeMockComplete {
    return Intl.message(
      'درخواست به صورت آزمایشی ثبت شد؛ سوءاثر هیچ چک واقعی رفع نشده است.',
      name: 'chequeMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `درخواست صدور دسته چک`
  String get chequeBookTitle {
    return Intl.message(
      'درخواست صدور دسته چک',
      name: 'chequeBookTitle',
      desc: '',
      args: [],
    );
  }

  /// `مشخصات دسته چک`
  String get chequeBookSelectionStep {
    return Intl.message(
      'مشخصات دسته چک',
      name: 'chequeBookSelectionStep',
      desc: '',
      args: [],
    );
  }

  /// `بررسی اسکان و املاک`
  String get chequeBookResidencyStep {
    return Intl.message(
      'بررسی اسکان و املاک',
      name: 'chequeBookResidencyStep',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات دریافت`
  String get chequeBookDeliveryStep {
    return Intl.message(
      'اطلاعات دریافت',
      name: 'chequeBookDeliveryStep',
      desc: '',
      args: [],
    );
  }

  /// `بعدی: بررسی اسکان و املاک`
  String get chequeBookNextResidency {
    return Intl.message(
      'بعدی: بررسی اسکان و املاک',
      name: 'chequeBookNextResidency',
      desc: '',
      args: [],
    );
  }

  /// `بعدی: اطلاعات دریافت`
  String get chequeBookNextDelivery {
    return Intl.message(
      'بعدی: اطلاعات دریافت',
      name: 'chequeBookNextDelivery',
      desc: '',
      args: [],
    );
  }

  /// `بعدی: تایید اطلاعات و پرداخت کارمزد`
  String get chequeBookNextConfirmation {
    return Intl.message(
      'بعدی: تایید اطلاعات و پرداخت کارمزد',
      name: 'chequeBookNextConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `شماره حساب جاری و تعداد برگ دسته چک را انتخاب کنید.`
  String get chequeBookSelectionPrompt {
    return Intl.message(
      'شماره حساب جاری و تعداد برگ دسته چک را انتخاب کنید.',
      name: 'chequeBookSelectionPrompt',
      desc: '',
      args: [],
    );
  }

  /// `سپرده مورد نظر خود را انتخاب کنید`
  String get chequeBookDepositHint {
    return Intl.message(
      'سپرده مورد نظر خود را انتخاب کنید',
      name: 'chequeBookDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `تعداد برگ`
  String get chequeBookLeafCount {
    return Intl.message(
      'تعداد برگ',
      name: 'chequeBookLeafCount',
      desc: '',
      args: [],
    );
  }

  /// `تعداد برگ دسته چک را انتخاب کنید`
  String get chequeBookLeafCountHint {
    return Intl.message(
      'تعداد برگ دسته چک را انتخاب کنید',
      name: 'chequeBookLeafCountHint',
      desc: '',
      args: [],
    );
  }

  /// `برای صدور دسته‌چک جدید، لازم است حداقل ۸۰٪ برگ‌های دسته چک قبلی به بانک برگشته باشند.`
  String get chequeBookUsedLeavesNotice {
    return Intl.message(
      'برای صدور دسته‌چک جدید، لازم است حداقل ۸۰٪ برگ‌های دسته چک قبلی به بانک برگشته باشند.',
      name: 'chequeBookUsedLeavesNotice',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ افتتاح حساب:`
  String get chequeBookOpenedAt {
    return Intl.message(
      'تاریخ افتتاح حساب:',
      name: 'chequeBookOpenedAt',
      desc: '',
      args: [],
    );
  }

  /// `برای کاربران حقیقی، صدور دسته‌چک ۵۰ برگی پس از پایان سال سوم امکان‌پذیر است.`
  String get chequeBookFiftyLeavesNotice {
    return Intl.message(
      'برای کاربران حقیقی، صدور دسته‌چک ۵۰ برگی پس از پایان سال سوم امکان‌پذیر است.',
      name: 'chequeBookFiftyLeavesNotice',
      desc: '',
      args: [],
    );
  }

  /// `بررسی سامانه اسکان و املاک...`
  String get chequeBookChecking {
    return Intl.message(
      'بررسی سامانه اسکان و املاک...',
      name: 'chequeBookChecking',
      desc: '',
      args: [],
    );
  }

  /// `آدرس محل سکونت شما در `
  String get chequeBookResidencyWarningStart {
    return Intl.message(
      'آدرس محل سکونت شما در ',
      name: 'chequeBookResidencyWarningStart',
      desc: '',
      args: [],
    );
  }

  /// `سامانه اسکان و املاک`
  String get chequeBookRegistryName {
    return Intl.message(
      'سامانه اسکان و املاک',
      name: 'chequeBookRegistryName',
      desc: '',
      args: [],
    );
  }

  /// ` تأیید نشده است.`
  String get chequeBookResidencyWarningEnd {
    return Intl.message(
      ' تأیید نشده است.',
      name: 'chequeBookResidencyWarningEnd',
      desc: '',
      args: [],
    );
  }

  /// `در صورت صحت آدرس، ابتدا آن را در سامانه اسکان و املاک ثبت کرده و سپس برای صدور دسته‌چک اقدام نمایید.`
  String get chequeBookMissingNotice {
    return Intl.message(
      'در صورت صحت آدرس، ابتدا آن را در سامانه اسکان و املاک ثبت کرده و سپس برای صدور دسته‌چک اقدام نمایید.',
      name: 'chequeBookMissingNotice',
      desc: '',
      args: [],
    );
  }

  /// `شما می‌توانید، آدرس مورد نظر را در سامانه‌ی اسکان و املاک کشور ثبت نموده و یا آدرس‌های اضافه خود را حذف نمایید.`
  String get chequeBookMultipleMissingNotice {
    return Intl.message(
      'شما می‌توانید، آدرس مورد نظر را در سامانه‌ی اسکان و املاک کشور ثبت نموده و یا آدرس‌های اضافه خود را حذف نمایید.',
      name: 'chequeBookMultipleMissingNotice',
      desc: '',
      args: [],
    );
  }

  /// `آدرس سامانه اسکان و املاک:`
  String get chequeBookRegistryUrlLabel {
    return Intl.message(
      'آدرس سامانه اسکان و املاک:',
      name: 'chequeBookRegistryUrlLabel',
      desc: '',
      args: [],
    );
  }

  /// `amlak.mrud.ir`
  String get chequeBookRegistryHost {
    return Intl.message(
      'amlak.mrud.ir',
      name: 'chequeBookRegistryHost',
      desc: '',
      args: [],
    );
  }

  /// `در صورت نیاز به تغییر آدرس، از بخش اطلاعات کاربری، `
  String get chequeBookAddressesNoticeStart {
    return Intl.message(
      'در صورت نیاز به تغییر آدرس، از بخش اطلاعات کاربری، ',
      name: 'chequeBookAddressesNoticeStart',
      desc: '',
      args: [],
    );
  }

  /// `آدرس‌های من`
  String get chequeBookMyAddresses {
    return Intl.message(
      'آدرس‌های من',
      name: 'chequeBookMyAddresses',
      desc: '',
      args: [],
    );
  }

  /// ` اقدام نمایید.`
  String get chequeBookAddressesNoticeEnd {
    return Intl.message(
      ' اقدام نمایید.',
      name: 'chequeBookAddressesNoticeEnd',
      desc: '',
      args: [],
    );
  }

  /// `آدرس‌های محل سکونت شما:`
  String get chequeBookResidences {
    return Intl.message(
      'آدرس‌های محل سکونت شما:',
      name: 'chequeBookResidences',
      desc: '',
      args: [],
    );
  }

  /// `آدرس محل سکونت شما:`
  String get chequeBookResidence {
    return Intl.message(
      'آدرس محل سکونت شما:',
      name: 'chequeBookResidence',
      desc: '',
      args: [],
    );
  }

  /// `دارای اسکان و املاک`
  String get chequeBookRegistered {
    return Intl.message(
      'دارای اسکان و املاک',
      name: 'chequeBookRegistered',
      desc: '',
      args: [],
    );
  }

  /// `فاقد اسکان و املاک`
  String get chequeBookNotRegistered {
    return Intl.message(
      'فاقد اسکان و املاک',
      name: 'chequeBookNotRegistered',
      desc: '',
      args: [],
    );
  }

  /// `مشخصات تحویل گیرنده دسته چک را وارد نمایید`
  String get chequeBookLegalRecipientPrompt {
    return Intl.message(
      'مشخصات تحویل گیرنده دسته چک را وارد نمایید',
      name: 'chequeBookLegalRecipientPrompt',
      desc: '',
      args: [],
    );
  }

  /// `نام و نام خانوادگی`
  String get chequeBookRecipientName {
    return Intl.message(
      'نام و نام خانوادگی',
      name: 'chequeBookRecipientName',
      desc: '',
      args: [],
    );
  }

  /// `نام و نام خانوادگی تحویل گیرنده را وارد کنید`
  String get chequeBookRecipientNameHint {
    return Intl.message(
      'نام و نام خانوادگی تحویل گیرنده را وارد کنید',
      name: 'chequeBookRecipientNameHint',
      desc: '',
      args: [],
    );
  }

  /// `نام و نام خانوادگی را وارد کنید.`
  String get chequeBookRecipientNameInvalid {
    return Intl.message(
      'نام و نام خانوادگی را وارد کنید.',
      name: 'chequeBookRecipientNameInvalid',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی`
  String get chequeBookRecipientNationalId {
    return Intl.message(
      'کد ملی',
      name: 'chequeBookRecipientNationalId',
      desc: '',
      args: [],
    );
  }

  /// `کد ملی تحویل گیرنده را وارد کنید`
  String get chequeBookRecipientNationalIdHint {
    return Intl.message(
      'کد ملی تحویل گیرنده را وارد کنید',
      name: 'chequeBookRecipientNationalIdHint',
      desc: '',
      args: [],
    );
  }

  /// `هزینه صدور دسته چک`
  String get chequeBookIssueFee {
    return Intl.message(
      'هزینه صدور دسته چک',
      name: 'chequeBookIssueFee',
      desc: '',
      args: [],
    );
  }

  /// `مطمئنید می‌خواهید آدرس زیر را حذف کنید؟`
  String get chequeBookDeletePrompt {
    return Intl.message(
      'مطمئنید می‌خواهید آدرس زیر را حذف کنید؟',
      name: 'chequeBookDeletePrompt',
      desc: '',
      args: [],
    );
  }

  /// `حذف و ادامه فرآیند`
  String get chequeBookDeleteContinue {
    return Intl.message(
      'حذف و ادامه فرآیند',
      name: 'chequeBookDeleteContinue',
      desc: '',
      args: [],
    );
  }

  /// `درخواست به‌صورت آزمایشی ثبت شد؛ دسته‌چک واقعی صادر و مبلغی برداشت نشده است.`
  String get chequeBookMockComplete {
    return Intl.message(
      'درخواست به‌صورت آزمایشی ثبت شد؛ دسته‌چک واقعی صادر و مبلغی برداشت نشده است.',
      name: 'chequeBookMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `باز کردن مرورگر در این دستگاه امکان‌پذیر نیست.`
  String get chequeBookLinkUnavailable {
    return Intl.message(
      'باز کردن مرورگر در این دستگاه امکان‌پذیر نیست.',
      name: 'chequeBookLinkUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `ابطال چک`
  String get chequeCancelTitle {
    return Intl.message(
      'ابطال چک',
      name: 'chequeCancelTitle',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب سپرده و نوع چک`
  String get chequeCancelSelectionStep {
    return Intl.message(
      'انتخاب سپرده و نوع چک',
      name: 'chequeCancelSelectionStep',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب چک‌ها`
  String get chequeCancelChequesStep {
    return Intl.message(
      'انتخاب چک‌ها',
      name: 'chequeCancelChequesStep',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب علت ابطال`
  String get chequeCancelReasonsStep {
    return Intl.message(
      'انتخاب علت ابطال',
      name: 'chequeCancelReasonsStep',
      desc: '',
      args: [],
    );
  }

  /// `دانلود نامه و ثبت درخواست`
  String get chequeCancelConfirmationStep {
    return Intl.message(
      'دانلود نامه و ثبت درخواست',
      name: 'chequeCancelConfirmationStep',
      desc: '',
      args: [],
    );
  }

  /// `سپرده پشت چک‌ها و نوع چک‌های مورد نظر‌ جهت ابطال را انتخاب کنید.`
  String get chequeCancelSelectionPrompt {
    return Intl.message(
      'سپرده پشت چک‌ها و نوع چک‌های مورد نظر‌ جهت ابطال را انتخاب کنید.',
      name: 'chequeCancelSelectionPrompt',
      desc: '',
      args: [],
    );
  }

  /// `سپرده مورد نظر خود را انتخاب کنید`
  String get chequeCancelDepositHint {
    return Intl.message(
      'سپرده مورد نظر خود را انتخاب کنید',
      name: 'chequeCancelDepositHint',
      desc: '',
      args: [],
    );
  }

  /// `نوع چک`
  String get chequeCancelType {
    return Intl.message('نوع چک', name: 'chequeCancelType', desc: '', args: []);
  }

  /// `نوع چک را انتخاب کنید`
  String get chequeCancelTypeHint {
    return Intl.message(
      'نوع چک را انتخاب کنید',
      name: 'chequeCancelTypeHint',
      desc: '',
      args: [],
    );
  }

  /// `کاغذی`
  String get chequeCancelPaper {
    return Intl.message('کاغذی', name: 'chequeCancelPaper', desc: '', args: []);
  }

  /// `دیجیتال`
  String get chequeCancelDigital {
    return Intl.message(
      'دیجیتال',
      name: 'chequeCancelDigital',
      desc: '',
      args: [],
    );
  }

  /// `در هر درخواست فقط می‌توانید چک‌های مربوط به یک سپرده و از یک نوع (دیجیتال یا کاغذی) را انتخاب کنید.`
  String get chequeCancelSelectionNotice {
    return Intl.message(
      'در هر درخواست فقط می‌توانید چک‌های مربوط به یک سپرده و از یک نوع (دیجیتال یا کاغذی) را انتخاب کنید.',
      name: 'chequeCancelSelectionNotice',
      desc: '',
      args: [],
    );
  }

  /// `چک‌های مورد نظر‌ جهت ابطال را انتخاب کنید`
  String get chequeCancelChequesPrompt {
    return Intl.message(
      'چک‌های مورد نظر‌ جهت ابطال را انتخاب کنید',
      name: 'chequeCancelChequesPrompt',
      desc: '',
      args: [],
    );
  }

  /// `جستجو بر اساس شماره چک یا شناسه صیاد`
  String get chequeCancelSearchHint {
    return Intl.message(
      'جستجو بر اساس شماره چک یا شناسه صیاد',
      name: 'chequeCancelSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `شماره چک`
  String get chequeCancelNumber {
    return Intl.message(
      'شماره چک',
      name: 'chequeCancelNumber',
      desc: '',
      args: [],
    );
  }

  /// `شناسه صیاد`
  String get chequeCancelSayad {
    return Intl.message(
      'شناسه صیاد',
      name: 'chequeCancelSayad',
      desc: '',
      args: [],
    );
  }

  /// `لیست چک‌های انتخاب شده`
  String get chequeCancelReview {
    return Intl.message(
      'لیست چک‌های انتخاب شده',
      name: 'chequeCancelReview',
      desc: '',
      args: [],
    );
  }

  /// `مطمئنید می‌خواید این چک رو از لیست چک‌های ابطالی حذف کنید؟`
  String get chequeCancelRemovePrompt {
    return Intl.message(
      'مطمئنید می‌خواید این چک رو از لیست چک‌های ابطالی حذف کنید؟',
      name: 'chequeCancelRemovePrompt',
      desc: '',
      args: [],
    );
  }

  /// `بله، حذف کن`
  String get chequeCancelRemove {
    return Intl.message(
      'بله، حذف کن',
      name: 'chequeCancelRemove',
      desc: '',
      args: [],
    );
  }

  /// `علت ابطال چک‌ها را انتخاب کنید`
  String get chequeCancelReasonsPrompt {
    return Intl.message(
      'علت ابطال چک‌ها را انتخاب کنید',
      name: 'chequeCancelReasonsPrompt',
      desc: '',
      args: [],
    );
  }

  /// `علت ابطال چک`
  String get chequeCancelReason {
    return Intl.message(
      'علت ابطال چک',
      name: 'chequeCancelReason',
      desc: '',
      args: [],
    );
  }

  /// `علت ابطال چک را انتخاب کنید`
  String get chequeCancelReasonHint {
    return Intl.message(
      'علت ابطال چک را انتخاب کنید',
      name: 'chequeCancelReasonHint',
      desc: '',
      args: [],
    );
  }

  /// `اعمال یک علت برای همه`
  String get chequeCancelAllReasons {
    return Intl.message(
      'اعمال یک علت برای همه',
      name: 'chequeCancelAllReasons',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب علت برای همه`
  String get chequeCancelAllReasonsTitle {
    return Intl.message(
      'انتخاب علت برای همه',
      name: 'chequeCancelAllReasonsTitle',
      desc: '',
      args: [],
    );
  }

  /// `مخدوش - استفاده نشده`
  String get chequeCancelDamaged {
    return Intl.message(
      'مخدوش - استفاده نشده',
      name: 'chequeCancelDamaged',
      desc: '',
      args: [],
    );
  }

  /// `دستور مرجع قضایی`
  String get chequeCancelJudicial {
    return Intl.message(
      'دستور مرجع قضایی',
      name: 'chequeCancelJudicial',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب`
  String get chequeCancelChoose {
    return Intl.message(
      'انتخاب',
      name: 'chequeCancelChoose',
      desc: '',
      args: [],
    );
  }

  /// `جهت ابطال چک‌ها ابتدا نامه‌ی زیر را دانلود و سپس درخواست خود را ثبت نهایی کنید.`
  String get chequeCancelLetterPrompt {
    return Intl.message(
      'جهت ابطال چک‌ها ابتدا نامه‌ی زیر را دانلود و سپس درخواست خود را ثبت نهایی کنید.',
      name: 'chequeCancelLetterPrompt',
      desc: '',
      args: [],
    );
  }

  /// `ذخیره نامه جهت تحویل به پست`
  String get chequeCancelDownload {
    return Intl.message(
      'ذخیره نامه جهت تحویل به پست',
      name: 'chequeCancelDownload',
      desc: '',
      args: [],
    );
  }

  /// `نامه دانلود شده را چاپ و به همراه چک‌های ذکر شده در آن به یکی از دفاتر پستی مجاز جهت ابطال تحویل دهید.`
  String get chequeCancelMailInstruction {
    return Intl.message(
      'نامه دانلود شده را چاپ و به همراه چک‌های ذکر شده در آن به یکی از دفاتر پستی مجاز جهت ابطال تحویل دهید.',
      name: 'chequeCancelMailInstruction',
      desc: '',
      args: [],
    );
  }

  /// `نتیجه‌ای یافت نشد`
  String get chequeCancelEmpty {
    return Intl.message(
      'نتیجه‌ای یافت نشد',
      name: 'chequeCancelEmpty',
      desc: '',
      args: [],
    );
  }

  /// `درخواست ابطال چک به‌صورت آزمایشی ثبت شد؛ هیچ چکی در بانک باطل نشده است.`
  String get chequeCancelMockComplete {
    return Intl.message(
      'درخواست ابطال چک به‌صورت آزمایشی ثبت شد؛ هیچ چکی در بانک باطل نشده است.',
      name: 'chequeCancelMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب سپرده و شرایط درخواست`
  String get transferSourceStep {
    return Intl.message(
      'انتخاب سپرده و شرایط درخواست',
      name: 'transferSourceStep',
      desc: '',
      args: [],
    );
  }

  /// `آدرس و زمان مراجعه کارشناس`
  String get transferVisitStep {
    return Intl.message(
      'آدرس و زمان مراجعه کارشناس',
      name: 'transferVisitStep',
      desc: '',
      args: [],
    );
  }

  /// `وارد کردن مقصدها`
  String get transferDestinationsStep {
    return Intl.message(
      'وارد کردن مقصدها',
      name: 'transferDestinationsStep',
      desc: '',
      args: [],
    );
  }

  /// `تایید نهایی و پرداخت کارمزد`
  String get transferConfirmationStep {
    return Intl.message(
      'تایید نهایی و پرداخت کارمزد',
      name: 'transferConfirmationStep',
      desc: '',
      args: [],
    );
  }

  /// `سپرده مورد نظر و تاریخ انتقال وجه را انتخاب کنید`
  String get transferSourcePrompt {
    return Intl.message(
      'سپرده مورد نظر و تاریخ انتقال وجه را انتخاب کنید',
      name: 'transferSourcePrompt',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ انتقال وجه`
  String get transferDate {
    return Intl.message(
      'تاریخ انتقال وجه',
      name: 'transferDate',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ انتقال وجه را تعیین کنید`
  String get transferDateHint {
    return Intl.message(
      'تاریخ انتقال وجه را تعیین کنید',
      name: 'transferDateHint',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ انتخابی نمی‌تواند جزء تعطیلات رسمی باشد.`
  String get transferHolidayNotice {
    return Intl.message(
      'تاریخ انتخابی نمی‌تواند جزء تعطیلات رسمی باشد.',
      name: 'transferHolidayNotice',
      desc: '',
      args: [],
    );
  }

  /// `انتخاب روز جاری فقط تا ساعت ۱۰ صبح امکان پذیر است.`
  String get transferCutoffNotice {
    return Intl.message(
      'انتخاب روز جاری فقط تا ساعت ۱۰ صبح امکان پذیر است.',
      name: 'transferCutoffNotice',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ معتبر و غیرتعطیل وارد کنید؛ انتخاب امروز فقط قبل از ساعت ۱۰ امکان دارد.`
  String get transferDateError {
    return Intl.message(
      'تاریخ معتبر و غیرتعطیل وارد کنید؛ انتخاب امروز فقط قبل از ساعت ۱۰ امکان دارد.',
      name: 'transferDateError',
      desc: '',
      args: [],
    );
  }

  /// `آدرس و زمان مراجعه کارشناس را انتخاب کنید.`
  String get transferVisitPrompt {
    return Intl.message(
      'آدرس و زمان مراجعه کارشناس را انتخاب کنید.',
      name: 'transferVisitPrompt',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ مراجعه`
  String get transferVisitDate {
    return Intl.message(
      'تاریخ مراجعه',
      name: 'transferVisitDate',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ مراجعه را تعیین کنید`
  String get transferVisitDateHint {
    return Intl.message(
      'تاریخ مراجعه را تعیین کنید',
      name: 'transferVisitDateHint',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ مراجعه باید روز کاری و بین امروز و تاریخ انتقال وجه باشد.`
  String get transferVisitDateError {
    return Intl.message(
      'تاریخ مراجعه باید روز کاری و بین امروز و تاریخ انتقال وجه باشد.',
      name: 'transferVisitDateError',
      desc: '',
      args: [],
    );
  }

  /// `اطلاعات مقصد را وارد کنید.`
  String get transferDestinationPrompt {
    return Intl.message(
      'اطلاعات مقصد را وارد کنید.',
      name: 'transferDestinationPrompt',
      desc: '',
      args: [],
    );
  }

  /// `افزودن دستی مقصد`
  String get transferAddManual {
    return Intl.message(
      'افزودن دستی مقصد',
      name: 'transferAddManual',
      desc: '',
      args: [],
    );
  }

  /// `افزودن مقصد بعدی`
  String get transferAddNext {
    return Intl.message(
      'افزودن مقصد بعدی',
      name: 'transferAddNext',
      desc: '',
      args: [],
    );
  }

  /// `افزودن مقصد`
  String get transferAddDestination {
    return Intl.message(
      'افزودن مقصد',
      name: 'transferAddDestination',
      desc: '',
      args: [],
    );
  }

  /// `آپلود فایل اکسل`
  String get transferUploadExcel {
    return Intl.message(
      'آپلود فایل اکسل',
      name: 'transferUploadExcel',
      desc: '',
      args: [],
    );
  }

  /// `مبلغ`
  String get transferAmount {
    return Intl.message('مبلغ', name: 'transferAmount', desc: '', args: []);
  }

  /// `مبلغ (ریال)`
  String get transferAmountRial {
    return Intl.message(
      'مبلغ (ریال)',
      name: 'transferAmountRial',
      desc: '',
      args: [],
    );
  }

  /// `مبلغ مورد نظر را وارد کنید`
  String get transferAmountHint {
    return Intl.message(
      'مبلغ مورد نظر را وارد کنید',
      name: 'transferAmountHint',
      desc: '',
      args: [],
    );
  }

  /// `مبلغ معتبر و بزرگ‌تر از صفر وارد کنید.`
  String get transferAmountError {
    return Intl.message(
      'مبلغ معتبر و بزرگ‌تر از صفر وارد کنید.',
      name: 'transferAmountError',
      desc: '',
      args: [],
    );
  }

  /// `نوع انتقال`
  String get transferMethod {
    return Intl.message(
      'نوع انتقال',
      name: 'transferMethod',
      desc: '',
      args: [],
    );
  }

  /// `روش انتقال`
  String get transferMethodRow {
    return Intl.message(
      'روش انتقال',
      name: 'transferMethodRow',
      desc: '',
      args: [],
    );
  }

  /// `نوع انتقال وجه را انتخاب کنید`
  String get transferMethodHint {
    return Intl.message(
      'نوع انتقال وجه را انتخاب کنید',
      name: 'transferMethodHint',
      desc: '',
      args: [],
    );
  }

  /// `ساتنا`
  String get transferSatna {
    return Intl.message('ساتنا', name: 'transferSatna', desc: '', args: []);
  }

  /// `شماره شبا را وارد کنید`
  String get transferIbanHint {
    return Intl.message(
      'شماره شبا را وارد کنید',
      name: 'transferIbanHint',
      desc: '',
      args: [],
    );
  }

  /// `شماره شبای معتبر وارد کنید.`
  String get transferIbanError {
    return Intl.message(
      'شماره شبای معتبر وارد کنید.',
      name: 'transferIbanError',
      desc: '',
      args: [],
    );
  }

  /// `بابت`
  String get transferPurpose {
    return Intl.message('بابت', name: 'transferPurpose', desc: '', args: []);
  }

  /// `علت انتقال را انتخاب کنید`
  String get transferPurposeHint {
    return Intl.message(
      'علت انتقال را انتخاب کنید',
      name: 'transferPurposeHint',
      desc: '',
      args: [],
    );
  }

  /// `واریز حقوق`
  String get transferSalary {
    return Intl.message(
      'واریز حقوق',
      name: 'transferSalary',
      desc: '',
      args: [],
    );
  }

  /// `شناسه واریز / توضیحات`
  String get transferDescription {
    return Intl.message(
      'شناسه واریز / توضیحات',
      name: 'transferDescription',
      desc: '',
      args: [],
    );
  }

  /// `شناسه واریز / توضیحات را وارد کنید`
  String get transferDescriptionHint {
    return Intl.message(
      'شناسه واریز / توضیحات را وارد کنید',
      name: 'transferDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `شناسه واریز`
  String get transferIdentifier {
    return Intl.message(
      'شناسه واریز',
      name: 'transferIdentifier',
      desc: '',
      args: [],
    );
  }

  /// `ثبت`
  String get transferSave {
    return Intl.message('ثبت', name: 'transferSave', desc: '', args: []);
  }

  /// `بررسی`
  String get transferReview {
    return Intl.message('بررسی', name: 'transferReview', desc: '', args: []);
  }

  /// `تایید و مرحله بعد`
  String get transferConfirmNext {
    return Intl.message(
      'تایید و مرحله بعد',
      name: 'transferConfirmNext',
      desc: '',
      args: [],
    );
  }

  /// `فایل XLS غیرخالی با حداکثر حجم ۱۰۰ کیلوبایت انتخاب کنید.`
  String get transferFileInvalid {
    return Intl.message(
      'فایل XLS غیرخالی با حداکثر حجم ۱۰۰ کیلوبایت انتخاب کنید.',
      name: 'transferFileInvalid',
      desc: '',
      args: [],
    );
  }

  /// `برای`
  String get transferUploadBefore {
    return Intl.message(
      'برای',
      name: 'transferUploadBefore',
      desc: '',
      args: [],
    );
  }

  /// `بارگذاری فایل اینجا`
  String get transferUploadAction {
    return Intl.message(
      'بارگذاری فایل اینجا',
      name: 'transferUploadAction',
      desc: '',
      args: [],
    );
  }

  /// `را کلیک کنید.`
  String get transferUploadAfter {
    return Intl.message(
      'را کلیک کنید.',
      name: 'transferUploadAfter',
      desc: '',
      args: [],
    );
  }

  /// `فرمت فایل: XLS  |  حداکثر حجم: ۱۰۰ KB`
  String get transferFileRequirements {
    return Intl.message(
      'فرمت فایل: XLS  |  حداکثر حجم: ۱۰۰ KB',
      name: 'transferFileRequirements',
      desc: '',
      args: [],
    );
  }

  /// `حذف مقصد`
  String get transferDeleteDestination {
    return Intl.message(
      'حذف مقصد',
      name: 'transferDeleteDestination',
      desc: '',
      args: [],
    );
  }

  /// `کارمزد خدمت در محل`
  String get transferServiceFee {
    return Intl.message(
      'کارمزد خدمت در محل',
      name: 'transferServiceFee',
      desc: '',
      args: [],
    );
  }

  /// `درخواست به‌صورت آزمایشی ثبت شد؛ هیچ وجه یا کارمزدی در بانک جابه‌جا نشده است.`
  String get transferMockComplete {
    return Intl.message(
      'درخواست به‌صورت آزمایشی ثبت شد؛ هیچ وجه یا کارمزدی در بانک جابه‌جا نشده است.',
      name: 'transferMockComplete',
      desc: '',
      args: [],
    );
  }

  /// `فایل مقصدها تایید شد؛ بررسی محتوای اکسل در نسخه بعد انجام می‌شود.`
  String get transferFileAccepted {
    return Intl.message(
      'فایل مقصدها تایید شد؛ بررسی محتوای اکسل در نسخه بعد انجام می‌شود.',
      name: 'transferFileAccepted',
      desc: '',
      args: [],
    );
  }

  /// `آدرس مراجعه کارشناس را انتخاب کنید`
  String get transferAddressHint {
    return Intl.message(
      'آدرس مراجعه کارشناس را انتخاب کنید',
      name: 'transferAddressHint',
      desc: '',
      args: [],
    );
  }

  /// `فایل اکسل باید `
  String get transferSamplePrefix {
    return Intl.message(
      'فایل اکسل باید ',
      name: 'transferSamplePrefix',
      desc: '',
      args: [],
    );
  }

  /// `مطابق نمونه`
  String get transferSampleLink {
    return Intl.message(
      'مطابق نمونه',
      name: 'transferSampleLink',
      desc: '',
      args: [],
    );
  }

  /// ` باشد.`
  String get transferSampleSuffix {
    return Intl.message(
      ' باشد.',
      name: 'transferSampleSuffix',
      desc: '',
      args: [],
    );
  }

  /// `داخلی`
  String get transferInternal {
    return Intl.message('داخلی', name: 'transferInternal', desc: '', args: []);
  }

  /// `پایا`
  String get transferPaya {
    return Intl.message('پایا', name: 'transferPaya', desc: '', args: []);
  }

  /// `حذف فایل`
  String get transferDeleteFile {
    return Intl.message(
      'حذف فایل',
      name: 'transferDeleteFile',
      desc: '',
      args: [],
    );
  }

  /// `گزارش درخواست‌ها`
  String get reportTitle {
    return Intl.message(
      'گزارش درخواست‌ها',
      name: 'reportTitle',
      desc: '',
      args: [],
    );
  }

  /// `نوع درخواست`
  String get reportRequestType {
    return Intl.message(
      'نوع درخواست',
      name: 'reportRequestType',
      desc: '',
      args: [],
    );
  }

  /// `وضعیت درخواست`
  String get reportRequestStatus {
    return Intl.message(
      'وضعیت درخواست',
      name: 'reportRequestStatus',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ درخواست`
  String get reportRequestDate {
    return Intl.message(
      'تاریخ درخواست',
      name: 'reportRequestDate',
      desc: '',
      args: [],
    );
  }

  /// `تاریخ`
  String get reportDate {
    return Intl.message('تاریخ', name: 'reportDate', desc: '', args: []);
  }

  /// `وضعیت`
  String get reportStatus {
    return Intl.message('وضعیت', name: 'reportStatus', desc: '', args: []);
  }

  /// `شناسه`
  String get reportIdentifier {
    return Intl.message('شناسه', name: 'reportIdentifier', desc: '', args: []);
  }

  /// `جزئیات`
  String get reportDetails {
    return Intl.message('جزئیات', name: 'reportDetails', desc: '', args: []);
  }

  /// `شناسه پرداخت`
  String get reportSearchIdentifier {
    return Intl.message(
      'شناسه پرداخت',
      name: 'reportSearchIdentifier',
      desc: '',
      args: [],
    );
  }

  /// `جستجوی نوع درخواست`
  String get reportSearchTypes {
    return Intl.message(
      'جستجوی نوع درخواست',
      name: 'reportSearchTypes',
      desc: '',
      args: [],
    );
  }

  /// `(انتخاب همه)`
  String get reportSelectAll {
    return Intl.message(
      '(انتخاب همه)',
      name: 'reportSelectAll',
      desc: '',
      args: [],
    );
  }

  /// `اعمال فیلتر`
  String get reportApplyFilter {
    return Intl.message(
      'اعمال فیلتر',
      name: 'reportApplyFilter',
      desc: '',
      args: [],
    );
  }

  /// `نوع درخواستی پیدا نشد.`
  String get reportNoTypes {
    return Intl.message(
      'نوع درخواستی پیدا نشد.',
      name: 'reportNoTypes',
      desc: '',
      args: [],
    );
  }

  /// `درخواستی با این مشخصات پیدا نشد.`
  String get reportNoResults {
    return Intl.message(
      'درخواستی با این مشخصات پیدا نشد.',
      name: 'reportNoResults',
      desc: '',
      args: [],
    );
  }

  /// `دریافت گزارش درخواست‌ها ناموفق بود.`
  String get reportLoadError {
    return Intl.message(
      'دریافت گزارش درخواست‌ها ناموفق بود.',
      name: 'reportLoadError',
      desc: '',
      args: [],
    );
  }

  /// `جزئیات درخواست`
  String get reportDetailsTitle {
    return Intl.message(
      'جزئیات درخواست',
      name: 'reportDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `لغو درخواست`
  String get reportCancelRequest {
    return Intl.message(
      'لغو درخواست',
      name: 'reportCancelRequest',
      desc: '',
      args: [],
    );
  }

  /// `مطمئنید می‌خواید این درخواست رو لغو کنید؟`
  String get reportCancelPrompt {
    return Intl.message(
      'مطمئنید می‌خواید این درخواست رو لغو کنید؟',
      name: 'reportCancelPrompt',
      desc: '',
      args: [],
    );
  }

  /// `بله، لغو کن`
  String get reportConfirmCancel {
    return Intl.message(
      'بله، لغو کن',
      name: 'reportConfirmCancel',
      desc: '',
      args: [],
    );
  }

  /// `لغو درخواست انجام نشد. دوباره تلاش کنید یا گزارش را به‌روز کنید.`
  String get reportCancelError {
    return Intl.message(
      'لغو درخواست انجام نشد. دوباره تلاش کنید یا گزارش را به‌روز کنید.',
      name: 'reportCancelError',
      desc: '',
      args: [],
    );
  }

  /// `در انتظار تایید`
  String get reportStatusAwaitingApproval {
    return Intl.message(
      'در انتظار تایید',
      name: 'reportStatusAwaitingApproval',
      desc: '',
      args: [],
    );
  }

  /// `انجام شده خودکار`
  String get reportStatusCompleted {
    return Intl.message(
      'انجام شده خودکار',
      name: 'reportStatusCompleted',
      desc: '',
      args: [],
    );
  }

  /// `رد شده`
  String get reportStatusRejected {
    return Intl.message(
      'رد شده',
      name: 'reportStatusRejected',
      desc: '',
      args: [],
    );
  }

  /// `خطای سیستم`
  String get reportStatusSystemError {
    return Intl.message(
      'خطای سیستم',
      name: 'reportStatusSystemError',
      desc: '',
      args: [],
    );
  }

  /// `لغو شده`
  String get reportStatusCancelled {
    return Intl.message(
      'لغو شده',
      name: 'reportStatusCancelled',
      desc: '',
      args: [],
    );
  }

  /// `امروز`
  String get reportDateToday {
    return Intl.message('امروز', name: 'reportDateToday', desc: '', args: []);
  }

  /// `هفته گذشته`
  String get reportDateLastWeek {
    return Intl.message(
      'هفته گذشته',
      name: 'reportDateLastWeek',
      desc: '',
      args: [],
    );
  }

  /// `ماه گذشته`
  String get reportDateLastMonth {
    return Intl.message(
      'ماه گذشته',
      name: 'reportDateLastMonth',
      desc: '',
      args: [],
    );
  }

  /// `۳ ماه گذشته`
  String get reportDateLastThreeMonths {
    return Intl.message(
      '۳ ماه گذشته',
      name: 'reportDateLastThreeMonths',
      desc: '',
      args: [],
    );
  }

  /// `افتتاح سپرده جاری`
  String get reportTypeCurrentDeposit {
    return Intl.message(
      'افتتاح سپرده جاری',
      name: 'reportTypeCurrentDeposit',
      desc: '',
      args: [],
    );
  }

  /// `مسدودی سپرده`
  String get reportTypeBlockDeposit {
    return Intl.message(
      'مسدودی سپرده',
      name: 'reportTypeBlockDeposit',
      desc: '',
      args: [],
    );
  }

  /// `رفع مسدودی سپرده`
  String get reportTypeUnblockDeposit {
    return Intl.message(
      'رفع مسدودی سپرده',
      name: 'reportTypeUnblockDeposit',
      desc: '',
      args: [],
    );
  }

  /// `تغییر گذرواژه موبایل بانک`
  String get reportTypeMobilePassword {
    return Intl.message(
      'تغییر گذرواژه موبایل بانک',
      name: 'reportTypeMobilePassword',
      desc: '',
      args: [],
    );
  }

  /// `تغییر گذرواژه اینترنت بانک`
  String get reportTypeInternetPassword {
    return Intl.message(
      'تغییر گذرواژه اینترنت بانک',
      name: 'reportTypeInternetPassword',
      desc: '',
      args: [],
    );
  }

  /// `تغییر سپرده جهت کسر اقساط`
  String get reportTypeInstallmentDeposit {
    return Intl.message(
      'تغییر سپرده جهت کسر اقساط',
      name: 'reportTypeInstallmentDeposit',
      desc: '',
      args: [],
    );
  }

  /// `صدور دسته چک`
  String get reportTypeChequeBook {
    return Intl.message(
      'صدور دسته چک',
      name: 'reportTypeChequeBook',
      desc: '',
      args: [],
    );
  }

  /// `رفع سوء اثر چک`
  String get reportTypeChequeClearance {
    return Intl.message(
      'رفع سوء اثر چک',
      name: 'reportTypeChequeClearance',
      desc: '',
      args: [],
    );
  }

  /// `انتقال وجه در محل`
  String get reportTypeOnSiteTransfer {
    return Intl.message(
      'انتقال وجه در محل',
      name: 'reportTypeOnSiteTransfer',
      desc: '',
      args: [],
    );
  }

  /// `خطا در پردازش`
  String get reportStatusProcessingError {
    return Intl.message(
      'خطا در پردازش',
      name: 'reportStatusProcessingError',
      desc: '',
      args: [],
    );
  }

  /// `در انتظار بررسی`
  String get reportStatusAwaitingReview {
    return Intl.message(
      'در انتظار بررسی',
      name: 'reportStatusAwaitingReview',
      desc: '',
      args: [],
    );
  }

  /// `تغییر شماره تلفن همراه`
  String get profileChangePhone {
    return Intl.message(
      'تغییر شماره تلفن همراه',
      name: 'profileChangePhone',
      desc: '',
      args: [],
    );
  }

  /// `شماره باید با کد ملی دارنده حساب مطابقت داشته باشد`
  String get profilePhoneNotice {
    return Intl.message(
      'شماره باید با کد ملی دارنده حساب مطابقت داشته باشد',
      name: 'profilePhoneNotice',
      desc: '',
      args: [],
    );
  }

  /// `شماره فعلی`
  String get profileCurrentPhone {
    return Intl.message(
      'شماره فعلی',
      name: 'profileCurrentPhone',
      desc: '',
      args: [],
    );
  }

  /// `شماره جدید`
  String get profileNewPhone {
    return Intl.message(
      'شماره جدید',
      name: 'profileNewPhone',
      desc: '',
      args: [],
    );
  }

  /// `شماره جدید خود را وارد کنید`
  String get profileNewPhoneHint {
    return Intl.message(
      'شماره جدید خود را وارد کنید',
      name: 'profileNewPhoneHint',
      desc: '',
      args: [],
    );
  }

  /// `رمز دوم`
  String get profileSecondPassword {
    return Intl.message(
      'رمز دوم',
      name: 'profileSecondPassword',
      desc: '',
      args: [],
    );
  }

  /// `وارد کردن رمز`
  String get profileOtpHint {
    return Intl.message(
      'وارد کردن رمز',
      name: 'profileOtpHint',
      desc: '',
      args: [],
    );
  }

  /// `درخواست رمز پویا`
  String get profileRequestOtp {
    return Intl.message(
      'درخواست رمز پویا',
      name: 'profileRequestOtp',
      desc: '',
      args: [],
    );
  }

  /// `رمز وارد شده صحیح نیست`
  String get profileOtpInvalid {
    return Intl.message(
      'رمز وارد شده صحیح نیست',
      name: 'profileOtpInvalid',
      desc: '',
      args: [],
    );
  }

  /// `اعتبار رمز به پایان رسیده است؛ دوباره درخواست دهید`
  String get profileOtpExpired {
    return Intl.message(
      'اعتبار رمز به پایان رسیده است؛ دوباره درخواست دهید',
      name: 'profileOtpExpired',
      desc: '',
      args: [],
    );
  }

  /// `هزینه استعلام شاهکار`
  String get profileShahkarFee {
    return Intl.message(
      'هزینه استعلام شاهکار',
      name: 'profileShahkarFee',
      desc: '',
      args: [],
    );
  }

  /// `درخواست تغییر شماره همراه ثبت شد.`
  String get profilePhoneSubmitted {
    return Intl.message(
      'درخواست تغییر شماره همراه ثبت شد.',
      name: 'profilePhoneSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `افزودن آدرس جدید`
  String get profileAddAddress {
    return Intl.message(
      'افزودن آدرس جدید',
      name: 'profileAddAddress',
      desc: '',
      args: [],
    );
  }

  /// `ویرایش آدرس`
  String get profileEditAddress {
    return Intl.message(
      'ویرایش آدرس',
      name: 'profileEditAddress',
      desc: '',
      args: [],
    );
  }

  /// `حذف آدرس`
  String get profileDeleteAddress {
    return Intl.message(
      'حذف آدرس',
      name: 'profileDeleteAddress',
      desc: '',
      args: [],
    );
  }

  /// `نوع آدرس`
  String get profileAddressType {
    return Intl.message(
      'نوع آدرس',
      name: 'profileAddressType',
      desc: '',
      args: [],
    );
  }

  /// `خانه`
  String get profileHome {
    return Intl.message('خانه', name: 'profileHome', desc: '', args: []);
  }

  /// `محل کار`
  String get profileWork {
    return Intl.message('محل کار', name: 'profileWork', desc: '', args: []);
  }

  /// `شماره تلفن:`
  String get profileTelephone {
    return Intl.message(
      'شماره تلفن:',
      name: 'profileTelephone',
      desc: '',
      args: [],
    );
  }

  /// `آدرس پستی:`
  String get profilePostalAddress {
    return Intl.message(
      'آدرس پستی:',
      name: 'profilePostalAddress',
      desc: '',
      args: [],
    );
  }

  /// `وضعیت اسکان و املاک`
  String get profileResidenceStatus {
    return Intl.message(
      'وضعیت اسکان و املاک',
      name: 'profileResidenceStatus',
      desc: '',
      args: [],
    );
  }

  /// `بررسی`
  String get profileReview {
    return Intl.message('بررسی', name: 'profileReview', desc: '', args: []);
  }

  /// `در حال استعلام ...`
  String get profileQuerying {
    return Intl.message(
      'در حال استعلام ...',
      name: 'profileQuerying',
      desc: '',
      args: [],
    );
  }

  /// `معتبر`
  String get profileValid {
    return Intl.message('معتبر', name: 'profileValid', desc: '', args: []);
  }

  /// `فاقد اسکان و املاک`
  String get profileMissingResidence {
    return Intl.message(
      'فاقد اسکان و املاک',
      name: 'profileMissingResidence',
      desc: '',
      args: [],
    );
  }

  /// `برای انجام درخواست‌های (صدور دسته چک، افتتاح حساب جاری،...) آدرس‌های محل سکونت باید در`
  String get profileResidenceNotice {
    return Intl.message(
      'برای انجام درخواست‌های (صدور دسته چک، افتتاح حساب جاری،...) آدرس‌های محل سکونت باید در',
      name: 'profileResidenceNotice',
      desc: '',
      args: [],
    );
  }

  /// `آدرسی ثبت نشده است`
  String get profileAddressesEmpty {
    return Intl.message(
      'آدرسی ثبت نشده است',
      name: 'profileAddressesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `استعلام انجام نشد؛ دوباره بررسی کنید`
  String get profileReviewError {
    return Intl.message(
      'استعلام انجام نشد؛ دوباره بررسی کنید',
      name: 'profileReviewError',
      desc: '',
      args: [],
    );
  }

  /// `عملیات انجام نشد؛ دوباره تلاش کنید`
  String get profileOperationError {
    return Intl.message(
      'عملیات انجام نشد؛ دوباره تلاش کنید',
      name: 'profileOperationError',
      desc: '',
      args: [],
    );
  }

  /// `افزودن شغل جدید`
  String get profileAddOccupation {
    return Intl.message(
      'افزودن شغل جدید',
      name: 'profileAddOccupation',
      desc: '',
      args: [],
    );
  }

  /// `ویرایش شغل`
  String get profileEditOccupation {
    return Intl.message(
      'ویرایش شغل',
      name: 'profileEditOccupation',
      desc: '',
      args: [],
    );
  }

  /// `حذف شغل`
  String get profileDeleteOccupation {
    return Intl.message(
      'حذف شغل',
      name: 'profileDeleteOccupation',
      desc: '',
      args: [],
    );
  }

  /// `شغل`
  String get profileOccupation {
    return Intl.message('شغل', name: 'profileOccupation', desc: '', args: []);
  }

  /// `شغل خود را انتخاب کنید`
  String get profileOccupationHint {
    return Intl.message(
      'شغل خود را انتخاب کنید',
      name: 'profileOccupationHint',
      desc: '',
      args: [],
    );
  }

  /// `شرح شغل`
  String get profileOccupationDescription {
    return Intl.message(
      'شرح شغل',
      name: 'profileOccupationDescription',
      desc: '',
      args: [],
    );
  }

  /// `شرح شغل خود را وارد کنید`
  String get profileOccupationDescriptionHint {
    return Intl.message(
      'شرح شغل خود را وارد کنید',
      name: 'profileOccupationDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `شرح شغل را وارد کنید`
  String get profileDescriptionRequired {
    return Intl.message(
      'شرح شغل را وارد کنید',
      name: 'profileDescriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `حداکثر تا ۳ ساعت پس از ثبت درخواست شغل جدید قابل مشاهده خواهد بود`
  String get profileOccupationNotice {
    return Intl.message(
      'حداکثر تا ۳ ساعت پس از ثبت درخواست شغل جدید قابل مشاهده خواهد بود',
      name: 'profileOccupationNotice',
      desc: '',
      args: [],
    );
  }

  /// `عنوان شغلی انتخاب شده ({selected}) از گروه فاقدین شغل است و با شغل قبلی شما ({existing}) نمی‌تواند به صورت همزمان انتخاب شود.`
  String profileOccupationConflict(String selected, String existing) {
    return Intl.message(
      'عنوان شغلی انتخاب شده ($selected) از گروه فاقدین شغل است و با شغل قبلی شما ($existing) نمی‌تواند به صورت همزمان انتخاب شود.',
      name: 'profileOccupationConflict',
      desc: '',
      args: [selected, existing],
    );
  }

  /// `برای تغییر از عنوان شغلی {previous} به {selected} نیاز به بررسی اپراتور است که پس از تایید تغییرات در پنل کاربری شما قابل مشاهده خواهد بود.`
  String profileOccupationReview(String previous, String selected) {
    return Intl.message(
      'برای تغییر از عنوان شغلی $previous به $selected نیاز به بررسی اپراتور است که پس از تایید تغییرات در پنل کاربری شما قابل مشاهده خواهد بود.',
      name: 'profileOccupationReview',
      desc: '',
      args: [previous, selected],
    );
  }

  /// `درخواست شغل ثبت شد و پس از بررسی قابل مشاهده خواهد بود.`
  String get profileOccupationQueued {
    return Intl.message(
      'درخواست شغل ثبت شد و پس از بررسی قابل مشاهده خواهد بود.',
      name: 'profileOccupationQueued',
      desc: '',
      args: [],
    );
  }

  /// `شغلی ثبت نشده است`
  String get profileOccupationsEmpty {
    return Intl.message(
      'شغلی ثبت نشده است',
      name: 'profileOccupationsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `عنوان`
  String get profileTitle {
    return Intl.message('عنوان', name: 'profileTitle', desc: '', args: []);
  }

  /// `شرح`
  String get profileDescription {
    return Intl.message('شرح', name: 'profileDescription', desc: '', args: []);
  }

  /// `طراح`
  String get profileDesigner {
    return Intl.message('طراح', name: 'profileDesigner', desc: '', args: []);
  }

  /// `مدرس`
  String get profileTeacher {
    return Intl.message('مدرس', name: 'profileTeacher', desc: '', args: []);
  }

  /// `استاد`
  String get profileProfessor {
    return Intl.message('استاد', name: 'profileProfessor', desc: '', args: []);
  }

  /// `خانه‌دار`
  String get profileHomemaker {
    return Intl.message(
      'خانه‌دار',
      name: 'profileHomemaker',
      desc: '',
      args: [],
    );
  }

  /// `ثبت درخواست`
  String get profileSubmit {
    return Intl.message(
      'ثبت درخواست',
      name: 'profileSubmit',
      desc: '',
      args: [],
    );
  }

  /// ` سامانه اسکان و املاک`
  String get profileResidenceRegistry {
    return Intl.message(
      ' سامانه اسکان و املاک',
      name: 'profileResidenceRegistry',
      desc: '',
      args: [],
    );
  }

  /// ` ثبت شده باشند.`
  String get profileResidenceRegistered {
    return Intl.message(
      ' ثبت شده باشند.',
      name: 'profileResidenceRegistered',
      desc: '',
      args: [],
    );
  }

  /// `از حذف شغل خود ({occupation}) مطمئن هستید؟`
  String profileDeleteOccupationPrompt(String occupation) {
    return Intl.message(
      'از حذف شغل خود ($occupation) مطمئن هستید؟',
      name: 'profileDeleteOccupationPrompt',
      desc: '',
      args: [occupation],
    );
  }

  /// `وجود حداقل یک شغل ثبت شده در پیشخوان الزامی‌است. شما می‌توانید بجای حذف این شغل آن را ویرایش کنید.`
  String get profileMinimumOccupation {
    return Intl.message(
      'وجود حداقل یک شغل ثبت شده در پیشخوان الزامی‌است. شما می‌توانید بجای حذف این شغل آن را ویرایش کنید.',
      name: 'profileMinimumOccupation',
      desc: '',
      args: [],
    );
  }

  /// `وجود حداقل یک آدرس خانه در پیشخوان الزامی‌است. لطفا ابتدا آدرس خانه خود را ثبت کرده سپس اقدام به ویرایش یا حذف این آدرس کنید.`
  String get profileMinimumAddress {
    return Intl.message(
      'وجود حداقل یک آدرس خانه در پیشخوان الزامی‌است. لطفا ابتدا آدرس خانه خود را ثبت کرده سپس اقدام به ویرایش یا حذف این آدرس کنید.',
      name: 'profileMinimumAddress',
      desc: '',
      args: [],
    );
  }

  /// `فعالسازی موبایل بانک`
  String get modernActivate {
    return Intl.message(
      'فعالسازی موبایل بانک',
      name: 'modernActivate',
      desc: '',
      args: [],
    );
  }

  /// `برای ورود به همراه بانک رسالت نیاز به فعالسازی آن دارید.`
  String get modernActivationIntro {
    return Intl.message(
      'برای ورود به همراه بانک رسالت نیاز به فعالسازی آن دارید.',
      name: 'modernActivationIntro',
      desc: '',
      args: [],
    );
  }

  /// `نام کاربری شما به صورت پیش‌فرض، شماره مشتری می‌باشد. شماره مشتری روی کارت بانکی شما، درست بالای شماره کارت ثبت شده است.`
  String get modernUsernameNotice {
    return Intl.message(
      'نام کاربری شما به صورت پیش‌فرض، شماره مشتری می‌باشد. شماره مشتری روی کارت بانکی شما، درست بالای شماره کارت ثبت شده است.',
      name: 'modernUsernameNotice',
      desc: '',
      args: [],
    );
  }

  /// `احراز هویت مشروط به تطابق کد ملی و شماره همراه است.`
  String get modernIdentityNotice {
    return Intl.message(
      'احراز هویت مشروط به تطابق کد ملی و شماره همراه است.',
      name: 'modernIdentityNotice',
      desc: '',
      args: [],
    );
  }

  /// `کارمزد ثبت احوال`
  String get modernRegistryFee {
    return Intl.message(
      'کارمزد ثبت احوال',
      name: 'modernRegistryFee',
      desc: '',
      args: [],
    );
  }

  /// `کارمزد دریافت رمز`
  String get modernPasswordFee {
    return Intl.message(
      'کارمزد دریافت رمز',
      name: 'modernPasswordFee',
      desc: '',
      args: [],
    );
  }

  /// `پرداخت کارمزد`
  String get modernPaymentStep {
    return Intl.message(
      'پرداخت کارمزد',
      name: 'modernPaymentStep',
      desc: '',
      args: [],
    );
  }

  /// `عملیات همراه بانک`
  String get modernOperations {
    return Intl.message(
      'عملیات همراه بانک',
      name: 'modernOperations',
      desc: '',
      args: [],
    );
  }

  /// `فراموشی رمز موبایل بانک`
  String get modernRecoveryTitle {
    return Intl.message(
      'فراموشی رمز موبایل بانک',
      name: 'modernRecoveryTitle',
      desc: '',
      args: [],
    );
  }

  /// `وضعیت درخواست`
  String get modernRequestStatus {
    return Intl.message(
      'وضعیت درخواست',
      name: 'modernRequestStatus',
      desc: '',
      args: [],
    );
  }

  /// `در انتظار نتیجه تایید هویت`
  String get modernAwaitingIdentity {
    return Intl.message(
      'در انتظار نتیجه تایید هویت',
      name: 'modernAwaitingIdentity',
      desc: '',
      args: [],
    );
  }

  /// `درصورتی که فرآیند احراز هویت با خطا روبرو شود مبلغ کارمزد کسر شده تا ۷۲ ساعت به کیف پول شما باز خواهد گشت.`
  String get modernRefundNotice {
    return Intl.message(
      'درصورتی که فرآیند احراز هویت با خطا روبرو شود مبلغ کارمزد کسر شده تا ۷۲ ساعت به کیف پول شما باز خواهد گشت.',
      name: 'modernRefundNotice',
      desc: '',
      args: [],
    );
  }

  /// `احراز هویت تأیید نشده است. می‌توانید درخواست جدیدی ثبت کنید.`
  String get modernRejected {
    return Intl.message(
      'احراز هویت تأیید نشده است. می‌توانید درخواست جدیدی ثبت کنید.',
      name: 'modernRejected',
      desc: '',
      args: [],
    );
  }

  /// `این تصویر نمونهٔ مرحلهٔ پس از ضبط است؛ فعلاً ویدئویی ضبط یا ارسال نمی‌شود.`
  String get modernPreviewNotice {
    return Intl.message(
      'این تصویر نمونهٔ مرحلهٔ پس از ضبط است؛ فعلاً ویدئویی ضبط یا ارسال نمی‌شود.',
      name: 'modernPreviewNotice',
      desc: '',
      args: [],
    );
  }

  /// `متن قوانین این خدمت هنوز ارائه نشده است.`
  String get modernTermsUnavailable {
    return Intl.message(
      'متن قوانین این خدمت هنوز ارائه نشده است.',
      name: 'modernTermsUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `تغییر سقف انتقال وجه`
  String get modernLimitsTitle {
    return Intl.message(
      'تغییر سقف انتقال وجه',
      name: 'modernLimitsTitle',
      desc: '',
      args: [],
    );
  }

  /// `سقف مجاز انتقال وجه روزانه در موبایل بانک شما به شرح زیر است.`
  String get modernLimitsIntro {
    return Intl.message(
      'سقف مجاز انتقال وجه روزانه در موبایل بانک شما به شرح زیر است.',
      name: 'modernLimitsIntro',
      desc: '',
      args: [],
    );
  }

  /// `سقف مجاز روزانه هر یک از انتقال وجه‌های زیر را برای موبایل بانک خود مشخص و ثبت کنید.`
  String get modernLimitsEditIntro {
    return Intl.message(
      'سقف مجاز روزانه هر یک از انتقال وجه‌های زیر را برای موبایل بانک خود مشخص و ثبت کنید.',
      name: 'modernLimitsEditIntro',
      desc: '',
      args: [],
    );
  }

  /// `درون بانکی`
  String get modernInternal {
    return Intl.message(
      'درون بانکی',
      name: 'modernInternal',
      desc: '',
      args: [],
    );
  }

  /// `حواله پایا بین بانکی`
  String get modernPaya {
    return Intl.message(
      'حواله پایا بین بانکی',
      name: 'modernPaya',
      desc: '',
      args: [],
    );
  }

  /// `ساتنا بین بانکی`
  String get modernSatna {
    return Intl.message(
      'ساتنا بین بانکی',
      name: 'modernSatna',
      desc: '',
      args: [],
    );
  }

  /// `ویرایش`
  String get modernEdit {
    return Intl.message('ویرایش', name: 'modernEdit', desc: '', args: []);
  }

  /// `مبلغی بیشتر از صفر و حداکثر تا سقف مجاز وارد کنید.`
  String get modernLimitError {
    return Intl.message(
      'مبلغی بیشتر از صفر و حداکثر تا سقف مجاز وارد کنید.',
      name: 'modernLimitError',
      desc: '',
      args: [],
    );
  }

  /// `حداکثر مبلغ مجاز انتقال وجه روزانه: {amount} ریال`
  String modernMaximumLimit(String amount) {
    return Intl.message(
      'حداکثر مبلغ مجاز انتقال وجه روزانه: $amount ریال',
      name: 'modernMaximumLimit',
      desc: '',
      args: [amount],
    );
  }

  /// `{amount} تومان`
  String modernToman(String amount) {
    return Intl.message(
      '$amount تومان',
      name: 'modernToman',
      desc: '',
      args: [amount],
    );
  }

  /// `سقف انتقال وجه در نسخهٔ آزمایشی ذخیره شد؛ تغییری در حساب بانکی انجام نشده است.`
  String get modernLimitsSaved {
    return Intl.message(
      'سقف انتقال وجه در نسخهٔ آزمایشی ذخیره شد؛ تغییری در حساب بانکی انجام نشده است.',
      name: 'modernLimitsSaved',
      desc: '',
      args: [],
    );
  }

  /// `غیرفعالسازی`
  String get modernDeactivate {
    return Intl.message(
      'غیرفعالسازی',
      name: 'modernDeactivate',
      desc: '',
      args: [],
    );
  }

  /// `غیرفعالسازی موبایل بانک`
  String get modernDeactivationTitle {
    return Intl.message(
      'غیرفعالسازی موبایل بانک',
      name: 'modernDeactivationTitle',
      desc: '',
      args: [],
    );
  }

  /// `علت درخواست غیرفعالسازی موبایل بانک خود را انتخاب کنید.`
  String get modernDeactivationIntro {
    return Intl.message(
      'علت درخواست غیرفعالسازی موبایل بانک خود را انتخاب کنید.',
      name: 'modernDeactivationIntro',
      desc: '',
      args: [],
    );
  }

  /// `نام کاربری`
  String get modernUsername {
    return Intl.message(
      'نام کاربری',
      name: 'modernUsername',
      desc: '',
      args: [],
    );
  }

  /// `علت درخواست`
  String get modernReason {
    return Intl.message(
      'علت درخواست',
      name: 'modernReason',
      desc: '',
      args: [],
    );
  }

  /// `علت درخواست خود را انتخاب کنید`
  String get modernReasonHint {
    return Intl.message(
      'علت درخواست خود را انتخاب کنید',
      name: 'modernReasonHint',
      desc: '',
      args: [],
    );
  }

  /// `احتمال هک شدن`
  String get modernCompromised {
    return Intl.message(
      'احتمال هک شدن',
      name: 'modernCompromised',
      desc: '',
      args: [],
    );
  }

  /// `سایر`
  String get modernOtherReason {
    return Intl.message('سایر', name: 'modernOtherReason', desc: '', args: []);
  }

  /// `درخواست غیرفعالسازی در نسخهٔ آزمایشی ثبت شد؛ سرویس بانکی واقعی تغییر نکرده است.`
  String get modernDeactivationSaved {
    return Intl.message(
      'درخواست غیرفعالسازی در نسخهٔ آزمایشی ثبت شد؛ سرویس بانکی واقعی تغییر نکرده است.',
      name: 'modernDeactivationSaved',
      desc: '',
      args: [],
    );
  }

  /// `برای تغییر رمز موبایل بانک ابتدا وارد موبایل بانک خود شوید.`
  String get modernGuideLogin {
    return Intl.message(
      'برای تغییر رمز موبایل بانک ابتدا وارد موبایل بانک خود شوید.',
      name: 'modernGuideLogin',
      desc: '',
      args: [],
    );
  }

  /// `از بخش سایر، گزینه تغییر رمز عبور را انتخاب کنید.`
  String get modernGuideOther {
    return Intl.message(
      'از بخش سایر، گزینه تغییر رمز عبور را انتخاب کنید.',
      name: 'modernGuideOther',
      desc: '',
      args: [],
    );
  }

  /// `رمز عبور فعلی خود و رمز جدید خود را وارد و تکرار کنید.`
  String get modernGuidePassword {
    return Intl.message(
      'رمز عبور فعلی خود و رمز جدید خود را وارد و تکرار کنید.',
      name: 'modernGuidePassword',
      desc: '',
      args: [],
    );
  }

  /// `مرحله {page} از ۴`
  String modernGuidePage(int page) {
    return Intl.message(
      'مرحله $page از ۴',
      name: 'modernGuidePage',
      desc: '',
      args: [page],
    );
  }

  /// `وارد کردن سریال پشت کارت ملی`
  String get modernSerialStep {
    return Intl.message(
      'وارد کردن سریال پشت کارت ملی',
      name: 'modernSerialStep',
      desc: '',
      args: [],
    );
  }

  /// `احراز هویت`
  String get modernKycStep {
    return Intl.message(
      'احراز هویت',
      name: 'modernKycStep',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'fa'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
