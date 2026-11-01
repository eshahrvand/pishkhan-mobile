# Phase 7 — Certificates and agents

Scope: AverageBalanceCubit, FinancialCertificateCubit, AgentCubit and
AgentSettingsCubit, under contract v1.23 and the current clean-code/UI skills.
Phase 6 and the dependency naming follow-up were committed in `ab7e274` before
this work. Phase 8 is outside this task.

## Request inventory and initial flow map

| Cubit | Operation owner | Triggers |
|---|---|---|
| Average balance | fetchCatalog | Provider entry / Retry |
| Average balance | submitCertificate | continueFlow from confirmation |
| Financial certificate | fetchCatalog | Provider entry / Retry |
| Financial certificate | submitCertificate | continueFlow from confirmation |
| Agent | fetchDeposits | Provider entry / Retry |
| Agent | submitAgents | Pending-list final confirmation |
| Agent settings | fetchAgents | Provider entry / Retry |

All seven operations already have separate owners. Fetch and submission statuses
remain independent. Receipt success feedback remains in the existing dialogs.

| Step | State readers and next | Retention / actual resets |
|---|---|---|
| Average conditions | Deposit, language, turnover, optional dates; continue to delivery | Deposit changes clear dependent conditions/dates. Back from delivery keeps entered data |
| Average delivery | Addresses, optional alternate recipient and optional agent; then fee confirmation | Local add/delete modifies only the flow list; selected deletion clears address. Hidden recipient/agent data stay in State but are omitted from payload |
| Average confirmation | Summary/invoice, total fee and wallet gate; submit then receipt/home | Retry preserves the last sent payload/key; leaving uses the existing receipt callback. First-step discard compares the entry snapshot |
| Financial conditions/recipient | Deposit and conditions; embassy/other-authority plus currency | Deposit clears conditions; recipient branch clears dependent values. Back retains completed steps |
| Financial Latin identity | Stored per-field validity for names, passport, expiry and Latin address | Each field update validates only itself. Catalog entry resolves seeded values; no additional future-expiry policy |
| Financial delivery/confirmation | Shared address/recipient behavior, wallet, summary, fee and receipt | Preserve address and hidden optional inputs across Back; serialize only the active recipient branch; retry identity depends on the submitted payload |
| Agent initial form | Eligible open deposit, operation, national ID and Jalali validity | Own-field validation; preliminary save adds an immutable draft without an API call |
| Agent pending list/sheet | Pending agents, consent, local add/remove, final submit | Add-next clears the consumed form; Cancel does not append. Removing the last draft restores the initial form while retaining the existing flow/consent semantics |
| Agent receipt | Result dialog, then home | Same pending-list payload/key on retry; unsaved form edits do not change the submitted list |
| Agent settings | Tab, catalog, committed filters and visible records; actions/details/add | Draft sheets borrow the Cubit. Apply commits; Cancel/outside/Back discard draft only. Details Back preserves tab and filters; cancellation remains unavailable |

All existing system/top-bar Back request gates remain; documentation claiming
Back is available during requests is historical wording to be corrected.
No new request ID, disposal guard, State logic or extra form layer is planned.

## Implemented operations and dependencies

All seven operation owners now use async/await and one Result switch each;
continueFlow delegates only to its existing submission owner. The three existing
UseCases are renamed to LoadCertificateCatalogUseCase, SubmitAgentsUseCase and
FetchAgentsUseCase, in average_balance_usecase.dart, submit_agents_usecase.dart
and agent_settings_usecase.dart. Their dependencies are wired in core/di and
Cubit resolves final fields with the complete approved name and no underscore.
LoadDepositsUseCase remains the previously registered shared agent catalog input.
There is no Cubit registration or data lookup in UI/router.

The shared catalog class deliberately has two named lazy-singleton registrations:
`average-balance` uses DepositCertificatesRepository; `financial-certificate` uses
FinancialCertificateRepository. Keeping the existing shared type avoids a new
wrapper hierarchy and preserves the two actual service adapters. A controlled DI
test verifies different catalogs cannot cross those names. Certificate repository
fields remain because each Cubit already submits through its repository under
the existing certificateBoundary. No speculative submission UseCase was added.
Catalog validation is now covered by the existing UnexpectedFailure policy as
well as the repository load, so an unexpected validation exception cannot leave
its Cubit loading. Domain has no GetIt or Flutter dependency.

## Notification and flow-aware review

All four screens group distinct per-operation failure listeners separately from
their typed-effect/navigation listener. Receipt listeners remain separate and
retain callback/dismissal behavior. Screen Consumers become Builders; the two
certificate root buildWhen predicates remain unchanged, preserving independent
stepper/form/footer subscriptions. Agent-settings rendering still owns its
selected State and passes it to its actual children. Borrowed Cubit scopes in
filter and add-agent sheets remain unchanged.

Every failure publishes its own status, Failure and prepared message together.
Retries pass through loading, so identical failures notify again. Typed commands
execute independently of old text; successful retries open the existing receipt
without replaying an error. Latest failure/message remain recorded until an
actual reset requires otherwise. Existing unit tests now assert that retention.

Removed **81 blanket failure/message null assignments**: average balance 19,
financial certificate 37, agent 15 and agent settings 10. Removed one terminal
agent hasChanges:false assignment because the modal receipt leads home; the
screen remains locked and final submission is disabled. Total clears removed:
**82**. No other reset was removed.

In particular, navigation actions still clear a pending certificate effect when
necessary because the existing effect/navigation consumer gives effect precedence.
Interaction consumption still clears the accepted commands. Deposit/recipient
branch resets, address removal, new-agent form resets and draft filter discard
retain their actual readers. Removing the last pending agent retains its original
consent/submission/error semantics and resets only the now-visible initial form.
Request snapshots and canonical payload comparison are unchanged: hidden optional
edits and unsaved agent-form edits do not create a new banking request identity.
No State fields/factories, request IDs, interaction counters, disposal guards,
routes, service IDs, payload formats, tariffs or date eligibility rules changed.

## Calculation and duplication review

Eleven repeated calculation groups were resolved inside the affected Cubits:
average condition eligibility, delivery eligibility and number normalization (3);
financial condition eligibility, delivery eligibility, recipient-branch
eligibility, Latin completeness and number normalization (5); agent draft
eligibility and number normalization (2); settings entry-number normalization (1).
Latin completeness is expressed through names, passport and address validity,
using the current field's fresh outcome and stored sibling outcomes; sibling
validators are never rerun by an input action. Helpers return only calculated
values and never build/publish State. Independent events keep explicit emits.

Long discard decisions and catalog-step eligibility were moved out of actions.
The original entry-selection order is preserved, including the certificate
catalog's first match of retained ID or normalized entry number, settings' first
catalog entry-filter resolution, sorted deposit numbers and the agent's open-only
catalog. The settings entry-resolution flag still snapshots the pre-await state.
Wallet/fee calculations and required text checks use pure calculations and the
existing central validator. No blanket State preparation/publication helper,
new validation facade or extra form State was introduced.

## Scoped verification

Baseline before edits: the ten flow/shared-certificate files plus core/di passed
**87 tests**. Final execution:

```sh
flutter test test/deposits/average_balance_cubit_test.dart test/deposits/average_balance_screen_test.dart test/deposits/financial_certificate_cubit_test.dart test/deposits/financial_certificate_screen_test.dart test/deposits/certificate_navigation_test.dart test/deposits/certificate_submission_ui_test.dart test/deposits/agent_cubit_test.dart test/deposits/agent_screen_test.dart test/deposits/agent_settings_cubit_test.dart test/deposits/agent_settings_screen_test.dart test/deposits/phase_7_notifications_test.dart test/core/di test/core/router/app_router_test.dart test/dashboard/implemented_services_navigation_test.dart
flutter analyze lib/features/deposits/presentation/average_balance lib/features/deposits/presentation/financial_certificate lib/features/deposits/presentation/introduce_agent lib/features/deposits/presentation/agent_settings lib/features/deposits/domain/usecases/average_balance_usecase.dart lib/features/deposits/domain/usecases/submit_agents_usecase.dart lib/features/deposits/domain/usecases/agent_settings_usecase.dart lib/core/di/injection_container.dart test/deposits/average_balance_cubit_test.dart test/deposits/financial_certificate_cubit_test.dart test/deposits/agent_cubit_test.dart test/deposits/agent_settings_cubit_test.dart test/deposits/phase_7_notifications_test.dart test/core/di/injection_container_test.dart
```

**102 tests passed; scoped analysis found no issues.** Diff check passed. No full
application test suite was run. A missing required value in the new DI test
fixture was corrected before the successful final run; no application change
was needed for that test compilation error. Existing SVG renderer filter and
foreignObject warnings do not fail the checks.

New behavioral tests cover identical retry failures, command execution after a
retained error, success receipts without replay, canonical retry identity after
hidden or unsaved edits, every Latin field's invalid/valid progression gate, and
separate named catalog adapters. Existing tests cover Back/exit confirmation,
pending controls and both Back gates, modal cancellation, add/delete address,
filter Apply/Cancel/dismissal, tab/detail retention, entry normalization, fee and
wallet gates, receipt callback, current date/validation rules and compact layouts.
The operations remain mock-backed; no real certificate, banking authority,
identity enquiry, cancellation or payment was introduced.

Duplication review: 11 repeated groups found, 11 resolved. Flow review: 82 clears
removed; all actual dependent resets and banking retry identity preserved.
Phase 7 is ready for owner review and remains uncommitted. Phase 8 has not started.
