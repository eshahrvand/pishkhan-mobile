# Phase 6 — Base deposit services

Scope: DepositListCubit, DepositRestrictionCubit (block/unblock),
CloseSurplusDepositsCubit and ProxyDepositCubit. Apply contract v1.22 and the
clean-code skill. Phase 5 was approved and committed as `85e74cf`. Phase 7 is
outside this task.

## Operation inventory before implementation

| Flow | Owner action | Triggers / operation |
|---|---|---|
| Deposit list | fetchDeposits | Provider entry and Retry: load/validate the deposit list |
| Restrictions | fetchCatalog | Provider entry and Retry: operation-specific account/reason/fee catalog |
| Restrictions | submitRestriction | Confirmed eligible form: block/unblock request |
| Surplus closure | fetchPrimaryDeposits | Provider entry and Retry: primary-account catalog |
| Surplus closure | submitClosure | continueFlow at primary selection: review then close all other accounts |
| Proxy | fetchCatalog | Provider entry and Retry: companies/subjects/accounts |
| Proxy | submitProxyDeposit | Confirmed form: mandate registration |

Seven Cubit request operations already have separate owners. Surplus review and
closure are one existing application operation; there is no intermediate UI page.
Nine existing UseCases cover these operations and the two inner closure steps.
Each is renamed with the UseCase class and _usecase.dart file suffix and wired
in GetIt. The pending closure payload must remain specific to one flow instance.

## Flow map and readers

| Step | Readers / next | Data retention and Back |
|---|---|---|
| List | DepositListContent/Filters read list, visible list, kind/status; overflow selects details or a service | Filters intersect, selected chip clears itself, dismissal leaves selection unchanged. Supported destination receives selected number; host callback keeps precedence. Back is blocked only while loading |
| Restriction form | Form reads operation catalog, selected account, previous block details and optional description; footer reads consent/fee/wallet/submit | New account clears consent; payload edits renew key, identical trimmed description retains key. Failed submit keeps form/key. Back/assistant after edits asks confirmation; all requests gate Back |
| Restriction receipt | Status success opens existing mock receipt; dismissal returns home | No competing success toast; no second submit; historical form data need no cleanup for departure |
| Surplus primary | Catalog count chooses primary form or empty result; form/footer read account and consent | Count >1 allows selection; <=1 shows empty. Selecting primary clears consent/renews key. Failure retries the exact reviewed payload. Back remains gated during requests |
| Surplus receipt | Existing simulated receipt, then home | Preserve reviewed account/token/key across uncertain response; a fresh flow has a fresh operation instance |
| Proxy form | Company/subject/account selectors, derived broker/toman amount; consent footer | Company clears subject/amount and restores full account list; subject resolves company and retains only an eligible account. Selection edits clear consent/renew key. Failure retains form/key. Back/assistant asks after edits; requests gate Back |
| Proxy receipt | Existing mock acknowledgement, then home | No duplicate submit or retained failure notification; dependent selections remain until departure |

Baseline: the eight unit/widget flow files plus `test/core/di` passed **58 tests**.
Implementation and final scoped verification follow below.

## Implemented changes and dependency lifetime

The seven request owners now use async/await and Result switches. All nine
existing UseCase classes have the `UseCase` suffix; their four source files end
in `_usecase.dart`, preserving existing grouping. GetIt wires repository and
UseCase constructor dependencies. Cubits resolve only the UseCases they invoke,
in final fields, and never construct them from a repository.

Eight stateless UseCases use lazy-singleton registrations. The existing mutable
`CloseRemainingDepositsUseCase` uses a factory: its pending reviewed request must
belong to one Cubit/flow. Its two actual UseCase dependencies are supplied by DI;
Domain remains independent of GetIt. The composite operation also converts an
unexpected payload-construction exception to the existing UnexpectedFailure,
matching the established boundary guarantee. Its review token, candidate set and
idempotency key remain cached together across uncertain retries.

The direct `AgentCubit` consumer of the shared `LoadDepositsUseCase` necessarily
receives its new import/name and final GetIt lookup; the repository field used
only to construct that UseCase is removed. No Agent action, State, listener or
other dependency is migrated in this phase. Its tests install the dependency
before construction and use a fresh locator scope for the alternative graph.
The full Agent rewrite remains phase 7.

## Notifications, flow resets and UI boundaries

Each request-failure listener observes its own entering-failure transition and
displays that snapshot's prepared message. Failure/message describe the latest
recorded failure, so retries, successful responses and typed commands retain
those values. All independent error/effect/receipt listeners share one
MultiBlocListener per screen, with BlocBuilder rendering; no screen Consumer
remains under the group. Receipt dialogs still own success feedback and navigate
home on dismissal. Effects never return early because old message text exists.
Unused footer subscriptions to failure changes were removed; actual footer data
and loading subscriptions remain.

Forty-nine blanket null assignments were removed: list 7, restriction 15,
closure 12, proxy 15 (individual failure/message assignments, not emit blocks).
Three additional success-only hasChanges:false assignments were removed: the
receipt is modal and its dismissal leaves the flow; no continuing form requires
that cleanup. Actual input resets remain explicit: consent/submit eligibility,
proxy subject/amount/options, primary selection/submission status and request
identity. Error retries preserve input and banking identity. State factories,
fields and part-of structure are unchanged.

Deposit-list in-screen Back and assistant now publish specific prepared effects;
UI executes them. Existing callback precedence is preserved: an assistant host
callback handles the action when present; otherwise it returns Home. System Back
and top-bar gates remain consistent during list fetch. The other three flows
retain their existing request gates, discard confirmation, post-frame authorized
Back and receipt dismissal behavior. Stale documentation claiming Back remained
available during loading was corrected; no new Back policy was introduced.

## Duplication and style review

Eight repeated calculation groups were resolved: numeric entry normalization in
each of the three forms (3), restriction submit eligibility (1), restriction
wallet comparison (1), surplus catalog-count branching (1), surplus request-key
construction (1), and proxy company-subject filtering (1). Substantial optional
entry selection and the long proxy eligibility condition use pure value helpers.
Each operation still has one owner (1/2/2/2 Result switches by Cubit); continueFlow
delegates to submitClosure without copying its lifecycle. No duplicated request
lifecycle, State-publication helper, constructor emit, UI dependency forwarding,
new State logic, extra request IDs or disposal checks were introduced. Repeated
fields in independent selection/back events remain visible in explicit emits.
The limited shared Agent dependency adjustment introduces no duplicated block or
additional clearing; unmodified Agent behavior is not claimed as phase-7 adoption.

## Final scoped verification

```sh
flutter test test/deposits/deposit_list_cubit_test.dart test/deposits/deposit_list_screen_test.dart test/deposits/deposit_restriction_cubit_test.dart test/deposits/deposit_restriction_screen_test.dart test/deposits/close_surplus_deposits_cubit_test.dart test/deposits/close_surplus_deposits_screen_test.dart test/deposits/proxy_deposit_cubit_test.dart test/deposits/proxy_deposit_screen_test.dart test/deposits/phase_6_notifications_test.dart test/deposits/agent_cubit_test.dart test/deposits/agent_screen_test.dart test/core/di test/core/router/app_router_test.dart test/dashboard/implemented_services_navigation_test.dart
flutter analyze lib/features/deposits/presentation/deposit_list lib/features/deposits/presentation/deposit_restriction lib/features/deposits/presentation/close_surplus_deposits lib/features/deposits/presentation/proxy_deposit lib/features/deposits/presentation/introduce_agent/cubit/agent_cubit.dart lib/features/deposits/domain/usecases/deposit_list_usecase.dart lib/features/deposits/domain/usecases/deposit_restrictions_usecase.dart lib/features/deposits/domain/usecases/close_surplus_deposits_usecase.dart lib/features/deposits/domain/usecases/proxy_deposits_usecase.dart lib/core/di/injection_container.dart test/deposits/deposit_list_cubit_test.dart test/deposits/deposit_list_screen_test.dart test/deposits/deposit_restriction_cubit_test.dart test/deposits/deposit_restriction_screen_test.dart test/deposits/close_surplus_deposits_cubit_test.dart test/deposits/close_surplus_deposits_screen_test.dart test/deposits/proxy_deposit_cubit_test.dart test/deposits/proxy_deposit_screen_test.dart test/deposits/phase_6_notifications_test.dart test/deposits/agent_cubit_test.dart
```

Tests: **88 passed**. Existing coverage checks filters, selected account context,
entry normalization, catalog branches, dependent selections, wallet/consent,
pending controls/Back, lost-response identity, mock debit/closure/mandate binding,
receipts and compact layouts. New tests verify repeated identical failures,
effects after retained errors and successful receipts after retry in all four
flows. A two-live-flow regression verifies independent reviewed payload caches.
The restriction unit assertion now expects the last timeout failure after an
input edit, replacing its legacy-null expectation.

No full-application suite was run. Existing SVG renderer warnings about filter
and foreignObject elements remain; they did not fail the tests. All operations
remain mock-backed; this refactor does not add bank execution or real payments.

Final scoped analysis: **no issues**. `git diff --check`: passed. An unused import
in the new test was removed before the final analysis. Phase 6 is ready for owner
review and remains uncommitted; phase 7 has not started.

Duplication review: 8 repeated calculation groups found, 8 resolved. Flow review:
52 clears removed (49 blanket failure/message null assignments and 3 terminal
hasChanges assignments); actual dependent resets and retry identity preserved.

## Owner follow-up — explicit dependency field names

Contract v1.23 now requires AuthCubit-aligned Cubit dependency fields: no leading
underscore for Repository/UseCase fields; full lowerCamelCase UseCase class name
including the UseCase suffix. For example:

```dart
final fetchDepositRestrictionCatalogUseCase = getIt<FetchDepositRestrictionCatalogUseCase>();
final submitDepositRestrictionUseCase = getIt<SubmitDepositRestrictionUseCase>();
```

Twenty-seven fields in twelve Cubits were renamed along with all references.
The additional Cubits are direct naming-only corrections in card services,
virtual cards, agent/settings, on-site transfers and cheque book/clearance.
Their dependency construction/lifetimes, request logic, State updates and literal
values are unchanged; this does not start their later-phase flow rewrites.
The existing legacy UseCase class/file/DI migrations remain assigned to those
phases. Domain constructor-field visibility and private calculation helpers,
request IDs and timers are outside this naming change.

A token comparison against the pre-follow-up working files verifies that all
twelve Cubit changes contain only identifier substitutions and formatting.
The follow-up command was:

```sh
flutter test test/deposits/deposit_list_cubit_test.dart test/deposits/deposit_restriction_cubit_test.dart test/deposits/close_surplus_deposits_cubit_test.dart test/deposits/proxy_deposit_cubit_test.dart test/deposits/phase_6_notifications_test.dart test/deposits/agent_cubit_test.dart test/deposits/agent_settings_cubit_test.dart test/transfers/on_site_transfer_cubit_test.dart test/cards/card_services/card_service_cubits_test.dart test/cards/presentation/flows/virtual_card_request/cubit/virtual_card_cubit_test.dart test/cheque/cheque_book_cubit_test.dart test/cheque/cheque_clearance_cubit_test.dart test/core/di
flutter analyze lib/features/deposits/presentation/proxy_deposit/cubit lib/features/deposits/presentation/close_surplus_deposits/cubit lib/features/deposits/presentation/deposit_list/cubit lib/features/deposits/presentation/agent_settings/cubit lib/features/deposits/presentation/deposit_restriction/cubit lib/features/deposits/presentation/introduce_agent/cubit lib/features/transfers/presentation/on_site_transfer/cubit lib/features/cards/presentation/change_card_deposit/cubit lib/features/cards/presentation/virtual_card_request/cubit lib/features/cards/presentation/expired_gift_balance/cubit lib/features/cheque/presentation/book_issuance/cubit lib/features/cheque/presentation/clearance/cubit
```

Follow-up tests: **126 passed**. This count is a separate scoped execution,
not added to the phase-6 total. Duplication review: 0 new repeated blocks.
Flow review: 0 additional clears removed by the naming-only follow-up.

Follow-up scoped analysis: **no issues**; diff check passed. The naming follow-up
and the phase-6 changes remain uncommitted for owner review.
