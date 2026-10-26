# دستور جلسهٔ Backend: Update Manager و Remote Config

**وضعیت:** پیش‌نویس برای توافق API؛ قرارداد فعلی بانک نیست  
**مخاطب:** تیم Backend، تیم Android/iOS و مالک محصول  
**هدف جلسه:** توافق روی ورودی‌ها، پاسخ، سیاست نسخه و رفتار اپ پیش از پیاده‌سازی

## ۱. مبنای فعلی پروژه

- پروژه Flutter است و از routeهای ثابت و کنترل‌شده در GoRouter استفاده می‌کند.
- نسخهٔ اپ، شمارهٔ build و پلتفرم باید از خود کلاینت خوانده شوند؛ نسخه را از تنظیمات یا پاسخ قبلی حدس نمی‌زنیم.
- Update screen می‌تواند یک Bottom Sheet برای انتخاب منبع نمایش دهد. Backend باید مشخص کند Update اجباری است یا اختیاری.
- Remote Config برای تنظیم رفتارهای قابل‌پیکربندی اپ است؛ محتوای صفحه‌ها و ترتیب سرویس‌ها مسئولیت Page Builder است.
- هیچ مقدار Remote Config نباید مجوز دسترسی به سرویس بانکی یا جایگزین بررسی مجوز در Backend باشد.

### واژه‌های این سند

- نسخهٔ اپ (`versionName`) نسخه‌ای است که برای کاربر نمایش داده می‌شود؛ برای مقایسهٔ ترتیب انتشار، مقدار عددی `buildNumber` مرجع است.
- کانال نصب (`channel`) محل توزیع نسخهٔ نصب‌شده است و با منبع انتخاب‌شده برای به‌روزرسانی (`source.id`) تفاوت دارد. برای مثال، ممکن است کاربر نسخه را از Bazaar نصب کرده باشد، اما هنگام Update منبع دیگری را انتخاب کند.
- نسخهٔ پشتیبانی‌شده حداقل `build` پشتیبانی‌شده‌ای است که Backend هنوز اجازهٔ استفاده از اپ را می‌دهد. این سیاست باید در APIهای عملیاتی هم enforce شود، نه فقط با بستن صفحه در اپ.

## ۲. Update Manager

### ۲.۱ جریان پیشنهادی

1. اپ در شروع یا زمان مناسب، `versionName` و `buildNumber` نصب‌شده را به API می‌فرستد.
2. Backend آخرین نسخهٔ قابل‌عرضه، حداقل نسخهٔ پشتیبانی‌شده، release notes و `sources` موجود را برمی‌گرداند.
3. اگر `buildNumber` نصب‌شده از حداقل مقدار پشتیبانی‌شده کمتر باشد، Update اجباری است؛ در غیر این صورت، اگر build جدیدی موجود باشد، Update اختیاری نمایش داده می‌شود.
4. Bottom Sheet، release notes و `sources` قابل انتخاب را نمایش می‌دهد: Bazaar، Myket و در صورت پشتیبانی، دانلود مستقیم.
5. کاربر منبع را انتخاب می‌کند. برای Store، اپ لینک/شناسهٔ معتبر همان Store را باز می‌کند. برای دانلود مستقیم، اپ artifact متناسب با پلتفرم و ABI دستگاه را می‌گیرد، اعتبارسنجی می‌کند و Android Package Installer را با تأیید کاربر باز می‌کند.

### ۲.۲ Endpoint پیشنهادی

```http
GET /mobile/v1/apps/{appId}/update-policy
    ?platform=android
    &versionName=5.4.0
    &buildNumber=50400
    &channel=direct
    &locale=fa-IR
    &supportedAbis=arm64-v8a,armeabi-v7a
```

نام مسیر و نسخهٔ API پیشنهادی است و باید با استاندارد فعلی بانک تطبیق داده شود.

| پارامتر | الزامی | منبع/معنا |
| --- | ---: | --- |
| `appId` | بله | شناسهٔ ثابت اپ؛ مثل `pishkhan-mobile` |
| `platform` | بله | `android` یا `ios` |
| `versionName` | بله | نسخهٔ قابل‌نمایش نصب‌شده |
| `buildNumber` | بله | عدد build نصب‌شده؛ مبنای مقایسه |
| `channel` | بله/ترجیحاً | کانال نصب/عرضه: `bazaar`, `myket`, `direct`, `app_store`, `test` |
| `locale` | بله | زبان فعلی اپ، مثل `fa-IR` |
| `supportedAbis` | Android | ABIهای پشتیبانی‌شدهٔ دستگاه، با اولویت |
| `osVersion` | اختیاری | نسخهٔ Android/iOS برای سازگاری |

**نکته:** شناسهٔ سخت‌افزاری، شماره تلفن، `session token` و مشخصات غیرضروری دستگاه برای تصمیم Update ارسال نشوند. اگر segmentation لازم است، کلیدهای حداقلی و هدف استفاده پیش از پیاده‌سازی تصویب شوند.

### ۲.۳ پاسخ پیشنهادی

```json
{
  "policyVersion": 1,
  "appId": "pishkhan-mobile",
  "platform": "android",
  "latest": {
    "versionName": "5.5.0",
    "buildNumber": 50500
  },
  "minimumSupportedBuild": 50200,
  "updateAvailable": true,
  "updateRequired": false,
  "releaseNotes": [
    { "locale": "fa-IR", "text": "بهبود امنیت و رفع چند مشکل." },
    { "locale": "en-US", "text": "Security improvements and fixes." }
  ],
  "sources": [
    {
      "id": "bazaar",
      "type": "store",
      "labelKey": "update.source.bazaar",
      "storeUrl": "https://cafebazaar.ir/app/{packageName}",
      "available": true
    },
    {
      "id": "myket",
      "type": "store",
      "labelKey": "update.source.myket",
      "storeUrl": "https://myket.ir/app/{packageName}",
      "available": true
    },
    {
      "id": "direct",
      "type": "direct",
      "available": true,
      "artifact": {
        "url": "https://download.example.invalid/signed-short-lived-url",
        "expiresAt": "2026-11-01T12:00:00Z",
        "fileName": "pishkhan-5.5.0-arm64-v8a.apk",
        "mimeType": "application/vnd.android.package-archive",
        "sizeBytes": 48392000,
        "sha256": "<server-provided-sha256>",
        "packageName": "<android-application-id>",
        "versionName": "5.5.0",
        "buildNumber": 50500,
        "abi": "arm64-v8a"
      }
    }
  ]
}
```

URLها و مقدار sha256 در این نمونه placeholder هستند و در پاسخ واقعی باید با مقادیر معتبر جایگزین شوند. اگر کلاینت build نصب‌شده از `minimumSupportedBuild` پایین‌تر باشد، `updateRequired` باید `true` شود. در غیر این صورت اپ قابل استفاده می‌ماند و انتخاب Update با کاربر است.

### ۲.۴ قرارداد فایل مستقیم و ایمنی نصب

- Backend باید artifact را برای همان `packageName` و با همان کلید signing اپ امضا کند؛ Android فقط زمانی Update را نصب می‌کند که امضای artifact با امضای اپ نصب‌شده سازگار باشد.
- URL دانلود بهتر است کوتاه‌عمر و HTTPS باشد. Token نشست یا اطلاعات کاربر داخل query string قرار نگیرد.
- در پاسخ، `sizeBytes`, `sha256`, `buildNumber`, `packageName`, `abi` و زمان انقضای URL بیاید.
- پیشنهاد شروع: یک APK universal برای ساده‌کردن نصب؛ اگر اندازه یا سیاست انتشار ایجاب کرد، انتخاب ABI در API و ارسال ABIهای مرتب‌شده انجام شود. نصب split APK فقط با توافق صریح و پشتیبانی کلاینت انجام شود.
- اپ باید اندازه و SHA-256 فایل را بررسی کند، package/version را کنترل کند و نصب را به Android Package Installer بسپارد. نصب بی‌صدا یا دورزدن تأیید سیستم در این قرارداد نیست.
- در iOS، مقصد باید Store مورد تأیید همان پلتفرم باشد؛ دانلود و نصب APK فقط برای Android است.
- خطای دانلود/انقضای URL باید امکان دریافت URL تازه را بدهد؛ پاسخ API نباید لینک منقضی‌شده را cache طولانی‌مدت کند.

### ۲.۵ رفتار UI مورد توافق

| وضعیت | رفتار پیشنهادی |
|---|---|
| Update موجود، اختیاری | Bottom Sheet قابل‌بستن با release notes و فقط `sources` با `available: true` |
| Update اجباری | screen یا Bottom Sheet غیرقابل‌بستن تا رسیدن به build پشتیبانی‌شده؛ CTAها فقط `sources` موجود |
| نسخهٔ به‌روز | هیچ پنجره‌ای نمایش داده نشود |
| API در دسترس نیست | اپ مانع استفادهٔ کاربر نشود، مگر اینکه policy اجباریِ ذخیره‌شده هنوز معتبر باشد؛ Product باید مدت اعتبار آن را تعیین کند |
| نسخه یا پلتفرم ناسازگار | پاسخ خطادار قابل‌تشخیص با کد خطای قراردادی، نه پاسخ مبهم یا crash |

این سیاست‌ها باید پیش از پیاده‌سازی نهایی شوند: رفتار Update اجباری هنگام قطع‌بودن API، فاصلهٔ نمایش دوبارهٔ Update اختیاری، امکان انتخاب «بعداً» و ذخیره‌شدن یا نشدن `source` انتخاب‌شده.

## ۳. Remote Config

### ۳.۱ مرز مسئولیت

Remote Config برای مقادیری مناسب است که نوع مشخص دارند و بدون انتشار نسخهٔ جدید قابل تغییرند؛ برای ساخت صفحه، ترتیب سرویس‌ها و تعریف مقصد استفاده نشود. این موارد در سند Page Builder هستند. هیچ مقدار config اجازهٔ ساخت route یا اجرای کد جدید نمی‌دهد.

### ۳.۲ Endpoint پیشنهادی

```http
GET /mobile/v1/apps/{appId}/config
    ?platform=android
    &versionName=5.4.0
    &buildNumber=50400
    &channel=bazaar
    &locale=fa-IR
If-None-Match: "config-2026-10-26-17"
```

### ۳.۳ پاسخ پیشنهادی

```json
{
  "schemaVersion": 1,
  "configVersion": "2026-10-26.17",
  "issuedAt": "2026-10-26T08:00:00Z",
  "expiresAt": "2026-10-27T08:00:00Z",
  "values": {
    "home.refreshIntervalSeconds": 300,
    "features.virtualCardRequest.enabled": true,
    "features.newLoanExperience.rolloutPercent": 10,
    "support.contact.enabled": true
  }
}
```

این JSON نمونه است. در قرارداد نهایی نوع هر کلید باید در schema مشخص باشد. پیشنهاد می‌شود به‌جای یک `Map<String, dynamic>` آزاد، مدل‌های type-safe یا یک envelope نسخه‌دار تعریف شود. مقدار `ETag` در header پاسخ HTTP قرار می‌گیرد، نه در body؛ اگر محتوا تغییر نکرده باشد، Backend باید `304 Not Modified` و body خالی برگرداند.

### ۳.۴ قواعد لازم

- برای هر کلید، نام دارای namespace، نوع داده، مقدار پیش‌فرض کلاینت، دامنهٔ مجاز، حداقل نسخهٔ پشتیبانی‌شده و مالک کلید ثبت شود.
- اپ ابتدا مقدارهای پیش‌فرض محلی را اعمال کند و سپس مقدارهای معتبر Remote Config را روی آن‌ها اعمال کند؛ config نامعتبر یا ناشناخته نباید باعث ازکارافتادن اپ شود.
- `ETag`/`If-None-Match` و پاسخ `304 Not Modified` برای کاهش ترافیک بررسی شود. زمان cache و رفتار آفلاین مشخص باشد.
- در ناسازگاری `schemaVersion`، نسخهٔ محلی استفاده شود و config ناسازگار اعمال نشود.
- Remote Config مرجع قطعی قابلیت‌های حساس، مجوز سرویس، سقف بانکی، مانده، قیمت یا کارمزد، و تصمیم احراز هویت نیست؛ Backend باید این موارد را هنگام هر درخواست عملیاتی دوباره بررسی کند.
- برای rollout درصدی از شناسهٔ مستعار و پایدار استفاده شود؛ اطلاعات شخصی خام نباید کلید تخصیص کاربر به bucket باشد. روش hash، ثبات تخصیص و زمان خارج‌کردن کاربر از rollout باید تعریف شود.
- config نباید شامل secret، access token، اطلاعات شخصی یا endpoint قابل‌تغییر برای دورزدن host allowlist باشد.
- رفتار kill switch باید مشخص باشد: خاموش‌کردن feature در UI چگونه دیده می‌شود و Backend با درخواست‌های در حال اجرا چه می‌کند.

## ۴. مواردی که باید پیش از پیاده‌سازی نهایی شوند

- OpenAPI یا نمونهٔ نهایی request/response برای هر دو سرویس.
- enumهای `platform`, `channel`, `source.type` و error codeها.
- قواعد نسخه، Update اجباری، Android `artifact`/`signature`/`checksum` و رفتار آفلاین.
- schema version، TTL، ETag، rollout و fallback برای Remote Config.
- owner هر فیلد و محیط‌های test/staging/production.

## ۵. نکات تکمیلی برای نهایی‌کردن قرارداد

### ۵.۱ تفکیک کانال نصب از منبع به‌روزرسانی

پارامتر channel در درخواست، محل توزیع نسخهٔ فعلی اپ است (برای نمونه bazaar یا myket). این پارامتر نمی‌گوید کاربر قرار است از کجا نسخهٔ بعدی را بگیرد؛ انتخاب کاربر از میان sources پاسخ انجام می‌شود و با source.id مشخص می‌شود. بنابراین این دو مقدار نباید یکی فرض شوند. اگر تشخیص کانال نصب در پلتفرم قابل اتکا نیست، باید روشن شود که این مقدار صرفاً اطلاعاتی است یا در تصمیم policy دخالت دارد.

### ۵.۲ قواعد سازگاری پاسخ Update

Backend باید نسخه‌ها را با `buildNumber` عددی مقایسه کند. `versionName` برای نمایش به کاربر و انتخاب `releaseNotes` است و نباید به‌تنهایی برای تشخیص جدیدتر بودن نسخه استفاده شود.

| وضعیت نسخهٔ نصب‌شده | updateAvailable | updateRequired | نتیجه |
|---|---:|---:|---|
| پایین‌تر از minimumSupportedBuild | true | true | Update اجباری است و دست‌کم یک source قابل استفاده باید ارائه شود. |
| برابر/بالاتر از minimumSupportedBuild و پایین‌تر از latest.buildNumber | true | false | Update اختیاری است. |
| برابر/بالاتر از latest.buildNumber | false | false | پنجرهٔ Update نمایش داده نمی‌شود. |

این جدول قاعدهٔ پیشنهادی است. Backend مسئول محاسبهٔ نهایی `policy` است و باید مقدارهای `updateAvailable` و `updateRequired` را با buildهای پاسخ سازگار برگرداند. ترکیب متناقض، مثل minimumSupportedBuild بزرگ‌تر از latest.buildNumber یا Update اجباری بدون source قابل دسترس، باید خطای Backend یا پیکربندی محسوب و پایش شود.

### ۵.۳ معنی source و release note

هر عضو `sources` گزینه‌ای است که اپ می‌تواند به کاربر نشان دهد. `id` شناسهٔ ثابت گزینه، `type` نوع رفتار (`store` یا `direct`) و `available` نشان می‌دهد که گزینه در این پاسخ قابل انتخاب است یا نه. عضو store باید مقصد کامل و قابل بازشدن برای همان اپ و همان پلتفرم داشته باشد. در JSON نمونه، الگوی {packageName} فقط placeholder است؛ قرارداد نهایی باید یا URL کامل بدهد یا الگوریتم جایگذاری packageName را تعریف کند. منبع direct فقط برای Android artifact نصب‌پذیر ارائه می‌کند؛ برای iOS مقصد Store لازم است.

`labelKey` فقط زمانی استفاده شود که ترجمهٔ آن در نسخهٔ نصب‌شدهٔ اپ وجود دارد. اگر نام یا متن منبع پویاست، پاسخ باید label چندزبانه بدهد. `releaseNotes` بر اساس `locale` درخواست انتخاب شوند. ترتیب جایگزین زبان باید ثابت باشد: ابتدا تطبیق کامل، سپس زبان پایه و در پایان زبان پیش‌فرض محصول.

برای artifact مستقیم، sha256 باید روی دقیقاً همان بایت‌های فایلی باشد که URL تحویل می‌دهد. sizeBytes حد اندازهٔ فایل است؛ اپ هر دو را قبل از درخواست نصب بررسی می‌کند. URL کوتاه‌عمر در پاسخ cache طولانی‌مدت نشود و در صورت انقضا، گرفتن URL تازه از همان policy یا endpoint توافق‌شده ممکن باشد.

### ۵.۴ قالب خطا و رفتار آفلاین

قالب مشترک خطا (کد پایدار، پیام قابل‌گزارش و requestId)، status codeها، rate limit و retry را تعیین کنید. دست‌کم خطای ورودی، `appId` یا `platform` ناشناخته، خطای موقت Backend و نبود `policy` باید کدهای جداگانه داشته باشند. متن خطا برای نمایش مستقیم به کاربر نیست؛ اپ متن محلی مناسب را انتخاب می‌کند.

اگر شبکه در دسترس نبود، پیشنهاد این است که اپ مانع استفادهٔ کاربر نشود؛ مگر اینکه policy اجباریِ ذخیره‌شده هنوز معتبر باشد و مدت اعتبار آن قبلاً توافق شده باشد. مدت اعتبار cache و این‌که policy اجباریِ ذخیره‌شده تا چه زمانی قابل اعمال است، تصمیم تیم محصول و Backend است و باید صریح ثبت شود.

### ۵.۵ قرارداد هر کلید Remote Config

برای هر کلید Remote Config، این موارد در `schema` نسخه‌گذاری‌شده ثبت شوند: نام، نوع JSON، مقدار پیش‌فرض اپ، بازه یا مقدارهای مجاز، حداقل نسخهٔ اپ، مالک کلید و توضیح کاربرد. برای مثال، `home.refreshIntervalSeconds` باید عدد صحیح با بازهٔ توافق‌شده باشد؛ مقدار متنی `"300"` به‌جای عدد `300` معتبر نیست.

پیشنهاد این است که `values` فقط مقدارهای فعال را override کند و برای کلیدهای غایب، اپ از مقدار پیش‌فرض همان نسخه استفاده کند. باید روشن باشد حذف override چگونه مقدار قبلی ذخیره‌شده در cache را پاک می‌کند؛ snapshot نسخه‌دار یا پاسخ کامل می‌تواند این ابهام را رفع کند. `ETag` در header پاسخ HTTP قرار می‌گیرد، نه در body. اگر config تغییر نکرده باشد، پاسخ `304 Not Modified` بدون body است.

برای rollout، پیشنهاد می‌شود Backend فعال‌بودن feature را برای کاربر واجد شرایط محاسبه کند و نتیجه را به‌صورت مقدار `boolean` برگرداند. اگر قرار است درصد خام به کلاینت داده شود، الگوریتم bucket، کلید pseudonymous، پایداری تخصیص و رفتار خروج از rollout باید جداگانه تعریف شود. Remote Config همچنان ابزار نمایش/رفتار کلاینت است و کنترل مجوز و اجرای عملیات بانکی در API اصلی Backend باقی می‌ماند.

## منابع داخلی پروژه

- [Dashboard development و ملاحظات اتصال سرویس/کاتالوگ](../dashboard/development.md)
- [معماری پروژه](../architecture-smart-virtual-counter-v2-en.md)
- routeهای اپ در `lib/core/router/app_routes.dart` و `lib/core/router/app_router.dart`
