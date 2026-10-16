<div dir="rtl" lang="fa" align="right">

# یکپارچه‌سازی وضعیت چهار تب در Home

طبق درخواست صاحب پروژه، تب اصلی، کارت، سپرده و تسهیلات یک `HomeCubit` و یک
`HomeState.initial` سادهٔ Freezed در `presentation/home/cubit/` دارند. پنج جفت
Cubit/State قبلیِ Dashboard، Cards، Deposits، Loans و DashboardNavigation حذف
شدند؛ wrapper یا State تو‌در‌تو برای نگه‌داشتن ساختار قبلی ایجاد نشده است.

## مالکیت و رفتار

- `DashboardScreen` یک Provider مشترک می‌سازد و Repositoryهای چهار سطح را در
  مرز ترکیب برنامه تزریق می‌کند. سه تب بانکی فقط `super.key` دارند.
- Home بارگذاری، خطا، داده، انتخاب تب و آیتم‌ها، علاقه‌مندی‌ها، نمایش اطلاعات
  کارت و فهرست عملیات مجاز را مدیریت می‌کند. State محاسبه و getter دست‌نویس ندارد.
- عملیات مستقل، `homeStatus`، `cardsStatus`، `depositsStatus` و `loansStatus` و
  محافظ پاسخ قدیمی مستقل دارند. تکمیل یک درخواست، داده‌های تب دیگر را پاک نمی‌کند.
- تعویض Repository فقط همان دادهٔ تغییرکرده را بازخوانی می‌کند؛ انتخاب سایر
  تب‌ها و پیش‌نویس علاقه‌مندی‌ها حفظ می‌شود. انتخاب آیتم با ID پایدار تطبیق می‌یابد.
- اکشن‌ها تغییرات مرتبط را با `emit(state.copyWith(...))` صریح منتشر می‌کنند.
  UI مستقیماً فیلدهای State را می‌خواند و هر builder/listener فقط به فیلدهای
  مسئولیت خودش وابسته است.
- رویدادهای نوع‌دار `HomeEffect` کپی، navigation، جزئیات و callback میزبان را
  به listener والد می‌رسانند. منابع Flutter و اثرهای UI وارد Cubit نشده‌اند.

## اعتبارسنجی

- `flutter test --no-pub`: هر ۳۴۷ تست کل برنامه پاس شد.
- `dart analyze --format machine lib/features/dashboard test/dashboard`:
  بدون خطا، هشدار یا پیام تحلیل.
- تست‌های مهاجرت، بارگذاری هم‌زمان، استقلال خطاها، حفظ پیش‌نویس، تعویض یک
  Repository، پاسخ قدیمی، بسته‌شدن scope، مجوز عملیات، کپی و navigation را پوشش می‌دهند.
- `build_runner` فایل Freezed مشترک را تولید کرد؛ `git diff --check` ایرادی نداشت.

لاگ تست کامل در `build/unified-home-all-tests.log` و تحلیل در
`build/unified-home-analyze.log` است. مستند داشبورد و راهنماهای تب‌ها به‌روز شدند.

</div>
