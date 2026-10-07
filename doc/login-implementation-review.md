# Login implementation — updated Figma frames

The login section is implemented from the Mobile Figma file
`nYQNyZdSs98lwymCpt5Sag`. Screens share the bank header and background artwork;
form and OTP values are controlled by `AuthCubit`.

| Phase | State | Figma node | Preview |
| --- | --- | --- | --- |
| 1 | Empty login | `27847:4237` | [PNG](login-review/phase1-empty.png) |
| 1 | Filled login | `27847:4802` | [PNG](login-review/phase1-filled.png) |
| 1 | Waiting for OTP | `27847:4900` | [PNG](login-review/phase1-wait-otp.png) |
| 1 | Entered OTP | `27847:4988` | [PNG](login-review/phase1-enter-otp.png) |
| 2 | Guest services | `27847:4724` | [PNG](login-review/phase2-guest-services.png) |
| 3 | Empty change-phone form | `27847:4335` | [PNG](login-review/phase3-empty.png) |
| 3 | Filled change-phone form | `27847:4441` | [PNG](login-review/phase3-filled.png) |
| 3 | Waiting for OTP | `27847:4548` | [PNG](login-review/phase3-wait-otp.png) |
| 3 | Entered OTP | `27847:4636` | [PNG](login-review/phase3-enter-otp.png) |

## Components and composition

- `AuthHeader`: 56px header, 24px menu at the physical right, bank logo at the
  physical left, and the exported divider.
- `AuthSectionHeading`: exported 10×20px mark, 16px DemiBold title,
  8px gap, and 14px/20px supporting text.
- `AuthNumericField` composes the public `AppTextField` with 14px/20px
  typography, Persian/Arabic digit normalization, numeric input, and controlled
  values. Filled numeric values are LTR and right-aligned.
- `AppButton`: 40px send-code action and 44px OTP submission. The empty
  identity form retains the blue send-code action from Figma; invalid submission
  shows localized field errors. OTP submission is disabled until four digits are
  present and the code has not expired.
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

To regenerate visual review PNGs (PowerShell):

```powershell
$env:UPDATE_LOGIN_PREVIEWS = '1'
flutter test test/auth_screen_test.dart
```

Previews render the application content at the 375px reference width with the
package's Persian fonts. Native status/navigation bars and the operating
system's keyboard are excluded; their dimensions are supplied as viewport
insets. Golden tests are not introduced.