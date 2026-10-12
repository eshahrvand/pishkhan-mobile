# My Loans — Phases 1 and 2 implementation review

[Rendered previews](loans-review/index.html) · [Full Dashboard development document](dashboard/dashboard-development.md)

| Phase | Screen | Figma node | Preview |
| --- | --- | --- | --- |
| 1 | Single loan | `27902:82623` | [PNG](loans-review/phase1-single.png) |
| 2 | Multiple loans | `27902:82592` | [PNG](loans-review/phase2-multi.png) |

## Reused components

AppLoanCard (including AppArrowButton and avp_ui AppProgressIndicator), AppTopBar, AppServiceGridCard, AppServiceGridItemView, AppServiceArtworkTile, AppAssistantButton and AppPrimaryNavigation are reused. The later progress fix corrects shared primitive sizing and the loan fill origin. No duplicate shared widget was introduced. Original operation/quick/pattern SVGs are registered in AppAssets. The identical quick-header asset is reused from depositsQuickAccess.

## Behavior and integration

DashboardScreen now retains four tabs. LoansTab renders one loan at 335×236 or multiple loans in an RTL snapping carousel at 316×236, with neighboring previews and indicators. Both states have four operations and two quick actions. Each action reports the selected BankLoan through LoanActionRequest. The summary arrow reports that card to the loan-details callback; no unspecified detail screen or banking operation is created. Copy callbacks/system clipboard preserve the raw original loan number.

Supply DashboardScreen.loans, onLoanActionRequested, onSelectedLoanChanged and onLoanDetailsRequested. A string-ID onServiceRequested fallback remains available but loses selected-loan context. The menu uses the supplied callback or the existing loan-filtered catalog; the assistant returns to Dashboard. Selection survives tab switching and data reorder by ID. Removing the selected loan falls back to the first remaining item; empty input renders safely. A subtree keyed by the PageController prevents an old scroll offset from overriding selection after data replacement.

## Known component differences

The card keeps AppShadows.md instead of the already-available AppShadows.bankCard; its 54px header differs from the design's 56px body origin. The shared arrow and active Loans navigation icon remain gray where Figma uses blue/white respectively. The progress issue is fixed: the shared primitive keeps an 8px foreground, AppLoanCard selects the physical-left origin, and BankLoan derives 40% single / 30%,70%,90% multi from paid/total counts. Shared Persian labels and fixed row sizing also remain limitations. Exact source, values, consumers and recommended optional variants/package corrections are documented in Dashboard development Section 13.6.

## Validation

Eleven focused screen tests, two count-model tests and all 119 app tests pass. All 102 avp_ui tests pass. Application and avp_ui analysis report no issues. See the Dashboard document for exact results and limits. The previews include safe-area spacing and exclude native system bar controls. Regenerate with UPDATE_LOANS_PREVIEWS=1 and flutter test test/loans_screen_test.dart.

## Dashboard ownership and Cubit migration

The tab, summary entity and action mapping now live under lib/features/dashboard. Dedicated feature folders are reserved for standalone pages. LoansTab requires DashboardLoansRepository; LoansCubit/LoansState own load outcomes and selected loan. DashboardScreen keeps optional list seeds for its default mocks and accepts an injected DashboardRepositories bundle for service integration. See [current architecture and complete Figma audit](dashboard/dashboard-development.md) for loading/error/empty/single/multiple states, immutable selection, mock flow and future adapter requirements.
