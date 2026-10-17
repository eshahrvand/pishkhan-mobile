# قرارداد کدنویسی UI، Cubit و State برای تیم و Agent

**پروژه:** پیشخوان مجازی هوشمند — `pishkhan_mobile`  
**نسخه:** ۱.۱ — قواعد تأییدشدهٔ صاحب پروژه، با موارد بازِ مشخص  
**تاریخ:** ۲۰۲۶/۱۰/۱۴  
**دامنه:** سبک نوشتن Presentation، مدیریت State و قواعد خوانایی  
**وضعیت:** در این مرحله فقط سند تهیه شده؛ هیچ refactor یا تغییر رفتار برنامه انجام نشده است.

این سند خواسته‌های صاحب پروژه و نمونه‌های ارائه‌شده را به قواعد مشخص تبدیل می‌کند. هدف این است که یک عضو تیم با باز کردن صفحه، مسیر ساخت UI، خواندن State و فراخوانی Cubit را مستقیم ببیند و برای فهم یک فرم ساده بین چندین wrapper و فایل جابه‌جا نشود.

«الزامی» و «ممنوع» در متن، دستورهای سبکی تأییدشدهٔ صاحب پروژه‌اند. بخش‌هایی که صریحاً «توصیه» یا «در انتظار بررسی» نامیده شده‌اند، الزام جدید نیستند. این سند به Agent مجوز تغییر خودکار کد نمی‌دهد و فایل [معماری](architecture-smart-virtual-counter-v2-en.md) یا [Skill فعلی UI](../.agents/skills/flutter-widget-ui-style/SKILL.md) را خودکار بازنویسی نمی‌کند. در اختلاف سبکی، دستور صریح صاحب پروژه که در این سند ثبت شده بر نمونه‌های قدیمی مقدم است؛ مرزها و موارد باز در بخش ۲۵ آمده‌اند.

**قاعدهٔ تفسیر:** Agent نباید از «خوانایی»، «تمیزتر»، «قابل‌توسعه» یا احتمال آینده، مجوز ساخت abstraction تازه، wrapper تازه، State موازی یا استثنا بر ممنوعیت‌ها نتیجه بگیرد. «ممنوع» را با تغییر اسم همان الگو دور نزن. «مجاز» را نیز به «اجباری برای همهٔ صفحات» تبدیل نکن. اگر رفتار موردنیاز واقعاً با قرارداد قابل‌پیاده‌سازی نیست، مورد مشخص را گزارش کن؛ قانون جایگزین اختراع نکن.

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
| ساخت Cubit صفحه | `BlocProvider(create: ...)` داخل `build` صفحه؛ بدون Screen/View اضافی |
| پیدا کردن Cubit | `context.read<MyCubit>()` در context زیر Provider |
| State | یک data class سادهٔ Freezed، بدون getter و منطق دست‌نویس |
| مقدار اولیه | constructor خوانای `State.initial(...)`؛ فقط یک factory |
| نمایش | خواندن مستقیم `state.field` داخل آرگومان ویجت |
| loading | مقایسهٔ مستقیم `state.submissionStatus == RequestStatus.loading` |
| تصمیم تجاری | محاسبه در action یا تابع مشخص Cubit و ذخیرهٔ نتیجه در State |
| تغییر وضعیت نمایشی | حتی نمایش رمز و باز/بسته‌شدن بخش، در Cubit/State؛ استفادهٔ معمول از `setState` ممنوع |
| فرم ثابت | فیلدهای صریح شبیه نمونهٔ صاحب پروژه؛ آرایه‌های موازی و dispatch با index ممنوع |
| متن وابسته به چند مرحله | تابع نام‌دار در UI که `String` برگرداند |
| side effect | Listener یا callback UI؛ خارج از builder و Cubit |
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
| `locator.get` داخل Cubit | dependency از constructor تزریق شود؛ service locator جدید نساز |
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
- مدیریت timer متعلق به جریان.

منطق تجاری قابل‌استفاده در چند مصرف‌کننده، در Domain می‌ماند؛ «منطق را به Cubit ببر» به معنی انتقال همهٔ قوانین بانک از UseCase به Cubit نیست. Cubit هماهنگ‌کنندهٔ رفتار فرم است.

### ۳.۳ UI: چیدمان، نمایش و تعامل با Flutter

UI مسئول است برای:

- ساخت درخت ویجت؛
- انتخاب متن ترجمه‌شده و رنگ و فاصله؛
- کنترل focus، scroll و controller؛
- نمایش dialog، sheet و snackbar؛
- navigation و callbackهای میزبان؛
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
| اسکرول به بالای صفحه بعد از تغییر مرحله | Listener UI |
| بستن sheet | UI |
| رمز دیده شود یا پنهان باشد؟ | field در State و action در Cubit؛ UI مقدار را نمایش می‌دهد |
| خطای عدم تطابق رمز نمایش داده شود؟ | اعتبارسنجی و field خطا در Cubit/State؛ focus-loss event از UI |
| ذخیره و بازیابی token | زیرساخت احراز هویت؛ خارج از widget |
| دنبال کردن صفحه یا کلیک | محل side effect مشخص؛ هرگز build تکرارشونده |

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

### ۶.۱ constructor خوانا و dependency تزریق‌شده

```dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.requestOtpUseCase,
    required this.submitLoginUseCase,
    AuthState initialState = const AuthState.initial(),
  }) : super(initialState);

  final RequestOtpUseCase requestOtpUseCase;
  final SubmitLoginUseCase submitLoginUseCase;

  Timer? _timer;
}
```

پارامتر `initialState` برای سازگاری با قرارداد پروژه و تست باقی می‌ماند؛ UI عادی لازم نیست هر بار State پیش‌فرض را پاس بدهد. پارامتر ورودی واقعی مانند `initialDepositNumber` با snapshot کامل State یکی نیست.

ساختار plain State و متدهای صریح را از نمونه می‌گیریم؛ نام use case و محل دریافت dependency از پروژهٔ دیگر کپی نمی‌شود.

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
    required this.repository,
    this.initialDepositNumber,
    this.onCompleted,
  });

  final DepositCertificatesRepository repository;
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
        repository: widget.repository,
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

- برای صفحهٔ جدید، Cubit را با `create` بساز.
- همان Cubit را دوباره در `initState` نساز.
- `close` دستی برای Cubit متعلق به `create` ننویس.
- `bloc: _cubit` را وقتی Provider درست در ancestor است اضافه نکن.
- `BlocProvider.value` فقط برای instance واقعاً موجود، مانند ادامهٔ همان فلو در sheet، استفاده شود.
- ساخت `Cubit()` داخل آرگومان `value` ممنوع است.

### ۹.۴ rebuild عادی با ورود تازه به flow فرق دارد

بازسازی ویجت با همان type و جایگاه و identityِ عنصر Provider، به‌خودی‌خود Cubit را دوباره نمی‌سازد. تغییر Key یا حذف subtree می‌تواند instance قبلی را از بین ببرد؛ reset را با آن پنهان نکن.

برای ورود جدید به سرویس، route جدید و scope تازه کافی است. تغییر runtimeِ repository فقط وقتی پشتیبانی شود که نیاز واقعی API صفحه باشد؛ `didUpdateWidget` عمومی و `changeRepository` برای همهٔ صفحات به‌صورت پیش‌فرض ساخته نشوند. اگر ورود جدید یا تغییر account در همان scope باید داده را reset کند، رفتار باید صریح، قابل‌تست و با action مشخص باشد.

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

مسیر concreteِ navigation در UI/router می‌ماند. Cubit نباید `context.push` یا `ScaffoldMessenger` صدا بزند. adapter با نام روشن مثل `openCardAction` مجاز است؛ زنجیرهٔ helperهای عمومی برای پنهان کردن یک action ساده ساخته نشود.

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

این کاربرد `.value` استثنای روشنِ استفاده از instance موجود است؛ sheet نباید Cubit صفحه را close کند.

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

**دستور صریح صاحب پروژه:** `setState` به‌صورت معمول استفاده نشود؛ حتی نمایش/پنهان‌کردن رمز، باز/بسته‌شدن summary یا یک انتخاب ظاهری باید field در Freezed State و action در Cubit داشته باشد. «این فقط UI state است» استثنا نیست.

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

اگر هیچ راه قابل‌اجرا با قرارداد flow و APIهای موجود نیست، استثنای موردی ممکن است بررسی شود. Agent باید قبل از ایجاد استثنا، محدودیت فنی مشخص و راه‌های بررسی‌شده را گزارش کند و تعیین تکلیف همان مورد را از صاحب پروژه بگیرد. کوتاه‌تر بودن کد، عادت Flutter یا «صرفاً نمایشی بودن» دلیل استثنا نیست. به‌جای `setState` هم State موازی با ValueNotifier یا notifier تازه برای دور زدن این قاعده نساز؛ استفادهٔ معمول از animation/controller موجود برای lifecycle و رفتار Flutter موضوع جداگانه‌ای است.

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

**مسئله:** indexهای ۳ و شرط‌های پراکنده، نیاز اسکرول را به جایگاه enum وابسته کرده‌اند؛ GlobalKey برای همهٔ chipها هزینهٔ ذهنی دارد.

**قاعده:** اسکرول، منطق UI است و نمی‌تواند به Cubit منتقل شود. ابتدا ساده‌ترین رفتار کاربر را با scroll API موجود پیاده کن. اگر ensureVisible به key نیاز دارد، دلیل مشخص و رفتار لازم را حفظ کن؛ key صرفاً برای تست یا هر chip ساخته نشود. index magic جای اسم رفتار را نگیرد.

### ۲۲.۴ _request و _more

این متدها ذاتاً نامعتبر نیستند؛ نمایش sheet و navigation کار UI است. مسئله زمانی است که یک متد، eligibility، payload، routing، پیام و محاسبهٔ انتخاب را مخلوط می‌کند.

**قاعده:** انتخاب و availability در Cubit؛ نمایش action sheet در UI؛ dispatch مسیر در قرارداد router موجود. متد UI کوتاه و با نامی مثل `openCardActions` یا `handleCardAction` مجاز است. صرف private بودن متد side effect، دلیل انتقال آن به Cubit نیست.

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
| mock داخل هر screen به‌صورت پیش‌فرض | dependency صریح؛ mock در composition محیط نمونه |
| success جعلی برای action پیاده‌نشده | پیام عدم دسترسی یا callback صریح میزبان |
| event analytics داخل build | lifecycle/observer یا callback مناسب |
| setState برای چشم رمز، summary یا خطای فرم | field در State و action صریح Cubit |
| آرایه‌های labels/hints/values و switch(index) برای فرم ثابت | inputهای صریح مطابق نمونهٔ صاحب پروژه |
| validateField('phone') برای فرم ثابت | update/validate مشخص هر فیلد با validator مرکزی |
| مقایسهٔ متن ترجمه‌شده برای تصمیم | شناسهٔ معنی‌دار یا چیدمان صریح |
| حذف field فقط چون UI فعلی آن را نمی‌خواند | بررسی مسئولیت عملیاتی یا قرارداد سرویس آینده |
| builder اجباری برای هر Text و Icon | builder دور بخش معنادارِ متغیر؛ سطح بالاتر برای جلوگیری از پراکندگی |

برای وابستگی mock، می‌توان flow نمونه را در route composition به MockRepository متصل کرد و screen را با interface واقعی نگه داشت. این پیشنهاد مجوز تعویض adapterهای فعلی بدون task نیست.

## ۲۴. دستور عملی Agent و چک‌لیست بازبینی

### ۲۴.۱ متن کوتاه قابل‌استفاده به‌عنوان دستور Agent

```text
برای Presentation این پروژه، قرارداد UI/Cubit/State مصوب را رعایت کن.

1. UI را با سبک آشنای تیم و build دارای block body بنویس.
2. BlocProvider(create) در صفحه/ورودی واقعی flow باشد؛ Screen/View خصوصی
   اضافه، Cubit دستی و bloc: صریح بدون نیاز نساز.
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
    اگر محدودیت فنی اجتناب‌ناپذیر است، آن مورد را قبل از استثنا گزارش کن.
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
```

این متن قواعد تأییدشده و مرزهای تصمیم‌های باز را ثبت می‌کند و می‌تواند در task مستنداتی جدا در AGENTS/Skill قرار بگیرد. اکنون آن فایل‌ها تغییر نکرده‌اند.

### ۲۴.۲ قبل از نوشتن UI

- [ ] نیاز واقعی صفحه، ورودی route و callback خروج مشخص است.
- [ ] component موجود در `avp_ui` و app shared بررسی شده است.
- [ ] نوع State و statusهای عملیات مشخص‌اند.
- [ ] روشن است چه تصمیمی در Cubit و چه نمایشی در UI است.
- [ ] برای صفحهٔ ساده، abstraction جدید طراحی نشده است.
- [ ] هیچ تغییر خارج از محدودهٔ task لازم فرض نشده است.

### ۲۴.۳ هنگام نوشتن Cubit

- [ ] constructor dependencyهای لازم را تزریق می‌کند.
- [ ] هر action نام رفتاری روشن دارد.
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

- [ ] Provider در محل روشن و با مالکیت create است.
- [ ] private View wrapper و Key پیش‌فرض ندارد.
- [ ] callbackها context صحیحِ زیر Provider دارند.
- [ ] state مستقیم در آرگومان‌ها خوانده می‌شود.
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

### ۲۴.۷ چطور استثنا نوشته شود؟

استثنا فقط برای نیاز واقعی، با توضیح نزدیک کد:

```dart
// این ردیف editor داخلی دارد؛ هنگام reorder، مقدار editor باید با ID کارت بماند.
key: ValueKey(card.id),
```

توضیح «برای clean code» یا «برای test» به‌تنهایی کافی نیست. اگر استثنا سبک اصلی تیم را تغییر می‌دهد، Agent باید دلیل را گزارش کند؛ خودش آن را به الگوی عمومی پروژه تبدیل نکند.

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
| setState | در بعضی فرم‌های فعلی وضعیت نمایشی/خطا محلی است | دستور مالک: وضعیت نمایشی و خطا در State؛ setState فقط با تعیین تکلیف محدودیت اجتناب‌ناپذیر |
| فرم ثابت | بعضی فرم‌ها آرایه‌های موازی دارند | فیلدهای صریح شبیه نمونه‌های مالک، بدون renderer یا dispatch با index |
| سطح builder | ممکن است «پایین‌ترین subtree» مطلق برداشت شود | بخش معنادارِ متغیر؛ جمع‌کردن builderها در سطح بالاتر برای خوانایی مجاز |

### ۲۵.۱.۱ وضعیت نهایی موارد بررسی‌شده؛ از پیشنهاد، الزام تازه نساز

شماره‌ها به فهرست بررسیِ تکمیلی در گفت‌وگو اشاره دارند، نه شمارهٔ فصل‌های این سند.

| مورد بررسی | تصمیم صاحب پروژه | اثر دقیق برای Agent |
|---|---|---|
| ۱: setState | ممنوع، حتی برای نمایش/پنهان‌کردن رمز | field نمایشی در State؛ action در Cubit؛ فقط محدودیت اجتناب‌ناپذیر جداگانه تعیین تکلیف شود |
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

### ۲۵.۲ آنچه الآن انجام شده

در این ویرایش فقط همین فایل Markdown به‌روز شده است. فایل‌های Dart، رفتار برنامه، dependencyها، Skill و README تغییر نکرده‌اند. اصلاح مستنداتیِ `S.current` در معماری مربوط به درخواست قبلی بود؛ در این ویرایش فایل معماری دوباره تغییر داده نشده است. تغییر موجود در `pubspec.yaml` نیز مربوط به وضعیت قبلی workspace است و در این task دست‌کاری نشده است.

### ۲۵.۳ پذیرش قرارداد، اجرای خودکار refactor نیست

برای همگام‌کردن سایر منابع با قواعد تأییدشده، سه کار مستنداتی می‌تواند در یک task مشخص انجام شود:

1. همگام کردن بخش ۱۲ و مثال Provider با همین قرارداد؛
2. اصلاح Skill برای حذف اسم‌ها و APIهای برنامهٔ دیگر و رفع تناقض‌ها؛
3. لینک کردن قرارداد مصوب در README و دستور ورودی Agent.

سپس یک flow نمونه، مثلاً Login یا Average Balance، می‌تواند در task جدا با همین قواعد بازنویسی و بررسی شود. تغییر همهٔ flowها باید محدوده و بررسی رفتار داشته باشد؛ پذیرش سبک به‌تنهایی مجوز refactor سراسری نیست.

### ۲۵.۴ مراجع

- [مستند معماری پروژه](architecture-smart-virtual-counter-v2-en.md)
- [Skill موجود UI](../.agents/skills/flutter-widget-ui-style/SKILL.md)
- [راهنمای مصرف avp_ui](main-app-integration-guide.md)
- [سیاست UI-first](avp-ui-first-implementation-policy.md)
- [API رسمی BlocProvider](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocProvider-class.html)
- [API رسمی BlocBuilder](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocBuilder-class.html)
- [API رسمی BlocListener](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocListener-class.html)

قواعد سبکی این سند از خواستهٔ صاحب پروژه می‌آیند؛ لینک‌های API صرفاً رفتار فنی widgetها را توضیح می‌دهند. معتبر بودن یک الگو در Flutter به معنی مطلوب بودن آن در سبک این تیم نیست.


