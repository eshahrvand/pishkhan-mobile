# Resalat Card Issuance Development Document

**Project:** Pishkhan AI / Smart Virtual Counter  
**Version:** 1.0.0  
**Date:** 2026-10-09  
**Status:** Connected UI flow with mock data; no real payment or issuance.  
**Architecture reference:** [Project architecture](../architecture-smart-virtual-counter-v2-en.md)  
**Related:** [Dashboard](../dashboard/dashboard-development.md), [Cards flow](../cards/card-features-development.md), [integration guide](../main-app-integration-guide.md), [rendered review gallery](../card-issuance-review/index.html), [package change audit](../../../avp_ui/docs/reviews/2026-10-09-card-issuance-ui-changes.md)

This document uses the project's 21 architecture sections. The issuance route is a dedicated feature under card_issuance; Dashboard remains the owner of its own tabs. The reusable Stepper lives in avp_ui. Existing shared invoice/address card components receive compatible parameters/variants rather than being duplicated.

## 1. Architectural Goals and Principles

Implement account/type selection, delivery information and confirmation as one stateful flow. UI composition consumes immutable state and calls Cubit commands. Shared components never own bank state, repository calls, payment or navigation.

The user reviewed component differences before implementation and selected compatible variants that preserve default behavior. Stepper was added to the sibling package before app composition. Fee values are illustrative, but the displayed total consistently derives from the mock fee items.

The explicit product correction takes precedence over the screenshot: enabling no-physical-card does not satisfy account/type requirements. Both must be selected before continuing. Delivery is skipped for this path; confirmation is still required.

## 2. Product Scope and Target Platforms

All references are in [the supplied Figma file](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27997-10084).

| Phase/state | Figma node | Behavior | Preview |
| --- | --- | --- | --- |
| 1: Selection empty | 27997:10084 | Two required selectors, no-physical toggle off, disabled Next | [Empty](../card-issuance-review/selection-empty.png) |
| 1: Selection filled | 27997:11251 | Selected account, current card/expiry, issuance type, enabled Next | [Filled](../card-issuance-review/selection-filled.png) |
| 1: No physical card | 27997:11119 | Toggle on; selectors remain required; delivery is skipped only after valid selection | [Nonphysical](../card-issuance-review/no-physical.png) |
| 2: Address empty | 27997:11135 | Existing-address selector, Add address, recipient and agent switches | [Empty address](../card-issuance-review/address-empty.png) |
| 2: Address selected | 27997:11153 | Compact address/delete card, selected address label, Next enabled when conditional fields are complete | [Selected address](../card-issuance-review/address-filled.png) |
| 3: Expanded fees | 27997:11179 | Summary, fees/wallet, terms and confirmation action | [Expanded](../card-issuance-review/confirmation-open.png) |
| 3: Collapsed fees | 27997:11215 | Fee detail lines hidden; total, wallet and status retained | [Collapsed](../card-issuance-review/confirmation-closed.png) |
| Shared Stepper | 27984:8986 | Controlled current/total count and caller copy; first/last examples | [First](../card-issuance-review/stepper-library-first.png), [last](../card-issuance-review/stepper-library-last.png) |

The supplied collapsed frame closes fee details while retaining the expanded information summary. The implementation supports these independently. The summary can also be collapsed, though that extra state has no supplied reference.

The add-address form, enabled recipient/agent forms, error/loading/empty/insufficient-wallet states and completion are usable UI extensions built with existing primitives. Their detailed frames were not supplied and they are not claimed to be Figma-certified.

Mobile reference size is 375×812 with 24px top/40px bottom safe-area reservations. Native status/navigation controls are provided by the OS; previews reserve their space without drawing them. Narrow 320×700 and 1.3 text scale are also checked in fa/en/ar.

## 3. Technology Stack

Flutter, flutter_bloc Cubit, Equatable, core Result/Failure, public avp_ui primitives, shared app widgets, flutter_svg and generated ARB localization. No additional dependency or transport library is introduced. Amounts use CurrencyFormatter; numeric inputs use DigitNormalizer.

## 4. Development Environment and Versions

The existing SDK, lockfiles, pubspec and lint rules govern builds. avp_ui remains the local path dependency ../avp_ui. This feature requires its updated source, asset declarations and exports; using an older package checkout cannot compile the new AppStepper/appearance API.

Both package and app integration guides receive identical new Stepper and issuance-composition sections. Existing repository-specific notes are retained. Generated localizations are updated through flutter gen-l10n.

## 5. Third-Party Dependency Governance

The existing dependencies cover SVG rendering, state and tests. No browser, payment SDK or HTTP client is added. Consumers import only package:avp_ui/avp_ui.dart. The package owns its Stepper SVGs; app-owned issuance icons remain in the app's flat assets/images registry.

## 6. Project Structure and Modularization

```text
lib/features/card_issuance/
  card_issuance.dart                                 public screen/entities/repository exports
  domain/
    entities/issuance_data.dart                      deposit, address, fee, catalog, identities, request, receipt
    repositories/card_issuance_repository.dart       load/submit Result boundary
    usecases/issuance_usecases.dart                  LoadIssuanceCatalog, SubmitCardIssuance
  data/mock/mock_card_issuance_repository.dart       sample catalog and explicit mock receipt
  presentation/
    card_issuance_screen.dart                        route, lifecycle, back, scroll, footer, callbacks
    cubit/card_issuance_state.dart                   statuses, step, immutable draft, derived validation
    cubit/card_issuance_cubit.dart                    load, editing, transitions, submission
    widgets/issuance_sections.dart                  selection/delivery/confirmation composition and icon/type mapping
    widgets/issuance_address_sheet.dart              local address form with existing controls
lib/core/router/card_features_navigation.dart        allowlisted entry bridge
lib/features/dashboard/presentation/dashboard_screen.dart  selected-deposit context forwarding
lib/features/cards/presentation/card_features_screen.dart    default reissue route
lib/shared/widgets/app_invoice.dart                  compatible invoice appearance/copy properties
lib/shared/widgets/app_address_card.dart             full/default and delivery/compact variants
lib/shared/widgets/app_delete_address_sheet.dart     reused deletion confirmation
lib/shared/assets/app_assets.dart                    canonical app asset paths
lib/l10n/app_{fa,en,ar}.arb                           issuance text
lib/l10n/generated/                                 generated localization getters
```

Package changes:

```text
avp_ui/lib/widgets/layout/app_stepper.dart            new shared controlled Stepper
avp_ui/lib/widgets/layout/layout.dart                public Stepper export
avp_ui/lib/widgets/fields/app_toggle.dart             opt-in issuance appearance
avp_ui/lib/tokens/app_card_issuance_colors.dart       context-specific semantic colors
avp_ui/lib/avp_ui.dart                               public token export
avp_ui/assets/icons/stepper-{track,progress}.svg      original Figma rings
avp_ui/pubspec.yaml                                 both asset declarations
avp_ui/example/lib/figma_name_mapper.dart            searchable name lookup and live Stepper preview
avp_ui/example/lib/components_tab.dart               first/last review examples
avp_ui/example/lib/main.dart                         sixth gallery tab; Components remains initial tab
avp_ui/docs/main-app-integration-guide.md             mapping and usage notes
avp_ui/docs/reviews/2026-10-09-card-issuance-ui-changes.md detailed package change audit
```

No DTO, HTTP data source or server mapper currently exists for issuance. The mock adapter returns domain entities directly. A production adapter must perform explicit transport-to-domain mapping instead of putting server JSON into widgets.

## 7. Architecture Layers and Dependency Direction

UI: CardIssuanceScreen owns the Cubit and scroll resource; it composes AppTopBar, AppStepper, section widgets, assistant, consent and AppButton. Section widgets pass data/styles/callbacks into existing shared/package components. IssuanceDelivery owns editing controllers and disposes them; persistent values live in IssuanceDraft, so back navigation can recreate controllers.

State: CardIssuanceCubit owns workflow commands, loading, selected IDs, validation orchestration and submission. CardIssuanceState and IssuanceDraft are Equatable and immutable. Derived getters resolve selection against the loaded catalog, filter fees and build the request.

Domain: plain immutable entities and a repository interface with Result returns. Use cases name loading and submission. There is no banking behavior in avp_ui or shared widgets.

Data: MockCardIssuanceRepository returns sampleCatalog and an IssuanceReceipt explicitly marked isMock. Replacing the catalog/submission adapter uses the same interface. Product-specific quotation, durable address CRUD and terms versions need additional orchestration once the service contract is known.

Data flow:

```text
Screen lifecycle -> Cubit.load -> LoadIssuanceCatalog -> repository.load
  <- Result<catalog/failure> <- mock adapter (future transport mapper)
  -> immutable state -> BlocConsumer -> existing components
User controls -> Cubit command -> validated draft -> derived request
Confirm -> SubmitCardIssuance -> repository.submit -> Result<receipt/failure>
  -> mock completion or preserved draft/retry
```

## 8. State Management

IssuanceStatus: initial, loading, loaded, empty, error, submitting, submitted. IssuanceStep: selection, delivery, confirmation. Empty means no eligible deposits or no supported issuance types; an empty address list remains a usable delivery state with Add address.

State contains catalog, draft, step, invoiceExpanded, summaryExpanded, failure and receipt. Draft contains depositId, type, addressId, noPhysicalCard, otherRecipient, includeAgent, termsAccepted, DeliveryPerson and BankAgent. No text controller lives in a Cubit/state/entity.

Selected account/address are looked up by ID. Unknown IDs are ignored by Cubit commands. Issuance types must belong to catalog.types. Selection never becomes valid merely because a flag is enabled.

| Gate | Actual state rule |
| --- | --- |
| Selection complete | Existing selected deposit plus a supported non-null issuance type |
| Delivery complete | Nonphysical path, or selected address plus complete enabled recipient/agent details |
| Recipient complete | Nonempty trimmed name, 10 ASCII digits for national ID, 11-digit mobile beginning 09 |
| Agent complete | Nonempty name and code |
| Continue | Status loaded plus the gate for the current step |
| Submit | Confirmation step, valid selection/delivery, accepted terms and wallet balance at least mock total |

National-ID validation is a format check, not a checksum or identity/eligibility verification. Agent codes are not verified against a directory. Production rules must come from the bank.

Edits clear terms acceptance and submission failure. Back without edits can retain acceptance. Turning conditional delivery fields off preserves their draft text, but the request omits disabled details. A nonphysical request always omits address, recipient and agent, even if earlier draft values exist.

load resets the draft and uses a generation counter. A newer load/repository replacement or disposal invalidates older asynchronous completions. submit sets submitting before awaiting, preventing double submission and editing. Submission failure returns to loaded with the draft preserved; Retry uses the same visible request data. Successful mock submission returns an explicitly identified preview completion.

State/step flow:

```text
initial -> loading -> loaded | empty | error
error/empty -> Retry -> loading
loaded selection -- account + type --> delivery -- address + conditional fields --> confirmation
loaded selection -- no physical + account + type ---------------------------> confirmation
confirmation -- accepted terms + sufficient balance --> submitting
submitting -> submitted (mock receipt) | loaded confirmation (failure/retry)
Back: confirmation -> delivery -> selection -> close
Back nonphysical: confirmation -> selection -> close
```

## 9. Domain Models and Data Rules

| Model | Fields | Current origin / meaning |
| --- | --- | --- |
| IssuanceDeposit | id, number, cardNumber, expiry | Mock catalog; number/card/expiry are display strings |
| IssuanceAddress | id, title, detail, postalCode | Mock catalog or route-local added address |
| IssuanceType | newNumber, existingNumber | App enum; localized labels; catalog decides which are available |
| IssuanceFee | kind, amountRial | Integer rial amounts; print/identity/delivery enum |
| IssuanceCatalog | deposits, addresses, fees, types, walletBalanceRial | Lists are unmodifiable; withAddresses creates a replacement |
| DeliveryPerson | name, nationalId, mobile | UI draft; numeric text normalized before state storage |
| BankAgent | name, code | UI draft; code normalized |
| IssuanceRequest | depositId, type, noPhysicalCard, address, recipient, agent | Derived from validated draft; no wallet charge is executed here |
| IssuanceReceipt | reference, isMock | Mock adapter returns UI-MOCK-001 / true |

The catalog has two accounts, one home address, three fee lines and a 2,000,000-rial balance. Physical fee items sum to 1,600,000; nonphysical excludes delivery and sums to 600,000. The Figma sample's 1,300,000 total conflicts with its 300,000 + 300,000 + 1,000,000 rows. Sample values are not payment instructions. The actual selected account drives current-card data and confirmation summary; a summary never copies a different static frame's account number.

The secondary existing-number choice is mock product behavior; only new-number selection is shown in the supplied frame. Server eligibility should replace this illustrative availability.

New addresses use a route-local local-address-N ID. Postal input is normalized, trimmed and checked for 10 digits. Deleting an address removes it only from the current catalog state, and clears the selected address when appropriate. Neither operation persists through the repository today.

## 10. Backend Integration and Server Readiness

The repository exposes load() and submit(IssuanceRequest). Loading/submission errors use core Failure rather than throwing through UI. The mock adapter makes no request to a bank, wallet or address service.

A proposed catalog/quotation response is below. This is a future contract, not an implemented endpoint or DTO:

```json
{
  "deposits": [{"id": "dep-1", "number": "10.1234567.1", "current_card": {"number": "5041721223456787", "expiry": "1405/11/17"}}],
  "issuance_types": [{"key": "new_number", "enabled": true}],
  "addresses": [{"id": "addr-1", "title": "خانه", "detail": "تهران ...", "postal_code": "1912134564"}],
  "wallet": {"balance_rial": 2000000},
  "quote": {"id": "quote-1", "currency": "IRR", "expires_at": "2026-10-09T12:00:00Z", "fees": [{"key": "print", "amount_rial": 300000}, {"key": "identity", "amount_rial": 300000}, {"key": "delivery", "amount_rial": 1000000}], "total_rial": 1600000},
  "capabilities": {"physical_card_optional": true, "other_recipient": true, "bank_agent": true},
  "terms": {"version": "v1", "url": "https://bank.example/terms/card-issuance"}
}
```

Mapping must validate stable IDs, uniqueness, required fields, amounts/currency, known enum keys and eligibility. Unknown issuance types must be hidden/disabled or represented by a reviewed fallback rather than executed as arbitrary strings. Current fee icons/labels map through IssuanceFeeKind in issuance_sections.dart; future unknown fee rows need a typed generic label/icon fallback. Routes and submission handlers remain app code.

Uniform catalog data can replace mock load without UI/Cubit changes. Selection-dependent bank quotes require a quote use case/repository operation and asynchronous quote states; no such endpoint is invented in this task. Clear accepted terms when the request, terms version or quote changes. Recheck balance/eligibility/fees on the server and enforce idempotency across retries. A local sufficient-balance calculation is presentation only, not a server payment authorization.

The production adapter must decide whether an address is an existing server ID or a locally added inline address. Add origin metadata or persist the local address before submitting; do not send the local mock ID as an authoritative bank ID. Recipient/agent inclusion is explicit. Terms version, quote ID and idempotency key also belong in the eventual request contract.

## 11. Networking and Transport

No networking implementation is present. Adapter implementations should map transport failures to Result, perform authenticated calls through the project's core services, and avoid exposing raw server messages through shared visuals. This UI does not define endpoint paths, payment credentials, timeouts or bank error codes.

## 12. Security, Privacy, and Persistence

Selected account, address and identity text stay in memory for the route lifetime. No new persistence, analytics, logs or secrets are added. Cancel/back does not execute a banking operation. Mock completion explicitly says no payment or issuance occurred.

Production submission needs authentication/service guards, accepted official terms, authoritative quotation and bank authorization. UI enablement and a mock receipt are not evidence that those checks happened. No speculative bank permission model is baked into the components.

## 13. UI, Design System, and Figma Audit

### 13.1 Component ownership

| Package | Existing/new components used |
| --- | --- |
| avp_ui | New AppStepper; existing AppSelect/AppSelectOption, AppToggle with opt-in appearance, AppCheckbox md, AppButton, AppTextField, AppTextArea; typography/colors/shadows/formatters/normalizer |
| shared | AppTopBar, AppAssistantButton, AppInvoice/AppInvoiceLine/AppWalletBalanceStatus, AppAddressCard delivery variant, AppDeleteAddressSheet, AppBottomSheetHeader |
| local composition | IssuanceSelection, IssuanceDelivery, IssuanceConfirmation, select/toggle composition, current-card and summary rows, address form, footer |

Local widgets compose feature-specific content and public controls; they do not recreate inputs, buttons, toggles or the shared invoice/address visuals.

### 13.2 Stepper verification

Figma 27984:8986 first/last and issuance instances were inspected. AppStepper has the 42×42 original gray/blue ring assets, 2.1px annulus, physical-left counter, 24px gap, 4px warning dot, BlueGray500 title and Gray400 supporting copy. Title uses 12/18 DemiBold, support 10/16 Light with a 6px gap and 8px right inset; current number is 12/18 Regular BlueGray600 and denominator 10/16 Light Gray500 with 2px gap.

Default progress is current/total. Authored library first 1/5 actually renders a 36-degree .1 arc; issuance first/second use .3/.6 despite displaying 1/3 and 2/3. Caller progress overrides reproduce those samples without changing state gates. Final ring is full. Numeric reading order is fixed LTR; text remains RTL. Long localized copy wraps and increases height rather than overflowing.

Package assets are declared explicitly in pubspec.yaml. Visual review initially caught a missing/stale consuming-test asset bundle that layout-only tests missed. Both package asset loads and app ring-pixel tests now verify the real drawing. Rebuild generated test assets if a path-dependency asset declaration changes; a test bundle can otherwise remain stale even when Dart source recompiles.

The new FigmaNameMapper example widget provides searchable implemented-name mapping and a live AppStepper preview. The Components tab also contains first/last variants. Stepper is registered exactly once in the mapper; both guides identify the public export and source.

### 13.3 Reviewed compatible changes

| Component | Before | Issuance configuration | Compatibility / verification |
| --- | --- | --- | --- |
| AppInvoice | Gray50 surface; Gray700 labels; Persian wallet-status defaults | backgroundColor white, labelColor Gray500 and localized status copy | Nullable parameters preserve defaults; existing invoice tests and both fee states checked |
| AppAddressCard | Full card with Home/Work header, phone, postal code and review/more content | variant delivery: white surface, 14px padding, 10px radius, 14/20 Regular address, left 20px red delete slot | full remains default; localized deleteLabel/icon/callback; existing Home/Work tests pass |
| AppToggle | Gray200 off track; one shadow; directional thumb | issuance appearance: Gray100, two Shadow/sm thumb layers, clipped rounded track, physical off-left/on-right | standard remains default; size, colors, alignment, shadows and existing toggle tests checked |
| AppSelect | Existing field/menu API | 44px control, 8px label gap, 12/18 Medium label, 14/20 Regular text, original 20px chevrons; per-state hint colors through textStyle | No package source change; selected/empty wrappers use existing properties |
| AppButton | Existing sizes/variants | 44px footer with 14/20 DemiBold; 139×20 app-owned slot for the compact Add address instance with 12/18 Medium and 8px content gap | Existing primitive reused; compact slot tested via the connected Add address action |

The Toggle small track is 36×20 with 16px thumb and 2px inset. AppShadows.cardList supplies the two authored y1 shadows (blur2/6%, blur3/10%). Standard hover/focus/disabled behavior remains unchanged and was not redesigned by these frames.

### 13.4 Asset inventory and geometry

All new app assets are non-empty original SVG downloads in the flat registered directory. AppAssets is the only path registry. The selected chevron reuses cardFeaturesChevron because its bytes match exactly. Existing back chevron, assistant stars and invoice glyphs are reused; their renderer slots are unchanged.

| AppAssets key | Original local source | Root dimensions |
| --- | --- | --- |
| issuanceCalendar | assets/images/issuance_calendar.svg | 20 × 20 |
| issuanceCardDivider | assets/images/issuance_card_divider.svg | 311 × 0.5 |
| issuanceCredit | assets/images/issuance_credit.svg | 20 × 20 |
| issuanceDivider | assets/images/issuance_divider.svg | 343 × 1 |
| issuancePlus | assets/images/issuance_plus.svg | 20 × 20 |
| issuanceSelectEmpty | assets/images/issuance_select_empty.svg | 20 × 20 |
| issuanceSummaryChevron | assets/images/issuance_summary_chevron.svg | 24 × 24 |
| issuanceSummaryDividerOperation | assets/images/issuance_summary_divider_operation.svg | 151 × 0.5 |
| issuanceSummaryDivider | assets/images/issuance_summary_divider.svg | 166 × 0.5 |
| issuanceTrash | assets/images/issuance_trash.svg | 20 × 20 |

Credit/calendar/trash/plus/chevrons use 20px slots; summary chevron's original 24px SVG is contained in a 20px design slot. Section dashed lines paint at 343×1 with zero layout height; current-card divider paints at 311×.5 with zero layout height. Summary separators flex between actual values and labels, keeping .5px height. Invoice icons remain owned by AppInvoiceIcons with 20px icon slots and an 18px currency slot containing the original approximately 12.8px glyph.

App-side callsites are in issuance_sections.dart; Stepper's ring assets are in its package source. Runtime Dart contains no temporary Figma asset URLs and no screenshot used as an implementation asset.

### 13.5 Retained differences and assumptions

| Item | Precise difference / limit | Reason / future action |
| --- | --- | --- |
| Disabled primary footer | Current AppButton uses Gray100 #F5F5F5 with no shadow; Figma uses Gray200 #E9EAEB plus Shadow/xs. Foreground Gray400 matches | Existing disabled behavior retained. Add an opt-in disabled appearance/token if reviewed; do not replace package defaults globally |
| Invoice divider layout | Existing .5px divider slots yield 239px expanded / 130.5px collapsed; authored zero-height divider layout is 238px / 130px | Shared default retained. Future compatible zero-height divider variant can remove the 1/.5px difference |
| Delivery Stepper title | Supplied delivery frames repeat the selection title; implementation uses the actual delivery-information title | Copy correction for the active phase; next label remains confirmation/payment |
| Nonphysical sample | Figma shows enabled Next with no account/type selected; implementation disables it | Explicit user correction overrides the sample |
| Summary account | Confirmation sample uses a different account from the selection frame; implementation shows the selected account | State-driven UI |
| Fee total | Sample 1.3M conflicts with row sum 1.6M; UI derives 1.6M, or .6M without delivery | Mock numbers kept coherent; real bank quote remains required |
| Terms | Reference shows checked state; initial consent is false and must be checked | User action is required; official terms callback/content is not connected |
| Nonphysical Stepper numbering | Selection 1/3 jumps to confirmation 3/3, with delivery skipped | Three defined milestones retained; confirm future 2-step renumbering if product requires it |
| Extra forms/states | Add address, recipient/agent enabled content, loading/errors/completion have no supplied frames | Existing primitives used; detailed design review remains open |
| Native bars / rasterization | OS bars are reserved, not drawn; SVG/Flutter shadow antialiasing can differ from Figma | Device review is separate from these widget previews |

AppDepositCard/AppPrimaryNavigation and earlier Dashboard issues are not changed by issuance. Their existing audit remains in Dashboard documentation. This task does not certify previously edited cards, textures, filters or unrelated component states.

## 14. Localization, Persian Support, and Dates

All new app copy is in app_fa.arb, app_en.arb and app_ar.arb, including conditional field labels, fees, errors, terms and completion. Existing dashboard loading/error/retry and back labels are reused. Stepper accessibility copy uses the parameterized issuanceStepSemantic(current,total,title). Shared invoice wallet statuses and compact address delete semantics receive localized copy.

Layout is RTL in every locale. Physical left positions are used only where the design fixes the ring, assistant or value/icon slot. Numeric strings use LTR reading order; CurrencyFormatter shows Persian digits and comma grouping. DigitNormalizer converts Persian/Arabic numeric input before validation. Mock expiry is already a Jalali display string; a real date mapper is not implemented.

## 15. Routing and Guards

Core openCardFeaturesService now allowlists card-issue and card-reissue in addition to existing card-list/card-virtual/card-expired-gift. Dashboard's explicit callbacks still take precedence. Deposit action context forwards the selected deposit number; the catalog preselects only a normalized exact match. An unmatched Dashboard/sample number leaves the required selector empty. No account is inferred from an IBAN.

The standalone Cards reissue action opens CardIssuanceScreen when no host onActionRequested callback is supplied. It forwards linkedDeposit as initial context. The existing callback contract is unchanged. Assistant navigation from this nested route pops issuance first and then invokes the Cards host callback, allowing the core bridge to return to Dashboard rather than leaving the card list over it.

Within the flow, top/system Back goes confirmation → delivery → selection; for nonphysical it goes confirmation → selection. Selection Back pops the route. Submission locks Back and editing; completion can close the route. onCompleted receives the typed receipt once when state becomes submitted. onTermsRequested and onAssistantPressed are host callbacks. Missing terms content shows an integration message instead of inventing legal text.

## 16. Testing Strategy

Test sources: test/card_issuance/card_issuance_cubit_test.dart and card_issuance_screen_test.dart. Twelve Cubit cases cover required selections, both physical paths, conditional identities, normalization, add/delete validation, unknown IDs, empty/error/retry, balance gate, duplicate submission/edit lock, retry preservation, stale loading and initial account normalization.

Eighteen widget cases cover seven flow states, two library Stepper samples, interactive selectors/nonphysical/terms/mock completion, address form validation, empty/error/retry, three locale/large-text cases, allowlisted routing, Back/delete cancel/confirm, and nested Cards reissue/assistant return.

Frame assertions check Stepper y104/42px, body/summary y172 and footer y712/44px. Actual pixels in the ring slot must contain the foreground and, before completion, the gray track. Explicit rootBundle loads catch missing package assets. Previews load real fonts and enable native shadows during capture. Existing global asset tests check unique paths and non-empty bundling.

Regenerate all nine review images:

```powershell
flutter test --dart-define=UPDATE_ISSUANCE_PREVIEWS=true test/card_issuance
```

Package: test/widgets/app_stepper_test.dart checks original asset loading/42px geometry/physical side, accessibility copy, narrow wrapping and standard-versus-issuance toggle behavior. Existing package regression suite and example mapper/gallery tests are run as well. Both analyzers and git diff --check are required. Previews are review artifacts, not runtime assets or golden baselines.

Validation results: full application suite 165 passed; final issuance suite 30 passed; full avp_ui suite 111 passed; final Stepper/Toggle regression suite 7 passed; example gallery/mapper suite 2 passed. Both final analyzers report no issues. Both git diff --check checks pass, all relative documentation links resolve, and both guideline additions are identical. All nine regenerated previews were visually reviewed.

No bank endpoint, payment execution, production identity verification, persistent address update, native device build or release deployment is verified by these tests.

## 17. Development and Code Review Process

Review domain/state separation, required selections under every toggle state, omitted request fields, stale-response guards and duplicate-submit behavior. Review both package and app diffs together, including asset declarations and public exports. Existing defaults must remain compatible; a visual variant must be explicitly chosen by the consuming feature.

The complete package change inventory is in the separate dated audit. The earlier uncommitted UI snapshot remains historical. No files are committed or published by this task.

## 18. Environments, CI/CD, and Release

No environment, secret, CI pipeline or release setting changes. CI/workspace setup must include the updated avp_ui sibling. For a published dependency, release/pin a version containing these APIs/assets before integrating the app. A real adapter should be injected through repository; the default remains mock until integration is explicitly supplied.

## 19. AI Assistant and Agent Layer

AppAssistantButton reuses existing artwork and invokes the host callback. It does not trigger submission or a new AI backend. The standalone fallback navigates back; core route callbacks restore Dashboard/prompt behavior. Assistant navigation is separate from payment state.

## 20. Open Items and Dependencies

- Authoritative account/card/address IDs, eligibility and supported issuance types.
- Official terms content/version and what server acceptance evidence is required.
- Selection-dependent quote/balance updates, fee availability and delivery-fee policy.
- Production request IDs, retry idempotency, timeout/error mapping and real receipt behavior.
- Durable address create/delete and required local-versus-server address origin metadata.
- Confirm recipient national-ID checksum/mobile rules and bank-agent verification.
- Detailed designs for add-address and enabled recipient/agent forms, mock completion replacement and insufficient-balance action.
- Confirm skipped-delivery Stepper numbering and the corrected delivery heading.
- Review opt-in disabled button appearance and zero-layout-height invoice dividers if exact raster equality is required.
- Device keyboard, screen-reader, large-text and multilingual visual review beyond tested reference sizes.

## 21. Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.0.0 | 2026-10-09 | Add package Stepper and Figma name mapper registration; compatible Toggle/Invoice/AddressCard variants; connected Resalat issuance flow, required nonphysical selections, mock repository/Cubit, routes/localizations, nine previews and component/data readiness audit |
