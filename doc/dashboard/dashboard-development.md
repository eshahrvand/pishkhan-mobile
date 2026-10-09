# Dashboard Development Document — Smart Virtual Counter

**Project:** Pishkhan AI / Resalat Smart Virtual Counter mobile application

**Framework:** Flutter / Dart

**Document version:** 2.0.0

**Date:** 2026-10-09

**Status:** Repository-backed mock UI and Cubit migration implemented; live bank services are not connected

**Scope:** Dashboard shell, dashboard page, Cards tab integration, Deposits phases 1–2, Loans phases 1–2, notification navigation

**Architecture reference:** [architecture-smart-virtual-counter-v2-en.md](../architecture-smart-virtual-counter-v2-en.md)

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

Dashboard owns its shell, Home content and Cards/Deposits/Loans tabs. A tab is a dashboard summary, not a standalone banking feature page. Dashboard-specific entities, actions, fixtures, repositories and Cubits now live under `lib/features/dashboard/`; future full Card, Deposit and Loan pages can use their dedicated feature folders without inheriting tab layout or selection state.

The dependency direction is presentation -> use case -> domain repository contract; the mock data layer implements those contracts. UI and Cubits consume the same interface that a future live repository will implement. No service request, authentication or banking transaction is executed by this prototype.

The earlier component decision explicitly required existing shared components unchanged. The subsequent progress-fix request authorized a focused correction to the existing progress primitive and its AppLoanCard callsite. This restructuring preserves those decisions. Section 13 records exact card/navigation differences and the expanded component-by-component Figma audit, including unresolved states rather than claiming complete pixel equality.

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
| Cards tab | Single/multiple card layouts, selected card, per-card visibility, copy, selected-card action callbacks | `lib/features/dashboard/presentation/tabs/cards/cards_tab.dart`; `27902:82533`, `27902:82561` |
| Deposits phase 1 | Single 335×202 deposit card, deposit operations, cheque operations when eligible, quick access | `lib/features/dashboard/presentation/tabs/deposits/deposits_tab.dart`; [27902:82476](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82476) |
| Deposits phase 2 | Multiple 316×191 deposit cards, snapping RTL carousel, neighboring previews, indicators, selected-deposit actions | Same screen; [27902:82503](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82503) |
| Deposits empty | Localized empty message and usable shell controls | `DepositsTab(repository: MockDashboardDepositsRepository(deposits: []))` |
| Loans phase 1 | Single 335×236 loan card, four operations and two quick actions | `lib/features/dashboard/presentation/tabs/loans/loans_tab.dart`; [27902:82623](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82623) |
| Loans phase 2 | Multiple 316×236 loan cards, snapping RTL carousel, neighboring previews and selected-loan callbacks | Same screen; [27902:82592](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82592) |
| Loans empty | Localized empty message; controls remain usable; no selected lookup/action groups | `LoansTab(repository: MockDashboardLoansRepository(loans: []))` |
| Notifications | Bell pushes list; opening marks read; Read all; detail; read state retained during shell lifetime | `lib/features/notifications/presentation/` |

Single versus multiple deposit layout is determined by list length. Cheque visibility is determined by `BankDeposit.hasChequeOperations`, independently of length. One deposit can have no cheque section; an eligible deposit in a multi-deposit list can have one. The default single example is eligible; all three default multi examples are ineligible, matching the supplied states.

The single frame has eight deposit operations, three cheque operations and eight quick actions. The multiple frame has eight deposit operations and eight quick actions. This implementation does not equate “multiple deposits” with “cheques unavailable.”

### 2.2 Platform scope

The architectural product targets Android, iOS and mobile Safari as the iOS fallback. This work is Flutter UI and adds no platform package. Clipboard copying uses `flutter/services.dart`. Native status/navigation bars and keyboards are excluded from review PNGs. No native device build or web deployment is claimed by these widget tests.

## 3. Technology Stack

| Concern | Installed/current implementation | Future integration |
| --- | --- | --- |
| Widgets | Flutter Material, public avp_ui primitives and existing shared widgets | Dedicated banking pages and reviewed variants |
| State | flutter_bloc; DashboardCubit, DashboardNavigationCubit, CardsCubit, DepositsCubit, LoansCubit | Same Cubits with service-backed repositories |
| Equality | Equatable 2.0.7; immutable entity/state collections | Keep immutable state contracts |
| Domain | Dashboard summary entities, repository interfaces and loading use cases | Validated service DTO mapping |
| Data | Async mock repository implementations and centralized mock fixtures | Remote datasources, transport DTOs, mappers and live repositories |
| Localization/artwork | fa/en/ar ARBs, local AppAssets, flutter_svg and PNGs | Optional remote icon resolver/cache |
| Routing | IndexedStack, Navigator; core notification navigation adapter | Service registry and authenticated guards |
| Errors | Typed Result/Failure with coded failures | Transport/auth/contract failures mapped by data layer |
| Testing | flutter_test unit/widget/geometry tests | Service contract and device tests |

`pubspec.yaml` uses `avp_ui: path: ../avp_ui`. This resolves the existing sibling package while removing the absolute Windows path and its analyzer portability warning. Application widgets import its public barrel, `package:avp_ui/avp_ui.dart`.

## 4. Development Environment and Versions

The project Dart constraint is `^3.13.3` in `pubspec.yaml`. The architecture document's Flutter/FVM selection is a policy proposal, not a completed pin in this repository. Do not infer an exact Flutter version from this feature document.

Configuration files are `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml` and `l10n.yaml`. Current analysis uses `flutter_lints`; the architectural custom import lints are not installed. Generated localization output is under `lib/l10n/generated/`.

The local SDK requires access to its cache outside the repository when generating localization or running tests. That execution requirement does not authorize changing SDK versions or shared-package source.

## 5. Third-Party Dependency Governance

Equatable `^2.0.7` is added to implement the architecture's value-equality state rule without generated state code; the selected version is recorded in pubspec.lock. Existing flutter_bloc is retained. No HTTP, DI, image-caching or routing dependency is introduced.

A future remote icon implementation still needs an approved caching strategy. Existing SVG and artwork asset callsites do not accept arbitrary URLs. Introducing repository contracts does not by itself implement remote images, API decoding or durable storage.

## 6. Project Structure and Modularization

### 6.1 File and folder map

All paths are repository-relative; `avp_ui` sources are in the sibling package.

```text
lib/features/dashboard/
  dashboard.dart                           public feature exports
  domain/
    entities/
      dashboard_item.dart                  immutable/equality item contract
      bank_card.dart                       BankCard, BankCardKind
      bank_deposit.dart                    BankDeposit, cheque capability
      bank_loan.dart                       BankLoan, numeric count/progress getters
      dashboard_home_data.dart             wallet + saved/fixed/suggested IDs
    repositories/dashboard_repositories.dart
                                           4 contracts + DashboardRepositories bundle
    usecases/
      load_dashboard_items.dart            snapshot, ID validation, failure boundary
      load_dashboard_home.dart             Home result boundary
  data/mock/
    dashboard_mock_data.dart               single/multiple fixtures (no entity statics)
    mock_dashboard_repositories.dart       4 async mock implementations
  presentation/
    dashboard_screen.dart                  composition root and IndexedStack
    cubit/
      dashboard_cubit.dart                 Home load + favorite transactions
      dashboard_state.dart                 Home lifecycle states
      dashboard_navigation_cubit.dart      primary-tab selection state/Cubit
      dashboard_tab_cubit.dart             common async item load/selection behavior
      dashboard_tab_state.dart             common item lifecycle and layout states
    tabs/
      cards/
        cards_tab.dart                     CardsTab; card/carousel composition
        card_actions.dart                  CardAction, CardActionRequest
        cubit/cards_cubit.dart              CardsCubit + visibility operations
        cubit/cards_state.dart              CardsState alias, CardsLoaded visibility map
      deposits/
        deposits_tab.dart                  DepositsTab; cheque/operation/quick groups
        deposit_actions.dart               DepositAction, DepositActionRequest
        cubit/deposits_cubit.dart           DepositsCubit
        cubit/deposits_state.dart           DepositsState alias, DepositsLoaded
      loans/
        loans_tab.dart                     LoansTab; summary/operations/quick groups
        loan_actions.dart                  LoanAction, LoanActionRequest
        cubit/loans_cubit.dart              LoansCubit
        cubit/loans_state.dart              LoansState alias, LoansLoaded
    shared/
      dashboard_services.dart              46 local service IDs and nine categories
      dashboard_assets.dart                feature aliases for AppAssets
      widgets/
        dashboard_async_view.dart          loading/error/retry/empty composition
        dashboard_bank_services.dart       fixed grid and favorite editor
        dashboard_service_tile.dart        service artwork/icon composition
        dashboard_services_sheet.dart      catalog/query/category sheet + reset sheet
        dashboard_all_services_screen.dart full catalog and category heading
        dashboard_reso_banner.dart         prompt resources/animation/lifecycle
        dashboard_header.dart              shared top bar wrapper
lib/core/result/
  result.dart                              Result<T>, Success<T>, Err<T>
  failure.dart                             Failure, DataFailure, UnexpectedFailure
lib/core/router/
  dashboard_notifications_navigation.dart  standalone notification navigation/cache
lib/shared/
  assets/app_assets.dart                    canonical local asset registry
  widgets/                                 reusable visual widgets; see Section 13
lib/l10n/                                  fa/en/ar ARBs + generated localizations
test/dashboard/
  dashboard_tab_cubits_test.dart            lifecycle, selection, immutable/race tests
  dashboard_async_ui_test.dart              status rendering/retry/disposal/integration
  support/dashboard_test_repositories.dart  controllable repository fake
test/{cards,deposits,loans}_screen_test.dart tab behavior/frame/geometry regressions
test/dashboard_cubit_test.dart              Home favorites regression
test/bank_loan_test.dart                    installment ratio guard tests
doc/dashboard/dashboard-development.md     this architecture document
doc/{dashboard,cards,deposits,loans}-review/ rendered UI galleries
```

Screen test filenames are retained for compatibility with existing preview commands; their subjects now instantiate *Tab classes. Entities no longer contain `.examples`/`.singleExample`; fixtures belong exclusively to DashboardMockData. There are no live DTOs, HTTP clients or API mappers yet.

### 6.2 Move and module boundaries

| Former dashboard-owned file | Current canonical file |
| --- | --- |
| features/cards/models/bank_card.dart | features/dashboard/domain/entities/bank_card.dart |
| features/cards/presentation/cards_screen.dart | features/dashboard/presentation/tabs/cards/cards_tab.dart |
| features/deposits/models/bank_deposit.dart | features/dashboard/domain/entities/bank_deposit.dart |
| features/deposits/presentation/deposits_screen.dart | features/dashboard/presentation/tabs/deposits/deposits_tab.dart |
| features/deposits/presentation/shared/deposit_actions.dart | features/dashboard/presentation/tabs/deposits/deposit_actions.dart |
| features/loans/models/bank_loan.dart | features/dashboard/domain/entities/bank_loan.dart |
| features/loans/presentation/loans_screen.dart | features/dashboard/presentation/tabs/loans/loans_tab.dart |
| features/loans/presentation/shared/loan_actions.dart | features/dashboard/presentation/tabs/loans/loan_actions.dart |

No compatibility re-exports are left in dedicated feature folders. App entry imports dashboard.dart. Standalone Notifications remains its own feature; the core navigation adapter owns the cross-feature presentation import and temporary read-state cache.

AppResalatCard, AppDepositCard, AppLoanCard, AppPrimaryNavigation, top bar, service grids, artwork tiles and assistant button stay in `lib/shared/widgets/`. They are reusable visual components with existing consumers/tests, not dashboard-specific business state. The package progress/button/input primitives stay in avp_ui. A future dedicated page can reuse these common visuals without importing a Dashboard tab or its Cubit. A shared full banking domain model may need a separate common contract later; the current summary models are owned by Dashboard.

## 7. Layering Pattern (Clean Architecture)

### 7.1 Current layers

**UI:** DashboardScreen composes the shell and injects repository instances. Each tab owns its Cubit lifecycle and observes typed state through BlocConsumer. Views pass loaded entity fields into existing shared visuals; they do not load fixtures or call transport services. PageController, FocusNode, text controller and animations remain view resources. Cards' privacy visibility and selected item are state, not controller fields.

**Presentation/state:** DashboardCubit owns asynchronous Home content and transactional favorites; DashboardNavigationCubit owns primary-tab selection. CardsCubit, DepositsCubit and LoansCubit own loading outcomes and selected IDs. Common behavior is factored once in DashboardTabCubit; typed loaded classes carry each tab's entity and card visibility. All states use Equatable and immutable collection snapshots.

**Domain:** Pure Dart entities, repository contracts and use cases have no Flutter imports. BankLoan derives footer and progress from one numeric count pair. LoadDashboardItems validates unique/nonblank IDs and detaches collection data before emitting it. These are dashboard summary/read models; formatted amounts and dates are still inherited prototype strings, not a complete banking domain representation.

**Data:** DashboardMockData holds samples; four mock repositories asynchronously return typed Result values. It is the only implemented data source. The shell's default composition explicitly creates mocks; passing DashboardRepositories replaces them. This is a small explicit composition root, not an installed get_it/injectable container.

### 7.2 Dependency direction and future adapters

```text
today: DashboardMockData -> MockDashboard*Repository
                                  implements domain repository interface
                                              ^
                                     LoadDashboard* use case
                                              ^
                                         tab/Home Cubit
                                              |
                                       immutable states
                                              v
                                      view -> shared/avp_ui

future: API -> remote datasource -> DTO -> validated mapper
                                          -> live repository
                                             implements the SAME interface
```

Recommended new adapter paths are `lib/features/dashboard/data/datasources/`, `data/dto/`, `data/mappers/` and `data/repositories/`. These do not exist yet. Summary fetch mapping belongs in Dashboard data, not in the dedicated Loan/Deposit page folders. Prefer validated raw money/date values plus a consistent display mapper when the bank schema is known; the present formatted summaries can be produced at the repository boundary without changing views/Cubits. Broader domain representation changes should be reviewed separately.

## 8. Service Flow Pattern and Suspended Requests

### 8.1 Current flow contract

DashboardScreen exposes:
- `initialFavorites` and `onFavoritesChanged(List<String>)`.
- `onServiceRequested(String)` and `onPromptSubmitted(String)`.
- `onMenuPressed`, `onProfilePressed`.
- `cards`, `onCardActionRequested(CardActionRequest)`, `onCardMorePressed(BankCard)`.
- `deposits`, `onDepositActionRequested(DepositActionRequest)`, `onSelectedDepositChanged(BankDeposit)`.
- `loans`, `onLoanActionRequested(LoanActionRequest)`, `onSelectedLoanChanged(BankLoan)` and `onLoanDetailsRequested(BankLoan)`.
- `enableAnimations`, default true.
- Optional `repositories: DashboardRepositories`; when supplied this bundle replaces default mock construction and seed arguments.

CardsTab, DepositsTab and LoansTab each require a typed domain repository; they no longer accept raw item-list arguments. Mock repository constructors accept those lists for previews/tests.

DepositsTab additionally exposes `onCopyNumber`, `onCopyIban`, `onTabSelected`, `onMenuPressed` and `onAssistantPressed`. The shell leaves copy callbacks unset so the existing platform clipboard fallback runs.

LoansTab additionally exposes onCopyNumber, onDetailsRequested, onTabSelected, onMenuPressed and onAssistantPressed. Every LoanActionRequest contains action and selected BankLoan. The shell invokes onLoanActionRequested when provided; otherwise onServiceRequested(action.id), which loses loan context. The summary arrow invokes onDetailsRequested for the card containing that arrow, wired to onLoanDetailsRequested in the shell. No unspecified detail screen is invented.

For a deposit action the dedicated callback receives both action and selected deposit. If it is absent, the shell falls back to `onServiceRequested(request.action.id)`, which loses deposit context. Production integration should provide the dedicated callback for deposit-scoped operations.

A null callback produces no bank execution. Selection events are fired on PageView page changes, not on initial construction or programmatic data replacement. Clients can derive initial selection from the first supplied item.

### 8.2 Deposit-dependent features

`BankDeposit.hasChequeOperations` is the only current per-deposit action capability. DepositsTab reads it from `DepositsLoaded.selected` on each loaded build; it inserts/removes the entire cheque group and gap. Other groups are fixed lists in DepositAction. Action requests always include the selected BankDeposit.

A server can supply `capabilities.chequeOperations`, or, more flexibly, a per-deposit `availableFeatureIds` list mapped into this flag today. A future presentation model should expose allowed/enabled action sets rather than infer them from account count or account type. Backend authorization must still validate every request.

### 8.3 Suspended requests and drafts

The UI has no suspended-request persistence/resumption. Favorites drafts are a different concept: a local editing transaction, not a submitted banking request. The architecture's request ID, idempotency, resumption and final confirmation belong to future service flows.

## 9. Security and Compliance Layer

No new security implementation is introduced. This is a UI prototype; logging into the demo does not verify bank credentials. Deposit examples are static and copy operations return caller-provided original strings.

The loan payment tile only emits a UI callback; no installment payment or money movement is performed. Neither visual hiding nor omission of a service is authorization. Server capabilities/permissions are for presentation; production APIs must enforce identity, ownership, service eligibility and platform restrictions. Cached catalog metadata must not grant a capability after it has been revoked.

Do not persist deposit numbers, IBANs, user prompts or tokens merely to implement catalog icon caching. Financial data storage follows the separate architecture's platform/security decisions.

## 10. Network and Authentication Layer

### 10.1 Current feature data sources, field by field

Dashboard services are instances of a compile-time enum, not records decoded from JSON. Category membership/order remain compile-time lists. Fixed/recommended order, saved favorites and wallet text come from DashboardHomeData through the Home repository/Cubit. Mock values are local fixtures; favorite editing remains local. Category membership and full catalog content still use the enum. There is no server feature response yet.

| Field / behavior | Actual current source | Dynamic today? | Server feasibility and required code change |
| --- | --- | --- | --- |
| ID | DashboardService.id, DepositAction.id, LoanAction.id, CardAction.id | Fixed supported IDs; favorites choose among them | Server may select known IDs. Add DTO parsing/registry resolution; unknown IDs must not reach firstWhere |
| Title | DashboardService.label/catalogLabel, DepositAction.label, CardsTab._label -> ARB getters | Locale-dependent, not arbitrary server copy | Add localized text map and optional known localization key; server text wins only with defined fallback |
| Description/supporting text | Reso banner and wallet ARBs; service item has no description field | Localized constants | Extend feature presentation model and an approved existing-component slot/variant before showing description |
| Icon | Enum asset switches + AppAssets local files | Selection of fixed/editing/saved variants is dynamic; source is local | Server iconKey resolver is easiest; URLs require renderer, cache, fallback and geometry contract |
| Item order | Home repository supplies fixedServiceIds/suggestedServiceIds; enum category and deposit/loan lists remain local | Repository and favorite ordering dynamic; mock defaults hard-coded | Sort validated server rank with stable ID tie-break; permit groups and ordered feature ID arrays |
| Category/group | DashboardCategory.services; deposit groups in screen | Filtered by query/category and deposit flag | Server can assign supported category keys/groups; unknown group types require fallback or omission |
| Visible | Fixed enum inclusion; search/category filtering; hasChequeOperations; nonempty lists | Local filters and deposit data only | Map explicit visibility/capabilities to view model; filter before building widgets |
| Enabled | AppServiceGridItem.enabled defaults true; sheet excludes already-selected favorites | Sheet duplicates disabled; deposit actions all enabled | Add per-feature enabled + disabled reason; preserve disabled callback/semantics policy |
| Route/action | Known enum ID passed to callbacks; local Navigator only for known screens | Host callbacks are injected | Server can name an allowlisted action target; it cannot create navigation code or execute arbitrary route strings |
| Action parameters | CardActionRequest.selected card; DepositActionRequest.selected deposit | Yes, current selection supplied | Merge whitelisted server params with trusted selected entity context; avoid trusting arbitrary IDs |
| Badge | No per-service badge in DashboardService/DepositAction/AppServiceGridItem; deposit type chip is separate | No feature badge support | Server may propose badge text/tone/count; add typed presentation field and approved visual support; it is not already rendered |
| Permissions | No role/permission model in service enums | No | DTO capability hints can filter UI; actual permission checks remain server-side |
| Platform eligibility | No per-feature platform metadata | No | Map platform lists and bank restriction policy to supported features; server is authoritative |
| Loading/error | Home and per-tab sealed Cubit states via Result-returning repositories | Yes; initial/loading/loaded/empty/error/retry | Live adapters return same Result types; offline/stale-cache policy remains future work |
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

Deposit icon mapping is in `lib/features/dashboard/presentation/tabs/deposits/deposit_actions.dart` (`DepositAction.asset`), not DashboardService.catalogAsset. New deposit files are original Figma SVGs. The cheque issuance asset was exported from the actual `cheque_request` instance because the generated reference incorrectly pointed to Chat. The SMS asset was also exported from its original Chat instance after visual verification found an identity icon in the generated alias.

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

Cards use `CardsTab._asset(CardAction)` in `lib/features/dashboard/presentation/tabs/cards/cards_tab.dart`, resolving `AppAssets.cardsAction*` and `cardsQuick*` in the same registry. Notifications use `notification_*.svg` and `notification_security.png`. Shared navigation owns dashboard_nav_*.svg and cards_nav_*.svg. None of these callsites is currently a network renderer.

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


### 10.6 BankLoan fields and transport readiness

Current model: `lib/features/dashboard/domain/entities/bank_loan.dart`. It is a pure Dart Dashboard summary entity, not an OpenAPI DTO. LoansTab receives it through DashboardLoansRepository/LoadDashboardItems/LoansCubit. Single/multi fixtures are in data/mock/dashboard_mock_data.dart, with count-derived proportions. The mock repository exists; live DTO mapping does not.

| Field | Current source / use | Proposed server mapping |
| --- | --- | --- |
| id | Required caller/fixture string; stable selection across reorder and callback identity | Stable opaque loan ID, unique within the input list |
| title | Nullable caller display string; null resolves `loansDefaultName` through context.l10n | Localized product/title map; resolve locale or known product key in presentation |
| number | Original caller string; shown and copied without conversion | Preserve raw string and leading zeros; do not parse as an integer |
| total | Caller-formatted amount string | Domain monetary amount and currency; a presentation mapper formats Persian grouping |
| installmentAmount | Caller-formatted amount string | Domain installment amount and currency; presentation formatting |
| paidInstallments | Caller/fixture integer paid count | Map installmentsPaidCount as a validated nonnegative integer |
| totalInstallments | Caller/fixture integer total count | Map installmentCount as a validated nonnegative integer |
| installmentsPaid | Derived footer string from the same counts, e.g. 3/10; FaNum displays Persian digits | Format the same numeric counts for the locale; never parse translated labels to calculate progress |
| nextInstallment | Caller-formatted Jalali date label | Parse server date in domain; use presentation Jalali formatting |
| progress | Derived paidInstallments / totalInstallments, bounded to [0,1]; zero total yields zero | Compute from validated counts; do not trust a separate inconsistent catalog percentage |

The single fixture uses 500,000,000 total, 50,000,000 installment, ۴/۱۰ and progress .4. Multi fixtures in RTL selection order are:

| ID | Original number | Total / installment | Paid display | Due-date display | Progress |
| --- | --- | --- | --- | --- | --- |
| loan-1 | 10-122-1234567-1 | 800,000,000 / 80,000,000 | ۳/۱۰ | ۱۴۰۴/۱۰/۰۳ | .3 |
| loan-2 | 10-122-1234567-2 | 500,000,000 / 50,000,000 | ۷/۱۰ | ۱۴۰۴/۱۰/۰۱ | .7 |
| loan-3 | 10-122-1234567-3 | 400,000,000 / 40,000,000 | ۹/۱۰ | ۱۴۰۴/۱۰/۰۸ | .9 |

The earlier prototype preserved Figma percentages independently of count labels. The progress-fix request makes counts authoritative: widths are now derived from paid/total. Figma styling and physical-left origin are preserved; old inconsistent percentages are historical evidence in Section 13.6.

LoanAction in `lib/features/dashboard/presentation/tabs/loans/loan_actions.dart` maps all six supported UI actions:

| Enum / integration ID | ARB title key | Exact local asset | Group |
| --- | --- | --- | --- |
| payInstallments / loan-pay-installments | loansPayInstallments | `assets/images/loans_pay.svg` | Operations |
| defer / loan-defer | dashboardDeferLoan | `assets/images/loans_defer.svg` | Operations |
| correctInstallments / loan-correct-installments | dashboardCorrectInstallments | `assets/images/loans_correct_installments.svg` | Operations |
| changeDeposit / loan-deposit | loansChangeDeposit | `assets/images/loans_change_deposit.svg` | Operations |
| relationships / loan-relationships | loansRelationships | `assets/images/loans_quick_relationships.svg` | Quick access |
| consolidate / loan-consolidate | consolidateDepositCredit | `assets/images/loans_quick_consolidate.svg` | Quick access |

All are registered in `lib/shared/assets/app_assets.dart`. Operations SVG roots are 32×32; quick exports are 70×70.5 with export shadow margin, rendered in the existing 64×64 AppServiceArtworkTile. The quick header reuses `AppAssets.depositsQuickAccess` -> `assets/images/deposits_quick_access.svg` (the same Figma asset reference), and the new pattern is `AppAssets.loansPatternUp` -> `assets/images/loans_pattern_up.svg` (375×122). Binary hash comparison found no exact existing matches for the seven newly downloaded files; no SVG was redrawn or edited.

The loan summary itself uses existing `AppAssets.loanCardCopy`, `loanCardDividerSingle`, `loanCardDividerMulti`, and `arrowButtonArrowLeft` through AppLoanCard/AppArrowButton, not feature-local replacement icons. Navigation uses the existing `dashboardNavLoan`.

Loan feature fields are currently:
- **Title/icon/ID/group/order:** compile-time enum mapping and localized ARBs; move to a server catalog only through the supported action registry.
- **Visibility:** all six actions render when at least one loan exists. There is no capability-dependent filtering in BankLoan yet.
- **Enabled:** all six items use AppServiceGridItem's default enabled=true. A callback may be absent; that does not represent bank eligibility.
- **Permissions/badges/disabled reason:** absent from BankLoan and LoanAction; not silently inferred from repayment progress or loan count.
- **Route/action:** known ID and selected loan are passed in LoanActionRequest. The arrow passes that card's BankLoan through onDetailsRequested. No server route string or detail screen is constructed.
- **Selected summary:** title, amounts, counts, dates and normalized progress change with the selected BankLoan. Every operation and quick action reports the selected loan.
- **Future server icons:** the key/URL/cache/fallback approach in Section 10.3 applies to LoanAction too. Changing its String asset switch alone cannot load a URL.

Proposed loan extension to the Section 10.4 response (illustrative; not an endpoint/parser implemented by this work):

```json
{
  "loans": [
    {
      "id": "loan-api-1",
      "number": "10-122-1234567-1",
      "productKey": "qarz_standard_no_fee",
      "title": {"fa": "تسهیلات قرض الحسنه عادی (بدون کارمزد)"},
      "totalAmount": "800000000",
      "installmentAmount": "80000000",
      "currency": "IRR",
      "installmentsPaidCount": 3,
      "installmentCount": 10,
      "nextInstallmentDate": "2026-10-09",
      "progress": 0.3,
      "progressBasis": "installment_count",
      "availableActionIds": ["loan-defer", "loan-deposit"],
      "disabledActionIds": ["loan-pay-installments"],
      "disabledReasons": {"loan-pay-installments": {"fa": "فعلاً در دسترس نیست"}}
    }
  ],
  "features": [
    {
      "id": "loan-defer",
      "type": "service",
      "title": {"fa": "امهال وام"},
      "icon": {"key": "loan.defer", "format": "svg", "template": "operation_icon"},
      "order": 20,
      "visible": true,
      "enabled": true,
      "action": {
        "kind": "service",
        "target": "loan-defer",
        "requiresSelectedLoan": true
      }
    }
  ]
}
```

A future `lib/features/dashboard/data/mappers/` mapper would validate dates/money/progress/IDs and construct domain entities; mapping would construct the current BankLoan summary and resolved feature items. availableActionIds/disabledActionIds are proposed and are not current model fields. Unknown actions must be omitted or disabled under an approved fallback policy, never routed to a similar service. Real payment handling, ownership checks, permission enforcement, authentication and final confirmation remain app/domain/API work. This task only implements the payment tile and callback.

### 10.7 What remains in the app

Navigation targets, authentication guards, service use cases, entity validation, final confirmation, transaction/request idempotency, approved visual templates, RTL rules, safe icon rendering and fallback behavior require shipped app code. Server metadata cannot introduce a new executable feature flow.

Titles, descriptions (once supported), known icon choices or approved remote artwork, order, category membership, visibility, enabled hints, badges (once supported), saved favorites, account data and action eligibility can be server-driven through a validated contract. They still need client rendering and mapping. Adding a feature of a known supported action/type can be metadata-only; adding a new flow, layout type or capability semantics needs an app release.

### 10.8 Replacing mock repositories with real services

The migration already supplies an asynchronous interface per surface in `domain/repositories/dashboard_repositories.dart`: getHome returns Result<DashboardHomeData?>; getCards/getDeposits/getLoans return Result<List<BankCard/BankDeposit/BankLoan>>. Mock constructors can seed one item, many or an empty list. A bank request failure must return Err, not Success([]).

Implement the corresponding interfaces under `data/repositories/`, backed by a transport datasource and validated DTO mapper under Dashboard data. Supply those four objects through `DashboardScreen(repositories: DashboardRepositories(...))`. Supplied repositories take precedence over cards/deposits/loans/initialFavorites seed arguments; those seeds remain convenience inputs for demo/default mock composition. Tab constructors require their own typed repository. Cubit constructors and view builds do not change when the implementation changes.

| Service integration task | Changes required | Changes not required |
| --- | --- | --- |
| Endpoint/auth/request handling | Remote datasource, authenticated client/core configuration, timeout/error classification | Tab widgets or selection algorithm |
| JSON/schema conversion | DTOs/mappers validate IDs, amount/date strings, counts and capabilities; return current dashboard summaries | AppDepositCard/AppLoanCard layout |
| Selected deposit cheque eligibility | Map server account capability into BankDeposit.hasChequeOperations | Existing cheque section composition |
| Item count/order/selection | Return ordered validated list; stable IDs retained by Cubit | Single/multiple UI branches or PageController API |
| Home wallet/fixed/recommended IDs | Produce DashboardHomeData; unsupported service IDs handled by mapper/local registry | Home Cubit loading interface |
| Favorite writes | Add repository save/use case, pending save/conflict/error states and persistence policy | Not implemented merely by swapping a read repository |
| Remote icons/badges/per-action permissions | Add typed catalog/view mapping, approved visual support and resolver/cache described in10.3–10.4 | Cannot be implemented solely by returning current local enum IDs |

All four tabs currently start their reads when IndexedStack mounts. Live services may prefer lazy load, batching, cache freshness or refresh-on-resume; those are policies to define before production. Request tokens protect state order; they do not cancel the underlying network call. No endpoint response has been guessed or wired during this migration.

## 11. Error Handling Pattern (Result & Failure)

`lib/core/result/result.dart` defines sealed Result<T>, Success<T> and Err<T>. `failure.dart` defines equality-based coded Failure, DataFailure and UnexpectedFailure. Failures contain no localized message or BuildContext.

Both loading use cases catch unexpected repository exceptions into UnexpectedFailure. Explicit repository Err values are preserved. LoadDashboardItems rejects duplicate/blank identifiers with `dashboard.items.invalid`; a successful empty list produces Empty, never Error. Home Success(null) produces DashboardEmpty, whereas a Home object with no favorites is normal DashboardLoaded.

Views localize a generic loading/failure/empty message and offer retry for Error. They do not display raw exception bodies or replace failed loads with sample data. Tab Loading/Error can retain a previous loaded snapshot for ID/visibility reconciliation, but stale cards/actions are hidden while those states are displayed. No offline-cache, permissions, transaction-error or field-level validation UI is claimed.

## 12. State Management with Cubit

### 12.1 Home and favorites

DashboardState in `presentation/cubit/dashboard_state.dart` is sealed: DashboardInitial, DashboardLoading, DashboardLoaded(data, draft), DashboardEmpty and DashboardError(failure). DashboardLoaded exposes committed favorites, nullable draft and visibleFavorites. Lists are immutable and state equality includes their values. DashboardCubit loads through LoadDashboardHome, deduplicates IDs and limits saved favorites to eight.

```text
Initial -> load -> Loading -> Loaded | Empty | Error
Error -> retry -> Loading -> new repository result
Loaded -> edit -> Loaded(draft)
draft -> add/remove (unique/max8) -> updated draft
draft -> confirm -> Loaded(committed) -> host onFavoritesChanged
draft -> cancel/system back -> Loaded(original saved IDs)
reset -> confirmation sheet -> Loaded(empty saved IDs) -> host callback
```

Empty favorites are not an empty Home response. Suggested and fixed service ID order comes from DashboardHomeData. Mock recommendations remain card-issue, loan-consolidate, card-deposit. Service labels/icons/routes still resolve locally against DashboardService. Unknown favorites are omitted safely from visual mapping; they do not trigger firstWhere exceptions. The mock composition filters initial caller IDs; a future data mapper should validate unsupported server IDs explicitly.

A load cancels an unsaved draft and replaces Home data; pending-load tokens prevent an old response overwriting a newer one. Favorites confirmation remains local plus a host callback, not a repository write/synchronized save. A production save/conflict policy is still required.

### 12.2 Typed tab states and selection

CardsState, DepositsState and LoansState are typed aliases over the sealed DashboardTabState<T> family. Their factories produce CardsLoaded, DepositsLoaded and LoansLoaded. The shared transitions are:

```text
Initial -> load -> Loading(previous?) -> Loaded | Empty | Error(previous?)
Loaded:
  immutable items, selectedId, selectedIndex, selected entity
  layout = single if length==1, otherwise multiple
CardsLoaded additionally: immutable visibility map keyed by card ID
swipe/indicator -> select(index) -> new Loaded -> contextual callback
reload/repository replacement -> retain selectedId if still present
selected removed -> first remaining item
success([]) -> Empty (no selected entity/actions)
Error -> retry -> same repository -> new load result
```

Tab load factories receive detached item snapshots. Card number parts and visibility maps cannot be mutated through state getters. Card visibility defaults to revealed for single-card layouts and hidden for multiple-card layouts; explicit per-ID choices survive selection/reload when the ID remains.

Cubit `select` ignores out-of-range indices and nonloaded states. A monotonically increasing request token makes the newest load win; completion after Cubit.close does not emit. Close invalidates pending responses; this guards emission, not transport cancellation.

### 12.3 View resources, lifecycle and shell

Each tab constructs its Cubit from its required repository, calls load, observes BlocConsumer, reloads when repository identity changes and closes it at disposal. Retry delegates to Cubit.load. PageController is not canonical state: selected ID/index comes from Loaded. Controllers are recreated when item order/IDs or viewport fraction changes; keepPage is false and an ObjectKey on the controller replaces the associated page subtree. Bloc listeners synchronize valid programmatic selection when the controller is idle.

DashboardNavigationCubit owns selected AppPrimaryTab. IndexedStack preserves all four tab instances; each loads once on mount, including offstage tabs. TickerMode pauses hidden animations. Back returns to Home or cancels a Home favorite draft. The shell reuses unchanged default mock repository objects on seed changes, so replacing loans does not reset Home favorites.

Selection callbacks remain page-change notifications, not initial-load/list-refresh events. Action requests carry the state-selected entity. The notification cache remains in a core navigation adapter, separate from Dashboard data/state.

### 12.4 Data and deposit-dependent flow

```text
mock repository / future live repository -> Result<List<BankDeposit>>
  -> LoadDashboardItems -> DepositsCubit -> DepositsLoaded.selected
     -> AppDepositCard fields
     -> hasChequeOperations -> cheque group visible/absent
     -> tap -> DepositActionRequest(action, selected deposit) -> host
loan counts -> BankLoan.progress + installmentsPaid
  -> LoansLoaded -> AppLoanCard -> existing AppProgressIndicator
  -> tap -> LoanActionRequest(action, selected loan) -> host
Home repository -> DashboardHomeData -> DashboardCubit -> wallet/fixed/favorite UI
ARBs + local enum/AppAssets mapping -> titles/icons/action widgets
```

Cheque availability is per selected deposit, independent of count. A server mapper can supply hasChequeOperations from account capabilities. Loan operations remain the same four plus two quick actions in both supplied frames; no unsupported eligibility policy is inferred. Existing physical-left loan progress and paid/total guard behavior remain intact.

## 13. Design System Package (`avp_ui`)

### 13.1 Ownership and reuse

| Owner | Used components / tokens | Location |
| --- | --- | --- |
| avp_ui | AppTheme, context.colors, AppTypography, AppSpacing, AppRadius, AppShadows, AppDashboardColors, AppLoginColors | External `avp_ui/lib/tokens/`, `theme/`, `extensions/`, exported by avp_ui.dart |
| avp_ui | AppButton, AppSearchField; shared components also compose package primitives | Public `package:avp_ui/avp_ui.dart` |
| App shared | AppLoanCard, AppArrowButton; loan card composes avp_ui AppProgressIndicator | `lib/shared/widgets/app_loan_card.dart`, `app_arrow_button.dart` |
| App shared | AppDepositCard | `lib/shared/widgets/app_deposit_card.dart` |
| App shared | AppPrimaryNavigation / AppPrimaryTab | `lib/shared/widgets/app_primary_navigation.dart` |
| App shared | AppTopBar | `lib/shared/widgets/app_top_bar.dart` |
| App shared | AppServiceGridCard, AppServiceGridItem, AppServiceGridItemView | `lib/shared/widgets/app_service_grid_card.dart` |
| App shared | AppServiceArtworkTile | `lib/shared/widgets/app_service_artwork_tile.dart` |
| App shared | AppAssistantButton, AppAssistantIcon | `lib/shared/widgets/app_assistant_button.dart` |
| App shared | AppWalletCard, AppBottomSheetHeader, AppResalatCard | Corresponding files in `lib/shared/widgets/` |
| Feature local | DashboardBankServices, DashboardServiceTile, DashboardResoBanner, catalog/sheet headings | `lib/features/dashboard/presentation/shared/widgets/` |
| Feature local | DepositsTab group/carousel composition, DepositAction mappings | `lib/features/dashboard/presentation/tabs/deposits/` |
| Feature local | LoansTab group/carousel composition, LoanAction mappings | `lib/features/dashboard/presentation/tabs/loans/` |

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

Recommendation: add an explicit visual variant or gradient parameter with the current rendering as the default; introduce a package-owned deposit gradient token for the reviewed design. Do not globally change the default or copy a new card into DepositsTab.

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

DashboardScreen, CardsTab, DepositsTab and LoansTab all use this navigation component. DashboardHeader/cards/deposits use the same AppTopBar; no header correction was introduced. Before this task, AppDepositCard was implemented and tested as a shared component but had no feature-screen callsite; this task adds its DepositsTab use. Shared financial-card tests cover its existing single/multi variants.

Recommendation: add an optional active deposit icon or reviewed selected-tab icon map to shared navigation, retaining default behavior. Avoid a global color filter on all icons: existing dashboard/card active and inactive assets have their own styling.

### 13.5 Decision and accepted visual limits

These issues remain because the user explicitly instructed “use exactly the current existing components” and requested documentation instead of correction. Existing shared tests and behavior remain the baseline. Exact pixel equality with the supplied frames is therefore not the acceptance criterion for those two components.

The existing grid's row wrapping, max-two-line labels and text metrics are also preserved. Existing deposit card labels are Persian strings inside the shared component; full multilingual card labels require a separate reviewed shared API extension. This task localizes screen/group/action/empty-state copy without editing that component.


### 13.6 Loans — shared-component comparison and retained differences

Loans reuses existing components; the progress primitive and AppLoanCard alignment callsite are corrected by the explicit progress-fix request. This is a feature-composition choice following the earlier shared-component approach; the current Loans instruction requires retained mismatches to be documented. No duplicate loan card, progress bar, arrow button or navigation bar was created.

**AppLoanCard** lives in `lib/shared/widgets/app_loan_card.dart`. Its native single/multi widths are 335/316 and height is 236, matching both frames. It uses the existing theme primary at alpha .32 for the header, a white body, rounded 16px corners, shared compact arrow and shared progress indicator.

| Property | Current shared rendering | Required by these Figma frames | Status / future fix |
| --- | --- | --- | --- |
| Card shadow | AppShadows.md: Color(0x0A0D120F), (0,4), blur 8, spread -2; Color(0x0A0D120A), (0,2), blur 4, spread -2 | Color(0x1A0A0D12), (0,4), blur 8, spread +2; Color(0x0F0A0D12), (0,2), blur 4, spread +2 | Retained. AppShadows.bankCard already holds the required layers; prefer an optional shadow/visual variant over replacing defaults |
| Header geometry | 54px header; padding left/right16, top14, bottom12 | Content at top16, 28px arrow row, then12px gap; body starts at56px relative to card | Retained 2px header/body offset and row-origin difference; introduce a reviewed optional layout variant |
| Summary arrow | Existing AppArrowButton uses arrow_button_arrow_left.svg; rendered arrow is gray | Blue arrow inside the white 28px circle | Retained. A reviewed optional icon/color variant must preserve other AppArrowButton consumers |
| Progress foreground | Fixed: visible blue fill, full 8px height, physical-left origin, derived paid/total width | Blue rounded 8px track from physical left, with paid counts authoritative | Resolved: 40% single, 30%/70%/90% multi |
| Active Loans navigation | AppPrimaryNavigation always uses dashboard_nav_loan.svg (gray) | White active loan icon on the blue selected background | Retained. Add optional selected-loan asset mapping while preserving defaults |
| Navbar shadow | Existing AppShadows.sm: alpha .06, offset(0,1), blur3/spread0 plus alpha .10, offset(0,1), blur2/spread-1 | Frame navbar uses alpha .08 with blur4/spread0 and alpha .04 with blur2/spread0 at offset(0,1) | Existing shared navigation difference retained across all tabs; use an optional instance elevation after review |
| Arrow surface decoration | Shared compact AppArrowButton includes a surface-alpha .8 border and AppShadows.xs | Figma compact white button has no explicit border/shadow in the supplied context | Existing arrow decoration retained; review together with the blue-icon variant |
| Labels/localization | Shared card owns Persian field/currency/footer strings | Persian frames match these labels; other locales require translated labels | Known pre-existing API limitation; add reviewed label parameters in a later shared change |
| Large text | Shared number/amount/footer rows are fixed at22px; title is one line | Figma normal scale is supplied; no authored large-text variant | No redesigned shared variant in this task; further large-text/long-value accessibility review needed |

#### Resolved progress issue: cause, calculation and rendering fix

Two independent problems were confirmed:

1. **Rendering, not zero/null mapping:** LoansTab passed BankLoan.progress to AppLoanCard, then to AppProgressIndicator. The old values were nonzero (.4906 single and .4025/.7466/.92 multi). In avp_ui lib/widgets/loaders/app_progress_indicator.dart, _ProgressTrack placed a non-positioned FractionallySizedBox inside a Stack. Its ColoredBox child had no intrinsic height, so loose constraints collapsed the blue foreground vertically despite the 8px gray background.
2. **Independent fixture percentages:** BankLoan stored a progress number separately from a formatted paid/total string, allowing the footer and bar to disagree. No backend or mapper was involved.

**Calculation:** BankLoan now stores integer paidInstallments and totalInstallments. The installmentsPaid footer and progress getters use the same counts. Progress is paid/total bounded to [0,1]; zero/unknown totals return zero. Negative counts are rejected by constructor assertions. Callers supply validated numeric counts rather than translated strings or arbitrary percentages.

**Rendering:** The existing package primitive now bounds the foreground with Positioned.fill and heightFactor: 1, preserving the full 8px height. A DecoratedBox with a 4px radius rounds the blue fill at both ends, including the partial trailing cap. Width is the fraction times track width, clipped to the existing rounded track. There is no custom overlay or duplicate bar.

**Figma origin:** The new optional AppProgressIndicator.fillAlignment defaults to AlignmentDirectional.centerStart for compatibility. AppLoanCard passes Alignment.centerLeft so blue fills from the physical left in RTL, as Figma shows. Its default progress is also .4, consistent with its default 4/10 label.

**Authoritative counts:** Figma's sample widths (.4906 for 4/10; .4025/.7466/.92 for 3/10,7/10,9/10) are inconsistent with those installment labels. Following the user's fix request, counts now determine the width: 40% single; 30%,70%,90% multi. Blue color, 8px height, rounded clipping and physical-left origin match the design.

**Changed files:** lib/features/dashboard/domain/entities/bank_loan.dart; lib/shared/widgets/app_loan_card.dart; test/bank_loan_test.dart; test/loans_screen_test.dart; and package lib/widgets/loaders/app_progress_indicator.dart, test/widgets/app_progress_indicator_test.dart, docs/main-app-integration-guide.md. The app integration guide records the new public parameter.

**Regression coverage:** Count tests cover ordinary ratios, different totals, zero paid/total, complete and inconsistent over-count input. Package tests measure actual foreground width and 8px height at zero/partial/full values in LTR and RTL and test the explicit physical-left origin. Screen tests measure single and every selected multi-loan fill; previews are regenerated and inspected. Other accepted loan-component differences remain open.


#### Consumers and compatibility

AppLoanCard had shared financial-card tests before this task; LoansTab is its feature-screen consumer. AppArrowButton is also exported as a shared standalone action and covered by shared tests. AppProgressIndicator is used inside AppLoanCard and AppFileUploadBase (lib/shared/widgets/app_file_upload_base.dart), and is a public avp_ui primitive; AppPrimaryNavigation is used by DashboardScreen, CardsTab, DepositsTab and LoansTab. Existing shared widgets continue to own their hard-coded/semantic color choices; no feature-owned hex colors were introduced.

Do not globally alter AppShadows.md or replace all navigation/arrow assets as part of fixing Loans: review other shared consumers and preserve compatibility with variants/parameters. The required loan shadow is already available as bankCard, while the focused progress package changes are documented above.

The feature does match the supplied page geometry at normal scale: top bar y24/h64, card top y104, native card h236, loan area h282, operations top y382/h176, quick access top y570/h176, 12px between groups, assistant/navigation at the existing fixed slots. Source SVGs, RTL action order, summary data, carousel previews and selected callback context are implemented. Progress is fixed; the other component exceptions above remain.

### 13.7 avp_ui change audit against Figma (2026-10-09)

**Scope and evidence.** The working package diff contains the earlier bankCard token addition and the progress repair. The recent integration commits also touched AppButton, AppTextField/AppSearchField, AppTypography, AppDashboardColors and AppLoginColors, so these are audited here rather than considering only today's dirty files. Package public exports, integration-guide edits and regression tests have no separate visual representation. No shared visual default is changed by the folder/Cubit migration.

The comparison uses freshly retrieved Figma design context and screenshots, then the actual package source, not names such as “Figma-aligned” in Dart comments. Button and input sets returned sparse metadata; individual variants were subsequently fetched. References below are all in [Pishkhan AI Mobile](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile). This is a source/token and rendered-frame review, not a claim of exhaustive pixel equality for every library variant.

| Changed component/source | Figma reference and verified properties | Remaining difference / recommendation |
| --- | --- | --- |
| AppProgressIndicator — avp_ui/lib/widgets/loaders/app_progress_indicator.dart | Linear progress set [15992:142102](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=15992-142102); loan [27902:82623](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82623). Height8, radius4, track #F5F5F5, foreground #1570EF; no gradient/shadow. Foreground now receives full height and proportional width. AppLoanCard's explicit centerLeft gives the Figma physical-left origin in RTL. Actual zero/partial/full geometry and every loan fixture are tested. | Count-based widths intentionally replace Figma's inconsistent sample percentages (Section 13.6). The broader primitive is not exact in all label variants: right-label design has a total320px row with a flexible shorter track; current width320 means track-only plus12px gap and label. Generic RTL default begins at directional start; Figma samples begin physically left. Some Figma0% variants retain an8px stub; app0 is genuinely empty. Floating tooltips use hardcoded offsets/clamps instead of fully matching all endpoint tooltip geometry. These untouched variants need a reviewed compatible API/layout fix; they are not used by loan cards. AppProgressCircle shares the file but its painter/layout were not changed and are not certified by this audit. |
| AppButton — avp_ui/lib/widgets/buttons/app_button.dart | Button set15699:34979; fetched [sm active15699:34995](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=15699-34995), md active15699:35395, xl active15699:36195, disabled15699:35035, focused15699:35515, text15699:35715 and loading15705:63267. Heights36/40/44/48, horizontal default padding18/20/22/24,20px icons,8px gap, radius8. Primary active #1570EF/white and xs shadow match. Type sm12/18 Medium; md/lg14/20 DemiBold; xl16/24 DemiBold. Additive horizontalPadding/foregroundColor parameters retain default behavior. Foreground overrides are deliberately ignored when disabled. | Disabled source removes xs shadow although inspected Figma disabled retains it. Focus source uses active brand/error color at .28 alpha, while Figma primary focus ring is opaque #E4F3FF,spread4. Loading source is disabled gray with spinner-only; Figma loading is #175CD3, xs shadow, label plus20px loader. Text-only source retains standard36/40/44/48 hit-area height/padding; Figma visible md text row is20px high. Source has Material splash/hover behavior, not an exact Figma motion specification. Review optional styling states/visible versus accessible hit bounds; do not silently alter other consumers. |
| AppTextField — avp_ui/lib/widgets/fields/app_text_field.dart | Input set15652:17725; inspected [regular active15652:17946](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=15652-17946), focused15652:26618 and focused/error15652:28442. Single-line44px, radius8, horizontal14px/vertical10px padding; label14/20 Medium,8px vertical gaps, body16/24 Regular, helper14/20 Regular. Active white/#D5D7DA/xs, focused #1570EF border, error #FDA29B and #F04438 helper match those source values. Added textStyle/onSubmitted/digit normalization are opt-in behavior; no new icon asset is embedded in the field. | Focused Figma variants inspected have xs only; source adds2px or4px primary/error ring. Regular Figma leading icon is a20px icon after8px gap; source uses Material prefix/suffix slots min48×44, so exact content positions need a variant-level layout review. Figma helper can include14px question icon and8px gap; source only displays helper text. AppTextArea delegates to the same field but was not separately changed/certified. AppTextField's fixed44px single-line height remains a large-text constraint. |
| AppSearchField — same package field file | Search set [15807:44137](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=15807-44137) includes Active/Hover/Focused/Disabled/Filled/View Only with default/error feedback. Verified44px/radius8, active white/#D5D7DA, hover #A4A7AE border with gray1004px ring, error hover #F97066/#FEE4E2 ring; filled text #181D27; view-only #FAFAFA/#414651; active-error #FFFBFA. clearIcon/searchIcon slots allow existing exact app SVGs instead of forced Material glyphs. | Generic search active hint uses #A4A7AE through AppTextField, while Figma search hint is #717680. Focus adds a source primary/error ring absent from Figma focused search. Default disabled text #A4A7AE matches its inspected text; icon-color differences remain where Figma has #535862. Material default search/close glyphs are not the authored Figma SVGs; Dashboard supplies AppAssets.dashboardCatalogSearch and dashboardSearchClear. Dashboard intentionally supplies14/20 text and subtle2px ring for its frame instance, rather than the generic16/24 design-set type. Clear IconButton uses Material hit-area behavior, not a fixed20px visible slot by itself. The Persian clear tooltip is still package-owned. |
| AppTypography — avp_ui/lib/tokens/app_typography.dart | Inspected Button/Input and Dashboard frame typography uses IRANYekanXFaNum at12/18,14/20,16/24, zero tracking; weights Regular400/Medium500/DemiBold600. defaultFontFamily now resolves packages/avp_ui/IRANYekanX, whose font files are declared in avp_ui/pubspec.yaml. The changed family path matches the actual package registration; tests load Regular/Medium/DemiBold/Bold fonts. | Tokens still include Material-scale defaults that need explicit line-height/tracking overrides for individual Figma instances; package font-path correction does not make every text style exact. Static widget tests verify metrics with production fonts; native font rasterization/browser/platform differences are not certified. |
| AppShadows.bankCard — avp_ui/lib/tokens/app_shadows.dart | Fresh Cards27902:82533 and Loans27902:82623 contexts confirm two layers: #0A0D121A offset(0,4),blur8,spread+2; #0A0D120F offset(0,2),blur4,spread+2 (Figma RGBA hex). Token uses correct Dart ARGB 0x1A0A0D12 and0x0F0A0D12. Existing AppResalatCard applies this matching elevation. | AppDepositCard and AppLoanCard still use md, not bankCard. Their exact mismatch is documented in13.3/13.6. md was not globally corrected; its unusual literals/spread remain pre-existing. |
| AppShadows focus-ring additions — same token file | Search hover Figma gray100/error100 rings have4px spread,zero blur/offset plus xs alpha. Source focusedGray4px #F5F5F5 and focusedError4px #FEE4E2 match those effect numbers. Button-focused Figma token #E4F3FF matches focusedPrimary4px's color/spread. | AppButton does not consume the matching focus token. AppTextField applies a primary/error ring to focused variants where retrieved Figma has xs only.2px variants support existing instance customization but are not demonstrated by the generic4px set; use only for reviewed instances. Shadow-list order differs from returned ring-first context and should be render-reviewed when changing ring composition. |
| AppDashboardColors — avp_ui/lib/tokens/app_dashboard_colors.dart | Dashboard27902:80847, favorite editing27902:81700, all-services27902:82267 and shared nav frames. Verified service #181D27, section #24292E, tile gray25 #FDFDFD; favorites blueGray50 #F8F9FC, border blueGray200 #D5D9EB, action blueGray600 #3E4784, optionText blueGray700 #363F72, categorySearch blueGray500 #4E5BA6, muted gray500 #717680; hero brand900 #194185, gray600 #535862; nav brand500 #2E90FA; assistant pink500 #EE46BC; editor warning25 #FFFCF5/warning200 #FEDF89; add success50 #ECFDF3/success400 #32D583/success500 #12B76A. | This token file has no sizes, icon geometry or gradients of its own. Hero haze animation colors are semantic inputs; they do not reproduce the exported baked artwork's full gradient/lighting exactly. Scrim #101828 is an overlay input with instance opacity/blur; screenshot resemblance alone does not certify compositing. Existing shared nav/card differences remain. |
| AppLoginColors — avp_ui/lib/tokens/app_login_colors.dart | Earlier integration touched login colors; inspected Login27847:4237 and guest-services27847:4724. Canvas gray25 #FDFDFD, notice warning100, notice text #383F45, muted service gray600 #535862 and section #24292E correspond to instance design colors. | serviceLabel #394047 is a sampled/custom instance color rather than a named palette style in the retrieved set. These tokens have no geometry/state/gradient of their own; this review does not certify every auth screen state. Existing login UI remains outside this Dashboard migration. |

**Changed parameters in actual consumers.** DashboardBankServices uses foregroundColor for blue-gray favorites actions and horizontalPadding2/8/0 for compact text controls; the service sheet injects the registered search/clear SVGs. AuthOtpForm uses horizontalPadding4. These additive overrides leave other package defaults intact. The file inventory and enum/icon tables in Section10 remain the exact runtime mapping.

**Conclusion and follow-up scope.** The progress repair and the bankCard token values are verified for their target instances. Remaining button/input/progress-label state differences and shared card/nav issues are explicitly open. This task neither replaces existing components nor introduces duplicate Figma-only components. Future fixes should add reviewed variants/parameters, validate both old and new consumers, and update this audit after source and rendered comparisons. No claim that the whole avp_ui library is “exactly Figma” is supported by the inspected evidence.

## 14. Localization, Persian Support, and Dates

The app installs AppTheme.light and forces RTL in the MaterialApp builder, including future languages. Screens also establish RTL explicitly. ARBs are fa/en/ar and generated through l10n.yaml.

Loans adds loansOperations, loansEmpty, loansPayInstallments, loansRelationships, loansDefaultName and loansChangeDeposit in all three ARBs. It reuses dashboardMyLoans, dashboardDeferLoan, dashboardCorrectInstallments and consolidateDepositCredit. Loan title uses the caller string when supplied and localized loansDefaultName otherwise. Shared card labels/currency remain Persian because their API has no label parameters.

New keys include depositsMyTitle, depositsOperations, depositsChequeOperations, depositsEmpty, depositsRepresentative, depositsLinkedCards, depositsLinkedLoans, depositsLocalTransfer, depositsMobileBank and depositsCopyNumber. Existing ARB keys cover statement, certificate, SMS, blocking, cheque actions, quick access and modern banking.

Action order is expressed from the RTL start: statement/certificate/SMS/block; representative/virtual card/linked cards/linked loans. Quick actions start with card issuance, local transfer, estimate and introduce loan; next proxy/mobile/internet/phone. Numeric strings are passed unchanged; AppDepositCard sets LTR for numeric values and RTL for labels. Copy callbacks return original number/IBAN, not formatted numeric conversions.

BankDeposit.openingDate is currently preformatted display data. Server openedAt should be parsed as a date and converted in presentation, respecting the architecture's Gregorian/UTC domain rule and Jalali UI requirement. The static typeLabel default is Persian; server/caller should supply a localized label for another locale.

Fonts are owned by avp_ui, not duplicated in pubspec. Test previews explicitly load Regular/Medium/DemiBold/Bold from package assets. Existing shared card scaling/label limits remain documented accessibility limitations rather than redesigned components.

## 15. Routing and Guards

DashboardScreen's IndexedStack now retains all four children in AppPrimaryTab order: dashboard/cards/deposits/loans. Every tab selects its screen; Loans selection no longer opens a service sheet. The Loans menu fallback still opens the loan-filtered catalog.

Back from Cards, Deposits or Loans selects Dashboard. Back while editing dashboard favorites cancels the draft. Bell navigation and all-services pages use Navigator.push. No go_router auth/platform/security guard was added.

Deposit menu uses the supplied onMenuPressed if available; otherwise the shell opens the existing deposits-filtered service sheet. The assistant on either Deposits or Loans switches to Dashboard and triggers the assistant service (or focuses the prompt if no service callback is supplied).

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
- Service-ID fallback, menu callback, assistant transition and navigation into the dedicated Loans tab.
- Narrow 320px viewport with 1.4 text scale and reachable quick action.

Existing dashboard/card/notification/widget and asset integrity tests remain regression coverage. AppAssets.all verifies every new registered file is bundled and non-empty; static asset metadata and rendered slots are checked against design context. The original cheque-plus instance export is used, not the incorrect generated Chat alias.

### 16.2 Visual review

[Deposit review gallery](../deposits-review/index.html) contains [single](../deposits-review/phase1-single.png) and [multiple](../deposits-review/phase2-multi.png) renders. They intentionally preserve the gradient/shadow and active-icon differences documented in Section 13. Preview canvas includes simulated safe-area spacing; it does not draw native system status/navigation controls.

Regenerate with PowerShell:

```powershell
$env:UPDATE_DEPOSITS_PREVIEWS = '1'
flutter test test/deposits_screen_test.dart
```

The previews are review artifacts, not screenshot UI assets or new golden baselines.

### 16.3 Results and limits

- `flutter test test/deposits_screen_test.dart`: 9 tests passed; final preview generation passed after the original SMS export was installed.
- `flutter test`: all 119 tests passed after the Dashboard tab/Cubit migration, including auth, cards, dashboard, deposits, loans, notifications, shared widgets and asset integrity tests.
- `flutter analyze`: no issues found. The sibling avp_ui dependency now uses a POSIX relative path.
- `git diff --check`: passed. Shared changes in this follow-up are limited to progress sizing/alignment.
- Final single and multi PNGs inspected; every new SVG is non-empty with expected root dimensions (32×32 operations, 20×20 quick header, 70×70.5 quick artwork, 375×122 pattern).
- flutter_svg emits its existing unsupported `<filter/>` warning for exported artwork. AppServiceArtworkTile already draws the tile shadow in Flutter; that shared behavior was preserved.

No bank API, request execution, release build, emulator/device run or remote icon loading is validated by this UI suite. Large text within the unmodified fixed-size card, unusual long type labels and extreme viewport heights need future accessibility review.


### 16.4 Loans verification and review artifacts

`test/loans_screen_test.dart` contains eleven focused tests:
- Single and multiple native shared-card variants; reference y382/y570 group geometry and RTL ordering.
- Original Figma operation and quick artwork rendered in the existing grid slots.
- Actual foreground width, 8px height and physical-left origin for single and every selected multi loan.
- Indicator selection changes title, total, installment amount, count, due date and progress property.
- Every one of the six action callbacks receives the selected loan.
- Detail arrow receives that card's loan; no guessed detail route is opened.
- RTL swipe changes selection.
- Copy callback and platform clipboard preserve the original number, including leading zeros.
- Reordered inputs retain the selected ID at the correct visible page; removal and empty input are safe.
- All four tabs retain state; system back returns to Dashboard.
- Default menu catalog, supplied menu override, assistant transition, string-ID fallback, narrow320px viewport and1.4 text scale.

The existing deposit integration regression was updated only for the intended navigation change: tapping Loans now opens LoansTab instead of a service sheet. The menu still opens the filtered sheet when no menu callback is supplied.

[Loan review gallery](../loans-review/index.html), [single](../loans-review/phase1-single.png), [multiple](../loans-review/phase2-multi.png). Normal-reference renders use375×878 with simulated24px top and40px bottom safe areas. Native system bars are excluded. Remaining card/arrow/navigation differences are documented in Section 13.6; repaired progress is visible and count-based; the previews are not presented as pixel-identical Figma results.

```powershell
$env:UPDATE_LOANS_PREVIEWS = '1'
flutter test test/loans_screen_test.dart
```

- `flutter test test/loans_screen_test.dart`: all 11 tests passed; final single/multi previews generated and visually inspected.
- `flutter test`: all 119 app tests passed, including state/lifecycle/retry and deposit/loan navigation regressions.
- `flutter analyze`: no issues found.
- Original SVGs remain unchanged. This follow-up modifies the shared progress primitive and AppLoanCard alignment/default ratio.
- avp_ui full test suite: all 102 tests passed; primitive coverage includes zero/partial/full LTR/RTL fill geometry.
- Focused app model/screen suite: 13 tests passed (2 model + 11 screen).
- avp_ui and app analysis: no issues found.
- No device/release build, bank API, payment transaction, loan-detail screen or production permission/progress calculation is claimed. Progress rendering and count calculation are fixed; other Section 13.6 component differences remain unresolved.

### 16.5 Folder/state migration verification

The migration preserves existing frame geometry and selected action/copy/detail contracts. All 119 application tests pass; all 102 avp_ui tests pass. Both application and package `flutter analyze` complete with no issues. `git diff --check` passes.

Seven new unit cases in `test/dashboard/dashboard_tab_cubits_test.dart` cover all three item-tab lifecycle transitions, single/multiple classification, selection retention after reorder, empty/error/retry, immutable input snapshots/visibility, invalid IDs, thrown repository exceptions, latest-response ordering, completion after disposal and Home favorite transactions. Five new widget cases in `test/dashboard/dashboard_async_ui_test.dart` verify tab error/retry/empty rendering, usable navigation, delayed loan loading, repository replacement, safe disposal and switching to another tab while Home is failing. The UI test harness loads the actual package fonts.

Existing card/deposit/loan suites now inject MockDashboard*Repository objects instead of raw lists; the root seed convenience API remains covered. Dedicated feature folders contain no dashboard code/import shims. Source and documentation references are checked after the move, including relative gallery links. The existing previews remain design-review artifacts; this migration adds no new visual design or golden acceptance baseline.

These results do not validate a real endpoint, transport cancellation, persisted preference writes, permissions, remote icon loading or device font rasterization. The remaining Figma differences are registered in13.2–13.7.

## 17. Development and Code Review Process

The decision gate was completed before coding: both Figma frames were compared to shared AppDepositCard and AppPrimaryNavigation; the differences were disclosed; the user selected reuse without modification.

The current change moves Dashboard-owned files, adds domain/data/use-case/state layers, updates composition and tests, and relocates this document. Registered artwork and shared visual defaults are preserved. The progress follow-up changes only the shared progress primitive and AppLoanCard alignment; remaining retained differences are documented above.

Review should confirm:
- Action eligibility follows selected-deposit data, not number of cards.
- Dedicated callbacks preserve selected context.
- Unknown catalog IDs cannot be treated as valid navigation.
- No temporary Figma URLs appear in runtime code.
- ARB source and generated output agree.
- Component issues are accurately recorded, not silently corrected.

Existing review docs remain useful design evidence: [dashboard](../dashboard-implementation-review.md), [cards](../cards-implementation-review.md), [login](../login-implementation-review.md) and [shared mapping](../shared-component-figma-mapping.md).

## 18. Environments, CI/CD, and Release

Current entry point is lib/main.dart; this feature does not add development/staging/production entry points, secrets, environment configuration or a CI pipeline.

Run flutter gen-l10n after ARB changes, flutter analyze, and flutter test. Preview regeneration is opt-in by environment variable and should not run automatically in release packaging. The sibling package path is now relative and the analyzer portability warning is resolved.

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
7. Loans phase 1/2 designs are implemented. Supply loan detail/service-flow designs and authoritative eligibility, payment scope and progress semantics.

### 20.2 Recorded technical debt and risks

| Item | Impact | Recommended follow-up |
| --- | --- | --- |
| Deposit gradient/shadow mismatch | Accepted design difference | Opt-in reviewed variant/parameters; use existing bankCard shadow |
| Active deposit icon gray | Accepted navigation difference | Optional active asset mapping without replacing defaults |
| Persian labels inside shared card | Partial multilingual card support | Reviewed label/semantic parameters in shared component |
| Fixed shared card dimensions/text | Constrained large-text/long-string support | Shared accessibility review with focused tests |
| Enum-centric service catalog | New unknown actions cannot be rendered/executed automatically | Typed server catalog + allowlisted registry + fallback policy |
| Mock bank data behind repositories | Loading/error/empty contracts implemented; accounts still samples | Implement validated remote repositories and authentication |
| Fallback string service callback | Loses selected-deposit context | Require DepositActionRequest handler for real operations |
| Dashboard ownership | Tab cross-feature imports removed; standalone notifications routed through core | Keep dedicated feature pages independent of tab state |
| No persistent favorites/notifications/selection | State lasts only for widget lifetime | Caller/repository storage with privacy policy |
| Sibling avp_ui path dependency | Relative path is portable with expected sibling checkout; not a published package pin | Define workspace/package release setup for CI |

Loan progress sizing and physical-left alignment are fixed. Remaining follow-ups: review optional bankCard shadow, header geometry and blue arrow; add an active white Loans navigation asset; provide authoritative installment counts and action eligibility. The folder ownership and state/repository gaps are now resolved. Remaining package state/geometry differences from the new audit (13.7), live transport, server catalog mapping and persistence are open.

## 21. Change Log

| Version | Date | Changes |
| --- | --- | --- |
| 2.0.0 | 2026-10-09 | Move all tabs/entities/actions under Dashboard; introduce mock repositories, Result/use cases and immutable Equatable Cubits/states; move this document to doc/dashboard and repair links; audit every recently touched package visual/token and record remaining differences |
| 1.2.0 | 2026-10-09 | Fix shared foreground sizing; derive progress from paid/total; select physical-left loan fill; add model/geometry regressions and regenerate previews |
| 1.1.0 | 2026-10-09 | Add Loans phases 1–2, fourth retained tab, selected-loan callback/copy/detail contracts, original artwork inventory, transport readiness and shared-component issue register |
| 1.0.0 | 2026-10-09 | Register Dashboard current architecture; add Deposits phases 1–2 and selection-driven cheque UI; record shared component exceptions, exact icon sources, server-readiness matrix, proposed contract, state/data flows and verification |
