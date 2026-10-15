<div dir="rtl" lang="fa" align="right">

# پیاده‌سازی router مرکزی و AppRoutes

## نتیجه

پس از تأیید شما، مسیریابی پروژه مطابق الگوی دو فایل مرکزی تغییر کرد:

- `lib/core/router/app_routes.dart`: یک کلاس `AppRoutes` برای تمام pathها و ساخت آدرسهای دارای query یا شناسه.
- `lib/core/router/app_router.dart`: تعریف مستقیم هر ۱۵ `GoRoute` داخل `GoRouter`، اتصال صفحه‌ها و خواندن ورودی مسیرها.

شش فایل route مربوط به featureها حذف شدند و توابع `buildAuthRoutes`، `buildCardsRoutes`، سایر factoryهای feature و `buildAppRoutes` دیگر در کد وجود ندارند.

## نام‌ها و قرارداد جدید

| مسیر | ثابت جدید |
| --- | --- |
| `/launch/splash` | `AppRoutes.splash` |
| `/dashboard/home` | `AppRoutes.home` |
| `/dashboard/services` | `AppRoutes.allServices` |
| `/auth/login` | `AppRoutes.login` |
| `/cards/password-services` | `AppRoutes.cardPasswords` |
| `/cards/list` | `AppRoutes.cardList` |
| `/cards/issuance` | `AppRoutes.cardIssuance` |
| `/cards/virtual-request` | `AppRoutes.virtualCardRequest` |
| `/cards/change-deposit` | `AppRoutes.changeCardDeposit` |
| `/cards/expired-gift-balance` | `AppRoutes.expiredGiftBalance` |
| `/deposits/list` | `AppRoutes.depositList` |
| `/deposits/average-balance` | `AppRoutes.averageBalance` |
| `/deposits/financial-certificate` | `AppRoutes.financialCertificate` |
| `/profile/messages` | `AppRoutes.messages` |
| `/profile/messages/:messageId` | `AppRoutes.messageDetail` |

آدرسهای قبلی حفظ شدند؛ تمام مصرف‌کنندگان کد و تست‌ها به ثابت‌های جدید تغییر کردند.

کلاس‌های ورودی مسیر مانند `CardRouteArguments` و `PasswordRouteArguments` در `app_router.dart` قرار گرفتند. helperهای `AppRoutes.cardListLocation` و `AppRoutes.messageDetailLocation` فقط ورودی رشته‌ای می‌گیرند و فایل pathها وابستگی به featureها ندارد.

## رفتار حفظ‌شده

`createAppRouter` همچنان نمونهٔ router را با session برنامه می‌سازد؛ `GoRoute`ها مستقیماً در همین فایل نوشته شده‌اند. باقی‌ماندن این تابع برای تزریق session، مسیر شروع و صفحهٔ جایگزین تست و برای مدیریت dispose است. فایل route جداگانه یا factory فهرست مسیر feature باقی نمانده است.

guard ورود، اعتبارسنجی مقصد `from`، انتقال `pendingExtra`، callback تکمیل ورود، خروج از حساب، صفحهٔ مسیر نامعتبر و رفتار بازگشت حفظ شدند. repository آزمایشی رمز کارت یک‌بار برای هر نمونهٔ router ساخته می‌شود تا رسیدها بین ورودهای مجدد باقی بمانند.

فراخوانی navigation از UI و بازکردن dialog و sheet در محل رویداد کاربر باقی است. منطق فرم‌ها و Cubitها تغییری نکرد. در اصلاح importها و مصرف pathها، قواعد مهارت `flutter-widget-ui-style` رعایت شد.

## مستندات

بخش ۱۵.۳ سند معماری با قرارداد جدید، مثال کد و دلیل تصمیم بازنویسی شد. بخش ساختار پوشه‌ها، توضیح تمرکز تغییرات، مثال flow و تاریخچهٔ تصمیم نیز هماهنگ شدند. راهنمای یکپارچه‌سازی و مستندات خدمات کارت، رمز کارت و فهرست سپرده به نام‌های جدید و router مرکزی ارجاع می‌دهند.

گزارش بررسی اولیهٔ همین موضوع به‌عنوان سابقهٔ تصمیم حفظ شد؛ این فایل نتیجهٔ اجرای تصمیم تأییدشده است.

## اعتبارسنجی

تحلیل ایستای `lib` و `test` بدون خطا بود؛ ۲۲ هشدار قبلی `UNUSED_ELEMENT` در ویجت‌های مشترک باقی است. به همین دلیل exit code ابزار تحلیل برابر ۲ است.

- اجرای `flutter test --no-pub --reporter expanded`: هر ۳۳۷ تست موفق شد؛ تست یکتایی و prefixها اکنون routeهای واقعی `router.configuration.routes` را می‌خواند. تست‌های ورود، حفظ مقصد و ورودی پس از ورود، مسیر نامعتبر، صفحه‌های خدمات کارت و سپرده و پیام‌ها هم پاس شدند.
- اجرای `dart analyze --format machine lib test`: بدون خطا و فقط همان ۲۲ هشدار قبلی.
- `git diff --check`: بدون ایراد فاصله‌گذاری.
- جست‌وجوی کد و تست‌ها: هیچ ارجاعی به کلاس‌های قدیمی path، factoryهای فهرست route یا import فایل‌های حذف‌شده باقی نمانده است.

لاگ تست‌ها در `build/centralized-router-tests.log` و خروجی تحلیل در `build/centralized-router-analyze.log` نگهداری می‌شوند.

</div>
