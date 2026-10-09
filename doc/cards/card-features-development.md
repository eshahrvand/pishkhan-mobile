# Cards Features Development Document

**Project:** Pishkhan AI / Smart Virtual Counter  
**Version:** 1.0.0  
**Date:** 2026-10-09  
**Status:** Connected UI flow with mock repository; bank execution is not connected.  
**Architecture reference:** [Project architecture](../architecture-smart-virtual-counter-v2-en.md)  
**Related:** [Dashboard architecture](../dashboard/dashboard-development.md), [rendered flow gallery](../card-features-review/index.html)

This document follows the project's 21 architecture sections. This is the standalone Cards feature. The Dashboard card carousel remains owned by Dashboard and has a separate model/repository/Cubit.

## 1. Architectural Goals and Principles

All six phases form one Cards flow: five categories share search, filtering, list rows and contextual actions. Details and filter sheets operate within the same route. No duplicate list, input, button or sheet-header component is created.

The component decision was reviewed before code. The user chose compatible variants/parameters and the missing package Chips component. Existing defaults are preserved; the colored list/header and compact filter styling are opt-in.

## 2. Product Scope and Target Platforms

| Phase/state | Figma node | Implemented behavior | Preview |
| --- | --- | --- | --- |
| 1: Resalat list | 27997:10059 | Four mock rows, category strip, search, filter, assistant | [Resalat](../card-features-review/resalat.png) |
| 1: Features sheet | 27997:11392 | Details, reissue, change linked deposit, block; selected-card context | [Actions](../card-features-review/actions.png) |
| 1: Details sheet | 27997:11463 | Number, IBAN, linked deposit, deposit type, expiry, status; Back | [Details](../card-features-review/details.png) |
| 2: Filter, all | 27997:11531 | Status and deposit selectors; Apply | [All](../card-features-review/filter-all.png) |
| 2: Filter selections | 27997:11563 | Draft selections, red Remove filter action, apply/cancel | [Selected](../card-features-review/filter-selected.png) |
| 3: Gift | 27997:11288 | Pink headers, four rows, expired-gift-balance action | [Gift](../card-features-review/gift.png) |
| 4: Virtual | 27997:11316 | Amber headers, four rows, virtual-card request action | [Virtual](../card-features-review/virtual.png) |
| 5: Bon / coupon | 27997:11344 | Rose headers, two rows, no category footer | [Bon](../card-features-review/coupon.png) |
| 6: Family | 27997:11368 | Green headers, two rows, no category footer | [Family](../card-features-review/family.png) |

All node references belong to [the supplied Figma file](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27997-10059). App controls are RTL-first on all locales. Native status/navigation bars are outside the UI implementation; review images reserve 24px/40px safe areas without drawing native system controls.

The four banking-feature rows are reused when opening a card's menu. Only the Resalat menu is authored in the supplied designs; category-specific future eligibility must come from bank requirements rather than inferred card colors.

## 3. Technology Stack

Flutter Material composition, flutter_bloc Cubit, Equatable entities/state, core Result/Failure, public avp_ui primitives, app shared visuals, flutter_svg, and generated fa/en/ar ARB localization. No new dependency is added.

## 4. Development Environment and Versions

Existing pubspec.yaml/pubspec.lock and analysis_options.yaml govern versions. avp_ui is the sibling path dependency ../avp_ui. ARBs are generated through flutter gen-l10n. The feature uses the current repository's Flutter SDK; no SDK migration or platform build is part of this change.

## 5. Third-Party Dependency Governance

Existing dependencies suffice. New package APIs are additive, public-barrel exported and regression-tested. No HTTP or caching package is introduced. Direct imports of avp_ui internals are not used by the main app.

## 6. Project Structure and Modularization

```text
lib/features/cards/
  cards.dart                                      public feature exports
  domain/
    entities/listed_card.dart                     ListedCard, CardCategory, CardStatus
    repositories/cards_repository.dart            CardsRepository.getCards
    usecases/load_cards.dart                      Result boundary + ID validation
  data/mock/mock_cards_repository.dart             mock summaries and async adapter
  presentation/
    card_features_screen.dart                     route composition, view resources
    card_feature_actions.dart                     typed action enum/request contract
    card_features_ui.dart                         labels, assets, category/type mapping
    cubit/card_features_state.dart                immutable data, filter/query/selection
    cubit/card_features_cubit.dart                 loading and UI state operations
    widgets/card_feature_sheets.dart               actions/details/filter composition
lib/core/router/card_features_navigation.dart      allowlisted standalone route bridge
lib/shared/widgets/app_cards_list.dart             coloredHeader opt-in variant
lib/shared/widgets/app_top_bar.dart                optional trailing/back widget/callback
lib/shared/widgets/app_bottom_sheet_header.dart    optional text-action color
lib/shared/assets/app_assets.dart                  original Figma artwork registry
lib/l10n/app_{fa,en,ar}.arb                         feature copy
lib/l10n/generated/                                generated output
test/cards/card_features_cubit_test.dart           four state/repository unit cases
test/cards/card_features_screen_test.dart          twelve flow/render/accessibility cases
test/cards/support/test_cards_repository.dart      controllable service fake
doc/cards/card-features-development.md             this document
doc/card-features-review/                          nine PNGs and HTML gallery
```

Dashboard entities/actions/Cubits stay under features/dashboard. ListedCard is a standalone list summary, not Dashboard BankCard. Common visuals remain shared or package-owned. Dashboard calls the core routing bridge instead of directly importing standalone feature UI.

## 7. Layering Pattern (Clean Architecture)

**Domain:** ListedCard and the category/status enums have no Flutter imports. ListedCard extends Equatable and is immutable. Repository returns Future<Result<List<ListedCard>>>. LoadCards catches unexpected transport exceptions and rejects duplicate/blank IDs before returning an immutable list.

**Data:** MockCardsRepository implements the interface. Defaults create 4 Resalat, 4 Gift, 4 Virtual, 2 Bon and 2 Family cards. Cards at index3 have another linked deposit and blocked status to make filtering observable; other mock cards are active. These are samples, not actual user accounts. Numbers and dates remain display-ready prototype strings.

**State:** CardFeaturesCubit invokes LoadCards. CardFeaturesState and CardFilter use value equality and immutable card lists. Controls derive content from the state rather than widget-local business variables.

**UI:** Screen/sheets compose public AppButton, AppChips, AppSearchField, AppSelect, AppCardsList, AppTopBar, AppBottomSheetHeader and AppAssistantButton. TextEditingController, ScrollController, GlobalKeys and modal resources remain in the view.

```text
MockCardsRepository / future live adapter
  -> CardsRepository
  -> LoadCards
  -> CardFeaturesCubit
  -> immutable CardFeaturesState
  -> CardFeaturesScreen + sheet composition
  -> shared widgets + avp_ui
```

## 8. Service Flow Pattern and Suspended Requests

```text
Dashboard catalog -> card-list -> CardFeaturesScreen(Resalat)
                    card-virtual -> same screen(Virtual)
                    card-expired-gift -> same screen(Gift)
category chip -> selectCategory -> filtered summary list/footer
search -> query -> list
filter button -> draft copy of committed filter
  status/deposit dropdown -> draft only
  Apply -> commit filter -> close sheet -> list changes
  Remove filter -> clear draft -> Apply commits clearing
  system back/outside tap -> discard draft
row More -> select card ID -> actions sheet
  Details -> details sheet -> Back -> list
  other action -> CardFeatureRequest(action, card, category) -> host
category footer -> CardFeatureRequest(action, category, card:null) -> host
assistant -> host override / return to dashboard prompt
```

The screen exposes repository, initialCategory, onActionRequested and onAssistantPressed. Initial category chooses the entry state. Repository identity changes reload data. Initial category is an entry parameter; ongoing category choice belongs to Cubit.

Reissue/change-deposit/block are integration events, not implemented transaction wizards. No designs for their subsequent pages were supplied. Missing action handlers display a localized unavailable message rather than falsely reporting success. Gift transfer and virtual request are category-level events and intentionally have no arbitrarily chosen card.

No suspended bank request or idempotent submission is implemented. Filter drafts are local UI transactions.

## 9. Security and Compliance Layer

No bank transaction, blocking operation or transfer is performed. Showing/enabling an action is not proof of bank eligibility. Production service APIs must validate ownership, authorization and current account state. A contextual request contains the selected summary snapshot; it must be revalidated before an actual banking operation. No financial data is written to disk by runtime UI.

## 10. Network and Authentication Layer

The real service replaces MockCardsRepository by implementing CardsRepository and passing it to CardFeaturesScreen.repository. The UI/Cubit loading API does not change.

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
| icon/tint/title | local enum + AppAssets + ARBs/package tokens | app-owned supported registry; future catalog cannot execute arbitrary routes |

No remote icon renderer, metadata-driven visual template or permission filter is present. The current mock data varies by ID/status/deposit; supplied Figma account numbers are illustrative and some mock row values intentionally differ.

## 11. Error Handling Pattern (Result & Failure)

LoadCards preserves Err failures and maps unexpected exceptions to UnexpectedFailure. Invalid IDs produce DataFailure('cards.invalid'). Failure codes are not displayed directly; the UI uses localized generic error and retry. Initial/loading, empty repository and zero search/filter results are separate outcomes. Error content hides old list/action rows rather than implying stale eligibility.

## 12. State Management with Cubit

CardFeaturesState stores status, immutable cards, category, query, committed filter, nullable draftFilter, selectedId and nullable Failure. CardsLoadStatus is initial/loading/loaded/empty/error. visibleCards combines category AND committed filter AND normalized query. The repository's empty state is distinct from a loaded dataset with no matches.

CardFilter contains nullable status/deposit; null means All. Dropdown selections use stable enum names/raw deposit values, not localized strings. Persian and Arabic digits normalize to Latin; spaces, hyphens, dots and ZWNJ are ignored for search. Original display values remain unchanged. Search applies to card number and linked deposit.

Cubit's monotonically increasing request token makes the newest load win and suppresses completion after close. Selection survives reload while its ID remains; category/filter changes clear it. Modal menus/details hold the tapped card snapshot, so later callbacks do not accidentally refer to another row. beginFilter/setDraft/applyFilter/cancelFilter/clearDraftFilter keep preview edits isolated.

Category chips are horizontally scrollable. Resalat/Gift/Virtual use the initial strip position when visible; Bon/Family reveal the end of the strip, matching the supplied frames. Narrow layouts additionally reveal a selected chip when needed. The chip scroll viewport includes 4px top/bottom padding so its shadow is not clipped. Outer top spacing and the following gap are each12px, preserving the chip-face/search/list positions while providing room for the shadow. Cubit does not own scroll controllers. The route disposes its Cubit and both controllers.

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

All new files are registered in lib/shared/assets/app_assets.dart and used by presentation/card_features_ui.dart or the sheets/screen.

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

The original modal SVG contains foreignObject/texture/displacement filter constructs unsupported by flutter_svg. Its supported fill remains intact; a native BackdropFilter(sigma2) supplies backdrop blur. The advanced Figma displacement/texture effect is not reproduced exactly. Both unsupported-element warnings and the remaining effect difference are recorded here; the source SVG is not edited or replaced.

Fixed44px input/40px chip/22px row geometry follows the normal-scale frames. Large-text/narrow interaction tests pass, with opt-in footer ellipsis; full untruncated large-text card-detail redesign and platform rasterization certification remain future work. OS status/navigation icons are not reproduced.

## 14. Localization, Persian Support, and Dates

All new app strings are in lib/l10n/app_fa.arb, app_en.arb and app_ar.arb. Existing dashboard/cards keys are reused where equivalent. Generated localizations are regenerated. Titles and metadata labels are passed to shared components instead of adding new hard-coded screen strings.

The package provides IRANYekanX/FaNum faces. UI remains RTL in all locales; card/IBAN strings use LTR reading order and physically left-aligned detail values where Figma specifies it. Search digit normalization is separate from display. Mock Jalali expiry strings are not converted to a real service date format.

## 15. Routing and Guards

Core card_features_navigation.dart allowlists card-list, card-virtual and card-expired-gift. It pushes one CardFeaturesScreen with the corresponding initial category. Dashboard's supplied onServiceRequested callback still takes precedence; existing host integrations are not overridden. Other IDs retain existing handling.

Back pops the standalone route and preserves Dashboard state. Assistant returns to Home/prompt through the core bridge. Real authentication/service guards and subsequent operation routes are not implied by these UI callbacks.

## 16. Testing Strategy

Four Cubit unit cases cover immutable data, category/selection, all digit sets, transactional filters, combined search/filter, reset, empty/error/retry, invalid IDs, unexpected repository exceptions, out-of-order responses and completion after disposal.

Twelve widget cases cover five native frames, action/detail context, sheet origins, filter Apply/cancel/Remove, search/category/footer context, Dashboard entry/back, empty data, delayed load/error/retry/repository replacement, and320px/1.4-scale reachability. Package tests cover chips semantics/height, compact selects, instance button style versus disabled behavior and narrow label bounds. Existing shared-component tests verify default compatibility.

Reference geometry:375px width,24px top safe area,40px bottom; list row starts y236 and measures343×116; features sheet y464/h308; details y284/h488; filter y424/h348. Gift/Virtual reference height854; other frame height812.

Regenerate review PNGs:
```powershell
flutter test --dart-define=UPDATE_CARD_FEATURES_PREVIEWS=true test/cards/card_features_screen_test.dart
```

The environment variable UPDATE_CARD_FEATURES_PREVIEWS=1 remains supported. Previews are review artifacts, not app UI assets/golden baselines. No bank endpoint, native device/release build, transaction or advanced SVG filter equivalence is validated by these tests.

Validation results: full application suite: 135 passed; final Cards flow suite after the typography adjustment: 12 passed; full avp_ui suite: 107 passed. Both analyzers report no issues. Both git diff --check commands pass. All nine regenerated previews were visually reviewed, and all 19 new assets are non-empty with verified metadata/callsites.

## 17. Development and Code Review Process

Review the compatible shared/package variants, domain/UI separation, modal draft cancellation, immutable state and selected callback context. Source assets must remain original and local; no temporary Figma URL belongs in runtime Dart. Changes in the sibling package require distributing/committing that package together with the app.

## 18. Environments, CI/CD, and Release

Existing app entry/locale/theme configuration is retained. No environment/secrets/CI/release setup is added. CI requires the updated sibling avp_ui source. Run both package and app analysis/tests before integration.

## 19. AI Assistant and Agent Layer

The existing assistant visual invokes a callback or returns from the route. No new assistant backend or inference is implemented. Assistant navigation must not submit card service operations.

## 20. Open Items and Dependencies

- Supply authoritative card/deposit IDs, statuses, product types and service contracts.
- Define supported actions per card type/status; the four-row menu is a UI prototype.
- Reissue now opens the [Resalat issuance flow](../card-issuance/card-issuance-development.md) by default; real execution remains unconnected. Supply change-deposit/block/gift-transfer/virtual-request flow designs and handlers.
- Decide whether query/filter should persist across route sessions; today they persist only within this route and across its category changes.
- Replace preformatted dates/amounts with validated service mapping where needed.
- Confirm whether sheet drag dismissal is required: current sheets support outside tap/back/explicit buttons; drag is disabled for the full-screen authored backdrop composition.
- Review advanced Figma backdrop texture/displacement support separately.
- Complete multilingual/long-string/large-text device review beyond the tested320px/1.4-scale layout.

## 21. Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.0.0 | 2026-10-09 | Implement six-phase standalone Cards flow, connected sheets, Cubit/mock repository, allowlisted routes and reviewed compatible shared/package variants; add tests and nine rendered review states |

## Resalat issuance integration (2026-10-09)

Without a supplied onActionRequested callback, the reissue sheet action opens CardIssuanceScreen with linkedDeposit context. Explicit host callbacks retain precedence. The nested assistant path pops issuance and then invokes the Cards host callback. See [complete flow architecture and component audit](../card-issuance/card-issuance-development.md) and [nine issuance/Stepper previews](../card-issuance-review/index.html).
