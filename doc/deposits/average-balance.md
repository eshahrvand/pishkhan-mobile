# Statement / average balance request

**Current dependency rule — contract v1.24:** application/data operations follow
Cubit → registered UseCase → Repository. Cubit imports/resolves UseCases only;
`core/di` wires their repositories. Any earlier direct-Repository or optional-
UseCase wording below is historical and superseded. Payloads, Result mapping,
validation, retry identity and UI behavior remain unchanged. See the
[UseCase-only migration review](../usecase-only-dependencies-review.md).


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
retry retains its idempotency key. Catalog controls gate invocation; no
speculative request ID or disposal guard is used. Provider owns
the Cubit lifetime under the current UI/Cubit contract.

## Validation

`test/deposits/average_balance_*_test.dart` covers six frame states, complete
navigation/submission, nullable dates, recipient requirements, optional agent
data, hidden-field omission, wallet gates, retry identity and Provider ownership,
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
registered UseCases through final GetIt fields, without dependency
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

Shared address editor migration is recorded in [phase 5](../profile/phase-5-review.md). Its
`ServiceRegistry.openAddressEditor` entry/result contract and this flow’s existing
address inputs, cancellation and validation remain unchanged.

## Phase 7 adoption and current verification

Under [contract v1.23](../ui-cubit-state-agent-rules-en.md), every request owner
uses async/await and a Result switch. UseCase fields are final,
without leading underscores; UseCase fields carry the full lowerCamelCase class
name including `UseCase`. Used UseCase classes/files have the required suffixes
and are resolved from GetIt; UI/router do not forward dependencies.

Independent request-failure, typed-effect/navigation and receipt listeners share
`MultiBlocListener` with `BlocBuilder` rendering. Each failure publishes status,
Failure and prepared text together. Notifications observe entering failure for
that operation, including identical retries. Latest failure/message remain
through loading, success and commands; effects do not gate on their presence.
Success uses the existing receipt instead of displaying retained failure text.
Actual form/draft/selection resets, validation, request identity and navigation
remain. See [phase 7 review](phase-7-review.md) for flow readers, dependency wiring,
consumer-driven clears and the final scoped commands/results. Historical broad
verification statements are not permission to run the full application suite.

The shared `LoadCertificateCatalogUseCase`, in `average_balance_usecase.dart`,
has two named GetIt registrations: `average-balance` uses
`DepositCertificatesRepository`; `financial-certificate` uses
`FinancialCertificateRepository`. Each Cubit resolves its own registration in
`loadCertificateCatalogUseCase`. This preserves the existing shared catalog
validation. Submission uses `SubmitAverageBalanceUseCase` from `average_balance_usecase.dart`,
wired to its corresponding repository by core/di. Cubit resolves the UseCase only;
it neither imports the repository nor passes a repository callback to a boundary.
The exact submitted request/key and UnexpectedFailure mapping are preserved.
Catalog validation is covered by the existing failure policy too.
Catalog entry still resolves supplied initial data and derives its validity;
subsequent input actions validate only the changed field and use stored sibling
flags. No additional passport-expiry or date policy was introduced.
