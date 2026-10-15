<div dir="rtl" lang="fa" align="right">

# انتقال سرویس رمز کارت به feature کارت

## نتیجه

جریان تنظیم، تغییر و بازیابی رمز دوم کارت متعلق به `cards` است. پوشهٔ `lib/features/auth/presentation/password_services` به `lib/features/cards/presentation/password_services` منتقل شد. ورود و OTP ورود همچنان در `auth` قرار دارند.

## تغییرات

- صفحه، ویجت‌ها، Cubit، State و فایل تولیدشدهٔ Freezed همراه جریان منتقل شدند.
- مدل `password_data.dart`، قرارداد `password_services_repository.dart`، use caseهای `password_services.dart` و پیاده‌سازی `mock_password_repository.dart` به لایه‌های متناظر در `features/cards` منتقل شدند؛ این جریان دیگر از feature احراز هویت import ندارد.
- تعریف route و `PasswordRouteArguments` از `auth_routes.dart` به `cards_routes.dart` منتقل شدند. repository آزمایشی همچنان در طول عمر route factory مشترک است تا رسیدها بین ورودهای مجدد حفظ شوند.
- ثابت route اکنون `CardsRoutes.passwords` و آدرس آن `/cards/password-services` است. آدرس قبلی `/auth/password-services` دیگر ثبت نمی‌شود. همهٔ ورودی‌های داخلی سرویس و فهرست مسیرهای مجاز بازگشت پس از ورود اصلاح شدند.
- تست‌های جریان به `test/cards/presentation/flows/password_services` منتقل و importهای پشتیبان تست اصلاح شدند. تست مالکیت و یکتایی routeها به‌روز شد و مسیر رمز کارت در تست مقصد مجاز بازگشت قرار گرفت.
- سند `doc/cards/password-services.md`، راهنمای یکپارچه‌سازی و جدول مالکیت featureها در سند معماری اصلاح شدند.

رفتار فرم‌ها، اعتبارسنجی رمز، مراحل جریان و قرارداد repository تغییری نکرده است. این جابه‌جایی اتصال واقعی به سرویس بانکی اضافه نمی‌کند.

## اعتبارسنجی

- اجرای کامل `flutter test --no-pub --reporter expanded`: هر ۳۳۷ تست موفق شد؛ شامل تست‌های Cubit، صفحهٔ رمز کارت، ورودی‌های تنظیم و بازیابی، و مسیریابی.
- اجرای `dart analyze --format machine lib`: بدون خطای تحلیل؛ ۲۲ هشدار قبلی `UNUSED_ELEMENT` در ویجت‌های مشترک باقی است. به دلیل این هشدارها exit code ابزار برابر ۲ است.
- فرمان `flutter analyze --no-pub` بدون تولید خروجی متوقف مانده بود؛ فرایند متعلق به همین بررسی متوقف و تحلیل مستقیم Dart جایگزین آن شد.
- جست‌وجوی کد، تست‌ها و مستندات جاری: ارجاعی به محل قدیمی سرویس در `auth` یا آدرس route قبلی باقی نمانده است. گزارش‌های تاریخی پوشهٔ `reports` مطابق زمان نگارش خود حفظ شده‌اند.
- `git diff --check` بدون ایراد فاصله‌گذاری بود.

لاگ تست‌ها در `build/password-services-migration-all-tests.log` و خروجی تحلیل در `build/password-services-migration-dart-analyze.log` قرار دارند.

</div>
