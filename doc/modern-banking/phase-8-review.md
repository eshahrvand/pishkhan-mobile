# Phase 8 — Modern banking, on-site transfer and request reports

> Historical migration record. The later owner amendment in contract v1.24
> withdraws its direct-Repository/optional-UseCase decisions. Current Cubits must
> use UseCases for all application/data operations. See the
> [follow-up review](../usecase-only-dependencies-review.md).


Scope/order: MobileBankCubit, MobileBankGuideCubit, TransferLimitsCubit,
MobileBankDeactivationCubit, OnSiteTransferCubit, RequestReportsCubit.
Apply contract v1.23 and the current Cubit/UI skills. Phase-7 documentation was
committed in `4ae403a` before work. Phase 9 is outside this task.

## Operation inventory before implementation

| Cubit | Owner action | Trigger / operation |
|---|---|---|
| Mobile bank | fetchMobileBank | Provider entry, Retry and refreshAfterService: operation-specific record/catalog |
| Mobile bank | submitIdentity | continueFlow from preview: existing prototype identity submission |
| Guide | None | Local page selection, explicit page reveal and Back/home only |
| Limits | fetchLimits | Provider entry / Retry: shared modern-banking catalog |
| Limits | submitLimits | Confirmed edit form: existing limit update |
| Deactivation | fetchMobileBank | Provider entry / Retry: shared catalog |
| Deactivation | submitDeactivation | Selected reason and consent |
| On-site transfer | fetchCatalog | Provider entry / Retry: source, address, schedule and fee |
| On-site transfer | submitDestination | Manual destination sheet: resolve selected recipient/context |
| On-site transfer | applyFileSelection | Raw native picker result: validate/upload file and publish progress |
| On-site transfer | submitTransfer | Confirmation: exact confirmed request snapshot |
| Reports | fetchReports | Provider entry / Retry: catalog and bank time |
| Reports | submitCancellation | Confirm cancellation: tracking ID and deterministic existing key |

Twelve requests have distinct owners. Guide has no request, so it receives no
status/failure/message fields. Existing Domain UseCases receive suffixes/GetIt
wiring; pure Domain filtering functions remain functions, without new layers.

## Flow readers and preservation map

| Flow | Readers / continuation | Preserved state and safeguards |
|---|---|---|
| Activation/recovery | Catalog record determines pending/approved/introduction or serial; serial, fees/consent, instruction, prototype preview, receipt | Independent activation/recovery records; original serial validity and retry identity. Back preserves form and discard semantics; child-service return refreshes the same catalog owner |
| Password guide | PageView owns Flutter controller; State owns actual selected page | Swipe updates the dot; indicator requests prepared page reveal. No request or ceremonial initial action. Preserve animation and resource disposal |
| Limits | Current values, editing controls/maxima, consent, success body | Own-field validation and stored sibling flags; unchanged payload reuses key; source deposit binding remains |
| Deactivation | Read-only username, selected reason, consent, existing success receipt | Same reason reuses identity; existing Back/confirmation and mock status change remain |
| Transfer source/visit | Source, transfer date, address, visit date, bank schedule and fee | Transfer-date edit resets dependent visit data. Local address collection stays flow-owned; Back retains valid previous steps |
| Manual destination | Typed inputs and independent lookup status, then prepared close effect | Request ID invalidates a dismissed/reopened editor. Success appends exactly one resolved record; errors retain draft |
| File selection/upload | Native picker result, upload progress, pending attachment, Review or Cancel | Picker/upload request identity rejects stale selection/progress/completion. Replacement cancellation preserves the previous reviewable file. No loading before actual file selection |
| Confirmation | Confirmed request, consent/wallet, receipt | Flow key and payload revision preserved; identical retry submits the exact snapshot. New payload renews the key; upload Review commits the selected attachment |
| Reports/list/filter | Catalog, bank time, identifier query, committed filters and visible records | Bank-day filtering and type-search normalization stay in Domain. Draft sheets borrow the same Cubit; Apply commits, dismiss/Cancel discard |
| Report details/cancellation | Selected report and pending-only cancellation action | Confirm uses existing tracking/key binding. Success replaces that report under current filters; a dismissed sheet's completion cannot close a different sheet |

All existing system/top-bar request gates remain. Actual draft/selection/command
resets and real request IDs are retained. Blanket error clears were removed
together with migration of their notification consumers. No banking/KYC
integration is added.

## Implementation and contract review

- Followed the six-Cubit order above. Each of the twelve requests retains one
  owner, now with `async/await` and an explicit Result switch. Trigger actions
  delegate; no request-publication helper, generic dispatcher, Cubit catch or
  disposal guard was introduced.
- Renamed `FetchMobileBankCatalogUseCase` and
  `UploadTransferDestinationsUseCase` and their files to the required suffixes.
  `core/di` registers both with repository constructor dependencies. Cubit uses
  final `fetchMobileBankCatalogUseCase` / `uploadTransferDestinationsUseCase`
  fields. Existing direct Repository operations stay direct; no new UseCase
  layer is added. Domain filtering remains pure functions in
  `filter_request_reports_usecase.dart`.
- Unexpected exceptions now become the existing `UnexpectedFailure` at the
  catalog/upload UseCase boundaries and the transfer mock Data adapter. Existing
  Result failures, validation, mock side effects and success data are unchanged.
- Five request screens group independent operation-failure and typed-effect
  listeners in `MultiBlocListener`, with `BlocBuilder` rendering. No listener
  treats retained message text as an event or a reason to skip an effect.
  Limits success uses its existing localized success body; receipts/modal
  effects execute after retry without clearing the old failure.
- Guide State still records the actual selected page. Its new typed commands
  prepare indicator-page animation and Back/home; UI retains/disposes
  PageController and reports actual page changes. Swipes do not request another
  animation. No artificial initial request/status is added.
- The report cancellation sheet retains its local `BlocConsumer`, which owns
  both its loading control and closing its own modal. This is a focused local
  subscription, not a second screen listener. Dismissed-request completion
  cannot close another filter sheet.
- Upload/destination request IDs, picker cancellation and progress handling,
  confirmed transfer snapshot, flow revision and idempotency keys remain.
  An unchanged confirmed payload keeps its key; payload change increments the
  revision only in the action. Repeated confirmation comparison is a pure
  predicate; independent upload-Review and manual-Next emits remain explicit.

## Duplication and flow-aware emit review

Nine repeated calculation/predicate groups were found and resolved:

| Cubit | Groups | Resolution |
|---|---:|---|
| Mobile bank | 1 | Payment eligibility shared by consent and forward/back navigation |
| Limits | 2 | Submit eligibility reads stored validity with the changed field; shared toman conversion |
| Transfer | 6 | Source eligibility, visit eligibility, destination/file presence, reviewed attachment presence, destination-form eligibility and confirmation-payload comparison |
| Guide / deactivation / reports | 0 | No additional repeated lifecycle or calculation needed extraction; existing Domain filtering remains shared |

Independent events' overlapping fields do not create artificial delegation.
The catalog availability predicate also names one long expression, as required
by the contract; it is not counted as duplication. There are no State-building
or State-publication helpers.

Removed 66 blanket `failure/message: null` assignments: mobile bank 8,
limits 7, deactivation 7, transfer 32, reports 12, guide 0. Each failure still
publishes status/failure/prepared message atomically. Real resets remain:
dependent visit date after transfer-date edit; fresh destination editor inputs;
pending upload/progress and Review eligibility after file replacement/removal;
picker initial status; fresh confirmation consent; filter drafts and consumed
commands. Their readers are listed in the flow map above. Successful submission
still disables the visible final action.

## Scoped verification — 2026-11-02

Baseline: 71 existing tests passed for the three changed feature modules,
modern-banking drawer and DI. The same 71 passed immediately after migration.
Final run: **88 tests passed**, including the additional notification/boundary
cases and directly related central routing/dashboard navigation:

```sh
flutter test test/modern_banking test/transfers test/requests test/dashboard/modern_banking_drawer_test.dart test/core/di test/core/router/app_router_test.dart test/dashboard/implemented_services_navigation_test.dart
```

Coverage includes repeated identical failures; retry-success with retained
failure text; navigation/filter/unavailable/receipt effects after errors;
activation/recovery separation; request identity; guide swipe/indicator;
stale upload/destination completions; replacement cancellation; bank-date
filtering; cancellation after sheet dismissal; and exception-to-Err conversion.
Test replacements are installed before lazy UseCases/Cubits resolve them.

```sh
flutter analyze lib/features/modern_banking lib/features/transfers lib/features/requests lib/core/di/injection_container.dart test/modern_banking test/transfers test/requests
```

Result: **No issues found**. Final `git diff --check` also passed. The code/style
review checked request ownership, explicit emits, independent statuses, final
dependency fields, suffix/import consistency, listener responsibility and the
flow readers above against contract v1.23.

Generated ignored Freezed outputs were refreshed with the existing full
build-runner command; this does not run the application test suite. No full-suite
tests, builds, dependency installation or design-system edits were performed.
SVG renderer diagnostics about existing unsupported filter/foreignObject
elements remain test-output noise; there were no test failures in the final run.
Real banking/KYC, native document selection and device execution are unverified.

The owner approved phase 8 and requested its commit before starting phase 9.

Duplication review: 9 repeated groups found, 9 resolved (pure predicates and
calculations). Flow review: 66 clears removed.
