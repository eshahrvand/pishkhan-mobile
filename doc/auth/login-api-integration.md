# Login API integration

## Confirmed contract and temporary decisions

The owner supplied the request/response samples and confirmed the raw `token` header
on 2026-10-21. The owner explicitly approved provisional sample-based DTOs until
the bank supplies OpenAPI (architecture §10.1). JSON serializers and the Retrofit
client are generated with build_runner; generated files must not be edited.
No real identity, token, account or loan sample is included in source or tests.

Base URL: `https://apii.rqbank.ir`.

The shared Dio reads its API base URL and connect/send/receive timeouts from
`core/config/constant.dart` (`AppConstants`). Current network timeouts remain
15/20/20 seconds respectively. Only the existing bank API address is configured;
additional server addresses must come from confirmed service contracts.

| Operation | Method/path | Body | Success |
|---|---|---|---|
| CAPTCHA | `GET /captcha` | None | MIME Base64 text plus the `SessionId` response header. Despite `Content-Type: image/jpeg`, CRLF is stripped before Base64 decoding; the image is validated in memory. |
| Request OTP | `POST /check-cif` | `nationalCode`, `ip`, `mobile`, `captcha`, `sessionId` (all strings) | `status: 0` and a nonempty `token`. This is a challenge token, not an authenticated session. |
| Verify OTP | `POST /check-sms` | `code` (six-digit string) | `status: 0`, a nonempty final `token`, and a customer matching the submitted national code. |

`check-sms` sends `token: <challenge token>` (without a Bearer prefix). The final token
replaces the challenge only after validation. HTTP 200 or a message saying OK
alone never authenticates a user. Unknown failures use the approved generic Persian message;
Dio exceptions and DTOs remain in the Data layer.

`check-cif` also requires the client protocol header `version: ng-1`, as shown
in the owner's working browser capture and explicitly set by the bank's public
web client (`https://vc.rqbank.ir/main.f9ce156486acf1b1.js`). Retrofit sets it on
that operation only; it is not the application's release version. CAPTCHA and
check-sms keep their existing headers. The phone capture lacked this header and
returned `status: 0, message: null, token: null`; this still cannot establish an
OTP challenge. The header mismatch is confirmed, but no live check-cif submission
is automated to prove it is the sole cause. Recheck with a fresh CAPTCHA on-device.
Response Set-Cookie headers alone do not establish a cookie requirement: the
supplied browser request shows no Cookie header, and the bank's inspected login
calls do not enable cross-origin credentials. No cookie jar or copied browser
Origin/Referer/Sec-Fetch headers are introduced by this correction.

The owner-approved Login amendment in the UI/Cubit/State contract retains one
shared `Failure? failure`, with `String? message` in State and no separate
message counter.
`presentation/login/cubit/auth_error_messages.dart` maps known Failure codes to
Persian text with a switch and generic fallback. Cubit emits the prepared message
in the failure emit; the filtered UI Listener observes the operation entering
failure and displays the prepared text. Identical failures after retry are delivered
again through loading-to-failure transitions, without effect/message counters. There is no separate
message Listener or duplicate inline API-error display. The unconnected guest
change-phone flow retains its previous inline unavailable feedback and receives
no new message/effect handling. Starting a request clears failure/message without
publishing a new notification. Other UI text and field validation retain their existing localization behavior.

For `HTTP 200` with `status: -1, message: WRONG_CAPTCHA, token: null`, the Data
mapper returns `Err(DataFailure('auth.wrong_captcha'))`. The optional DTO message
is a technical discriminator, never raw display text. Unknown rejection messages
remain generic. No DioException or Cubit catchError is added for business rejection.

IP policy and CAPTCHA session binding:

- `ip` is the fixed sample value `192.168.0.1`; it is not device IP detection.
- `sessionId` comes exclusively from the `SessionId` header of the same CAPTCHA
  response (verified against the live endpoint on 2026-10-21). Retrofit returns
  `HttpResponse<String>` so the Data layer can read both headers and body.
  The image and ID are mapped together, then published atomically in State.
  `LoginCaptcha` is their single source; AuthState has no separate sessionId.
  Refresh clears the old image/ID/answer and replaces them with the new pair.
  A missing or blank header fails the CAPTCHA load and cannot enable an OTP request.
  Client-generated session IDs have been removed; there is no random fallback.

## Boundaries and behavior

`AuthScreen` creates `AuthCubit` directly and calls `fetchCaptcha()` in
`BlocProvider.create`. Cubit fields resolve actual application dependencies
through GetIt. Domain use cases call `AuthRepository`; `RemoteAuthRepository`
uses `AuthRemoteDataSource` (Retrofit) and maps DTOs into Equatable entities.
State remains plain Freezed data with independent CAPTCHA, OTP-request and
verification statuses. Cubit uses returned `.then` chains.

The Cubit keeps simple input validation and its dependent flags in one action.
Short eligibility conditions stay directly in `copyWith`. The longer OTP-request
predicate is calculated by `_canRequestOtp` from fresh/current validity flags and
the CAPTCHA status; it neither validates again nor constructs/publishes State.
`submitOtpRequest` chooses between the unavailable guest change-phone path and
the private login OTP operation, which retains its complete loading/Success/Err
lifecycle with explicit emits. The clock is attached once during CAPTCHA entry;
its countdown callback owns tick updates and expiry. The temporary 60-second
duration has one constant. This readability refactor changes no endpoint, State
field, public action contract or OTP policy.

Opening change-phone and returning from that identity form to Login now directly
emit `AuthState.initial`, explicitly retaining the current CAPTCHA image/SessionId
pair and its request status. Form inputs, validation, OTP/challenge/countdown,
request errors and pending commands receive their defaults. In particular, these
reset events clear an old effect instead of retaining it implicitly. They do not
fetch another CAPTCHA or cancel the flow-owned clock; the cleared `otpStartTick`
keeps it idle. Resend and Back from OTP still preserve identity data through their
existing partial updates and fetch a fresh CAPTCHA.

A five-response reliability check found one Base64 layer in every response, but
four decoded JPEGs were missing their terminal EOI byte(s) and failed Flutter
image decoding. Completing only the JPEG EOI marker allowed all five to decode.
The Data mapper now accepts at most two Base64 text layers, stopping as soon as
JPEG/PNG bytes are reached. For JPEGs without the final EOI marker it appends only
the missing marker byte(s), never image content. It then decodes a frame through
Flutter's image codec and disposes the temporary frame/codec before returning
LoginCaptcha. Unrecoverable or invalid image responses return
`auth.captcha_invalid_response`; they never publish a successful CAPTCHA State.
There is no automatic retry, fabricated image or fallback SessionId. Normal valid
JPEG/PNG bytes and their associated SessionId are preserved. Regression fixtures
use a synthetic 200×70 JPEG, not real bank CAPTCHA content.

CAPTCHA bytes stay in memory; there is no cached network image or disk file.
The image widget uses `Image.memory` because AvpImage has no byte-source API.
UI loading gates block repeated submissions, input edits and Back during requests.
Blocked Back now follows the owner-approved policy for all request-driven flows. The resend button
uses `isLoading` for verification and only `canResendOtp` in its onPressed gate.
The explicit initial action attaches the Cubit-owned clock. An OTP-success
snapshot records its start tick; identity screens produce no countdown emissions.
Closing immediately cancels the clock and closes the Cubit. As explicitly accepted
by the UI/Cubit contract, a late request completion can raise an uncaught emit-after-
close error; no closed/disposed guard or deferred-close workaround is introduced.

The local OTP countdown is 60 seconds pending an expiry field from the backend.
Expiry disables verification. With no resend endpoint supplied, requesting a new
code returns to the identity form and fetches a fresh CAPTCHA, preserving identity
fields. The consumed CAPTCHA is not automatically replayed. Change-phone uses no
login endpoint as a substitute; it reports that its own service is not connected.

`AccessTokenStore` in `core/security/access_token_store.dart` keeps the final
login token in memory. Token persistence belongs to this security infrastructure;
the network layer does not contain a second storage implementation. Under the owner's
2026-10-24 amendment, Android also saves that token with
`flutter_secure_storage: ^11.2.0`, using the package's default Keystore-backed
RSA-OAEP/AES-GCM protection without biometric prompts. Web and other platforms
remain memory-only; a fresh web page requires login. No browser token storage
or cookies are introduced, and iOS persistence is outside this Android task.

Only a successful check-sms response whose customer matches the login identity
can be persisted. The repository awaits the secure write before returning
Success; storage exceptions become Err through the existing Data failure mapper.
The OTP challenge token, OTP, identity and customer response are not persisted.

Android startup reads the saved token before routing. If a nonblank token exists,
the owner explicitly accepts entering the app without a server validity check
for now: there is currently no validation API. Missing, blank or unreadable
credentials require login. Resuming does not claim the token is unexpired or
unrevoked, does not restore customer records, and does not make requests to a
guessed endpoint. No local expiry duration is fabricated. A future authenticated
API/validation contract must establish server authorization and expiry handling.

Logout awaits secure token deletion, then clears memory and route state. If
deletion fails, it reports the error instead of claiming successful logout;
the session stays unchanged for retry. Android disables cloud Auto Backup and
excludes `FlutterSecureStorage.xml` and `FlutterSecureKeyStorage.xml` from legacy
backup rules and Android 12+ cloud/device transfer rules. Startup removes the
obsolete `prototype.authenticated.v1` preference and never trusts it.

No refresh token was supplied. Refresh-token storage/rotation is a future design,
not the role of the current saved token. No refresh endpoint or automatic retry
is introduced. Package configuration follows the
[11.2.0 package documentation](https://pub.dev/packages/flutter_secure_storage/versions/11.2.0)
and [Android backup guidance](https://developer.android.com/identity/data/autobackup).
Other banking features and dashboard data remain on their existing mock repositories.

## Transport and remaining bank dependencies

Dio uses HTTPS with normal certificate verification, bounded timeouts, no redirect
following and no automatic POST replay. In Debug builds only, the shared
ApiLoggingInterceptor prints the full URL
and query values, request/response headers and bodies without redaction,
allowlists or output-length limits. This includes SessionId, token, Authorization,
cookies, identity fields, OTP/CAPTCHA values, unknown JSON fields and raw Base64
or non-JSON responses. It also prints request numbers, timeouts, response type,
HTTP status, elapsed time and error details. HTTP 200 with a nonzero bank status
remains BUSINESS ERROR. The formatter does not modify request/response values.
Multipart fields and file metadata are displayed; file and live response streams
are not consumed by logging. All current Login calls use ordinary JSON/plain
responses and display their complete bodies. The logger lives in
`core/network/data/interceptors/api_logging_interceptor.dart`, with a separate
payload formatter. It applies to every API using the registered shared Dio, not
just Login. The owner enabled Release diagnostics on 2026-10-25. Registration
and callbacks use AppConstants.apiLoggingEnabled (`API_LOGS`, currently true by
default in all modes). Disable diagnostics with `--dart-define=API_LOGS=false`. Unit tests use synthetic data and fake transports;
no diagnostic probes or live-bank test switches are added to production code.
Hot restart a running app to recreate the shared Dio client.
The owner explicitly authorized temporary review releases without the local
`security.pinning_not_configured` request blocker on 2026-10-25. Debug, Profile
and Release now use ordinary HTTPS certificate validation; no invalid-certificate
callback or trust-all adapter is installed. Approved current/backup SPKI hashes,
expiry policy and rotation instructions remain required to implement architecture
§9.4 for production. The current code is not a completed pinning implementation.

Before production: obtain official OpenAPI/error codes, approved SPKI pins and
expiry handling, IP policy, OTP expiry/resend
contract, token lifetime/refresh/logout contracts, and confirmed server idempotency
support. Correlation/security header names must also be agreed with the bank;
they are not fabricated from the sample. Web cross-origin access requires server CORS.

## Verification

Tests use generated Retrofit code with a fake Dio adapter to inspect exact paths,
JSON keys and raw token-header handling. They cover wrapped Base64, invalid images/JSON,
HTTP errors, business rejection, missing tokens, customer mismatch, OTP length,
loading, retry, expiry, logout and removal of the prototype persistence behavior.
They also cover the supplied HTTP-200 WRONG_CAPTCHA response, unknown-message
fallback, repeated identical notifications, initial CAPTCHA error delivery,
retry clearing without notification replay, and blocked Back during requests.
Token tests simulate device storage across fresh store/session instances, ensure
only the final token is saved, and cover failed reads/writes/deletes and Logout.
A Chrome test verifies memory-only behavior even with an Android browser platform.
These storage tests use a fake platform channel, not the device's actual Keystore;
an on-device close/reopen/Logout check remains part of Android acceptance testing.
Fixtures use synthetic data. Real-network smoke testing requests only CAPTCHA;
no live identity submission or OTP verification is automated.

Generation:

```sh
dart run build_runner build
dart run intl_utils:generate
```

Run the complete generator to preserve ignored Freezed outputs used by other
features; a filtered build can remove cached generated files outside its filter.
