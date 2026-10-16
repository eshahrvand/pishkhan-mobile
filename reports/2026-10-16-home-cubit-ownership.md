<div dir="rtl" lang="fa" align="right">

# انتقال منطق Home به Cubit

تاریخ: ۲۰۲۶/۱۰/۱۶

طبق قرارداد [UI/Cubit/State](../doc/ui-cubit-state-agent-rules-en.md)، آماده‌سازی
داده و تصمیم‌های Home از UI جدا شد. تب‌های کارت، سپرده و تسهیلات بازنویسی نشدند.

- Cubit لیست خدمات، جست‌وجو و یکسان‌سازی نویسه‌ها، محدودیت دسته‌ها، گروه‌بندی،
  حذف گروه‌های خالی و امکان انتخاب گزینه‌ها را محاسبه می‌کند. UI مستقیماً
  `state.groups` را نمایش می‌دهد؛ انتخاب در اکشن Cubit نیز کنترل می‌شود.
- پیشنهادهای علاقه‌مندی‌ها داخل `DashboardCubit.edit()` از دادهٔ بارگذاری‌شده
  خوانده می‌شوند؛ UI دیگر پیشنهادها را از State به اکشن برنمی‌گرداند.
- متن دستیار و امکان ارسال در Freezed State قرار گرفت. پاک‌سازی فاصله‌ها و رد
  متن خالی داخل `DashboardResoCubit.submitPrompt()` انجام می‌شود. فیلد ورودی به
  State متصل است؛ callback میزبان در UI اجرا می‌شود.
- وابستگی Repository همچنان از ورودی صفحه تزریق می‌شود؛ خواندن داده و مدیریت
  پاسخ‌ها داخل Cubit/UseCase است. کنترل focus، انیمیشن، چیدمان و navigation در
  UI باقی مانده‌اند. متن جست‌وجوی محلی‌شده از Presentation تأمین می‌شود و Cubit
  مستقیماً به `S.current` دسترسی ندارد.
- تغییرات State در اکشن‌ها با `emit(state.copyWith(...))` صریح نوشته شده‌اند؛
  واسطهٔ ساخت یا انتشار State، getter محاسباتی و `setState` اضافه نشده است.

## اعتبارسنجی

- فایل‌های Freezed با `dart run build_runner build` تولید شدند.
- اجرای `flutter test --no-pub test/dashboard test/core/router/app_router_test.dart`:
  هر ۷۷ تست پاس شد؛ شامل جست‌وجو، انتخاب تکراری، collapse، علاقه‌مندی‌ها، ارسال
  متن، چرخه عمر، تعویض Repository و مسیریابی.
- اجرای `dart analyze --format machine lib/features/dashboard test/dashboard`:
  بدون خطا، هشدار یا پیام تحلیل.
- تست ارسال متن پس از ورود مقدار، یک فریم برای بازسازی وضعیت دکمه از State
  انتظار می‌کشد. اعتبارسنجی داخل Cubit باقی است.

لاگ‌های اجرایی در `build/home-cubit-tests.log` و `build/home-cubit-analyze.log`
قرار دارند. تست‌ها پیام‌های SVG مربوط به `filter`/`foreignObject` و هشدار
hit-test ارسال متن را چاپ می‌کنند؛ نتیجهٔ اجرای نهایی موفق است. هیچ اتصال
واقعی به سرویس بانکی یا وابستگی جدیدی اضافه نشده است.

</div>
