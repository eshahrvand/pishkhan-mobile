# Loans Development
[Full Dashboard development document](../dashboard/development.md)

| Phase | Screen | Figma node |
| --- | --- | --- |
| 1 | Single loan | `27902:82623` |
| 2 | Multiple loans | `27902:82592` |

## Reused components

AppLoanCard (including AppArrowButton and avp_ui AppProgressIndicator), AppTopBar, AppServiceGridCard, AppServiceGridItemView, AppServiceArtworkTile, AppAssistantButton and AppPrimaryNavigation are reused. The later progress fix corrects shared primitive sizing and the loan fill origin. No duplicate shared widget was introduced. Original operation/quick/pattern SVGs are registered in AppAssets. The identical quick-header asset is reused from depositsQuickAccess.

## Behavior and integration

DashboardScreen now retains four tabs. LoansTab renders one loan at 335×236 or multiple loans in an RTL snapping carousel at 316×236, with neighboring previews and indicators. Both states have four operations and two quick actions. Each action reports the selected BankLoan through LoanActionRequest. The summary arrow reports that card to the loan-details callback; no unspecified detail screen or banking operation is created. Copy callbacks/system clipboard preserve the raw original loan number.

Supply DashboardScreen.repositories, onLoanActionRequested, onSelectedLoanChanged and onLoanDetailsRequested. A string-ID onServiceRequested fallback remains available but loses selected-loan context. The menu uses the supplied callback or the existing loan-filtered catalog; the assistant returns to Dashboard. Selection survives tab switching and data reorder by ID. Removing the selected loan falls back to the first remaining item; empty input renders safely. After PageController replacement, a guarded post-frame jump restores the selected index; page-change callbacks are ignored during synchronization so an old offset cannot overwrite selection. No widget Key is manually assigned.

## Known component differences

The card keeps AppShadows.md instead of the already-available AppShadows.bankCard; its 54px header differs from the design's 56px body origin. The shared arrow and active Loans navigation icon remain gray where Figma uses blue/white respectively. The progress issue is fixed: the shared primitive keeps an 8px foreground, AppLoanCard selects the physical-left origin, and BankLoan derives 40% single / 30%,70%,90% multi from paid/total counts. Shared Persian labels and fixed row sizing also remain limitations. Exact source, values, consumers and recommended optional variants/package corrections are documented in Dashboard development Section 13.6.

## Validation

Eleven focused screen tests, two count-model tests and all 119 app tests pass. All 102 avp_ui tests pass. Application and avp_ui analysis report no issues. See the Dashboard document for exact results and limits.

## Dashboard ownership and Cubit migration

The tab, summary entity and action mapping live under lib/features/dashboard. Dedicated feature folders are reserved for standalone pages. DashboardScreen injects the DashboardRepositories bundle into HomeCubit; HomeState owns independent load outcomes and the selected loan alongside the other tabs. LoansTab has no repository parameter. See [current architecture and complete Figma audit](../dashboard/development.md) for loading/error/empty/single/multiple states, immutable selection, mock flow and future adapter requirements.

## Cubit/State coding convention

Follow [architecture Section 12](../architecture-smart-virtual-counter-v2-en.md#12-state-management-with-cubit) for new work and refactors. State is a plain Freezed data class with defaults and independent request statuses. Cubits accept an initial State, compute UI data and eligibility, and emit immutable snapshots through `copyWith`. UI reads those fields directly; no custom State/Cubit getters or UI-facing rules facade is used. Dependencies remain injectable and lifecycle/duplicate-request safeguards stay in place.

## Unified Home ownership (2026-10-16)

All four dashboard tabs now share `HomeCubit`/`HomeState` at
`presentation/home/cubit/home_cubit.dart` and `home_state.dart`.
`DashboardScreen` provides the single scope and injects the repository bundle.
The tab constructors accept only `super.key`; load, selection, operation lists
and typed effects belong to Home. See [current state contract](../dashboard/development.md#12-state-management-with-cubit).
