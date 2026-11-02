# Transfer expired gift card balance

**Current dependency rule — contract v1.24:** application/data operations follow
Cubit → registered UseCase → Repository. Cubit imports/resolves UseCases only;
`core/di` wires their repositories. Any earlier direct-Repository or optional-
UseCase wording below is historical and superseded. Payloads, Result mapping,
validation, retry identity and UI behavior remain unchanged. See the
[UseCase-only migration review](../usecase-only-dependencies-review.md).


Reviewed: 2026-11-01 — phase 4, contract v1.21.

Status: interactive two-step flow with a registered repository. The default adapter records a demo request without transferring funds.

## Design and entry points

All references belong to the [Cards Figma design](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27997-10381).

| State | Node |
| --- | --- |
| Selection without account filter | `27997:10381` |
| Selected cards | `27997:10644` |
| Removable selected-card sheet | `27997:10746` |
| Destination empty | `27997:10666` |
| Destination and consent filled | `27997:10706` |
| Selection with account filter | `27997:10403` |
| Filter sheet, all accounts | `27997:10576` |
| Filter sheet, account selected | `27997:10610` |

The authenticated route is `/cards/expired-gift-balance` (`AppRoutes.expiredGiftBalance`). Service ID `card-expired-gift` now opens this workflow from the service catalog and the standalone Gift cards action. Explicit host callbacks retain precedence. The existing generic gift-balance action on dashboard cards is a separate service and retains its behavior.

## Selection and review

`ExpiredGiftBalanceCubit` owns the workflow, search, selected card objects, computed total, temporary/applied filter, destination, consent and submission. The filter button and each card's linked-deposit row are shown when the customer's catalog has at least two accounts. One-account catalogs use the no-filter layout. The default mock catalog has two accounts; a one-account repository fixture exercises the alternative.

Search normalizes Persian and Arabic digits and accepts grouped card numbers. Select all affects the visible result set only. Search and filters preserve selections outside that result set. The review sheet always lists the complete selection, with sequential numbering and removal actions. Removing cards updates the count and total in Cubit and resets consent.

Next opens the selected-card sheet. Its Back button closes the sheet and advances to destination selection when at least one card remains. Outside/back dismissal stays on selection. The header's list action also opens review; closing it on the destination step preserves that step. Removing the last card returns to selection and disables Next.

## Destination and submission

Destination shows the selected count and sum of those cards' actual balances. The sample Figma summary differs from the sum of its repeated sample rows; the implementation computes the total consistently rather than copying that conflicting constant.

Destination selection and accepted terms are required to submit. Going back retains selected cards and destination, but clears consent. The terms action accepts a host callback and otherwise reports the unavailable document. Pending transfers disable edits, duplicate submission and workflow back navigation. Failures are retryable; unchanged retries preserve the request's idempotency key. Completion displays the adapter receipt with an explicit demo marker when appropriate.

## Filter sheet

Opening the filter copies the applied account into a draft. Choosing an account changes only the draft. Apply commits it; dismissing cancels it. The All option removes the filter. The selector passes the rendered typed filter option; Cubit does not repeat option-membership checks. The account filter is independent of the transfer destination.

## Data and UI integration

The flow shares `CardServicesRepository`, validated `CardServiceCatalog` and typed receipts with [change linked card deposit](change-card-deposit.md). Gift requests contain selected card IDs, destination ID and an idempotency key. The mock adapter validates the selection and records an in-memory demo receipt. Real expiry, ownership, eligibility, available amounts, destination permissions, server idempotency and execution must be supplied by the bank adapter. Zero-balance cards cannot be selected.

The screen supplies a `BlocProvider` whose `create` constructs the Cubit and calls `fetchCatalog()`. The provider closes it on removal and retains it across ordinary rebuilds; a fresh route scope resolves its registered dependencies without adding a runtime repository setter. UI reads status and step directly from State. Search results, selected records, totals and action eligibility are computed in the Cubit and emitted as immutable State fields; no custom getters are defined. The view owns navigation and completion effects. Selection, destination and the two substantial sheets are coherent UI sections; related card detail rows remain with selection and are reused by review. Search uses `avp_ui` `AppTextField` directly; selectors, checkboxes, toggles, buttons and progress use package components. The existing app sheet header and authored scrim are reused. The top bar's optional leading action slot is scoped to this screen and preserves previous callers' defaults.

Before implementing the flow, `avp_ui` `AppStepper` was fixed to keep the title dot adjacent to the title and the supporting copy on the physical right under RTL. The 42-pixel ring remains on the physical left, with the authored 24-pixel gap and 6-pixel text gap. Long labels wrap. This requires distributing the updated sibling package with the app.

All new copy is localized for Persian, English and Arabic, and inputs remain RTL. Native status/navigation bars are owned by the platform. Sheets reserve safe areas, constrain their height and scroll on small screens.

## Validation

Cubit tests cover account-count variants, normalized search, visible-set selection, draft filter cancellation/application, removal, totals, back behavior, consent, transfer gating and retry. Widget tests exercise the supplied states, both sheets, account variants, service navigation and 320-pixel phones with enlarged text in all three locales. A geometry regression verifies Stepper dot/title alignment and subtitle spacing.

Optional captures use `CAPTURE_CARD_SERVICE_PREVIEWS=1 flutter test test/cards/card_services/card_service_screens_test.dart` and write to ignored `build/previews/card-services/`. No images or visual review galleries are stored in `doc/`.

## Cubit/State coding convention

Follow the authoritative [UI/Cubit/State contract v1.21](../ui-cubit-state-agent-rules-en.md)
and [clean-code skill](../../.agents/skills/pishkhan-cubit-clean-code/SKILL.md).
Keep the plain Freezed `State.initial` / `part of` structure and independent
operation statuses. Cubit owns requests, form calculations and modal-result
interpretation, with explicit copyWith/emit and async/await followed by Result
switches. Each operation has one owner. No `.then`, isClosed, defensive action
entry checks or State publication helpers are introduced.

GetIt registers dependencies, never Cubits. Existing UseCases have the `UseCase`
class suffix and `_usecase.dart` filename suffix, are wired in core/di and are
resolved once in final Cubit fields. Provider.create directly constructs Cubit
and calls its real fetch action. UI/router do not forward data dependencies.

Screen-level MultiBlocListener groups independent request feedback, effects,
navigation and completion. BlocBuilder renders; coherent local controller/modal
Consumers remain at their resource owner. Each entering-failure listener displays
the prepared text from that snapshot; effect handlers never gate on retained
message presence. Failure/message may remain after recovery. Existing success
behavior, Back gates, typed payloads and command consumption are preserved.

## Phase-4 flow review

| Operation | Owner | Trigger |
|---|---|---|
| Catalog | `fetchCatalog` | Provider entry; failed/empty catalog Retry |
| Transfer | `_submitTransfer` | Destination branch of `submitCurrentStep`; retry |

`LoadCardServiceCatalogUseCase` is registered/wired in DI and resolved in its
final Cubit field. `TransferGiftBalanceUseCase` owns the transfer dependency in
the same `card_services_usecase.dart` group. DI wires both; Cubit has no
Repository import/lookup. The existing typed request/key and Result mapping remain.

| Step | State read / retained | Next / lifetime |
|---|---|---|
| Catalog/list | catalogStatus, visible cards, gift/deposit map, filter options | Successful data enters selection; empty/failure can retry |
| Select/search/filter | selected card objects, total, visible selection, draft/applied filter | Search/filter retain hidden selections; modal cancellation retains committed filter |
| Review | complete selection, advanceAfterReview, step, edit/review flags | Remove updates total/consent; empty selection returns to selection; raw dismissal preserves the defined step |
| Destination | selected cards/total, destination, consent, canContinue | Back keeps selections/destination but invalidates consent |
| Submit/retry | status, selected IDs/destination/key, editability | Same payload retains key; selection/destination changes invalidate it |
| Receipt/exit | receipt, success and navigation | Callback/inline receipt stay on route; Back exits without selection cleanup |

Toggle one card, select all visible and remove from review are independent
selection events. Each now explicitly emits its own selected cards, total,
eligibility and consent changes. Shared pure calculations remain; the former
`_selectGiftCards` State-publication intermediary is removed. The catalog’s
indexed gift/deposit mapping is a pure calculation, not a State builder.

Five screen listeners separately own two request failures, navigation, typed
filter/review effects and success completion. Removed 12 blanket failure/message
clears from the original source. Real selection/consent, modal availability,
submission-state and command updates remain. See [phase-4 verification](phase-4-review.md).
