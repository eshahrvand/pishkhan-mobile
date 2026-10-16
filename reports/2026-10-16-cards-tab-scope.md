<div dir="rtl" lang="fa" align="right">

# حذف ورودی‌های CardsTab

طبق درخواست صریح صاحب پروژه، سازندهٔ `CardsTab` اکنون فقط `super.key` دارد.
Repository و همهٔ callbackهای قبلی از این فایل حذف شده‌اند. Carousel کارت‌ها
نیز بدون callback ورودی ساخته می‌شود و اکشن‌های `CardsCubit` را فراخوانی می‌کند.

`DashboardScreen` مالک Provider مربوط به `CardsCubit` است. Repository در این
مرز تزریق می‌شود و تعویض آن، داده‌های همان Cubit را بازخوانی می‌کند. فهرست
عملیات، انتخاب کارت و ساخت payloadها داخل Cubit هستند. برای کپی، منو، تب،
دستیار و عملیات کارت، Cubit خروجی نوع‌دار در State قرار می‌دهد؛ BlocListener
والد اثر مربوط را اجرا می‌کند. `effectId` اجرای دوبارهٔ همان تعامل را پشتیبانی
می‌کند. callback، BuildContext و API کلیپ‌بورد وارد Cubit نشده‌اند.

تست‌های مستقل CardsTab به Provider/Listener جدید متصل شدند؛ تست‌های جدید نیز
تکرار عملیات، اعتبار payload کپی و اتصال callback والد را بررسی می‌کنند.

- `flutter test --no-pub test/dashboard test/core/router/app_router_test.dart`:
  هر ۸۱ تست پاس شد.
- فایل‌های Freezed با build_runner تولید شدند.
- لاگ تست‌ها: `build/cards-tab-scope-tests.log`.

</div>
