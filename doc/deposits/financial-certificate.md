# Financial solvency certificate

`FinancialCertificateScreen` implements the eleven Mobile Figma frames
`28060:13889`, `28060:14588`, `28060:14667`, `28060:14746`, `28060:14762`,
`28060:14779`, `28060:14830`, `28060:14933`, `28060:14863`, `28060:14881`
and `28060:14907` in five steps: deposit/conditions, recipient/currency,
Latin identity, delivery and confirmation/payment fees.

The authenticated route is `/deposits/financial-certificate`. Both the
`deposit-certificate` service and deposit-list action pass the originating
account number. Explicit host callbacks retain precedence.

## State and behavior

Plain Freezed State and direct Cubit `emit(state.copyWith(...))` updates follow
the repository architecture. The Cubit receives its repository; widgets own
presentation, while the repository boundary contains asynchronous errors.

At least one condition is required. Changing the deposit clears conditions.
Embassy recipients require an embassy from the catalog and a currency. Other
authorities require a nonblank name and currency. Changing branches clears
the previous branch's values, and only the active branch enters the request.
The available embassies, currencies, accounts, addresses and fees are supplied
by the adapter; the default data is illustrative.

The Latin step requires name, surname, father's name, passport number, a valid
Gregorian expiry date (`YYYY/MM/DD` or `YYYY-MM-DD`) and a Latin address.
Persian digits are normalized to ASCII; a locally bundled OFL Roboto face keeps
passport/date/address numerals visually Latin. This is basic input formatting,
not passport verification. No future-expiry eligibility rule is inferred from
the design. There is no calendar picker; expiry can be typed directly.

Delivery, local address creation/deletion, optional bank agent input and the
expandable summary/invoice reuse the statement feature's composition. An
alternate delivery recipient requires name and ten-digit national identifier.
Local address edits last only during the flow. The Latin address uses a native
themed field with its own controller because the package textarea enforces a
130px minimum, while the design requires 90px. It grows with text scaling.

The wallet gates the final action. Submission locks duplicate requests and
edits, retries unchanged requests with the same key, omits hidden optional
fields and ignores stale or disposed asynchronous results. The default adapter
returns a clearly labeled demo receipt: no financial certificate is issued and
no wallet debit occurs. Bank verification, actual tariffs and payment execution
remain repository integration work.

## Validation

`test/deposits/financial_certificate_*_test.dart` covers all eleven reference
states, the complete five-step flow, both recipient branches, basic Latin/date
validation, digit normalization, delivery requirements, wallet eligibility,
duplicate/retry/disposal behavior, add/delete-address dialogs and service entry.
Compact 320px layouts are exercised in fa/en/ar with larger text and keyboard
insets. Optional frame captures use `CAPTURE_CERTIFICATE_PREVIEWS=1` and write
to ignored `build/previews/certificates/`.

The [statement/average-balance feature](average-balance.md) was implemented and
its focused tests passed before work on this second phase began. Its calendar
dates remain optional as requested.

## UI/Cubit contract adoption (2026-10-17)

Repository wiring belongs to GetIt rather than screen constructors. Conditions
are explicitly authored controls rather than parallel label/index arrays. Cubit
owns field-update actions, Back/primary-action decisions and address/agent
interaction intents. The existing Latin multiline rendering is retained; its
package-component limitation is documented in the adoption report.

### Dependency and listener clarification (2026-10-17)

The screen/feature-flow widget owns BlocProvider.create, including Home in
DashboardScreen; GoRouter only selects the destination. Cubits resolve existing
Repository/service/UseCase registrations through GetIt fields, without dependency
constructor arguments from UI. Multi-case and substantial async listeners use
named widget/State methods with the existing listenWhen filter.
