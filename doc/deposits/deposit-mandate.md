# Deposit mandate

Route: `/deposits/proxy`; existing service ID: `deposit-proxy`. Dashboard and
deposit quick-service entries open the central route. An optional deposit number
is resolved by Cubit against the service catalog, normalizing Persian/Arabic digits.

The flow's implementation name is `deposit_mandate`: its presentation folder,
Domain files, Cubit/State, widgets and tests use `DepositMandate` naming.
The Persian title remains «سپرده وکالتی». The existing URL and service ID above
are retained for current callers and saved links. Existing mock record IDs,
error codes, request-key/receipt prefixes and artwork filenames also retain
their original values; this rename changes no request data or flow behavior.

Figma file `nYQNyZdSs98lwymCpt5Sag`, nodes `28060:13974` and `28060:13996`.
The owner explicitly requires company, subject and deposit to remain dropdowns,
including the filled subject field whose design omits the chevron.

## Behavior

- Fetch companies, subjects and eligible deposits from the repository. Company
  choice narrows the subject list. Choosing a subject first resolves its company.
- Subject choice narrows deposits to the eligibility mapping supplied by the
  service. An existing deposit is retained only if it belongs to the new set.
  Company changes clear the old subject and its derived information.
- Broker and amount come from the selected subject and are read-only. Cubit
  converts rial to toman for the helper; UI performs only localized display
  formatting. These values are not client-editable request amounts.
- Changing any selection clears terms acceptance. All three selections and
  fresh consent are required before submission. Loading disables controls and
  the button uses the existing loading state. Both Back paths stay blocked
  while catalog/submission requests are pending.
- Catalog errors expose Retry. Submission errors preserve the form and request
  identity; retry sends the same payload/key. Payload edits create a fresh key.
  Back/assistant requests confirmation after edits. Terms currently display the
  existing unavailable feedback. The receipt explicitly identifies mock completion.

## Ownership and reuse

`DepositMandateScreen` directly creates its Cubit inside `BlocProvider.create`
and invokes the real catalog fetch. Cubit resolves `FetchDepositMandateCatalogUseCase`
and `SubmitDepositMandateUseCase` through final GetIt fields; DI supplies their repository;
presentation classes are not registered. State retains the plain Freezed
`.initial` / `part of` structure and separate catalog/submission statuses.
Dependent selection, eligibility filtering, conversion, request construction and
exit-result interpretation stay in Cubit. Named, filtered listeners execute
Flutter navigation, dialogs and feedback. Application boundaries convert
unexpected repository exceptions into the existing `UnexpectedFailure`.

Reuses `CertificateSelect`, `CertificateInput`, `AppCheckbox`, `AppButton`,
`AppTopBar`, `AppAssistantButton`, `DepositDivider` and the exit dialog.
`DepositRequestFooter` is extracted from the existing restriction footer and
used by both flows; the existing restriction Bloc subscription and callbacks
remain at their owning feature boundary. `CertificateInput` gains an optional
text style, preserving existing defaults. The 14px amount-info icon is the
original Figma SVG; other icons and dashed divider reuse existing matching assets.

## Mock integration

`MockDepositMandateRepository` supplies the design's imported-car company,
subject, broker and 5,000,000,000-rial amount. Deposits ending in `.1` and `.2`
belong to that subject's preview eligibility set. A second explicitly labeled
demo company/subject uses deposit `.3` to exercise dependent selection.

The repository validates catalog/company/subject/deposit binding, rejects key
conflicts and duplicate subject/deposit mandates, and caches identical request
results. A lost response can be retried without another mock registration.
No real deposit mandate, bank block or balance reservation is created.
A live service must replace the repository and enforce ownership, current
eligibility, current terms and mandate amounts, atomic reservation/registration
and idempotency on the server. The UI must not infer authorization from these
preview values or from the generic deposit-list fixtures.

## Verification

`test/deposits/deposit_mandate_cubit_test.dart` and
`test/deposits/deposit_mandate_screen_test.dart` cover the two designed states,
all dropdowns, dependent resets, read-only fields, entry resolution, errors,
pending controls, Back, lost-response retry and mock-boundary tampering checks.
The form is also checked at 320px with larger text in fa/en/ar. Existing
restriction-screen, router and DI tests cover the shared-footer integration.
Set `CAPTURE_CERTIFICATE_PREVIEWS=1` to save previews under
`build/previews/certificates/deposit-mandate-*.png`.

The naming change is checked with this scoped regression command, covering the
flow, shared notification consumers, DI, routing, dashboard entry and artwork:

```sh
flutter test --no-pub test/deposits/deposit_mandate_cubit_test.dart test/deposits/deposit_mandate_screen_test.dart test/deposits/phase_6_notifications_test.dart test/core/di test/core/router test/dashboard/implemented_services_navigation_test.dart test/dashboard/presentation/flows/home/screens/dashboard_review_test.dart test/dashboard/presentation/flows/banking_overview/screens/deposits_screen_test.dart test/core/config/image_assets_test.dart
```

## Phase 6 notification and style adoption

Under [contract v1.22](../ui-cubit-state-agent-rules-en.md), request errors notify
on each operation's entering-failure transition. Every failure publishes status,
Failure and its prepared message together. Last failure/message remain through
loading, success, input and command changes; message presence is not an event.
Independent failure, typed-effect and receipt subscriptions share
`MultiBlocListener`; rendering uses `BlocBuilder`. Effects never inspect a retained
message before executing. Success uses the existing receipt, without replaying
old failure text. Retry/empty sections, actual validation and loading gates stay.
