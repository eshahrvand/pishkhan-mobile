# Login development and review

Reviewed: 2026-11-01 — Cubit migration, phase 1 and UseCase DI correction.

Login uses the bank CAPTCHA, check-cif and check-sms endpoints. Guest
change-phone remains unconnected. The [API integration document](../auth/login-api-integration.md)
records the confirmed wire contract, token handling and temporary bank decisions.

The [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md), including its
owner amendments, is authoritative. The
[Cubit clean-code skill](../../.agents/skills/pishkhan-cubit-clean-code/SKILL.md)
provides the operation inventory, flow review and duplication review workflow.
This document describes current implementation; it introduces no new rules.

## Ownership and files

| Location under `lib/features/auth/` | Responsibility |
| --- | --- |
| `presentation/login/cubit/auth_cubit.dart` | Specific input, request, countdown, guest-selection and Back actions |
| `presentation/login/cubit/auth_state.dart` | Plain Freezed `.initial`, part of Cubit; independent CAPTCHA, OTP-request and login statuses; latest failure/message and typed effect; generated State string output disabled |
| `presentation/login/screens/auth_screen.dart` | Provider, named filtered effect listener, overall composition and Back gate |
| `presentation/login/widgets/auth_identity_form.dart` | Explicit identity inputs, change-phone notice, CAPTCHA and request button |
| `presentation/login/widgets/auth_captcha_field.dart` | Controlled CAPTCHA answer, refresh and in-memory image |
| `presentation/login/widgets/auth_otp_form.dart` | Controlled OTP, countdown/resend and submit |
| `presentation/login/widgets/auth_request_error.dart` | Existing inline unavailable feedback for guest change-phone |
| `presentation/login/widgets/auth_header.dart`, `auth_form_shared.dart`, `auth_services_sheet.dart`, `auth_services_grid.dart` | Header, shared heading and guest-service UI |

AuthScreen directly creates `AuthCubit(initialState: initialState)..fetchCaptcha()`
in `BlocProvider.create`. That Provider owns closing; ordinary rebuilds retain
its instance. GetIt registers data dependencies, never Cubit. The Cubit resolves
three final UseCase fields internally: `FetchLoginCaptchaUseCase`,
`RequestLoginOtpUseCase` and `VerifyLoginOtpUseCase`. Each is registered in
`core/di`; that composition root supplies AuthRepository to its constructor.
Cubit neither holds a Repository nor constructs UseCases. UI/router do not
receive or forward these dependencies. Construction preserves the supplied/default State unchanged and
starts no request or timer.

## Operation inventory

| Operation | Owner action | Triggers | Result |
| --- | --- | --- | --- |
| Fetch CAPTCHA | `fetchCaptcha` | Provider entry, refresh, resend; OTP Back delegates to resend | Image/SessionId pair or prepared failure |
| Request login OTP | `submitOtpRequest` | Identity button or keyboard | Challenge, OTP step, masked mobile and countdown start, or prepared failure |
| Verify login OTP | `submitLogin` | OTP button or keyboard, with the non-null challenge | Completion effect after token persistence, or prepared failure |

Each owner contains its dependency call, await, Result switch and explicit
loading/success/failure emits once. `submitOtpRequest` also selects the existing
unavailable change-phone branch without calling a bank endpoint. The former
private login-OTP request wrapper is removed; the lifecycle is visible in the
specific action. No generic dispatcher or State-publication helper was added.

## User path and State consumers

| Step/event | Readers and data | Continuation and retention |
| --- | --- | --- |
| Login identity | Identity form reads values/errors; CAPTCHA reads image/answer/status; button reads eligibility/status | Failure preserves identity. Success opens OTP in the same Cubit. |
| CAPTCHA refresh | CAPTCHA input/image and request button read the cleared answer, image pair, validity/error and eligibility | Retains national ID/mobile; the old answer cannot enable a request against a new session. |
| Login OTP | OTP form reads challenge, masked mobile, code, countdown, eligibility and login status | Failure preserves challenge/code for retry. Success asks the host/router to complete login. |
| OTP Back or resend | `requestBack` delegates to `submitOtpResend`, then `fetchCaptcha` | Returns to identity, retains national ID/mobile, clears the old challenge/code/countdown and fetches a fresh CAPTCHA. Both Futures await that fetch. |
| Guest change-phone | Identity inputs, CAPTCHA and inline unavailable feedback | Request stays on the form and calls no login endpoint. Back resets to Login. |
| Open/leave change-phone | Explicit `AuthState.initial(...)` | Retains CAPTCHA image/SessionId pair and status; other fields, errors and effects take their defaults. |
| Guest menu | Listener opens sheet; raw nullable ID returns to `selectGuestService` | Dismissal does nothing; Cubit selects change-phone or a typed host-callback effect. |

OTP-request success no longer repeats `otp: ''`, `isOtpValid: false` and
`canSubmitLogin: false`: normal entry already has these values, and return/resend
clears them before another challenge. Final login success still disables submit
while the host completes navigation. CAPTCHA invalidation, resend resets,
loading failure/message clears and actual form resets retain their owners.

## Validation, requests and effects

National-ID and mobile updates each run their central validator once and publish
the fresh value, stored validity and typing error. Every nonempty invalid input
shows its error immediately; focus-loss actions read stored validity. CAPTCHA
checks six-digit syntax; editing clears its shown syntax error and focus loss
reads stored validity. Its actual answer is server-validated. OTP also uses six
digits. Aggregate eligibility reads other stored flags; repeated predicates are
private calculations returning values, never State.

Request actions return `Future<void>` with async/await and a Result switch after
await. Data converts transport, mapping and storage exceptions to Err. Loading
clears failure/message; failures publish operation status and text prepared by
`getAuthErrorMessage`. The Listener observes entering-failure transitions, so
identical retry failures notify again without counters or duplicate inline API
messages. Unconnected change-phone keeps its separate inline feedback.

UI owns loading/disabled controls and system/in-screen Back gating. Actions do
not repeat these preconditions. Loading buttons use `isLoading` and the relevant
eligibility flag; keyboard callbacks also gate loading because they lack a
loading-button API. The listener consumes reusable interactions before executing
Flutter effects, checks `context.mounted` after sheets and returns raw selections
to Cubit. Completion invokes the existing host callback.

The existing 60-second countdown starts from the successful challenge's clock
tick. Its periodic clock attaches once in the explicit CAPTCHA action, stays idle
when `otpStartTick` is null and is cancelled in `close()`. Expiry disables
verification and enables resend. No disposal guards, overlap counters, new timing
policy or new effect framework were introduced.

## UI and reference frames

UI uses Persian `S.current`, RTL, `AppTheme.light()` and public avp_ui controls.
Inputs are controlled by State. This phase preserves existing artwork, geometry,
theme overrides, focused subscriptions and form-transition keys. CAPTCHA uses
`Image.memory` because AvpImage has no in-memory byte input. The identity form
stays cohesive despite exceeding the usual file-size review point.

Reference file: `nYQNyZdSs98lwymCpt5Sag`.

| Frame | Figma node |
| --- | --- |
| Empty / filled Login | `27847:4237` / `27847:4802` |
| Waiting / entered Login OTP | `27847:4900` / `27847:4988` |
| Guest services | `27847:4724` |
| Empty / filled change-phone | `27847:4335` / `27847:4441` |
| Waiting / entered change-phone OTP design | `27847:4548` / `27847:4636` |

Change-phone OTP frames are design states, not a connected change-phone API.
App artwork uses `AppConstants.baseImage`. The bundled CAPTCHA is a design/test
asset; live challenges come from the bank.

## Verification

Relevant suites cover response mapping, six-digit OTP, identity validation,
CAPTCHA replacement, loading/Back gates, repeated notifications, countdown,
resets, token persistence and router completion/return paths. Phase 1 adds
regressions for pending Back/CAPTCHA completion followed by a fresh challenge,
and pending verification followed by a failure retaining retry data.

```sh
flutter analyze
flutter test test/auth test/core/router test/core/security test/core/network test/core/di
```

The Web token-store test is skipped by native runs and needs a browser run.
Tests use synthetic identities, fake repositories/transports and storage channels;
they submit no real identity/OTP. Native secure-storage and live-device acceptance
remain separate from these automated checks. See the API document for integration
limits and generation commands.

### Phase-1 verification — 2026-11-01

| Check | Before refactor | After refactor |
| --- | --- | --- |
| `flutter analyze` | No issues | No issues |
| Relevant native suites above | 119 passed, 1 skipped | 121 passed, 1 skipped |
| Skipped case | Web-only token store | Same Web-only token-store case |

The two additional cases exercise Back awaiting CAPTCHA and retaining verification
retry data. No browser run, live-bank call or device acceptance was performed.
State shape, UI, API payloads, storage policy and countdown policy are unchanged.

Duplication review: 1 repeated field group found, 1 resolved (OTP defaults are
already owned by resend). All 3 request lifecycles have one owner. Flow review:
3 repeated clears removed from OTP-request success.

### UseCase DI correction — 2026-11-01

The three Login UseCases now have explicit `UseCase` suffixes and lazy-singleton
registrations. AuthCubit resolves those registered instances into final fields;
Repository constructor wiring occurs only in core/di. The DI regression test
replaces AuthRepository in an isolated container before first UseCase resolution,
then exercises CAPTCHA, OTP request and verification through that container's
UseCases. Tests reset registrations between scopes; replacing a Repository does
not rewire an already-resolved lazy-singleton UseCase.

After this correction, `flutter analyze` reports no issues and the same native
suites pass 122 tests with the same single Web-only skip. No flow behavior or
State fields were changed by this correction.

Duplication review: 0 repeated blocks introduced; all 3 request operations still
have one owner. Flow review: 0 clears added or removed by the DI correction.
