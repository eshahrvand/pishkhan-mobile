# Cards Features Development Document

**Project:** Pishkhan AI / Smart Virtual Counter  
**Version:** 1.1.0<br>
**Date:** 2026-11-01<br>
**Status:** Connected UI flow with mock repository; bank execution is not connected.  
**Architecture reference:** [Project architecture](../architecture-smart-virtual-counter-v2-en.md)  

This document follows the project's 21 architecture sections. This is the standalone Cards feature. The Dashboard card carousel remains owned by Dashboard and has a separate model/repository/Cubit.

## 1. Architectural Goals and Principles

The six original design states form one Cards flow: five categories share search, filtering, list rows and contextual actions. Details and filter sheets operate within the same route. No duplicate list, input, button or sheet-header component is created.

The component decision was reviewed before code. The user chose compatible variants/parameters and the missing package Chips component. Existing defaults are preserved; the colored list/header and compact filter styling are opt-in.

## 2. Product Scope and Target Platforms

| Phase/state | Figma node | Implemented behavior |
| --- | --- | --- |
| 1: Resalat list | 27997:10059 | Four mock rows, category strip, search, filter, assistant |
| 1: Features sheet | 27997:11392 | Details, reissue, change linked deposit, block; selected-card context |
| 1: Details sheet | 27997:11463 | Number, IBAN, linked deposit, deposit type, expiry, status; Back |
| 2: Filter, all | 27997:11531 | Status and deposit selectors; Apply |
| 2: Filter selections | 27997:11563 | Draft selections, red Remove filter action, apply/cancel |
| 3: Gift | 27997:11288 | Pink headers, four rows, expired-gift-balance action |
| 4: Virtual | 27997:11316 | Amber headers, four rows, virtual-card request action |
| 5: Bon / coupon | 27997:11344 | Rose headers, two rows, no category footer |
| 6: Family | 27997:11368 | Green headers, two rows, no category footer |

All node references belong to [the supplied Figma file](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27997-10059). App controls are RTL-first on all locales. Native status/navigation bars are outside the UI implementation; review images reserve 24px/40px safe areas without drawing native system controls.

The four banking-feature rows are reused when opening a card's menu. Only the Resalat menu is authored in the supplied designs; category-specific future eligibility must come from bank requirements rather than inferred card colors.

## 3. Technology Stack

Flutter Material composition, flutter_bloc Cubit, Equatable domain entities and Freezed Cubit State, core Result/Failure, public avp_ui primitives, app shared visuals, flutter_svg, and generated fa/en/ar ARB localization. No new dependency is added.

## 4. Development Environment and Versions

Existing pubspec.yaml/pubspec.lock and analysis_options.yaml govern versions. avp_ui is the sibling path dependency ../avp_ui. ARB localization is consumed through generated `S.current`; generation follows the current project configuration. The feature uses the current repository's Flutter SDK; no SDK migration or platform build is part of this change.

## 5. Third-Party Dependency Governance

Existing dependencies suffice. New package APIs are additive, public-barrel exported and regression-tested. No HTTP or caching package is introduced. Direct imports of avp_ui internals are not used by the main app.

## 6. Project Structure and Modularization

```text
lib/features/cards/
  cards.dart
  domain/entities/                              ListedCard, CardFilter
  domain/repositories/cards_repository.dart      CardsRepository.getCards
  domain/usecases/card_features_usecase.dart     LoadCardsUseCase
  data/repositories/mock_cards_repository.dart   mock summaries and Result adapter
  presentation/card_features/
    card_feature_action.dart                    typed action/request contract
    cubit/card_features_cubit.dart               operation, inputs, pure calculations
    cubit/card_features_state.dart               part of Cubit, plain Freezed State
    cubit/card_features_effect.dart              prepared typed interactions
    screens/card_list_screen.dart                Provider, listeners, route composition
    widgets/                                    filters, list, sheets and display helpers
lib/core/di/injection_container.dart             Repository and UseCase registration
lib/core/router/card_features_navigation.dart    allowlisted route bridge
lib/shared/widgets/                             shared app composition
lib/generated/l10n.dart                          generated S localization access
lib/l10n/app_{fa,en,ar}.arb                       feature copy
test/cards/presentation/flows/card_features/      Cubit, widget and repository fixtures
```

Dashboard entities/actions/Cubits stay under features/dashboard. ListedCard is a standalone list summary, not Dashboard BankCard. Common visuals remain shared or package-owned. Dashboard calls the core routing bridge instead of directly importing standalone feature UI.

## 7. Layering Pattern (Clean Architecture)

**Domain:** ListedCard and the category/status enums have no Flutter imports. ListedCard extends Equatable and is immutable. Repository returns Future<Result<List<ListedCard>>>. LoadCardsUseCase catches unexpected transport exceptions and rejects duplicate/blank IDs before returning an immutable list.

**Data:** MockCardsRepository implements the interface. Defaults create 4 Resalat, 4 Gift, 4 Virtual, 2 Bon and 2 Family cards. Cards at index3 have another linked deposit and blocked status to make filtering observable; other mock cards are active. These are samples, not actual user accounts. Numbers and dates remain display-ready prototype strings.

**State:** CardFeaturesCubit invokes LoadCardsUseCase. CardFeaturesState and CardFilter use value equality and immutable card lists. Controls derive content from the state rather than widget-local business variables.

**UI:** Screen/sheets compose public AppButton, AppChips, AppSearchField, AppSelect, AppCardsList, AppTopBar, AppBottomSheetHeader and AppAssistantButton. TextEditingController, ScrollController and modal resources remain in the view. No manual widget keys are created in Cards presentation. Category visibility uses a local Builder context with Scrollable.ensureVisible. `CardListScreen` directly constructs Cubit in `BlocProvider.create` and calls `fetchCards`; Provider owns closing. `BlocProvider.value` only shares that instance with the filter sheet. Ordinary rebuilds retain the same flow. Tests locate controls by public widget properties, content and structure.

```text
MockCardsRepository / future live adapter
  -> CardsRepository
  -> LoadCardsUseCase
  -> CardFeaturesCubit
  -> immutable CardFeaturesState
  -> CardListScreen + sheet composition
  -> shared widgets + avp_ui
```

## 8. Service Flow Pattern and Suspended Requests

```text
Dashboard catalog -> card-list -> CardListScreen(Resalat)
                    card-virtual -> VirtualCardRequestScreen
                    card-virtual-list -> same screen(Virtual)
                    card-expired-gift -> same screen(Gift)
category chip -> selectCategory -> filtered summary list/footer
search -> query -> list
filter button -> draft copy of committed filter
  status/deposit dropdown -> draft only
  Apply -> commit filter -> close sheet -> list changes
  Remove filter -> clear draft -> Apply commits clearing
  system back/outside tap -> discard draft
row More -> requestCardActions(rendered card) -> actions sheet
  Details -> details sheet -> Back -> list
  other action -> CardFeatureRequest(action, card, category) -> host
category footer -> CardFeatureRequest(action, category, card:null) -> host
assistant -> host override / return to dashboard prompt
```

The screen exposes initialCategory, onActionRequested and onAssistantPressed. Cubit resolves its registered `LoadCardsUseCase` once in a final field; DI wires `CardsRepository` into the UseCase; no repository is passed through the screen. Initial category is applied on the first fetch only; subsequent category choices belong to Cubit and survive retries.

Reissue, change-deposit, expired-gift and virtual-request use their existing
mock service routes when no host override is supplied. Block remains unavailable
without host integration. Category footer requests have no arbitrarily selected
card. These paths do not claim live bank execution; see their individual flow docs.

No suspended bank request or idempotent submission is implemented. Filter drafts are local UI transactions.

## 9. Security and Compliance Layer

No bank transaction, blocking operation or transfer is performed. Showing/enabling an action is not proof of bank eligibility. Production service APIs must validate ownership, authorization and current account state. A contextual request contains the selected summary snapshot; it must be revalidated before an actual banking operation. No financial data is written to disk by runtime UI.

## 10. Network and Authentication Layer

The real service replaces MockCardsRepository through the CardsRepository registration in GetIt before a fresh flow scope is created. The screen does not receive a repository and the Cubit has no runtime repository-replacement action.

Recommended adapter locations: data/datasources/, data/dto/, data/mappers/, data/repositories/. They are not created with fictitious endpoints. A mapper should preserve string numbers/IBANs and leading zeros, validate unique IDs, decode category/status keys, format dates/amounts consistently, and return Err for a request failure. Success([]) is genuinely empty data.

| Current field | Source/use | Future mapping |
| --- | --- | --- |
| id | mock stable identifier; selection/equality | opaque server ID |
| category | CardCategory enum; chips, icon/header/footer | validated type key; unknown type omitted/reported |
| number | original string; shown and searchable | preserve string; never parse to integer |
| linkedDeposit | original string; details/search/filter | validated stable deposit reference/display mapping |
| iban | original string; details | validate/preserve raw string |
| expiry | formatted mock Jalali string | service date -> display formatting |
| depositTypeKey | qarz mock key, localized known type | supported product/type-key registry |
| status | active/blocked/expired enum; details/filter | known service status with explicit unknown handling |
| action availability | local four-row menu/category footer | reviewed per-card capability/action set; not currently modeled |
| icon/tint/title | local enum + direct image paths + ARBs/package tokens | app-owned supported registry; future catalog cannot execute arbitrary routes |

No remote icon renderer, metadata-driven visual template or permission filter is present. The current mock data varies by ID/status/deposit; supplied Figma account numbers are illustrative and some mock row values intentionally differ.

## 11. Error Handling Pattern (Result & Failure)

LoadCardsUseCase preserves Err failures and maps unexpected exceptions to UnexpectedFailure. Invalid IDs produce DataFailure('cards.invalid'). Cubit publishes `cardsStatus: failure`, the Failure and `getRequestErrorMessage(failure)` together. A focused status listener displays that prepared text; codes are never shown directly. Failure/message retain the latest recorded error after loading, recovery and commands. They do not describe current request status or gate typed effects. Initial/loading, empty repository and zero search/filter results are separate outcomes. Error content hides old list/action rows rather than implying stale eligibility.

## 12. State Management with Cubit

The plain Freezed `CardFeaturesState.initial` stores `cardsStatus`, immutable cards, category, searchQuery, committed filter, nullable draftFilter, selectedCard, footerAction, typed effect and shared latest failure/message. Its `part of` organization is preserved. RequestStatus is initial/loading/success/failure. visibleCards combines category AND committed filter AND normalized query. The repository's empty state is distinct from a loaded dataset with no matches.

CardFilter contains nullable status/deposit; null means All. Dropdown selections use stable enum names/raw deposit values, not localized strings. Persian and Arabic digits normalize to Latin; spaces, hyphens, dots and ZWNJ are ignored for search. Original display values remain unchanged. Search applies to card number and linked deposit.

`fetchCards` owns the complete async/await lifecycle and `switch (result)`.
It resolves the entry category/footer on the first fetch only. On completion it
filters with the current category/query/committed filter, resolves the selected
card from fresh data by ID and prepares sorted unique deposit numbers. Retry
preserves user selections. There is no list-fetch request ID or disposal guard;
normal UI exposes retry after failure. Do not claim newest-fetch-wins semantics
for arbitrary overlapping programmatic list reloads.

Category/filter changes clear the old selectedCard because the active list has
changed. Apply commits the draft and clears it; cancellation clears only the draft.
`requestFilter`, the field-specific draft actions, `applyFilterSheetResult` and
`resetDraftFilter` keep edits isolated. Outside tap and system Back return null and
discard the draft. Action/details effects carry the tapped card snapshot.

The screen groups independent cards-failure and typed-effect listeners in one
MultiBlocListener, with BlocBuilder rendering the existing screen tree. `CardFeaturesFilters` separately owns category-reveal effects and its
category rendering subscription. Effects are consumed before awaiting Flutter
APIs, so repeated sheets work without counters. No effect handler checks old
message presence. No new success toast is introduced.

Category chips are horizontally scrollable. Resalat/Gift/Virtual use the initial strip position when visible; Bon/Family reveal the end of the strip, matching the supplied frames. Narrow layouts additionally reveal a selected chip when needed. The chip scroll viewport includes 4px top/bottom padding so its shadow is not clipped. Outer top spacing and the following gap are each12px, preserving the chip-face/search/list positions while providing room for the shadow. Cubit does not own scroll controllers. Provider disposes Cubit when the route is removed; the filter widget disposes both controllers.

## 13. Design System Package (avp_ui)

| Component | Change and verified properties | Default compatibility |
| --- | --- | --- |
| AppCardsList (shared) | coloredHeader=true: white 343×116 row; outer8/8/12 insets;36px tinted rounded8 header;8px gap;22px detail rows with8px gap; no divider;12px Medium/Regular; gray500 labels; authored20px icons | default plain header/divider/insets/shadow unchanged |
| AppTopBar (shared) | optional trailingIcon/trailingTooltip/onTrailingPressed;64px height,16px horizontal inset,40px action wrapper and exact24px back instance | menu/user/bell callers retain previous behavior |
| AppBottomSheetHeader (shared) | optional textActionColor; handle-only32px/33×2; titled56px/31×2; red12px Remove action | existing primary action color unchanged when omitted |
| AppChips (new avp_ui) |40px height,14px horizontal padding, radius100,selected14/20 Medium/#1570EF/white; default14/20 Regular/#FDFDFD/#383F45; Bon/Family opt into Medium/#414651, exact instance sm elevation | additive component; optional icon, selected and callback properties |
| AppButton (avp_ui) | backgroundColor for #FEC84B44px filter control; labelStyle for16/24 footer at44px; contentGap10; constrainLabel opt-in ellipsis for narrow/large-text footer | all defaults unchanged; disabled source colors still override instance colors |
| AppSelect (avp_ui) | textStyle/labelStyle/labelSpacing/trailing provide14/20 Regular values,12/18 Medium labels,8px gap, exact20px chevron;44px input/radius8/#D5D7DA/xs | existing16px value/14px label/6px gap/Material chevron retained |
| AppSearchField/AppTextField (avp_ui) | optional hintColor #9EA5AD; focusRing.none leaves xs without halo;44px field and14/20 text in this flow | existing hint/halo defaults retained |
| AppCardFeatureColors (new avp_ui) | header colors #D1E9FF/#FDF2FA/#FFFAEB/#FFF1F3/#ECFDF3; filter #FEC84B; default chip text #383F45; hint #9EA5AD; destructive action #F04438 | separate semantic tokens; no global palette replacement |
| AppShadows.cardList/chips (new tokens) | ARGB0x1A0A0D12(0,1),blur3,spread0;0x0F0A0D12(0,1),blur2,spread0 | existing sm/md/bankCard untouched |
| AppAssistantButton (shared) | existing44px pink circle and exact two star assets; left16;16px above safe bottom or76px with footer | reused unchanged |

No app-owned hex colors or duplicate control implementation is introduced. The full package retains earlier documented loading/focus-state differences outside the supplied Cards frames; this task does not globally redesign those states.

### Exact artwork and export provenance

All new files use the AppConstants.baseImage prefix and are used by presentation/card_features_ui.dart or the sheets/screen.

| Asset file under assets/images/ | Role / rendered slot |
| --- | --- |
| card_features_back.svg |24px header instance; actual chevron5.499×9.481 inside |
| card_features_resalat.svg |20px blue card icon |
| card_features_gift.svg |20px pink gift icon |
| card_features_virtual.svg |16.284×12.95 vector in20px slot, offset1.667/3.334 |
| card_features_coupon.svg |20px rose Bon icon |
| card_features_family.svg |20px green family icon |
| card_features_filter.svg |20px icon in44px amber button |
| card_features_search.svg |20px search slot in44px field |
| card_features_separator.png |686×2 source raster, rendered343×1 dashed divider; stretches to current content width |
| card_features_info.svg |24px Details action |
| card_features_reissue.svg |24px Reissue action |
| card_features_change_deposit.svg |24px Change deposit action |
| card_features_block.svg |24px Block action |
| card_features_divider.svg |335×0.5 sheet separator, painted without adding row height |
| card_features_filter_header.svg |20px header filter icon |
| card_features_chevron.svg |20px dropdown chevron |
| card_features_expired_gift.svg |20px category footer icon |
| card_features_plus.svg |20px virtual request footer icon |
| card_features_scrim.svg |original #101828/.64 modal overlay; scales to safe-area content |

The generated header export referenced a hamburger instead of the actual instance override. The back asset was exported read-only from Figma node I27997:10060;13867:8754;13867:8738, preserving its24px canvas and #535862 chevron. Other files are original provided exports, not redrawn paths or screen screenshots.

Original category-vector transforms are preserved; existing legacy AppCardsList icons stay unchanged. The colored variant passes the new exact category icons through its existing cardIcon slot. More remains the existing matching horizontal-dot asset. Assistant and search-clear use the existing registered shared artwork.

### Known rendering limits

The shared AppServiceSheetRoute paints the original #101828/.64 scrim as a native
modal barrier. Its opacity and sigma2 backdrop blur animate in place; only the
panel slides. Card action/detail/filter sheets share this route with other card
services. The original SVG stays in the asset bundle but is not rendered as a
full-height sliding sheet background. Advanced Figma displacement/texture is not
reproduced.

Fixed44px input/40px chip/22px row geometry follows the normal-scale frames. Large-text/narrow interaction tests pass, with opt-in footer ellipsis; full untruncated large-text card-detail redesign and platform rasterization certification remain future work. OS status/navigation icons are not reproduced.

## 14. Localization, Persian Support, and Dates

All new app strings are in lib/l10n/app_fa.arb, app_en.arb and app_ar.arb. Existing dashboard/cards keys are reused where equivalent. Generated localizations are regenerated. Titles and metadata labels are passed to shared components instead of adding new hard-coded screen strings.

The package provides IRANYekanX/FaNum faces. UI remains RTL in all locales; card/IBAN strings use LTR reading order and physically left-aligned detail values where Figma specifies it. Search digit normalization is separate from display. Mock Jalali expiry strings are not converted to a real service date format.

## 15. Routing and Guards

Core card_features_navigation.dart allowlists card-list, card-virtual and card-expired-gift. It pushes one CardListScreen with the corresponding initial category. Dashboard's supplied onServiceRequested callback still takes precedence; existing host integrations are not overridden. Other IDs retain existing handling.

Back pops the standalone route and preserves Dashboard state. Assistant returns to Home/prompt through the core bridge. Real authentication/service guards and subsequent operation routes are not implied by these UI callbacks.

## 16. Testing Strategy

Current tests exercise immutable data, category/query preservation, fresh selected
records on reload, digit normalization, transactional filters, empty/error/retry,
invalid IDs and exception-to-Err conversion. Widget tests cover authored geometry,
selected card callbacks, Apply/Remove/cancel/outside dismissal/system Back,
post-layout category reveal, ordinary rebuilds, route entry and narrow/large text.
Phase 3 additionally covers identical failure notifications, filter opening with
a retained error, recovery without message replay and service callbacks after error.
No tests require completion after Cubit disposal or a runtime repository setter.

Reference geometry:375px width,24px top safe area,40px bottom; list row starts y236 and measures343×116; features sheet y464/h308; details y284/h488; filter y424/h348. Gift/Virtual reference height854; other frame height812.

No bank endpoint, native device/release build, transaction or advanced SVG filter equivalence is validated by these tests.

Historical design implementation results (2026-10-09, not phase-3 evidence): full application suite: 135 passed; final Cards flow suite after the typography adjustment: 12 passed; full avp_ui suite: 107 passed. Both analyzers report no issues. Both git diff --check commands pass.

## 17. Development and Code Review Process

Review the compatible shared/package variants, domain/UI separation, modal draft cancellation, immutable state and selected callback context. Source assets must remain original and local; no temporary Figma URL belongs in runtime Dart. Changes in the sibling package require distributing/committing that package together with the app.

## 18. Environments, CI/CD, and Release

Existing app entry/locale/theme configuration is retained. No environment/secrets/CI/release setup is added. CI requires the updated sibling avp_ui source. Run both package and app analysis/tests before integration.

## 19. AI Assistant and Agent Layer

The existing assistant visual invokes a callback or returns from the route. No new assistant backend or inference is implemented. Assistant navigation must not submit card service operations.

## 20. Open Items and Dependencies

- Supply authoritative card/deposit IDs, statuses, product types and service contracts.
- Define supported actions per card type/status; the four-row menu is a UI prototype.
- Reissue opens the [Resalat issuance flow](card-issuance.md). Change deposit opens [change linked card deposit](change-card-deposit.md); the gift action opens [expired gift balance](expired-gift-balance.md); virtual requests open the [virtual request flow](virtual-card-request.md). These use mock execution; authoritative bank adapters and block-card behavior remain outstanding.
- Decide whether query/filter should persist across route sessions; today they persist only within this route and across its category changes.
- Replace preformatted dates/amounts with validated service mapping where needed.
- Confirm whether sheet drag dismissal is required: current sheets support outside tap/back/explicit buttons; drag is disabled for the full-screen authored backdrop composition.
- Review advanced Figma backdrop texture/displacement support separately.
- Complete multilingual/long-string/large-text device review beyond the tested320px/1.4-scale layout.

## 21. Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.1.0 | 2026-11-01 | Phase-3 Cubit/UseCase/GetIt and status-notification migration; preserve existing UI and banking behavior; current verification below |
| 1.0.0 | 2026-10-09 | Implement six-phase standalone Cards flow, connected sheets, Cubit/mock repository, allowlisted routes and reviewed compatible shared/package variants; add tests and nine rendered review states |

## Resalat issuance integration (2026-10-09)

Without a supplied onActionRequested callback, the reissue sheet action opens CardIssuanceScreen with linkedDeposit context. Explicit host callbacks retain precedence. The nested assistant path pops issuance and then invokes the Cards host callback. See [complete flow architecture and component audit](card-issuance.md).

## Phase 3 — Cubit contract adoption (2026-11-01)

The authoritative [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md)
and [clean-code skill](../../.agents/skills/pishkhan-cubit-clean-code/SKILL.md)
control this migration. There are no `.then` chains, `isClosed`, Cubit-side
UseCase construction or State publication helpers in this Cubit.
`LoadCardsUseCase` lives in `card_features_usecase.dart`, is registered in GetIt
and is resolved once in a final Cubit field. GetIt never registers Cubit.

| Operation | Owner | Triggers |
|---|---|---|
| Card list | `fetchCards` | Provider entry, visible failure Retry |

| Step | Reads | Next / return / lifetime |
|---|---|---|
| Loading/failure | cardsStatus, message at failure transition | Retry in the same live scope; Back unavailable while loading |
| List/search/category | cards, visibleCards, category, query, footerAction | Same screen; selections/query survive reload |
| Filter sheet | draftFilter and depositNumbers; committed filter stays unchanged | Apply commits; dismiss/cancel discards draft; Cubit stays alive |
| Actions/details | selected card snapshot in effect | Details or existing service/host callback; modal shares route lifetime |
| Service / route exit | prepared request and serviceId | Navigation/host runs independently of retained error; Provider closes on removal |

Repeated calculations remain pure helpers: filtering, deposit-number extraction,
footer choice, service ID and category reveal. Independent search/category/Apply
emits stay explicit even when they touch overlapping fields. The private
`_fetchCardsForCategory` pass-through split was removed so the real operation is
readable in `fetchCards` itself. No request lifecycle was duplicated.

Flow review: removed 8 blanket failure/message clears. Existing selectedCard,
draftFilter and consumed-effect clears retain their actual list/modal readers.
Category reveal still runs once after initial listener attachment/layout and on
subsequent selection. No request payload, route, bank adapter or visual token changed.

Phase-3 verification is recorded in [virtual-card-request.md](virtual-card-request.md#phase-3-verification).

## Phases 1–3 listener-composition follow-up

The owner-approved [contract v1.21](../ui-cubit-state-agent-rules-en.md#116-choose-builder-listener-or-consumer-by-responsibility)
groups independent listeners at each screen/flow boundary and uses BlocBuilder
for rendering there. CardListScreen now has two focused listeners in one
MultiBlocListener: entering cards failure and non-reveal typed effects.
CardFeaturesFilters keeps its local Consumer for category rendering and scrolling
through its own ScrollController; it remains the sole category-reveal consumer.

The former outer Listener/inner Consumer has only been recomposed. Existing
predicates, named callbacks, sheet results/consumption, post-layout reveal,
Provider ownership, Back behavior and widget-tree content are unchanged. No
Cubit/State/dependency or request changes are part of this follow-up.
Verification for this follow-up is recorded in
[virtual-card-request.md](virtual-card-request.md#listener-composition-follow-up-verification).
