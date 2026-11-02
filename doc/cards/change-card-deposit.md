# Change linked card deposit

**Current dependency rule — contract v1.24:** application/data operations follow
Cubit → registered UseCase → Repository. Cubit imports/resolves UseCases only;
`core/di` wires their repositories. Any earlier direct-Repository or optional-
UseCase wording below is historical and superseded. Payloads, Result mapping,
validation, retry identity and UI behavior remain unchanged. See the
[UseCase-only migration review](../usecase-only-dependencies-review.md).


Reviewed: 2026-11-01 — phase 4, contract v1.21.

Status: implemented with a registered repository and illustrative in-memory data. No bank operation or wallet debit is performed by the default adapter.

## Design and entry points

All references belong to the [Cards Figma design](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27997-10143).

| State | Node |
| --- | --- |
| Empty form | `27997:10143` |
| Card selected, destination empty | `27997:10849` |
| Destination and consent filled | `27997:10873` |

The authenticated route is `/cards/change-deposit` (`AppRoutes.changeCardDeposit`). Service ID `card-deposit` opens it from the dashboard service catalog, the dashboard card action, and the standalone card action sheet. Explicit host action callbacks retain precedence. `CardRouteArguments.initialCardNumber` carries selected-card context; a matching repository card is selected after loading. Unknown card numbers leave the selector empty rather than inventing a bank record.

## Behavior and state ownership

`ChangeCardDepositCubit` owns loading, selected card, destination eligibility, consent, submission and failures. The current deposit is derived from the selected card and displayed read-only. The destination list excludes that deposit. Changing a card resets destination and consent; changing destination resets consent. Submission requires a known card and destination, accepted terms and sufficient wallet balance. Loading submissions disable editing, back navigation and duplicate submission.

The initial empty design is an unselected form with loaded options, distinct from a genuinely empty catalog. Empty catalogs, loading and load failures have dedicated UI states with retry. A failed submission leaves the form editable. An unchanged retry retains its idempotency key; editing the request creates a new key. There is no request-ID or disposal guard: UI controls initial catalog retry and locks editing/Back during submission. No newest-load-wins behavior is claimed for arbitrary programmatic overlap.

The terms action delegates to the optional host callback. Without one, the app reports that the terms document is unavailable. Completion delegates to the optional receipt callback and displays an explicitly marked demo receipt when using the mock adapter.

## Data and integration

The category-level `CardServicesRepository` is shared with the [expired gift balance flow](expired-gift-balance.md). Its domain entities and requests live in `lib/features/cards/domain/`; `LoadCardServiceCatalogUseCase` validates IDs, deposit references and nonnegative monetary values, and adapter exceptions become `Failure` values.

`MockCardServicesRepository` supplies two accounts, selectable cards, a 1,300,000-rial illustrative fee and a 2,000,000-rial wallet balance. It also resolves the existing dashboard demo card. Fees are supplied by the adapter, not inferred from a bank tariff. Replace the repository when authoritative catalogs, eligibility, fees, terms and execution endpoints are available. The mock receipt cache only deduplicates calls in memory and does not persist or change balances or card linkage.

## UI composition

The screen supplies a `BlocProvider` whose `create` constructs the Cubit and calls `fetchCatalog()`. The provider closes it on removal and preserves it across ordinary rebuilds. A fresh route/Provider scope receives new entry context and resolves dependencies; ordinary rebuilds do not implicitly reset it. UI reads status and step directly from State. The Cubit computes selected records, empty-data state and action eligibility before emitting immutable State fields; no custom getters are defined. The view owns navigation and completion effects; the form owns the substantial input/invoice section. Inputs use `avp_ui` `AppSelect` directly, including the disabled current-deposit field. Buttons and checkboxes also come from `avp_ui`; the existing app invoice and top bar are reused. Shared request footer/status/spacing components are grouped under `presentation/shared/`, rather than creating a file per label or field. Handwritten UI files follow the widget skill's approximate 200-line target and allow cohesive sections around 200–300 lines.

All new copy is localized in the Persian, English and Arabic ARBs. App controls remain RTL in every locale; card display grouping uses the package formatter. Original Figma helper icons are bundled locally; runtime code has no temporary Figma URLs.

## Validation

Cubit tests cover selection/reset rules, seeded card normalization, wallet gating, adapter failures, UI invocation gates, safe retry and unchanged request keys. Widget tests exercise all three design states, submission failure/retry, service navigation and selected-card context. The shared Stepper has a regression test for right-aligned labels and dot spacing in the related gift flow.

Optional visual captures are generated by:

```sh
CAPTURE_CARD_SERVICE_PREVIEWS=1 flutter test test/cards/card_services/card_service_screens_test.dart
```

They go to ignored `build/previews/card-services/`; no screenshots or galleries belong in `doc/`.

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
| Deposit change | `submitDepositChange` | Submit and its retry |

`loadCardServiceCatalogUseCase` resolves the shared registered
`LoadCardServiceCatalogUseCase` from `card_services_usecase.dart`. Submission
uses `SubmitCardDepositChangeUseCase` from the same group, wired with the
repository in core/di. It preserves the request/key and existing exception
mapping without a Repository dependency in Cubit; no endpoint is added.

| Step | State read / retained | Next / lifetime |
|---|---|---|
| Catalog | catalogStatus, catalog, initial-card match, source/destinations | Failure/empty retry stays in scope |
| Select card/destination | selected objects, source, destination, consent, wallet and canSubmit | Card change must clear destination; either edit invalidates consent and retry key |
| Submission | exact card/source/destination IDs and key; status/editability | Failure retains input and key, enabling unchanged retry |
| Receipt | receipt and success status | Same route shows receipt and invokes onCompleted once; Back leaves without cleanup |
| Exit confirmation | navigation plus existing form | Cancel preserves form; authorized Back remains until pop |

There are four independent screen listeners: catalog failure, submission failure,
navigation and successful completion. Removed 10 blanket failure/message clears.
Destination, consent, submission-status and command clears retain their actual
form/modal readers. See [phase-4 verification](phase-4-review.md).
