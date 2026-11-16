# Loan request implementation

**Latest UI review (2026-11-15):** [page-by-page visual corrections](ui-review-2026-11-15.md)
records the renewed 105-frame Figma review, native-width renders, UI changes and
scoped verification. Earlier comparison/correction reports below remain history.

**Latest assessment update:** [live slider classification and native-size Figma
verification](loan-assessment-slider-2026-11-14.md). Current scoped verification:
47 loan tests, 19 related regression tests and 8 shared-slider tests passed.

**Current follow-up:** the owner requested correction of the differences found in
the [105-frame audit](figma-comparison-2026-11-14.md). See the
[correction report](figma-corrections-2026-11-14.md) for the implemented changes,
current tests and remaining bank-content boundaries. The 67/38 split below is
initial access history. Full physical-device/pixel acceptance of all 105 states
is still not claimed.

Owner scope: 2026-11-14. Mock integration explicitly approved. The UI/Cubit/State
contract v1.24 controls implementation. No TLS or live bank changes.

## Request ownership inventory

| Operation | Owning action | Triggers |
| --- | --- | --- |
| Catalog and current request | fetchCatalog | Provider, retry, completion |
| Bound quote | fetchQuote | selectDeposit, selectRepayment, updateAmount, updateMonths |
| Inquiries | fetchInquiries | continueFlow, retry |
| Guarantor check | checkGuarantor | Check button |
| Collateral validation | checkCollateral | Next button |
| Save/resume draft | saveDraft | successful inquiries/collateral |
| Signing challenge | requestSigningOtp | contract acceptance, resend |
| Final submission | submitLoan | OTP confirmation |
| Cancel current request | cancelRequest | confirmed cancellation |

## Flow map

| Step | Reads | Next/back | Scope |
| --- | --- | --- | --- |
| Introduction | video, current request, receipt | start / resume / cancel | same Cubit |
| Assessment | deposit, repayment, amount, months, slider positions/limits, bound quote | inquiries / introduction | same Cubit |
| Inquiries | independent rows and request status | collateral or contract / assessment | same Cubit |
| Collateral | quote, guarantor, own/guarantor instrument | contract / inquiries | same Cubit |
| Contract | summary, insurance, contract acceptance | OTP modal / preceding step | same Cubit |
| OTP | bound challenge, five digits, deadline, submission | receipt modal / contract | borrowed Cubit |
| Receipt | tracking record | introduction | completed form discarded |

Quote changes invalidate inquiries/collateral because they were bound to the old
amount/deposit/repayment. Input changes invalidate their own check result. Ordinary
loading/success does not clear recorded request failures. Back is disabled while
requests are pending. Modal results and step decisions belong to Cubit.

## Design access

Figma file nYQNyZdSs98lwymCpt5Sag, nodes 28180:37941 onward supplied by owner.
The initial inspection reached the Education-plan MCP limit. The subsequent
review retrieved all 105 unique high-fidelity contexts and screenshots. Those
references now drive the visual corrections, including social-credit-core.
Unknown rating and unsuitable ranges remain blocked; the latter follows the
owner's instruction pending designer clarification.

The [figma-design-to-code skill](/Users/mahdi/.codex/plugins/cache/openai-curated-remote/figma/18.0.0/skills/figma-design-to-code/SKILL.md)
controls source fidelity. Access coverage is separate from device visual acceptance.

## Integration boundaries

The repository is an in-memory simulation, not bank lending approval. Credit
thresholds, installment arithmetic, instrument checks and OTPs are mock fixtures.
No bank request, real guarantee, insurance purchase or digital signature occurs.
Official tutorial URL, contract document/download, insurance wording and external
Merat/iCup destinations require approved bank content; no URL is fabricated.
Mock drafts survive route re-entry through the registered repository, not app
restart or another device. Production resume must be server-owned.

## Initial Figma frame access history

Retrieved 67 supplied frames, with screenshots and high-fidelity contexts:

`28180:37941`, `28180:37962`, `28180:37984`, `28180:37995`, `28180:38108`, `28180:38239`, `28180:38390`, `28180:38506`, `28180:39945`, `28180:40405`, `28180:40438`, `28180:40508`, `28180:41160`, `28180:41290`, `28180:41441`, `28180:41669`, `28180:41749`, `28180:41823`, `28180:39282`, `28180:39430`, `28180:38836`, `28180:38952`, `28180:39975`, `28180:40526`, `28180:40544`, `28180:40597`, `28180:41089`, `28180:40647`, `28180:41210`, `28180:41361`, `28180:41521`, `28180:41595`, `28180:39345`, `28180:39408`, `28180:38613`, `28180:38729`, `28180:39915`, `28180:40005`, `28180:40023`, `28180:40070`, `28180:40117`, `28180:40338`, `28180:40174`, `28180:40256`, `28180:40458`, `28180:40781`, `28180:40861`, `28180:40941`, `28180:41015`, `28180:40696`, `28180:40759`, `28180:39059`, `28180:39175`, `28180:39469`, `28180:39585`, `28180:43783`, `28180:43813`, `28180:44139`, `28180:44192`, `28180:44245`, `28180:44298`, `28180:43831`, `28180:43911`, `28180:44065`, `28180:43698`, `28180:43761`, `28180:42854`.

Not retrieved after the connector's Education-plan quota was exhausted:

`28180:43991`, `28180:41897`, `28180:39692`, `28180:42824`, `28180:42013`, `28180:39808`, `28180:42141`, `28180:42257`, `28180:44348`, `28180:44378`, `28180:42872`, `28180:42919`, `28180:42966`, `28180:43187`, `28180:43023`, `28180:43105`, `28180:43254`, `28180:43390`, `28180:43470`, `28180:43550`, `28180:43624`, `28180:43305`, `28180:43368`, `28180:42373`, `28180:42489`, `28180:44481`, `28180:44597`, `28180:44704`, `28180:44734`, `28180:44752`, `28180:44802`, `28180:44882`, `28180:44962`, `28180:45036`, `28180:44396`, `28180:44459`, `28180:42596`, `28180:42712`.

The ordinary tiers and social-credit-core now have their mock flow implementations.
The former uninspected list above is historical and no longer an access blocker.
Unknown tiers and unsuitable ranges cannot progress. Pixel acceptance of every
variant remains separate from the implemented behavior and selected captures.

## Local simulator scenarios

- Default tier: excellent. At ten months, 500,000,000 / 1,500,000,000 /
  2,500,000,000 / 3,500,000,000 rial exercise excellent / fully-suitable /
  suitable / unsuitable ranges. Lump-sum uses the ten-month sample amount bands
  independently of its 4–10 month duration. These are fixture thresholds, not bank rules.
- Mock constructor accepts tier, rejected inquiry and latency. Tests install
  it through DI before creating Cubit; there is no scenario selector in product UI.
- Valid mock guarantor IDs: 0081234562 is not a customer; 0499370899 exceeds
  guarantee capacity; other valid IDs use the explicit simulated recipient.
  Changing guarantor clears the previous guarantor's instrument binding.
- Instrument 1111111111 is rejected. Other 8–20 digit values are simulated,
  not authoritative treasury/cheque ownership verification.
- Test-mode signing accepts any five-digit code. The 60-second challenge and
  repeat request invalidation remain enforced; a repeat request invalidates
  the prior challenge. Submission is bound to the saved draft and idempotent by
  draft ID. A loan-data/insurance change resets consent to the old draft.
- Installment amounts sum exactly to principal. Mock due dates are Gregorian/UTC
  on the 17th of subsequent months; the UI formats them as Jalali. No interest,
  bank calendar or actual installment schedule is inferred. The separate display
  schedule adds an explicit 5,000,000-rial fee fixture, not a computed bank fee.
- Saved mock drafts have an explicit one-minute demonstration expiresAt. Without
  an expiry supplied in data, the UI shows no countdown. Expiry never automatically
  cancels a request. Production expiry must come from the bank contract.

## Shared package and assets

Owner approved the compatible `AppSlider.singleThumb` extension in sibling
`../avp_ui`. Default range behavior stays unchanged. Auxiliary bars paint above
track background. Ship both repositories together. No dependency was installed.
The app uses original Figma poster/icons under `assets/images/loan_request_*`
and existing public avp_ui components. No temporary Figma URL is used at runtime.
SVG filters/foreignObject effects emit renderer warnings; device rasterization
and exact visual matching of every frame remain unverified.

New loan copy currently uses Persian fallback in the three ARB resources;
English/Arabic translations remain a localization follow-up. Existing keys and
translations are preserved. Generated localization changes include generator
formatting; generated files were not manually edited.

## Verification and review

Initial scoped application run (historical: 38 passed; no complete-suite run):

```sh
flutter test --no-pub test/loans test/core/router/app_router_test.dart test/core/di/injection_container_test.dart test/core/config/image_assets_test.dart test/dashboard/implemented_services_navigation_test.dart
```

Latest widget run (4 passed, including unknown credit and 320px viewport with
260px keyboard inset):

```sh
CAPTURE_LOAN_PREVIEWS=1 flutter test --no-pub test/loans/loan_request_screen_test.dart
```

Scoped application analysis completed without issues:

```sh
flutter analyze --no-pub lib/features/loans test/loans lib/core/di/injection_container.dart lib/core/router lib/core/flow/service_registry.dart lib/features/dashboard/presentation/shared/dashboard_services.dart test/core/router/app_router_test.dart
```

Sibling avp_ui verification (6 slider tests passed; analysis without issues):

```sh
flutter test --no-pub test/widgets/app_slider_test.dart
flutter analyze --no-pub lib/widgets/selectors/app_slider.dart test/widgets/app_slider_test.dart
```

Captured previews are under `build/previews/loans/`: introduction, assessment,
contract, contract_sheet, otp and receipt. These cover the main path, not every
Figma frame. Native device playback, full bank signing, platform release builds
and every uninspected branch remain unverified.

Cubit review: 9 application operations have 9 request owners and 9 Result
switches. UseCase fields are registered/final; no Repository dependency or
exception guard is present in Cubit. Independent events retain explicit emits.
Shared step-number, repayment-limit and slider-position calculations are extracted;
two unused State clears were
removed. Remaining invalidations bind quotes, guarantors, instruments and
contract consent to the data the next step actually consumes.

An unexpected submission/instrument error reports a request failure without
falsely labelling a valid OTP or instrument as invalid. Field errors are reserved
for their specific rejection codes. The latest Cubit recheck covers this boundary.


The slider positions are plain State data calculated in Cubit with the catalog
limits; UI constructs Flutter RangeValues directly from those fields. Resuming a
lump-sum draft preserves its 4–10 month limits. Quote requests have no redundant
deposit guard because their actual UI triggers always supply a selected deposit.
Bank identifiers use explicit LTR direction/isolation within the RTL layout.

Latest flow recheck after those changes: 22 tests passed, and scoped analysis
reported no issues:

```sh
flutter test --no-pub test/loans
flutter analyze --no-pub lib/features/loans test/loans
```

Duplication review: 3 repeated calculations found, 3 resolved (step number,
repayment limits, slider normalization). Flow review: 2 clears removed.

Ordinary collateral form errors appear on blur using validity already stored by
the relevant field update. Editing clears that field's visible error. Tests cover
this lifecycle for national ID and both instrument fields.

Initial distinct coverage: 18 Loan Cubit tests, 5 Loan widget tests, 19 directly
related application regression tests, and 6 sibling slider tests. These are scoped
runs, not full-application coverage or device E2E tests. All passed. The latest
loan-flow analysis and sibling slider analysis reported no issues.

Changes remain uncommitted in both the app and sibling avp_ui repositories.

## Assessment slider refresh layout

Refreshing a quote retains the previous confirmed quote for bound operations.
A shared pure Domain calculation publishes the current local assessment before
the request completes, keeping score, monthly payment and credit sections visible. The
progress indicator has a permanent 4px slot. Next remains disabled until the
latest quote succeeds; the installment-table button and credit interactions
also require a successful quote. Current credit colors and classification update
immediately without dimming. Pending credit interactions and their accessibility
semantics remain blocked until confirmation.
The existing request-ID check still rejects older overlapping responses.

A compact-viewport regression test changes both slider callbacks while delayed
quotes overlap and measures slider/credit rectangles, content height and scroll
offset through loading. It also checks disabled actions and latest-result binding.
This is a widget regression test, not physical-device verification.

This correction removes one quote clear and introduces no repeated request
operation, State field, dependency or package change.

Verification: `flutter test --no-pub test/loans` passed all 18 Cubit tests and
the existing four widget tests, but the new widget test initially checked the
previous render before the stream-triggered frame. After allowing that frame,
`flutter test --no-pub test/loans/loan_request_screen_test.dart` passed all five
widget tests, including actual loading-frame geometry assertions. Analysis passed:

```sh
flutter analyze --no-pub lib/features/loans/presentation/request/widgets/loan_assessment.dart lib/features/loans/presentation/request/cubit/loan_request_cubit.dart test/loans/loan_request_screen_test.dart
```

## Current verification after Figma corrections

32 loan tests (20 Cubit and 12 widget tests) and 19 directly related regression
tests passed. Scoped analysis reported no issues. See the correction report for
the exact commands and remaining visual/integration limits. Inquiry results now
flow through a Stream with one owning Cubit action. No full application suite ran.
