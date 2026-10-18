# Dashboard Cards Development

| Screen | Figma node |
| --- | --- |
| Multiple cards | [27902:82561](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82561&m=dev) |
| Single card | [27902:82533](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82533&m=dev) |

## Reused components

- `AppResalatCard`: existing 335 × 202 single and 316 × 191 multi variants. Refined the gradient, security-field geometry, Medium/DemiBold detail weights, visibility masking, semantic labels and responsive width/text sizing.
- `AppServiceGridCard` and `AppServiceGridItemView`: existing service and quick-access variants. The new optional `stretchItems: false` preserves the 72px micro-service width, 6px gaps, and RTL alignment used by these frames. Existing callers retain their previous defaults.
- `AppTopBar`, `AppPrimaryNavigation`, `AppAssistantButton`, `AppAssistantIcon` and `AppServiceArtworkTile`: extracted the compatible dashboard visuals into shared widgets. Dashboard compatibility names remain available, and its existing notifications, search and customization interactions are retained.
- `AppShadows.bankCard` in `avp_ui`: reproduces the card instance's two shadow layers. The existing general-purpose `md` token remains separate.

All static assets are local and registered in `AppAssets`. The virtual-card artwork was exported from the original quick-access instance because the generated asset reference returned an identity icon. No screenshots are used as UI assets.

## Behavior and integration

The second primary tab now opens `CardsTab` from `DashboardScreen`.
Single-card data automatically selects the single layout; multiple cards use a snapping RTL carousel with neighboring-card previews and indicators.

Each card keeps its own visibility state. Hidden details mask expiry and CVV2 while retaining the card number and IBAN, matching Figma.
Copy actions preserve the original card number/IBAN and use the system clipboard unless the caller supplies an override.

Actions return `CardActionRequest`, including the selected `BankCard` and action.
The selected card's `canSetSecondPin` determines whether the middle PIN operation is “Set second PIN” (single frame) or “Forgot second PIN” (multi frame).
`HomeCubit` prepares `cardActions`, `pinActions` and `cardQuickActions` together
with the selected card in one State update. `CardsTab` renders these lists
directly; it does not decide which PIN operation applies or construct request
payloads. `requestCardAction` validates the current loaded selection and action
before returning a typed request for the UI's host callback. Loading, failure
and empty data expose no operations. Reloading re-evaluates changed card
capabilities, even when the selected card ID is unchanged.
The more/menu actions have caller callbacks; additional menu/service screens are outside these two supplied frames.

Supply `DashboardScreen.repositories`, `onCardActionRequested` and `onCardMorePressed` for integration.
The existing `onServiceRequested` remains a fallback for action IDs.
`CardsTab` has only `const CardsTab({super.key})`. It reads an ancestor
`HomeCubit` through BlocBuilder and sends interactions to Cubit actions.
`DashboardScreen` creates and disposes that Cubit through BlocProvider and
updates its repository when injected dependencies change. Default data come
from DashboardMockData through MockDashboardCardsRepository.

Typed `HomeEffect` values carry action, more, selection, copy, tab, menu and
assistant requests. A monotonically increasing `effectId` lets BlocListener
handle repeated identical interactions. DashboardScreen owns the listener that
executes clipboard/navigation/menu effects and host callbacks. Cubit contains
no BuildContext, platform clipboard calls or UI callback fields. Standalone
tests/hosts supply the same Provider/Listener scope around `const CardsTab()`;
the tab has no Repository or callback constructor parameters.

Tab switching retains dashboard favorites and card state. Back from Cards returns to Dashboard.
Deposits and Loans now open their retained feature tabs; see [Deposits development](../deposits/development.md) and [Loans development](../loans/development.md). Their menu fallbacks still open the respective service catalogs.

## Validation

Focused tests check both frame layouts, RTL ordering, carousel selection, per-card visibility, original-value copying, service callbacks, tab switching/back, enlarged text/small screens and empty data.
The dashboard and notification regression tests are included because navigation and header visuals are now shared.

Native status/navigation bars are excluded from the PNGs.

The [Dashboard architecture document](../dashboard/development.md) records the folder move, mock repository/Cubit design and complete component audit. All 119 app tests and 102 avp_ui tests pass; both analyzers report no issues.

## Cubit/State coding convention

Follow [architecture Section 12](../architecture-smart-virtual-counter-v2-en.md#12-state-management-with-cubit) for new work and refactors. State is a plain Freezed data class with defaults and independent request statuses. Cubits accept an initial State, compute UI data and eligibility, and emit immutable snapshots through `copyWith`. UI reads those fields directly; no custom State/Cubit getters or UI-facing rules facade is used. Dependencies remain injectable and lifecycle/duplicate-request safeguards stay in place.

## Unified Home ownership (2026-10-16)

All four dashboard tabs now share `HomeCubit`/`HomeState` at
`presentation/home/cubit/home_cubit.dart` and `home_state.dart`.
`DashboardScreen` provides the single scope and injects the repository bundle.
The tab constructors accept only `super.key`; load, selection, operation lists
and typed effects belong to Home. See [current state contract](../dashboard/development.md#12-state-management-with-cubit).
