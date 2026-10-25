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
retry retains its idempotency key. Request-ID checks cover genuinely overlapping catalog responses. Provider owns
the Cubit lifetime under the current UI/Cubit contract.

## Validation

`test/deposits/average_balance_*_test.dart` covers six frame states, complete
navigation/submission, nullable dates, recipient requirements, optional agent
data, hidden-field omission, wallet gates, retry identity, overlapping fetches and Provider ownership,
service routing and 320px screens with larger text in fa/en/ar.

Optional captures use `CAPTURE_CERTIFICATE_PREVIEWS=1` and write PNGs into
ignored `build/previews/certificates/`. Static assets are locally bundled and
referenced with `AppConstants.baseImage`; exact duplicate artwork is reused. The design's
OS status/navigation bars are reserved as viewport insets, not drawn by the app.

## UI/Cubit contract adoption (2026-10-17)

Repository wiring belongs to GetIt rather than screen constructors. The Cubit
owns Back/primary-action decisions and address/agent interaction intents. The
shared delivery form sends individual recipient-field events without resending
State-owned sibling values. Receipt/dialog results return to Cubit.

### Dependency and listener clarification (2026-10-17)

The screen/feature-flow widget owns BlocProvider.create, including Home in
DashboardScreen; GoRouter only selects the destination. Cubits resolve existing
Repository/service/UseCase registrations through GetIt fields, without dependency
constructor arguments from UI. Multi-case and substantial async listeners use
named widget/State methods with the existing listenWhen filter.

## Shared address feature

Address form, Cubit and State live in `features/address/presentation/editor`.
This flow opens it through `ServiceRegistry.openAddressEditor` and returns the raw
result to its own Cubit. Core `DeliveryAddress` is the common entity;
`CertificateAddress` remains a compatibility alias. Recipient/agent fields and
summary visuals are reused from `lib/shared/widgets` without another copy of
address State. Profile address management and registry verification remain
separate integrations.

See [Deposits development](development.md) and
[Cheque development](../cheque/development.md) for current routing, mock boundaries
and address reuse. The cheque postal-office helper finds offices; it does not own
this editor's postal-code validation.
