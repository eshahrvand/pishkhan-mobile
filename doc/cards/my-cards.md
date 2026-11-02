# Dashboard Cards development and review

Reviewed: 2026-11-01 — Cubit migration, phase 2.

CardsTab is the retained Cards summary tab of DashboardScreen. It shares
HomeCubit/HomeState with Home, Deposits and Loans. The standalone card-list and
card-service flows belong to features/cards and are migrated separately.
The [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md) governs new
work; [Dashboard development](../dashboard/development.md) records current
ownership, operation/flow maps and validation.

## Ownership and data

DashboardScreen directly creates HomeCubit in BlocProvider.create and calls
fetchDashboard. CardsTab takes only super.key and reads the shared Provider.
There are no repository/callback constructor parameters or runtime repository
replacement API on either widget. HomeCubit receives no Repository arguments.

DI registers `LoadDashboardItemsUseCase<BankCard>`; HomeCubit resolves it into a
final field and calls it from fetchCards. Repository constructor wiring stays in
core/di. The existing mock repository supplies DashboardMockData until the bank
provides a real schema/adapter. No Cubit is registered in GetIt.

fetchCards explicitly emits loading before awaiting its one UseCase call, then
switches on Result for success/failure. It retains a previous selection snapshot
for ID reconciliation and invalidates current list/selection/actions while
loading. Success preserves a matching ID after reorder, otherwise selects the
first record; empty results clear selection/actions. Pure shared calculations
resolve selection/index and availability; emits stay visible in the action.

## User behavior

- One card uses the single layout; several use a snapping RTL carousel with
  neighboring previews and indicators. Selection survives tab switching.
- Each card has independent visibility. Hidden details mask expiry/CVV2 while
  number/IBAN remain visible. Reload reconciles privacy by card ID; single data
  defaults visible and multiple data defaults hidden.
- Cubit prepares cardActions, pinActions and cardQuickActions from the selected
  record. canSetSecondPin controls the setup operation; changed capabilities are
  re-evaluated even if the record ID is unchanged.
- requestCardAction constructs CardActionRequest from the selected BankCard.
  UI availability controls invocation; Cubit does not repeat eligibility or
  loading checks. The existing navigation adapter receives the prepared request.
- Copy effects preserve original strings. The Home listener executes clipboard
  and other Flutter effects; reusable commands are consumed before execution.
- Loading, error and empty UI expose no banking operations. Retry uses fetchCards.
  Failure notifications use the shared prepared-message/status-transition path.
- Back/loading, menu, assistant and supported service entries retain the common
  dashboard behavior. Unsupported actions keep unavailable feedback.

Flutter PageController ownership, attachment/reposition scheduling and disposal
remain in the carousel widget. They are not Cubit/State resources. No new keys,
UI wrappers, package variants, request counters or disposal guards were added.

## Components and design references

| Frame | Figma node |
| --- | --- |
| Multiple cards | `27902:82561` |
| Single card | `27902:82533` |

Reference file: nYQNyZdSs98lwymCpt5Sag. Existing AppResalatCard single/multi
variants, AppTopBar, service grids, artwork tiles, assistant and primary navigation
are retained. UI uses public avp_ui primitives/tokens, S.current, RTL and direct
AppConstants.baseImage paths. Shared assets are not copied or redrawn.

Historical component comparisons and known visual differences remain in
[Dashboard Section 13](../dashboard/development.md#13-design-system-package-avp_ui).
Phase 2 does not claim a new pixel comparison or package-wide visual approval.

## Verification

Tests under test/dashboard cover single/multiple/empty/error/loading, selection,
privacy, original-value copying, capability changes, service navigation, retained
state across tabs, small viewports and enlarged text. Domain tests also verify
immutable snapshots, invalid IDs and unexpected repository errors. Relevant
commands and current phase results are in Dashboard development; old 119/102
suite totals are not current validation claims.
