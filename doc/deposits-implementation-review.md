# My Deposits — Phases 1 and 2 implementation review

[Rendered previews](deposits-review/index.html) · [Full Dashboard development document](dashboard-development.md)

| Phase | Screen | Figma node | Preview |
| --- | --- | --- | --- |
| 1 | Single deposit | `27902:82476` | [PNG](deposits-review/phase1-single.png) |
| 2 | Multiple deposits | `27902:82503` | [PNG](deposits-review/phase2-multi.png) |

## Reused components

AppDepositCard, AppPrimaryNavigation, AppTopBar, AppServiceGridCard, AppServiceGridItemView, AppServiceArtworkTile and AppAssistantButton are reused without source modifications. No duplicate shared component was introduced. New feature artwork is registered in AppAssets. SMS and cheque issuance icons were exported from their original instances after generated asset aliases proved incorrect.

## Behavior and integration

DashboardScreen now opens DepositsScreen as the third retained tab. One deposit uses the single card; multiple deposits use a snapping RTL carousel with neighboring previews and indicator navigation. Switching tabs retains selection; system back returns to Dashboard. Loans continues to open the existing service catalog.

BankDeposit.hasChequeOperations drives cheque-section visibility independently of list length. The single Figma fixture enables it; the three multi fixtures disable it. Mixed caller data changes visible operations as selection changes. Data reorder retains selection by ID; removal falls back to the first remaining deposit; empty data renders safely.

Supply DashboardScreen.deposits and onDepositActionRequested for selected-deposit action context. onSelectedDepositChanged reports page changes. The existing onServiceRequested is a string-ID fallback and does not preserve deposit context. Standalone DepositsScreen also supports original-value copy overrides, menu, assistant and tab callbacks. Fetching data, durable storage and executing bank operations remain caller-owned.

## Accepted component differences

Per the user decision, AppDepositCard retains its existing corner-aligned gradient/default stops and AppShadows.md. The required shadow already exists as AppShadows.bankCard. AppPrimaryNavigation retains the gray deposit icon even on its blue selected surface; Figma requires white. Exact values, consumers, reasons and recommended optional variants are documented in Dashboard development Section 13.

## Validation

Nine focused deposit tests and all 94 app tests pass. Analysis reports only the existing absolute Windows avp_ui path warning. Preview geometry, assets, capabilities, selected callback context, copying, retained tab state, back navigation, data replacement and narrow-screen/larger-text use were verified.

Regenerate with UPDATE_DEPOSITS_PREVIEWS=1 and flutter test test/deposits_screen_test.dart. The gallery includes safe-area spacing but excludes native system bar controls.
