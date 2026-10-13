# Deposits Development
[Full Dashboard development document](../dashboard/development.md)

| Phase | Screen | Figma node |
| --- | --- | --- |
| 1 | Single deposit | `27902:82476` |
| 2 | Multiple deposits | `27902:82503` |

## Reused components

AppDepositCard, AppPrimaryNavigation, AppTopBar, AppServiceGridCard, AppServiceGridItemView, AppServiceArtworkTile and AppAssistantButton are reused without source modifications. No duplicate shared component was introduced. New feature artwork is registered in AppAssets. SMS and cheque issuance icons were exported from their original instances after generated asset aliases proved incorrect.

## Behavior and integration

DashboardScreen now opens DepositsTab as the third retained tab. One deposit uses the single card; multiple deposits use a snapping RTL carousel with neighboring previews and indicator navigation. Switching tabs retains selection; system back returns to Dashboard. Loans opens its retained dashboard tab.

BankDeposit.hasChequeOperations drives cheque-section visibility independently of list length. The single Figma fixture enables it; the three multi fixtures disable it. Mixed caller data changes visible operations as selection changes. Data reorder retains selection by ID; removal falls back to the first remaining deposit; empty data renders safely.

Supply DashboardScreen.deposits and onDepositActionRequested for selected-deposit action context. onSelectedDepositChanged reports page changes. The existing onServiceRequested is a string-ID fallback and does not preserve deposit context. Standalone DepositsTab also supports original-value copy overrides, menu, assistant and tab callbacks. Fetching data, durable storage and executing bank operations remain caller-owned.

## Accepted component differences

Per the user decision, AppDepositCard retains its existing corner-aligned gradient/default stops and AppShadows.md. The required shadow already exists as AppShadows.bankCard. AppPrimaryNavigation retains the gray deposit icon even on its blue selected surface; Figma requires white. Exact values, consumers, reasons and recommended optional variants are documented in Dashboard development Section 13.

## Validation

Nine focused deposit tests and all 119 app tests pass. Application and avp_ui analysis report no issues. Preview geometry, assets, capabilities, selected callback context, copying, retained tab state, back navigation, data replacement and narrow-screen/larger-text use were verified.

## Dashboard ownership and Cubit migration

The tab, summary entity and action mapping now live under lib/features/dashboard. Dedicated feature folders are reserved for standalone pages. DepositsTab requires DashboardDepositsRepository; DepositsCubit/DepositsState own load outcomes and selected deposit. DashboardScreen keeps optional list seeds for its default mocks and accepts an injected DashboardRepositories bundle for service integration. See [current architecture and complete Figma audit](../dashboard/development.md) for loading/error/empty/single/multiple states, immutable selection, mock flow and future adapter requirements.

## Cubit/State coding convention

Follow [architecture Section 12](../architecture-smart-virtual-counter-v2-en.md#12-state-management-with-cubit) for new work and refactors. State is a plain Freezed data class with defaults and independent request statuses. Cubits accept an initial State, compute UI data and eligibility, and emit immutable snapshots through `copyWith`. UI reads those fields directly; no custom State/Cubit getters or UI-facing rules facade is used. Dependencies remain injectable and lifecycle/duplicate-request safeguards stay in place.
