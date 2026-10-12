# Dashboard implementation review

All four phases are implemented from the updated Mobile Figma file.
Open [the rendered screen gallery](dashboard-review/index.html) to review all nine states.

| Phase | Screen | Figma node | Preview |
| --- | --- | --- | --- |
| Phase 1 | Default | [27902:80847](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-80847&m=dev) | [PNG](dashboard-review/phase1-default.png) |
| Phase 1 | Default setting | [27902:81083](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-81083&m=dev) | [PNG](dashboard-review/phase1-setting.png) |
| Phase 2 | Customize service | [27902:81228](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-81228&m=dev) | [PNG](dashboard-review/phase2-services.png) |
| Phase 2 | Search service | [27902:81468](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-81468&m=dev) | [PNG](dashboard-review/phase2-search.png) |
| Phase 3 | Customize (six) | [27902:81700](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-81700&m=dev) | [PNG](dashboard-review/phase3-edit-six.png) |
| Phase 3 | Customize (eight) | [27902:81873](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-81873&m=dev) | [PNG](dashboard-review/phase3-edit-eight.png) |
| Phase 3 | Reset | [27902:82066](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82066&m=dev) | [PNG](dashboard-review/phase3-reset.png) |
| Phase 4 | Customized | [27902:80947](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-80947&m=dev) | [PNG](dashboard-review/phase4-customized.png) |
| Phase 4 | All services | [27902:82267](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82267&m=dev) | [PNG](dashboard-review/phase4-all-services.png) |

## Component review

- Wallet card and bottom-sheet header reuse the existing shared components.
- The base micro-service component remains a 72px item with a 64px tile, 32px icon, 8px gap and 10px/16px Regular label. Its public view now accepts instance width and tile size. The all-services page uses four flexible columns and 12px/18px Medium labels; the editor uses 66px tiles.
- The eight fixed services and the selected-services card are separate compositions. The selected card has an empty action, three suggested services, editing, saved, eight-item limit, and reset states.
- The compact service choices named “Deposit Card” in the sheet are ordinary frames, not the existing bank deposit card. They are implemented directly from the page frames; no extra component link is required.
- Public `avp_ui` additions: `AppDashboardColors`, `AppButton.foregroundColor` and `AppSearchField.clearIcon`. Defaults remain compatible with existing consumers.
- Original Figma SVGs are local and registered in `AppAssets`. The original header and back icons were exported from their instance nodes because the design-context connector returned the menu SVG for multiple distinct icons. SVG blur/shadow filters are reproduced with Flutter effects where the SVG renderer cannot render them.

## Behavior

“View all” opens a separate page with 45 services across nine categories.
The add-service sheet has compact choices, a collapsible cards group, searchable grouped results, and disabled choices for services already selected.
Search normalizes Persian/Arabic yeh and kaf and zero-width spaces.

Customization allows at most eight unique services. Draft additions/removals do not alter saved choices until Confirm. Cancel discards the draft; confirmed Reset clears the selection. Starting from the empty action suggests issuance, credit consolidation and changing the linked card deposit.

`initialFavorites` supplies saved IDs; `onFavoritesChanged` reports confirmed/reset selections.
`onServiceRequested`, `onPromptSubmitted`, `onMenuPressed` and `onProfilePressed` remain caller integration points. Durable storage and banking service execution belong to the caller.

The search frame repeats the card-deposit text under Wallet, while the all-services frame labels it as the wallet deposit. The implementation keeps the wallet-specific catalog label and service ID in search.

## Motion and accessibility

The Figma frames contain no authored motion timelines. The requested animations use:
- hint typing/erasing at 90ms per grapheme, with pauses between phrases;
- a smooth 12-second gradient/glow movement cycle behind the unchanged artwork.

Hint animation pauses while the field is focused or contains user text. It never writes the input controller. Motion stops for reduced-motion settings, disabled tickers and background lifecycle states.
`DashboardScreen.enableAnimations` defaults to true; static previews disable it.
Small screens and enlarged text retain scrolling, wrapped labels and reachable actions.

## Validation

The app test suite and shared button/search tests cover transactional editing, the eight-item limit, reset confirmation, grouped search/clear/duplicate prevention, catalog navigation, callbacks, responsive layouts, and motion/input preservation.
Optional preview regeneration: set `UPDATE_DASHBOARD_PREVIEWS=1` and run `flutter test test/dashboard_review_test.dart`.
Previews exclude native status/navigation bars and the system keyboard.

## Development architecture and Deposits tab

See [Dashboard development document](dashboard/dashboard-development.md) for the complete 21-section feature architecture, file map, data and icon inventory, server contract proposal and known shared-component differences. The [deposit review gallery](deposits-review/index.html) covers single and multiple deposits.

## Loans tab

Both Loans phases are now integrated as the fourth retained primary tab. See [Loans implementation review](loans-implementation-review.md), [loan previews](loans-review/index.html) and [Dashboard development document](dashboard/dashboard-development.md) for model/state architecture, selected-loan callback contracts, server readiness and shared-component differences.

## Dashboard folder and state migration

All four dashboard surfaces are owned by lib/features/dashboard. Home and the three banking tabs use Cubit/state classes with domain repository interfaces and asynchronous mock implementations. Dedicated card/deposit/loan folders are reserved for standalone pages. The relocated [Dashboard architecture document](dashboard/dashboard-development.md) contains the complete file map, lifecycle/selection rules, service replacement steps and avp_ui Figma audit. Application tests: 119; package tests: 102 pass; both analyzers report no issues.
