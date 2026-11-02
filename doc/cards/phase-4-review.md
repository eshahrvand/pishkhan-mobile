# Phase 4 — card services migration review

> Historical migration record. The later owner amendment in contract v1.24
> withdraws its direct-Repository/optional-UseCase decisions. Current Cubits must
> use UseCases for all application/data operations. See the
> [follow-up review](../usecase-only-dependencies-review.md).


Reviewed: 2026-11-01. Baseline commit: `5092e02`. Governing reference:
[UI/Cubit/State contract v1.21](../ui-cubit-state-agent-rules-en.md) and the
[clean-code skill](../../.agents/skills/pishkhan-cubit-clean-code/SKILL.md).
The owner approved phase 4 after committing phase 3 and the listener-composition
follow-up. No phase-5 implementation or banking integration is included.

## Scope and behavior

The four reviewed flows are [issuance](card-issuance.md),
[change linked deposit](change-card-deposit.md),
[expired gift balance](expired-gift-balance.md) and
[second-password services](password-services.md). Their documents record each
step's readers, modal return path and lifetime. Plain Freezed States and their
part-of organization are unchanged; no generated file was edited manually.

Step order, enabled controls, validation, exact request payloads, optional-data
omission, selected-record context, mock receipts, route destinations and Back
behavior are preserved. Existing success callbacks and inline/modal receipts
remain; no success toast or endpoint is added. No dependency/package change.

## Request inventory before implementation

| Cubit | Operation owner | Trigger actions / UI |
|---|---|---|
| CardIssuanceCubit | fetchIssuanceCatalog | Provider entry; catalog Retry |
| CardIssuanceCubit | submitCardIssuance | Confirmation continueFlow; retry |
| ChangeCardDepositCubit | fetchCatalog | Provider entry; catalog Retry |
| ChangeCardDepositCubit | submitDepositChange | Submit; retry |
| ExpiredGiftBalanceCubit | fetchCatalog | Provider entry; catalog Retry |
| ExpiredGiftBalanceCubit | _submitTransfer | Destination submitCurrentStep; retry |
| SecondPasswordCubit | fetchCatalog | Provider entry; catalog Retry |
| SecondPasswordCubit | _fetchExistingRequest | Selection submitCurrentStep; retry |
| SecondPasswordCubit | _submitPassword | Change form or recording submitCurrentStep; retry |

Nine operations retain one dependency call/await/Result switch each. Step-routing
actions delegate to their actual operation owner; no lifecycle is copied.
No overlap request ID, disposal check, catchError or try/catch is added in Cubit.
Existing Repository/UseCase exception boundaries still convert exceptions to Err.

## Dependency access

Six existing UseCases now have the UseCase suffix and GetIt registrations:

| File under cards/domain/usecases | Registered classes |
|---|---|
| card_issuance_usecase.dart | LoadIssuanceCatalogUseCase; SubmitCardIssuanceUseCase |
| card_services_usecase.dart | LoadCardServiceCatalogUseCase |
| password_services_usecase.dart | LoadPasswordCatalogUseCase; CheckPasswordRequestUseCase; SubmitSecondPasswordUseCase |

Grouping and Domain boundaries are unchanged. Factories in core/di wire the
registered Repository; each Cubit resolves its used UseCases once in final
fields. Change-deposit/gift submission keeps its existing direct Repository
operation protected by cardServiceBoundary, as Virtual Card did in phase 3.
No extra submission UseCase layer is introduced. Domain never resolves GetIt.
Tests configure registrations before overriding data dependencies and constructing
Cubit; factories do not retain an already-resolved old Repository graph.

## Explicit actions and calculations

Issuance's thirteen draft/address edit actions now invalidate terms and confirmed
snapshot and publish the fresh dependent eligibility in the same snapshot. They
no longer invoke a second updateTermsAcceptance(false) publication. Its submit
owner retains the confirmed/new request and loading in one publication, removing
the separate _submitConfirmedIssuance lifecycle split. Retry keeps the exact
confirmed request object. Issuance still has no invented bank idempotency key.

Three password input actions similarly publish consent, form eligibility and
primary action together. Own-field validators still run once; aggregate validity
uses stored field outcomes. The repeated issuance delivery/omission condition is
implemented once in the pure _isDeliveryStepOrOmitted predicate.

Gift toggle, select-all-visible and review removal remain independent events
with explicit emits and shared pure totals/eligibility calculations. The former
_selectGiftCards publication intermediary is removed. Indexed gift/deposit
mapping and password initial-card matching are focused pure calculations.
No State constructor/publication helper or artificial event delegation is added.

## Notifications and screen composition

Every failure publishes its operation status, Failure and prepared message
atomically. Each screen uses independent entering-failure listeners plus its
prepared effect/navigation/completion listeners in MultiBlocListener, with
BlocBuilder for screen rendering. No second screen Consumer remains. Existing
local controller/scroll consumers keep their actual resource boundaries.

Named handlers no longer display/return early on message presence. Retained
failure/message describe the latest recorded error; current operation status
controls feedback. Loading between attempts allows identical errors to notify
again. Successful retries and unrelated commands do not replay older messages.

## Flow-aware emit review

Removed **70 explicit blanket failure/message clears** from the original source:
issuance 14, change-deposit 10, gift 12, password 34. Password's real State.initial
subform resets still intentionally reset unlisted fields; these are not changed
into synthetic per-field actions or message-retention exceptions.

Identified readers retain required clears:

- Issuance: replacement catalog/draft must align step, validity and confirmed
  snapshot; form edits invalidate terms and snapshot; address modal starts a fresh
  local form. Step/recipient/agent controls read these values.
- Change-deposit: card changes invalidate destination; card/destination edits
  invalidate consent, submission view status and request identity.
- Gift: selection/destination changes invalidate consent and request identity;
  filter/review/submission locks and retry state drive the still-visible flow.
- Password: actual selection resets discard old secrets and key; Back/reentry
  preserves required input while resetting defined visibility/error controls.
  Successful submit purges PINs, confirmation and serial with their dependent
  flags before showing the record/calling the host, while the scope is alive.
  This existing security boundary is preserved. Failed submission retains secrets
  and key for retry. Home/exit actions add no cleanup.
- All flows: reusable commands clear on UI acceptance; authorized exit intent
  remains set until pop. No cleanup is added to close or to receipt navigation.

## Verification

Baseline: `flutter test test/cards test/core/di test/flow_exit_contract_test.dart`
passed **196 tests** before changes. Four new widget scenarios cover repeated
failures, effects after retained errors, recovery without replay, exact retry
identity and one successful completion for each flow. Existing null-error
assertions are updated to the approved latest-recorded-error semantics; initial
null and real-reset assertions remain. Widget Cubit lookup uses an existing
public top bar rather than requiring a Consumer implementation detail.

Final checks completed successfully:

- `flutter test test/cards test/core/di test/flow_exit_contract_test.dart`: **200 passed** (baseline 196 plus four new widget scenarios).
- Complete `flutter test`: **754 passed, 1 Web-only skip, 0 failures**.
- `flutter analyze`: **no issues found**.
- `git diff --check`: passed. Updated flow-document local links resolve.

The expanded test runs cover the earlier phases and other application features
without extending their implementation scope. Phase 4 is ready for owner review;
its changes are not automatically committed and phase 5 has not started.

Duplication review: 1 repeated predicate found, 1 resolved (delivery/omission →
_isDeliveryStepOrOmitted); 9 unique operation owners. Flow review: 70 clears removed.
