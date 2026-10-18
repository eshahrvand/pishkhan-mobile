# Login Development

## UI structure after the auth refactor

`AuthScreen` lives in
`lib/features/auth/presentation/login/screens/auth_screen.dart`. Its `widgets/`
folder contains six files:

- `auth_header.dart`: bank header and menu action.
- `auth_identity_form.dart`: explicit identity inputs, change-phone notice,
  CAPTCHA and request-code button.
- `auth_otp_form.dart`: OTP input, independently subscribed countdown/resend
  control and submission button.
- `auth_form_shared.dart`: the heading reused by identity and OTP forms.
- `auth_services_sheet.dart`: guest-service sheet composition and section titles.
- `auth_services_grid.dart`: responsive service rows and their tile composition.

Small field icons, CAPTCHA rows, countdown controls and service labels/tiles
remain inline in their owning section. The identity form is intentionally larger
than the usual 200-line review point so the complete fixed form is readable in
one file. Existing focused subscriptions, validation callbacks, geometry and
flow-transition keys are preserved. The authoritative style rules are the
[UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md).

The login section is implemented from the Mobile Figma file
`nYQNyZdSs98lwymCpt5Sag`. Screens share the bank header and background artwork;
form and OTP values are controlled by `AuthCubit`.

| Phase | State | Figma node |
| --- | --- | --- |
| 1 | Empty login | `27847:4237` |
| 1 | Filled login | `27847:4802` |
| 1 | Waiting for OTP | `27847:4900` |
| 1 | Entered OTP | `27847:4988` |
| 2 | Guest services | `27847:4724` |
| 3 | Empty change-phone form | `27847:4335` |
| 3 | Filled change-phone form | `27847:4441` |
| 3 | Waiting for OTP | `27847:4548` |
| 3 | Entered OTP | `27847:4636` |

## Components and composition

- `AuthHeader`: 56px header, 24px menu at the physical right, bank logo at the
  physical left, and the exported divider.
- `AuthSectionHeading`: exported 10×20px mark, 16px DemiBold title,
  8px gap, and 14px/20px supporting text.
- Login, CAPTCHA, and OTP use the public `AppTextField` directly with 14px/20px
  typography, Persian/Arabic digit normalization, numeric filtering and explicit
  limits. Optional `value` and `onFocusLost` parameters provide controlled text
  and focus-loss validation. Empty and filled text stays RTL with
  `TextAlign.start`. The intermediary `AuthNumericField` has been removed.
- `AppButton`: 40px send-code action and 44px OTP submission. The send-code
  action uses `isActive: state.formValid` and remains disabled until the national
  ID checksum, mobile format and six-digit CAPTCHA format are valid. CAPTCHA
  correctness remains server-owned. `isLoading` reads the request status and
  displays the package spinner while blocking interaction. Keyboard submission
  also respects the Cubit's loading guard. OTP submission is disabled until four
  digits are present and the code has not expired.
- CAPTCHA and timer slots are 148px wide, separated from the field by 7px.
- `AuthServicesSheet`: 528px at the reference viewport, 56px shared header,
  20px/32px body insets, 104px service rows, and 24px/12px section gaps.
  Content scrolls when the available height is smaller; service tiles wrap on
  narrow viewports.
- Login and change-phone OTP screens use the same title and submit label, as in
  the supplied frames. System back returns to the preceding form and retains
  its entered values; back from change-phone returns to login.
- `AppLoginColors` is exported by `avp_ui` for the exact login-specific
  notice and service-label tokens. `AppTextField.textAlign` is an additive
  public parameter; existing callers retain `TextAlign.start`.

## Assets

The background PNG is an export of the background artwork node
`27847:4238`, not a screenshot of the screen. All visible login SVGs and
the CAPTCHA example are downloaded from the supplied frames and registered
in `AppAssets`. Existing asset paths are reused.

## Interaction and integration

This remains a UI prototype. OTP issuance, verification, and CAPTCHA challenge
generation are not connected to bank APIs; the bundled CAPTCHA is the Figma
example. Refresh clears its entered value. The UI does not claim a completed
server authentication.

`AuthScreen.onAuthenticated` is the completion callback for either OTP path.
`onGuestServiceRequested` reports service and related-link IDs to the caller.
Selecting change-phone in the guest sheet opens its form directly.

Validation runs on focus loss and submit, and an error clears on editing.
`BlocSelector` isolates field, button, and countdown rebuilds.
Resend becomes available after expiry and clears the previous OTP.

## Verification

`test/auth_screen_test.dart` covers all nine frame states, reference geometry,
localized validation, Persian numeric input, disabled OTP submission, resend,
back navigation with retained values, and guest-service callbacks.

package's Persian fonts. Native status/navigation bars and the operating
system's keyboard are excluded; their dimensions are supplied as viewport
insets. Golden tests are not introduced.

## Cubit/State coding convention

Follow [architecture Section 12](../architecture-smart-virtual-counter-v2-en.md#12-state-management-with-cubit) for new work and refactors. State is a plain Freezed data class with defaults and independent request statuses. Cubits accept an initial State, compute UI data and eligibility, and emit immutable snapshots through `copyWith`. UI reads those fields directly; no custom State/Cubit getters or UI-facing rules facade is used. Dependencies remain injectable and lifecycle/duplicate-request safeguards stay in place.

## UI/Cubit contract adoption (2026-10-17)

AuthCubit is constructed directly in BlocProvider.create and disposed with its scope. GetIt contains data dependencies only; it never registers Cubits.
OTP completion, OTP focus intent and guest-service selection are Cubit actions;
a filtered listener executes typed AuthEffect values. The guest sheet returns a
raw service ID; it no longer chooses the change-phone flow. No bank API is added.

### Dependency and listener clarification (2026-10-17)

The screen/feature-flow widget owns BlocProvider.create, including Home in
DashboardScreen; GoRouter only selects the destination. Cubits resolve existing
Repository/service/UseCase registrations through GetIt fields, without dependency
constructor arguments from UI. Multi-case and substantial async listeners use
named widget/State methods with the existing listenWhen filter.
