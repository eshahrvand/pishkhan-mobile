<div dir="rtl" lang="fa" align="right">

# بازبینی همهٔ فیچرها با قرارداد UI / Cubit / State

> این گزارش snapshot پیش از اصلاحات است. وضعیت اصلاح یافته‌ها و اجرای جدید در [گزارش اصلاحات](2026-10-17-ui-cubit-contract-fixes.md) ثبت شده است.

تاریخ: ۲۰۲۶/۱۰/۱۷ — مبنا: [قرارداد نسخهٔ ۱.۶](../doc/ui-cubit-state-agent-rules-en.md) و [AGENTS.md](../AGENTS.md).

**نتیجه:** انطباق کامل نیست. اتصال DI و ساختار Stateها عمدتاً مطابق جهت مصوب شده، اما UI فیلتر کارت، Back داشبورد، ساخت State اعلان‌ها، مصرف بعضی effectها و مرزهای subscription هنوز مسئله دارند. اجرای فعلی تست‌ها نیز سبز نیست.

این کار صرفاً بازبینی است؛ فایل Dart، تست، قواعد معماری یا بستهٔ avp_ui اصلاح نشده است. گزارش روی snapshot فعلیِ دارای تغییرات commit‌نشده تهیه شده؛ اجرای قدیمی با نتیجهٔ ۳۶۴ موفق را نمی‌توان به این snapshot نسبت داد.

## محدوده و روش

هر شش فیچر `launch`، `auth`، `dashboard`، `cards`، `deposits` و `profile` در فهرست بررسی قرار گرفتند. ۲۱۴ فایل Dart دست‌نویس در این فیچرها فهرست و برای الگوهای قرارداد بررسی شدند؛ generatedها کنار گذاشته شدند. ۱۵ Cubit و ۱۵ State وجود دارد.

بازبینی دستی بر نقطهٔ ورود همهٔ جریان‌های موجود، Providerها، Cubit/State، تصمیم‌های callback و modal، Back، عملیات async و اجزای subscription متمرکز بود. جست‌وجوی ساختاری سراسر فایل‌ها برای DI، کلیدها، setState، getterها، callbackها، کنترل خام و typography مکمل این بررسی است؛ نتیجهٔ ابزار به‌تنهایی «انطباق کامل» محسوب نشده است. بررسی تصویری تمام صفحه‌ها یا اثبات درستی تمام قواعد بانکی انجام نشده است.

فقط جریان‌های پیاده‌سازی‌شده بررسی می‌شوند. عنوانی در کاتالوگ مانند خرید کارت هدیه که هنوز مسیر عملیاتی ندارد، یک فلوی کامل مستقل فرض نشده است. صدور و تجدید کارت نیز یک پیاده‌سازی مشترک دارند.

اولویت‌ها: **P1** مانع اعتبارسنجی تحویل؛ **P2** نقض معماری یا رفتار قابل‌توجه؛ **P3** استایل/مرزبندی قابل‌اصلاح. «مانع انطباق» یعنی نیاز به تصمیم API/طراحی با شواهد مشخص، نه اجازهٔ ساخت استثنا.

## پوشش، فیچر به فیچر

| ترتیب | فیچر | فایل دست‌نویس | جریان‌ها و بخش‌های بررسی‌شده | نتیجه |
| --- | --- | ---: | --- | --- |
| ۱ | Launch | ۲ | Splash و مسیر unavailable | تخلف قطعی مهم در محدودهٔ قواعد بررسی‌شده ثبت نشد؛ صفحهٔ ثابت به Cubit تشریفاتی نیاز ندارد |
| ۲ | Auth | ۱۰ | ورود، تغییر موبایل، OTP مشترک، خدمات مهمان | هستهٔ مالکیت درست؛ A01–A02 |
| ۳ | Dashboard | ۵۱ | Home، علاقه‌مندی/ویرایش/reset، Reso، شیت جست‌وجو، همهٔ خدمات، تب‌های کارت/سپرده/تسهیلات | D01–D04 و V01 |
| ۴ | Cards | ۹۵ | فهرست/فیلتر/جزئیات، صدور/تجدید، تغییر سپردهٔ کارت، موجودی هدیهٔ منقضی، درخواست مجازی، تنظیم/تغییر/بازیابی رمز و رسید/KYC نمایشی | C01–C05 و G01–G02 |
| ۵ | Deposits | ۴۸ | فهرست/فیلتر/جزئیات، معدل حساب، تمکن، افزودن/حذف آدرس | E01–E04 و G01–G02 |
| ۶ | Profile | ۸ | صندوق اعلان، خواندن تکی/همه، جزئیات پیام | P01–P05 |

موفق‌بودن یک محور در یک فیچر به معنی بی‌نقص‌بودن همان فیچر نیست. یافته‌های پایین نمونهٔ قابل‌اقدام از نقض‌های تأییدشده‌اند؛ نبود یافته برای یک تابع، گواه رسمی صحت تمام رفتار آن نیست.

## ۱. Launch

[splash_screen.dart:18](../lib/features/launch/presentation/splash/screens/splash_screen.dart:18) و [route_unavailable_screen.dart:8](../lib/features/launch/presentation/shared/widgets/route_unavailable_screen.dart:8) بررسی شدند. Splash فقط انتقال ثابت را بعد از frame اجرا می‌کند و guard احراز هویت در Router است؛ در این بازبینی آن را بدون شاهد به‌عنوان محاسبهٔ تجاری پنهان یا ضرورت افزودن Cubit تازه گزارش نکردم. مسیر unavailable هم adapter سادهٔ نمایش/navigation است.

## ۲. Auth

Provider مستقیم داخل AuthScreen است؛ State.initial ساده، اعتبارسنجی مرکزی از اولین رقم و تایمر متعلق به Cubit با close موجودند. متد listener چندحالته نام‌دار است. Key مرحله برای reset فرم دلیل رفتاری نزدیک کد دارد و با keyهای تزئینی Profile یکی تلقی نشده است.

### A01 — P3: ویجت‌های استخراج‌شده در فایل مسئولیت دیگر مانده‌اند

شاهد: [auth_screen.dart:165](../lib/features/auth/presentation/login/screens/auth_screen.dart:165)، [auth_identity_form.dart:54](../lib/features/auth/presentation/login/widgets/auth_identity_form.dart:54)، [auth_otp_form.dart:76](../lib/features/auth/presentation/login/widgets/auth_otp_form.dart:76).

AuthHeader داخل فایل صفحه، AuthCaptchaRow/AuthIdentityFields داخل فایل فرم و AuthOtpTimer داخل فایل OTP هستند. مطابق ۱۴.۳، widget عمومیِ استخراج‌شده باید فایل خودش را داشته باشد؛ این مورد مجوز ساخت wrapper برای فاصله و آیکون نیست.

اصلاح موردنیاز: جداسازی همان مسئولیت‌های واقعی، با حفظ subscription و API؛ بدون ریزکردن اجزای تزئینی.

### A02 — P3: اندازهٔ فونت در فیچر بازتعریف شده است

شاهد: [auth_identity_form.dart:228](../lib/features/auth/presentation/login/widgets/auth_identity_form.dart:228)، [auth_services_grid.dart:99](../lib/features/auth/presentation/login/widgets/auth_services_grid.dart:99).

fontSizeهای ۱۴ و ۱۰ داخل feature تعیین می‌شوند. بخش ۲۱.۳ مصرف نقش typography موجود را مقرر می‌کند.

اصلاح موردنیاز: استفاده از نقش/variant مصوب موجود؛ تغییر ظاهر یا ساخت token جدید بدون بررسی طراحی انجام نشود.

## ۳. Dashboard

HomeCubit از فیلد GetIt استفاده می‌کند؛ Router دیگر Provider Home نمی‌سازد. تب‌های کارت، سپرده و تسهیلات همان HomeCubit را می‌خوانند؛ loadهای مستقل status و generation جدا دارند. Reso برای منبع ui.Image و controller مالک UI دارد؛ ValueNotifier texture یک State تجاری موازی تشخیص داده نشد.

### D01 — P2: صفحه به wrapper ساخت Provider تبدیل شده است

شاهد: [dashboard_screen.dart:16](../lib/features/dashboard/presentation/home/screens/dashboard_screen.dart:16).

DashboardScreen یک build پیکانی دارد و تمام محتوای صفحه در DashboardBody کلاس دوم همان فایل قرار گرفته است. این نام عمومی، کارکرد wrapper صرفاً زیر Provider را تغییر نمی‌دهد؛ با ۹.۲، ۱۳.۱ و ۱۴.۳ ناسازگار است.

اصلاح موردنیاز: Provider و ترکیب اصلی UI در build بدنه‌دار خود صفحه باشند؛ استخراج فقط در مرز مسئولیت واقعی انجام شود، نه برای نگه‌داشتن ساختار تست.

### D02 — P2: تصمیم Back هنوز در UI است

شاهد: [dashboard_home_panel.dart:64](../lib/features/dashboard/presentation/home/widgets/dashboard_home_panel.dart:64).

onPopInvokedWithResult براساس selectedTab و draft تصمیم می‌گیرد selectTab یا cancelFavorites را صدا بزند. طبق ۳.۵ و ۲۰.۲، این تصمیم جریان متعلق به Cubit است.

اصلاح موردنیاز: یک اکشن Back در HomeCubit وضعیت را تفسیر کند؛ UI فقط رویداد و اثر آماده را اجرا کند.

### D03 — P2: چند اثر واقعی در صفحهٔ تولیدی بدون واکنش مصرف می‌شوند

شاهد: [dashboard_screen.dart:106](../lib/features/dashboard/presentation/home/screens/dashboard_screen.dart:106)، [home_cubit.dart:415](../lib/features/dashboard/presentation/home/cubit/home_cubit.dart:415)، [home_cubit.dart:796](../lib/features/dashboard/presentation/home/cubit/home_cubit.dart:796).

HomeProfileRequested، HomePromptSubmitted، HomeCardMoreRequested و HomeLoanDetailsRequested به break می‌رسند. برای Assistant/Tab/Selection مصرف‌کنندهٔ دیگری وجود دارد؛ این یافته آن رویدادها را شامل نمی‌شود. اما برای این چهار اثر در صفحهٔ تولیدی مقصد/پیام مشخصی دیده نشد. پس کلیک پروفایل/بیشتر کارت/جزئیات و ارسال prompt می‌تواند بی‌نتیجه بماند.

اصلاح موردنیاز: اثرهای واقعی به مصرف‌کنندهٔ مشخص متصل شوند؛ خدمت پیاده‌نشده پاسخ unavailable مصوب بدهد. callbackهای harness تست جای اجرای واقعی برنامه نیستند.

### D04 — P3: فونت‌های محلی داشبورد به‌جای نقش مصوب

شاهد: [dashboard_bank_services.dart:114](../lib/features/dashboard/presentation/shared/widgets/dashboard_bank_services.dart:114)، [dashboard_favorites_grid.dart:63](../lib/features/dashboard/presentation/shared/widgets/dashboard_favorites_grid.dart:63).

در بخش خدمات و علاقه‌مندی‌ها fontSize محلی ۱۰/۱۲ وجود دارد؛ نیازمند تطبیق با ۲۱.۳ است.

اصلاح موردنیاز: نقش typography مناسب از طراحی پروژه مصرف شود؛ اصلاح صرفاً مکانیکی که ظاهر را عوض کند پیشنهاد نمی‌شود.

## ۴. Cards

در شش Cubit اصلی وابستگی از GetIt گرفته می‌شود؛ سازنده‌ها State ورودی را حفظ می‌کنند. فیلتر داده و درخواست خدمت عمدتاً در Cubit هستند. در جریان رمز، تصمیم تأیید خروج و نتیجهٔ بسته‌شدن رسید در Cubit انجام شده و برخلاف G02 الگوی مناسب‌تری دارد. مرزهای Result/خطا و محافظ‌های generation/ارسال در مسیرهای اصلی موجودند؛ این ادعا حسابرسی امنیتی سرویس واقعی نیست.

### C01 — P2: فیلتر فهرست کارت هنوز در UI هماهنگ و بازسازی می‌شود

شاهد: [card_feature_sheets.dart:135](../lib/features/cards/presentation/card_features/widgets/card_feature_sheets.dart:135)، [card_feature_sheets.dart:181](../lib/features/cards/presentation/card_features/widgets/card_feature_sheets.dart:181)، [card_feature_sheets.dart:209](../lib/features/cards/presentation/card_features/widgets/card_feature_sheets.dart:209)، [card_feature_sheets.dart:234](../lib/features/cards/presentation/card_features/widgets/card_feature_sheets.dart:234).

لانچر beginFilter را اجرا و بعد از بسته‌شدن cancelFilter را تعیین می‌کند. callbackها CardFilter را با فیلد تازه و فیلد همسایه از snapshot UI بازسازی و all را به null تبدیل می‌کنند. با ۳.۵، ۱۳.۴ و ۱۶ ناسازگار است؛ صرفاً نمایش options نیست.

اصلاح موردنیاز: اکشن‌های فیلد مشخص و مدیریت draft/result در Cubit؛ لانچر فقط modal API و widget عمومی محتوا را اجرا کند. قالب بزرگ filter/action نیز از callback launcher به widget مسئول منتقل شود.

### C02 — P2: پنج اشتراک فرم در Cards فاقد buildWhen هستند

شاهد: [card_feature_sheets.dart:142](../lib/features/cards/presentation/card_features/widgets/card_feature_sheets.dart:142)، [card_issuance_screen.dart:116](../lib/features/cards/presentation/card_issuance/screens/card_issuance_screen.dart:116)، [change_card_deposit_screen.dart:56](../lib/features/cards/presentation/change_card_deposit/screens/change_card_deposit_screen.dart:56)، [expired_gift_balance_screen.dart:85](../lib/features/cards/presentation/expired_gift_balance/screens/expired_gift_balance_screen.dart:85)، [virtual_card_request_screen.dart:68](../lib/features/cards/presentation/virtual_card_request/screens/virtual_card_request_screen.dart:68).

این‌ها فرم‌ها/فهرست‌هایی با چند وضعیت یا دادهٔ قابل‌تغییرند. نبود buildWhen با ۱۱.۱ ناسازگار است. listenWhen در این موارد وجود دارد و مشکل با فقدان listener filter اشتباه گرفته نشده است.

اصلاح موردنیاز: مرز subscription منسجم و predicate پوشانندهٔ تمام فیلدهای مصرفی تعریف شود؛ builder جدا برای هر Text لازم نیست.

### C03 — P2: فیلتر footer رمز تمام داده‌های مصرفی را پوشش نمی‌دهد

شاهد: [password_flow_footer.dart:20](../lib/features/cards/presentation/password_services/widgets/password_flow_footer.dart:20)، [password_flow_footer.dart:30](../lib/features/cards/presentation/password_services/widgets/password_flow_footer.dart:30)، [password_flow_footer.dart:125](../lib/features/cards/presentation/password_services/widgets/password_flow_footer.dart:125).

builder از showFullStatus، isChange و formComplete می‌خواند ولی buildWhen آن‌ها را مقایسه نمی‌کند. تغییر بعضی فیلدهای دیگر ممکن است فعلاً rebuild را اتفاقی تأمین کند؛ این وابستگی ضمنی با ۱۱.۱ سازگار نیست.

اصلاح موردنیاز: تمام ورودی‌های واقعی این subtree در predicate یا مرز درستِ subscription پوشش داده شوند. این مورد گزارش قطعیِ خرابی بصری در اجرای حاضر نیست.

### C04 — P3: متن چندمرحله‌ای footer رمز در عبارت تودرتو تعیین می‌شود

شاهد: [password_flow_footer.dart:125](../lib/features/cards/presentation/password_services/widgets/password_flow_footer.dart:125).

label با چند شرط isChange/step/formComplete در آرگومان widget انتخاب می‌شود. طبق ۱۵ و ۲۲.۷، متن چندمرحله‌ای باید helper نمایشی نام‌دار String داشته باشد؛ تصمیم ادامهٔ واقعی در Cubit بماند.

اصلاح موردنیاز: فقط انتخاب ترجمه به helper نمایشی معنادار منتقل شود؛ eligibility یا مرحلهٔ بعد به UI اضافه نشود.

### C05 — P3: چند widget عمومی در فایل محتوای رمز جمع شده‌اند

شاهد: [password_flow_content.dart:90](../lib/features/cards/presentation/password_services/widgets/password_flow_content.dart:90).

PasswordFlowBody کنار PasswordFlowContent قرار گرفته است؛ نمونهٔ روشن دیگری از عدم رعایت الزام فایل مستقل برای widget استخراج‌شده در ۱۴.۳ است.

اصلاح موردنیاز: فقط مرزهای مسئولیتی موجود مستقل شوند؛ تعداد فایل، هدف مستقل بازآرایی نیست.

## ۵. Deposits

هر سه صفحهٔ اصلی Repository ورودی ندارند؛ Providerهای مستقیم و متدهای effect نام‌دار وجود دارند. درخواست گواهی و نتیجهٔ آدرس در Cubit ساخته/تفسیر می‌شوند. فرم آدرس مستقل، Cubit محلی و نتیجهٔ ذخیره از State دارد. شروط ثابت تمکن صریح نوشته شده‌اند.

### E01 — P2: Consumer اصلی معدل حساب buildWhen ندارد

شاهد: [average_balance_screen.dart:117](../lib/features/deposits/presentation/average_balance/screens/average_balance_screen.dart:117).

فرم چندمرحله‌ای و چندعملیاتی از State گسترده ساخته می‌شود، بدون buildWhen؛ مورد ششمِ یافتهٔ سراسری اشتراک‌هاست. FinancialCertificateScreen برخلاف این صفحه buildWhen دارد.

اصلاح موردنیاز: predicate کامل در مرز بخش‌های منسجم، مطابق ۱۱.۱.

### E02 — P3: اشتراک turnover در والد و فرزند تکرار شده است

شاهد: [average_balance_conditions.dart:19](../lib/features/deposits/presentation/average_balance/widgets/average_balance_conditions.dart:19)، [average_balance_turnover_field.dart:15](../lib/features/deposits/presentation/average_balance/widgets/average_balance_turnover_field.dart:15).

Conditions تغییر turnover را دنبال می‌کند و برای چیدمان هم می‌خواند؛ TurnoverField دوباره همان داده را subscribe می‌کند. این تکرار مشخص با قاعدهٔ مرز subscription در ۱۲ نیازمند اصلاح است.

اصلاح موردنیاز: مقدار انتخاب‌شده و callback روشن به فرزند داده شود یا مرز والد بازطراحی شود؛ بدون ایجاد State موازی.

### E03 — مانع انطباق: فیلد لاتین تمکن نسخهٔ مستقل کنترل پکیج است

شاهد: [financial_latin_address_field.dart:8](../lib/features/deposits/presentation/financial_certificate/widgets/financial_latin_address_field.dart:8)، [financial_latin_address_field.dart:45](../lib/features/deposits/presentation/financial_certificate/widgets/financial_latin_address_field.dart:45).

کنترل از TextField خام و style اختصاصی استفاده می‌کند. توضیح فایل نیاز ۹۰px را مطرح می‌کند؛ API فعلی AppTextArea حداقل ۱۳۰px و API محدودتری دارد. بنابراین صرف وجود TextField را بدون توجه به نبود variant هم‌ارز به‌عنوان خرابی ساده تلقی نکردم؛ اما این بخش نیز انطباق کامل با مسیر کامپوننت عمومی را ثابت نمی‌کند.

اصلاح موردنیاز: variant/API هم‌ارز طراحی مشخص شود و فقط در محدودهٔ مجاز بسته اصلاح شود. جایگزینی کور با AppTextArea که ظاهر را عوض کند یا معافیت خودسرانه از سند، راهکار تأییدشده نیست.

### E04 — P3: اندازهٔ فونت لاتین در فیچر تعیین شده است

شاهد: [financial_latin_identity.dart:59](../lib/features/deposits/presentation/financial_certificate/widgets/financial_latin_identity.dart:59)، [financial_latin_identity.dart:167](../lib/features/deposits/presentation/financial_certificate/widgets/financial_latin_identity.dart:167).

fontSize ثابت و شرطی در فیلدهای لاتین وجود دارد. نیاز طراحی واقعی باید با typography/variant مصوب حل شود؛ این یافته جدا از مالکیت درست محاسبات در Cubit است.

اصلاح موردنیاز: نقش یا variant متن لاتین بررسی شود؛ ثبت فونت/اندازهٔ تازه بدون task طراحی انجام نشود.

## ۶. Profile

Provider داخل NotificationsScreen است و State یک factory سادهٔ initial دارد؛ تقسیم read/unread بعد از اکشن‌ها و callback تغییر پیام‌ها وجود دارد. این نکات، تخلف constructor و openMessage را رفع نمی‌کنند.

### P01 — P2: سازندهٔ NotificationsCubit State مشتق‌شده می‌سازد

شاهد: [notifications_cubit.dart:10](../lib/features/profile/presentation/message_center/cubit/notifications_cubit.dart:10).

constructor در super لیست را کپی و read/unread را فیلتر می‌کند؛ initialState ورودیِ قابل‌حفظ هم ندارد. ممنوعیت ۶.۱.۱ فقط emit نیست؛ محاسبهٔ جایگزین State در super هم شامل آن است.

اصلاح موردنیاز: ساختار State.initial فعلی حفظ و بارگذاری/تقسیم پیام‌ها در اکشن اولیهٔ صریح Provider انجام شود.

### P02 — P2: خوانده‌شدن و payload پیام در UI تعیین می‌شود

شاهد: [notifications_screen.dart:25](../lib/features/profile/presentation/message_center/screens/notifications_screen.dart:25).

openMessage شرط !isRead را بررسی، markRead را اجرا و سپس message.markRead() را برای مسیر می‌سازد. طبق ۳.۵، تصمیم و دادهٔ نتیجه باید از Cubit بیاید.

اصلاح موردنیاز: اکشن openMessage(id) در Cubit دادهٔ معتبر و قصد نمایش جزئیات را آماده کند؛ UI فقط مسیر آماده را باز کند.

### P03 — P2: هویت پیام به متن ترجمه‌شده وابسته است

شاهد: [notification_message.dart:51](../lib/features/profile/domain/entities/notification_message.dart:51)، [notification_message.dart:57](../lib/features/profile/domain/entities/notification_message.dart:57).

id پیام‌های امنیتی از security-$date ساخته می‌شود و date از S.current آمده است. تغییر locale می‌تواند ID، lookup مسیر و تطبیق read-state را عوض کند. خود مدل Domain هم به ترجمه و asset برنامه وابسته شده است. با ۲۱.۴ و مرز Domain/UI ناسازگار است.

اصلاح موردنیاز: ID ثابت مستقل از نمایش؛ ترجمهٔ dateLabel و نمونه‌های نمایشی در مرز مناسب قرار بگیرند. مدل داده برای این کار به ViewModel عمومی تازه نیاز ندارد.

### P04 — P3: keyهای تستی و reset با Key در UI باقی مانده‌اند

شاهد: [notifications_screen.dart:39](../lib/features/profile/presentation/message_center/screens/notifications_screen.dart:39)، [notifications_screen.dart:51](../lib/features/profile/presentation/message_center/screens/notifications_screen.dart:51)، [notification_card.dart:30](../lib/features/profile/presentation/message_center/widgets/notification_card.dart:30)، [notification_detail_screen.dart:28](../lib/features/profile/presentation/message_center/screens/notification_detail_screen.dart:28).

Keyهای notifications_screen/read_all/notification_unread و مشابه برای ساختار نمایش استفاده شده‌اند؛ نیاز رفتاری مستند ندارند. ValueKey(messages) هم تعویض scope را با هویت لیست پنهان می‌کند؛ توضیح «ورودی عوض شود reset شود» قرارداد صریح action/lifetime را جایگزین نمی‌کند. §۱۸ و §۹.۴.

اصلاح موردنیاز: تست‌ها بر محتوا/ساختار عمومی تکیه کنند؛ تغییر واقعی inbox با ورودی/اکشن scope روشن شود. key واقعاً رفتاری تنها با نیاز مشخص حفظ شود.

### P05 — P3: رنگ hex و فونت محلی در جزئیات پیام

شاهد: [notification_detail_screen.dart:101](../lib/features/profile/presentation/message_center/screens/notification_detail_screen.dart:101)، [notification_card.dart:75](../lib/features/profile/presentation/message_center/widgets/notification_card.dart:75).

رنگ 0xfff6f2ee و اندازهٔ محلی ۱۰ در feature تعریف شده‌اند؛ با ۲۱.۳ نیاز به تطبیق دارند.

اصلاح موردنیاز: token رنگ و نقش متن مصوب مصرف شود؛ تغییر رنگ طراحی به انتخاب Agent انجام نشود.

## ۷. یافته‌های مشترک بین جریان‌ها

### G01 — P2: خروج از فرمِ دارای ورودی بدون تأیید دورریختن داده

بخش ۲۰.۲ برای مرحلهٔ اول فرمِ دارای دادهٔ قابل‌ازبین‌رفتن، تأیید خروج می‌خواهد. در جریان‌های زیر requestBack مستقیماً اثر back منتشر می‌کند یا پس از back()==false خارج می‌شود؛ شاخهٔ تأیید ورودی مشاهده نشد:

- [card_issuance_cubit.dart:93](../lib/features/cards/presentation/card_issuance/cubit/card_issuance_cubit.dart:93)
- [change_card_deposit_cubit.dart:32](../lib/features/cards/presentation/change_card_deposit/cubit/change_card_deposit_cubit.dart:32)
- [expired_gift_balance_cubit.dart:71](../lib/features/cards/presentation/expired_gift_balance/cubit/expired_gift_balance_cubit.dart:71)
- [virtual_card_cubit.dart:31](../lib/features/cards/presentation/virtual_card_request/cubit/virtual_card_cubit.dart:31)
- [average_balance_cubit.dart:90](../lib/features/deposits/presentation/average_balance/cubit/average_balance_cubit.dart:90)
- [financial_certificate_cubit.dart:93](../lib/features/deposits/presentation/financial_certificate/cubit/financial_certificate_cubit.dart:93)

اصلاح باید در Cubit و براساس dirty-state واقعی باشد؛ فرم خالی نیازمند دیالوگ تشریفاتی نیست. فیلتر staged با انصراف عادی هم طبق قرارداد خودش discard می‌شود و الزاماً همان قانون فرم بانکی را ندارد.

### G02 — P2: UI پس از رسید ادامهٔ Home را تعیین می‌کند

[virtual_card_request_screen.dart:40](../lib/features/cards/presentation/virtual_card_request/screens/virtual_card_request_screen.dart:40)، [average_balance_screen.dart:78](../lib/features/deposits/presentation/average_balance/screens/average_balance_screen.dart:78)، [financial_certificate_screen.dart:82](../lib/features/deposits/presentation/financial_certificate/screens/financial_certificate_screen.dart:82).

UI بعد از callback/بسته‌شدن dialog مستقیماً requestHome را صدا می‌زند. این ادامهٔ جریان باید با اکشن نتیجهٔ نمایش/بسته‌شدن رسید به Cubit بازگردد و خود Cubit دربارهٔ خروج تصمیم بگیرد (§۳.۵). این یافته به معنی انتقال showDialog یا BuildContext به Cubit نیست. مسیر رمز با recordPresentationClosed نمونهٔ مقایسه‌ای مناسب داخل پروژه است.

### ریسک نیازمند بررسی اجرایی مستقل: خروج از PopScope بسته

در درخواست مجازی و رمز، canPop:false است و اثر خروج به NavigationActions.back می‌رسد که در صورت canPop مسیر Router، pop اجرا می‌کند. §۲۰.۲ مسیر روشن خروج برای scope بسته می‌خواهد. در این بررسی ادعا نمی‌کنم روی همهٔ پلتفرم‌ها pop شکست می‌خورد؛ باید Back سیستم و دکمه، با استک واقعی، جدا بررسی شوند. این مورد با شکست تست‌های layout فعلی یکی نیست.

## ۸. اعتبارسنجی روی همین snapshot

### تحلیل استاتیک

`flutter analyze --no-pub lib/core lib/features test` موفق بود: **No issues found**. این فرمان همهٔ ویژگی‌ها و تست‌ها را پوشش می‌دهد، اما `lib/shared` را به‌عنوان target مستقل شامل نمی‌شود. موفقیت analyzer هیچ‌کدام از تخلف‌های قرارداد بالا را مجاز نمی‌کند.

### V01 — P1: تست کامل سبز نیست

`flutter test --no-pub --concurrency=2` پایان یافت: **۳۵۳ موفق، ۱۱ ناموفق، مجموع ۳۶۴ تست**؛ مدت ثبت‌شده ۱:۳۸.

همهٔ شکست‌ها در `test/dashboard/presentation/flows/home/screens/dashboard_review_test.dart` هستند. شواهد اصلی:

[dashboard_review_test.dart:101](../test/dashboard/presentation/flows/home/screens/dashboard_review_test.dart:101) هنوز با find.byType(DashboardScreen) دنبال context می‌گردد، درحالی‌که [home_tab_test_scope.dart:279](../test/dashboard/support/home_tab_test_scope.dart:279)، DashboardBody را mount می‌کند. چند تست با StateError: No element شکست می‌خورند. دو تست انتهایی نیز خطای invariant مربوط به debugDisableShadows دارند؛ آن را بدون اجرای جداگانه، باگ مستقل محصول نتیجه نمی‌گیرم. تغییر global در خط ۹۱ تست و مسیر restore باید در اصلاح fixture ایمن شود.

در این audit تست‌ها اصلاح یا بازنویسی نشدند؛ حفظ شکست فعلی به معنی پذیرفتن آن برای تحویل بعدی نیست. مشکل fixture باید همراه D01 و با حفظ مالکیت واقعی Provider حل شود؛ افزودن factory یا wrapper تولیدی فقط برای خوشایند تست با قرارداد سازگار نیست.

پیام‌های SVG دربارهٔ filter/foreignObject در log نیز وجود دارند؛ آن‌ها با assertionهای شکست‌خورده یکی نیستند.

## ۹. مواردی که نباید از این گزارش اشتباه نتیجه گرفته شوند

- ۱۵ State از نظر یک factory initial و نبود getter محاسباتی دست‌نویس بررسی شدند؛ ساختارشان برای تقلید نمونه بازنویسی نشود. P01 دربارهٔ constructor Cubit است، نه الزام تغییر State schema.
- در جست‌وجوی تولید، ثبت/دریافت Cubit از GetIt و پاس‌دادن Repository در سازندهٔ صفحه یا Cubit مشاهده نشد. UseCase → Repository injection در Domain تخلف این قانون نیست.
- setState برای flow state، callback بی‌نوع Function?/dynamic و متد private سازندهٔ Widget در featureهای فعلی در جست‌وجوی ساختاری پیدا نشدند. این نتیجه فقط همان الگوها را پوشش می‌دهد.
- post-frame لازم برای attachment اسکرول CardList، اندازه‌گیری TextPainter، منابع تصویر Reso و dispose controller، کار UI هستند؛ نباید برای حذف تابع UI به Cubit منتقل شوند.
- loop داده‌های واقعی و selector options ممنوعیت فرم ثابت آرایه‌ای نیستند. بازبودن تصمیم تطبیق enum با index نیز به‌تنهایی مجوز گزارش هر index به‌عنوان تخلف جدید نیست.
- کنترل فقط‌نمایش مثل جزئیات پیام، همهٔ خدمات ثابت یا unavailable لزوماً Cubit تازه لازم ندارد.
- اتصال‌های بانکی موجود عمدتاً mock هستند؛ نتیجهٔ تست UI اثبات اتصال واقعی بانک نیست و این audit task اتصال سرویس ایجاد نمی‌کند.

## ۱۰. ترتیب پیشنهادی اصلاح، همچنان فیچر به فیچر

1. Launch: رفتار موجود حفظ شود؛ تغییر تشریفاتی لازم نیست.
2. Auth: A01–A02 بدون تغییر رفتار اعتبارسنجی/OTP.
3. Dashboard: ابتدا D01 و fixture شکست‌خوردهٔ V01، سپس Back و مصرف effectها؛ هر سه تب و Reso دوباره بررسی شوند.
4. Cards: اول مالکیت filter، بعد subscriptionها و خروجِ داده‌دار؛ سپس footer و استایل. هر جریان شش‌گانه جدا اعتبارسنجی شود.
5. Deposits: معدل و تمکن جدا؛ receipt continuation و subscription اصلاح، محدودیت API لاتین به‌صورت مشخص حل شود.
6. Profile: constructor و اکشن openMessage، سپس ID پایدار، keyها و tokenهای نمایش.

این فهرست پیشنهاد ترتیب کار بعدی است و ادعای انجام اصلاحات نیست. اجرای این audit فقط این گزارش و پیوند فهرست گزارش‌ها را ایجاد/به‌روز کرده است.

</div>
