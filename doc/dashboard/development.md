# Dashboard development and review

Reviewed: 2026-11-01 — Cubit migration, phase 2.

The dashboard owns Home and the Cards, Deposits and Loans summary tabs. All four
share one HomeCubit/HomeState. Dedicated card/deposit/cheque and other service
flows retain their own feature scopes. Dashboard data still comes from mock
repositories; this phase adds no endpoint, banking operation or assistant backend.

The [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md), including the
2026-11-01 UseCase and independent-event clarifications, is authoritative.
Apply the [Cubit clean-code skill](../../.agents/skills/pishkhan-cubit-clean-code/SKILL.md).
Historical multi-Cubit layouts, repository constructor parameters, generation
counters, disposal guards and `.then` examples are superseded by the code and
rules described here.

## Approved notification model — implemented for this flow

The owner-approved [contract v1.20](../ui-cubit-state-agent-rules-en.md) uses
per-operation terminal status transitions for request feedback and independent
typed-effect execution. Failure/message may retain the latest recorded error;
there is no blanket clearing requirement. Success feedback, when required, uses
localized UI success text. Clears remain only for a real consumer/reset need.

The initial documentation-first rule is now implemented for this flow. Each
request-failure listener observes only its operation's entering-failure transition;
typed effects execute independently of retained message text. Existing success
behavior is preserved without adding new success toasts. Earlier phase test
results below remain historical; the notification migration has its own checks.

## 1. Ownership and scope

DashboardScreen directly constructs HomeCubit and calls `fetchDashboard()` in
BlocProvider.create. The router only selects the destination. Provider owns
closing; ordinary rebuilds preserve the instance and IndexedStack retains the
four tab widgets. Screen/panel/tab constructors take only super.key; data
repositories and UseCases are not passed through widgets or routes.

HomeCubit owns loaded summaries, selected records, privacy visibility, available
operation lists, favorites, drawer/picker search, prompt state and hint timing.
Flutter focus, PageControllers, image resources and background animation remain
owned by their widgets. State is plain data and contains no handwritten logic.

## 2. Files and dependencies

| Source | Responsibility |
| --- | --- |
| `lib/features/dashboard/domain/entities/` | Immutable summary entities, Home data and snapshot contract |
| `domain/repositories/dashboard_repositories.dart` | Four repository interfaces and the existing DashboardRepositories bundle |
| `domain/usecases/home_usecase.dart` | LoadDashboardHomeUseCase and typed LoadDashboardItemsUseCase |
| `data/datasources/dashboard_mock_data.dart` | Local fixtures |
| `data/repositories/mock_dashboard_repositories.dart` | Four mock adapters |
| `presentation/home/cubit/` | HomeCubit, plain part-of HomeState.initial and typed HomeEffect |
| `presentation/home/screens/` | DashboardScreen, catalog page and three banking tabs |
| `presentation/home/widgets/` | Home composition, carousels, service groups, drawer and favorite picker |
| `presentation/shared/` | Service/action/category definitions and shared dashboard visuals |
| `lib/core/di/injection_container.dart` | Dependency registration and UseCase constructor wiring |

The four repository interfaces and bundle remain lazy singletons. The two
UseCase classes have explicit UseCase suffixes. DI registers Home plus three
typed item UseCases (BankCard, BankDeposit and BankLoan). Their factory lifetime
matches the previous per-Cubit UseCase construction: each new Home scope resolves
its own stateless instances and retains them in final fields. A retained Cubit is
not rewired by changing a registration. Cubit no longer holds the repository
bundle or constructs UseCases; Domain has no GetIt dependency.

Tests configure production registrations, install controlled repositories before
Cubit construction, close test-owned Cubits and reset GetIt. There is no
production changeRepository API or Cubit factory/registration for tests.

## 3. Operation inventory

| Operation | Owner | Triggers and publication |
| --- | --- | --- |
| Home content | fetchHome | Initial fetchDashboard and Home retry; homeStatus, data and service lists |
| Cards | fetchCards | Initial fetchDashboard and Cards retry; cardsStatus, immutable cards, selection/actions/privacy |
| Deposits | fetchDeposits | Initial fetchDashboard and Deposits retry; depositsStatus, selection/actions/cheque capability |
| Loans | fetchLoans | Initial fetchDashboard and Loans retry; loansStatus, selection and action lists |

fetchDashboard awaits Future.wait of these four owners, preserving concurrent
startup. Each owner has one UseCase call, one await and one Result switch. Loading
is emitted before invoking the UseCase. Each completion copies the current State,
so another operation's response, selected tab or favorite edit is not overwritten.
There are no request-ID counters: no new overlap policy is introduced.

## 4. User path and State readers

| Step/event | Readers | Retention and next step |
| --- | --- | --- |
| Enter dashboard | Status-driven Home and tab sections | Four independent reads start; one failure does not erase another section's data/status. |
| Open a banking tab | Tab, carousel and service groups | selectedTab changes; other selections, drafts and privacy survive. |
| Retry banking data | Tab loading/empty/error branches and selection reconciliation | Old visible list/selection/actions are invalidated by the owner; success restores the prior selection by ID when available, otherwise first item. |
| Select a card/deposit/loan | Carousel and operation groups | Cubit stores the rendered object and its index together; the next action uses that selected record. |
| Edit favorites | Home service editor, limit notice and add control | Saved favorites remain in homeData; draft list and flags change. Empty saved favorites start from suggestions, capped at eight. |
| Apply / Cancel / Reset | Home service section | Apply commits draft locally; Cancel restores saved IDs; confirmed Reset clears saved/draft favorites. No server save exists. |
| Favorite picker | Home-owned sheet query, groups, collapse and selection | Opening resets picker inputs; selected favorites are disabled; dismissal retains the draft. |
| Drawer | Home-owned groups/query/selection | Opening resets the drawer; raw result returns to Cubit for Home/service intent. |
| Prompt / motion | Banner input, typing hint and background animation | Cubit owns eligibility/typing; UI executes focus and animation using prepared State and Flutter lifecycle inputs. |
| Navigate/copy/open sheet | Focused HomeEffect listeners | Reusable commands are consumed before Flutter work; no sequence counters. |

Home loading now omits five redundant clears: homeData, favoriteServices,
fixedServices, canAddFavorite and isFavoritesLimitReached. Home content is gated
by homeStatus while pending/failed, and the success action replaces all five
before the next content step reads them. isEditingFavorites still resets at the
fetch boundary. Banking invalidation remains because selection reconciliation,
action availability and the carousel depend on a consistent loading snapshot.

## 5. Favorites and independent events

`openFavoritesEditing`, `addFavorite`, `removeFavorite`, `applyFavorites`,
`cancelFavorites` and `resetFavorites` are specific actions. The former
beginFavoritesEditing name and all callers now use the approved open vocabulary.

The owner explicitly approved retaining their individual emits even where field
names overlap. Fetching, opening, adding, removing and cancelling are independent
events; they are not routed through a fabricated publication action. Repeated
capacity predicates use `_canAddFavorite` and `_isFavoritesLimitReached`.
Calculations return values, never State. The same rule applies to future phases.

The limit stays eight. Unsupported/duplicate IDs and ordering retain existing
behavior. Picker results and reset confirmation are interpreted in Cubit. No
new persistence or server capability is inferred from local customization.

## 6. Selection, privacy and actions

The shared pure `_findRetainedSelection` calculation keeps a matching ID or
selects the first remaining record. `_selectedItemIndex` returns its list index
or the empty default. `_hasSelection` supplies repeated availability predicates.
No helper constructs or publishes State.

Card visibility remains per ID and is reconciled against the fetched cards;
single-card data defaults visible and multi-card data defaults hidden. The
selected card's canSetSecondPin determines its PIN operations. Cheque operations
follow the selected deposit's hasChequeOperations, independently of list length.
Loan operations retain selected BankLoan context. Copy effects carry original
number/IBAN strings; UI executes Clipboard.setData.

## 7. Prompt and lifecycle

Prompt submission stores trimmed text and a typed effect, retaining the existing
unavailable feedback. It does not contact an assistant service. Drawer and picker
normalization/filtering remain in Cubit and keep their existing search behavior.

The hint clock preserves its 90ms grapheme-aware typing/erasing cadence and hold
periods. Pure predicates determine motion permission, foreground availability and
whether typing may run without focus/input. These results are explicitly emitted
by the input/lifecycle actions. The timer helper only starts/cancels its resource;
close cancels it. UI retains focus, reduced-motion/TickerMode observations, image
decoding resources and background animation. No closed/disposed guard or parallel
flow notifier is introduced.

## 8. Failures and loading

Independent home/cards/deposits/loans statuses use the existing RequestStatus.
Loading retains the latest failure/message. Err publishes its own failure status
and Persian message prepared by the core Presentation mapper. Four focused failure
listeners
observe entering-failure status transitions, so concurrent failures and repeated
identical retries each notify. The independent typed-effect listener executes
commands without reading or clearing an old message. HomeCubit now has no
failure/message null-clears; unrelated data/selection resets are unchanged.

UseCases preserve repository Err values and catch unexpected exceptions through
the existing UnexpectedFailure boundary. Item loads reject blank/duplicate IDs
and detach immutable snapshots. Empty lists and Home Success(null) remain valid
empty results. There is no fabricated sample fallback on failure.

UI owns pending interaction and Back gates; Cubit does not repeat them. State
continues to have a single `.initial` Freezed factory, part-of layout, generated
equality and disabled generated string output. There are no State getters or
new status aliases.

## 9. Navigation and integration limits

Home effects request sheets, clipboard, focus and supported service destinations.
The central AppRoutes/GoRouter and existing service navigation adapter translate
those intents into routes, retaining selected card/deposit input. System Back
from a banking tab returns to Home; Back during favorite editing cancels its
draft. All pending operations gate Back through UI. Unsupported service/profile,
loan-detail and assistant actions keep their existing unavailable behavior.

Notifications retain the existing Home-owned list and raw change callback through
the core navigation adapter. Their separate profile feature is migrated in its
own phase. Dashboard data/favorites remain local mock state; no durable favorite
save, remote catalog, icon policy, extra guards or bank endpoint is implemented.

## 10. UI, assets and localization

Use package:avp_ui/avp_ui.dart and AppTheme.light. UI reads S.current from generated
intl_utils resources in lib/generated; fa/en/ar ARBs are under lib/l10n. App assets
use AppConstants.baseImage. Controls, numeric copying, carousel geometry and
semantic colors retain their current behavior. Financial summaries still contain
prototype display strings; live money/date mapping needs a confirmed bank schema.

Known source/Figma differences are preserved in Section 13. This refactor changes
no shared component, asset, spacing, typography or design-system default.

## 11. Verification

Baseline: 116 tests passed using test/dashboard, test/core/di, test/core/router
and test/app_drawer_test.dart. Final validation also includes Login, token storage
and network regressions because the shared DI registrations changed.

```sh
flutter analyze
flutter test test/dashboard test/core/di test/core/router test/app_drawer_test.dart test/auth test/core/security test/core/network
```

The additional scope-isolation test constructs two Home Cubits with different
repositories, then fetches both after the second registration. Each must use its
own retained UseCases. Existing tests cover concurrent responses, repeated errors,
selection/reorder/empty/retry, favorite transactions, picker search/collapse,
clipboard, navigation, loading/Back, prompt motion and RTL/geometry.

No real banking request, device/release run, browser execution or fresh Figma
comparison is part of this verification. The native suite skips the existing
Web-only token-store case.

### Phase-2 verification results — 2026-11-01

| Check | Result |
| --- | --- |
| Baseline dashboard/DI/router/drawer suites | 116 passed |
| Expanded dashboard + auth/security/network regression suites | 218 passed, 1 Web-only skip |
| Final Home/banking Cubit rerun after shared search normalization extraction | 23 passed |
| Final flutter analyze | No issues |
| git diff --check | Passed |

The final focused rerun uses
`flutter test test/dashboard/presentation/flows/home/cubit test/dashboard/presentation/flows/banking_overview/cubit`.
The additional test verifies dependency isolation between two Home scopes.

### Phase-1 and phase-2 re-review after filename clarification

Contract v1.19 makes `_usecase.dart` mandatory for UseCase source filenames.
Dashboard now uses `domain/usecases/home_usecase.dart` and Login uses
`domain/usecases/login_usecase.dart`; Cubit, DI and test imports are updated.
The class grouping, registered UseCases and their lifetimes remain unchanged.

Both phases were re-reviewed against the updated contract and skill: naming,
DI boundaries, Provider ownership, plain State structure, independent statuses,
single request owners, explicit emits, pure calculations, effects, validation,
flow-aware clearing and the approved independent-event rule. The existing DI
test's isClosed assertion was removed in favor of its State/fetch behavior checks.

The combined native suites above passed 218 tests with the same one Web-only
skip; flutter analyze and git diff --check passed. No further request or State
changes were needed for the filename correction. Future phases apply the same
filename suffix within their authorized scope.

Duplication review: 0 new repeated blocks found, 0 resolved. Flow review: 0 new
clears added or removed in this re-review.

### Phase-2 duplication and flow review

| Repeated responsibility | Resolution |
| --- | --- |
| Retain selection by ID / first-item fallback | `_findRetainedSelection` |
| Empty-aware selected index | `_selectedItemIndex` |
| Selection-dependent action availability | `_hasSelection` |
| Favorite add capacity | `_canAddFavorite` |
| Favorite limit notice | `_isFavoritesLimitReached` |
| Hint typing eligibility | `_canTypeHint` |
| Motion availability in foreground | `_isMotionEnabled` |
| Persian/Arabic search-character normalization | `_normalizeSearchCharacters`, with each search's trim/case/whitespace order preserved |

Overlapping favorite field groups remain explicit under the owner's approved
independent-event clarification. Each of the four requests has one owner, one
UseCase call and one Result switch. No State-publication intermediary exists.

Duplication review: 8 repeated calculation/predicate families found, 8 resolved;
independent-event emits retained under owner approval. Flow review: 5 redundant
Home loading clears removed; banking selection/action invalidation preserved.

## Status-driven notification migration — phases 1 and 2

The approved v1.20 model is now implemented for Login and Dashboard. Each request
has its own focused entering-failure subscription, while the existing typed-effect
listener executes independently of retained error text. No success toast was added;
Login completion and existing service feedback retain their previous behavior.
State structure, UseCases, payloads, routing and unrelated resets are unchanged.

Across the two Cubits, 35 legacy null-clears were removed. CAPTCHA's existing
failure clear is retained to dismiss guest change-phone's inline notice; the
inline-only unavailable branch now explicitly clears message so it cannot reuse
an earlier API message when its legacy OTP failure status changes. The Auth
failure-display method accepts the absent payload only after a status-triggered
subscription. Its effect handler never inspects message. Final explicit null
assignments for failure/message total 2, down from 36.

Behavioral checks cover identical retry errors, retained text without replay on
input/loading/success, OTP focus and completion after failure, menu opening after
failure, concurrent dashboard errors followed by another operation's success,
and guest inline feedback/refresh. The dashboard test scope was updated to keep
request feedback separate from adapted host effects as well.

Verification: 76 focused tests passed; the expanded phase-1/phase-2 regression
command passed 220 tests with 1 Web-only skip. Flutter analyze reported no issues;
git diff --check passed. Synthetic transports/repositories were used; no live-bank,
browser or device acceptance run is claimed.

```sh
flutter test test/dashboard test/core/di test/core/router test/app_drawer_test.dart test/auth test/core/security test/core/network
flutter analyze
```

Duplication review: 0 new repeated operations found, 0 resolved; all 7 request
owners remain unique. Flow review: 35 clears removed, 1 inline-feedback clear
retained and 1 inline-only payload clear added. No other reset group was changed.

## 12. State Management with Cubit

This section preserves the previous documentation link target. HomeCubit and
HomeState under presentation/home/cubit own all four tabs. Independent request
owners and final registered UseCase fields are described in Sections 2–3;
State readers and retention are in Section 4. There are no per-tab Cubits,
nested State families, changeRepositories action or constructor initialization.

## 13. Design System Package (`avp_ui`)

The detailed comparison below is retained historical evidence from 2026-10-09.
Phase 2 changes no shared visuals or package APIs and performs no new Figma audit.
Do not read historical verification claims as results of this Cubit refactor.
Current component source and the integration guide remain the API authority.

### 13.1 Ownership and reuse

| Owner | Used components / tokens | Location |
| --- | --- | --- |
| avp_ui | AppTheme, context.colors, AppTypography, AppSpacing, AppRadius, AppShadows, AppDashboardColors, AppLoginColors | External `avp_ui/lib/tokens/`, `theme/`, `extensions/`, exported by avp_ui.dart |
| avp_ui | AppButton, AppSearchField; shared components also compose package primitives | Public `package:avp_ui/avp_ui.dart` |
| App shared | AppLoanCard, AppArrowButton; loan card composes avp_ui AppProgressIndicator | `lib/shared/widgets/app_loan_card.dart`, `app_arrow_button.dart` |
| App shared | AppDepositCard | `lib/shared/widgets/app_deposit_card.dart` |
| App shared | AppPrimaryNavigation / AppPrimaryTab | `lib/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart` |
| App shared | AppTopBar | `lib/shared/widgets/app_top_bar.dart` |
| App shared | AppServiceGridCard, AppServiceGridItem, AppServiceGridItemView | `lib/shared/widgets/app_service_grid_card.dart` |
| App shared | AppServiceArtworkTile | `lib/shared/widgets/app_service_artwork_tile.dart` |
| App shared | AppAssistantButton, AppAssistantIcon | `lib/shared/widgets/app_assistant_button.dart` |
| App shared | AppWalletCard, AppBottomSheetHeader, AppResalatCard | Corresponding files in `lib/shared/widgets/` |
| Feature local | DashboardBankServices, DashboardServiceTile, DashboardResoBanner, catalog/sheet headings | `lib/features/dashboard/presentation/shared/widgets/` |
| Feature local | DepositsTab group/carousel composition, DepositAction mappings | `lib/features/dashboard/presentation/home/screens/` and `home/widgets/` |
| Feature local | LoansTab group/carousel composition, LoanAction mappings | `lib/features/dashboard/presentation/home/screens/` and `home/widgets/` |

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

Source: `lib/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart`. The deposit branch always resolves `${AppConstants.baseImage}dashboard_nav_deposit.svg` -> `assets/images/dashboard_nav_deposit.svg`. There is no active/inactive branch for that tab.

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

**Scope and evidence.** The working package diff contains the earlier bankCard token addition and the progress repair. The recent integration commits also touched AppButton, AppTextField/AppSearchField, AppTypography, AppDashboardColors and AppLoginColors, so these are audited here rather than considering only today's dirty files. Package public exports, integration-guide edits and regression tests have no separate visual agent. No shared visual default is changed by the folder/Cubit migration.

The comparison uses freshly retrieved Figma design context and screenshots, then the actual package source, not names such as “Figma-aligned” in Dart comments. Button and input sets returned sparse metadata; individual variants were subsequently fetched. References below are all in [Pishkhan AI Mobile](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile). This is a source/token and rendered-frame review, not a claim of exhaustive pixel equality for every library variant.

| Changed component/source | Figma reference and verified properties | Remaining difference / recommendation |
| --- | --- | --- |
| AppProgressIndicator — avp_ui/lib/widgets/loaders/app_progress_indicator.dart | Linear progress set [15992:142102](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=15992-142102); loan [27902:82623](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82623). Height8, radius4, track #F5F5F5, foreground #1570EF; no gradient/shadow. Foreground now receives full height and proportional width. AppLoanCard's explicit centerLeft gives the Figma physical-left origin in RTL. Actual zero/partial/full geometry and every loan fixture are tested. | Count-based widths intentionally replace Figma's inconsistent sample percentages (Section 13.6). The broader primitive is not exact in all label variants: right-label design has a total320px row with a flexible shorter track; current width320 means track-only plus12px gap and label. Generic RTL default begins at directional start; Figma samples begin physically left. Some Figma0% variants retain an8px stub; app0 is genuinely empty. Floating tooltips use hardcoded offsets/clamps instead of fully matching all endpoint tooltip geometry. These untouched variants need a reviewed compatible API/layout fix; they are not used by loan cards. AppProgressCircle shares the file but its painter/layout were not changed and are not certified by this audit. |
| AppButton — avp_ui/lib/widgets/buttons/app_button.dart | Button set15699:34979; fetched [sm active15699:34995](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=15699-34995), md active15699:35395, xl active15699:36195, disabled15699:35035, focused15699:35515, text15699:35715 and loading15705:63267. Heights36/40/44/48, horizontal default padding18/20/22/24,20px icons,8px gap, radius8. Primary active #1570EF/white and xs shadow match. Type sm12/18 Medium; md/lg14/20 DemiBold; xl16/24 DemiBold. Additive horizontalPadding/foregroundColor parameters retain default behavior. Foreground overrides are deliberately ignored when disabled. | Disabled source removes xs shadow although inspected Figma disabled retains it. Focus source uses active brand/error color at .28 alpha, while Figma primary focus ring is opaque #E4F3FF,spread4. Loading source is disabled gray with spinner-only; Figma loading is #175CD3, xs shadow, label plus20px loader. Text-only source retains standard36/40/44/48 hit-area height/padding; Figma visible md text row is20px high. Source has Material splash/hover behavior, not an exact Figma motion specification. Review optional styling states/visible versus accessible hit bounds; do not silently alter other consumers. |
| AppTextField — avp_ui/lib/widgets/fields/app_text_field.dart | Input set15652:17725; inspected [regular active15652:17946](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=15652-17946), focused15652:26618 and focused/error15652:28442. Single-line44px, radius8, horizontal14px/vertical10px padding; label14/20 Medium,8px vertical gaps, body16/24 Regular, helper14/20 Regular. Active white/#D5D7DA/xs, focused #1570EF border, error #FDA29B and #F04438 helper match those source values. Added textStyle/onSubmitted/digit normalization are opt-in behavior; no new icon asset is embedded in the field. | Focused Figma variants inspected have xs only; source adds2px or4px primary/error ring. Regular Figma leading icon is a20px icon after8px gap; source uses Material prefix/suffix slots min48×44, so exact content positions need a variant-level layout review. Figma helper can include14px question icon and8px gap; source only displays helper text. AppTextArea delegates to the same field but was not separately changed/certified. AppTextField's fixed44px single-line height remains a large-text constraint. |
| AppSearchField — same package field file | Search set [15807:44137](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=15807-44137) includes Active/Hover/Focused/Disabled/Filled/View Only with default/error feedback. Verified44px/radius8, active white/#D5D7DA, hover #A4A7AE border with gray1004px ring, error hover #F97066/#FEE4E2 ring; filled text #181D27; view-only #FAFAFA/#414651; active-error #FFFBFA. clearIcon/searchIcon slots allow existing exact app SVGs instead of forced Material glyphs. | Generic search active hint uses #A4A7AE through AppTextField, while Figma search hint is #717680. Focus adds a source primary/error ring absent from Figma focused search. Default disabled text #A4A7AE matches its inspected text; icon-color differences remain where Figma has #535862. Material default search/close glyphs are not the authored Figma SVGs; Dashboard supplies ${AppConstants.baseImage}dashboard_catalog_search.svg and dashboardSearchClear. Dashboard intentionally supplies14/20 text and subtle2px ring for its frame instance, rather than the generic16/24 design-set type. Clear IconButton uses Material hit-area behavior, not a fixed20px visible slot by itself. The Persian clear tooltip is still package-owned. |
| AppTypography — avp_ui/lib/tokens/app_typography.dart | Inspected Button/Input and Dashboard frame typography uses IRANYekanXFaNum at12/18,14/20,16/24, zero tracking; weights Regular400/Medium500/DemiBold600. defaultFontFamily now resolves packages/avp_ui/IRANYekanX, whose font files are declared in avp_ui/pubspec.yaml. The changed family path matches the actual package registration; tests load Regular/Medium/DemiBold/Bold fonts. | Tokens still include Material-scale defaults that need explicit line-height/tracking overrides for individual Figma instances; package font-path correction does not make every text style exact. Static widget tests verify metrics with production fonts; native font rasterization/browser/platform differences are not certified. |
| AppShadows.bankCard — avp_ui/lib/tokens/app_shadows.dart | Fresh Cards27902:82533 and Loans27902:82623 contexts confirm two layers: #0A0D121A offset(0,4),blur8,spread+2; #0A0D120F offset(0,2),blur4,spread+2 (Figma RGBA hex). Token uses correct Dart ARGB 0x1A0A0D12 and0x0F0A0D12. Existing AppResalatCard applies this matching elevation. | AppDepositCard and AppLoanCard still use md, not bankCard. Their exact mismatch is documented in13.3/13.6. md was not globally corrected; its unusual literals/spread remain pre-existing. |
| AppShadows focus-ring additions — same token file | Search hover Figma gray100/error100 rings have4px spread,zero blur/offset plus xs alpha. Source focusedGray4px #F5F5F5 and focusedError4px #FEE4E2 match those effect numbers. Button-focused Figma token #E4F3FF matches focusedPrimary4px's color/spread. | AppButton does not consume the matching focus token. AppTextField applies a primary/error ring to focused variants where retrieved Figma has xs only.2px variants support existing instance customization but are not demonstrated by the generic4px set; use only for reviewed instances. Shadow-list order differs from returned ring-first context and should be render-reviewed when changing ring composition. |
| AppDashboardColors — avp_ui/lib/tokens/app_dashboard_colors.dart | Dashboard27902:80847, favorite editing27902:81700, all-services27902:82267 and shared nav frames. Verified service #181D27, section #24292E, tile gray25 #FDFDFD; favorites blueGray50 #F8F9FC, border blueGray200 #D5D9EB, action blueGray600 #3E4784, optionText blueGray700 #363F72, categorySearch blueGray500 #4E5BA6, muted gray500 #717680; hero brand900 #194185, gray600 #535862; nav brand500 #2E90FA; assistant pink500 #EE46BC; editor warning25 #FFFCF5/warning200 #FEDF89; add success50 #ECFDF3/success400 #32D583/success500 #12B76A. | This token file has no sizes, icon geometry or gradients of its own. Hero haze animation colors are semantic inputs; they do not reproduce the exported baked artwork's full gradient/lighting exactly. Scrim #101828 is an overlay input with instance opacity/blur; screenshot resemblance alone does not certify compositing. Existing shared nav/card differences remain. |
| AppLoginColors — avp_ui/lib/tokens/app_login_colors.dart | Earlier integration touched login colors; inspected Login27847:4237 and guest-services27847:4724. Canvas gray25 #FDFDFD, notice warning100, notice text #383F45, muted service gray600 #535862 and section #24292E correspond to instance design colors. | serviceLabel #394047 is a sampled/custom instance color rather than a named palette style in the retrieved set. These tokens have no geometry/state/gradient of their own; this review does not certify every auth screen state. Existing login UI remains outside this Dashboard migration. |

**Changed parameters in actual consumers.** DashboardBankServices uses foregroundColor for blue-gray favorites actions and horizontalPadding2/8/0 for compact text controls; the service sheet injects the registered search/clear SVGs. AuthOtpForm uses horizontalPadding4. These additive overrides leave other package defaults intact. Current asset switches live in presentation/shared/dashboard_services.dart and the card/deposit/loan action files; inspect those sources for runtime mappings.

**Conclusion and follow-up scope.** The progress repair and the bankCard token values are verified for their target instances. Remaining button/input/progress-label state differences and shared card/nav issues are explicitly open. This task neither replaces existing components nor introduces duplicate Figma-only components. Future fixes should add reviewed variants/parameters, validate both old and new consumers, and update this audit after source and rendered comparisons. No claim that the whole avp_ui library is “exactly Figma” is supported by the inspected evidence.

### 13.8 Standalone Cards flow integration (2026-10-09)

The dedicated Cards flow now lives under features/cards, separately from Dashboard's carousel. The core routing bridge opens it for card-list/card-virtual/card-expired-gift when no host service override is supplied. Reviewed additive shared/package parameters preserve existing Dashboard defaults. See [Cards architecture and current component audit](../cards/card-services.md) for the new colored AppCardsList variant, configurable back/sheet actions, compact selectors/search, AppChips, footer styling and recorded backdrop SVG limitation.
