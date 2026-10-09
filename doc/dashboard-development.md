# Dashboard Development Document — Smart Virtual Counter

**Project:** Pishkhan AI / Resalat Smart Virtual Counter mobile application  
**Framework:** Flutter / Dart  
**Document version:** 1.0.0  
**Date:** 2026-10-09  
**Status:** UI implementation; bank repositories and service execution are not connected  
**Scope:** Dashboard shell, dashboard page, Cards tab integration, Deposits phases 1–2, notification navigation  
**Architecture reference:** [architecture-smart-virtual-counter-v2-en.md](architecture-smart-virtual-counter-v2-en.md)

This feature document follows all 21 sections of the project's architecture document in the same order. It records the current code separately from proposed architecture and server integration. The architecture document is a revised draft; listing a planned library or layer there does not mean it exists in this application.

## Table of Contents

1. Architectural Goals and Principles
2. Product Scope and Target Platforms
3. Technology Stack
4. Development Environment and Versions
5. Third-Party Dependency Governance
6. Project Structure and Modularization
7. Layering Pattern
8. Service Flow Pattern and Suspended Requests
9. Security and Compliance Layer
10. Network and Authentication Layer
11. Error Handling Pattern
12. State Management with Cubit
13. Design System Package
14. Localization, Persian Support, and Dates
15. Routing and Guards
16. Testing Strategy
17. Development and Code Review Process
18. Environments, CI/CD, and Release
19. AI Assistant and Agent Layer
20. Open Items and Dependencies
21. Change Log

## 1. Architectural Goals and Principles

The shell composes existing visual components and passes integration events to the caller. It does not fetch banking data, authenticate service operations, or execute requests. Deposit actions carry the selected deposit rather than relying on a global selection.

For this task the user's component decision explicitly takes precedence over exact Figma matching: use the existing shared components unchanged. Neither `AppDepositCard` nor `AppPrimaryNavigation` was modified. The same applies to the top bar, grids, artwork tile and assistant button. Known differences are recorded in Section 13.

The current prototype uses feature presentation folders and simple presentation models. The final clean architecture requires domain entities, use cases, repository interfaces, remote DTOs and mappers; those have not been fabricated for a UI-only implementation.

## 2. Product Scope and Target Platforms

### 2.1 Implemented screens, tabs and phases

| Surface | Implemented states / behavior | Source |
| --- | --- | --- |
| App entry | Persian locale, enforced RTL, prototype login completion switches to shell | `lib/main.dart` |
| Dashboard page | Wallet example, Reso prompt, eight fixed services, empty favorites, draft editing, saved favorites, eight-item limit, reset confirmation | `lib/features/dashboard/presentation/dashboard_screen.dart`, `shared/widgets/dashboard_bank_services.dart` |
| Dashboard phase 1 | Default dashboard and starting customization | Figma nodes `27902:80847`, `27902:81083` |
| Dashboard phase 2 | Add-service sheet and grouped search | `27902:81228`, `27902:81468` |
| Dashboard phase 3 | Six/eight draft favorites and reset | `27902:81700`, `27902:81873`, `27902:82066` |
| Dashboard phase 4 | Saved favorites and separate all-services page | `27902:80947`, `27902:82267` |
| Cards tab | Single/multiple card layouts, selected card, per-card visibility, copy, selected-card action callbacks | `lib/features/cards/presentation/cards_screen.dart`; `27902:82533`, `27902:82561` |
| Deposits phase 1 | Single 335×202 deposit card, deposit operations, cheque operations when eligible, quick access | `lib/features/deposits/presentation/deposits_screen.dart`; [27902:82476](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82476) |
| Deposits phase 2 | Multiple 316×191 deposit cards, snapping RTL carousel, neighboring previews, indicators, selected-deposit actions | Same screen; [27902:82503](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82503) |
| Deposits empty | Localized empty message and usable shell controls | `DepositsScreen(deposits: [])` |
| Loans tab | Opens existing filtered loan service sheet; dedicated loan tab UI is not implemented | `DashboardScreen._selectTab` |
| Notifications | Bell pushes list; opening marks read; Read all; detail; read state retained during shell lifetime | `lib/features/notifications/presentation/` |

Single versus multiple deposit layout is determined by list length. Cheque visibility is determined by `BankDeposit.hasChequeOperations`, independently of length. One deposit can have no cheque section; an eligible deposit in a multi-deposit list can have one. The default single example is eligible; all three default multi examples are ineligible, matching the supplied states.

The single frame has eight deposit operations, three cheque operations and eight quick actions. The multiple frame has eight deposit operations and eight quick actions. This implementation does not equate “multiple deposits” with “cheques unavailable.”

### 2.2 Platform scope

The architectural product targets Android, iOS and mobile Safari as the iOS fallback. This work is Flutter UI and adds no platform package. Clipboard copying uses `flutter/services.dart`. Native status/navigation bars and keyboards are excluded from review PNGs. No native device build or web deployment is claimed by these widget tests.

## 3. Technology Stack

| Concern | Installed/current implementation | Planned architecture, not implemented here |
| --- | --- | --- |
| Widgets | Flutter Material layout, public `avp_ui` primitives, app shared components | Additional banking flow screens |
| Favorites state | `flutter_bloc` / `DashboardCubit` | Repository-backed preferences |
| Deposit selection | Private StatefulWidget state + PageController | Cubit when asynchronous deposit loading/service status is added |
| Static artwork | `flutter_svg`, bundled PNGs, `AppAssets` | Remote icon resolver/cache |
| Localization | ARB + Flutter generated localizations, fa/en/ar | Remote localized feature text fallback |
| Routing | IndexedStack and Navigator/MaterialPageRoute | `go_router`, core service registry and guards |
| Network | None in these features | Dio/Retrofit, generated OpenAPI DTOs |
| DI / serialization | None in these features | get_it/injectable, json_serializable |
| Testing | flutter_test, font-loaded widget renders | Contract, mapper, repository and E2E tests |

`pubspec.yaml` points `avp_ui` to `C:\Users\mahdi\StudioProjects\avp_ui`. Only `package:avp_ui/avp_ui.dart` is imported. The machine-specific dependency is existing setup, not a change made for Deposits.

## 4. Development Environment and Versions

The project Dart constraint is `^3.13.3` in `pubspec.yaml`. The architecture document's Flutter/FVM selection is a policy proposal, not a completed pin in this repository. Do not infer an exact Flutter version from this feature document.

Configuration files are `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml` and `l10n.yaml`. Current analysis uses `flutter_lints`; the architectural custom import lints are not installed. Generated localization output is under `lib/l10n/generated/`.

The local SDK requires access to its cache outside the repository when generating localization or running tests. That execution requirement does not authorize changing SDK versions or shared-package source.

## 5. Third-Party Dependency Governance

No dependency was added for this task. The existing Flutter, avp_ui, flutter_bloc, flutter_svg and localization dependencies are sufficient.

Remote image delivery would require choosing a caching strategy or approved package later. SVG and raster delivery must not be assumed to share an implementation. The existing `SvgPicture.asset` callsites support local SVGs only; `AppServiceArtworkTile` accepts an asset path, not a URL or arbitrary ImageProvider.

## 6. Project Structure and Modularization

### 6.1 File and folder map

All paths below are relative to this repository unless explicitly identified as package-owned.

| Path | Classes / responsibility |
| --- | --- |
| `lib/main.dart` | PishkhanApp, MyApp; app theme, localization, RTL, prototype auth boundary |
| `lib/features/dashboard/presentation/dashboard_screen.dart` | DashboardScreen, _DashboardScreenState; shell tabs, favorites owner, navigation and caller callbacks |
| `lib/features/dashboard/presentation/cubit/dashboard_cubit.dart` | DashboardState and DashboardCubit; committed favorites, nullable draft, edit/add/remove/confirm/cancel/reset |
| `lib/features/dashboard/presentation/shared/dashboard_services.dart` | DashboardService (46 IDs), DashboardCategory (nine groups); label and icon mapping, fixed/recommended/group lists |
| `lib/features/dashboard/presentation/shared/dashboard_assets.dart` | DashboardAssets; aliases for header/pattern assets |
| `lib/features/dashboard/presentation/shared/widgets/dashboard_bank_services.dart` | DashboardBankServices, DashboardDashedBorder; fixed services and favorite editor |
| `lib/features/dashboard/presentation/shared/widgets/dashboard_service_tile.dart` | DashboardServiceTile; saved/editing artwork and fallback wave/icon composition; DashboardAssistantIcon compatibility alias |
| `lib/features/dashboard/presentation/shared/widgets/dashboard_services_sheet.dart` | DashboardServicesSheet, private state; grouped catalog, query normalization, exclusions, collapse; sheet/reset entry functions |
| `lib/features/dashboard/presentation/shared/widgets/dashboard_all_services_screen.dart` | DashboardAllServicesScreen, DashboardCategoryHeading; full catalog and category visual mapping |
| `lib/features/dashboard/presentation/shared/widgets/dashboard_reso_banner.dart` | DashboardResoBanner and private state; text controller, hint timer, glow animation, lifecycle and texture loading |
| `lib/features/dashboard/presentation/shared/widgets/dashboard_header.dart` | Compatibility DashboardHeader wrapping shared top bar |
| `lib/features/deposits/models/bank_deposit.dart` | BankDeposit; caller-supplied presentation data and Figma example fixtures |
| `lib/features/deposits/presentation/deposits_screen.dart` | DepositsScreen, _DepositsScreenState; layout, selected index, PageController, copy and UI callbacks |
| `lib/features/deposits/presentation/shared/deposit_actions.dart` | DepositAction; action IDs, three ordered lists, localization/icon mapping; DepositActionRequest |
| `lib/features/cards/models/bank_card.dart` | BankCard, BankCardKind; example/presentation card data |
| `lib/features/cards/presentation/cards_screen.dart` | CardsScreen, private state, CardAction, CardActionRequest |
| `lib/features/notifications/models/notification_message.dart` | NotificationMessage, examples and markRead |
| `lib/features/notifications/presentation/notifications_screen.dart` | NotificationsScreen, private message list/read-state update |
| `lib/features/notifications/presentation/notification_detail_screen.dart` | NotificationDetailScreen |
| `lib/features/notifications/presentation/widgets/` | NotificationHeader, NotificationCard |
| `lib/shared/assets/app_assets.dart` | AppAssets; canonical local asset constants and all-file integrity list |
| `lib/shared/widgets/` | Shared visual widgets listed in Section 13 |
| `lib/l10n/app_fa.arb`, `app_en.arb`, `app_ar.arb` | App-owned copy |
| `lib/l10n/l10n.dart` | AppLocalizations export and context.l10n extension |
| `lib/l10n/generated/` | Generated localization classes; modify ARBs, then regenerate |
| `test/deposits_screen_test.dart` | Deposit layout, selection, copy, data updates, tab/back and responsive checks; optional previews |
| `doc/deposits-review/` | Rendered phase1-single.png and phase2-multi.png, gallery |
| `doc/dashboard-development.md` | This document |

There is no Dashboard/Deposits DTO mapper, remote datasource, repository implementation, domain entity, domain repository or use case in the current code. `BankDeposit` is a presentation model despite living under `models/`; it is not an OpenAPI DTO or banking domain object.

### 6.2 Module boundaries

The current DashboardScreen imports CardsScreen/BankCard and DepositsScreen/BankDeposit to compose the prototype shell. This mirrors existing card integration but differs from the draft architecture's strict “no direct cross-feature imports” goal. A production shell/router should own composition and use core service contracts. This task does not add domain coupling or execute cross-module bank services.

## 7. Layering Pattern (Clean Architecture)

### 7.1 Current layers

**UI:** Screens build widget trees from public design primitives and existing shared widgets. Deposits composes AppDepositCard and AppServiceGridCard. Visual group layout is local composition, not a duplicate shared component.

**Presentation state:** Favorites are controlled by DashboardCubit. Selected primary tab, notifications cache and prompt focus are private shell state. Deposit index and page controller are private deposit-screen state. Models and action requests are passed by constructors/callbacks.

**Domain/data:** Not connected. Static enum IDs and examples substitute for backend data. There is no account validation, entitlement service, balance fetch, request submission or durable favorites storage.

### 7.2 Intended production dependency direction

```text
Remote API -> generated DTO -> Data mapper -> Domain entity
     ^              Repository implementation -> Repository interface
     |                                                   ^
  datasource                                          Use case
                                                          ^
                                                       Cubit
                                                          |
                                              presentation state/model
                                                          v
                                        screen -> shared + avp_ui widgets
```

Proposed mapper locations are `lib/features/dashboard/data/mappers/` for catalog response mapping and `lib/features/deposits/data/mappers/` for deposit DTOs. These folders do not exist in this implementation. Keep localized labels and formatted Jalali dates in presentation mapping; keep Gregorian/UTC dates and raw identifiers in the domain.

## 8. Service Flow Pattern and Suspended Requests

### 8.1 Current flow contract

DashboardScreen exposes:
- `initialFavorites` and `onFavoritesChanged(List<String>)`.
- `onServiceRequested(String)` and `onPromptSubmitted(String)`.
- `onMenuPressed`, `onProfilePressed`.
- `cards`, `onCardActionRequested(CardActionRequest)`, `onCardMorePressed(BankCard)`.
- `deposits`, `onDepositActionRequested(DepositActionRequest)`, `onSelectedDepositChanged(BankDeposit)`.
- `enableAnimations`, default true.

DepositsScreen additionally exposes `onCopyNumber`, `onCopyIban`, `onTabSelected`, `onMenuPressed` and `onAssistantPressed`. The shell leaves copy callbacks unset so the existing platform clipboard fallback runs.

For a deposit action the dedicated callback receives both action and selected deposit. If it is absent, the shell falls back to `onServiceRequested(request.action.id)`, which loses deposit context. Production integration should provide the dedicated callback for deposit-scoped operations.

A null callback produces no bank execution. Selection events are fired on PageView page changes, not on initial construction or programmatic data replacement. Clients can derive initial selection from the first supplied item.

### 8.2 Deposit-dependent features

`BankDeposit.hasChequeOperations` is the only current per-deposit action capability. The screen reads it from `widget.deposits[_selected]` on each build; it inserts/removes the entire cheque group and gap. Other groups are fixed lists in DepositAction. Action requests always include the selected BankDeposit.

A server can supply `capabilities.chequeOperations`, or, more flexibly, a per-deposit `availableFeatureIds` list mapped into this flag today. A future presentation model should expose allowed/enabled action sets rather than infer them from account count or account type. Backend authorization must still validate every request.

### 8.3 Suspended requests and drafts

The UI has no suspended-request persistence/resumption. Favorites drafts are a different concept: a local editing transaction, not a submitted banking request. The architecture's request ID, idempotency, resumption and final confirmation belong to future service flows.

## 9. Security and Compliance Layer

No new security implementation is introduced. This is a UI prototype; logging into the demo does not verify bank credentials. Deposit examples are static and copy operations return caller-provided original strings.

Neither visual hiding nor omission of a service is authorization. Server capabilities/permissions are for presentation; production APIs must enforce identity, ownership, service eligibility and platform restrictions. Cached catalog metadata must not grant a capability after it has been revoked.

Do not persist deposit numbers, IBANs, user prompts or tokens merely to implement catalog icon caching. Financial data storage follows the separate architecture's platform/security decisions.

## 10. Network and Authentication Layer

### 10.1 Current feature data sources, field by field

Dashboard services are instances of a compile-time enum, not records decoded from JSON. Category membership and order are compile-time lists. Favorites are constructor-supplied IDs validated against that enum, or IDs chosen locally. There is no server feature response yet.

| Field / behavior | Actual current source | Dynamic today? | Server feasibility and required code change |
| --- | --- | --- | --- |
| ID | DashboardService.id, DepositAction.id; CardAction.id | Fixed supported IDs; favorites choose among them | Server may select known IDs. Add DTO parsing/registry resolution; unknown IDs must not reach firstWhere |
| Title | DashboardService.label/catalogLabel, DepositAction.label, CardsScreen._label -> ARB getters | Locale-dependent, not arbitrary server copy | Add localized text map and optional known localization key; server text wins only with defined fallback |
| Description/supporting text | Reso banner and wallet ARBs; service item has no description field | Localized constants | Extend feature presentation model and an approved existing-component slot/variant before showing description |
| Icon | Enum asset switches + AppAssets local files | Selection of fixed/editing/saved variants is dynamic; source is local | Server iconKey resolver is easiest; URLs require renderer, cache, fallback and geometry contract |
| Item order | DashboardService.fixed/recommended/group arrays; DepositAction lists | Favorites retain caller/user ordering | Sort validated server rank with stable ID tie-break; permit groups and ordered feature ID arrays |
| Category/group | DashboardCategory.services; deposit groups in screen | Filtered by query/category and deposit flag | Server can assign supported category keys/groups; unknown group types require fallback or omission |
| Visible | Fixed enum inclusion; search/category filtering; hasChequeOperations; nonempty lists | Local filters and deposit data only | Map explicit visibility/capabilities to view model; filter before building widgets |
| Enabled | AppServiceGridItem.enabled defaults true; sheet excludes already-selected favorites | Sheet duplicates disabled; deposit actions all enabled | Add per-feature enabled + disabled reason; preserve disabled callback/semantics policy |
| Route/action | Known enum ID passed to callbacks; local Navigator only for known screens | Host callbacks are injected | Server can name an allowlisted action target; it cannot create navigation code or execute arbitrary route strings |
| Action parameters | CardActionRequest.selected card; DepositActionRequest.selected deposit | Yes, current selection supplied | Merge whitelisted server params with trusted selected entity context; avoid trusting arbitrary IDs |
| Badge | No per-service badge in DashboardService/DepositAction/AppServiceGridItem; deposit type chip is separate | No feature badge support | Server may propose badge text/tone/count; add typed presentation field and approved visual support; it is not already rendered |
| Permissions | No role/permission model in service enums | No | DTO capability hints can filter UI; actual permission checks remain server-side |
| Platform eligibility | No per-feature platform metadata | No | Map platform lists and bank restriction policy to supported features; server is authoritative |
| Loading/error | No async feature load state | No | Add Cubit states, retry, empty, stale/cache policy; current empty deposits is not a loading/error state |
| Favorites | DashboardState.favorites/draft; initialFavorites and callback | Yes, locally and via caller | Server can supply saved IDs and accept confirmed/reset changes; define conflict/order/max-length policy |
| Favorite limit | DashboardCubit.maxFavorites = 8 | Fixed | Server can advertise limit, but app must constrain supported layouts and behavior; not currently configurable |
| Tooltip/accessibility | Local semantics from localized label and helper controls | Localized/user data | Accept optional localized accessibility text; retain safe local labels; do not remove accessibility semantics |
| Style/size/layout | App tokens, shared widget defaults, fixed 64px tiles and 72px item widths | Some supported component parameters | Supported semantic template/tone keys only; arbitrary CSS/colors/spacing cannot fully replace the design system |
| Search text | Sheet searches normalized local catalogLabel | User query dynamic | Build searchable local view models from resolved remote labels/keywords; server search needs debounce, cancellation and async states |

The shared AppServiceGridItem fields are exactly `id`, `label`, `icon` (a Widget), `iconSize`, `onTap` and `enabled`. They are UI parameters, not a transport schema: Widgets and callbacks cannot be deserialized from a response. A mapper must construct them from validated data.

### 10.2 Exact icon sources and mappings

All feature artwork is local under the flat `assets/images/` folder, registered by `AppAssets` in `lib/shared/assets/app_assets.dart`, and bundled by `pubspec.yaml`'s `assets/images/` entry. Feature icons are SVGs rendered by flutter_svg, not an icon font or a Material icon catalog. The application uses the package's IRANYekan font for text only.

The dashboard mapping is in `lib/features/dashboard/presentation/shared/dashboard_services.dart`:
- `catalogAsset`: full catalog and fallback tiles.
- `fixedAsset`: fixed service block.
- `optionAsset`: compact/search sheet rows.
- `tileAsset(editing:, full:)`: precomposed favorite artwork when available. The current `full` argument does not alter its switch result.
- `DashboardCategory.asset/activeAsset`: category icons.

`DashboardServiceTile` in `presentation/shared/widgets/dashboard_service_tile.dart` chooses precomposed AppServiceArtworkTile or a local wave + catalog icon. Cheque issuance has a specific `AppAssets.dashboardFavoriteChequeIcon` composition. The fixed assistant uses shared `AppAssistantIcon`, composed from `dashboardAssistantSpark` and `dashboardAssistantStar`; the inventory table's fallback star path is not the whole fixed assistant visual.

Favorite artwork mappings:
| Service | Saved file | Editing file |
| --- | --- | --- |
| card-deposit | `assets/images/dashboard_favorite_card_deposit.svg` | `assets/images/dashboard_favorite_card_deposit_edit.svg` |
| loan-consolidate | `assets/images/dashboard_favorite_consolidation.svg` | `assets/images/dashboard_favorite_consolidation_edit.svg` |
| card-issue | `assets/images/dashboard_favorite_issue.svg` | `assets/images/dashboard_favorite_issue_edit.svg` |
| deposit-proxy | `assets/images/dashboard_favorite_proxy.svg` | `assets/images/dashboard_favorite_proxy_edit.svg` |
| modern-mobile | `assets/images/dashboard_favorite_mobile.svg` | `assets/images/dashboard_favorite_mobile_edit.svg` |
| modern-internet | Fallback wave + catalog icon | `assets/images/dashboard_favorite_internet_edit.svg` |
| loan-deposit | Fallback wave + catalog icon | `assets/images/dashboard_favorite_loan_deposit_edit.svg` |
| Other services | Fallback wave + catalog icon | Same fallback, inside editor wrapper |

Fallback wave: `assets/images/dashboard_tile_wave.svg`. Decorative/banner images: `dashboard_reso.png`, `dashboard_texture.png`, local glows and prompt arrow via AppAssets in DashboardResoBanner. Header pattern and header-action aliases are DashboardAssets in `shared/dashboard_assets.dart`. These are app shell artwork, not backend feature-item icons.

The complete compile-time service inventory follows; the table resolves the actual switch fallbacks, including generic “more” artwork. It lists all 46 enum values; the nine-category catalog contains 45 entries because assistant is outside those category lists.

| Enum / action ID | Persian label key | Fixed icon file | Catalog icon file | Sheet icon file |
| --- | --- | --- | --- | --- |
| `assistant` / `assistant` | `dashboardAssistant` | `assets/images/dashboard_assistant_star.svg` | `assets/images/dashboard_assistant_star.svg` | `assets/images/dashboard_option_more.svg` |
| `statement` / `deposit-statement` | `balanceAverageStatement` | `assets/images/dashboard_fixed_statement.svg` | `assets/images/dashboard_catalog_statement.svg` | `assets/images/dashboard_option_more.svg` |
| `certificate` / `deposit-certificate` | `financialCertificate` | `assets/images/dashboard_fixed_certificate.svg` | `assets/images/dashboard_catalog_certificate.svg` | `assets/images/dashboard_option_more.svg` |
| `representative` / `deposit-representative` | `introduceRepresentative` | `assets/images/dashboard_fixed_representative.svg` | `assets/images/dashboard_catalog_representative.svg` | `assets/images/dashboard_option_more.svg` |
| `sms` / `deposit-sms` | `smsSettings` | `assets/images/dashboard_fixed_sms.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `issue` / `card-issue` | `issueResalatCard` | `assets/images/dashboard_catalog_issue.svg` | `assets/images/dashboard_catalog_issue.svg` | `assets/images/dashboard_option_issue.svg` |
| `password` / `card-password` | `cardPasswordIssue` | `assets/images/dashboard_fixed_password.svg` | `assets/images/dashboard_catalog_password.svg` | `assets/images/dashboard_option_password.svg` |
| `cardDeposit` / `card-deposit` | `changeCardDeposit` | `assets/images/dashboard_catalog_card_deposit.svg` | `assets/images/dashboard_catalog_card_deposit.svg` | `assets/images/dashboard_option_card_deposit.svg` |
| `block` / `card-block` | `blockCard` | `assets/images/dashboard_fixed_block.svg` | `assets/images/dashboard_catalog_block.svg` | `assets/images/dashboard_option_block.svg` |
| `estimate` / `loan-estimate` | `loanEstimate` | `assets/images/dashboard_fixed_estimate.svg` | `assets/images/dashboard_catalog_estimate.svg` | `assets/images/dashboard_option_more.svg` |
| `introduce` / `loan-introduce` | `introduceLoan` | `assets/images/dashboard_catalog_introduce.svg` | `assets/images/dashboard_catalog_introduce.svg` | `assets/images/dashboard_option_more.svg` |
| `consolidation` / `loan-consolidate` | `consolidateDepositCredit` | `assets/images/dashboard_catalog_consolidation.svg` | `assets/images/dashboard_catalog_consolidation.svg` | `assets/images/dashboard_option_more.svg` |
| `loanDeposit` / `loan-deposit` | `changeInstallmentDeposit` | `assets/images/dashboard_catalog_loan_deposit.svg` | `assets/images/dashboard_catalog_loan_deposit.svg` | `assets/images/dashboard_option_more.svg` |
| `phoneBank` / `modern-phone` | `dashboardPhoneBank` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `mobileBank` / `modern-mobile` | `mobileBankSettings` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `internetBank` / `modern-internet` | `internetBankSettings` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `cardsList` / `card-list` | `dashboardCardsList` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `virtualCard` / `card-virtual` | `dashboardVirtualCard` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `unblockCard` / `card-unblock` | `dashboardUnblockCard` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `expiredGift` / `card-expired-gift` | `dashboardExpiredGift` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `issueCheque` / `cheque-issue` | `issueChequeBook` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `clearCheque` / `cheque-clear` | `dashboardClearCheque` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `cancelCheque` / `cheque-cancel` | `dashboardCancelCheque` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `localTransfer` / `transfer-local` | `dashboardLocalTransfer` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `myLoans` / `loan-list` | `dashboardMyLoans` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `loanReport` / `loan-report` | `dashboardLoanReport` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `correctInstallments` / `loan-correct-installments` | `dashboardCorrectInstallments` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `deferLoan` / `loan-defer` | `dashboardDeferLoan` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `depositsList` / `deposit-list` | `dashboardDepositsList` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `openCurrent` / `deposit-open-current` | `dashboardOpenCurrent` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `closeExtras` / `deposit-close-extras` | `dashboardCloseExtras` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `representationSettings` / `deposit-representation-settings` | `dashboardRepresentationSettings` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `proxy` / `deposit-proxy` | `proxyDeposit` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `unblockDeposit` / `deposit-unblock` | `dashboardUnblockDeposit` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `blockDeposit` / `deposit-block` | `dashboardBlockDeposit` | `assets/images/dashboard_catalog_representative.svg` | `assets/images/dashboard_catalog_representative.svg` | `assets/images/dashboard_option_more.svg` |
| `walletInfo` / `wallet-info` | `dashboardWalletInfo` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `walletCharge` / `wallet-charge` | `dashboardWalletCharge` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `walletWithdraw` / `wallet-withdraw` | `dashboardWalletWithdraw` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `walletTransfer` / `wallet-transfer` | `dashboardWalletTransfer` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `walletHistory` / `wallet-history` | `dashboardWalletHistory` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `walletDeposit` / `wallet-deposit` | `dashboardWalletDeposit` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `changeIdentity` / `identity-change` | `dashboardChangeIdentity` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `occupation` / `identity-occupation` | `dashboardOccupation` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `addresses` / `identity-addresses` | `dashboardAddresses` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `changePhone` / `identity-phone` | `dashboardChangePhone` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_catalog_more.svg` | `assets/images/dashboard_option_more.svg` |
| `requests` / `requests-list` | `dashboardRequests` | `assets/images/dashboard_catalog_requests.svg` | `assets/images/dashboard_catalog_requests.svg` | `assets/images/dashboard_option_more.svg` |

Deposit icon mapping is in `lib/features/deposits/presentation/shared/deposit_actions.dart` (`DepositAction.asset`), not DashboardService.catalogAsset. New deposit files are original Figma SVGs. The cheque issuance asset was exported from the actual `cheque_request` instance because the generated reference incorrectly pointed to Chat. The SMS asset was also exported from its original Chat instance after visual verification found an identity icon in the generated alias.

| Action / integration ID | ARB title key | Local icon file | Group |
| --- | --- | --- | --- |
| `statement` / `deposit-statement` | `balanceAverageStatement` | `assets/images/deposits_statement.svg` | Deposit operations |
| `certificate` / `deposit-certificate` | `financialCertificate` | `assets/images/deposits_certificate.svg` | Deposit operations |
| `sms` / `deposit-sms` | `smsSettings` | `assets/images/deposits_sms.svg` | Deposit operations |
| `block` / `deposit-block` | `dashboardBlockDeposit` | `assets/images/deposits_block.svg` | Deposit operations |
| `representative` / `deposit-representation-settings` | `depositsRepresentative` | `assets/images/deposits_representative.svg` | Deposit operations |
| `virtualCard` / `card-virtual` | `dashboardVirtualCard` | `assets/images/deposits_virtual.svg` | Deposit operations |
| `linkedCards` / `deposit-linked-cards` | `depositsLinkedCards` | `assets/images/deposits_cards.svg` | Deposit operations |
| `linkedLoans` / `deposit-linked-loans` | `depositsLinkedLoans` | `assets/images/deposits_loans.svg` | Deposit operations |
| `issueCheque` / `cheque-issue` | `issueChequeBook` | `assets/images/deposits_cheque_issue.svg` | Cheque operations |
| `cancelCheque` / `cheque-cancel` | `dashboardCancelCheque` | `assets/images/deposits_cheque_cancel.svg` | Cheque operations |
| `clearCheque` / `cheque-clear` | `dashboardClearCheque` | `assets/images/deposits_cheque_clear.svg` | Cheque operations |
| `issueCard` / `card-issue` | `issueResalatCard` | `assets/images/deposits_quick_issue.svg` | Quick access |
| `localTransfer` / `transfer-local` | `depositsLocalTransfer` | `assets/images/deposits_quick_transfer.svg` | Quick access |
| `estimateLoan` / `loan-estimate` | `loanEstimate` | `assets/images/deposits_quick_estimate.svg` | Quick access |
| `introduceLoan` / `loan-introduce` | `introduceLoan` | `assets/images/deposits_quick_introduce.svg` | Quick access |
| `proxy` / `deposit-proxy` | `proxyDeposit` | `assets/images/deposits_quick_proxy.svg` | Quick access |
| `mobileBank` / `modern-mobile` | `depositsMobileBank` | `assets/images/deposits_quick_mobile.svg` | Quick access |
| `internetBank` / `modern-internet` | `internetBank` | `assets/images/deposits_quick_internet.svg` | Quick access |
| `phoneBank` / `modern-phone` | `dashboardPhoneBank` | `assets/images/deposits_quick_phone.svg` | Quick access |

| Category | Current icon file |
| --- | --- |
| `modern` | `assets/images/dashboard_catalog_category_modern.svg` |
| `cards` | `assets/images/dashboard_catalog_category_card.svg` |
| `cheque` | `assets/images/dashboard_catalog_category_cheque.svg` |
| `transfers` | `assets/images/dashboard_catalog_category_transfer.svg` |
| `loans` | `assets/images/dashboard_catalog_category_loan.svg` |
| `deposits` | `assets/images/dashboard_catalog_category_deposit.svg` |
| `wallet` | `assets/images/dashboard_catalog_category_wallet.svg` |
| `identity` | `assets/images/dashboard_catalog_category_identity.svg` |
| `requests` | `assets/images/dashboard_catalog_category_requests.svg` |

The Cards category active file is `assets/images/dashboard_category_card_active.svg`. Search headings use `assets/images/dashboard_search_card.svg`, `dashboard_search_wallet.svg` and `dashboard_search_identity.svg` for those three categories; all other headings use the category mapping above. Category dividers are resolved by DashboardCategoryHeading in the same all-services source.

Cards use `CardsScreen._asset(CardAction)` in `lib/features/cards/presentation/cards_screen.dart`, resolving `AppAssets.cardsAction*` and `cardsQuick*` in the same registry. Notifications use `notification_*.svg` and `notification_security.png`. Shared navigation owns dashboard_nav_*.svg and cards_nav_*.svg. None of these callsites is currently a network renderer.

### 10.3 Could icons come from the server?

**Known icon keys:** Yes, with a modest mapping layer. Return a stable key such as `deposit.statement`; map it to AppAssets using an allowlisted registry. This removes server dependence on local file names and permits controlled fallback. It does not add a new glyph when the app has not shipped it.

**Remote URLs:** Possible, but not supported by current service widgets without adapter changes. Add a typed icon descriptor (`key`, `url`, `format`, `version`, optional digest); remote loader; timeout/error fallback; bounded memory/disk cache; and a renderer that chooses SVG versus PNG/WebP. Prefer HTTPS on approved asset hosts. Validate declared and actual content types; do not execute arbitrary scripts. SVG gets vector rendering, raster gets ImageProvider/Image with fit behavior. Unsupported formats should show a local fallback.

Preserve the design slot: 32×32 for ordinary operations, 64×64 for quick artwork, 20px for headers. Precomposed quick SVGs include the wave and export bounds (70×70.5 with shadow margin), so a bare icon URL cannot automatically substitute for that artwork. Either specify a supported bare-icon template and compose the tile, or supply complete approved artwork. Do not modify AppServiceArtworkTile silently; it currently draws the local 64px tile/shadow and places the original export at (-3,-2).

Required code changes: new catalog DTO/model/mapper, icon resolver, async image component, and conversion of enum-centric iteration/filtering into resolved presentation records. Existing `AppServiceGridItem.icon` can accept a renderer Widget, but AppServiceArtworkTile.asset and DashboardService enum switches remain local-only.

Caching should key by icon key + version/content hash; use bounded storage, invalidation, offline fallback and deterministic tests. Feature metadata freshness and icon freshness are separate policies. Failed icon loading must not remove known authorized actions or blank the whole dashboard.

### 10.4 Proposed server response contract (not implemented)

This is a proposal for review against the bank's OpenAPI specification, not an existing endpoint or parser.

```json
{
  "schemaVersion": 1,
  "catalogVersion": "2026-10-09.1",
  "expiresAt": "2026-10-10T00:00:00Z",
  "favoriteLimit": 8,
  "favoriteIds": ["card-issue", "deposit-statement"],
  "groups": [
    {
      "id": "deposits",
      "type": "service_grid",
      "title": {"fa": "عملیات سپرده", "en": "Deposit operations", "ar": "عمليات الودائع"},
      "iconKey": "category.deposits",
      "order": 10,
      "visible": true,
      "featureIds": ["deposit-statement", "cheque-issue"]
    }
  ],
  "features": [
    {
      "id": "deposit-statement",
      "type": "service",
      "title": {"fa": "صورت‌حساب / معدل موجودی", "en": "Statement / average balance"},
      "localizationKey": "balanceAverageStatement",
      "description": {"fa": "مشاهده گزارش سپرده"},
      "icon": {
        "key": "deposit.statement",
        "url": "https://assets.bank.example/icons/deposit-statement.svg",
        "format": "svg",
        "version": "2",
        "sha256": null,
        "template": "operation_icon"
      },
      "order": 10,
      "visible": true,
      "enabled": true,
      "disabledReason": null,
      "badge": {"text": {"fa": "جدید", "en": "New"}, "tone": "info", "count": null},
      "permissions": ["deposit.statement.read"],
      "platforms": ["android", "ios", "web"],
      "action": {
        "kind": "service",
        "target": "deposit-statement",
        "requiresSelectedDeposit": true,
        "parameters": {"reportKind": "statement"}
      },
      "accessibilityLabel": {"fa": "مشاهده صورت‌حساب سپرده"},
      "searchKeywords": {"fa": ["گردش", "معدل"]},
      "minAppVersion": "1.0.0",
      "favoriteEligible": true
    },
    {
      "id": "cheque-issue",
      "type": "service",
      "title": {"fa": "صدور دسته چک"},
      "icon": {"key": "cheque.issue", "format": "svg", "template": "operation_icon"},
      "order": 20,
      "visible": true,
      "enabled": true,
      "requiredDepositCapability": "chequeOperations",
      "action": {"kind": "service", "target": "cheque-issue", "requiresSelectedDeposit": true}
    }
  ],
  "deposits": [
    {
      "id": "dep-1",
      "type": "personal_current",
      "typeLabel": {"fa": "جاری حقیقی", "en": "Personal current"},
      "number": "10.12003456.1",
      "iban": "IR550700010001112003761001",
      "openedAt": "2024-09-14",
      "capabilities": {"chequeOperations": true},
      "availableFeatureIds": ["deposit-statement", "cheque-issue"],
      "disabledFeatureIds": []
    }
  ]
}
```

The example host is illustrative. `sha256` must contain a real digest if used, not an invented placeholder. Permission strings are illustrative bank-owned contract keys.

Parsing policy:
1. Validate schema version, supported feature type, group type, icon template and action kind.
2. Resolve title by current locale, known localization key, then a defined fallback; never use a getter name for reflection.
3. Resolve target through an app-owned ServiceRegistry/allowlist; a server ID cannot instantiate Dart classes.
4. Drop unknown or unsupported action targets from actionable lists; optionally show a non-actionable “update required” item if product design specifies it. Do not silently open a different service.
5. Ignore unknown optional JSON fields for forward compatibility. Preserve/log unsupported IDs without personal data for diagnostics.
6. Filter unsupported platform/version/permission hints and per-deposit capabilities; deduplicate IDs; clamp sizes/counts; stable-sort.
7. Map raw deposit data separately; use openedAt in the domain and format a Jalali openingDate in presentation.
8. Filter favorites against the resolved supported catalog before building any firstWhere lookup.
9. Server eligibility remains a hint until request authorization. Revalidate on action execution.

`description`, badge, permissions, remote icon, availableFeatureIds and feature-level enabled fields in this proposal are not currently represented/rendered by DepositAction. Implementing this response requires real model and mapper work, not merely swapping a list.

### 10.5 BankDeposit fields and transport readiness

| Field | Current source/use | Server path and conversion |
| --- | --- | --- |
| id | Caller/static fixture; stable selection across reorder and callback context | Stable opaque deposit ID; must be unique within list |
| typeLabel | Caller display string; default Persian “جاری حقیقی”; shown in existing chip | Resolve localized typeLabel or known deposit type to local copy |
| number | Caller/static original string; displayed and copied verbatim | Preserve source string; no numeric parsing or lost leading zeros |
| iban | Caller/static original string; displayed and copied verbatim | Preserve raw IBAN separately from optional display formatting |
| openingDate | Caller formatted display string | DTO Gregorian openedAt -> domain date -> Jalali presentation label |
| hasChequeOperations | Caller boolean; controls cheque group only | Map bank capability/available-action data, never derive from deposit count |

### 10.6 What remains in the app

Navigation targets, authentication guards, service use cases, entity validation, final confirmation, transaction/request idempotency, approved visual templates, RTL rules, safe icon rendering and fallback behavior require shipped app code. Server metadata cannot introduce a new executable feature flow.

Titles, descriptions (once supported), known icon choices or approved remote artwork, order, category membership, visibility, enabled hints, badges (once supported), saved favorites, account data and action eligibility can be server-driven through a validated contract. They still need client rendering and mapping. Adding a feature of a known supported action/type can be metadata-only; adding a new flow, layout type or capability semantics needs an app release.

## 11. Error Handling Pattern (Result & Failure)

There is no API Result/Failure hierarchy in these feature implementations. The empty list is a deliberate UI state; it must not stand in for failed authentication, network loading or a repository error.

A future Cubit should distinguish loading, ready, empty, stale/offline and failure. Pure mappers should report invalid contract data independently from transport errors. Action rejection, missing permissions and selected-deposit removal should be explicit domain/presentation events. Do not catch every exception and silently replace data with Figma examples.

## 12. State Management with Cubit

### 12.1 Favorites state

DashboardState contains immutable favorites and nullable draft. visibleFavorites reads draft while editing and favorites otherwise. DashboardCubit deduplicates initial IDs and takes at most eight. DashboardScreen filters initial IDs against DashboardService.values before constructing the Cubit.

```text
Saved/empty -> edit -> Draft (existing favorites, or suggested IDs)
Draft -> add/remove (unique, max 8) -> Draft
Draft -> confirm -> Saved + onFavoritesChanged
Draft -> cancel/system back -> previous Saved
Reset request -> confirmation sheet
  cancel -> unchanged draft/saved
  confirm -> empty Saved + onFavoritesChanged
```

The recommendation list is card-issue, loan-consolidate, card-deposit. There is no reorder gesture or backend save result. The host can persist confirmed/reset IDs through onFavoritesChanged.

### 12.2 Shell and deposit state

```text
Auth prototype completion -> DashboardScreen
  Dashboard tab <-> Cards tab <-> Deposits tab (IndexedStack)
  Loans tab -> filtered service sheet
  Bell -> NotificationsScreen -> NotificationDetailScreen

Deposits input list -> first selected index
  swipe / indicator -> new index -> callback -> rebuild action groups
  hasChequeOperations=true -> cheque section visible
  false -> section absent
  action tap -> DepositActionRequest(action, selected deposit) -> host
  tab switch -> state retained
  system back from Cards/Deposits -> Dashboard
  list reorder -> retain selected ID at new index
  selected item removed -> first remaining item
  empty list -> no selected lookup, no card/action groups
```

PageController is replaced when index/list length or viewport fraction changes and disposed with the screen. keepPage is false to avoid restoring a stale page offset after data replacement. The shell disposes DashboardCubit and prompt FocusNode. There is no separate deposit Cubit/state class: _DepositsScreenState is the sole local state owner for this UI-only phase.

### 12.3 Data flow

```text
Today:
  ARBs + enums + AppAssets -> localized widget inputs
  caller BankDeposit list -> selected index -> AppDepositCard
                              -> hasChequeOperations -> groups
  tap -> request callback -> caller integration (no bank API)
  initialFavorites -> DashboardCubit -> favorite widgets
  confirm/reset -> onFavoritesChanged -> caller storage (if supplied)

Future:
  API -> DTO -> repository mapper -> domain data -> use case/Cubit
      -> presentation model + icon resolver -> current shared widget composition
```

## 13. Design System Package (`avp_ui`)

### 13.1 Ownership and reuse

| Owner | Used components / tokens | Location |
| --- | --- | --- |
| avp_ui | AppTheme, context.colors, AppTypography, AppSpacing, AppRadius, AppShadows, AppDashboardColors, AppLoginColors | External `avp_ui/lib/tokens/`, `theme/`, `extensions/`, exported by avp_ui.dart |
| avp_ui | AppButton, AppSearchField; shared components also compose package primitives | Public `package:avp_ui/avp_ui.dart` |
| App shared | AppDepositCard | `lib/shared/widgets/app_deposit_card.dart` |
| App shared | AppPrimaryNavigation / AppPrimaryTab | `lib/shared/widgets/app_primary_navigation.dart` |
| App shared | AppTopBar | `lib/shared/widgets/app_top_bar.dart` |
| App shared | AppServiceGridCard, AppServiceGridItem, AppServiceGridItemView | `lib/shared/widgets/app_service_grid_card.dart` |
| App shared | AppServiceArtworkTile | `lib/shared/widgets/app_service_artwork_tile.dart` |
| App shared | AppAssistantButton, AppAssistantIcon | `lib/shared/widgets/app_assistant_button.dart` |
| App shared | AppWalletCard, AppBottomSheetHeader, AppResalatCard | Corresponding files in `lib/shared/widgets/` |
| Feature local | DashboardBankServices, DashboardServiceTile, DashboardResoBanner, catalog/sheet headings | `lib/features/dashboard/presentation/shared/widgets/` |
| Feature local | DepositsScreen group/carousel composition, DepositAction mappings | `lib/features/deposits/presentation/` |

No duplicate deposit card or navigation component was created. Narrow screens wrap the existing card in a FittedBox with its native aspect ratio. That scales the existing component as a whole; it does not change its gradient, shadow, fonts or fixed native dimensions.

### 13.2 Known issue: AppDepositCard gradient

Current source: `lib/shared/widgets/app_deposit_card.dart`.

| Property | Current unmodified component | New Figma requirement |
| --- | --- | --- |
| Gradient geometry | LinearGradient begin Alignment.bottomRight, end Alignment.topLeft; no explicit authored angle | Single CSS/Figma reference angle -58.86308919844143°; multi -58.92376501651299° |
| Light color | #7D55D6 in both variants | Single #7D55D6; multi #7D54D6 |
| Dark color | AppPalette.purple800 (#4A1FB8) | #4A1FB8 |
| Stops | Not supplied, therefore Flutter default 0.0 and 1.0 | 0.0077394 and 0.97863 |
| Dimensions | single 335×202, multi 316×191 | Same dimensions |

At the native dimensions, the corner-to-corner vector corresponds approximately to a CSS-direction angle of -58.910650° for single and -58.849960° for multi (computed as -atan(width/height)); these are geometry-derived values, not angles authored in the component. The current gradient direction is bound to the component corners rather than explicit Figma handles/angle/stops. Its effective diagonal depends on card aspect ratio; matching a general diagonal does not preserve the required stop positions or multi light color.

Recommendation: add an explicit visual variant or gradient parameter with the current rendering as the default; introduce a package-owned deposit gradient token for the reviewed design. Do not globally change the default or copy a new card into DepositsScreen.

### 13.3 Known issue: AppDepositCard shadow

The current card uses `AppShadows.md` from `avp_ui/lib/tokens/app_shadows.dart`. Its source values are:

| Layer | Current md | Required Figma / existing bankCard |
| --- | --- | --- |
| First | Color(0x0A0D120F), offset (0,4), blur 8, spread -2 | Color(0x1A0A0D12), offset (0,4), blur 8, spread +2 |
| Second | Color(0x0A0D120A), offset (0,2), blur 4, spread -2 | Color(0x0F0A0D12), offset (0,2), blur 4, spread +2 |

Dart Color integers are ARGB: the current md literals' alpha/channel ordering is materially different from the required literals. This document records the actual code values, not merely the token name “Shadow/md.”

**AppShadows.bankCard already contains the exact two required layers.** It was added for the Cards design and is used by AppResalatCard. It is not used by AppDepositCard today.

Recommendation: allow a reviewed shadow/visual variant in AppDepositCard that uses bankCard, keeping its current default for compatibility. Do not change AppShadows.md globally; that token may affect other shared consumers.

### 13.4 Known issue: AppPrimaryNavigation selected Deposits icon

Source: `lib/shared/widgets/app_primary_navigation.dart`. The deposit branch always resolves `AppAssets.dashboardNavDeposit` -> `assets/images/dashboard_nav_deposit.svg`. There is no active/inactive branch for that tab.

The selected tab already gets the blue AppDashboardColors.navActive surface, white label and DemiBold text, but the bundled deposit icon remains gray. Both new frames require a white money-bill icon in the active deposit tab. This was deliberately preserved.

DashboardScreen, CardsScreen and the new DepositsScreen all use this navigation component. DashboardHeader/cards/deposits use the same AppTopBar; no header correction was introduced. Before this task, AppDepositCard was implemented and tested as a shared component but had no feature-screen callsite; this task adds its DepositsScreen use. Shared financial-card tests cover its existing single/multi variants.

Recommendation: add an optional active deposit icon or reviewed selected-tab icon map to shared navigation, retaining default behavior. Avoid a global color filter on all icons: existing dashboard/card active and inactive assets have their own styling.

### 13.5 Decision and accepted visual limits

These issues remain because the user explicitly instructed “use exactly the current existing components” and requested documentation instead of correction. Existing shared tests and behavior remain the baseline. Exact pixel equality with the supplied frames is therefore not the acceptance criterion for those two components.

The existing grid's row wrapping, max-two-line labels and text metrics are also preserved. Existing deposit card labels are Persian strings inside the shared component; full multilingual card labels require a separate reviewed shared API extension. This task localizes screen/group/action/empty-state copy without editing that component.

## 14. Localization, Persian Support, and Dates

The app installs AppTheme.light and forces RTL in the MaterialApp builder, including future languages. Screens also establish RTL explicitly. ARBs are fa/en/ar and generated through l10n.yaml.

New keys include depositsMyTitle, depositsOperations, depositsChequeOperations, depositsEmpty, depositsRepresentative, depositsLinkedCards, depositsLinkedLoans, depositsLocalTransfer, depositsMobileBank and depositsCopyNumber. Existing ARB keys cover statement, certificate, SMS, blocking, cheque actions, quick access and modern banking.

Action order is expressed from the RTL start: statement/certificate/SMS/block; representative/virtual card/linked cards/linked loans. Quick actions start with card issuance, local transfer, estimate and introduce loan; next proxy/mobile/internet/phone. Numeric strings are passed unchanged; AppDepositCard sets LTR for numeric values and RTL for labels. Copy callbacks return original number/IBAN, not formatted numeric conversions.

BankDeposit.openingDate is currently preformatted display data. Server openedAt should be parsed as a date and converted in presentation, respecting the architecture's Gregorian/UTC domain rule and Jalali UI requirement. The static typeLabel default is Persian; server/caller should supply a localized label for another locale.

Fonts are owned by avp_ui, not duplicated in pubspec. Test previews explicitly load Regular/Medium/DemiBold/Bold from package assets. Existing shared card scaling/label limits remain documented accessibility limitations rather than redesigned components.

## 15. Routing and Guards

DashboardScreen's IndexedStack retains three children: dashboard, cards and deposits. AppPrimaryTab order is dashboard/cards/deposits/loans. The loans selection opens a sheet and never selects index 3, which has no dedicated screen.

Back from Cards or Deposits selects Dashboard. Back while editing dashboard favorites cancels the draft. Bell navigation and all-services pages use Navigator.push. No go_router auth/platform/security guard was added.

Deposit menu uses the supplied onMenuPressed if available; otherwise the shell opens the existing deposits-filtered service sheet. The assistant switches to Dashboard and triggers the assistant service (or focuses the prompt if no service callback is supplied).

Routes are app-owned code. A future server action target must resolve through an allowlist/service registry and pass domain guards. Arbitrary paths/URLs from feature JSON are not implemented here.

## 16. Testing Strategy

### 16.1 Focused verification

`test/deposits_screen_test.dart` checks:
- Native single/multi card variants and unchanged shared-component reuse.
- Deposit operations start at y=341 for the 375px reference viewport with simulated 24px status inset.
- RTL ordering of the operation tiles.
- Cheque visibility for default frames and mixed capability data.
- Indicator selection and swipe selection.
- Selected deposit in action callbacks.
- Original values through copy overrides and platform clipboard fallback.
- Stable selection after reordered data; fallback after selected removal; empty data.
- Retained selection across Cards/Deposits tab switches and system-back navigation.
- Service-ID fallback, menu callback, assistant transition and existing Loans sheet.
- Narrow 320px viewport with 1.4 text scale and reachable quick action.

Existing dashboard/card/notification/widget and asset integrity tests remain regression coverage. AppAssets.all verifies every new registered file is bundled and non-empty; static asset metadata and rendered slots are checked against design context. The original cheque-plus instance export is used, not the incorrect generated Chat alias.

### 16.2 Visual review

[Deposit review gallery](deposits-review/index.html) contains [single](deposits-review/phase1-single.png) and [multiple](deposits-review/phase2-multi.png) renders. They intentionally preserve the gradient/shadow and active-icon differences documented in Section 13. Preview canvas includes simulated safe-area spacing; it does not draw native system status/navigation controls.

Regenerate with PowerShell:

```powershell
$env:UPDATE_DEPOSITS_PREVIEWS = '1'
flutter test test/deposits_screen_test.dart
```

The previews are review artifacts, not screenshot UI assets or new golden baselines.

### 16.3 Results and limits

- `flutter test test/deposits_screen_test.dart`: 9 tests passed; final preview generation passed after the original SMS export was installed.
- `flutter test`: all 94 tests passed, including existing auth, cards, dashboard, notifications, shared widgets and asset integrity tests.
- `flutter analyze`: no Dart errors or new lint findings; one existing `path_not_posix` warning at `pubspec.yaml:37:11` for the absolute Windows avp_ui path. Analyzer exits nonzero for this warning.
- `git diff --check`: passed. Shared widget source diff is empty.
- Final single and multi PNGs inspected; every new SVG is non-empty with expected root dimensions (32×32 operations, 20×20 quick header, 70×70.5 quick artwork, 375×122 pattern).
- flutter_svg emits its existing unsupported `<filter/>` warning for exported artwork. AppServiceArtworkTile already draws the tile shadow in Flutter; that shared behavior was preserved.

No bank API, request execution, release build, emulator/device run or remote icon loading is validated by this UI suite. Large text within the unmodified fixed-size card, unusual long type labels and extreme viewport heights need future accessibility review.

## 17. Development and Code Review Process

The decision gate was completed before coding: both Figma frames were compared to shared AppDepositCard and AppPrimaryNavigation; the differences were disclosed; the user selected reuse without modification.

Changes are feature screen/model/mapping, shell wiring, registered app-owned artwork, ARB/generated localization, tests and documentation. Shared widget source and avp_ui source must remain unchanged in this task.

Review should confirm:
- Action eligibility follows selected-deposit data, not number of cards.
- Dedicated callbacks preserve selected context.
- Unknown catalog IDs cannot be treated as valid navigation.
- No temporary Figma URLs appear in runtime code.
- ARB source and generated output agree.
- Component issues are accurately recorded, not silently corrected.

Existing review docs remain useful design evidence: [dashboard](dashboard-implementation-review.md), [cards](cards-implementation-review.md), [login](login-implementation-review.md) and [shared mapping](shared-component-figma-mapping.md).

## 18. Environments, CI/CD, and Release

Current entry point is lib/main.dart; this feature does not add development/staging/production entry points, secrets, environment configuration or a CI pipeline.

Run flutter gen-l10n after ARB changes, flutter analyze, and flutter test. Preview regeneration is opt-in by environment variable and should not run automatically in release packaging. Known analyzer warning for the absolute Windows avp_ui path is existing setup; it is not a new Dart error.

Production release requires the architecture's API, authentication, platform security and bank approval work; UI completion alone is not release readiness.

## 19. AI Assistant and Agent Layer

DashboardResoBanner owns the prompt text controller. Submitting trims the text and calls onPromptSubmitted only when nonempty. Animated hints never write into user input. Hint typing/erasing is 90ms per grapheme; glow cycles over 12 seconds. Motion stops for reduced motion, disabled TickerMode and background lifecycle.

Shared assistant buttons delegate to the caller. The deposit assistant returns to the dashboard prompt/service path. No AI inference, voice handling, tool execution or conversational banking backend is added.

A future assistant and form flow must use the same bank service contract/registry and authorization rather than interpreting server dashboard metadata as executable instructions.

## 20. Open Items and Dependencies

### 20.1 Open product / bank questions

1. Supply authoritative deposit types and capabilities; decide whether cheque actions differ individually rather than as one group.
2. Define localized deposit type names, Jalali dates and account display/copy rules.
3. Approve catalog response schema, action keys, unknown-ID policy, icon delivery and metadata freshness.
4. Define disabled reasons, badges, permissions and favorite synchronization/conflicts.
5. Define selected-deposit persistence and whether selection callbacks must also fire on data replacement.
6. Confirm scope of local transfer UI: this design contains a tile, while the architecture limits request-based versus payment execution. No execution was added.
7. Supply the dedicated Loans tab design and service flow screens.

### 20.2 Recorded technical debt and risks

| Item | Impact | Recommended follow-up |
| --- | --- | --- |
| Deposit gradient/shadow mismatch | Accepted design difference | Opt-in reviewed variant/parameters; use existing bankCard shadow |
| Active deposit icon gray | Accepted navigation difference | Optional active asset mapping without replacing defaults |
| Persian labels inside shared card | Partial multilingual card support | Reviewed label/semantic parameters in shared component |
| Fixed shared card dimensions/text | Constrained large-text/long-string support | Shared accessibility review with focused tests |
| Enum-centric service catalog | New unknown actions cannot be rendered/executed automatically | Typed server catalog + allowlisted registry + fallback policy |
| Figma example data | UI can appear complete without live banking state | Repository/Cubit loading/error/empty states |
| Fallback string service callback | Loses selected-deposit context | Require DepositActionRequest handler for real operations |
| Shell imports feature screens directly | Differs from proposed strict module boundaries | Move composition/routing to shell/core when architecture is implemented |
| No persistent favorites/notifications/selection | State lasts only for widget lifetime | Caller/repository storage with privacy policy |
| Machine-specific avp_ui path | Portability warning | Separate dependency setup cleanup, outside this task |

No component issue is treated as resolved by this feature.

## 21. Change Log

| Version | Date | Changes |
| --- | --- | --- |
| 1.0.0 | 2026-10-09 | Register Dashboard current architecture; add Deposits phases 1–2 and selection-driven cheque UI; record shared component exceptions, exact icon sources, server-readiness matrix, proposed contract, state/data flows and verification |
