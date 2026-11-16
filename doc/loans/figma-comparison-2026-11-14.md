# بازبینی مجدد وام در مقایسه با Figma

**وضعیت بعدی:** این سند، مبنای قبل از اصلاح است. اصلاح‌های درخواست‌شده و نتیجهٔ تست‌های جدید در [گزارش اصلاحات](figma-corrections-2026-11-14.md) ثبت شده‌اند.

تاریخ: ۱۴ نوامبر ۲۰۲۶. این سند گزارش مقایسه است؛ در این بازبینی کد محصول و رفتار Mock تغییر نکرده است.

## نتیجه

پیاده‌سازی فعلی، پیاده‌سازی منطبق با تمام طرح‌ها نیست. مسیر اصلی Mock کار می‌کند، اما چند جزء با ظاهر عمومی جایگزین شده‌اند و بعضی حالت‌های درخواستی هنوز پیاده نشده‌اند. ایراد «مشاهده جدول اقساط» هم در لینک ورودی و هم در خود شیت تأیید شد. پاس‌شدن تست‌های عملکرد قبلی، تأیید تطابق بصری نبوده است.

تمام **۱۰۵ فریم یکتا** دوباره با `get_design_context`، همراه اسکرین‌شات دریافت شدند؛ هیچ پاسخ sparse یا خطای سهمیه‌ای در این دریافت وجود نداشت. لینک تکراری `44962` یک بار شمرده شده و لینک شکستهٔ `39408` اصلاح شده است. محدودیت ۳۸ فریم در گزارش قبلی مربوط به دریافت اولیه بود و اکنون مانع بررسی نیست.

مقایسه شامل ساختار و متن طرح‌های تمام خانواده‌ها با کد فعلی، مشاهدهٔ اسکرین‌شات‌های نمایندهٔ حالت‌ها و ثبت ۸ تصویر از خروجی مسیر اصلی است. **این، تأیید پیکسلی ۱۰۵ خروجی مستقل اپ یا تست گوشی واقعی نیست.** تصاویر سیستم‌عامل داخل Figma، از جمله status bar و navigation bar، جزو ویجت اپ محسوب نشده‌اند. اعداد نمونهٔ بانک هم به‌عنوان قرارداد سرویس فرض نشده‌اند.

## ۱. لینک «مشاهده جدول اقساط» — مغایرت قطعی

مرجع: [38390](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38390)، حالت یکجا: [38506](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38506). همین الگو در ۲۵ حالت اعتبارسنجی دارای سپرده دیده می‌شود.

| ویژگی | Figma | پیاده‌سازی فعلی |
| --- | --- | --- |
| جایگاه | راست‌چین، زیر مبلغ قسط؛ در حالت یکجا زیر اسلایدر مدت | عملاً متن در وسط پهنای صفحه |
| متن | ۱۲px، Medium، line-height برابر ۱۸px | پیش‌فرض `AppButtonSize.md`: متن ۱۴px و ارتفاع ۴۰px |
| فلش | `angle-left-small` در سمت چپ متن، slot برابر ۲۰×۲۰ | حذف شده |
| فاصلهٔ متن و فلش | ۸px | فلشی وجود ندارد |
| فضای افقی | چیدمان جمع‌وجور لینک | padding پیش‌فرض ۲۰px و گسترش در عرض موجود |

منبع کد: [loan_assessment.dart](../../lib/features/loans/presentation/request/widgets/loan_assessment.dart)، بخش `Align` و `AppButton`، و اندازه‌های دکمه در `../avp_ui/lib/widgets/buttons/app_button.dart`.

علت: `Align(centerStart)` به‌تنهایی دکمه را به اندازهٔ محتوایش جمع نمی‌کند. `AppButton` در این مصرف عرض موجود را می‌گیرد و `Center` داخلی آن متن را وسط قرار می‌دهد. مشکل فقط انتخاب راست/چپ نیست.

اصلاح لازم: لینک باید با ترکیب مجاز کنترل موجود و اندازه/استایل صریح، عرض متناسب با محتوا، فلش اصلی و راست‌چینی ساخته شود؛ وضعیت غیرفعال هنگام دریافت quote جدید هم حفظ شود. تغییر سراسری پیش‌فرض تمام دکمه‌ها لازم نیست.

## ۲. خودِ شیت جدول اقساط — مغایرت قطعی و مهم

مرجع: [38239](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38239).

در Figma، عنوان «جدول اقساط» است. هر ردیف یک کارت سفید مستقل با border، شعاع ۱۲px و padding برابر ۱۶px است. کارت شامل badge آبی شمارهٔ ردیف ۲۲×۲۲، badge نوع ردیف، خط جداکننده، مبلغ و تاریخ همراه آیکون تقویم است. اولین ردیف نوع «کارمزد» و ردیف‌های بعد نوع «قسط» دارند.

در [loan_installments_sheet.dart](../../lib/features/loans/presentation/request/widgets/loan_installments_sheet.dart)، عنوان از کلید «مشاهده جدول اقساط» استفاده می‌کند؛ یک `LoanValueRow` ساده و سپس تاریخ خارج از کارت رسم می‌شود. badge شماره، badge نوع، border کارت، divider و تقویم وجود ندارند. خروجی ثبت‌شده همین اختلاف را تأیید می‌کند.

همچنین [LoanInstallment](../../lib/features/loans/domain/entities/loan_application.dart) فقط مبلغ و تاریخ دارد؛ بنابراین نوع «کارمزد/قسط» را نمی‌تواند مستقل نمایش دهد. اصلاح ظاهر باید همراه مدل نمایشی قابل‌نمایش برای نوع ردیف باشد. **فرمول، مبلغ و زمان کارمزد نباید از روی یک نمونهٔ Figma اختراع شود**؛ در Mock می‌توان دادهٔ نمونهٔ صریح داشت و قرارداد واقعی باید جداگانه تأمین شود.

## ۳. سایر مغایرت‌ها

اولویت «بالا» یعنی فقدان حالت/دادهٔ لازم یا تفاوت ساختاری محسوس؛ «متوسط» یعنی تفاوت ظاهر یا متن. منابع زیر داخل `lib/features/loans/` هستند.

| شناسه | اولویت | فریم‌های نماینده | تفاوت با کد فعلی و اصلاح لازم |
| --- | --- | --- | --- |
| F03 | بالا | 44481، 44597، 44704 تا 44459 | «هسته اعتماد اجتماعی» در طرح مسیر معتبر تا ثبت دارد، ولی `MockLoanApplicationRepository.quote` آن را به `unknown` تبدیل و ادامه را مسدود می‌کند. نمایش اختصاصی تک‌بازهٔ آن هم وجود ندارد. این محدودیتِ پیاده‌سازی قبلی است، نه سیاست بانک. |
| F04 | بالا | 38390، 41897، 42141، 44481، 42596 | `LoanCreditScale` همیشه سه عنوان و دو مرز داخلی دارد. طرح با طبقهٔ پایه تغییر می‌کند: نمونهٔ ممتاز سه‌بازه، نمونهٔ کاملاً متناسب دوبازه، نمونهٔ متناسب و هسته اجتماعی تک‌بازه دارند. رنگ و نمایش نامتناسب هم نیازمند حالت مستقل است. |
| F05 | بالا | 39059، 39175، 39692، 39808، 42373، 42489، 42596، 42712 | نامتناسب در طرح سه مقدار «توان لازم/توان شما/کسری» و دو راهکار با شرح و لینک مرآت دارد. `LoanCreditStatus` این ساختار را ندارد و به دو متن کوتاه خلاصه کرده است. مسدود بودن ادامه طبق دستور مالک حفظ شود. |
| F06 | متوسط | 38390، 37995 و سایر اعتبارسنجی‌ها | ردیف مبلغ، مدت، مبلغ قسط و طبقه از `LoanValueRow` یکسان استفاده می‌کنند؛ borderها و پس‌زمینه‌های متفاوت طرح اعمال نشده‌اند. مثلاً مبلغ قسط در طرح زمینهٔ آبی روشن و عدد خاکستری دارد، ولی فعلاً زمینه سفید و کل مبلغ آبی است. |
| F07 | متوسط | 38390 و سایر اعتبارسنجی‌ها | واحد پول در طرح slot و استایل مجزا دارد. `loanMoney` کل عدد و ریال را یک String می‌کند؛ در خروجی RTL جای واحد، وزن و رنگ آن با طرح یکسان نیست. همین مورد در خلاصه‌ها هم دیده می‌شود. |
| F08 | متوسط | 38390، 37995، 42141 | ردیف طبقه و کارت‌های وضعیت border و چیدمان اختصاصی دارند. ردیف expandable در طرح فلش دارد و عبارت «طبقه اعتباری: ...» پیوسته است؛ فلش در کد فعلی حذف شده و برچسب/مقدار دو طرف ردیف هستند. آیکون info در طرح ۱۲px و در مصرف فعلی ۲۰px است. |
| F09 | متوسط | 38390، 38506 | کارت امتیاز/مجموع وام‌ها و جداکننده‌های نقطه‌چین طرح به دو ستون متن و فاصلهٔ خالی تبدیل شده‌اند؛ نقطه‌های رنگی امتیاز و مجموع وام‌ها وجود ندارند. |
| F10 | بالا | 37962 | درخواست جاری یک کارت با سربرگ رنگی، زمان، badge مرحله و دو اکشن متنی جداشده با divider است. `LoanIntroduction` عنوان و چند ردیف ساده و دو دکمهٔ بزرگ نشان می‌دهد؛ زمان و سربرگ کارت پیاده نشده‌اند. نباید برای زمان درخواست، مدت فرضی بانکی ساخته شود. |
| F11 | متوسط | 39430، 39408، 40759، 43761، 43368، 44459 | کارت بازگشت پس از ثبت باید badge نارنجی «آماده واریز»، منوی سه‌نقطه و آیکون کپی شمارهٔ درخواست داشته باشد. فعلاً عنوان سبز و ردیف‌های عمومی است؛ اکشن کپی و ساختار کارت وجود ندارند. |
| F12 | بالا | 40544، 44139، 40023، 40174، 43023 | توضیح ضمانت شامل کادر اطلاعات، آیکون، متن بخش‌بندی‌شده و لینک آی‌کاپ است. `LoanCollateralForm` آن را به یک متن ساده کوتاه کرده است؛ قسمت‌های لازم برای دریافت سفته در UI موجود نیست. مقصد واقعی لینک باید تأمین شود. |
| F13 | متوسط | 40117، 40338، 42966، 43187 | دو خطای ضامن در طرح کادر هشدار قرمز با آیکون دارند. کد فعلی فقط Text قرمز نشان می‌دهد. حالت نمایش نام ضامن و فاصلهٔ آن با هشدار نیز با فرم هدف تطبیق کامل ندارد. |
| F14 | متوسط | 40174، 40256، 44139، 44245 | انتخاب سند در طرح علامت تیکِ انتخاب‌شده دارد؛ کد از همان آرت‌ورک radio نوع بازپرداخت استفاده می‌کند. این دو کنترل ظاهر یکسانی در Figma ندارند. چیدمان عنوان اطلاعات و placeholder شناسه‌ها هم یکسان نیست. |
| F15 | متوسط | 39945، 40405، 40438، 40508 و تکرارهای سایر طبقات | بدنهٔ رد استعلام، اکشن تلاش مجدد همراه آیکون و جزئیات رنگ/فاصله با کارت فعلی یکسان نیست. Mock از همه processing به یک نتیجهٔ دسته‌ای می‌رود؛ حالت‌های میانیِ ترکیب processing با approved/rejected، مانند 40405 و 40438، در سناریوی فعلی تولید نمی‌شوند. |
| F16 | متوسط | 38108 | راهنمای طبقه، متن کامل بخش‌بندی‌شدهٔ سه بازه دارد؛ `LoanInformationSheet` با متن خلاصه‌شده و دکمهٔ برگشت اضافه نمایش داده می‌شود. ساختار و ارتفاع آن مطابق شیت هدف نیست. |
| F17 | بالا | 41290، 41089 | شیت جزئیات بیمه، شماره سپرده و مبلغ را پیش از توضیح دارد. مصرف فعلی `LoanInformationSheet` این دو ردیف را حذف کرده و متن «در انتظار محتوای بانک» نمایش می‌دهد. تأمین متن نهایی بانک مستقل از اصلاح چیدمان است. |
| F18 | متوسط | 41160، 40647، 40458، 44298، 43254، 44752 | خلاصه قرارداد نزدیک‌تر از سایر بخش‌هاست، ولی dividerها، فاصله‌ها و اکشن مشاهده قرارداد با طرح یکسان نیستند. در حالت بیمهٔ اختیاری، عنوان و متن باید متناسب با همان variant باشند، نه متن ثابت حالت پوشش بیمه. |
| F19 | بالا | 41441، 41669 و تکرارها | Figma شیت بلند قرارداد با ناحیهٔ متن قابل اسکرول و اکشن‌های پایین دارد. خروجی فعلی یک شیت کوتاه با متن هشدار Mock است. دانلود قرارداد نیز به unavailable می‌رود. متن نمونهٔ طرح نباید بدون تأیید بانک به قرارداد رسمی تبدیل شود؛ با این حال اسکلت و ارتفاع نسخهٔ نمایشی هم باید درست ساخته شود. |
| F20 | متوسط | 41749، 41823 و تکرارها | ساختار پنج خانه و دو دکمه موجود است؛ ولی جملهٔ شماره موبایل در طرح یکپارچه است و فعلاً شماره در سطر جدا قرار می‌گیرد. آیکون ساعت شمارش‌معکوس حذف شده و فاصله‌های عمودی مطابق طرح نیستند. |
| F21 | بالا | 39282، 39345، 40696، 43698، 43305، 44396 | پشت شیت موفقیت در Figma صفحهٔ ابتدایی وام است. خروجی فعلی هنوز صفحهٔ قرارداد را نشان می‌دهد و فقط پس از بستن رسید به ابتدا می‌رود. کادر کد پیگیری نیز border و alignment طرح را ندارد. |
| F22 | متوسط | 38390، 39945 و مراحل بعد | supportingText مرحله‌نما در طرح با «بعدی:» شروع می‌شود؛ `loanNextLabel` فعلاً فقط نام مرحله را می‌دهد. ضخامت/فاصلهٔ متن‌ها و برخی اندازه‌های کنترل‌های پیش‌فرض در خروجی با نمونه تفاوت دارند. |

## موارد درست یا خارج از اثبات این مقایسه

- SafeArea و محدودیت ارتفاع/اسکرول شیت‌ها وجود دارند؛ حذف آنها راه اصلاح ظاهر نیست.
- غیرفعال بودن ادامه هنگام دریافت quote جدید، حفظ snapshot قبلی و جلوگیری از پرش هنگام loading اصلاح قبلی‌اند و باید حفظ شوند.
- خودِ پنج‌رقمی بودن OTP، مسیر کلی inquiries → collateral/contract و کنترل پذیرش قوانین پیاده شده‌اند. این موارد به معنی تطابق ظاهر نیستند.
- فایل پوستر محلی صحیح و غیرخالی است. در capture تست ویجت، پوستر به‌صورت زمینهٔ خالی دیده شد؛ علت روی گوشی واقعی اثبات نشده و نباید از آن نتیجه گرفت که asset حذف شده است. خطای رندر SVG شامل filter/foreignObject هم در لاگ تست دیده می‌شود. بررسی بارگذاری/رندر تصویر و آیکون‌ها روی خروجی واقعی لازم است.
- پخش واقعی ویدئو، دانلود قرارداد، امضای بانکی و مقصد مرآت/آی‌کاپ با دادهٔ فعلی قابل تأیید نیستند. این محدودیت‌های اتصال/محتوا را نباید با اختلاف layout یکی دانست.

## ابهام‌ها و ناسازگاری‌های خودِ Figma

۱. در 40174، مبلغ درخواست ۲٫۵ میلیارد ریال است، مبلغ سفتهٔ نمایشی ۳٫۳۶ میلیارد و متن توضیح ۳٫۶ میلیارد است؛ هیچ‌کدام ۱۲۰٪ عدد درخواست نیستند. مقدار واقعی باید از داده/قرارداد تعیین شود، نه کپی این نمونه‌ها.

۲. توضیح بازهٔ متناسب در 41897/42013 هم «به ضامن نیاز ندارید» می‌گوید و هم برای ضامن سند می‌خواهد. مرحله‌های بعد ضامن دارند. این تناقض متنی نیازمند اصلاح طراح است.

۳. بعضی طرح‌های نامتناسب دکمهٔ مرحله بعد را فعال نشان می‌دهند. دستور صریح مالک فعلاً ادامه را ممنوع کرده؛ این تفاوت عمدی و مجاز است و TODO باید حفظ شود.

۴. اصطلاح روی خود طرح «هسته اعتماد اجتماعی» است؛ متن درخواست «هسته اعتبار اجتماعی» است. واژهٔ نهایی باید یکدست شود.

۵. مقدار نمونهٔ شمارش‌معکوس در طرح `00:60` است. نمایش استاندارد یک دقیقه `01:00` است؛ این مورد به‌عنوان خطای کد ثبت نشده است. تاریخ و کارمزد نمونه‌ها نیز قانون زمان‌بندی بانکی نیستند.

## ترتیب پیشنهادی اصلاح

۱. لینک ورودی و کارت‌های جدول اقساط، همراه مدل نوع ردیف و تست ظاهر/چیدمان.

۲. اجزای مشترک اعتبارسنجی: ردیف مبلغ/مدت/قسط، واحد پول، کارت‌های وضعیت، بازهٔ وابسته به طبقه، نامتناسب و هسته اجتماعی.

۳. کارت درخواست جاری و نتیجهٔ ثبت، سپس فرم تضامین و هشدارهای ضامن.

۴. شیت‌های راهنما، بیمه، قرارداد و OTP و تغییر صفحهٔ زیر رسید پیش از نمایش آن.

۵. تست تصویری برای variantهای واقعی، با فونت و asset بارگذاری‌شده؛ تست عملکرد، loading و viewport کوچک نیز حفظ شود. هیچ فرمول بانکی یا متن قرارداد رسمی از طرح حدس زده نشود.

## شواهد و اجرا

فریم‌های Figma با اسکرین‌شات و کد دقیق دوباره دریافت و ساختار/متن‌های خانواده‌ها با widgetهای فعلی مقایسه شدند. تصویر خروجی برای introduction، assessment، contract، contract_sheet، otp و receipt ثبت و مشاهده شد. دو capture اضافیِ جدول و پایین اعتبارسنجی نیز ثبت و مشاهده شدند.

```sh
CAPTURE_LOAN_PREVIEWS=1 flutter test --no-pub test/loans/loan_request_screen_test.dart --plain-name 'entry, assessment, contract, OTP and receipt use the same scope'
CAPTURE_LOAN_PREVIEWS=1 flutter test --no-pub .dart_tool/loan_audit_preview_test.dart --plain-name 'entry, assessment, contract, OTP and receipt use the same scope'
```

هر دو اجرا: یک تست مسیر اصلی پاس شد. دومی نسخهٔ موقت همان تست با capture شیت اقساط و اسکرول به پایین اعتبارسنجی است؛ کد محصول یا تست tracked را تغییر نداده است. تصاویر در `build/previews/loans/` قرار دارند. این اجراها صرفاً شواهد عملکرد مسیر و capture هستند؛ نتیجهٔ مقایسهٔ بصری در بخش‌های بالا **عدم تطابق** است. تست کامل پروژه اجرا نشده است.

## فهرست همهٔ فریم‌ها

جدول زیر تمام ۱۰۵ فریم دریافت‌شده را به خانواده و بخش مقایسه وصل می‌کند. «بازبینی» به معنی بررسی مرجع و مصرف کد است، نه پاس‌شدن تطابق پیکسلی آن فریم روی گوشی. ارجاع به یک گروه یافته به معنی وجود تک‌تک ایرادهای آن گروه در همهٔ فریم‌ها نیست؛ مثلاً پیش از انتخاب سپرده، جدول اقساط هنوز نمایش داده نمی‌شود.

| خانواده | تعداد فریم |
| --- | --- |
| خلاصه قرارداد | 7 |
| شیت قرارداد | 12 |
| استعلامات | 16 |
| OTP | 12 |
| شیت بیمه | 2 |
| بازگشت پس از ثبت | 6 |
| تضامین و ضامن | 16 |
| اعتبارسنجی | 24 |
| راهنمای طبقه اعتباری | 1 |
| ورود بدون درخواست | 1 |
| رسید | 6 |
| درخواست جاری | 1 |
| جدول اقساط | 1 |

| فریم Figma | خانواده | موارد مقایسه |
| --- | --- | --- |
| [37941](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-37941) | ورود بدون درخواست | بارگذاری ویدئو/پوستر و منابع محتوا |
| [37962](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-37962) | درخواست جاری | F10 |
| [37984](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-37984) | اعتبارسنجی | حالت پیش از انتخاب سپرده؛ F22؛ هنوز جدول/نتیجه ندارد |
| [37995](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-37995) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [38108](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38108) | راهنمای طبقه اعتباری | F16 |
| [38239](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38239) | جدول اقساط | بخش ۲؛ ساختار کارت و مدل نوع ردیف |
| [38390](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38390) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [38506](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38506) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [38613](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38613) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [38729](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38729) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [38836](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38836) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [38952](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-38952) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [39059](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39059) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [39175](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39175) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [39282](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39282) | رسید | F21 |
| [39345](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39345) | رسید | F21 |
| [39408](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39408) | بازگشت پس از ثبت | F11 |
| [39430](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39430) | بازگشت پس از ثبت | F11 |
| [39469](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39469) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [39585](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39585) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [39692](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39692) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [39808](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39808) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [39915](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39915) | استعلامات | F15، F22 |
| [39945](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39945) | استعلامات | F15، F22 |
| [39975](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-39975) | استعلامات | F15، F22 |
| [40005](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40005) | استعلامات | F15، F22 |
| [40023](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40023) | تضامین و ضامن | F12–F14، F22 |
| [40070](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40070) | تضامین و ضامن | F12–F14، F22 |
| [40117](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40117) | تضامین و ضامن | F12–F14، F22 |
| [40174](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40174) | تضامین و ضامن | F12–F14، F22 |
| [40256](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40256) | تضامین و ضامن | F12–F14، F22 |
| [40338](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40338) | تضامین و ضامن | F12–F14، F22 |
| [40405](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40405) | استعلامات | F15، F22 |
| [40438](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40438) | استعلامات | F15، F22 |
| [40458](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40458) | خلاصه قرارداد | F18 |
| [40508](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40508) | استعلامات | F15، F22 |
| [40526](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40526) | استعلامات | F15، F22 |
| [40544](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40544) | تضامین و ضامن | F12–F14، F22 |
| [40597](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40597) | خلاصه قرارداد | F18 |
| [40647](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40647) | خلاصه قرارداد | F18 |
| [40696](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40696) | رسید | F21 |
| [40759](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40759) | بازگشت پس از ثبت | F11 |
| [40781](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40781) | شیت قرارداد | F19 |
| [40861](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40861) | شیت قرارداد | F19 |
| [40941](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-40941) | OTP | F20 |
| [41015](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41015) | OTP | F20 |
| [41089](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41089) | شیت بیمه | F17 |
| [41160](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41160) | خلاصه قرارداد | F18 |
| [41210](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41210) | شیت قرارداد | F19 |
| [41290](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41290) | شیت بیمه | F17 |
| [41361](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41361) | شیت قرارداد | F19 |
| [41441](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41441) | شیت قرارداد | F19 |
| [41521](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41521) | OTP | F20 |
| [41595](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41595) | OTP | F20 |
| [41669](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41669) | شیت قرارداد | F19 |
| [41749](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41749) | OTP | F20 |
| [41823](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41823) | OTP | F20 |
| [41897](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-41897) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [42013](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42013) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [42141](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42141) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [42257](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42257) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [42373](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42373) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [42489](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42489) | اعتبارسنجی | بخش ۱، F04–F09، F22 |
| [42596](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42596) | اعتبارسنجی | بخش ۱، F04–F09، F22؛ F03 |
| [42712](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42712) | اعتبارسنجی | بخش ۱، F04–F09، F22؛ F03 |
| [42824](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42824) | استعلامات | F15، F22 |
| [42854](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42854) | استعلامات | F15، F22 |
| [42872](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42872) | تضامین و ضامن | F12–F14، F22 |
| [42919](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42919) | تضامین و ضامن | F12–F14، F22 |
| [42966](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-42966) | تضامین و ضامن | F12–F14، F22 |
| [43023](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43023) | تضامین و ضامن | F12–F14، F22 |
| [43105](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43105) | تضامین و ضامن | F12–F14، F22 |
| [43187](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43187) | تضامین و ضامن | F12–F14، F22 |
| [43254](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43254) | خلاصه قرارداد | F18 |
| [43305](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43305) | رسید | F21 |
| [43368](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43368) | بازگشت پس از ثبت | F11 |
| [43390](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43390) | شیت قرارداد | F19 |
| [43470](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43470) | شیت قرارداد | F19 |
| [43550](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43550) | OTP | F20 |
| [43624](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43624) | OTP | F20 |
| [43698](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43698) | رسید | F21 |
| [43761](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43761) | بازگشت پس از ثبت | F11 |
| [43783](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43783) | استعلامات | F15، F22 |
| [43813](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43813) | استعلامات | F15، F22 |
| [43831](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43831) | شیت قرارداد | F19 |
| [43911](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43911) | شیت قرارداد | F19 |
| [43991](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-43991) | OTP | F20 |
| [44065](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44065) | OTP | F20 |
| [44139](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44139) | تضامین و ضامن | F12–F14، F22 |
| [44192](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44192) | تضامین و ضامن | F12–F14، F22 |
| [44245](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44245) | تضامین و ضامن | F12–F14، F22 |
| [44298](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44298) | خلاصه قرارداد | F18 |
| [44348](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44348) | استعلامات | F15، F22 |
| [44378](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44378) | استعلامات | F15، F22 |
| [44396](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44396) | رسید | F21 |
| [44459](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44459) | بازگشت پس از ثبت | F11 |
| [44481](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44481) | اعتبارسنجی | بخش ۱، F04–F09، F22؛ F03 |
| [44597](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44597) | اعتبارسنجی | بخش ۱، F04–F09، F22؛ F03 |
| [44704](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44704) | استعلامات | F15، F22 |
| [44734](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44734) | استعلامات | F15، F22 |
| [44752](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44752) | خلاصه قرارداد | F18 |
| [44802](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44802) | شیت قرارداد | F19 |
| [44882](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44882) | شیت قرارداد | F19 |
| [44962](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-44962) | OTP | F20 |
| [45036](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=28180-45036) | OTP | F20 |
