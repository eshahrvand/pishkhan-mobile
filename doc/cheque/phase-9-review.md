# Phase 9 — Postal offices and cheque flows

Scope/order: PostalOfficesCubit, ChequeClearanceCubit,
ChequeCancellationCubit, ChequeBookCubit. Contract v1.23 and the current Cubit/UI
skills apply. Phase 8 was committed in `3a808b8` before this work.

## Request inventory before implementation

| Cubit | Owner | Triggers / operation |
|---|---|---|
| Postal | fetchProvinces | Provider entry / Retry: province and city catalog |
| Postal | searchPostalOffices | Search: offices for the selected city |
| Clearance | fetchCatalog | Provider entry / Retry: deposits and reasons |
| Clearance | submitClearance | Confirmed form: clearance request |
| Cancellation | fetchCatalog | Provider entry / Retry: deposits, types and reasons |
| Cancellation | fetchCheques | Selection Next / Retry: selected account/type list |
| Cancellation | submitCancellation | Final Next: confirmed request snapshot |
| Book | fetchCatalog | Provider entry / Retry: applicant/accounts/leaf counts |
| Book | fetchResidency | Selection Next / check Retry: registry residences |
| Book | deleteAddress | Registry deletion confirmation; delivery-only removal stays local |
| Book | applyAddressResult | Raw editor result: save selected delivery address; Cancel does nothing |
| Book | fetchQuote | Delivery Next / Retry: quote for the exact delivery draft |
| Book | submitIssuance | Final action: confirmed draft, quote and stable key |

Thirteen requests retain distinct owners. Their existing UseCases receive
class/file suffixes and GetIt wiring; this does not add new application layers.

## Flow map and emit readers

| Flow / step | Readers and continuation | Preserved data / reset need |
|---|---|---|
| Postal location | Province/city selectors and Search | Province resets dependent city/results; city resets results/status. Pending request blocks selection, Back and close |
| Postal results | Retrieved addresses, Share or Back/search again | Back preserves chosen location. Share uses prepared text and consumed effect; native chooser remains UI-owned. Reopening owns a new Cubit |
| Clearance form | Deposit, cheque syntax/not-found error, selected reason, document instructions, conditional letter and consent | Deposit clears its cheque; reason clears dependent letter/consent. Retry preserves request key. Inputs renew the key as before |
| Clearance result/exit | Receipt on success; inline not-found error and operation feedback on failure | Success disables submit and clears hasChanges for actual exit behavior. Back/assistant confirm only edited forms; receipt dismissal returns Home |
| Cancellation selection/list | Deposit/type, fetched records, search and selected entries | Account/type changes clear dependent selection and confirmed request. Search preserves hidden selections. Existing list request ID rejects older replies |
| Review/reasons | Selected records, delete confirmation, individual/common reason drafts | Next opens review; explicit review Back advances only when requested and entries remain. Outside/system dismissal stays. Removing last reason-stage item returns to list |
| Cancellation confirmation | Exact selected records/reasons snapshot and consent | Returning without edits preserves key; payload edits invalidate snapshot; consent reset belongs to a fresh confirmation. Receipt returns Home |
| Book selection/check | Optional entry deposit, per-account counts and registry result | Account/count changes invalidate dependent quote/snapshot. Existing residency request ID preserves newest response |
| Book residency | Registered/unregistered residence cards, delete and acknowledgement/Next | Registry deletion recalculates eligibility from returned residences. Local delivery removal does not mutate registry. Single-unverified acknowledgement returns Home |
| Book delivery | Selected saved address, recipient validity, optional agent | Address save returns selected data; cancellation leaves form intact. Back retains earlier inputs. UI owns editor/modal resources |
| Book quote/confirmation | Quote binding, exact draft, totals/wallet and submission key | Existing quote request ID rejects old reply. Submission retries exact snapshot/key; quote renews key as before. Success disables action; receipt Home |

System/header request gates, real request IDs and server-side mock validation
remain. Existing local Consumers retain controller/modal responsibilities; screen
request feedback and typed effects are separated together with blanket
failure/message clears. No live banking/postal service is introduced.

## Implementation and final contract review

- Migrated the four Cubits in the declared order. Each of the thirteen request
  owners has exactly one dependency call, `await` and Result switch. Continuation
  actions delegate. Existing list/residency/quote request IDs and their
  invalidation remain; no extra counter or disposal guard is introduced.
- Renamed all thirteen existing UseCase classes with the `UseCase` suffix and
  all four grouped files with `_usecase.dart`: postal `lookup_usecase.dart`,
  cheque `cheque_clearance_usecase.dart`, `cheque_cancellation_usecase.dart` and
  `cheque_book_usecase.dart`. DI registers them with the appropriate repository.
  Cubits resolve final fields with complete lowerCamelCase names, with no leading
  underscore, Cubit-side construction or repository forwarding. Domain remains
  independent of GetIt. Repository fields used solely for wiring were removed.
- Preserved each existing Domain `try/catch` boundary and `UnexpectedFailure`
  conversion. No extra request layer, dependency or adapter was introduced.
- All four flow boundaries use focused operation-failure and typed-effect
  listeners in `MultiBlocListener`, with `BlocBuilder` rendering. Clearance's
  existing loading-focus/success-receipt listener remains separate in the same
  list. Failure handling always publishes status/failure/prepared message
  together; effects never inspect retained message presence.
- Cancellation's local content Consumer still owns scroll-to-step; the local
  review Consumer still owns nested deletion. Their layout timing, command
  consumption and Provider lifetime remain. The redundant header builder was
  removed because the screen already renders from that same State.
- Plain Freezed State.initial / part-of organization and all independent
  operation statuses remain unchanged; no code-generation refresh was needed.
- Checked initial Provider actions, changed constructors, callbacks and
  listeners against contract v1.23. UI owns native sharing, modals, focus and
  scroll, while Cubit retains validation, raw modal-result interpretation,
  request payloads and flow decisions. Existing controls retain pending-request
  gates; no defensive duplicate Cubit guard is added.

## Duplication review

Twelve repeated calculation/predicate groups were found and resolved:

| Cubit | Groups | Resolution |
|---|---:|---|
| Postal | 0 | Two distinct operations, no duplicated request lifecycle |
| Clearance | 1 | Shared submit eligibility with the changed field's fresh validity and stored sibling flags; preserves the not-found distinction |
| Cancellation | 2 | Selected-entry existence and input-presence exit confirmation |
| Book | 9 | Registered-address filtering; review requirement; initial delivery address; registered-address existence; acknowledgement eligibility; deletion eligibility; primary action; residency continuation; selection continuation |

Book delivery eligibility was already shared; its calculation remains shared,
with each caller now supplying only the current address and any freshly changed
validity/requirement. Cancellation's one long review-continuation predicate is
also named outside the action; it is not counted as a repeated group.

Registry-check and registry-deletion results remain independent operations.
Their repeated field groups keep explicit emits and share only pure value
calculations. No helper constructs/publishes State or mutates Cubit fields.

## Flow-aware emit review

Removed **83** habitual failure/message clears: postal 9, clearance 20,
cancellation 26, book 28. Status transitions trigger feedback even when the same
error text repeats. Success and command effects work with retained errors.

Preserved the flow map's actual dependent resets and operational data:

- Postal province/city/results selection and status resets; share command
  consumption. A reopened sheet starts its own independent scope.
- Clearance deposit-dependent cheque reset, reason-dependent letter/consent
  resets, inline invalid/not-found errors and key renewal on the same inputs as
  before. Letter or consent changes still cannot bypass a not-found error.
- Cancellation account/type-dependent selection/search, fresh reason drafts,
  selection-dependent confirmed-request invalidation, final consent/status and
  actual modal command consumption. Back without payload edits retains the key.
- Book account/count-dependent residency/quote/snapshot invalidation, fresh
  confirmation identity, local address removal and pending-deletion consumption.
  Recipient validity stays stored; caller cancellation preserves previous inputs.
  Actual exit behavior still reads hasChanges. Successful requests keep the
  visible final action disabled; no earlier form data is cleaned on receipt exit.

## Scoped verification — 2026-11-02

Baseline: **89 existing tests passed**. Those same tests passed after the initial
operation/listener migration. Final run: **93 tests passed**, adding meaningful
feedback/retry regressions for the four changed flows:

```sh
flutter test test/postal_offices test/cheque test/core/di test/core/router/app_router_test.dart test/dashboard/implemented_services_navigation_test.dart
```

Existing coverage includes all five book scenarios; account/count/recipient
validation; registry versus local address removal; quote binding, expiry and
mock idempotency; stale list/residency/quote replies; not-found cheque feedback;
selection/search/reason drafts; nested review deletion; request Back gates;
repeated postal sharing; service routing and narrow layouts.

New notification coverage repeats province/office errors and shares actual
addresses twice after success, repeats clearance submission then opens postal
and content effects, repeats cancellation list/submission errors then opens
review/reason/receipt, and repeats errors for all six book operations before
successful recovery/submission with the same confirmed key. The initial postal
test lacked a Scaffold in its test host; that test-only setup was corrected.
Controlled repositories are installed before lazy UseCases/Cubits resolve them;
test scopes are reset afterward.

```sh
flutter analyze lib/features/postal_offices lib/features/cheque lib/core/di/injection_container.dart test/postal_offices test/cheque
```

Result: **No issues found**. `git diff --check` passed. No full-app test suite,
build, dependency installation or design-system change was performed. Existing
SVG renderer diagnostics about unsupported filter/foreignObject elements remain
test-output noise. Live banking/registry/postal services and actual device
share/browser behavior are outside this verification.

The owner approved phase 9 and requested its commit before starting phase 10.

Duplication review: 12 repeated groups found, 12 resolved (pure calculations and
predicates). Flow review: 83 clears removed.
