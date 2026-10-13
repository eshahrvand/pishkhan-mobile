# Statement / average balance request

The three-step `AverageBalanceScreen` implements the six frames
`28060:13878`, `28060:14966`, `28060:14984`, `28060:15007`,
`28060:15025` and `28060:15087` in the Mobile Figma file.

The authenticated route is `/deposits/average-balance`. The
`deposit-statement` service and standalone deposit action open it with the
selected account number; explicit host callbacks retain precedence.

## State and behavior

Plain Freezed State and direct Cubit `emit(state.copyWith(...))` transitions
own deposit/condition selection, delivery information, fee display and submission.
Changing the deposit clears dependent conditions. Language and transaction type
are required before continuing. Back retains entered data. Other-recipient
details are required only when enabled; bank agent input is optional.

No calendar picker exists in the installed UI package; only Jalali formatting
is available. Per the owner instruction, dates remain optional, their picker
interaction is deferred, and they do not gate the Next button. Nullable domain
dates are Gregorian/UTC, with Jalali display formatting only in UI.

The address selector, local add/delete actions, conditional recipient fields,
optional agent field and expandable summary/invoice use existing package and
app components. Agent lookup is an explicit integration-unavailable action.
Local address changes last only for the flow lifetime.

The adapter supplies print/delivery fees and wallet balance. The sample costs
300,000 + 1,000,000 = 1,300,000 rial are illustrative. Server authorization,
official tariffs, real documents and wallet execution are not connected.
Mock submission returns a clearly marked demo receipt without charging or
issuing a certificate. Submission locks edits and duplicate requests; unchanged
retry retains its idempotency key. Stale/disposed asynchronous results are ignored.

## Validation

`test/deposits/average_balance_*_test.dart` covers six frame states, complete
navigation/submission, nullable dates, recipient requirements, optional agent
data, hidden-field omission, wallet gates, retry identity, race/disposal safety,
service routing and 320px screens with larger text in fa/en/ar.

Optional captures use `CAPTURE_CERTIFICATE_PREVIEWS=1` and write PNGs into
ignored `build/previews/certificates/`. Static assets are locally bundled and
registered in `AppAssets`; exact duplicate artwork is reused. The design's
OS status/navigation bars are reserved as viewport insets, not drawn by the app.
