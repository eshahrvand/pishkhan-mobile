# Login API integration

## Confirmed contract and temporary decisions

The owner supplied the request/response samples and confirmed the raw `token` header
on 2026-10-21. The owner explicitly approved provisional sample-based DTOs until
the bank supplies OpenAPI (architecture §10.1). JSON serializers and the Retrofit
client are generated with build_runner; generated files must not be edited.
No real identity, token, account or loan sample is included in source or tests.

Base URL: `https://apii.rqbank.ir`.

| Operation | Method/path | Body | Success |
|---|---|---|---|
| CAPTCHA | `GET /captcha` | None | MIME Base64 text plus the `SessionId` response header. Despite `Content-Type: image/jpeg`, CRLF is stripped before Base64 decoding to in-memory image bytes. |
| Request OTP | `POST /check-cif` | `nationalCode`, `ip`, `mobile`, `captcha`, `sessionId` (all strings) | `status: 0` and a nonempty `token`. This is a challenge token, not an authenticated session. |
| Verify OTP | `POST /check-sms` | `code` (six-digit string) | `status: 0`, a nonempty final `token`, and a customer matching the submitted national code. |

`check-sms` sends `token: <challenge token>` (without a Bearer prefix). The final token
replaces the challenge only after validation. HTTP 200 or a message saying OK
alone never authenticates a user. Unknown failures use localized generic UI text;
Dio exceptions and DTOs remain in the Data layer.

IP policy and CAPTCHA session binding:

- `ip` is the fixed sample value `192.168.0.1`; it is not device IP detection.
- `sessionId` comes exclusively from the `SessionId` header of the same CAPTCHA
  response (verified against the live endpoint on 2026-10-21). Retrofit returns
  `HttpResponse<String>` so the Data layer can read both headers and body.
  The image and ID are mapped together, then published atomically in State.
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

CAPTCHA bytes stay in memory; there is no cached network image or disk file.
The image widget uses `Image.memory` because AvpImage has no byte-source API.
UI loading gates block repeated submissions, input edits and Back during requests.
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

AccessTokenStore is memory-only. A managed RouterSession requires a verified
token before sign-in and clears it on logout. Startup removes the obsolete
`prototype.authenticated.v1` preference instead of treating it as authentication.
A fresh application session requires login. No refresh token was supplied, so no
refresh endpoint, disk token persistence or automatic retry is invented.
Other banking features and dashboard data remain on their existing mock repositories.

## Transport and remaining bank dependencies

Dio uses HTTPS with normal certificate verification, bounded timeouts, no redirect
following and no automatic POST replay. In development/profile builds,
ApiLoggingInterceptor prints method, sanitized URL, HTTP status and success/error
results to the terminal. HTTP 200 with a nonzero bank status is labeled BUSINESS
ERROR. Only diagnostic response fields are exposed; credentials, identities,
banking records, query values and request headers/bodies are masked or omitted.
Raw CAPTCHA Base64, binary data and non-JSON pages are summarized. Output is
bounded and logging is not registered in release builds.
Development/profile traffic can use the supplied host. Mobile release traffic is
blocked with `security.pinning_not_configured` until architecture §9.4 can be
implemented using bank-approved current and backup SPKI hashes, expiry policy
and rotation instructions. Web relies on browser TLS as the architecture specifies.
The current code is not a completed certificate-pinning implementation.

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
Fixtures use synthetic data. Real-network smoke testing requests only CAPTCHA;
no live identity submission or OTP verification is automated.

Generation:

```sh
dart run build_runner build
dart run intl_utils:generate
```

Run the complete generator to preserve ignored Freezed outputs used by other
features; a filtered build can remove cached generated files outside its filter.
