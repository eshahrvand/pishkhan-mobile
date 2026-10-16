<div dir="rtl" lang="fa" align="right">

# ثبت وابستگی‌های Home در GetIt

پکیج `get_it` اضافه شد. فایل `lib/core/di/injection_container.dart` ثبت مرکزی وابستگی‌های Home را انجام می‌دهد و `main` پیش از اجرای برنامه `configureDependencies` را فراخوانی می‌کند.

- رابط‌های `DashboardHomeRepository`، `DashboardCardsRepository`، `DashboardDepositsRepository` و `DashboardLoansRepository` همراه با `DashboardRepositories` به‌صورت lazy singleton ثبت می‌شوند. پیاده‌سازی‌ها همان mockهای موجود هستند.
- `HomeCubit` به‌صورت factory ثبت می‌شود. ثبت factory، repositoryها را از GetIt دریافت و از سازنده تزریق می‌کند؛ خود Cubit به GetIt وابسته نیست.
- route خانه از `getIt<HomeCubit>()` استفاده می‌کند. `BlocProvider` بارگذاری اولیه و بسته‌شدن Cubit هنگام خروج را مدیریت می‌کند. `RepositoryProvider` قبلی از ریشهٔ برنامه حذف شد.
- چهار تب Home همچنان State مشترک همان Cubit را نمایش می‌دهند. ثبت factory مانع اشتراک State بین دو بار ورود به خانه یا استفادهٔ مجدد از Cubit بسته‌شده می‌شود.
- ثبت مرکزی به محدودهٔ Home اعمال شده است؛ وابستگی‌های سرویس‌های مستقل دیگر در این تغییر بازنویسی نشده‌اند.

## بررسی

تست‌های DI از container مستقل استفاده می‌کنند و دریافت repository جایگزین، یکسان‌بودن نمونه‌های ثبت‌شده و مستقل‌بودن نمونه‌های Cubit را بررسی می‌کنند. تست route نیز بسته‌شدن Cubit بعد از خروج از حساب و ساخته‌شدن State تازه بعد از ورود مجدد را بررسی می‌کند.

- اجرای کامل `flutter test --no-pub`: هر ۳۵۴ تست موفق بود.
- تحلیل Dart فایل‌های DI، راه‌اندازی، router و تست‌های وابسته: بدون خطا و هشدار.
- بررسی `git diff --check`: موفق.

ثبت نسخه و شیوهٔ استفاده با [مستندات رسمی GetIt](https://pub.dev/packages/get_it) تطبیق داده شد.

</div>
