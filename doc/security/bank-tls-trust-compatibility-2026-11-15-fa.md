# گزارش ناسازگاری زنجیرهٔ اعتماد TLS سرویس بانک با اندروید قدیمی

**مخاطب:** تیم امنیت، زیرساخت و مسئول گواهی‌های بانک  
**پروژه:** اپلیکیشن پیشخوان — `pishkhan_mobile`  
**تاریخ تدوین:** ۲۰۲۶-۱۱-۱۵  
**سرویس:** `https://apii.rqbank.ir/captcha`  
**وضعیت:** بازتولید اختلاف اعتماد با curl؛ تصمیم اصلاح و تأیید نهایی اپ هنوز انجام نشده است.

این سند بر پایهٔ خروجی تست‌هایی تهیه شده که توسعه‌دهنده در Termux روی شبیه‌ساز ارائه کرده است. نتایج نقل‌شده، اسکن مستقل همهٔ زیرساخت بانک یا آزمایش تمام نسخه‌های اندروید نیستند. برای تهیهٔ این سند، کد شبکه و تنظیمات گواهی اپ تغییر نکرده است.

## ۱. موضوع قابل طرح در جلسه

در یک محیط یکسان، درخواست کپچا با مخزن CA پیش‌فرض Termux موفق می‌شود، ولی با مجموعهٔ CA استخراج‌شده از اندروید ۱۲ همان شبیه‌ساز شکست می‌خورد. خطا هنگام ساخت و اعتبارسنجی زنجیرهٔ اعتماد رخ می‌دهد؛ قبل از ارسال درخواست HTTP.

ریشهٔ مسیر موفق، `Certum Trusted Root CA` است. جست‌وجوی نام دقیق این ریشه در مجموعهٔ استخراج‌شدهٔ اندروید، نتیجه‌ای نداشته است. شواهد با نبودن ریشهٔ جدید در این ایمیج قدیمی سازگارند. مسئلهٔ قابل اقدام، سازگاری مسیر اعتماد ارائه‌شده با دستگاه‌های پشتیبانی‌شده است؛ نه تولید گواهی self-signed جدید یا حذف اعتبارسنجی TLS.

**درخواست اصلی از بانک:** بررسی و ارائهٔ زنجیرهٔ سازگار و مورد تأیید Certum برای کلاینت‌های قدیمی، شامل امکان نصب cross-certificate رسمی در نقطهٔ خاتمهٔ TLS، و اعلام سیاست پشتیبانی/تعویض گواهی.

## ۲. محیط و محدودهٔ شواهد

| مورد | مقدار مشاهده‌شده / وضعیت |
| --- | --- |
| دستگاه آزمایش مستقیم | شبیه‌ساز `emulator-5554`، اندروید **۱۲**، معماری `x86_64` |
| ابزار داخل اندروید | Termux، curl نسخهٔ `8.12.1` و OpenSSL؛ نسخهٔ دقیق OpenSSL ثبت نشده است |
| دامنه و SNI | `apii.rqbank.ir` |
| IP مشاهده‌شده | `5.160.154.95`؛ مختص این تست و قابل تغییر |
| درخواست | `GET /captcha`، بدون نیاز به توکن ورود |
| TLS موفق | `TLSv1.2`، رمز `ECDHE-RSA-AES128-GCM-SHA256` |
| مخزن موفق | `$PREFIX/etc/tls/cert.pem` در Termux |
| مخزن ناموفق | تجمیع `/system/etc/security/cacerts/*` همان شبیه‌ساز |
| اندروید ۱۴ و بالاتر | موفقیت طبق گزارش توسعه‌دهنده؛ لاگ مقایسه‌ای و موجودی CA آن دستگاه‌ها در این بررسی ثبت نشده است |
| اندروید ۱۳ | تست مستقیم مجزا در شواهد این سند موجود نیست |
| خود اپ Flutter | خطای خام همان اجرای ناموفق هنوز در این مجموعهٔ شواهد ثبت نشده است |

نکته: اجرای curl در Termux معادل اجرای پشتهٔ TLS خود Flutter نیست. تست دوم، curl/OpenSSL را با CAهای سیستم تغذیه کرده است؛ این کار موجودی اعتماد را کنترل می‌کند، ولی الگوریتم اعتبارسنجی Android TrustManager یا Dart را عیناً شبیه‌سازی نمی‌کند.

## ۳. شماتیک زنجیره و محل شکست

### زنجیرهٔ مشاهده‌شده

پیکان‌ها در شکل زیر به معنی «صادر شده توسط» هستند:

```text
Server certificate / Leaf
  Subject: *.rqbank.ir
  SAN: *.rqbank.ir, rqbank.ir
          |
          | issued by
          v
Intermediate CA
  Certum DV TLS G2 R39 CA
          |
          | issued by
          v
Root trust anchor
  Certum Trusted Root CA
```

خروجی `s_client -showcerts` نشان می‌دهد سرور در این اتصال دو گواهی می‌فرستد: گواهی دامنه و گواهی میانی. ریشه در خروجی بخش verification از مخزن اعتماد Termux پیدا شده است. **ارسال‌نشدن ریشه توسط سرور، به‌خودی‌خود نقص پیکربندی نیست؛ ارسال ریشه نیز به‌تنهایی آن را در کلاینت معتبر نمی‌کند.**

### مقایسهٔ دو مسیر

```text
Same emulator / Same host / Certificate verification enabled
                         |
              DNS resolution: successful
                         |
              TCP connection: successful
                         |
              TLS server certificate received
                         |
              Build and validate trust path
                  /                    \
                 /                      \
       Termux CA bundle          Android 12 CA bundle
       Trusted path found        Trusted path not found
                 |                      |
       TLS handshake succeeds    TLS verification fails
                 |                      |
       GET /captcha is sent      No HTTP request is sent
                 |                      |
       HTTP 200                  curl error 60
```

## ۴. شواهد ثبت‌شده

### آزمون A — مخزن پیش‌فرض Termux: موفق

```text
CAfile: /data/data/com.termux/files/usr/etc/tls/cert.pem
subject: CN=*.rqbank.ir
subjectAltName: host "apii.rqbank.ir" matched cert's "*.rqbank.ir"
issuer: C=PL; O=Asseco Data Systems S.A.; CN=Certum DV TLS G2 R39 CA
SSL certificate verify ok.
SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256
HTTP/1.1 200
```

این تست علاوه بر اعتماد، تطابق نام دامنه را نیز تأیید کرده است. پیشنهاد TLS 1.3 در ClientHello و انتخاب TLS 1.2 در ادامه، در این تست مانع اتصال نبوده است.

### آزمون B — CAهای اندروید ۱۲: ناموفق

```text
CAfile: /data/data/com.termux/files/usr/tmp/android-ca.pem
CApath: /data/data/com.termux/files/usr/tmp/empty-ca
TLSv1.2 (IN), TLS handshake, Certificate (11)
TLSv1.2 (OUT), TLS alert, unknown CA (560)
SSL certificate problem: unable to get local issuer certificate
curl: (60) SSL certificate problem: unable to get local issuer certificate
```

تفاوت کنترل‌شده، فایل/دایرکتوری CA مصرفی curl بوده است. این نتیجه نشان‌دهندهٔ شکست اعتبارسنجی با مجموعهٔ استخراج‌شده است، نه خطای کپچا، OTP، CORS یا پاسخ HTTP بانک.

### آزمون C — نمایش مسیر موفق با OpenSSL

```text
depth=2 ... CN=Certum Trusted Root CA
verify return:1
depth=1 ... CN=Certum DV TLS G2 R39 CA
verify return:1
depth=0 CN=*.rqbank.ir
verify return:1
Verification: OK
Verify return code: 0 (ok)
```

فرمان اصلی این آزمون `-servername` داشت، ولی `-verify_hostname` نداشت؛ بنابراین به‌تنهایی شاهد تطابق hostname محسوب نمی‌شود. شاهد تطابق hostname، آزمون curl در بخش A است. نسخهٔ تکمیلی فرمان در بخش ۹، hostname را نیز صریحاً بررسی می‌کند.

### آزمون D — جست‌وجوی نام ریشه در مجموعهٔ اندروید

```sh
openssl crl2pkcs7 -nocrl -certfile "$TMPDIR/android-ca.pem" | openssl pkcs7 -print_certs -noout | grep -F 'Certum Trusted Root CA'
```

خروجی گزارش‌شده خالی است؛ خطای parsing گزارش نشده است. این شاهد، نبودن گواهی با این نام در مجموعهٔ استخراج‌شده را نشان می‌دهد. برای تطبیق هویت رمزنگاری گواهی، fingerprint باید بررسی شود؛ صرف نام Subject جایگزین fingerprint نیست.

## ۵. هویت گواهی‌ها

| نقش | Subject / CN | Issuer | بازهٔ اعتبار مشاهده‌شده |
| --- | --- | --- | --- |
| دامنه | `*.rqbank.ir` | `Certum DV TLS G2 R39 CA` | از `2026-10-19 14:49:32 UTC` تا `2027-05-06 14:49:31 UTC` |
| میانی | `Certum DV TLS G2 R39 CA` | `Certum Trusted Root CA` | از `2024-06-18 07:41:22 UTC` تا `2039-06-05 07:41:22 UTC` |
| ریشهٔ مسیر موفق | `Certum Trusted Root CA` | ریشهٔ رسمی Certum؛ فایل مستقل در تست ارائه نشده است | باید با فایل رسمی و سیاست جاری بانک تطبیق داده شود |

Fingerprintهای SHA-256 زیر از [مخزن رسمی Certum](https://www.certum.eu/en/cert_expertise_root_certificates/) هنگام تدوین سند استخراج شده‌اند؛ fingerprint فایل ریشهٔ داخل Termux هنوز مستقلاً محاسبه و با آن تطبیق داده نشده است:

```text
Certum Trusted Root CA — Root, Generation G2
FE7696573855773E37A95E7AD4D9CC96C30157C15D31765BA9B15704E1AE78FD

Certum DV TLS G2 R39 CA — Intermediate
83C0A5A76844C840DFAF820FFD02ADF6573A26823EF6AF758A3384A0AC044083
```

اعتبار زمانی خود گواهی، لزوماً معادل مدت اعتماد همهٔ سیستم‌عامل‌ها و برنامه‌های ریشه نیست؛ تیم امنیت باید سیاست جاری صادرکننده و برنامه‌های اعتماد را نیز بررسی کند.

## ۶. چرا تفاوت با اندروید ۱۴ محتمل است؟

[اطلاعیهٔ رسمی Certum دربارهٔ ریشه‌های جدید](https://support.certum.eu/en/technical-news/certum-implements-new-root-cas/) توضیح می‌دهد که ریشهٔ جدید روی اندروید ۱۴ و بالاتر پشتیبانی می‌شود، ولی ممکن است در نسخه‌های قدیمیِ بدون به‌روزرسانی مخزن گواهی موجود نباشد. این توضیح با شواهد ما سازگار است.

همچنین [مستند AOSP دربارهٔ Conscrypt](https://source.android.com/docs/core/ota/modular-system/conscrypt) مخزن ریشهٔ قابل‌به‌روزرسانی از اندروید ۱۴ را شرح می‌دهد. این توضیح زمینهٔ تفاوت نسخه‌هاست؛ اثبات نمی‌کند که Dio در Flutter دقیقاً از همان مسیر Java/Conscrypt استفاده می‌کند.

پس باید دو گزاره را جدا نگه داشت:

- **مشاهده‌شده:** مسیر فعلی با CAهای این شبیه‌ساز اندروید ۱۲ تأیید نمی‌شود و ریشهٔ نام‌برده در آن مجموعه دیده نشده است.
- **نیازمند تست تکمیلی:** همین علت، توضیح قطعی خطای هر دستگاه اندروید ۱۳ و پایین‌تر و موفقیت همهٔ دستگاه‌های اندروید ۱۴ و بالاتر باشد.

## ۷. گزینه‌های اصلاح برای تصمیم بانک

### گزینهٔ اول — زنجیرهٔ سازگار در سمت سرور

پیشنهاد اولیه، بررسی cross-certificate رسمی Certum در نقطهٔ خاتمهٔ TLS است. Certum در [راهنمای رسمی مهاجرت](https://support.certum.eu/en/technical-news/certum-implements-new-root-cas/) این روش را برای محیط‌های قدیمی معرفی کرده و نصب آن را وظیفهٔ مدیر سرور می‌داند:

[Cross-certificate رسمی مرتبط با Certum Trusted Root CA](https://repository.certum.pl/ctnca-ctrca.pem)

```text
Proposed alternate path — validate before deployment

*.rqbank.ir
    |
Certum DV TLS G2 R39 CA
    |
Certum Trusted Root CA — official cross-signed certificate
    |
Older trusted Certum root
    |
Trust anchor already present on target legacy devices
```

این شکل، طرح مسیر جایگزین است؛ نتیجهٔ استقرار یا تست انجام‌شده نیست. بانک باید issuer، امضا، fingerprint، بازهٔ اعتبار، محدودیت‌ها و سیاست اعتماد cross-certificate را با Certum تأیید کند. گواهی cross-signed با فایل ریشهٔ self-signed یک فایل یکسان نیست؛ Subject مشترک کافی نیست.

نام دقیق ریشهٔ مقصد باید از فایل رسمی cross-certificate تأیید و موجودی آن در دستگاه‌های هدف بررسی شود. مسیر قدیمی نیز محدودیت زمانی و سیاستی دارد و نباید راهکار دائمیِ بدون برنامهٔ مهاجرت فرض شود.

اقدام‌ها: بررسی پیکربندی virtual host/SNI، ترتیب chain، همهٔ گره‌های ارائه‌دهندهٔ TLS و سازگاری مسیر جدید با کلاینت‌های قدیمی و جدید. صرف افزودن فایل ریشهٔ self-signed به chain سرور، جای cross-certificate مناسب را نمی‌گیرد.

### گزینهٔ دوم — افزودن CA رسمی به اتصال بانک در اپ

اگر اصلاح سمت سرور ممکن یا کافی نباشد، با تصویب امنیت بانک می‌توان گواهی عمومی CA رسمی را در تنظیمات اتصال بانک به‌عنوان trust anchor افزود. [Dart SecurityContext](https://api.dart.dev/dart-io/SecurityContext/setTrustedCertificates.html) امکان افزودن CA مورد اعتماد را دارد؛ این سند نسخهٔ اجرایی یا تغییر کد را تجویز نمی‌کند.

شرایط تصمیم و پیاده‌سازی:

- دریافت از منبع رسمی و تطبیق fingerprint از مسیر مورد تأیید بانک.
- محدودکردن استفاده به کلاینت و مقصد بانکی؛ تغییرنکردن اعتماد سراسری سایر ارتباطات اپ.
- تعیین صریح اعتمادهای پیش‌فرض مجاز، رفتار redirect و دامنهٔ اثر CA؛ افزودن CA معادل محدودکردن اعتماد به یک hostname نیست.
- حفظ بررسی نام دامنه، اعتبار زمانی، زنجیره و امضا؛ بدون callback پذیرش همهٔ گواهی‌ها.
- تعیین مالک چرخهٔ عمر، تعویض، حذف اعتماد، پاسخ به compromise و نسخه‌های اپِ باقی‌مانده در دستگاه کاربران.
- ثبت فقط گواهی عمومی؛ کلید خصوصی سرور یا CA وارد اپ نمی‌شود.
- آزمون با نسخهٔ واقعی Flutter/Dart و آداپتور Dio پروژه؛ اتکا به XML اندروید بدون اثبات اثر آن بر مسیر Dart کافی نیست.

**تفکیک مهم:** افزودن CA به trust store با SPKI pinning یا pin کردن گواهی دامنه یکسان نیست. سیاست pinning فعلی/پشتیبان و تعویض آن موضوع مستقلِ تصمیم بانک است؛ این اصلاح نباید به‌صورت ضمنی آن سیاست را تغییر دهد.

### گزینهٔ سوم — تغییر زنجیره یا گواهی با توافق صادرکننده

اگر مسیر جایگزین مناسب نباشد، بانک با صادرکننده دربارهٔ گواهی/زنجیرهٔ سازگار با ماتریس پشتیبانی تصمیم بگیرد. گزینه باید هم با کلاینت قدیمی و هم با سیاست اعتماد جدید سازگار باشد؛ برگشت ساده به ریشهٔ قدیمی بدون بررسی دورهٔ حذف اعتماد کافی نیست.

### اقدام‌هایی که این تشخیص توجیه نمی‌کند

- `badCertificateCallback => true`، trust-all یا حذف اعتبارسنجی در نسخهٔ عملیاتی.
- استفاده از HTTP به‌جای HTTPS.
- ساخت گواهی self-signed دلخواه در تیم اپ برای معتبرکردن سرور فعلی.
- نصب دستی CA توسط عموم کاربران به‌عنوان راهکار انتشار اپ.
- اعتماد به فایل گواهی صرفاً به دلیل دریافت‌شدن از اتصال نامعتبر.

## ۸. درخواست‌های مشخص از تیم امنیت و زیرساخت

1. تأیید chain فعلی و SHA-256 گواهی دامنه، میانی، ریشه و cross-certificate مورد تأیید.
2. بررسی امکان ارائهٔ مسیر cross-signed رسمی و اعلام گره/لایهٔ مسئول تغییر: reverse proxy، gateway، WAF، load balancer یا سرویس نهایی؛ معماری دقیق از این لاگ‌ها قابل تعیین نیست.
3. اعلام حداقل اندروید پشتیبانی‌شده و سیاست دستگاه‌های بدون به‌روزرسانی CA.
4. تأیید یکسان‌بودن chain در همهٔ مقصدهای DNS/گره‌ها و با SNI صحیح، از شبکهٔ مجاز تست.
5. انتخاب اصلاح سمت سرور یا CA اختصاصی کلاینت اپ، همراه مالک اجرا، زمان‌بندی و rollback.
6. اعلام سیاست تمدید، تعویض و حذف اعتماد و، در صورت الزام، SPKI pinهای جاری/پشتیبان؛ fingerprint گواهی با SPKI pin اشتباه نشود.
7. هماهنگی لاگ خام Flutter روی دستگاه مشکل‌دار برای تطبیق علت خطای اپ با شواهد curl.

## ۹. دستورهای بازتولید

تمام فرمان‌های این بخش داخل **Termux** اجرا می‌شوند. `-k` یا `--insecure` استفاده نشده است. فرمان‌ها هیچ توکن ورود، OTP یا اطلاعات مشتری نیاز ندارند؛ درخواست GET فقط کپچای جدید می‌گیرد.

### ثبت مشخصات محیط

```sh
getprop ro.build.version.release
getprop ro.build.version.sdk
getprop ro.product.cpu.abi
getprop ro.build.fingerprint
getprop ro.build.version.security_patch
date -u
curl --version
openssl version -a
```

برای گزارش تکرارپذیر، تنظیمات شبکه، VPN/proxy، نسخهٔ Termux و نسخهٔ اپ نیز ثبت شوند؛ اطلاعات هویتی یا شناسهٔ شخصی دستگاه لازم نیست.

### آزمون A — مخزن پیش‌فرض Termux

```sh
curl -v --connect-timeout 15 --max-time 30 -o /dev/null https://apii.rqbank.ir/captcha
```

### استخراج CAهای اندروید قدیمی و آزمون B

فرمان استخراج زیر برای **اندروید ۱۲ مورد آزمایش** است. در اندروید ۱۴ و بالاتر، مسیر APEX و مجموعهٔ مؤثر اعتماد باید جداگانه بررسی شود؛ این مسیر نسخهٔ عمومیِ همهٔ دستگاه‌ها نیست.

```sh
cat /system/etc/security/cacerts/* > "$TMPDIR/android-ca.pem"
mkdir -p "$TMPDIR/empty-ca"
curl -v --connect-timeout 15 --max-time 30 --cacert "$TMPDIR/android-ca.pem" --capath "$TMPDIR/empty-ca" -o /dev/null https://apii.rqbank.ir/captcha
```

فایل bundle نباید خالی باشد و خطای خواندن/تجزیهٔ گواهی نباید نادیده گرفته شود. نسخهٔ curl، backend TLS و مسیر CA چاپ‌شده در خروجی نیز ثبت شوند.

### نمایش زنجیرهٔ سرور — آزمون تکمیلی C

```sh
openssl s_client -connect apii.rqbank.ir:443 -servername apii.rqbank.ir -verify_hostname apii.rqbank.ir -CAfile "$PREFIX/etc/tls/cert.pem" -verify_return_error -showcerts </dev/null
```

افزودهٔ `-verify_hostname` نسبت به تست اولیه برای بررسی صریح نام دامنه است. در صورت معطل‌شدن فرمان، با `Ctrl+C` متوقف شود.

### جست‌وجوی نام ریشه — آزمون D

```sh
openssl crl2pkcs7 -nocrl -certfile "$TMPDIR/android-ca.pem" | openssl pkcs7 -print_certs -noout | grep -F 'Certum Trusted Root CA'
```

### تطبیق fingerprint فایل دریافتی از بانک

`bank-approved-root.pem` نام نمونهٔ فایل عمومی دریافتی از کانال تأییدشده است؛ این فایل هنوز در پروژه اضافه نشده است.

```sh
openssl x509 -in bank-approved-root.pem -noout -subject -issuer -dates -fingerprint -sha256
```

## ۱۰. معیار پذیرش و بستن مسئله

| کنترل | معیار پذیرش | وضعیت فعلی |
| --- | --- | --- |
| اصالت گواهی | فایل‌ها و fingerprintها از کانال معتبر تأیید شوند | نیازمند تأیید بانک |
| Android 12 فعلی | اعتبارسنجی روشن، handshake موفق و پاسخ کپچا | با bundle سیستم شکست؛ پس از اصلاح باید تکرار شود |
| سایر نسخه‌های هدف | ماتریس مصوب بانک، شامل ۱۳ و ۱۴ و نسخه‌های منتخب قدیمی/جدید | آزمون مستند تکمیل نشده است |
| خود اپ | کپچا با Dio واقعی، بدون bypass، روی دستگاه مشکل‌دار موفق شود | نیازمند تست/لاگ |
| آزمون منفی | دامنهٔ اشتباه، گواهی نامعتبر و chain غیرمجاز در محیط تست کنترل‌شده رد شوند | انجام نشده است |
| یکسانی زیرساخت | مسیر صحیح روی همهٔ گره‌های TLS و شبکه‌های مجاز | بررسی نشده است |
| چرخهٔ عمر | سیاست تعویض، حذف اعتماد، pinning احتمالی و rollback ثبت شود | نیازمند تصمیم بانک |

موفقیت curl با bundle سفارشی، به‌تنهایی معیار بستن خطای اپ نیست. پس از اصلاح، نسخهٔ واقعی اپ و مسیر دریافت کپچا باید با اعتبارسنجی روشن آزموده شوند.

## ۱۱. وضعیت کد و شیوهٔ اشتراک شواهد

در [کارخانهٔ Dio پروژه](../../lib/core/network/data/dio_factory.dart)، HTTPS استاندارد فعال است؛ CA سفارشی یا callback پذیرش گواهی نامعتبر نصب نشده است. [سند اتصال ورود](../auth/login-api-integration.md#transport-and-integration-limits) نیز تصمیم فعلی و نیاز به دریافت سیاست pinning بانک را ثبت کرده است. این گزارش آن تصمیم‌ها را تغییر نمی‌دهد.

در خروجی کامل `s_client` ممکن است `Master-Key`، شناسهٔ نشست و در curl هدرهای `Set-Cookie`/`SessionId` دیده شوند. این سند آن مقادیر را بازنشر نمی‌کند. برای تبادل عادی با تیم بانک، subject/issuer، fingerprint، chain، زمان، نسخهٔ ابزار و متن خطا کافی است؛ لاگ کامل فقط در کانال مورد تأیید امنیت و پس از حذف داده‌های نشست به اشتراک گذاشته شود.

## ۱۲. متن کوتاه پیشنهادی برای طرح موضوع

> روی شبیه‌ساز اندروید ۱۲، درخواست کپچای `apii.rqbank.ir` با CAهای Termux موفق و با CAهای استخراج‌شدهٔ سیستم با خطای `unable to get local issuer certificate` ناموفق است. مسیر موفق به `Certum Trusted Root CA` می‌رسد و نام این ریشه در مجموعهٔ سیستم یافت نشده است. لطفاً زنجیرهٔ فعلی و امکان ارائهٔ cross-certificate رسمی Certum در نقطهٔ خاتمهٔ TLS را بررسی کنید. هدف، پشتیبانی دستگاه‌های مصوب بانک با اعتبارسنجی کامل HTTPS است؛ نه غیرفعال‌کردن اعتبارسنجی یا ساخت self-signed جدید. در صورت نیاز به CA داخل اپ، فایل رسمی، fingerprint، دامنهٔ اعتماد و سیاست چرخهٔ عمر باید توسط امنیت بانک تأیید شوند.
