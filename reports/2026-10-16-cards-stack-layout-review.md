<div dir="rtl" lang="fa" align="right">

# بررسی Stack و Positioned در تمام فیچرهای کارت

هر ۱۲ مورد `Stack` در `lib/features/cards/presentation` بررسی شد. چهار مورد غیرضروری حذف شد و هشت مورد برای حفظ ظاهر، اسکرول، برش تصویر یا هم‌پوشانی واقعی باقی ماند. key دستی جدیدی اضافه نشده است.

## تغییرات

| محل | نتیجه |
| --- | --- |
| `password_services/screens/second_password_screen.dart` | Stack پس‌زمینه و Positioned.fill حذف شد؛ رنگ همان State مستقیماً به Scaffold داده می‌شود و محتوای صفحه با همان Column نمایش داده می‌شود. subscription تکراریِ پس‌زمینه نیز حذف شد. |
| `password_services/widgets/second_password_view.dart` | همان ساده‌سازی پس‌زمینه، با حفظ subscription رنگ و محتوای Column. |
| `card_features/widgets/card_features_ui.dart` | قاب تک‌آیکنِ کارت مجازی با SizedBox و Padding جایگزین شد؛ اندازه و مختصات آیکن ثابت ماند. |
| `virtual_card_request/widgets/virtual_card_content.dart` | قاب تک‌آیکنِ ردیف هزینه با Padding جایگزین شد؛ اندازه و مختصات ثابت ماند. |

## موارد حفظ‌شده

| محل | دلیل |
| --- | --- |
| `card_features/screens/card_features_screen.dart` | دستیار و دکمهٔ ثابت پایین روی محدودهٔ اسکرول هستند. Column ارتفاع viewport، مرکز حالت خالی و رفتار اسکرول را تغییر می‌دهد. این همان نمونهٔ معرفی‌شده توسط کاربر است و دلیل حفظ Stack کنار کد ثبت شد. |
| `card_issuance/screens/card_issuance_screen.dart` | دستیار و footer روی فرم قرار دارند؛ ارتفاع footer با مرحله و اندازهٔ متن تغییر می‌کند. حفظ مختصات و رفتار فعلی به این هم‌پوشانی نیاز دارد. |
| `card_features/widgets/card_feature_sheets.dart` | پنل sheet روی لایهٔ محو و ناحیهٔ لمسِ بستن sheet نمایش داده می‌شود. |
| `shared/card_service_sheet.dart` | همان هم‌پوشانی sheet و لایهٔ محو، با محدودیت safe area. |
| `password_services/widgets/password_sheets.dart` | همان هم‌پوشانی sheet و scrim، همراه با رفتار dismiss. |
| `password_services/widgets/password_instruction_section.dart` | قاب پوستر، تصویر را با ابعاد و جابه‌جایی مشخص برش می‌دهد؛ Row/Column معادل همان برش نیست. |
| `password_services/widgets/password_recording_section.dart` | تصویر، scrim و کنترل پخش روی یکدیگرند. |
| `expired_gift_balance/screens/expired_gift_balance_screen.dart` | نشان تعداد کارت‌های انتخاب‌شده روی آیکن قرار دارد و از قاب آیکن بیرون می‌زند. |

## اعتبارسنجی ظاهر و رفتار

- پیش از تغییر، تصاویر مرجع با تست‌های موجود ساخته شدند و بعد از تغییر همان حالت‌ها دوباره ثبت شدند.
- هر ۳۹ تصویر تازه در فهرست کارت‌ها، خدمات رمز و درخواست کارت مجازی، از نظر بایت‌های PNG و SHA-256 کاملاً یکسان بود؛ هیچ اختلاف تصویری ثبت نشد.
- تست‌های همین سه جریان: هر ۶۱ تست موفق بود. بررسی اندازه، مختصات، فرم‌ها، sheetها، زبان‌ها و رفتار بازگشتِ موجود حفظ شد.
- تحلیل Dart کارت‌ها و تست‌های وابسته بدون خطا و هشدار بود.
- اجرای کامل `flutter test --no-pub`: هر ۳۵۷ تست موفق بود. بررسی `git diff --check` نیز موفق بود.
- این تغییر ادعای عددی دربارهٔ افزایش سرعت ندارد؛ چیدمان‌ها و subscriptionهای غیرضروری حذف شده‌اند و ظاهرِ حالت‌های ثبت‌شده حفظ شده است.

خروجی‌های محلی اعتبارسنجی در `build/cards-layout-before`، `build/cards-layout-image-comparison.json` و logهای `build/cards-layout-*` هستند و وارد مخزن نمی‌شوند.

</div>
