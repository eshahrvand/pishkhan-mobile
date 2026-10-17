# قرارداد کدنویسی UI، Cubit و State برای تیم و Agent

**پروژه:** پیشخوان مجازی هوشمند — `pishkhan_mobile`  
**نسخه:** ۱.۶ — قرارداد الزام‌آور یکپارچهٔ معماری و استایل UI<br>
**تاریخ:** ۲۰۲۶/۱۰/۱۷<br>
**دامنه:** سبک نوشتن Presentation، مدیریت State و قواعد خوانایی  
**وضعیت:** در این مرحله فقط سند تهیه شده؛ هیچ refactor یا تغییر رفتار برنامه انجام نشده است.

این سند خواسته‌های صاحب پروژه و نمونه‌های ارائه‌شده را به قواعد مشخص تبدیل می‌کند. هدف این است که یک عضو تیم با باز کردن صفحه، مسیر ساخت UI، خواندن State و فراخوانی Cubit را مستقیم ببیند و برای فهم یک فرم ساده بین چندین wrapper و فایل جابه‌جا نشود.

«الزامی» و «ممنوع» در متن، دستورهای سبکی تأییدشدهٔ صاحب پروژه‌اند. فقط مواردی که صریحاً «توصیه» یا «در انتظار بررسی» نامیده شده‌اند باز هستند؛ این عنوان‌ها هیچ قاعدهٔ الزام‌آوری را تضعیف نمی‌کنند. اصول یکپارچهٔ بخش ۲.۳ الزامی‌اند، نه پیشنهاد. این سند به Agent مجوز تغییر خودکار کد نمی‌دهد و فایل [معماری](architecture-smart-virtual-counter-v2-en.md) یا [Skill فعلی UI](../.agents/skills/flutter-widget-ui-style/SKILL.md) را خودکار بازنویسی نمی‌کند. در اختلاف سبکی، دستور صریح صاحب پروژه که در این سند ثبت شده بر نمونه‌های قدیمی مقدم است؛ مرزها و موارد باز در بخش ۲۵ آمده‌اند.

**قاعدهٔ تفسیر:** Agent نباید از «خوانایی»، «تمیزتر»، «قابل‌توسعه» یا احتمال آینده، مجوز ساخت abstraction تازه، wrapper تازه، State موازی یا استثنا بر ممنوعیت‌ها نتیجه بگیرد. «ممنوع» را با تغییر اسم همان الگو دور نزن. «مجاز» را نیز به «اجباری برای همهٔ صفحات» تبدیل نکن. اگر رفتار موردنیاز واقعاً با قرارداد قابل‌پیاده‌سازی نیست، مورد مشخص را گزارش کن؛ قانون جایگزین اختراع نکن.

این سند همتای فارسی [قرارداد انگلیسی نسخهٔ ۱.۶](ui-cubit-state-agent-rules-en.md) است. قواعد مصوب در هر دو نسخه یکسان‌اند؛ متن قدیمی، مثال تاریخی یا سند جانبی مجوز برداشت مخالف نیست.

## اجرای الزامی برای تمام Agentها

این قرارداد مرجع واحد سبک پروژه برای UI، Cubit، State، ساخت Provider و مرز وابستگی‌هاست. پیش از برنامه‌ریزی، نوشتن یا بازبینی کد مرتبط، تمام سند خوانده شود. [AGENTS.md ریشهٔ پروژه](../AGENTS.md) این کار را برای Agent الزامی کرده است؛ خواندن Skill یا دیدن کد قدیمی جای آن را نمی‌گیرد.

«باید» و «ممنوع» الزام‌اند. عبارت‌های «ترجیح»، «پیش‌فرض» یا «معمولاً» در مثال‌های قدیمی نمی‌توانند ممنوعیت صریح را دور بزنند. مواردی که صریحاً مجازند، دامنهٔ قانون را مشخص می‌کنند و مجوز ساخت استثنای تازه نیستند. فقط دستور صریح صاحب پروژه که همان قاعده را تغییر دهد، آن را اصلاح می‌کند؛ درخواست عادی پیاده‌سازی به معنی معافیت نیست.

Agent حق ندارد:

- سلیقهٔ معماری خودش را جایگزین قرارداد کند؛
- به کد قدیمیِ ناسازگار، عرف فریم‌ورک، نمونهٔ Skill، راحتی تست، سرعت، خط کمتر یا توسعهٔ احتمالی آینده استناد کند تا قانون را رعایت نکند؛
- الگوی ممنوع را با تغییر اسم، wrapper یا جابه‌جایی ظاهری مجاز جلوه دهد؛
- تصمیم جریان را در callback، lifecycle، متد UI، listener، notifier، mapper یا adapter مسیریابی پنهان کند؛
- با تخلف شناخته‌شده در کدی که ایجاد یا تغییر داده، کار را کامل یا کاملاً منطبق اعلام کند.

پیش از کدنویسی، مالک هر رفتار مشخص شود: Cubit/Domain یا عملیات مشخصِ وابسته به Flutter. پس از پیاده‌سازی، تمام constructorها، Providerها، callbackها، listenerها، فیلدهای State و ویجت‌های استخراج‌شدهٔ تغییرکرده بررسی و تخلف‌ها اصلاح شوند. موفقیت تست و تحلیل استاتیک به معنی معافیت از قواعد سبک نیست.

اگر نیاز مشخصی واقعاً در چارچوب قرارداد قابل‌اجرا نیست، تعارض دقیق گزارش شود و همان تغییر وابسته پیاده‌سازی نشود؛ کارهای مستقلِ مجاز ادامه پیدا کنند. راهکار ممنوع اجرا نشود، قانون بی‌صدا ضعیف نشود و برای کار معمول، مجوز دورزدن قانون درخواست نشود.

این الزام‌ها در محدودهٔ کار مجاز کاربر اعمال می‌شوند؛ مجوز بازنویسی بی‌درخواستِ کل پروژه نیستند و به معنی انطباق تمام کدهای قدیمیِ دست‌نخورده نیستند.

## فهرست

1. برداشت از خواسته‌ها و تصمیم‌های اصلی
2. نمونهٔ مرجع چه چیزی را تعیین می‌کند؟
3. مسئولیت UI، Cubit و State
4. ساختار فایل‌ها و نام‌گذاری
5. قرارداد State
6. قرارداد Cubit و متدهای تغییر فیلد
7. محاسبات و فیلدهای وابسته
8. عملیات async، خطا و پاسخ قدیمی
9. الگوی BlocProvider داخل صفحه
10. استفادهٔ مستقیم از State در UI
11. buildWhen و listenWhen
12. مرز subscription و انتقال State به فرزند
13. سبک نوشتن درخت UI
14. شکستن صفحه و عمومی بودن ویجت‌ها
15. شرط‌های نمایشی و توابع عنوان و متن
16. فیلتر، انتخاب و لیست‌ها
17. دیالوگ و Bottom Sheet
18. کلیدها و تست‌های UI
19. controller، focus، timer و lifecycle
20. جریان چندمرحله‌ای و Back
21. طراحی مشترک، RTL و ترجمه
22. بررسی مثال‌های فعلی پروژه
23. خطاهای رایج و اصلاح پیشنهادی
24. دستور عملی Agent و چک‌لیست بازبینی
25. اختلاف با مستندات فعلی و مسیر پذیرش

## ۱. برداشت از خواسته‌ها و تصمیم‌های اصلی

| موضوع | قاعدهٔ مصوب |
|---|---|
| ساخت Cubit صفحه | ساخت مستقیم در BlocProvider.create خود صفحه/فلو؛ بدون ثبت Cubit در GetIt، helper ساخت، Screen/View اضافه یا Provider صفحه در Router |
| دریافت وابستگی | ثبت Repository/Service/API/UseCase واقعی در GetIt؛ دریافت در فیلد Cubit، بدون پارامتر وابستگی در سازندهٔ صفحه یا Cubit |
| پیدا کردن Cubit | `context.read<MyCubit>()` در context زیر Provider |
| State | یک data class سادهٔ Freezed، بدون getter و منطق دست‌نویس |
| مقدار اولیه | constructor خوانای `State.initial(...)`؛ فقط یک factory |
| نمایش | خواندن مستقیم `state.field` داخل آرگومان ویجت |
| loading | مقایسهٔ مستقیم `state.submissionStatus == RequestStatus.loading` |
| منطق قابل‌انتقال | هر تصمیم و محاسبهٔ مستقل از منابع Flutter در Cubit/Domain؛ شامل ساخت درخواست و هماهنگی تعامل |
| تغییر وضعیت نمایشی | حتی نمایش رمز و باز/بسته‌شدن بخش، در Cubit/State؛ استفادهٔ معمول از `setState` ممنوع |
| فرم ثابت | فیلدهای صریح شبیه نمونهٔ صاحب پروژه؛ آرایه‌های موازی و dispatch با index ممنوع |
| متن وابسته به چند مرحله | تابع نام‌دار در UI که `String` برگرداند |
| side effect | تصمیم و دادهٔ آماده در Cubit؛ اجرای Flutter در Listener و برگرداندن نتیجهٔ خام به Cubit |
| بازسازی UI | `BlocBuilder` دور بخش معنادارِ متغیر؛ نه builder اجباری برای تک‌تک ویجت‌ها |
| side effect تکرارشونده | `BlocListener` با `listenWhen` دقیق |
| شکستن UI | معمولاً پس از حدود ۱۵۰–۲۰۰ خط یا وقتی یک بخش واقعاً دوباره استفاده می‌شود |
| ویجت استخراج‌شده | کلاس عمومی با نام مشخص در فایل خودش |
| wrapper اضافی | ممنوع؛ مخصوصاً `_ScreenView` صرفاً برای قرار گرفتن زیر Provider |
| تابع سازندهٔ UI | `_content`، `_body` و `_footer` که درخت UI برمی‌گردانند ممنوع |
| Key | پیش‌فرض: اضافه نکن؛ فقط با نیاز رفتاری مشخص و توضیح نزدیک کد |
| widget ناشناخته | ابتدا API عمومی `avp_ui` را بررسی کن؛ abstraction جدید به ابتکار Agent نساز |
| محدودهٔ تغییر | بدون درخواست صریح، refactor گسترده، تغییر پکیج و نصب dependency انجام نده |

خوانایی فقط با تعداد کمتر خط سنجیده نمی‌شود. چند خط تکرار روشن، از یک سازوکار عمومی با چندین callback و نوع دادهٔ نامفهوم قابل‌قبول‌تر است.

## ۲. نمونهٔ مرجع چه چیزی را تعیین می‌کند؟

### ۲.۱ مواردی که از نمونه پذیرفته می‌شوند

- متدهای مشخص مانند `updatePhoneNumber`، `updateOtp` و `requestOtp`.
- `emit(state.copyWith(...))` صریح و قابل‌ردیابی.
- State شامل مقدار فیلدها، وضعیت درخواست و قابلیت انجام action.
- ساخت Provider داخل صفحه، سپس Listener و Scaffold.
- خواندن مستقیم State در آرگومان‌ها؛ بدون تبدیل State به یک ViewModel دیگر.
- `buildWhen` و `listenWhen` در محل مصرف.
- استفاده از ویجت‌های آشنای تیم و پکیج طراحی موجود.
- استخراج فرم، بخش OTP یا بخش بزرگی از جریان؛ بدون تقسیم عنوان و فاصله و آیکون به فایل‌های مستقل.

### ۲.۲ مواردی که نباید عیناً از برنامهٔ دیگر کپی شوند

نمونهٔ Axino مرجع سبک است؛ قرارداد شبکه، ذخیره‌سازی و امنیت این پروژه را تعیین نمی‌کند.

| مورد در نمونه | تصمیم برای این پروژه |
|---|---|
| دریافت وابستگی | Repository/Service/UseCase ثبت‌شده در فیلد Cubit از GetIt دریافت شود؛ lookup در UI یا Router ممنوع |
| `S.current` | الگوی مصوب دسترسی مستقیم به ترجمه؛ پیاده‌سازی در task جدا |
| enum مشترک با `otpSubmitting` و `authLoading` | برای عملیات مستقل، status مستقل با `RequestStatus` موجود |
| دو emit برای ورودی و وضعیت دکمه | ترجیح: یک emit برای snapshot کامل و سازگار |
| `void ... async` | برای عملیات قابل‌انتظار از `Future<void>` استفاده شود |
| نبود `isClosed` بعد از await | guard بسته شدن و در صورت نیاز guard پاسخ قدیمی حفظ شود |
| controller در StatelessWidget و focus ایستا | مالک lifecycle، StatefulWidget با dispose باشد |
| `print` کردن OTP یا PIN | ممنوع؛ دادهٔ حساس در log قرار نگیرد |
| ذخیرهٔ رمز خام یا fallback مانند `0000` | وارد قرارداد این پروژه نشود |
| تغییر UI بعد از callback با State قبلی | نتیجهٔ action یا مقدار تازهٔ State خوانده شود |
| نمونهٔ OTP با طول‌های ۴، ۶ و شرط `> 4` | طول مجاز از قرارداد همان سرویس تعیین و در همهٔ مسیرها یکسان شود |

این تفاوت‌ها سبک موردنظر تیم را تغییر نمی‌دهند؛ جلوی تکثیر اشکال‌های lifecycle و رفتار را می‌گیرند.

### ۲.۳ اصول یکپارچه و الزام‌آورِ تأییدشده

صاحب پروژه منطق بخش‌های **۲، ۳، ۴، ۶، ۷ و ۸** بررسی Caltivita را تأیید کرده است. معنای الزام‌آور آن‌ها در همین سند آمده؛ دو سند موقت فارسی و انگلیسی آن بررسی حذف شده‌اند. Agent نباید برای اجرای قواعد به آن پیش‌نویس‌ها وابسته باشد یا استثناهای پیاده‌سازی مرجع را قانون پروژه تلقی کند.

| حوزه | الزام | برداشت ممنوع |
| --- | --- | --- |
| معماری | Provider متعلق به صفحه/فلوی واقعی است؛ مراحل مشترک همان Cubit را می‌خوانند؛ UI State را نمایش می‌دهد و اکشن مشخص می‌فرستد | Cubit اضافی برای هر child، هماهنگ‌کنندهٔ تجاری در UI یا لایهٔ غیرضروری |
| GetIt | فقط وابستگی واقعی ثبت شود؛ Cubit وابستگی را در فیلد دریافت کند؛ مرجع تغییرناپذیر final باشد مگر تعویض وابستگی رفتار واقعاً مجاز باشد | ثبت/دریافت Cubit از GetIt، پاس‌دادن Repository/Service/UseCase به سازندهٔ Cubit یا UI و lookup داده در Router/UI |
| ساخت | constructor مستقیم و اکشن اولیهٔ صریح در BlocProvider.create خود صفحه/فلو؛ State اولیه دست‌نخورده بماند | Provider صفحه در GoRouter، _createCubit، wrapper مخفی‌کنندهٔ ساخت و emit/load/timer/محاسبهٔ State در constructor |
| عمر نمونه | create مالک close است؛ value فقط نمونهٔ موجود را در مرز واقعی مثل modal عرضه می‌کند | Cubit تازه در value، بستن Cubit قرض‌گرفته‌شده یا ساخت تکراری در rebuild عادی |
| اکشن | تصمیم، اعتبارسنجی، محاسبه، ساخت درخواست و نتیجهٔ modal در Cubit/Domain؛ emit(copyWith) در خود اکشن | dispatch با نام رشته‌ای یا index فیلد، واسطهٔ انتشار State، getter محاسباتی State یا ساخت request در UI |
| async | عملیات قابل‌انتظار Future<void>؛ loading/result/failure صریح و محافظ‌های لازم lifecycle، پاسخ قدیمی، ارسال تکراری و idempotency بانکی | کپی زنجیره‌های void تودرتو یا حذف محافظ‌ها برای شباهت ظاهری به نمونه |
| نمایش | Builder بخش منسجم متغیر را بسازد؛ child دریافت‌کنندهٔ State والد اشتراک تکراری همان داده نسازد؛ build درخواست شروع نکند | load/submit/analytics در build، builder تشریفاتی برای هر Text/Icon یا تصمیم تجاری در buildWhen |
| اثر نمایشی | Listener مجری اثر آماده؛ Consumer وقتی همان بخش نمایش و اثر را با هم نیاز دارد؛ MultiBlocListener برای اثرهای مستقل | تصمیم جریان در listener، Consumer اجباری در همه‌جا یا چارچوب effect عمومی بدون نیاز مشخص |
| متد listener | switch چندحالتهٔ effect و بدنهٔ async مفصل، متد نام‌دار widget/State باشد؛ listenWhen دقیق کنار ارجاع بماند | callback چندحالتهٔ inline یا انتقال تصمیم درخواست/اعتبار/مقصد به متد UI |
| نوشتن UI | چیدمان صریح و build با بدنهٔ block؛ label/value/error/action هر فیلد ثابت کنار هم | متد برگردانندهٔ درخت Widget، wrapper خصوصی Screen/View یا renderer فرم ثابت با array/map/record/schema |
| مرز ویجت | مسئولیت بزرگ یا استفادهٔ مجدد واقعی در widget عمومی و فایل خودش با حفظ subscription/resource استخراج شود | فایل برای تک‌تک فاصله‌ها و آیکون‌ها، خردکردن بی‌دلیل یا حد خط دقیق برگرفته از اندازهٔ فایل مرجع |
| استایل | کلاس PascalCase، فایل snake_case، متد camelCase، super.key، const مناسب، callback نوع‌دار، S.current و طراحی پروژه | Function?/dynamic برای نوع معلوم، کپی API/رنگ/فونت/asset پروژهٔ مرجع یا اختراع کامپوننت ناموجود |
| modal و منابع | launcher فقط Flutter API با ورودی آماده و widget عمومی را اجرا کند؛ SafeArea و فضای کیبورد متناسب رعایت شود؛ controller/focus/scroll در مالک UI dispose شوند | منطق جریان در launcher، منابع Flutter در State/Cubit یا انتخاب موازی با setState/notifier |

**ساختار State فعلی باید حفظ شود:** یک Freezed ساده با `.initial`، سازمان‌دهی `part of` موجود، `RequestStatus` فعلی، nullability معنی‌دار و پیش‌فرض‌های مناسب. برای تقلید نمونه، نام‌گذاری و سازمان‌دهی State تغییر نکند؛ dynamic buffer، status nullable غیرضروری یا انتخاب محلی موازی وارد نشود. status مستقل فقط برای عملیات مستقل واقعی باشد، نه فیلد تشریفاتی. حفظ ساختار، تضمین صحت تمام به‌روزرسانی‌های تاریخی نیست.

**تست وابستگی:** نمونهٔ کنترل‌شده قبل از ساخت Cubit در GetIt ثبت شود؛ سپس Cubit متعلق به تست بسته و locator تست reset شود. تعویض ثبت، نمونهٔ ذخیره‌شده در فیلد Cubit موجود را خودکار عوض نمی‌کند. برای راحتی تست، constructor override وابستگی، ثبت Cubit یا factory تولیدی تازه نساز. این بند الزام تست برای هر تغییر جزئی یا API تعویض وابستگی در همهٔ جریان‌ها نیست.

سایر موضوع‌های بررسی مرجع، توضیحی یا تأییدنشده‌اند و الزام یا مجوز مهاجرت تازه ایجاد نمی‌کنند. منطق سلامت، اشتراک، شبکه یا جزئیات پیاده‌سازی مرجع بر این قرارداد مقدم نیست.

## ۳. مسئولیت UI، Cubit و State

### ۳.۱ State: داده و وضعیت متعلق به flow

State نگه می‌دارد:

- مقدار ورودی‌ها؛
- دادهٔ دریافتی؛
- مرحلهٔ جاری؛
- وضعیت مستقل درخواست‌ها؛
- نتیجهٔ انتخاب، فیلتر و محاسباتی که UI نیاز دارد؛
- خطاهای فیلد و Failure؛
- اطلاعات رسید و نتیجهٔ عملیات.
- وضعیت نمایشی قابل‌تغییر مانند `isPasswordVisible` و `isSummaryExpanded`؛
- دادهٔ عملیاتی معنی‌دار مانند snapshot تأییدشدهٔ درخواست، وقتی قرارداد flow آن را لازم می‌داند.

State **انجام نمی‌دهد**: محاسبه، اعتبارسنجی، ترجمه، navigation، دسترسی به repository یا ساخت ویجت.

### ۳.۲ Cubit: تصمیم و تغییر وضعیت

Cubit مسئول است برای:

- اعتبارسنجی از طریق validator و use case؛
- تعیین `canSubmit`، `canContinue` و eligibility؛
- تغییر مرحله و حفظ یا پاک کردن دادهٔ وابسته؛
- فیلتر داده، حل انتخاب و محاسبهٔ جمع مبلغ؛
- فراخوانی use case/repository؛
- جلوگیری از درخواست تکراری و پاسخ قدیمی؛
- مدیریت timer متعلق به جریان؛
- ساخت درخواست خدمت و نگه‌داشتن زمینهٔ رکورد انتخاب‌شده؛
- تصمیم عملیات مجاز، footer، مقصد و رفتار back/exit؛
- تصمیم نمایش action sheet، جزئیات، تأیید یا reveal دسته؛
- تفسیر نتیجهٔ sheet/dialog و تعیین اکشن بعدی.

منطق تجاری قابل‌استفاده در چند مصرف‌کننده، در Domain می‌ماند؛ «منطق را به Cubit ببر» به معنی انتقال همهٔ قوانین بانک از UseCase به Cubit نیست. Cubit هماهنگ‌کنندهٔ رفتار فرم است.

### ۳.۳ UI: چیدمان، نمایش و تعامل با Flutter

UI مسئول است برای:

- ساخت درخت ویجت؛
- انتخاب متن ترجمه‌شده و رنگ و فاصله؛
- مالکیت و dispose منابع focus، scroll و controller؛
- اجرای dialog، sheet، snackbar، navigation یا callback آماده‌شده توسط Cubit؛
- برگرداندن نتیجهٔ خام تعامل به Cubit بدون تصمیم ادامهٔ جریان؛
- فراخوانی actionهای Cubit در پاسخ به کاربر.

«UI مسئول نمایش است» به معنی مجاز بودن نگه‌داشتن booleanهای نمایشی در State کلاس Flutter و تغییرشان با `setState` نیست. مقدار این وضعیت‌ها در Freezed State است و action مربوط به آن‌ها در Cubit قرار دارد. controller، focus و scroll، منابع Flutter با مالک UI و lifecycle مشخص‌اند؛ این منابع را به State داده‌ای منتقل نکن.

### ۳.۴ جدول تصمیم برای محل منطق

| مثال | محل |
|---|---|
| شماره موبایل معتبر است؟ | validator خالص؛ نتیجهٔ فرم در Cubit |
| آیا جمع هزینه از موجودی بیشتر است؟ | Cubit/Domain؛ نتیجه در State |
| کدام کارت‌ها با جستجو مطابقت دارند؟ | Cubit |
| کدام مرحله بعدی است؟ | Cubit |
| عنوان فارسی مرحلهٔ فعلی چیست؟ | تابع نمایشی UI |
| رنگ متن خطا چیست؟ | UI و token طراحی |
| اسکرول به بالای صفحه بعد از تغییر مرحله | تصمیم reveal در Cubit؛ اجرای scroll در Listener UI |
| بستن sheet | تصمیم جریان در Cubit؛ اجرای Flutter API در UI |
| رمز دیده شود یا پنهان باشد؟ | field در State و action در Cubit؛ UI مقدار را نمایش می‌دهد |
| خطای عدم تطابق رمز نمایش داده شود؟ | اعتبارسنجی و field خطا در Cubit/State؛ focus-loss event از UI |
| ذخیره و بازیابی token | زیرساخت احراز هویت؛ خارج از widget |
| دنبال کردن صفحه یا کلیک | محل side effect مشخص؛ هرگز build تکرارشونده |

### ۳.۵ دروازهٔ اجباری مالکیت: منطق قابل‌انتقال در UI ممنوع است

هر تابع، callback، listener، builder و lifecycle باید این بررسی را بگذراند: اگر رفتار بدون BuildContext، Widget، controller یا اطلاعات واقعی layout قابل‌اجراست، مالک آن Cubit/Domain است. کوتاه‌بودن، privateبودن، درگیری navigation یا نام «هماهنگی UI» استثنا نیست.

UI نباید request بسازد؛ action/category را به خدمت تبدیل کند؛ footer یا eligibility را تعیین کند؛ دربارهٔ نتیجهٔ modal، حذف آدرس، ادامهٔ مرحله، تأیید خروج یا back تصمیم بگیرد. این موارد در Cubit انجام و دادهٔ آمادهٔ اثر منتشر شوند. UI فقط Flutter API را اجرا و نتیجهٔ خام—حتی null هنگام انصراف—را به اکشن مربوط برگرداند.

نام متدهایی مانند `_request`، `_more`، `_back` یا `_handleEffect` مالکیت را تغییر نمی‌دهد. helper، extension، adapter، callback، notifier یا mapper راه فرار نیست. Cubit نباید برای اجرای این وظایف BuildContext یا controller دریافت کند.

کارهایی که واقعاً در UI می‌مانند: ساخت widget، ترجمه و قالب‌بندی مقدار محاسبه‌شده، theme/layout/viewport، اتصال و dispose منابع، همگام‌سازی controller از State، guardهای mounted/hasClients و اجرای focus/scroll/navigation/modal. عنوان و asset نمایشی می‌توانند helper مقدار داشته باشند؛ آن helper حق تعیین عملیات یا محاسبهٔ مبلغ ندارد.

اثر باید دادهٔ لازم و زمینهٔ کارت/سپرده را از Cubit بگیرد. نتیجهٔ تعامل در Cubit بررسی شود؛ پاسخ قدیمی، انصراف و قفل عملیات نیز همان‌جا مدیریت شوند. adapter کوتاهی که فقط Flutter API را اجرا کند مجاز است؛ حتی یک خط تصمیم قابل‌انتقال در آن مجاز نیست.

## ۴. ساختار فایل‌ها و نام‌گذاری

نمونهٔ پیشنهادی یک سرویس:

```text
lib/features/auth/
  domain/
    repositories/
    usecases/
  data/
    repositories/
  presentation/
    login/
      cubit/
        auth_cubit.dart
        auth_state.dart
        auth_cubit.freezed.dart        # generated
      screens/
        auth_screen.dart
      widgets/
        login_form_widget.dart
        otp_widget.dart
```

نام پوشهٔ سرویس مطابق معماری باشد. فایل‌های generated دستی ویرایش نمی‌شوند.

### ۴.۱ نام کلاس‌ها و متدها

```dart
class AuthScreen extends StatefulWidget { ... }
class LoginFormWidget extends StatelessWidget { ... }
class OtpWidget extends StatefulWidget { ... }

void updatePhoneNumber(String value) { ... }
void updateNationalId(String value) { ... }
void updateOtp(String value) { ... }
Future<void> requestOtp() async { ... }
Future<void> submitLogin() async { ... }
```

اسم action باید رفتار را روشن کند. نام‌هایی مانند `process`، `handle`، `apply` یا `update` بدون بیان موضوع، کافی نیستند.

فیلدها جدا و خوانا نوشته شوند:

```dart
final String? initialDepositNumber;
final VoidCallback? onAssistantPressed;
final ValueChanged<CertificateReceipt>? onCompleted;
```

فشرده‌نویسی چند فیلد نامرتبط در یک declaration، قاعدهٔ پیش‌فرض این قرارداد نیست.

## ۵. قرارداد State

### ۵.۱ یک State ساده، یک factory

برای هماهنگی با نمونهٔ صاحب پروژه، در این قرارداد نام constructor اولیه `initial` است. این فقط نام constructor داده است؛ State به unionهای `loading/success/error` تقسیم نمی‌شود.

```dart
// auth_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

// تعریف AuthCubit در همین فایل قرار می‌گیرد.
```

```dart
// auth_state.dart
part of 'auth_cubit.dart';

enum AuthStep {
  identity,
  otp,
}

@Freezed(toStringOverride: false)
abstract class AuthState with _$AuthState {
  const factory AuthState.initial({
    @Default(AuthStep.identity) AuthStep step,
    @Default(RequestStatus.initial) RequestStatus otpRequestStatus,
    @Default(RequestStatus.initial) RequestStatus loginStatus,
    @Default('') String phoneNumber,
    @Default('') String nationalId,
    @Default('') String otp,
    @Default(false) bool isPhoneNumberError,
    @Default(false) bool isNationalIdError,
    @Default(false) bool isOtpError,
    @Default(false) bool canRequestOtp,
    @Default(false) bool canSubmitLogin,
    @Default(0) int remainingSeconds,
    Failure? otpRequestFailure,
    Failure? loginFailure,
  }) = _AuthState;
}
```

مثال‌ها الگوی پیشنهادی هستند، نه فایل آمادهٔ جایگزینی در پروژه. importهای Domain، UseCase و کلیدهای ترجمه باید با سرویس واقعی تطبیق یابند. نام‌های `AuthState` و `AuthCubit` در این مثال‌ها تعریف‌های آموزشی‌اند و اکنون به برنامه افزوده نشده‌اند.

**تصمیم پس از مقایسهٔ مرجع:** ساختار فعلی State پیشخوان حفظ می‌شود. factory بی‌نام و فایل State مستقل در Caltivita دلیل مهاجرت این پروژه نیست؛ status nullable و dynamic edit buffer نمونه کپی نشوند.

### ۵.۲ ممنوع: getter و منطق دست‌نویس در State

```dart
// ممنوع
const AuthState._();

bool get isLoading => loginStatus == RequestStatus.loading;

bool get canSubmit => otp.length == 4 && remainingSeconds > 0;

List<ListedCard> get visibleCards => cards.where(...).toList();
```

به‌جای getterِ `isLoading`، UI مستقیماً status را مقایسه می‌کند. `canSubmitLogin` و `visibleCards` دادهٔ محاسبه‌شده در Cubit هستند و به‌صورت field ذخیره می‌شوند.

accessorهای generated، `copyWith` و equalityِ Freezed جزو زیرساخت‌اند؛ این ممنوعیت شامل آن‌ها نمی‌شود.

### ۵.۳ پیش‌فرض و nullable

```dart
@Default(false) bool termsAccepted,
@Default(0) int totalRial,
@Default(<ListedCard>[]) List<ListedCard> cards,
ServiceBankCard? selectedCard,
Failure? failure,
```

- برای مقدار معلوم، default غیر-null بگذار.
- برای «هنوز انتخاب نشده»، `null` معنی‌دار است.
- `bool?` برای وضعیت بله/خیر عادی ممنوع است.
- مقدار ناشناختهٔ مالی را با صفر جعلی پنهان نکن؛ در صورت نیاز `int?` یا وضعیت دادهٔ مشخص استفاده کن.
- لیست و مدل داخل State immutable و دارای equality مناسب باشد.

### ۵.۴ status مستقل برای هر عملیات

```dart
@Default(RequestStatus.initial) RequestStatus catalogStatus,
@Default(RequestStatus.initial) RequestStatus quoteStatus,
@Default(RequestStatus.initial) RequestStatus submissionStatus,
```

ممنوع است همهٔ این وضعیت‌ها را در یک enum بزرگ مانند `quoteLoading / submitLoading / quoteSuccess / submitSuccess` ادغام کنیم. `step` و outcome تجاری با چرخهٔ درخواست متفاوت‌اند.

### ۵.۵ فیلد فعلی، قرارداد سرویس آینده و فیلد بی‌دلیل

هر field باید مصرف یا مسئولیت قابل‌بیان داشته باشد؛ **مصرف مستقیم در UI شرط وجود همهٔ fieldها نیست.** فیلدهای موردنیاز اتصال سرویس واقعی، retry یا چرخهٔ عملیات می‌توانند باقی بمانند، حتی اگر UI فعلی آن‌ها را نخواند. نام عملیات، قرارداد یا دلیل مشخص آن باید معلوم باشد.

```dart
// مجاز، اگر عملیات ارسال و اتصال آیندهٔ آن مشخص است.
@Default(RequestStatus.initial) RequestStatus submissionStatus,

// مجاز، اگر flow باید snapshot دقیقِ تأییدشده را برای ارسال/retry حفظ کند.
IssuanceRequest? confirmedRequest,
```

- Agent فقط به علت «الان در UI مصرف نمی‌شود» field را حذف نکند.
- Agent به علت «شاید بعداً لازم شود» برای همهٔ Cubitها status و فیلد تشریفاتی نسازد.
- Stateِ انتخاب تبِ بدون عملیات async، صرفاً به خاطر template به RequestStatus نیاز ندارد.
- نتیجهٔ محاسبه، وضعیت نمایشی یا خطایی که UI به آن نیاز دارد، باید از State خوانده شود؛ نبود مصرف می‌تواند نقص UI باشد و باید بررسی شود، نه اینکه field خودکار حذف شود.

### ۵.۶ مدل درخواست با State فرم متفاوت است

`CardIssuanceState` وضعیت flow است. `IssuanceRequest` یک مدل دادهٔ ارسال است که **می‌تواند یک field داخل State باشد**. این دو را یکی فرض نکن.

```dart
// مصرف UI از State فرم
value: state.draft.depositId,
isLoading: state.submissionStatus == RequestStatus.loading,

// مصرف عملیاتی داخل action Cubit
final request = state.confirmedRequest;
```

هیچ حکم کلی برای بیرون بردن همهٔ requestها از State نداریم. snapshot تأییدشده و قابل‌retry می‌تواند در State بماند؛ request موقتی نیز می‌تواند هنگام submit از دادهٔ State ساخته شود. Agent باید قرارداد موجود flow را حفظ کند و این سند را مجوز تغییر محل مدل درخواست یا بازنویسی UI نداند. نام `confirmedRequest` در مثال، پیشنهاد توضیحی است و دستور renameِ field فعلی نیست.

## ۶. قرارداد Cubit و متدهای تغییر فیلد

### ۶.۱ constructor خوانا و دریافت وابستگی داخل Cubit

```dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    AuthState initialState = const AuthState.initial(),
  }) : super(initialState);

  final requestOtpUseCase = getIt<RequestOtpUseCase>();
  final submitLoginUseCase = getIt<SubmitLoginUseCase>();

  Timer? _timer;
}
```

پارامتر `initialState` برای سازگاری با قرارداد پروژه و تست باقی می‌ماند؛ UI عادی لازم نیست هر بار State پیش‌فرض را پاس بدهد. پارامتر ورودی واقعی مانند `initialDepositNumber` با snapshot کامل State یکی نیست.

ساختار State ساده، اکشن صریح و دریافت وابستگی ثبت‌شده در فیلد Cubit، الگوی مصوب است؛ وابستگی و API ساختگی از پروژهٔ دیگر اضافه نشود.

### ۶.۱.۱ constructor باید State اولیه را حفظ کند

constructor فقط State ورودی را به `super(initialState)` می‌دهد و ورودی واقعی شروع را نگه می‌دارد. فیلد وابستگی، نمونهٔ ثبت‌شده را از GetIt می‌گیرد. constructor نباید emit، load، اکشن initialization، timer، فیلتر، محاسبهٔ دادهٔ مشتق یا ساخت درخواست اجرا کند؛ همین کارها پشت initializer/helper یا State جایگزین در super هم ممنوع‌اند.

Provider اکشن اولیه را صریح اجرا می‌کند:

```dart
create: (_) => CardFeaturesCubit(
  initialCategory: initialCategory,
)..load(),
```

ساختن Cubit به‌تنهایی باید دقیقاً snapshot اولیه را حفظ کند. حل پارامتر شروع و محاسبات وابسته در اکشن اولیه انجام می‌شوند.

### ۶.۲ action کوچک و مشخص

فرض این مثال: input عددی قبلاً در UI نرمال شده و هنگام درخواست async، ویرایش هویت قفل است.

```dart
void updatePhoneNumber(String value) {
  if (state.otpRequestStatus == RequestStatus.loading ||
      state.loginStatus == RequestStatus.loading) {
    return;
  }

  emit(
    state.copyWith(
      phoneNumber: value,
      isPhoneNumberError: false,
      canRequestOtp: checkOtpButtonEnable(
        phoneNumber: value,
        nationalId: state.nationalId,
      ),
      otpRequestStatus: RequestStatus.initial,
      otpRequestFailure: null,
    ),
  );
}

bool checkOtpButtonEnable({
  required String phoneNumber,
  required String nationalId,
}) {
  return PhoneNumberValidator.isValid(phoneNumber) &&
      NationalCodeValidator.isValid(nationalId);
}
```

تابع `checkOtpButtonEnable` داخل Cubit است و از UI صدا زده نمی‌شود. ورودی تازه را می‌گیرد تا تصمیم بر اساس `state.phoneNumber` قدیمی نباشد.

### ۶.۳ یک تغییر کاربر، یک snapshot سازگار

```dart
// مطلوب
emit(
  state.copyWith(
    otp: value,
    isOtpError: false,
    canSubmitLogin: CodeValidator.isValid(value, length: 4) &&
        state.remainingSeconds > 0,
  ),
);
```

```dart
// برای ورودی و نتیجهٔ وابسته، الگوی پیش‌فرض نباشد.
emit(state.copyWith(otp: value));
emit(state.copyWith(canSubmitLogin: checkButtonEnable()));
```

چند emit برای `loading → success` لازم است؛ چند emit برای نمایش لحظه‌ای دادهٔ ناسازگار لازم نیست. دو emit در نمونهٔ مالک، مجوز ساخت snapshot ناقص در همهٔ actionها نیست.

### ۶.۴ ممنوعیت قطعی واسطهٔ ساخت و انتشار State

```dart
// ممنوع
@override
void emit(AuthState next) {
  super.emit(AuthRules.prepare(next));
}
```

```dart
// ممنوع؛ نام private هم استثنا ایجاد نمی‌کند.
void updatePhoneNumber(String value) {
  emit(_prepareState(state.copyWith(phoneNumber: value)));
}
```

در این قرارداد، action باید فیلدهایی را که تغییر می‌دهد روشن نشان دهد. **Agent حق ساخت واسطه برای `emit`، آماده‌سازی State یا انتشار خودکار State را ندارد.** private یا public بودن، کوچک بودن تابع یا استفاده در یک flow این ممنوعیت را تغییر نمی‌دهد.

همهٔ این نام‌ها، وقتی همین مسئولیت را دارند، ممنوع‌اند:

```dart
emit(_prepareState(...));
emit(calculateNextState(...));
emit(AuthRules.prepare(...));
_updateState(...);       // محاسبهٔ پنهان + emit
emitPreparedState(...);
publishState(...);
```

تغییر اسم، استفاده از extension، mixin، BaseCubit یا override کردن `emit` راه دور زدن قاعده نیست. در action، `emit(state.copyWith(...))` به‌صورت صریح نوشته شود.

**تابع خالصِ یک محاسبه با این ممنوعیت فرق دارد.** تابعی مثل `checkOtpButtonEnable(...)` یا `calculateSelectedCardsTotal(...)` می‌تواند `bool` یا مبلغ برگرداند؛ نباید State بسازد، emit کند، ورودی‌ها را پنهانی تغییر دهد یا UI را به rules facade متصل کند.

```dart
// مجاز: یک محاسبهٔ مشخص، بدون ساخت State و بدون emit.
bool checkOtpButtonEnable({
  required String phoneNumber,
  required String nationalId,
}) {
  return PhoneNumberValidator.isValid(phoneNumber) &&
      NationalCodeValidator.isValid(nationalId);
}

// action با تغییرهای صریح
void updateNationalId(String value) {
  emit(
    state.copyWith(
      nationalId: value,
      isNationalIdError:
          value.isNotEmpty && !NationalCodeValidator.isValid(value),
      canRequestOtp: checkOtpButtonEnable(
        phoneNumber: state.phoneNumber,
        nationalId: value,
      ),
    ),
  );
}
```

این snippet بدنهٔ سبک action را نشان می‌دهد؛ guardهای flow، مثل عدم ویرایش هنگام درخواست یا پس از موفقیت، در متد واقعی نیز باید صریح حفظ شوند. نمونهٔ کوتاه، مجوز حذف guard نیست.

### ۶.۵ اعتبارسنجی با سبک صاحب پروژه: فیلد مشخص، تابع مرکزی

در مرجع صاحب پروژه، `updatePhoneNumber(value)` تابع `validatePhoneNumber(value)` و `updateNationalId(value)` تابع `isNationalIDValid(value)` را صدا می‌زنند. مرجع از `validateField('phone')` یا dispatch عمومی بر اساس String استفاده نمی‌کند. همین سبک، قرارداد این پروژه است.

```dart
// ممنوع برای فرم ثابت
void validateField(String field) {
  switch (field) {
    case 'nationalId':
      // ...
    case 'phone':
      // ...
  }
}
```

```dart
// مجاز: action مشخص + validator مرکزیِ موجود پروژه
void validateNationalId() {
  emit(
    state.copyWith(
      isNationalIdError: !NationalCodeValidator.isValid(state.nationalId),
    ),
  );
}

void validatePhoneNumber() {
  emit(
    state.copyWith(
      isPhoneNumberError: !PhoneNumberValidator.isValid(state.phoneNumber),
    ),
  );
}
```

```dart
AppTextField(
  value: state.nationalId,
  normalizeDigits: true,
  maxLength: 10,
  errorText: state.isNationalIdError ? S.current.authInvalidNationalId : null,
  onChanged: (value) {
    context.read<AuthCubit>().updateNationalId(value);
  },
  onFocusLost: () {
    context.read<AuthCubit>().validateNationalId();
  },
),
```

نام تابع validator در کد مرجع و پروژهٔ فعلی متفاوت است؛ الگوریتم دوم ساخته نشود. در وضعیت فعلی پروژه، مرجع کد ملی `NationalCodeValidator.isValid` است. اگر صاحب پروژه تابع دیگری را به‌عنوان مرجع نهایی تعیین کرد، مصرف‌کننده‌ها به همان مرجع وصل می‌شوند، نه اینکه regex/checksum موازی در UI و Cubit نوشته شود.

**توضیح صریح مالک: اعتبارسنجی زندهٔ کد ملی و شماره تلفن در فرم ورود، از اولین رقم شروع می‌شود؛ ورودی مشترک تغییر شماره تلفن نیز همین رفتار را دارد.** هر `onChanged` باید action مشخص همان فیلد در Cubit را فراخوانی کند. Cubit با validator مشترک، مقدار تازه و flag خطای آن را در یک emit به‌روز می‌کند. هر مقدار غیرخالی و نامعتبر، حتی ورودی ناقص، باید بلافاصله متن قرمز خطای موجود را نمایش دهد. انتظار تا رسیدن به طول کامل، خروج فوکوس، debounce یا submit ممنوع است. معتبر شدن مقدار باید خطا را همان لحظه حذف کند. فیلد خالی و دست‌نخورده خطای تایپ ندارد؛ خطای required هنگام خروج فوکوس یا submit همچنان پشتیبانی می‌شود. UI مستقیماً flag خطا را در BlocBuilder موجود می‌خواند و هیچ خطایی با `setState` ذخیره نمی‌شود. این توضیح جدید بر نمونهٔ قدیمی که نمایش خطای کد ملی را تا رقم دهم به تأخیر می‌انداخت، اولویت دارد.

شناسه‌های رشته‌ایِ خطای سرور در قرارداد API، مسئلهٔ دیگری‌اند. Agent از ممنوعیت dispatch رشته‌ای برای فرم ثابت، دستور تغییر خودکار قرارداد fieldErrors سرور نتیجه نگیرد.

## ۷. محاسبات و فیلدهای وابسته

### ۷.۱ محاسبهٔ مجموع در Cubit

```dart
void selectCards(Set<String> selectedIds) {
  if (state.submissionStatus == RequestStatus.loading ||
      state.submissionStatus == RequestStatus.success) {
    return;
  }

  final selectedCards = state.cards
      .where((card) => selectedIds.contains(card.id))
      .toList();
  final totalRial = selectedCards.fold<int>(
    0,
    (total, card) => total + card.balanceRial,
  );

  emit(
    state.copyWith(
      selectedIds: selectedCards.map((card) => card.id).toSet(),
      selectedCards: selectedCards,
      totalRial: totalRial,
      termsAccepted: false,
      canContinue: selectedCards.isNotEmpty,
      canSubmit: false,
      failure: null,
    ),
  );
}
```

این متغیرهای محلی داخل **Cubit** مجازند؛ آن‌ها بخشی از محاسبه‌اند. ممنوعیت alias مربوط به بازبسته‌بندی State در builderِ UI است.

### ۷.۲ داده و نتیجه همیشه با هم تغییر کنند

برای هر فیلد مشتق‌شده، همهٔ ورودی‌های آن معلوم باشند:

| field | ورودی‌ها | actionهایی که باید آن را به‌روز کنند |
|---|---|---|
| `canRequestOtp` | موبایل، کد ملی | تغییر هر دو فیلد، reset |
| `canSubmitLogin` | OTP، زمان باقیمانده | تغییر OTP، tick، انقضا، reset |
| `visibleCards` | لیست، query، category، filter | load، جستجو، تغییر دسته، اعمال فیلتر |
| `totalRial` | انتخاب‌ها، مبالغ | انتخاب/حذف، load جدید |
| `canSubmit` | دادهٔ فرم، پذیرش شرایط، eligibility | تمام تغییرهای مرتبط |

ساخت یک boolean در State کافی نیست؛ هر action وابسته باید آن را صحیح نگه دارد. در review، یک ورودی را تغییر بده و بررسی کن خروجی همراه آن تغییر کرده باشد.

### ۷.۳ چه چیزی field جدید نمی‌خواهد؟

برای هر مقایسهٔ کوچک یک boolean جدید نساز:

```dart
// مطلوب: وضعیت درخواست واضح است.
isLoading: state.submissionStatus == RequestStatus.loading,
```

```dart
// غیرضروری، اگر فقط alias همان enum است.
@Default(false) bool isSubmissionLoading,
```

`canSubmit` تصمیم ترکیبی رفتار فرم است؛ `isSubmissionLoading` معمولاً تکرار یک status است.

## ۸. عملیات async، خطا و پاسخ قدیمی

### ۸.۱ الگوی خوانای بارگذاری

در این مثال از قرارداد واقعی `CardServicesRepository` و `LoadCardServiceCatalog` استفاده شده؛ State پیشنهادی فیلدهای `catalogStatus`، `catalog` و `catalogFailure` دارد.

```dart
int _catalogRequestId = 0;

Future<void> loadCatalog() async {
  if (isClosed) return;

  final requestId = ++_catalogRequestId;

  emit(
    state.copyWith(
      catalogStatus: RequestStatus.loading,
      catalogFailure: null,
    ),
  );

  final result = await LoadCardServiceCatalog(repository)();

  if (isClosed || requestId != _catalogRequestId) return;

  switch (result) {
    case Success(:final data):
      emit(
        state.copyWith(
          catalogStatus: RequestStatus.success,
          catalog: data,
          catalogFailure: null,
        ),
      );
    case Err(:final failure):
      emit(
        state.copyWith(
          catalogStatus: RequestStatus.failure,
          catalogFailure: failure,
        ),
      );
  }
}
```

خطای exceptionِ غیرمنتظره باید در boundaryِ UseCase/repository به `Err` تبدیل شود؛ اگر dependency این ضمانت را ندارد، این action هم باید `try/catch` با failure مشخص داشته باشد. Agent نباید assume کند هر Future همیشه به Result می‌رسد.

### ۸.۲ submission: محافظ مستقل از ظاهر دکمه

```dart
Future<void> submit() async {
  if (isClosed ||
      !state.canSubmit ||
      state.submissionStatus == RequestStatus.loading ||
      state.submissionStatus == RequestStatus.success) {
    return;
  }

  final request = createSubmissionRequest();

  emit(
    state.copyWith(
      submissionStatus: RequestStatus.loading,
      submissionFailure: null,
    ),
  );

  final result = await submitUseCase(request);

  if (isClosed) return;

  switch (result) {
    case Success(:final data):
      emit(
        state.copyWith(
          submissionStatus: RequestStatus.success,
          receipt: data,
          canSubmit: false,
        ),
      );
    case Err(:final failure):
      emit(
        state.copyWith(
          submissionStatus: RequestStatus.failure,
          submissionFailure: failure,
        ),
      );
  }
}
```

`createSubmissionRequest` نمونهٔ تابع مشخص ساخت request در Cubit است؛ نه تابع محاسبه در UI. فرض این snippet این است که هنگام submission، edit/reset/load قفل‌اند. اگر تعویض adapter یا reset هم‌زمان ممکن باشد، request ID عملیات نیز باید بررسی شود.

### ۸.۳ قواعد قطعی async

- عملیات قابل‌انتظار، `Future<void>` برگرداند؛ `void async` ننویس.
- قبل از await، status به loading تغییر کند.
- بعد از await، `isClosed` بررسی شود.
- در بارگذاری یا quote هم‌پوشان، generation/request ID لازم است.
- پاسخ قدیمی نباید نتیجهٔ انتخاب جدید را بازنویسی کند.
- فیلدهای قابل‌ویرایش در زمان عملیات حساس از داخل Cubit هم قفل شوند.
- retryِ همان درخواست بانکی، همان idempotency key را حفظ کند.
- تغییر payload پس از failure، هویت درخواست را طبق قرارداد سرویس تازه کند.
- idempotency سمت کلاینت جای ضمانت سمت سرور را نمی‌گیرد.
- `.then` مجاز است، ولی chain باید return/await شود و guard و failure branch داشته باشد. سبک پایهٔ این سند `async/await` است.

### ۸.۴ خطا در UI ترجمه می‌شود

Failure را به متن خام در Domain تبدیل نکن. UI می‌تواند ساده باشد:

```dart
if (state.catalogStatus == RequestStatus.failure)
  Text(S.current.dashboardLoadError),
```

اگر چند code پیام متفاوت دارند، تابع نمایشی نام‌دار مثل `getFailureMessage(failure)` بنویس؛ برای ترجمه از `S.current` استفاده می‌کند و صرفاً برای گرفتن متن، BuildContext دریافت نمی‌کند. UI نباید مستقیماً `DioException` یا DTO خطا را بررسی کند.

## ۹. الگوی BlocProvider داخل صفحه

### ۹.۱ ساختار پایهٔ موردنظر تیم

صفحه با block body نوشته می‌شود. Provider داخل همین `build` است و ادامهٔ درخت را مستقیم می‌بینیم:

```dart
class AverageBalanceScreen extends StatefulWidget {
  const AverageBalanceScreen({
    super.key,
    this.initialDepositNumber,
    this.onCompleted,
  });

  final String? initialDepositNumber;
  final ValueChanged<CertificateReceipt>? onCompleted;

  @override
  State<AverageBalanceScreen> createState() {
    return _AverageBalanceScreenState();
  }
}

class _AverageBalanceScreenState extends State<AverageBalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AverageBalanceCubit(
        initialDepositNumber: widget.initialDepositNumber,
      )..load(),
      child: BlocListener<AverageBalanceCubit, AverageBalanceState>(
        listenWhen: (previous, current) {
          return previous.submissionStatus != current.submissionStatus;
        },
        listener: (context, state) {
          if (state.submissionStatus == RequestStatus.success &&
              state.receipt != null) {
            widget.onCompleted?.call(state.receipt!);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const AverageBalanceConditions(),
                const Spacer(),
                BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
                  buildWhen: (previous, current) {
                    return previous.step != current.step ||
                        previous.canContinue != current.canContinue ||
                        previous.submissionStatus != current.submissionStatus;
                  },
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppButton(
                        label: getAverageBalanceButtonTitle(state.step),
                        isLoading:
                            state.submissionStatus == RequestStatus.loading,
                        onPressed: state.canContinue &&
                                state.submissionStatus != RequestStatus.loading &&
                                state.submissionStatus != RequestStatus.success
                            ? () {
                                context.read<AverageBalanceCubit>().continueFlow();
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

این یک نمونهٔ **ساختار صفحه** است؛ `continueFlow` و تابع عنوان، پیشنهاد این سندند. `AverageBalanceConditions` بخش مستقل فرم است و State موردنیاز خودش را با builder می‌خواند. این نمونه پیاده‌سازی کامل صفحهٔ چندمرحله‌ای نیست.

Repository موردنیاز در GetIt تنظیم می‌شود و Cubit آن را در فیلد خودش می‌گیرد. صفحه هیچ فیلد، پارامتر یا lookup وابستگی ندارد. ورودی واقعی مثل initialDepositNumber مستقیماً به Cubit می‌رود؛ dependency-free بودن Cubit هم ساخت آن را عوض نمی‌کند. برای تنظیم mock، وابستگی محیط تست/نمونه تغییر می‌کند، نه API صفحه.

اگر صفحه controller یا lifecycle ندارد، همین ساختار در `StatelessWidget` هم صحیح است. StatefulWidget بودن، شرط فنی استفاده از Provider نیست. Agent فقط برای شبیه کردن ظاهر کد، State خالی نسازد.

### ۹.۲ ساختار نامطلوب برای این تیم

```dart
// برای صفحهٔ سادهٔ این پروژه، این لایه‌بندی اضافه نشود.
Widget build(BuildContext context) => BlocProvider(
  key: ValueKey((repository, initialDepositNumber)),
  create: (_) => AverageBalanceCubit(...)..load(),
  child: _AverageBalanceView(...),
);

class _AverageBalanceView extends StatelessWidget { ... }
```

این الگو ذاتاً خطای Flutter نیست. مخالفت این قرارداد با wrapper خصوصی اضافه، پراکندگی خواندن صفحه و reset ضمنی با Key است. آن را «Provider خراب» یا «علت ساخت مجدد Cubit در هر build» معرفی نکن.

### ۹.۳ مالک Cubit، Provider است

در `BlocProvider(create: ...)`، Provider مالک instance و بستن آن است. در `BlocProvider.value`، instance موجود عرضه می‌شود و Provider آن را خودکار نمی‌بندد. رفتار lazy ساخت نیز در API توضیح داده شده است. [مرجع رسمی BlocProvider](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocProvider-class.html)

قواعد پروژه:

- Cubit جدید مستقیماً داخل BlocProvider.create خود صفحه/فلوی واقعی ساخته شود؛ constructor و اکشن اولیه در همان callback دیده شوند.
- GetIt فقط Repository، Service/API، DAO یا UseCase واقعی را ثبت کند؛ ثبت یا دریافت Cubit/Bloc با هیچ lifetime مجاز نیست.
- وابستگی در فیلد Cubit دریافت شود؛ نه در UI/Router و نه از پارامتر سازندهٔ Cubit، صفحه یا route.
- GoRouter فقط مقصد را انتخاب کند؛ Provider مخصوص صفحه در خود صفحه باشد.
- `_create`، `_createCubit`، `_buildCubit` یا factory تولیدی مخفی‌کنندهٔ ساخت ممنوع‌اند. بلوک inline برای زمان‌بندی واقعی layout مجاز است، ولی ساخت مستقیم همان‌جا می‌ماند.
- مراحل مشترک فلو همان یک نمونه را بخوانند. Cubit دوباره در initState، builder یا listener ساخته نشود.
- Provider.create مالک close است؛ Cubit قرض‌گرفته‌شده با value دستی بسته نشود.
- value فقط برای instance موجود است؛ `value: Cubit()` ممنوع است.
- context.read از context زیر Provider باشد؛ `bloc: _cubit` وقتی Provider صحیح وجود دارد اضافه نشود.
- تست، ثبت وابستگی را پیش از ساخت یا mount کنترل و پس از اجرا reset کند؛ API تولیدی برای تزریق Repository در تست گسترش پیدا نکند.

### ۹.۴ rebuild عادی با ورود تازه به flow فرق دارد

بازسازی ویجت با همان type و جایگاه و identityِ عنصر Provider، به‌خودی‌خود Cubit را دوباره نمی‌سازد. تغییر Key یا حذف subtree می‌تواند instance قبلی را از بین ببرد؛ reset را با آن پنهان نکن.

برای ورود جدید به سرویس، route جدید و scope تازه کافی است. تعویض runtime وابستگی فقط در نیاز واقعیِ جداگانهٔ مجاز و در مرز DI/فلو بررسی شود؛ ورودی Repository به صفحه اضافه نشود؛ `didUpdateWidget` عمومی و `changeRepository` برای همهٔ صفحات به‌صورت پیش‌فرض ساخته نشوند. اگر ورود جدید یا تغییر account در همان scope باید داده را reset کند، رفتار باید صریح، قابل‌تست و با action مشخص باشد.

### ۹.۵ context زیر Provider

این اشتباه رایج ممنوع است:

```dart
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => AuthCubit(...),
    child: AppButton(
      onPressed: () {
        // context متعلق به بالای Provider است.
        context.read<AuthCubit>().requestOtp();
      },
    ),
  );
}
```

contextِ callbackِ `BlocBuilder` و `BlocListener` زیر Provider قرار می‌گیرد؛ از همان استفاده کن. اگر action در یک بخش ثابت خارج از builder است، `Builder` فقط برای گرفتن context صحیح مجاز است:

```dart
return BlocProvider(
  create: (_) => AuthCubit(...),
  child: Builder(
    builder: (context) {
      return Scaffold(
        body: AppButton(
          label: S.current.dashboardRetry,
          onPressed: () {
            context.read<AuthCubit>().requestOtp();
          },
        ),
      );
    },
  ),
);
```

این کاربرد `Builder` نیاز context دارد؛ جایگزین همهٔ `BlocBuilder`ها یا wrapper تزئینی نیست.

## ۱۰. استفادهٔ مستقیم از State در UI

### ۱۰.۱ مطلوب

```dart
AppButton(
  label: S.current.issuanceSubmit,
  isLoading: state.submissionStatus == RequestStatus.loading,
  onPressed: state.canSubmit
      ? () {
          context.read<ChangeCardDepositCubit>().submit();
        }
      : null,
),
```

```dart
AppTextField(
  value: state.phoneNumber,
  errorText: state.isPhoneNumberError
      ? S.current.authPhoneInvalid
      : null,
  onChanged: (value) {
    context.read<AuthCubit>().updatePhoneNumber(value);
  },
),
```

`authPhoneInvalid` در این مثال نام پیشنهادی ترجمه است؛ در پیاده‌سازی واقعی باید کلید موجود/مصوب ARB استفاده شود.

### ۱۰.۲ ممنوع: aliasسازی برای فیلدهای State

```dart
builder: (context, state) {
  final loading = state.submissionStatus == RequestStatus.loading;
  final form = state.draft;
  final cards = state.visibleCards;
  final canSubmit = state.canSubmit;
  final buttonState = FormButtonViewModel(...);

  return AppButton(
    isLoading: loading,
    onPressed: canSubmit ? ... : null,
  );
}
```

وقتی expression ساده است، مستقیم بنویس. وقتی تصمیم تجاری طولانی است، آن را در Cubit محاسبه کن. وقتی انتخاب متن نمایشی طولانی است، تابع نام‌دار UI استفاده کن. ساخت متغیر محلی راه پیش‌فرض هیچ‌کدام نیست.

### ۱۰.۳ متغیر محلی مطلقاً ممنوع نیست

موارد زیر مجازند:

- `screenSize` برای محدودیت چیدمان، اگر واقعاً مصرف شود؛
- نتیجهٔ `await showModalBottomSheet` در callback؛
- payload یا result درخواست در Cubit؛
- snapshot برای مقابله با stale response؛
- متغیر محلی محاسبه در تابع نمایشی نام‌دار؛
- object عملیاتی مانند controller با مالک lifecycle.

در builder، `final cubit = context.read<MyCubit>()` خطای فنی نیست، اما در سبک پیشنهادی تیم، actionها به‌صورت مستقیم `context.read<MyCubit>().action()` نوشته می‌شوند. aliasهای متعدد برای State و Cubit ساخته نشوند.

### ۱۰.۴ داخل builder از همان `state` بخوان

```dart
// مطلوب
selected: state.category == category,
```

```dart
// نامطلوب: ترکیب snapshot نمایشی با وضعیت زندهٔ instance
selected: context.read<CardFeaturesCubit>().state.category == category,
```

`context.read` برای صدا زدن action است، نه subscription نمایشی. خواندن `cubit.state` در callbackِ پس از action وقتی مقدار تازه لازم است مجاز است؛ این تفاوت در بخش lifecycle توضیح داده شده است.

## ۱۱. buildWhen و listenWhen

### ۱۱.۱ قاعدهٔ پایه

- هر Listener باید `listenWhen` مرتبط با side effect خودش داشته باشد.
- هر builder در فرم‌های دارای چند عملیات یا timer باید `buildWhen` مشخص داشته باشد.
- predicate باید همهٔ فیلدهای مصرف‌شده توسط همان subtree را پوشش دهد.
- مقایسه‌ها را با `previous` و `current` بنویس؛ نام‌های `a/b` یا `s1/s2` پیش‌فرض تیم نباشند.
- predicate را به یک تابع عمومی ناشناس پنهان نکن.

`buildWhen` فیلتر تغییر State برای rebuild است و guard رفتار تجاری یا تضمین «این builder هرگز اجرا نمی‌شود» نیست. guard درخواست در Cubit لازم است. [مرجع رسمی BlocBuilder](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocBuilder-class.html)

### ۱۱.۲ نمونهٔ کامل subscription دکمه

```dart
BlocBuilder<AuthCubit, AuthState>(
  buildWhen: (previous, current) {
    return previous.loginStatus != current.loginStatus ||
        previous.canSubmitLogin != current.canSubmitLogin;
  },
  builder: (context, state) {
    return AppButton(
      label: S.current.issuanceSubmit,
      isLoading: state.loginStatus == RequestStatus.loading,
      onPressed: state.canSubmitLogin &&
              state.loginStatus != RequestStatus.loading &&
              state.loginStatus != RequestStatus.success
          ? () {
              context.read<AuthCubit>().submitLogin();
            }
          : null,
    );
  },
),
```

این builder به tick تایمر حساس نیست، مگر tick باعث تغییر `canSubmitLogin` شود. همین رفتار برای انقضای OTP لازم است.

### ۱۱.۳ نمونهٔ Listener خطا و موفقیت

```dart
BlocListener<AuthCubit, AuthState>(
  listenWhen: (previous, current) {
    return previous.loginStatus != current.loginStatus;
  },
  listener: (context, state) {
    if (state.loginStatus == RequestStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.dashboardLoadError),
        ),
      );
    }

    if (state.loginStatus == RequestStatus.success) {
      onAuthenticated?.call();
    }
  },
  child: ...,
),
```

Listener برای navigation، dialog و پیام مناسب است و به initial state در لحظهٔ اتصال callback نمی‌دهد؛ برای یک state از پیش موجود، طراحی جدا لازم است. [مرجع رسمی BlocListener](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocListener-class.html)

برای دو failure پیاپی، action باید چرخهٔ `failure → loading → failure` داشته باشد. اگر طراحی خاصی بدون تغییر status رویداد جدید تولید می‌کند، فقط مقایسهٔ status کافی نیست؛ شناسهٔ نتیجهٔ همان عملیات لازم می‌شود. event system عمومی بدون نیاز واقعی نساز.

### ۱۱.۴ MultiBlocListener برای اثرهای مستقل

```dart
MultiBlocListener(
  listeners: [
    BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return previous.otpRequestStatus != current.otpRequestStatus;
      },
      listener: (context, state) {
        if (state.otpRequestStatus == RequestStatus.failure) {
          // نمایش پیامِ failure همین عملیات.
        }
      },
    ),
    BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return previous.loginStatus != current.loginStatus;
      },
      listener: (context, state) {
        if (state.loginStatus == RequestStatus.success) {
          onAuthenticated?.call();
        }
      },
    ),
  ],
  child: ...,
),
```

برای یک اثر ساده، یک Listener کافی است. MultiBlocListener صرفاً برای شبیه کردن ظاهر نمونه اضافه نشود. Listener خالی یا placeholder در کد نهایی ممنوع است.

### ۱۱.۵ اشتباه خطرناک buildWhen

```dart
// ناقص
buildWhen: (previous, current) {
  return previous.status != current.status;
},
builder: (context, state) {
  return Text('${state.remainingSeconds}');
},
```

این subtree مقدار زمان را می‌خواند ولی predicate به آن حساس نیست. نتیجه می‌تواند UI عقب‌مانده باشد. predicate درست باید `remainingSeconds` را مقایسه کند.

اگر `buildWhen` به ۱۵–۲۰ فیلد نیاز دارد، اول مرز subtree را بررسی کن. برای کوتاه کردن آن، State را به record یا object دیگری تبدیل نکن. اگر همان بخش بزرگ واقعاً همهٔ State را لازم دارد، یک builder معمولی با توضیح نیاز همهٔ تغییرها بهتر از predicate ناقص است.

### ۱۱.۶ انتخاب Builder، Listener و Consumer بر اساس مسئولیت

- فقط نمایش State: BlocBuilder.
- فقط اجرای اثر Flutter: BlocListener.
- نمایش و اثر در همان بخش، مثل دکمهٔ loading همراه با بستن شیت پس از موفقیت: BlocConsumer.
- چند اثر مستقل: MultiBlocListener؛ این widget Cubit جدید نمی‌سازد و قالب اجباری همهٔ صفحه‌ها نیست.

switch چندحالتهٔ effect و listener async مفصل باید متد نام‌دار widget/State باشند و با `listener: _handleEffect` ارجاع داده شوند. listenWhen دقیق کنار ارجاع بماند. متد فقط اثر ازپیش‌تعیین‌شدهٔ Flutter را اجرا و نتیجهٔ خام را به Cubit برمی‌گرداند؛ eligibility، request و تصمیم جریان در آن ممنوع‌اند.

نبود buildWhen یا listener inline در نمونهٔ مرجع، قواعد فعلی را لغو نمی‌کند. status می‌تواند نتیجهٔ عملیات را مشخص کند؛ اثرهای تکراری با status یکسان در صورت نیاز شناسهٔ قابل‌اعتماد می‌خواهند. سازوکار درست موجود حذف و چارچوب effect عمومی صرفاً برای تقلید نمونه ساخته نشود.

## ۱۲. مرز subscription و انتقال State به فرزند

دو مدل روشن مجاز است؛ ترکیب بی‌دلیل آن‌ها ممنوع است.

**قاعدهٔ اصلی محل builder:** ابتدا بخش واقعاً وابسته به State را مشخص کن. builder دور همان مسئولیت معنادار قرار بگیرد؛ «تا جای ممکن پایین» به معنی یک builder برای تک‌تک Text، Icon و input نیست. اگر فقط لیست تغییر می‌کند، header و footer ثابت را در subscription همان لیست قرار نده. اگر چند input یا کنترل مرتبط با هم تغییر می‌کنند، یک builder برای همان فرم کافی است. وقتی builderهای خرد زیاد و پراکنده می‌شوند، builder در سطح بالاتر قابل‌قبول است و دلیلش حفظ خوانایی است.

| وضعیت صفحه | انتخاب مطلوب | برداشت ممنوع |
|---|---|---|
| فقط لیست تغییر می‌کند | builder داخل Expanded و دور لیست/وضعیت بارگذاری همان لیست | builder دور کل صفحه صرفاً از روی عادت |
| دو یا چند فیلد مرتبط یک فرم | یک builder دور همان فرم با buildWhen مناسب | builder اختصاصی اجباری برای هر input و متن خطا |
| timer پرتکرار و فرم با آپدیت مستقل | جداکردن subscription timer در همان بخش معنادار | استخراج چند فایل فقط برای هر عدد و آیکون timer |
| چند بخش هم‌زمان داده‌های مشترک را می‌خوانند و builderها زیاد شده‌اند | یک builder بالاتر و خواندن مستقیم State | اصرار به خردکردن برای کمینه‌کردن تعداد rebuild به هر قیمت |

buildWhen برای خوانایی و فیلتر تغییرها استفاده می‌شود؛ تضمین مطلق اینکه بخش ثابت هیچ‌وقت rebuild نمی‌شود نیست. هدف، جلوگیری از subscription بی‌دلیل به تغییرهای flow است، نه جنگ با هر rebuild طبیعی Flutter.

### ۱۲.۱ بخش مستقل، builder خودش را دارد

والد State را برای همین بخش نمی‌خواند:

```dart
Column(
  children: [
    const LoginFormWidget(),
    const OtpWidget(),
  ],
),
```

`LoginFormWidget` می‌تواند builder مرتبط با phone/nationalId داشته باشد و `OtpWidget` builder مرتبط با OTP و timer. این همان مدل آشنای نمونهٔ صاحب پروژه است.

### ۱۲.۲ والد State را می‌خواند، فرزند آن را مصرف می‌کند

```dart
BlocBuilder<CardIssuanceCubit, CardIssuanceState>(
  buildWhen: (previous, current) {
    return previous.draft != current.draft ||
        previous.deposit != current.deposit ||
        previous.totalRial != current.totalRial;
  },
  builder: (context, state) {
    return IssuanceSummaryWidget(state: state);
  },
),
```

```dart
// widgets/issuance_summary_widget.dart
class IssuanceSummaryWidget extends StatelessWidget {
  const IssuanceSummaryWidget({
    super.key,
    required this.state,
  });

  final CardIssuanceState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(state.deposit?.number ?? ''),
        Text(CurrencyFormatter.format(state.totalRial)),
      ],
    );
  }
}
```

`CurrencyFormatter.format` در API فعلی پکیج وجود دارد و مقدار را برای نمایش قالب‌بندی می‌کند؛ محاسبهٔ مبلغ در Cubit انجام شده است. برای ویجت مخصوص همان فلو، دریافت State کامل مجاز است. primitive پکیج `avp_ui` نباید به State اپ وابسته شود؛ primitive فقط داده و callback عمومی می‌گیرد.

### ۱۲.۳ nesting لازم با nesting تکراری فرق دارد

یک builder والد که فقط `step` را برای انتخاب فرم می‌خواند و یک builder در فرم فرزند که ورودی‌های همان فرم را می‌خواند، ممکن است لازم باشد. این دو subscription مسئولیت متفاوت دارند.

اگر والد همهٔ دادهٔ فرزند را می‌خواند و به فرزند می‌دهد، فرزند دوباره برای همان داده subscription نسازد.

`BlocSelector` در کتابخانه معتبر است، اما سبک پیش‌فرض این تیم `BlocBuilder + buildWhen` است. Agent نباید بدون نیاز، tuple/record selector، چند field projection یا یک ساختار موازی برای State ایجاد کند. در این قرارداد، selector فقط با نیاز مشخص و دلیل قابل‌توضیح استفاده می‌شود.

### ۱۲.۴ مثال: فقط لیست به State وابسته است

```dart
// این بخش زیر BlocProvider صفحه قرار دارد.
Column(
  children: [
    Text(S.current.dashboardCardsList),
    const SizedBox(height: 16),
    Expanded(
      child: BlocBuilder<CardFeaturesCubit, CardFeaturesState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.visibleCards != current.visibleCards;
        },
        builder: (context, state) {
          if (state.status == RequestStatus.initial ||
              state.status == RequestStatus.loading) {
            return Center(child: Text(S.current.dashboardLoading));
          }

          if (state.status == RequestStatus.failure) {
            return Center(
              child: AppButton(
                label: S.current.dashboardRetry,
                onPressed: () {
                  context.read<CardFeaturesCubit>().load();
                },
              ),
            );
          }

          return ListView.builder(
            itemCount: state.visibleCards.length,
            itemBuilder: (context, index) {
              return AppCardsList(
                cardNumber: state.visibleCards[index].number,
                linkedDeposit: state.visibleCards[index].linkedDeposit,
              );
            },
          );
        },
      ),
    ),
    const SizedBox(height: 16),
    Text(S.current.cardFeatureDetails),
  ],
),
```

این مثال فقط مرز subscription را نشان می‌دهد؛ صفحهٔ واقعی empty/no-results و اکشن‌های ردیف خودش را حفظ می‌کند. برای عنوان و متن ثابت نمونه، builder جدید ساخته نشده است.

### ۱۲.۵ مثال: یک فرم مرتبط، یک builder

```dart
BlocBuilder<AuthCubit, AuthState>(
  buildWhen: (previous, current) {
    return previous.phoneNumber != current.phoneNumber ||
        previous.nationalId != current.nationalId ||
        previous.isPhoneNumberError != current.isPhoneNumberError ||
        previous.isNationalIdError != current.isNationalIdError;
  },
  builder: (context, state) {
    return Column(
      children: [
        AppTextField(
          value: state.phoneNumber,
          hintText: S.current.loginPhoneHint,
          normalizeDigits: true,
          maxLength: 11,
          errorText: state.isPhoneNumberError ? S.current.authInvalidPhone : null,
          onChanged: (value) {
            context.read<AuthCubit>().updatePhoneNumber(value);
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          value: state.nationalId,
          hintText: S.current.loginNationalIdHint,
          normalizeDigits: true,
          maxLength: 10,
          errorText:
              state.isNationalIdError ? S.current.authInvalidNationalId : null,
          onChanged: (value) {
            context.read<AuthCubit>().updateNationalId(value);
          },
        ),
      ],
    );
  },
),
```

این مثال خلاف قرارداد نیست، حتی اگر تغییر phone باعث بازسازی هر دو input شود. دو فیلد مسئولیت یک فرم منسجم دارند. برای نمونهٔ کامل، focus-loss validation و وضعیت enabled نیز متناسب با همان flow به فیلدها و buildWhen اضافه می‌شوند.

## ۱۳. سبک نوشتن درخت UI

### ۱۳.۰ اصول الزام‌آور استایل UI

کلاس و widget با PascalCase، فایل Dart با snake_case و متد با camelCase نام‌گذاری شود. constructor از super.key و در صورت امکان const استفاده کند. callback با نوع معلوم، VoidCallback، ValueChanged<T> یا نوع تابع صریح داشته باشد؛ Function?/dynamic راه فرار از اعلام نوع نیست. nullability باید معنی واقعی داشته باشد.

از typography، رنگ معنایی، asset و API عمومی avp_ui خود پروژه استفاده شود؛ کپی نام کامپوننت، palette، فونت یا ظاهر پروژهٔ مرجع ممنوع است. ترجمه با S.current انجام شود. چیدمان صریح Row/Column/Padding/SizedBox و شرط‌های کوچک نمایشی خوانا بمانند؛ ابزار خاص باید نیاز واقعی layout/lifecycle را حل کند.

widget استخراج‌شدهٔ بزرگ یا واقعاً قابل‌استفادهٔ مجدد، عمومی و در فایل خودش باشد و مرز subscription/resource را حفظ کند. عنوان، فاصله یا آیکون یک‌بارمصرف به فایل جدا شکسته نشوند. تعداد خطِ نمونه حد دقیق تازه ایجاد نمی‌کند؛ مسئولیت و استفادهٔ واقعی تعیین‌کننده‌اند. build نباید load، submit، analytics یا تصمیم جریان اجرا کند.

### ۱۳.۱ block body برای build

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<AuthCubit, AuthState>(
    buildWhen: (previous, current) {
      return previous.step != current.step;
    },
    builder: (context, state) {
      return Column(
        children: [
          const SizedBox(height: 20),
          if (state.step == AuthStep.identity)
            const LoginFormWidget(),
          if (state.step == AuthStep.otp)
            const OtpWidget(),
        ],
      );
    },
  );
}
```

برای درخت قابل‌توجه، `Widget build(...) =>` ننویس. هدف این است که structure، predicate و `return` بدون فشرده‌سازی قابل‌خواندن باشند. متد سادهٔ value helper می‌تواند کوتاه باشد.

### ۱۳.۲ ابزارهای آشنا پیش‌فرض‌اند

از `Column`، `Row`، `Padding`، `SizedBox`، `Expanded`، `SafeArea`، `ListView` و ویجت‌های موجود `avp_ui` استفاده کن.

`Builder`، `LayoutBuilder`، `PopScope`، `AnimatedPadding` و سایر ابزارها ممنوع نیستند؛ باید مسئلهٔ مشخصی حل کنند. برای فرم ساده، `CustomScrollView + slivers`، چند wrapper و یک layout framework داخلی نساز.

Agent باید برای ابزار غیرمعمول بتواند در یک جمله نیازش را بیان کند: «LayoutBuilder لازم است چون تعداد ستون‌های کارت بر اساس عرض تغییر می‌کند.» جملهٔ «تمیزتر است» دلیل کافی نیست.

### ۱۳.۳ شرط کوچک inline بماند

```dart
Text(
  state.isPhoneNumberError
      ? S.current.authPhoneInvalid
      : S.current.authPhoneHint,
),
```

اگر شرط چندمرحله‌ای است، تابع نام‌دار بنویس. ternary سه‌لایه و `switch` بلند داخل آرگومان ویجت پیش‌فرض نباشد.

### ۱۳.۴ فشرده‌سازی و frameworkسازی ممنوع

```dart
// نامطلوب برای فرم با فیلدهای مشخص
FieldRenderer(
  schema: [
    ('phone', state.phoneNumber, updatePhone, ...),
    ('national', state.nationalId, updateNational, ...),
  ],
),
```

**برای فرم ثابت، نوشتن inputهای صریح مطابق نمونه‌های صاحب پروژه الزامی است، نه صرفاً ترجیح.** تعداد پنج یا ده فیلد هم مجوز آرایه‌کردن فرم نیست. label، hint، value، error و callback هر فیلد کنار همان فیلد دیده شوند. نیاز آتی Agent/assistant به schema، دلیل تبدیل فرم‌های فعلی به renderer عمومی نیست.

الگوهای زیر برای فرم ثابت ممنوع‌اند:

```dart
final labels = [...];
final hints = [...];
final values = [...];

for (var index = 0; index < labels.length; index++)
  AppTextField(
    value: values[index],
    onChanged: (value) {
      switch (index) {
        // انتخاب action بر اساس شمارهٔ فیلد
      }
    },
  );
```

استفاده از Map، record، function list، schema یا metadata به‌جای سه آرایه، همان الگو را مجاز نمی‌کند. این حکم دربارهٔ **تعریف فیلدهای فرم ثابت** است؛ نمایش فهرست واقعی کارت‌ها، سپرده‌ها یا گزینه‌های یک انتخابگر با builder/loop مجاز است. ساخت فرم واقعاً پویا از قرارداد مستقل سرور، خارج از این قاعده و نیازمند task و قرارداد صریح است؛ Agent حق ندارد ثابت‌بودن فرم را خودش به پویا تغییر دهد.

UI هنگام تغییر یک فیلد، فقط همان مقدار تازه را به action مشخص Cubit بدهد. بازسازی مدل کامل گیرنده از چند controller یا فرستادن مقدار سایر فیلدها از snapshot UI، پیش‌فرض نیست:

```dart
// مطلوب
onChanged: (value) {
  context.read<CardIssuanceCubit>().updateRecipientName(value);
},

// نامطلوب برای تغییر یک فیلد ثابت
onChanged: (value) {
  context.read<CardIssuanceCubit>().setRecipient(
    DeliveryPerson(
      name: value,
      nationalId: nationalIdController.text,
      mobile: mobileController.text,
    ),
  );
},
```

به‌روزرسانی مدل داخلی از مقدار تازه و State موجود، در Cubit انجام می‌شود. دریافت یک object کامل از نتیجهٔ sheet یا API، مورد دیگری است و این ممنوعیت آن را حذف نمی‌کند.

### ۱۳.۵ closure کوتاه و action روشن

```dart
onChanged: (value) {
  context.read<AuthCubit>().updateNationalId(value);
},
```

`onChanged: cubit.updateNationalId` از نظر فنی معتبر است، اما فرم صریح بالا سبک پایهٔ تیم است. callback بلندِ شامل محاسبه، چند درخواست و navigation را داخل آرگومان ننویس؛ محاسبه را به Cubit و هماهنگی UI را به متدی با نام رفتاری مشخص منتقل کن.

## ۱۴. شکستن صفحه و عمومی بودن ویجت‌ها

### ۱۴.۱ قاعدهٔ اندازه

| اندازهٔ تقریبی فایل UI دست‌نویس | اقدام |
|---|---|
| کمتر از ۱۵۰ خط | عموماً همان فایل را نگه دار؛ extraction فقط برای reuse واقعی |
| حدود ۱۵۰–۲۰۰ خط | مسئولیت‌ها را بررسی کن؛ یک یا دو بخش معنادار می‌توانند استخراج شوند |
| بیشتر از حدود ۲۰۰ خط | تقسیم به فرم، لیست، summary یا sheet را جدی انجام بده |
| بخش منسجم کمی بزرگ‌تر از ۲۰۰ خط | با دلیل روشن قابل‌قبول است؛ برای عدد، ساختار را خراب نکن |

تعداد خط ماشینی معیار قطعی کیفیت نیست. import، خطوط خالی و formatting را دست‌کاری نکن تا فایل ظاهراً کوچک شود. کد generated در این شمارش نیست.

### ۱۴.۲ دو دلیل اصلی extraction

1. صفحه/بخش بزرگ شده و یک مسئولیت مشخص را می‌توان جدا خواند.
2. همان بخش در همین فلو بیش از یک بار استفاده می‌شود.

مالکیت controller پیچیده یا آپدیت پرتکرار timer نیز می‌تواند دلیل مشخصی باشد، ولی نباید بهانهٔ تولید ده ویجت برای صفحهٔ ساده شود. یک builder کوچک به‌تنهایی دلیل extraction نیست.

### ۱۴.۳ کلاس عمومی در فایل مستقل

```dart
// widgets/card_features_content.dart
class CardFeaturesContent extends StatelessWidget {
  const CardFeaturesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardFeaturesCubit, CardFeaturesState>(
      // buildWhen و UI مرتبط با همان بخش
      ...
    );
  }
}
```

```dart
// در صفحه
Expanded(
  child: CardFeaturesContent(),
),
```

نام کلاس با `_` شروع نمی‌شود. `class _CardFeaturesContent` و `class _AverageBalanceView` برای ویجت استخراج‌شده ممنوع‌اند. کلاس `_AuthScreenState extends State<AuthScreen>` private می‌ماند؛ آن implementation داخلی StatefulWidget است، نه widget استخراج‌شده.

### ۱۴.۴ ممنوع: تابع برگشت‌دهندهٔ درخت UI

```dart
Widget _content(BuildContext context, MyState state) { ... }
Widget _body(BuildContext context, MyState state) { ... }
Widget _footer(BuildContext context, MyState state) { ... }
```

در سبک این تیم، اگر لازم است این بخش جدا شود، widget عمومی در فایل خودش بساز. اگر آن‌قدر کوچک است که widget نمی‌خواهد، inline نگه دار. تابع `String getButtonTitle(...)` با تابع `Widget _footer(...)` یکسان نیست.

این یک قاعدهٔ خوانایی تیم است؛ به‌اشتباه ادعا نکن که هر تابع برگشت‌دهندهٔ Widget ذاتاً باعث خرابی performance در Flutter است.

### ۱۴.۵ چیزهایی که نباید استخراج شوند

- `TitleWidget` فقط برای یک Text یک‌بارمصرف؛
- `GapWidget` برای SizedBox؛
- `IconWrapper` بدون رفتار و reuse؛
- `ScreenBodyView` فقط برای context زیر Provider؛
- یک widget برای هر branch کوتاه `if`؛
- یک widget برای هر property مربوط به یک input.

### ۱۴.۶ نمونهٔ تقسیم منطقی LoginLocalAuth

برای مثال بزرگ صاحب پروژه، تقسیم قابل‌قبول می‌تواند این باشد:

```text
screens/login_local_auth_screen.dart       Provider، Listener، چیدمان کلی
widgets/local_password_form.dart           توضیح، نمایش وضعیت PIN، keyboard
widgets/local_password_action.dart         دکمه و subscription مربوط به آن
```

اگر دکمه فقط چند خط است، فایل سوم لازم نیست. برای چهار نقطهٔ PIN، یک template/ویجت تکرارشونده فقط اگر reuse واقعی دارد یا فرم را به‌وضوح ساده می‌کند؛ چهار نقطه را به چهار فایل تقسیم نکن.

## ۱۵. شرط‌های نمایشی و توابع عنوان و متن

### ۱۵.۱ عنوان پنج مرحله در یک تابع نام‌دار

این یک تابع UI است؛ فقط متن ترجمه‌شده برمی‌گرداند:

```dart
String getFinancialCertificateStepTitle(
  FinancialCertificateStep step,
) {
  switch (step) {
    case FinancialCertificateStep.conditions:
      return S.current.certificateConditionsStep;
    case FinancialCertificateStep.recipient:
      return S.current.financialRecipientStep;
    case FinancialCertificateStep.latinIdentity:
      return S.current.financialLatinStep;
    case FinancialCertificateStep.delivery:
      return S.current.financialDeliveryStep;
    case FinancialCertificateStep.confirmation:
      return S.current.issuanceConfirmTitle;
  }
}
```

مصرف مستقیم:

```dart
AppStepper(
  currentStep: state.stepNumber,
  totalSteps: 5,
  title: getFinancialCertificateStepTitle(state.step),
  supportingText: getFinancialCertificateNextTitle(state.step),
),
```

`stepNumber` در این نمونه field پیشنهادی State است که Cubit همراه `step` به‌روز می‌کند. محاسبهٔ ترتیب مرحله به متن ترجمه‌شده گره نخورد.

### ۱۵.۲ متن دکمه با نام مشخص

```dart
String getAverageBalanceButtonTitle(
  AverageBalanceStep step,
) {
  switch (step) {
    case AverageBalanceStep.conditions:
    case AverageBalanceStep.delivery:
      return S.current.issuanceNext;
    case AverageBalanceStep.confirmation:
      return S.current.issuanceSubmit;
  }
}
```

اگر پنج مرحله متن متفاوت دارند، پنج case روشن بنویس. اگر فقط دو حالت کوچک وجود دارد، ternary ساده هم مجاز است. تابع صرفاً برای طولانی‌تر کردن دو حالت واضح لازم نیست.

### ۱۵.۳ چرا این تابع در Cubit نیست؟

Cubit مرحله را تعیین می‌کند؛ زبان و کلمهٔ نمایشی را UI تعیین می‌کند. موارد زیر ممنوع‌اند:

```dart
// ممنوع در Cubit
String getButtonTitle(BuildContext context) { ... }

emit(state.copyWith(buttonTitle: 'ثبت درخواست'));

emit(state.copyWith(buttonTitle: S.current.submit));
```

اگر تصمیم متن پیچیده و متکی به چند قانون تجاری باشد، Cubit یک enum معنی‌دار مانند `primaryAction` یا `nextStep` در State نگه می‌دارد و تابع UI آن را ترجمه می‌کند. enumِ عنوان فقط برای حذف یک ternary ساخته نشود.

### ۱۵.۴ محل تابع نمایشی

- اگر فقط همین صفحه مصرف می‌کند، تابع value می‌تواند در همان فایل بماند.
- اگر چند widget همین flow مصرف می‌کنند، در فایل مشخص `..._labels.dart` قرار بگیرد.
- helper نمایشی نباید `emit`، API call یا navigation انجام دهد.
- نام تابع معنی را بیان کند: `getIssuanceButtonTitle` از `labelFor` روشن‌تر است.
- `List<String> titles` و دسترسی `titles[state.step.index]` برای چند مرحلهٔ مشخص، الگوی پیش‌فرض نیست؛ enum را صریح map کن.

### ۱۵.۵ حذف منطق تجاری از ظاهر

```dart
// ممنوع: تصمیم هزینه و eligibility در builder
final walletSufficient = state.catalog!.walletBalanceRial >=
    state.fees.fold<int>(0, (sum, fee) => sum + fee.amountRial);
```

```dart
// مطلوب: Cubit نتیجه را محاسبه کرده است.
if (!state.walletSufficient)
  Text(S.current.issuanceWalletInsufficient),
```

اگر کلید ترجمهٔ مثال موجود نیست، نام مصوب ARB اضافه یا جایگزین می‌شود؛ نمایش code فنی به کاربر مجاز نیست.

### ۱۵.۶ متن ترجمه‌شده، شناسهٔ تصمیم نیست

**الزامی:** label فقط برای نمایش است. شرطِ رفتار، انتخاب، فاصله یا پایان لیست بر اساس متن ترجمه‌شده ممنوع است.

```dart
// ممنوع: معنای «آخرین قانون» به متن ترجمه گره خورده است.
if (ruleTitle != S.current.passwordDateRule)
  const SizedBox(height: 12),
```

در یک مجموعهٔ ثابت کوچک، بخش‌ها و فاصله‌ها را صریح بنویس. در لیست واقعی پویا، تصمیم با شناسهٔ معنی‌دار یا موقعیت همان لیست انجام شود، نه برابری ترجمه. تغییر زبان یا یکسان‌شدن متن دو گزینه نباید رفتار را تغییر دهد.

## ۱۶. فیلتر، انتخاب و لیست‌ها

### ۱۶.۱ جستجو در Cubit، نمایش مستقیم در UI

```dart
void updateSearch(String value) {
  emit(
    state.copyWith(
      query: value,
      visibleCards: filterCards(
        cards: state.cards,
        query: value,
        category: state.category,
        filter: state.filter,
      ),
    ),
  );
}
```

`filterCards` تابع مشخص Cubit است؛ filter تجاری را در `itemBuilder` یا helper UI انجام نده. همین تابع از load و تغییر category و اعمال filter هم با ورودی تازه فراخوانی می‌شود.

### ۱۶.۲ لیست خوانا، بدون alias

```dart
ListView.separated(
  itemCount: state.visibleCards.length,
  separatorBuilder: (context, index) {
    return const SizedBox(height: 10);
  },
  itemBuilder: (context, index) {
    return AppCardsList(
      cardNumber: state.visibleCards[index].number,
      linkedDeposit: state.visibleCards[index].linkedDeposit,
      cardNumberLabel: S.current.cardFeatureNumber,
      linkedDepositLabel: S.current.cardFeatureDeposit,
      onMoreTap: () {
        showCardActionsSheet(context, state.visibleCards[index]);
      },
    );
  },
),
```

برای stateful row که identity آن در reorder لازم است، Key ممکن است توجیه داشته باشد؛ برای ردیف سادهٔ نمایش، فقط برای finder تست key نگذار.

### ۱۶.۳ فیلتر موقت و نهایی

```dart
void openFilter() {
  emit(state.copyWith(draftFilter: state.filter));
}

void updateDraftStatus(CardStatus? value) {
  if (state.draftFilter == null) return;
  emit(
    state.copyWith(
      draftFilter: CardFilter(
        status: value,
        deposit: state.draftFilter!.deposit,
      ),
    ),
  );
}

void updateDraftDeposit(String? value) {
  if (state.draftFilter == null) return;
  emit(
    state.copyWith(
      draftFilter: CardFilter(
        status: state.draftFilter!.status,
        deposit: value,
      ),
    ),
  );
}

void applyFilter() {
  if (state.draftFilter == null) return;

  emit(
    state.copyWith(
      filter: state.draftFilter!,
      visibleCards: filterCards(
        cards: state.cards,
        query: state.query,
        category: state.category,
        filter: state.draftFilter!,
      ),
      draftFilter: null,
      selectedCard: null,
    ),
  );
}

void cancelFilter() {
  emit(state.copyWith(draftFilter: null));
}
```

sheet فقط انتخاب را به این actionها می‌دهد. ساخت لیست فیلترشده و تعیین اینکه Apply چه کاری کند در Cubit است. نتیجهٔ بستن sheet با tap بیرون یا Back نیز باید cancel شود؛ رفتار فقط برای دکمهٔ Cancel پیاده نشود.

### ۱۶.۴ انتخاب category و footer

در نمونهٔ فعلی، `footerAction` داخل builder از category محاسبه شده است. چون این انتخاب تعیین می‌کند کدام سرویس در دسترس است، پیشنهاد این قرارداد آن است که تصمیم در Cubit باشد:

```dart
void selectCategory(CardCategory category) {
  emit(
    state.copyWith(
      category: category,
      selectedCard: null,
      visibleCards: filterCards(
        cards: state.cards,
        query: state.query,
        category: category,
        filter: state.filter,
      ),
      footerAction: getCategoryFooterAction(category),
    ),
  );
}
```

enumِ action اگر برای رفتار تجاری/State استفاده می‌شود، در Domain یا فایل مستقل feature قرار می‌گیرد؛ Cubit نباید برای آن فایل widget را import کند.

UI:

```dart
if (state.footerAction != null)
  AppButton(
    label: getCardActionTitle(state.footerAction!),
    onPressed: () {
      // dispatch مسیر از طریق قرارداد ناوبری موجود پروژه.
      openCardAction(context, state.footerAction!);
    },
  ),
```

مسیر concreteِ navigation در UI/router می‌ماند. Cubit نباید `context.push` یا `ScaffoldMessenger` صدا بزند. adapter فقط طبق بخش ۳.۵ و برای اجرای Flutter با مقصد ازپیش‌تعیین‌شده مجاز است؛ تصمیم action/category یا ساخت درخواست در آن ممنوع است.

### ۱۶.۵ راهکار پیشنهادی انتخابگر نوع‌دار — توصیه، نه الزام مهاجرت

**وضعیت تصمیم:** صاحب پروژه توضیح و راهکار مناسب خواسته است؛ این قسمت پیشنهاد مشخص را ثبت می‌کند و مجوز تغییر خودکار انتخابگرهای موجود نیست. ممنوعیت عمومی String، enum جدید برای تمام selectها یا بازنویسی fieldErrors از آن استنتاج نشود.

مسئلهٔ فعلی: نوع وضعیت کارت `CardStatus` است، ولی انتخابگر آن را به String تبدیل می‌کند و سپس با `byName` به enum برمی‌گرداند:

```dart
AppSelect<String>(
  value: state.draftFilter?.status?.name ?? 'all',
  // ...
);

// سپس در callback:
CardStatus.values.byName(value);
```

**راهکار پیشنهادی:** مقدار انتخابگر همان نوع معنی‌دار باشد؛ label جداگانه ترجمه شود. برای انتخابی که گزینهٔ «همه» ندارد، `AppSelect<CardStatus>` کافی است. برای فیلتر شامل «همه»، API فعلی `AppSelect` مقدار برگشتی null را لغو انتخاب می‌داند؛ بنابراین null را به‌عنوان گزینهٔ «همه» نفرست. enum مشخص همان فیلتر مناسب است:

```dart
// تعریف flow؛ نام مثال است، نه دستور افزودن آن به همهٔ features.
enum CardStatusFilter {
  all,
  active,
  blocked,
  expired,
}

// field در State پیشنهادی همین فیلتر
@Default(CardStatusFilter.all) CardStatusFilter draftStatusFilter,
```

```dart
AppSelect<CardStatusFilter>(
  value: state.draftStatusFilter,
  label: S.current.cardFeatureCardStatus,
  options: [
    AppSelectOption(
      value: CardStatusFilter.all,
      label: S.current.cardFeatureAll,
    ),
    AppSelectOption(
      value: CardStatusFilter.active,
      label: S.current.cardFeatureActive,
    ),
    AppSelectOption(
      value: CardStatusFilter.blocked,
      label: S.current.cardFeatureBlocked,
    ),
    AppSelectOption(
      value: CardStatusFilter.expired,
      label: S.current.cardFeatureExpired,
    ),
  ],
  onChanged: (value) {
    context.read<CardFeaturesCubit>().updateDraftStatusFilter(value);
  },
),
```

```dart
// action مشخص؛ بدون parsing رشته و بدون ساخت State در helper
void updateDraftStatusFilter(CardStatusFilter value) {
  emit(state.copyWith(draftStatusFilter: value));
}
```

تبدیل «همه» به نبود شرط و اعمال فیلتر، هنگام Apply در Cubit انجام می‌شود. در پیاده‌سازی واقعی، بازبودن draft و guardهای flow نیز حفظ می‌شوند. این مثال فقط value/callback نوع‌دار را نشان می‌دهد، نه تمام جریان فیلتر.

فهرست `options` بالاتر آرایهٔ ممنوعِ فرم نیست؛ گزینه‌های **یک انتخابگر** است و هر گزینه label و value روشن دارد. ID کارت یا سپرده که واقعاً String است، String باقی می‌ماند. از این پیشنهاد، wrapper عمومی، mapper عمومی یا enum برای داده‌های ذاتاً رشته‌ای ساخته نشود.

## ۱۷. دیالوگ و Bottom Sheet

### ۱۷.۱ الگوی مجاز: تابع باز کردن + کلاس عمومی

تابع فقط sheet را باز می‌کند و widget عمومی را تحویل می‌دهد؛ درخت بزرگ UI داخل callback مخفی نمی‌شود.

```dart
// widgets/card_details_sheet.dart
Future<void> showCardDetailsSheet(
  BuildContext context,
  ListedCard card,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    builder: (sheetContext) {
      return CardDetailsSheet(card: card);
    },
  );
}

class CardDetailsSheet extends StatelessWidget {
  const CardDetailsSheet({
    super.key,
    required this.card,
  });

  final ListedCard card;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardDetailRow(
              title: S.current.cardFeatureNumber,
              value: card.number,
              valueDirection: TextDirection.ltr,
            ),
            CardDetailRow(
              title: S.current.cardFeatureIban,
              value: card.iban,
              valueDirection: TextDirection.ltr,
            ),
            CardDetailRow(
              title: S.current.cardFeatureDeposit,
              value: card.linkedDeposit,
              valueDirection: TextDirection.ltr,
            ),
            CardDetailRow(
              title: S.current.cardFeatureStatus,
              value: getCardStatusTitle(card.status),
              valueDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: S.current.backLabel,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

`CardDetailRow` چهار بار مصرف دارد، بنابراین extraction آن واقعی است. اگر `avp_ui` ردیف استاندارد معادل دارد، همان را مصرف کن؛ این نمونه مجوز کپی primitive پکیج نیست. در صورت نبود معادل، برای ردیف مخصوص جزئیات کارت می‌توان کلاس عمومی زیر را در فایل خودش داشت:

```dart
// widgets/card_detail_row.dart
class CardDetailRow extends StatelessWidget {
  const CardDetailRow({
    super.key,
    required this.title,
    required this.value,
    required this.valueDirection,
  });

  final String title;
  final String value;
  final TextDirection valueDirection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textDirection: valueDirection,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
```

ترجمهٔ عنوان ردیف و تعیین directionِ شماره/شبا، منطق نمایشی UI است. لازم نیست همهٔ این داده‌ها به Cubit منتقل شوند. اگر نمایش sheet فقط snapshot جزئیات است و هیچ interaction تجاری ندارد، Cubit جدا برای sheet هم لازم نیست.

### ۱۷.۲ موارد ممنوع در sheet نمونهٔ فعلی

```dart
final rows = [
  (S.current.cardFeatureNumber, card.number),
  (S.current.cardFeatureIban, card.iban),
];

Text(rows[index].$1);
Text(rows[index].$2);
textDirection: index < 3 ? TextDirection.ltr : TextDirection.rtl,
```

برای چند ردیف مشخص، نام title/value و direction صریح خواناتر است. تعیین نوع فیلد با index شکننده است: با جابه‌جایی ردیف‌ها معنای direction عوض می‌شود.

record در Dart ذاتاً ممنوع نیست؛ استفاده از `$1/$2` و شرط index برای قالب‌بندی فرم‌های ثابت، در این قرارداد پذیرفته نیست. اگر تعداد ردیف‌ها واقعاً پویا است، مدل دارای فیلد نام‌دار و مسئولیت مشخص استفاده شود.

### ۱۷.۳ sheet مشترک با Cubit صفحه

modal معمولاً در route مجزا ساخته می‌شود؛ دسترسی به Provider محلی صفحه را بدون بررسی فرض نکن. برای ادامهٔ همان state، instance موجود را منتقل کن:

```dart
Future<void> showCardFilterSheet(BuildContext context) async {
  final cubit = context.read<CardFeaturesCubit>();
  cubit.openFilter();

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: const CardFilterSheet(),
        );
      },
    );
  } finally {
    if (!cubit.isClosed) cubit.cancelFilter();
  }
}
```

در `CardFilterSheet`، دکمهٔ Apply ابتدا `applyFilter` را صدا می‌زند و سپس modal را می‌بندد. `cancelFilter` باید در صورت `draftFilter == null` بدون اثر اضافی برگردد؛ بعد از Apply، finally نباید filter ثبت‌شده را پاک کند.

این کاربرد `.value` حالت صریحاً مجازِ اشتراک instance موجود است؛ sheet نباید Cubit صفحه را close کند.

### ۱۷.۴ dialog حذف: UI تأیید می‌گیرد، Cubit حذف می‌کند

```dart
Future<void> confirmAddressRemoval(
  BuildContext context,
  CertificateAddress address,
) async {
  final confirmed = await showAddressDeleteSheet(context, address);

  if (!context.mounted || confirmed != true) return;

  context.read<AverageBalanceCubit>().removeAddress();
}
```

اسم تابع، رفتار را مشخص می‌کند. هیچ filter لیست آدرس یا محاسبهٔ `canContinue` در این callback انجام نمی‌شود. خود dialog در widget عمومی مستقل تعریف می‌شود. اگر Cubit حذف را با ID انجام می‌دهد، ID ثابت همان snapshot تأییدشده منتقل شود.

### ۱۷.۵ از helper عمومی بدون نیاز دوری کن

`_sheet<T>(context, panel).then((_) {})` برای پنهان کردن چند خط مشترک، پیش‌فرض نیست. اگر API مشترک sheet در `avp_ui` وجود دارد، همان را استفاده کن؛ وگرنه تابع feature با نام روشن و builder کوتاه مناسب است.

`then((_) {})` فقط برای دور انداختن result به کار نرود؛ return type و await را صریح بنویس. keyboard inset، امکان scroll و RTL در همهٔ sheetهای دارای ورودی رعایت شوند.

## ۱۸. کلیدها و تست‌های UI

### ۱۸.۱ پیش‌فرض: Key اضافه نکن

```dart
// مطلوب
AppChips(
  label: getCardCategoryTitle(category),
  selected: state.category == category,
  onPressed: () {
    context.read<CardFeaturesCubit>().selectCategory(category);
  },
),
```

```dart
// بدون نیاز رفتاری مشخص، ممنوع
key: Key('card_category_${category.name}'),
key: const Key('continue_button'),
key: const ValueKey('screen_body'),
key: UniqueKey(),
```

`super.key` در constructor لازم و مجاز است. ممنوعیت، ساخت دستی key در محل مصرف بدون دلیل است.

### ۱۸.۲ موارد دارای دلیل واقعی

| نیاز | امکان استفاده |
|---|---|
| identity ردیف stateful هنگام جابه‌جایی | `ValueKey(item.id)` |
| ReorderableList | کلید پایدار ردیف |
| دسترسی واقعاً لازم به FormState | `GlobalKey<FormState>` |
| AnimatedList | کلید state همان لیست |
| اندازه‌گیری/ensureVisible برای مورد مشخص | GlobalKey با دلیل و lifecycle معلوم |
| reset عمدی یک subtree stateful | فقط اگر reset صریح مسئله را حل نکند؛ دلیل نزدیک کد |

صرف ListView بودن، داشتن label یا خواستن finder راحت، دلیل کافی نیست. `UniqueKey` در build می‌تواند state را بی‌دلیل از بین ببرد.

### ۱۸.۳ تست باید تا حد امکان رفتار عمومی را پیدا کند

برای تست، از label، text، widget type، tooltip و semantics واقعی استفاده کن. semantics برای دسترس‌پذیری طراحی می‌شود؛ شناسهٔ تصنعی تست را در semanticLabel نگذار.

اگر کنترل تکراری و واقعاً مبهم است، ابتدا finderِ محدود به parent مناسب بساز. Key آزمایشی آخرین انتخاب با دلیل مشخص است، نه پیش‌فرض هر button. برای حذف keyهای فعلی نیز باید تست‌های وابسته در refactor مجاز، همراه تغییر بازبینی شوند؛ الان چیزی حذف نشده است.

## ۱۹. controller، focus، timer و lifecycle

### ۱۹.۱ کنترل‌شده با value؛ وقتی controller لازم نیست

API فعلی `AppTextField`، `value` و `onFocusLost` دارد. برای ورودی ساده:

```dart
AppTextField(
  value: state.phoneNumber,
  normalizeDigits: true,
  keyboardType: TextInputType.phone,
  maxLength: 11,
  errorText: state.isPhoneNumberError
      ? S.current.authPhoneInvalid
      : null,
  onChanged: (value) {
    context.read<AuthCubit>().updatePhoneNumber(value);
  },
  onFocusLost: () {
    context.read<AuthCubit>().validatePhoneNumber();
  },
),
```

`controller` و `value` را هم‌زمان نده؛ API فعلی این پکیج این حالت را نمی‌پذیرد.

### ۱۹.۲ اگر controller لازم است، StatefulWidget مالک آن باشد

```dart
class OtpWidget extends StatefulWidget {
  const OtpWidget({super.key});

  @override
  State<OtpWidget> createState() {
    return _OtpWidgetState();
  }
}

class _OtpWidgetState extends State<OtpWidget> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        return previous.isOtpError != current.isOtpError ||
            previous.otpRequestStatus != current.otpRequestStatus ||
            previous.loginStatus != current.loginStatus;
      },
      builder: (context, state) {
        return AppTextField(
          controller: _otpController,
          focusNode: _otpFocusNode,
          normalizeDigits: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          enabled: state.otpRequestStatus != RequestStatus.loading &&
              state.loginStatus != RequestStatus.loading &&
              state.loginStatus != RequestStatus.success,
          obscureText: true,
          enableIMEPersonalizedLearning: false,
          errorText: state.isOtpError
              ? S.current.authOtpInvalid
              : null,
          onChanged: (value) {
            context.read<AuthCubit>().updateOtp(value);
          },
        );
      },
    );
  }
}
```

این نمونه فقط مالکیت controller را نشان می‌دهد. اگر Cubit مقدار OTP را reset یا autofill می‌کند، controller نیز باید با یک listener مربوط به تغییر `otp` هماهنگ شود؛ یا به‌جای controller از `value` استفاده کن. controller نباید منبع حقیقت تجاری دوم باشد. مقدار را در build به controller تحمیل نکن، چون انتخاب متن و cursor را مختل می‌کند.

### ۱۹.۳ ممنوع: منبع UI در Cubit یا static

```dart
// ممنوع
static final FocusNode otpFocusNode = FocusNode();

class AuthCubit extends Cubit<AuthState> {
  final controller = TextEditingController();
  BuildContext? context;
}
```

State هم `TextEditingController`، `FocusNode`، `ScrollController`، Widget و BuildContext نگه نمی‌دارد.

### ۱۹.۴ snapshot قدیمی در onChanged

```dart
// اشتباه: state این closure ممکن است متعلق به پیش از action باشد.
onChanged: (value) {
  context.read<AuthCubit>().updatePhoneNumber(value);

  if (!state.isPhoneNumberError) {
    // تصمیم با snapshot قبلی گرفته شده است.
    _nationalCodeFocusNode.requestFocus();
  }
},
```

در صورت نیاز واقعی به جابه‌جایی focus بر مبنای اعتبار ورودی، Cubit باید نتیجهٔ مشخص مثل `isPhoneNumberValid` را همراه ورودی ذخیره کند؛ callback پس از action هم‌زمان، مقدار تازه را می‌خواند:

```dart
onChanged: (value) {
  context.read<AuthCubit>().updatePhoneNumber(value);

  if (value.length == 11 &&
      context.read<AuthCubit>().state.isPhoneNumberValid) {
    _nationalCodeFocusNode.requestFocus();
  }
},
```

یا Listener با مقایسهٔ تغییر همان field این کار را انجام می‌دهد. `isPhoneNumberError == false` الزاماً به معنی معتبر بودن نیست؛ ممکن است هنوز focus-loss validation انجام نشده باشد. fieldِ اعتبار فقط وقتی این نیاز وجود دارد افزوده شود.

### ۱۹.۵ timer در Cubit، نمایش در UI

با فرض اینکه `AuthCubit` دارای `_timer` و `_otpDeadline` است و OTP چهاررقمی است:

```dart
DateTime? _otpDeadline;

void startOtpTimer(int seconds) {
  stopOtpTimer();
  _otpDeadline = DateTime.now().add(Duration(seconds: seconds));

  emit(
    state.copyWith(
      remainingSeconds: seconds,
      canSubmitLogin: CodeValidator.isValid(state.otp, length: 4) &&
          seconds > 0,
    ),
  );

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      if (isClosed) {
        stopOtpTimer();
        return;
      }

      final milliseconds = _otpDeadline!
          .difference(DateTime.now())
          .inMilliseconds;
      final remainingSeconds = milliseconds <= 0
          ? 0
          : (milliseconds / 1000).ceil();

      if (remainingSeconds == 0) stopOtpTimer();

      emit(
        state.copyWith(
          remainingSeconds: remainingSeconds,
          canSubmitLogin:
              CodeValidator.isValid(state.otp, length: 4) &&
              remainingSeconds > 0,
        ),
      );
    },
  );
}

void stopOtpTimer() {
  _timer?.cancel();
  _timer = null;
}

@override
Future<void> close() {
  stopOtpTimer();
  return super.close();
}
```

deadline باعث می‌شود پس از تأخیر tick یا background زمان با تعداد callback اشتباه نشود. این countdown نمایشی است؛ اعتبار و مهلت واقعی OTP را سرور تعیین می‌کند. اگر refreshِ فوری روی resumed لازم است، lifecycle UI زمان تازه را از action Cubit درخواست می‌کند؛ MethodChannel یا BuildContext به Cubit منتقل نمی‌شود.

UI فقط زمان را قالب‌بندی می‌کند:

```dart
String getOtpRemainingTime(int remainingSeconds) {
  final minutes = remainingSeconds ~/ 60;
  final seconds = remainingSeconds % 60;

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
```

```dart
BlocBuilder<AuthCubit, AuthState>(
  buildWhen: (previous, current) {
    return previous.remainingSeconds != current.remainingSeconds;
  },
  builder: (context, state) {
    return Text(
      CurrencyFormatter.toPersianDigits(
        getOtpRemainingTime(state.remainingSeconds),
      ),
    );
  },
),
```

تقسیم ثانیه برای **نمایش متن** در تابع UI مجاز است؛ eligibilityِ ارسال OTP در Cubit می‌ماند. به‌جای `00:60`، زمان در قالب دقیقه و ثانیه صحیح نمایش داده شود.

### ۱۹.۶ بعد از await در UI

هر callback که پس از await از context یا Stateِ ویجت استفاده می‌کند، `context.mounted` یا `mounted` را بررسی کند. تأخیر مصنوعی `Future.delayed(300ms)` برای focus پیش‌فرض نباشد؛ focus بعد از نمایش واقعی بخش و با guard lifecycle انجام شود.

پاک کردن controller به معنی فراخوانی خودکار `onChanged` نیست. reset تجاری را Cubit انجام می‌دهد و نمایش از State همگام می‌شود.

### ۱۹.۷ ممنوعیت setState، شامل وضعیت صرفاً نمایشی

**دستور صریح صاحب پروژه:** استفاده از `setState` برای وضعیت جریان یا نمایش ممنوع است؛ حتی نمایش/پنهان‌کردن رمز، باز/بسته‌شدن summary یا یک انتخاب ظاهری باید field در Freezed State و action در Cubit داشته باشد. «این فقط UI state است» استثنا نیست.

```dart
// State
@Default(false) bool isPasswordVisible,
@Default(false) bool isConfirmationPasswordVisible,
@Default(false) bool isSummaryExpanded,
```

```dart
// Cubit
void togglePasswordVisibility() {
  emit(
    state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ),
  );
}

void toggleConfirmationPasswordVisibility() {
  emit(
    state.copyWith(
      isConfirmationPasswordVisible: !state.isConfirmationPasswordVisible,
    ),
  );
}

void updateSummaryExpanded(bool value) {
  emit(state.copyWith(isSummaryExpanded: value));
}
```

```dart
BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
  buildWhen: (previous, current) {
    return previous.password != current.password ||
        previous.isPasswordVisible != current.isPasswordVisible;
  },
  builder: (context, state) {
    return AppTextField(
      value: state.password,
      obscureText: !state.isPasswordVisible,
      normalizeDigits: true,
      enableIMEPersonalizedLearning: false,
      onChanged: (value) {
        context.read<SecondPasswordCubit>().passwordChanged(value);
      },
      suffixIcon: AppButton(
        variant: AppButtonVariant.text,
        label: state.isPasswordVisible
            ? S.current.passwordHide
            : S.current.passwordShow,
        onPressed: () {
          context.read<SecondPasswordCubit>().togglePasswordVisibility();
        },
      ),
    );
  },
),
```

fieldهای visibility در مثال، افزوده‌های قرارداد هدف‌اند و فعلاً به State واقعی اضافه نشده‌اند. در flow واقعی، enabled/loading/validation همان فیلد نیز در UI و buildWhen مرتبط حفظ می‌شود.

حفظ controller و FocusNode در StatefulWidget مجاز است؛ ساخت چنین ویجتی به معنی مجوز `setState` نیست. Listener فوکوس، event را به action مشخص مانند `validatePasswordConfirmation()` می‌دهد؛ نتیجهٔ mismatch و زمان نمایش خطا در State هستند.

```dart
// ممنوع
bool showPassword = false;
bool mismatch = false;

setState(() => showPassword = !showPassword);
setState(() => mismatch = password.text != confirmation.text);
```

اگر اجرای نیاز با قرارداد و APIهای موجود واقعاً ممکن نیست، تعارض دقیق گزارش و تغییر وابسته پیاده‌سازی نشود. Agent اختیار ساخت استثنا ندارد؛ فقط اصلاح صریح همان قانون توسط صاحب پروژه آن را تغییر می‌دهد. کوتاه‌تر بودن کد، عادت Flutter و «صرفاً نمایشی بودن» معافیت نیستند. State موازی با ValueNotifier یا notifier تازه هم راه دورزدن ممنوعیت نیست. استفادهٔ معمول از controller/animation برای منبع و lifecycle واقعی Flutter موضوع جداگانه‌ای است.

### ۱۹.۸ lifecycle محل هماهنگی منطق فلو نیست

initState، didChangeDependencies، didUpdateWidget، پرچم محلی scheduled و post-frame نباید تصمیم قابل‌انتقال را پنهان کنند. didChangeDependencies فقط برای وابستگی inherited واقعی است؛ انتخاب دسته و شروع جریان به‌صورت پیش‌فرض آنجا انجام نمی‌شود.

post-frame فقط برای نیاز واقعی attachment/layout مانند scroll extent یا اتصال listener استفاده شود. Cubit قصد reveal و هدف منطقی را تعیین می‌کند؛ UI زمان‌بندی و mounted/hasClients و اندازهٔ واقعی را مدیریت می‌کند. پرچم تکراری و lifecycle تشریفاتی ممنوع است.

## ۲۰. جریان چندمرحله‌ای و Back

### ۲۰.۱ یک action برای دکمهٔ اصلی

به‌جای تکرار تعیین submit/next در چند callback UI:

```dart
Future<void> continueFlow() async {
  if (!state.canContinue ||
      state.submissionStatus == RequestStatus.loading ||
      state.submissionStatus == RequestStatus.success) {
    return;
  }

  if (state.step == IssuanceStep.confirmation) {
    await submit();
    return;
  }

  nextStep();
}
```

UI:

```dart
onPressed: state.canContinue
    ? () {
        context.read<CardIssuanceCubit>().continueFlow();
      }
    : null,
```

تعیین مرحلهٔ بعد با Cubit است؛ انتخاب فرم مرحلهٔ فعلی در UI می‌ماند. builderِ انتخاب فرم فقط `step` را می‌خواند؛ فرم‌های مستقل فیلدهای خودشان را می‌خوانند.

### ۲۰.۲ back داخل فرم و خروج از route

- Cubit تصمیم می‌گیرد آیا یک مرحله به عقب می‌رود.
- UI تصمیم navigation و نمایش تأیید خروج را اجرا می‌کند.
- Back سخت‌افزاری و دکمهٔ داخل صفحه باید رفتار یکسان داشته باشند.
- هنگام submission، خروج و ویرایش مطابق قرارداد جریان قفل باشند.
- اولین مرحلهٔ فرمِ دارای ورودیِ از دست‌رونده، تأیید خروج دارد.
- بعد از رسید موفق، خروج از flow با `go` به مقصد مصوب انجام شود؛ کاربر نباید به فرم قابل‌ارسال مجدد برگردد.

نمونهٔ متد UI مجاز:

```dart
Future<void> handleFlowBack(BuildContext context) async {
  if (context.read<CardIssuanceCubit>().state.submissionStatus ==
      RequestStatus.loading) {
    return;
  }

  if (context.read<CardIssuanceCubit>().back()) return;

  final confirmed = await showExitFlowConfirmation(context);

  if (!context.mounted || confirmed != true) return;

  NavigationActions.back(context);
}
```

این مثال مسیر back برای فرمِ پیش از موفقیت است؛ صفحهٔ رسید مسیر خروج خودش را دارد. وقتی `PopScope.canPop` خروج را مسدود کرده، اجرای خروج تأییدشده باید یک مسیر صریح برای آزاد کردن pop یا `go` داشته باشد؛ `pop` دوباره به scope مسدودشده فرستاده نشود. این رفتار در تغییر واقعی باید با Back سیستم تست شود.

متد UI بالا side effect هماهنگ می‌کند؛ برخلاف `_body` درخت Widget تولید نمی‌کند و محاسبهٔ مرحله انجام نمی‌دهد.

**الزام back:** دکمهٔ داخل صفحه اکشن Cubit مثل requestBack را صدا بزند. Cubit قفل ارسال، عقب‌رفتن مرحله یا درخواست تأیید/خروج را تعیین کند. UI اثر را اجرا، پس از await context.mounted را بررسی و نتیجهٔ تأیید را به Cubit برگرداند. زنجیرهٔ back → تأیید → خروج با خواندن status در helper/listener UI ممنوع است.

وقتی PopScope خروج را بسته، اثر خروج باید مسیر اجرایی واقعی برای رفع محدودیت یا مقصد go مصوب داشته باشد؛ pop دوباره به scope مسدود ارسال نشود. Back سیستم و دکمهٔ صفحه هر دو بررسی شوند.

### ۲۰.۳ پارامتر شروع و reset

`initialDepositNumber`، category اولیه و tracking ID ورودی route هستند. Provider آن‌ها را به Cubit می‌دهد. Cubit انتخاب را حل می‌کند و state اولیهٔ معنی‌دار را می‌سازد. UI شمارهٔ اولیه را در build بین لیست‌ها جستجو نمی‌کند.

برای flow قابل‌ادامه، state از سرور بازیابی می‌شود؛ این سند سبک UI را تعیین می‌کند و جای قرارداد `resume` معماری را نمی‌گیرد.

## ۲۱. طراحی مشترک، RTL و ترجمه

### ۲۱.۱ استفاده از avp_ui

قبل از ساخت هر component:

1. [راهنمای integration](main-app-integration-guide.md) را بررسی کن.
2. public exportهای `package:avp_ui/avp_ui.dart` را ببین.
3. component موجود را استفاده کن.
4. فقط دادهٔ feature، callback و validation را از اپ بده.
5. اگر API کافی نیست، نیاز variant/component را مشخص کن؛ extension پکیج فقط در دامنهٔ مجاز task انجام شود.

قاعدهٔ «ویجت عمومی در فایل مستقل» مجوز کپی AppButton، AppTextField، checkbox یا theme پکیج در اپ نیست. wrapper حول یک component موجود فقط با رفتار یا reuse مشخص ساخته می‌شود.

### ۲۱.۲ ابزارهای Material

layoutهایی مانند Row/Column/Padding/SafeArea و Text در ترکیب صفحه استفاده می‌شوند. کنترل‌های خام مانند TextField، Checkbox و ElevatedButton وقتی معادل `avp_ui` وجود دارد استفاده نمی‌شوند. این تفکیک مانع آن است که Agent برای هر Text یک component ناموجود از پروژهٔ دیگری اختراع کند.

برای dialog و feedback نیز اول API موجود پکیج بررسی شود. `ScaffoldMessenger` در مثال‌های این سند برای نشان دادن محل side effect است؛ اگر feedback عمومی مصوب در پکیج موجود است، همان API استفاده می‌شود.

### ۲۱.۳ typography و رنگ

```dart
Text(
  S.current.cardFeatureDetails,
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    color: context.colors.textPrimary,
  ),
),
```

- `TextStyle(fontSize: ...)` و رنگ hex جدید در feature ننویس.
- از semantic tokenهای فعلی استفاده کن.
- font اصلی پکیج دوباره در اپ ثبت نشود.
- برای variation مشخص Figma، از نقش typography موجود با `copyWith` استفاده شود.
- `const` برای constructor و SizedBox ثابت رعایت شود.
- فاصله‌های طراحی از tokenها یا الگوی موجود همان صفحه گرفته شوند؛ Figma با عددهای سلیقه‌ای Agent تغییر نکند.

### ۲۱.۴ RTL و ارقام

- چیدمان اپ RTL است؛ آن را در route و overlay حفظ کن.
- `EdgeInsetsDirectional`، `AlignmentDirectional` و `TextAlign.start/end` پیش‌فرض‌اند.
- شماره کارت، شبا و شناسه‌هایی که باید Latin/LTR باشند، direction خود را صریح دارند.
- input عددی Persian/Arabic را به Latin نرمال کن؛ validator خالص ورودی Latin می‌گیرد.
- مقدار مبلغ در State عدد است؛ نمایش مبلغ با formatter پکیج انجام می‌شود.
- تاریخ Domain/Data میلادی و UTC است؛ نمایش شمسی در UI انجام می‌شود.
- status code، tracking ID و label ترجمه‌شده با یکدیگر جابه‌جا نشوند.

### ۲۱.۵ analytics در build ننویس

نمونه‌های قدیمی Skill، ثبت event در build را پیشنهاد می‌کنند؛ این سند آن را برای رویداد یک‌بارمصرف صفحه نمی‌پذیرد. build تکرار می‌شود. event صفحه باید در lifecycle/observer مشخص و event کلیک در callback همان کلیک ثبت شود. زیرساخت analytics جدید فقط برای این سند ساخته نمی‌شود.

### ۲۱.۶ قرارداد مصوب دسترسی به ترجمه: S.current

**تصمیم صاحب پروژه در ۲۰۲۶/۱۰/۱۴:** متن UI با `S.current.mobileNumber` و به‌طور کلی `S.current.<key>` خوانده شود. کلاس `S` از ARB با `intl_utils` تولید می‌شود؛ یک facade دست‌نویس برای کوتاه کردن `AppLocalizations` ساخته نمی‌شود.

```dart
import 'package:pishkhan_mobile/generated/l10n.dart';

Text(S.current.mobileNumber);
Text(S.current.otpSentMessage(state.maskedPhone));
```

نام `mobileNumber` نمونهٔ سبک مطلوب است؛ اضافه کردن یا تغییر کلید واقعی باید با فایل ARB هماهنگ باشد. نمونه‌های ترجمهٔ این سند به قرارداد هدف به‌روز شده‌اند.

- استفادهٔ مستقیم الزامی است؛ `final l10n = ...` یا `final strings = S.current` در UI نساز.
- تابع عنوان چندمرحله‌ای، مرحله را می‌گیرد و از `S.current` متن را برمی‌گرداند؛ صرفاً برای ترجمه BuildContext نگیرد.
- Cubit و Domain به `S.current` دسترسی ندارند؛ کد خطا، enum و داده تولید می‌کنند.
- S.current پس از load شدن delegate مصرف می‌شود؛ خود این دسترسی subscription تغییر زبان نیست.
- تغییر runtime زبان، اگر جداگانه درخواست شود، باید locale اپ و rebuild بخش‌های لازم را هماهنگ کند.
- تولید ترجمه، تنظیم delegateها و تست localeها مطابق [بخش ۱۴.۱ معماری](architecture-smart-virtual-counter-v2-en.md#141-localization) است.

**این تغییر صرفاً مستنداتی است.** کد فعلی هنوز `gen-l10n`، `AppLocalizations` و `context.l10n` دارد؛ dependency، ARB و Dart تغییر نکرده‌اند. اجرای مهاجرت به task مستقل نیاز دارد.

## ۲۲. بررسی مثال‌های فعلی پروژه

این بخش diagnosis سبکی است؛ همهٔ موارد به معنی bug اجرایی نیستند.

### ۲۲.۱ AverageBalanceScreen و _AverageBalanceView

**مسئلهٔ خوانایی:** صفحه عمدتاً wrapperِ Provider است و UI در کلاس private دیگری قرار دارد. Keyِ شامل repository و seed، reset را ضمنی می‌کند.

**قاعدهٔ پیشنهادی:** Provider، Listener و Scaffold در buildِ همان صفحه؛ بخش‌های واقعی مثل Conditions و Delivery به widget عمومی مستقل تبدیل شوند. `initialState` عمومی صفحه فقط وقتی نیاز واقعی قراردادی دارد باقی بماند؛ برای هر صفحه به‌صورت خودکار اضافه نشود.

**نکتهٔ فنی:** ساخت فعلی معتبر است و rebuild معمولی Provider را حتماً reset نمی‌کند. لازم نیست برای اصلاح سبک، lifecycle درست موجود را از بین ببریم.

### ۲۲.۲ CardListScreen با Cubit دستی

**مسئلهٔ خوانایی:** صفحه هم `_cubit` می‌سازد و close می‌کند، هم `bloc:` صریح می‌دهد و هم UI بزرگ و متدهای برگشت‌دهندهٔ Widget دارد.

**قاعدهٔ پیشنهادی:** Provider مالک Cubit شود؛ controller و focus و scroll متعلق به Stateِ ویجت بمانند. بخش بزرگ لیست در `CardFeaturesContent` عمومی استخراج شود؛ `_content` حذف شود. تغییر category و query، لیست آماده را در State به‌روز کنند.

`didUpdateWidget` و `changeRepository` فقط با نیاز تعویض runtime نگه داشته شوند؛ Agent به‌صورت خودکار برای تست یا احتمال آینده آن‌ها را اضافه نکند.

### ۲۲.۳ _revealCategory و chip keys

**قاعده:** Cubit قصد reveal و هدف دسته را منتشر می‌کند؛ UI فقط scroll API و layout واقعی و guard منابع را اجرا می‌کند. controller و BuildContext وارد Cubit/State نمی‌شوند. GlobalKey صرفاً برای هر chip یا تست ساخته نشود؛ نیاز رفتاری واقعی لازم است. شرط magic index جای مفهوم رفتار را نگیرد.

### ۲۲.۴ _request و _more

**قاعدهٔ الزام‌آور:** ساخت request، انتخاب action/service و تفسیر نتیجهٔ شیت در Cubit است. UI فقط اثر آماده را اجرا و نتیجهٔ خام را به اکشن برمی‌گرداند. `_request` یا `_more` یا `handleCardAction` با تصمیم قابل‌انتقال، حتی کوتاه، ممنوع است. لانچر فقط در نقش adapter محدود Flutter طبق بخش ۳.۵ مجاز است؛ تغییر نام درخت تصمیم آن را مجاز نمی‌کند.

### ۲۲.۵ footerAction در builder

**مسئله:** ruleِ سرویس قابل‌شروع در محل چیدمان قرار گرفته است.

**قاعده:** اگر یک تصمیم رفتاری است، action در State ذخیره شود؛ عنوان آن با تابع نمایشی UI ترجمه شود. اگر فقط variation ظاهری است، helper UI کافی است. Agent تفاوت این دو را صریح بررسی کند.

### ۲۲.۶ rows با record و $1/$2

**مسئله:** عنوان و مقدار با جایگاه شناخته می‌شوند و direction بر اساس index تغییر می‌کند.

**قاعده:** چند ردیف ثابت را با `CardDetailRow(title:, value:, valueDirection:)` صریح بنویس. برای دادهٔ واقعاً پویا، مدل دارای اسم فیلد مناسب باشد؛ UI ثابت را به schema تبدیل نکن.

### ۲۲.۷ title و next و stepNumber در builder صدور کارت

**مسئله:** انتخاب عنوان و مرحلهٔ بعد، قبل از return چند متغیر محلی تولید کرده و خواندن UI را طولانی می‌کند.

**قاعده:** ترتیب واقعی flow و stepNumber در Cubit/State؛ متن `getIssuanceStepTitle` و `getIssuanceNextTitle` در UI؛ مصرف مستقیم در AppStepper. UI برای چندمرحله‌ای بودن، array موازیِ title/progress نسازد.

### ۲۲.۸ _body و _footer در صدور کارت

**مسئله:** بخش‌های بزرگ UI پشت تابع private مخفی‌اند.

**قاعده:** اگر حجم صفحه نیاز دارد، `IssuanceContent` یا `IssuanceFooter` عمومی در فایل خودش، با Stateِ مستقیم یا subscription مستقلِ روشن. برای شاخهٔ loading کوچک، widget مستقل تازه لازم نیست.

### ۲۲.۹ _prepareState در Cubitهای فعلی

**مسئله:** یک تغییر سادهٔ فیلد ممکن است به تابع مرکزی بزرگی برود که انتخاب، هزینه، editability، request و چند boolean را هم‌زمان بازسازی می‌کند. خواننده برای فهم action مجبور است کل helper را دنبال کند.

**قاعده:** action صریح و helper خالصِ محاسبه با نام مشخص. `emit(state.copyWith(...))` در خود action نوشته شود؛ `_prepareState` و هر واسطهٔ آماده‌سازی/انتشار State، چه private و چه public، ممنوع‌اند. محاسبهٔ مشترک واقعی فقط به‌صورت مقدار خالص حفظ شود، نه State سازنده یا facade دوم رفتار.

### ۲۲.۱۰ توابع label و asset

تابع برگردانندهٔ String مانند `getCardStatusTitle` یا asset path، منطق نمایشی است و قابل‌قبول است. تابع ساخت `Widget` با لایه‌های transform و layout، با value helper یکی نیست؛ اگر مسئولیت بزرگ/تکراری دارد component مصوب لازم است، وگرنه inline بماند.

## ۲۳. خطاهای رایج و اصلاح پیشنهادی

| نامطلوب | جایگزین |
|---|---|
| `final loading = state.status == ...` | مقایسهٔ مستقیم در آرگومان |
| `final cards = state.visibleCards` | `state.visibleCards` مستقیم |
| getterِ `State.canSubmit` | field محاسبه‌شده توسط Cubit |
| `prepareState / _updateState / publishState` با مسئولیت ساخت یا انتشار State | emit و copyWith صریح داخل action؛ helper فقط برای مقدار خالص |
| `AuthRules / ViewStateMapper` برای فرم ساده | action و تابع مشخص Cubit |
| `_ScreenView` صرفاً زیر Provider | UI در همان buildِ صفحه |
| `_buildContent()` بزرگ | widget عمومی در فایل مستقل |
| component برای یک SizedBox | SizedBox inline |
| `ValueKey((repository, seed))` پیش‌فرض | scope route تازه یا reset صریحِ موردنیاز |
| `GlobalKey` برای همهٔ chipها | فقط key لازم برای رفتار واقعی |
| `rows[index].$1/$2` برای چند فیلد ثابت | propertyهای title/value مشخص |
| direction با `index < 3` | direction صریح هر نوع داده |
| انتخاب title با arrayِ enum.index | تابع عنوان با caseهای معنی‌دار |
| eligibility در onPressed | تصمیم در Cubit، UI فقط action را صدا می‌زند |
| async callback بدون mounted | guard پس از await |
| timer بدون close | cancel در close |
| controller در StatelessWidget | value کنترل‌شده یا مالک StatefulWidget |
| fieldErrors مستقل در UI و Cubit | خطا در State؛ UI فقط ترجمه می‌کند |
| خاموش بودن دکمه به‌عنوان guard اصلی | guard صریح در action |
| navigator در Cubit | Listener/callback UI |
| validation code در widget | validator/UseCase و هماهنگی Cubit |
| mock داخل هر screen به‌صورت پیش‌فرض | mock در ثبت DI محیط؛ دریافت وابستگی در Cubit |
| Repository/UseCase از پارامتر صفحه یا سازندهٔ Cubit | دریافت از GetIt در فیلد Cubit |
| _createCubit یا ثبت Cubit در GetIt | ساخت مستقیم در BlocProvider.create خود صفحه/فلو |
| success جعلی برای action پیاده‌نشده | پیام عدم دسترسی یا callback صریح میزبان |
| event analytics داخل build | lifecycle/observer یا callback مناسب |
| setState برای چشم رمز، summary یا خطای فرم | field در State و action صریح Cubit |
| آرایه‌های labels/hints/values و switch(index) برای فرم ثابت | inputهای صریح مطابق نمونهٔ صاحب پروژه |
| validateField('phone') برای فرم ثابت | update/validate مشخص هر فیلد با validator مرکزی |
| مقایسهٔ متن ترجمه‌شده برای تصمیم | شناسهٔ معنی‌دار یا چیدمان صریح |
| حذف field فقط چون UI فعلی آن را نمی‌خواند | بررسی مسئولیت عملیاتی یا قرارداد سرویس آینده |
| builder اجباری برای هر Text و Icon | builder دور بخش معنادارِ متغیر؛ سطح بالاتر برای جلوگیری از پراکندگی |

برای mock، ثبت وابستگی در DI محیط مربوط تنظیم شود. Provider مستقیم Cubit را می‌سازد و خود Cubit وابستگی را در فیلد دریافت می‌کند. Repository از UI عبور نمی‌کند. این قاعده مجوز تعویض adapterهای فعلی خارج از محدودهٔ task نیست.

## ۲۴. دستور عملی Agent و چک‌لیست بازبینی

### ۲۴.۱ متن کوتاه قابل‌استفاده به‌عنوان دستور Agent

```text
برای Presentation این پروژه، تمام قرارداد UI/Cubit/State را پیش از کار بخوان.
بخش اجرای الزامی و ۲.۳ الزام‌اند؛ استثنای خودسرانه، تغییر نام الگوی ممنوع یا
استناد به Skill/مثال قدیمی مجاز نیست. ساختار State فعلی حفظ شود. با تخلف
شناخته‌شده در کد ایجادشده/تغییرکرده، کار را کامل اعلام نکن.

1. UI را با سبک آشنای تیم و build دارای block body بنویس.
2. BlocProvider(create) در صفحه/ورودی واقعی flow باشد؛ Screen/View خصوصی
   اضافه، Cubit دستی و bloc: صریح بدون نیاز نساز. constructor مستقیم و اکشن
   اولیه در create باشند؛ ثبت Cubit در GetIt و helper ساخت ممنوع است.
3. در callbackها از context زیر Provider استفاده کن.
4. State یک data class سادهٔ Freezed است؛ getter و منطق دست‌نویس ندارد.
5. UI مستقیم state.field را می‌خواند؛ alias، record projection یا ViewModel
   برای بازبسته‌بندی State نساز.
6. statusهای عملیات مستقل را جدا نگه دار و loading را مستقیم مقایسه کن.
7. تصمیم فرم، validation، فیلتر و جمع مبلغ در Cubit/Domain است.
8. emit و copyWith در خود action صریح باشند؛ هیچ prepareState، updateState،
   StateMapper یا wrapper انتشار State، حتی private، نساز. helper خالصِ bool/عدد مجاز است.
9. عنوان چندمرحله‌ای را با تابع نام‌دار UI ترجمه کن؛ BuildContext وارد Cubit نشود.
10. Listener دارای listenWhen و builder فرم دارای buildWhen مرتبط باشد.
    builder را دور بخش معنادارِ متغیر قرار بده؛ یک builder برای هر ویجت اجبار نیست.
    اگر فقط لیست تغییر می‌کند، همان لیست subscribe شود. برای چند فیلد مرتبط یا
    builderهای زیاد، builder بالاتر قابل‌قبول است.
11. صفحه را معمولاً نزدیک 150–200 خط بازبینی کن؛ فقط بخش بزرگ یا reuse واقعی
    را به widget عمومی در فایل مستقل استخراج کن. ده wrapper کوچک نساز.
12. تابع private برگشت‌دهندهٔ درخت UI و widget private استخراج‌شده ننویس.
13. Key فقط با نیاز رفتاری و دلیل نزدیک کد؛ key تزئینی/تستی پیش‌فرض ممنوع.
14. ابتدا API عمومی avp_ui را بررسی کن؛ component ناموجود اختراع نکن.
15. Controller/focus/scroll در مالک UI و timer در Cubit، با dispose/close صحیح.
16. guard ارسال تکراری، isClosed، پاسخ قدیمی و idempotency حفظ شوند.
17. بدون درخواست، refactor سراسری، تغییر package و dependency جدید انجام نده.
18. setState حتی برای وضعیت نمایشیِ رمز و summary استفاده نکن. مقدار در State
    و action در Cubit باشد. notifier موازی برای دور زدن این قاعده نساز.
    تعارض واقعی را بدون اجرای راهکار ممنوع گزارش کن؛ Agent اختیار استثنا ندارد.
19. فرم ثابت را مثل مرجع مالک صریح بنویس؛ آرایهٔ labels/values/callbacks، schema
    و switch(index) برای تعریف فیلدهای آن ممنوع‌اند. لیست دادهٔ واقعی مجاز است.
20. هر فیلد فرم action مشخص داشته باشد و validator مرکزی را صدا بزند؛ dispatch
    با نام رشته‌ای فیلد و regex/checksum تکراری نساز.
21. متن ترجمه فقط نمایش است؛ با آن رفتار یا فاصله را تعیین نکن.
22. field عملیاتی یا متعلق به قرارداد سرویس آینده را فقط به علت نبود مصرف UI حذف نکن.
    snapshot درخواست می‌تواند در State بماند؛ payload تازه نیز می‌تواند هنگام submit ساخته شود.
23. پیشنهاد انتخابگر نوع‌دار (بخش 16.5) مجوز مهاجرت نیست. مورد تطبیق دو enum با
    index هنوز باز است. callback خالی دکمه فعلاً موضوع اصلاح نیست.
24. فقط از S.current.<key> برای ترجمهٔ UI استفاده کن؛ نه alias و نه context.l10n.
25. تمام رفتار قابل‌انتقال بدون منابع Flutter در Cubit/Domain باشد؛ ساخت درخواست،
    انتخاب عملیات/footer/مقصد و تفسیر نتیجهٔ modal هم شامل این الزام هستند.
26. UI اکشن می‌فرستد؛ Cubit State و اثر نوع‌دار آماده را منتشر می‌کند؛ UI Flutter
    API را اجرا و نتیجهٔ خام را برمی‌گرداند. اثر تکراری باید قابل‌اعتماد تحویل شود.
27. lifecycle و post-frame فقط attachment/layout واقعی و guard منابع باشند؛
    didChangeDependencies تشریفاتی یا پرچم محلی جریان ساخته نشود.
28. وابستگی داده از UI عبور نکند و پارامتر constructor Cubit هم نباشد؛ فیلد Cubit
    آن را از GetIt بگیرد. Provider خود صفحه/فلو مستقیماً Cubit را بسازد؛ GoRouter
    فقط مقصد را انتخاب کند. listener چندحالته متد نام‌دار UI داشته باشد.
```

این متن خلاصهٔ قواعد الزام‌آور است، نه جایگزین سند کامل. AGENTS.md ریشه خواندن و اجرای تمام قرارداد را لازم می‌کند؛ موضوع باز هیچ قاعدهٔ مصوبی را ضعیف نمی‌کند.

### ۲۴.۲ قبل از نوشتن UI

- [ ] نیاز واقعی صفحه، ورودی route و callback خروج مشخص است.
- [ ] component موجود در `avp_ui` و app shared بررسی شده است.
- [ ] نوع State و statusهای عملیات مشخص‌اند.
- [ ] هر helper/callback پیشنهادی از دروازهٔ مالکیت بخش ۳.۵ عبور کرده است.
- [ ] روشن است چه تصمیمی در Cubit و چه نمایشی در UI است.
- [ ] برای صفحهٔ ساده، abstraction جدید طراحی نشده است.
- [ ] هیچ تغییر خارج از محدودهٔ task لازم فرض نشده است.

### ۲۴.۳ هنگام نوشتن Cubit

- [ ] وابستگی واقعی در فیلد Cubit از GetIt دریافت می‌شود؛ سازندهٔ Cubit/UI پارامتر Repository/Service/UseCase ندارد.
- [ ] هر action نام رفتاری روشن دارد.
- [ ] ساخت درخواست، تصمیم عملیات/footer/مقصد و نتیجهٔ modal متعلق به Cubit است.
- [ ] اثر آماده، داده و زمینهٔ لازم را بدون منبع Flutter دارد و تکرار آن قابل‌تحویل است.
- [ ] emitهای ورودی، خروجی‌های وابسته را هم‌زمان به‌روز می‌کنند.
- [ ] helperها نام محاسبه را بیان می‌کنند و UI از آن‌ها قانون دریافت نمی‌کند.
- [ ] helper هیچ State جدیدی نمی‌سازد و emit نمی‌کند؛ تغییرهای State در خود action دیده می‌شوند.
- [ ] اعتبارسنجی هر فیلد به سبک متد مشخص مالک است و validator مرکزی را فراخوانی می‌کند.
- [ ] status مستقل برای عملیات مستقل وجود دارد.
- [ ] submit داخل Cubit دوباره eligibility را کنترل می‌کند.
- [ ] loading قبل از await ثبت می‌شود.
- [ ] بعد از await، disposal و پاسخ قدیمی بررسی می‌شوند.
- [ ] retry همان payload، key مناسب و پایدار دارد.
- [ ] timer/subscription متعلق به Cubit در close آزاد می‌شود.
- [ ] اطلاعات حساس log یا در toString عمومی تولید نمی‌شوند.

### ۲۴.۴ هنگام نوشتن State

- [ ] فقط field، enum و factory داده دارد.
- [ ] visibility، expanded و خطای قابل‌نمایش فرم نیز از State کنترل می‌شوند.
- [ ] field آینده/عملیاتی با مسئولیت مشخص حفظ شده و field تشریفاتی تازه ساخته نشده است.
- [ ] نبود مصرف مستقیم UI به‌تنهایی دلیل حذف request یا metadata عملیات نبوده است.
- [ ] getter، BuildContext، Widget و controller ندارد.
- [ ] null فقط با معنی واقعی استفاده شده است.
- [ ] defaultها بی‌جهت nullable نیستند.
- [ ] field مشتق‌شدهٔ لازم، همهٔ actionهای وابسته را پوشش می‌دهد.
- [ ] boolean جدید فقط alias یک status نیست.
- [ ] equality و immutabilityِ مدل‌های داخل State مناسب‌اند.

### ۲۴.۵ هنگام نوشتن UI

- [ ] Provider خود صفحه/فلوی واقعی مالک create است؛ GoRouter Cubit صفحه نمی‌سازد.
- [ ] constructor و اکشن اولیه در create مستقیم دیده می‌شوند؛ helper ساخت یا دریافت Cubit از GetIt نداریم.
- [ ] Repository/Service/UseCase از UI یا سازندهٔ Cubit پاس داده نمی‌شود؛ lookup در فیلد Cubit است.
- [ ] GetIt فقط وابستگی‌ها را ثبت می‌کند؛ تست API تولیدی را برای تزریق وابستگی گسترش نمی‌دهد.
- [ ] private View wrapper و Key پیش‌فرض ندارد.
- [ ] callbackها context صحیحِ زیر Provider دارند.
- [ ] state مستقیم در آرگومان‌ها خوانده می‌شود.
- [ ] هیچ تصمیم قابل‌انتقالی در helper، callback، listener، build یا lifecycle UI نمانده است.
- [ ] listener اثر آماده را اجرا و نتیجهٔ خام modal را به Cubit می‌دهد؛ مرحلهٔ بعد را انتخاب نمی‌کند.
- [ ] listener چندحالته/async مفصل متد نام‌دار دارد و listenWhen دقیق کنار ارجاع آن است.
- [ ] هر helper باقی‌ماندهٔ UI به Flutter یا نمایش مشخص نیاز دارد؛ کوتاهی و privateبودن دلیل نیست.
- [ ] اثر اولیه بعد از اتصال/layout واقعی تحویل می‌شود؛ hook یا پرچم تکراری وجود ندارد.
- [ ] منطق هزینه، فیلتر و eligibility در builder نیست.
- [ ] عنوان‌های طولانی تابع نمایشی نام‌دار دارند.
- [ ] side effect در builder انجام نمی‌شود.
- [ ] listenWhen و buildWhen همهٔ نیازهای واقعی بخش را پوشش می‌دهند.
- [ ] nested subscription برای همان داده تکرار نشده است.
- [ ] builder دور بخش معنادارِ متغیر است؛ برای هر Text و Icon builder جدا ساخته نشده است.
- [ ] setState، boolean محلی یا notifier موازی برای وضعیت قابل‌نمایش flow ندارد.
- [ ] فرم ثابت، inputهای صریح دارد؛ آرایهٔ موازی و dispatch بر اساس index ندارد.
- [ ] متن ترجمه‌شده برای تصمیم رفتار یا چیدمان مقایسه نشده است.
- [ ] ویجت استخراج‌شده عمومی و در فایل خودش است.
- [ ] `_content/_body/_footer` با خروجی Widget ندارد.
- [ ] ابزار غیرمعمول Flutter، نیاز مشخص و قابل‌توضیح دارد.
- [ ] controller/focus/scroll مالک و dispose دارند.
- [ ] RTL، localization و typography پکیج رعایت شده‌اند.

### ۲۴.۶ بررسی رفتار هنگام refactor مجاز

وقتی تغییر واقعی کد درخواست شد، این سناریوها ارزش تست دارند:

1. تغییر ورودی، canSubmit و خطا را صحیح به‌روز می‌کند.
2. tick تایمر فقط بخش لازم را به‌روز می‌کند؛ انقضا دکمه را غیرفعال می‌کند.
3. double tap دو submission تولید نمی‌کند.
4. failure دادهٔ لازم برای retry را حفظ می‌کند.
5. پاسخ quote قدیمی انتخاب جدید را عوض نمی‌کند.
6. close شدن flow، emit دیرهنگام ندارد.
7. sheet filter با Back/بیرون بستن، draft را discard می‌کند.
8. rebuild معمولی فرم، Cubit و ورودی‌ها را reset نمی‌کند.
9. Back سیستم و Back داخل UI رفتار یکسان دارند.
10. بعد از success، فرم قابل‌ارسال دوباره در stack باقی نمی‌ماند.

برای تأیید نوشتن یک متغیر یا محل Padding، تستی که implementation را تکرار می‌کند ننویس. برای تغییر رفتاری، تست مرتبط را اجرا کن و نتیجه را دقیق گزارش بده. در این task صرفاً سند تهیه شده و تست اجرایی برنامه اجرا نشده است.

### ۲۴.۷ دروازهٔ اتمام: استثنای خودسرانه ممنوع

قبل از اعلام اتمام، تمام قواعد الزام‌آور مرتبط با کد ایجادشده یا تغییرکرده بررسی و تخلف‌ها اصلاح شوند. در صورت مانع، نیاز اجرا‌نشده و تعارض دقیق گزارش شوند؛ انطباق کامل ادعا نشود. تست موفق، کد قدیمی، Skill، زمان محدود یا سلیقهٔ معماری قانون را لغو نمی‌کنند.

برای حالت صریحاً مجاز، مثل حفظ هویت editor یک ردیف هنگام reorder، نیاز رفتاری نزدیک کد نوشته شود:

```dart
// Reordering must preserve the editor associated with this card ID.
key: ValueKey(card.id),
```

این توضیحِ یک حالت مجاز است، نه ساخت استثنای تازه. Agent نمی‌تواند اجازهٔ تازه اختراع کند؛ کار نامرتبط هم از محدودهٔ مجاز بیرون می‌ماند.

## ۲۵. اختلاف با مستندات فعلی و مسیر پذیرش

### ۲۵.۱ تغییرهای پیشنهادی نسبت به قواعد موجود

| موضوع | وضعیت منابع فعلی | پیشنهاد این سند |
|---|---|---|
| factory State | `State(...)` و generated مستقل State | سبک مرجع `State.initial(...)` و part of Cubit |
| initialState تزریق‌شده | در بخش ۱۲ الزام شده | در constructor قابل‌پشتیبانی؛ در UI فقط وقتی لازم است پاس داده شود |
| Provider و View | نمونهٔ architecture از child View استفاده می‌کند | صفحهٔ ساده بدون wrapper View خصوصی؛ Provider و UI در همان build |
| state preparation | private helper هماهنگ‌کننده در بخش ۱۲ مجاز است | دستور جدید مالک: واسطهٔ ساخت/انتشار State مطلقاً ممنوع؛ helper فقط مقدار خالص برگرداند |
| کلاس widget استخراج‌شده | Skill اجازهٔ helper محلی در همان فایل می‌دهد | مطابق خواستهٔ مالک، widget عمومی در فایل خودش |
| اندازهٔ فایل | Skill حدود ۲۰۰ و بازهٔ ۲۰۰–۳۰۰ | بررسی extraction نزدیک ۱۵۰–۲۰۰؛ تقسیم مسئولیتی، بدون ریزکردن |
| selector | Skill و معماری آن را معمولاً مجاز می‌دانند | `BlocBuilder + buildWhen` پیش‌فرض؛ selector فقط با نیاز مشخص |
| getter و alias | architecture عمدتاً ممنوع کرده | با مثال‌های مستقیم و checklist دقیق تثبیت شده |
| Material | بیان مطلق در بعضی قسمت‌های Skill | layout پایه مجاز؛ کنترل دارای معادل پکیج جایگزین نشود |
| localization | کد فعلی gen-l10n و context.l10n دارد | الگوی مصوب S.current؛ مهاجرت کد هنوز انجام نشده |
| analytics در build | در Skill مثال دارد | side effect تکرارشونده در build ممنوع |
| Key | Skill استثناهای عمومی دارد | استثنا با نیاز رفتاری روشن؛ reset خودکار Provider پیش‌فرض نیست |
| setState | در بعضی فرم‌های فعلی وضعیت نمایشی/خطا محلی است | دستور مالک: وضعیت نمایشی و خطا در State؛ Agent اختیار معافیت ندارد؛ مانع واقعی گزارش شود |
| فرم ثابت | بعضی فرم‌ها آرایه‌های موازی دارند | فیلدهای صریح شبیه نمونه‌های مالک، بدون renderer یا dispatch با index |
| سطح builder | ممکن است «پایین‌ترین subtree» مطلق برداشت شود | بخش معنادارِ متغیر؛ جمع‌کردن builderها در سطح بالاتر برای خوانایی مجاز |

### ۲۵.۱.۱ وضعیت نهایی موارد بررسی‌شده؛ از پیشنهاد، الزام تازه نساز

شماره‌ها به فهرست بررسیِ تکمیلی در گفت‌وگو اشاره دارند، نه شمارهٔ فصل‌های این سند.

| مورد بررسی | تصمیم صاحب پروژه | اثر دقیق برای Agent |
|---|---|---|
| ۱: setState | ممنوع، حتی برای نمایش/پنهان‌کردن رمز | field نمایشی در State؛ action در Cubit؛ استثنای خودسرانه ممنوع؛ مانع واقعی گزارش شود |
| ۲: فرم آرایه‌ای | نمونه‌های صریح مالک مبنا هستند | فرم ثابت با input صریح؛ loop دادهٔ واقعی و options انتخابگر مجاز |
| ۳: محل BlocBuilder | پایین‌تر تا جایی که خوانا و معنادار است | فقط بخش متغیر subscribe شود؛ builder اجباری برای هر ویجت نساز؛ برای تعداد زیاد، سطح بالاتر مجاز |
| ۴: اعتبارسنجی رشته‌ای | سبک متدهای مشخص نمونهٔ مالک | update/validate مشخص و validator مرکزی؛ dispatch با String برای فرم ثابت ممنوع |
| ۵: typed select | راهکار مناسب توضیح داده شود | پیشنهاد AppSelect<T> با مقدار معنی‌دار در بخش ۱۶.۵؛ تغییر selectهای فعلی هنوز الزام نیست |
| ۶: تصمیم با متن ترجمه | موافقت | متن صرفاً برای نمایش؛ شرط رفتار/فاصله با ترجمه ممنوع |
| ۷: تطبیق دو enum با index | فعلاً در انتظار بررسی | هیچ refactor یا ممنوعیت تازه برای آن از این سند نتیجه نگیر |
| ۸: field بدون مصرف فعلی | بررسی دلیل؛ اتصال سرویس آینده هم معتبر است | field را خودکار حذف نکن؛ field بی‌دلیل و status تشریفاتی تازه هم نساز |
| ۹: request داخل State | تمایز با State فرم روشن شد؛ حذف کلی تصویب نشده | مصرف عملیاتی مجاز است؛ UI دادهٔ موردنیازش را از State بخواند؛ محل request را خودکار تغییر نده |
| ۱۰: callback خالی | فعلاً مشکلی ندارد | () {} در callback دکمه صرفاً با استناد به این بررسی اصلاح نشود |
| ۱۱: اعتبارسنجی مشترک و prepareState | تابع validator مرکزی لازم؛ واسطهٔ emit ممنوع | regex/checksum تکراری نساز؛ helper خالص مجاز؛ State preparation یا انتشار عمومی/خصوصی ممنوع |

بازبودن مورد ۷، مجوز آرایه‌کردن فرم ثابت یا وابسته‌کردن action فیلد به index نیست؛ آن‌ها در مورد ۲ صریحاً ممنوع شده‌اند. پذیرفته‌بودن callback خالیِ دکمه در مورد ۱۰ نیز مجوز ساخت Listener خالی یا API ساختگی نیست. این‌ها موضوع‌های متفاوت‌اند.

### ۲۵.۲ وضعیت یکپارچه‌سازی

نسخهٔ ۱.۶ اصول تأییدشدهٔ بخش‌های ۲، ۳، ۴، ۶، ۷ و ۸ مرجع را در همین قرارداد یکپارچه و ساختار State فعلی را حفظ می‌کند. AGENTS.md ریشه، خواندن سند و دروازهٔ بررسی انطباق را الزامی کرده است. دو سند موقت Caltivita حذف شده‌اند؛ نسخهٔ فارسی و انگلیسی قرارداد اصلی باقی‌اند. این ویرایش مستندات، کد Dart را تغییر نمی‌دهد و انطباق تمام برنامهٔ موجود را تأیید نمی‌کند.

### ۲۵.۳ پذیرش قرارداد، مجوز refactor خودکار نیست

AGENTS.md از قبل به این قرارداد الزام می‌دهد. نمونه‌های قدیمی معماری یا Skill آن را ضعیف نمی‌کنند. همگام‌کردن متن آن منابع یا افزودن لینک README باید در task مستنداتی مجاز باشد؛ انجام آن‌ها پیش‌شرط رعایت قواعد این سند نیست.

بازنویسی هر جریان به task با محدوده و بررسی رفتار نیاز دارد. پذیرش سبک به‌تنهایی مجوز تغییر تمام flowها، پکیج‌ها یا شبکه نیست.

### ۲۵.۴ مراجع

- [مستند معماری پروژه](architecture-smart-virtual-counter-v2-en.md)
- [Skill موجود UI](../.agents/skills/flutter-widget-ui-style/SKILL.md)
- [راهنمای مصرف avp_ui](main-app-integration-guide.md)
- [سیاست UI-first](avp-ui-first-implementation-policy.md)
- [API رسمی BlocProvider](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocProvider-class.html)
- [API رسمی BlocBuilder](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocBuilder-class.html)
- [API رسمی BlocListener](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocListener-class.html)

قواعد سبکی این سند از خواستهٔ صاحب پروژه می‌آیند؛ لینک‌های API صرفاً رفتار فنی widgetها را توضیح می‌دهند. معتبر بودن یک الگو در Flutter به معنی مطلوب بودن آن در سبک این تیم نیست.


