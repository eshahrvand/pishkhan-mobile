# Virtual Card Request Development

**Current dependency rule — contract v1.24:** application/data operations follow
Cubit → registered UseCase → Repository. Cubit imports/resolves UseCases only;
`core/di` wires their repositories. Any earlier direct-Repository or optional-
UseCase wording below is historical and superseded. Payloads, Result mapping,
validation, retry identity and UI behavior remain unchanged. See the
[UseCase-only migration review](../usecase-only-dependencies-review.md).


Reviewed: 2026-11-01 — phase 3, contract v1.20.

## 1. Purpose

Implement the supplied empty and completed request forms using shared UI and a replaceable repository. This prototype does not issue cards or debit a wallet.

## 2. Design scope

Figma file nYQNyZdSs98lwymCpt5Sag: empty `27997:10100`, filled `27997:10897`. . No subsequent receipt screen or KYC sequence was supplied. After successful submission the flow returns directly to the main page without a dialog.

## 3. Stack

Existing Flutter, flutter_bloc Cubit, Equatable, Result/Failure, flutter_svg, public avp_ui components and generated fa/en/ar localization. No new dependencies.

## 4. Entry points

Dashboard Card Services and deposit quick actions use `card-virtual`, now opening `VirtualCardRequestScreen` and forwarding a selected deposit if available. `card-virtual-request` is an alias. Existing card lists remain reachable through Cards/category chips; `card-virtual-list` explicitly opens the Virtual category. Its Request virtual card footer opens the form. Supplied host callbacks continue to take priority.

## 5. Feature boundaries

The request is under `lib/features/cards/presentation/virtual_card_request`, independent of card listing and physical card issuance. Public exports: screen, typed repository/catalog/deposit/quote/request/receipt and mock adapter. No private avp_ui import or new package widget is needed.

## 6. Structure

Domain models/repository/UseCases live under `lib/features/cards/domain/`; the mock adapter is under `data/repositories/`. The owning screen is `presentation/virtual_card_request/screens/virtual_card_request_screen.dart`, with Cubit/State in that flow’s `cubit/` directory and public content/footer widgets in `widgets/`. Controller lifecycle and navigation belong to the screen; request/quote/consent state belongs to Cubit.

## 7. Repository contract

`load()` returns selectable deposit IDs/numbers, indicative unit fee and count limit. `quote(depositId, count)` returns a quote ID, binding, unit fee, total and wallet balance. `submit(VirtualCardRequest)` uses that exact quote and an idempotency key. The app treats adapter quotes as display data, not payment authorization. A production endpoint must validate ownership, eligibility, quote freshness, limits, balance and consent atomically.

## 8. Sample fees and discrepancies

The empty Figma notice says41,250 per card. The completed four-card frame says300,000 per card and quotes1,300,000 total, rather than1,200,000. Mock data preserves both authored states. It explicitly provides the four-card1,300,000 quote; other sample quantities use300,000 per card. This is illustrative, not a tariff. No hidden100,000 fee or real charge is inferred. Production fees and the count cap must come from the adapter; mock maxCount is999.

## 9. Loading and validation

Loading, failed and empty catalogs have separate UI states with Retry. Load validation rejects blank/duplicate deposit IDs, blank numbers, negative indicative fees and invalid count caps. Exceptions map to UnexpectedFailure. Quote validation rejects blank tokens, wrong deposit/count bindings and negative money values.

## 10. Editing

Deposit selection is restricted to the loaded catalog. The count input normalizes Persian/Arabic digits, accepts digits and allows up to6 characters. State requires a positive integer within the adapter limit. Zero/out-of-range counts show localized errors. Selection/count edits delegate to `fetchQuote`, which clears the old quote, accepted terms and the visible retry target/eligibility. The latest failure/message remain recorded; they are not current status. The private last-submitted request and idempotency key are retained until a genuinely different submission payload is sent.

## 11. Quoting

Valid edits trigger a quote. Only the quote operation uses a request ID. It increments before the start-or-skip decision, including invalid count edits, so an older quote cannot overwrite the current form. Catalog/submission have no request ID or disposal guard. Edits remain possible while quoting; terms and submission wait for the current result. Failed quotes expose Retry and require fresh consent after recovery. No stale quote can authorize a changed selection.

## 12. Invoice

The initial per-card notice becomes the existing expandable AppInvoice when a quote is available. Expanded shows the quoted total, per-card fee, wallet balance and sufficient/insufficient status. Collapsing keeps total and wallet. `zeroHeightDividers: true` produces the authored174px expanded/130px collapsed sizes. White surface,16px corners and Gray500 labels are opt-in instance values.

## 13. Terms

The localized linked terms text calls an optional host callback. With no supplied official document it reports that terms await service integration. The checkbox can be toggled before selection; each selection/quote change clears it. Submission requires the current quote plus consent, and remains disabled during quoting/sending.

## 14. Submission

Submission requires a current valid quote, count, deposit, sufficient wallet and terms. Its loading emit locks editing/submission controls; UI disables Back and prevents duplicate taps. Cubit does not repeat those UI preconditions in entry guards. Failed submission keeps the same idempotency key for a retry; changing request data replaces it. Success invokes the optional typed callback with the receipt and returns to the first/main route, closing both the request and any intermediate card-list route. No confirmation dialog is shown. Execution remains mocked; no card is issued and no payment occurs.

## 15. Security

No actual bank endpoints, camera, permission prompts, credential storage or wallet debit are added. Runtime state remains in memory. Server-side authorization and authoritative fee/quote verification remain adapter responsibilities. The mock accepts only quotes it previously issued and supplies idempotent demo receipts.

## 16. Component reuse

AppTopBar, AppSelect, AppTextField, AppCheckbox and AppButton remain shared components. AppInvoice remains app-owned shared composition. Existing blueGray100 palette and typography/radius tokens implement notices. Exact info-circle artwork reuses password_camera_info.svg because it is byte-identical to the virtual-card Figma asset. This filename reuse does not couple business flows.

## 17. Asset fidelity

The parent export initially referenced base bars/print component artwork, while the rendered instances use angle-right-small/Virtual Card overrides. Context was read for the actual instance nodes `I27997:10898;13867:8754;13867:8738` and `I27997:10915;16662:54695`. Original downloaded assets are virtual_request_back.svg (24×24) and virtual_request_card.svg (16.2878×12.9544). The latter occupies the authored20px slot at8.33% left/16.67% top. No SVG paths are modified or screenshots used as implementation assets. Existing chevrons, dashed divider, money glyphs and invoice controls are reused.

## 18. Layout and localization

All locales are RTL-first. Numeric input values use LTR with physical right alignment. The body starts at y104 with16px side padding. At375px the prompt is40px, notice74px (y164), deposit selector70px (y258), count44px (y374), dashed divider y438, invoice174px (y458). The empty preview reserves24/40px native insets at375×814; filled uses375×812, matching the respective footer anchors. Content scrolls on narrow/large-text displays; native system bars are not drawn. Corrected spacing and localized separators can differ from mixed-digit prototype strings.

## 19. Verification

Current Cubit tests cover bounded count validation, quote ordering and bindings,
invalidation by an empty/invalid count, consent/wallet eligibility, request identity
across retries and changed payloads, empty/invalid catalog recovery, initial deposit
normalization, exit decisions and mock idempotency. Widget tests cover geometry,
selectors, digit normalization, invoice expansion, poor wallet, narrow/large text
in fa/en/ar, routes and returning home from the list footer without a receipt dialog.
UI tests verify disabled controls/Back during pending operations instead of
requiring Cubit-side guards. No latest-catalog/disposal suppression is claimed.

Phase 3 adds repeated-error/retained-error exit-dialog coverage and strengthens
retry-success completion assertions. DI tests verify all three renamed UseCases
use their own container’s Repository registrations. Earlier counts (14 targeted,
30 regressions) belong to the original design implementation and are not current
migration evidence. See the phase-3 verification section below.

## 20. Remaining integration

Authoritative deposit eligibility/limits, consistent bank tariff, quote expiry/repricing policy, official terms/version, production receipt/card-list refresh and any bank-required KYC remain undefined. A new quote must require renewed consent. The provided two-frame UI is complete with mock execution; it does not claim production banking behavior.

## Phase 3 — Cubit/State contract adoption

Follow the authoritative [contract](../ui-cubit-state-agent-rules-en.md) and
[clean-code skill](../../.agents/skills/pishkhan-cubit-clean-code/SKILL.md).
`VirtualCardState.initial` stays plain Freezed data with its existing `part of`
structure and independent catalog/quote/submission statuses. The constructor
preserves the supplied snapshot; `BlocProvider.create` directly constructs Cubit
and calls `fetchCatalog`. UI owns the count controller and disposes it.

Catalog, quote and submission use `LoadVirtualCardCatalogUseCase`,
`QuoteVirtualCardsUseCase` and `SubmitVirtualCardsUseCase`, grouped in
`virtual_card_request_usecase.dart`. GetIt wires their repository; Cubit resolves
only final UseCase fields. Submission's unexpected-exception mapping now lives
inside its UseCase. No endpoint or validation is added.
Domain has no GetIt dependency. Existing contract validation and exception mapping
are unchanged; no validation is duplicated in submit or UI.

| Operation | Owner | Triggers |
|---|---|---|
| Catalog | `fetchCatalog` | Provider entry; Retry after failed/empty catalog |
| Quote | `fetchQuote` | `selectDeposit`, `updateCount`, quote `submitRetry` |
| Submission | `submitVirtualCards` | Submit; submission `submitRetry` |

All owners use async/await and one `switch (result)` per request. Input actions
publish only their input and delegate to the quote owner. The quote ID and its
check live only there. `_canSubmit` remains the shared pure eligibility predicate;
`_canRetry` selects retry eligibility. No State-building/publication helper exists.

| Step | Reads | Next / return / lifetime |
|---|---|---|
| Catalog loading/failure/empty | catalogStatus, catalog; message on failure transition | Retry stays in scope; initial/default eligibility has not been enabled |
| Editable form | deposit, countText/count validity, isEditable, quote, consent | Selection/count can change during quote; Back is blocked while any request loads |
| Quote start/skip | quoteStatus, quote, termsAccepted, canSubmit, retryAction/canRetry | Old quote/consent/retry are invalid for the new form and must clear; scope stays alive |
| Quote failure/retry | quoteStatus and retry target | Same operation retries; consent is renewed after recovery |
| Submission loading/failure | submissionStatus, isEditable, canSubmit/canRetry, exact request identity | UI locks controls; failure restores edit/retry eligibility and keeps form data/key |
| Exit confirmation | navigation and existing form values | Cancel/outside dismiss preserves input; confirm permits route pop |
| Successful submission | status, receipt, home navigation | Callback then return home; request/list routes close, so no earlier data cleanup |

MultiBlocListener groups the three independent entering-failure listeners and
the focused navigation listener. BlocBuilder renders the existing screen tree.
Navigation never inspects retained message/failure. Each Err publishes status/failure/prepared message atomically.
Repeated identical failures notify through loading → failure. Recovery does not
replay old text; success keeps the existing callback/navigation without a new toast.
Reusable confirmation commands are consumed before awaiting the dialog; authorized
Back stays set until the route pops.

Flow review: removed 8 blanket failure/message clears, 3 redundant initial
eligibility resets from catalog loading and the success-only retryAction clear.
Catalog nulling keeps catalog-dependent content absent while fetching and makes a
failed retry after an empty catalog render the load error rather than the stale
empty-catalog label.
Quote invalidation and submission control flags retain their concrete form readers.
Success only publishes submission status, receipt and home navigation; inputs,
consent and private request identity are not tidied up on exit.

## Phase-3 verification

- Before code changes, `flutter test test/cards/presentation/flows/card_features test/cards/presentation/flows/virtual_card_request test/core/di` passed 53 tests.
- After migration, the same focused command passed 56 tests (three new behavioral/DI cases; existing cases strengthened).
- `flutter analyze` reported no issues; `git diff --check` passed.
- The first complete `flutter test` run passed 745 tests with 1 Web-only skip and 5 failures in the message-center widget suite. The same 5 failures were reproduced on pre-phase-3 commit `3fb09b1` in an isolated temporary source snapshot: that test file never installed the Dashboard UseCases required since phase 2.
- The only message-center change installs the existing `configureDependencies` in test setup and resets GetIt in teardown. All 5 tests then passed. Message-center application code and its phase-5 scope are untouched.
- Final complete `flutter test`: **750 passed, 1 Web-only skip, 0 failures**. The run completed successfully after the test-only DI setup correction.

Duplication review: 0 repeated operations found, 0 resolved (4 unique operation
owners). Flow review: 20 clears removed (16 failure/message, 3 initial eligibility
resets, 1 exit-only retry target). Existing request identity and mandatory
quote/form/modal invalidation remain intact.

Scope remains phase 3; phase 4 requires owner review/approval. This phase is not
committed automatically. The recovered ten-phase plan is in
[cubit-migration-plan.md](../cubit-migration-plan.md).

## Listener-composition follow-up verification

After the phase-3 full-suite result above, the owner approved the composition
clarification in [contract v1.21](../ui-cubit-state-agent-rules-en.md#116-choose-builder-listener-or-consumer-by-responsibility).
The three request listeners and the navigation listener now share one
MultiBlocListener. The previous screen Consumer becomes BlocBuilder; its body,
PopScope, controller owner, callbacks and predicates are unchanged. No Cubit or
State changes are introduced by this follow-up. The existing widget test helper
locates BlocBuilder instead of Consumer; behavioral assertions are preserved.

AuthScreen and DashboardScreen already use this arrangement. Their local form,
focus, controller and modal subscription boundaries were reviewed and preserved.
Existing coherent local Consumers stay at the owner of their Flutter effect.

Follow-up behavioral verification: `flutter test test/auth test/dashboard test/cards test/core/di test/core/router test/app_drawer_test.dart test/flow_exit_contract_test.dart` passed **385 tests**. Coverage includes repeat failures, effects after retained errors, retry-success, quote ordering/identity, initial category reveal, modal dismissal, controller interaction and route/Back behavior. No new behavior or mechanical structure-only test was added.

`git diff --check` passed. Final `flutter analyze`: **no issues found**. The 750-test full run above
predates this composition change and is not presented as its verification.
