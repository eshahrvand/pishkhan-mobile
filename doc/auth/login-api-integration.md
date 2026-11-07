# Login API integration

Reviewed: 2026-11-01 — Cubit migration, phase 1 and UseCase DI correction.

This document records the implemented Login transport and the owner's confirmed
temporary decisions. [Login development](../login/development.md) describes UI,
operation ownership, the user path and the phase-1 review. The
[UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md) is authoritative;
legacy examples prescribing returned `.then` chains do not apply to AuthCubit.

## Approved notification model — implemented for this flow

The owner-approved [contract v1.20](../ui-cubit-state-agent-rules-en.md) uses
per-operation terminal status transitions for request feedback and independent
typed-effect execution. Failure/message may retain the latest recorded error;
there is no blanket clearing requirement. Success feedback, when required, uses
localized UI success text. Clears remain only for a real consumer/reset need.

The initial documentation-first rule is now implemented for this flow. Each
request-failure listener observes only its operation's entering-failure transition;
typed effects execute independently of retained message text. Existing success
behavior is preserved without adding new success toasts. Earlier phase test
results below remain historical; the notification migration has its own checks.

Under [contract v1.21](../ui-cubit-state-agent-rules-en.md#116-choose-builder-listener-or-consumer-by-responsibility),
AuthScreen already groups CAPTCHA, OTP-request and login failure listeners plus
the typed-effect listener in MultiBlocListener. Existing BlocBuilders render the
step and form sections; there is no Consumer for a second screen-effect path.
The phase-1 composition required no code change. Guest inline feedback, command
consumption, success callback, initial attachment and existing build/listen
predicates remain intact.


## Confirmed bank contract

The owner supplied request/response samples and confirmed the raw token header
on 2026-10-21. Sample-based DTOs are provisionally approved until OpenAPI arrives.
Retrofit and JSON serializers are generated with build_runner and are not edited
manually. Source/tests contain synthetic fixtures, not real customer credentials.

Base URL: `https://apii.rqbank.ir`, configured with the shared 15/20/20-second
connect/send/receive timeouts in `core/config/constant.dart`.

| Operation | Method/path | Request | Accepted response |
| --- | --- | --- | --- |
| CAPTCHA | `GET /captcha` | No body | Decodable Base64 image plus nonblank `SessionId` response header |
| Request OTP | `POST /check-cif` | String fields: `nationalCode`, `ip`, `mobile`, `captcha`, `sessionId`; header `version: ng-1` | `status: 0` and a nonblank challenge token |
| Verify OTP | `POST /check-sms` | Six-digit string `code`; raw `token: <challenge token>` header, without Bearer prefix | `status: 0`, nonblank final token and customer matching submitted national code |

HTTP 200 or an OK message alone does not authenticate. Only validated check-sms
success establishes login, after the final token is successfully stored. Unknown
bank failures map to the approved generic message; raw server text is not shown.

The check-cif protocol header was confirmed from the owner's working browser
capture and the bank's inspected public web client. It is not the app release
version and applies only to check-cif. The phone capture without this header
returned status zero with null token/message; that response remains invalid.
No automated live identity submission proves this header was the sole cause.
A fresh on-device CAPTCHA is required for live acceptance. Set-Cookie alone does
not establish a cookie requirement: no cookie jar or copied browser
Origin/Referer/Sec-Fetch headers were introduced.

## CAPTCHA image and session binding

The endpoint labels its Base64 text as image/jpeg. Retrofit requests plain text
and returns `HttpResponse<String>` so Data can access both body and headers.
Data strips CRLF, accepts at most two Base64 text layers and stops at JPEG/PNG
bytes. A previously recorded five-response check found incomplete JPEG EOI
markers in four responses. The mapper completes only missing terminal EOI bytes,
then validates an actual frame with Flutter's codec and disposes the temporary
frame/codec. It does not fabricate image content or automatically retry.

Invalid images return `auth.captcha_invalid_response`. A missing/blank SessionId
fails loading. `LoginCaptcha` contains both validated bytes and that response's
SessionId; AuthState has no duplicate session field. Refresh clears the old pair
and answer, and success replaces the pair atomically. There is no client-generated
SessionId or fallback. Regression fixtures use a synthetic JPEG and PNG.

CAPTCHA bytes stay in memory. UI uses `Image.memory` because AvpImage has no byte
source; no disk or network image cache is used. Refresh invalidates CAPTCHA
eligibility while preserving national ID/mobile.

`ip` remains the owner-approved fixed sample `192.168.0.1`; it is not detected
device IP. Bank confirmation is still needed before changing that policy.

## Layers, operations and failures

The three Login UseCases are defined in
`lib/features/auth/domain/usecases/login_usecase.dart`; the `_usecase.dart`
suffix follows the owner's filename clarification and contract v1.19.

AuthScreen directly constructs AuthCubit in its Provider and calls fetchCaptcha.
Cubit resolves `FetchLoginCaptchaUseCase`, `RequestLoginOtpUseCase` and
`VerifyLoginOtpUseCase` through final GetIt fields. All three are registered in
`core/di`; their constructors receive the registered AuthRepository there.
Cubit does not receive/forward a Repository or construct UseCases. Domain
UseCases call their repository interface and do not import GetIt. RemoteAuthRepository uses the generated Retrofit client,
maps DTOs to Equatable entities and catches transport, parse/mapping and storage
exceptions as Err. No DioException or DTO enters Cubit/UI.

AuthCubit now uses async/await for its three operations:

- `fetchCaptcha`: loading/invalidation, one fetch, then success or failure.
- `submitOtpRequest`: chooses the unavailable guest branch or owns the complete
  check-cif lifecycle directly, without a private request wrapper.
- `submitLogin`: loading, one verification, then completion or failure.

Each dependency call, await and Result switch appears once per operation.
`submitOtpResend` clears the old OTP session and awaits fetchCaptcha; Back from
OTP awaits that same action. The constructor preserves its supplied/default
initial State; it performs no initialization. State remains one plain Freezed
`.initial` factory, part of Cubit, with independent operation statuses.

Requests no longer clear failure/message merely for notification delivery.
Failure callbacks and typed-effect execution have separate focused subscriptions.
A pure Presentation switch helper, `presentation/login/cubit/auth_error_messages.dart`,
prepares approved Persian text with a generic fallback. Focused listeners observe
entering-failure transitions. Identical failures notify again after loading,
without effect/navigation/message counters or a parallel notifier. API errors
are not duplicated inline. Other UI labels/validation use `S.current`.

HTTP 200 with `status: -1, message: WRONG_CAPTCHA` maps in Data to
`Err(DataFailure('auth.wrong_captcha'))`. Unknown business rejections retain the
generic failure. They do not become DioExceptions. Cubit has no catchError,
try/catch, defensive loading/eligibility entry guards or closed/disposed checks.
The existing Data mapper already uses `UnexpectedFailure` for unknown exceptions;
phase 1 adds no Failure type or change to the shared failure hierarchy.

The notification migration preserves two explicit consumer-driven clears:
CAPTCHA start clears failure to dismiss the inline guest notice, and the guest
unavailable branch clears message so it cannot reuse an earlier API error text.
That branch retains its existing status/inline behavior without a new endpoint.
All actual API errors still prepare failure/message together. The effect handler
never checks retained message presence; success completion is unchanged.
Current migration verification is recorded in Login development: 220 regression
tests passed with one Web-only skip and analysis reported no issues.

## Flow behavior retained in phase 1

National-ID/mobile input actions validate only their own field once and immediately
show errors for nonempty invalid values. Focus-loss actions read stored validity.
CAPTCHA syntax errors clear on editing; server validation remains authoritative.
OTP is six digits. Eligibility predicates reuse stored validity and return values,
never State. No State-construction/publication intermediary is used.

The explicit CAPTCHA action attaches the Cubit-owned periodic clock once. Successful
check-cif records its start tick and starts the existing 60-second countdown.
Identity forms have no countdown emissions; expiry disables verification and
enables resend. With no supplied resend endpoint, resend/OTP Back returns to
identity and fetches a fresh CAPTCHA while retaining national ID/mobile. It never
replays the consumed CAPTCHA. Close cancels the clock. Late completion follows
the owner-approved lifetime policy in the coding contract; no disposal workaround
is added.

Opening change-phone and returning from its identity form directly emit
`AuthState.initial`, explicitly retaining the CAPTCHA pair and status. Other
inputs, validity/errors, challenge/countdown and pending effects reset to defaults.
This is an actual reset event, not constructor initialization. The cleared start
tick keeps the existing clock idle. Guest change-phone remains unavailable and
never calls a login endpoint as a substitute; its inline feedback is retained.

UI owns repeat-tap/edit availability and blocks system/in-screen Back while any
Login request is loading. Under the 2026-11-07 owner update, only the active
operation's button shows loading. CAPTCHA refresh shows loading only while
fetching CAPTCHA and is disabled during OTP requests. The countdown/resend
control retains its content during verification; its callback requires
`canResendOtp` and no pending verification. Specific actions own step decisions and raw guest
sheet-result interpretation. The listener consumes reusable commands before
Flutter operations and checks mounted after awaiting sheets. Completion invokes
the existing router/host callback; successful submission is disabled meanwhile.

## Final token storage and routing

`core/security/access_token_store.dart` owns the final token's memory copy.
Under the 2026-10-24 owner amendment, Android also persists it through
flutter_secure_storage 11.2.0 using its default Keystore-backed RSA-OAEP/AES-GCM
configuration, without biometric prompts. Web and other platforms are memory-only;
a new Web instance requires login. No localStorage, sessionStorage, cookies or
persistent iOS/desktop storage is introduced.

The repository awaits secure storage before returning Success. Write errors
become Err and do not complete login. The challenge token, OTP, identity and
customer response are not persisted. Android disables cloud Auto Backup and
excludes FlutterSecureStorage.xml and FlutterSecureKeyStorage.xml from backup
and Android 12+ cloud/device-transfer rules.

Startup restores a nonblank saved Android token before routing. This is the
owner-approved local resume decision without a server-validity check; it does not
claim expiry/revocation validity or restore customer records. Blank, missing or
unreadable storage requires login. Startup removes the obsolete
`prototype.authenticated.v1` marker and never trusts it. Isolated RouterSession
instances remain available for router tests.

Logout awaits deletion before clearing memory and route state. A deletion error
leaves the session unchanged for retry. No refresh/validation/logout endpoint or
synthetic expiry was supplied. No guessed request, automatic POST replay or
refresh-token rotation is implemented. Validated post-login return locations and
pending typed route inputs retain their existing behavior.

## Transport and integration limits

The shared Dio uses ordinary HTTPS validation, bounded timeouts, no redirect
following and no automatic POST replay. Approved current/backup SPKI pins and
expiry/rotation policy remain a production integration task. The owner removed
the unconfigured-pinning request blocker for review releases on 2026-10-25;
no invalid-certificate callback or trust-all adapter is installed.

The shared API logger follows the owner's temporary diagnostics instruction,
including Release troubleshooting from 2026-10-25. Factory registration and
callbacks use `AppConstants.apiLoggingEnabled`: API_LOGS defaults to true in all
modes and can be disabled with `--dart-define=API_LOGS=false`. It prints full URLs,
headers, bodies, errors, timing and HTTP/business outcomes without masking or
length truncation. Multipart fields/file metadata are printed without consuming
upload/response streams. Restart the app to recreate shared Dio after changing
the compile-time flag. Cubit/State logging was not expanded.

Still required from the bank: official OpenAPI/error codes, SPKI pins and expiry
policy, IP policy, OTP expiry/resend, token lifetime/validation/refresh/logout,
server idempotency and agreed correlation/security headers. Web access requires
server CORS. No missing bank contract is fabricated. Dashboard and other banking
features keep their existing mock adapters.

## Verification and generation

Tests use synthetic fixtures and a fake Dio adapter to check paths, headers,
JSON, image decoding, rejection/missing-token/customer mismatch, storage failure,
loading, countdown, Back, repeat notifications and router completion. Storage
checks use a fake platform channel, not the device Keystore. Live close/reopen,
Logout and fresh-CAPTCHA checks remain device acceptance work. Phase 1 performs
no live-bank request.

```sh
flutter analyze
flutter test test/auth test/core/router test/core/security test/core/network test/core/di
```

The native run skips `test/core/security/access_token_store_web_test.dart`;
that memory-only browser check requires Chrome. Test results for this phase are
recorded in the phase-1 verification section of Login development.

```sh
dart run build_runner build
dart run intl_utils:generate
```

Generated files are not hand-edited. Run the complete build_runner generator
when generation is needed: a filtered run can remove cached ignored Freezed
outputs outside its filter. Phase 1 changes neither State's shape nor DTOs and
needs no regeneration.

### Listener-composition follow-up verification — 2026-11-01

The shared phase-1/2/3 regression command passed 385 tests after the card-list and
virtual-request screen composition change. This flow’s existing composition and
local resource/modal consumers were preserved. See the command and final checks
in [the follow-up report](../cards/virtual-card-request.md#listener-composition-follow-up-verification).
