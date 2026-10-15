<div dir="rtl" lang="fa" align="right">

# حذف emit از سازندهٔ AuthCubit

تاریخ: ۲۰۲۶/۱۰/۱۵

## تغییر انجام‌شده

طبق درخواست صاحب پروژه، بلاک محاسبه و `emit` پس از `super(initialState)` از سازندهٔ [AuthCubit](../lib/features/auth/presentation/login/cubit/auth_cubit.dart) حذف شد. اکنون سازنده فقط State ورودی یا State پیش‌فرض را به Cubit می‌دهد:

<pre dir="ltr">AuthCubit({AuthState initialState = const AuthState.initial()})
  : super(initialState);</pre>

مقادیر پیش‌فرض Freezed هنگام ساخت `AuthState.initial()` اعمال می‌شوند. دیگر هیچ محاسبه یا انتشار State در بدنهٔ سازنده انجام نمی‌شود. اکشن‌های موجود همچنان مسئول تغییر مقدارها و محاسبات مرتبط با تعامل کاربر هستند.

## اثر روی State سفارشی و تست‌ها

اگر فراخواننده State سفارشی برای مرحله‌ای مانند OTP ارسال کند، باید مقادیر مرتبط مانند `isOtp`، `otpValid` و شمارهٔ ماسک‌شده را نیز صریح و سازگار بدهد. سازنده دیگر آن‌ها را از روی `step` یا ورودی‌ها بازنویسی نمی‌کند.

داده‌های اولیهٔ سناریوهای تست ورود کامل شدند تا مرحله، پرچم‌های نمایشی و اعتبار OTP را صریح مشخص کنند. سناریوی انقضا و ارسال مجدد OTP نیز از State اولیهٔ کامل مرحلهٔ تغییر شماره استفاده می‌کند. بررسی‌های رفتاری تست‌ها حفظ شدند.

## اعتبارسنجی

<pre dir="ltr">flutter test --no-pub test/auth/presentation/flows/login/screens</pre>

نتیجهٔ اجرای نهایی: هر ۱۵ تست پاس شدند.

<pre dir="ltr">flutter analyze --no-pub lib/features/auth/presentation/login/cubit/auth_cubit.dart test/auth/presentation/flows/login/screens/auth_screen_test.dart</pre>

نتیجه: بدون ایراد. تحلیل مربوط به دو فایل مشخص‌شده بود و analyze کل پروژه دوباره اجرا نشد.

## محدوده

تغییر پیاده‌سازی محدود به سازندهٔ `AuthCubit` است. داده‌های اولیهٔ تست مرتبط و فهرست گزارش‌ها نیز به‌روز شدند. این درخواست به سایر Cubitها تعمیم داده نشد.

</div>
