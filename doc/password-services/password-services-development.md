# Password Services Development Document

**Date:** 2026-10-10  
**Status:** Feature 1 implemented with a mock repository and real sample-video playback. Bank password changes, KYC capture and SMS execution are unconnected.  
**Scope:** First-time second-password setup, forgotten second-password recovery and change-password requests share the same flow. Recovery/change add an operation selector; change asks for the current PIN and submits directly from the password form. First-PIN handling remains outside this implementation.
**References:** [architecture](../architecture-smart-virtual-counter-v2-en.md), [UI-first policy](../avp-ui-first-implementation-policy.md), [integration guide](../main-app-integration-guide.md), [review gallery](../password-services-review/index.html).

## 1. Architectural Goals and Principles

Presentation composes existing shared/package widgets. Immutable Equatable state owns selection, draft and transitions; pure PIN/serial validation lives in core/validators. Domain use cases form the repository/error boundary. The video player has no bank logic. The explicit request to simulate Phase 6 takes precedence over the recorded-video picture.

## 2. Product Scope and Target Platforms

| Phase/state | Figma node | Current behavior / preview |
| --- | --- | --- |
| 1 Empty selection | 27997:10930 | [Selection](../password-services-review/selection-empty.png); card type, card and password selectors |
| 1 Card types | 27997:11039 | [Four choices](../password-services-review/card-types.png) |
| 1 Card numbers | 27997:11068 | [Card list](../password-services-review/card-numbers.png); stable IDs, original numbers |
| 1 Password types | 27997:11094 | [Type explanations](../password-services-review/password-types.png); First PIN reports unsupported; second enters Feature 1 |
| 2 No open validation | 27997:10942 | [Filled selection](../password-services-review/selection-filled.png), read-only operation, 1,300,000-rial fee and 2,000,000-rial sample wallet |
| 2 Open validation | 27997:12028 | [Pending sheet](../password-services-review/pending.png); flow stops before PIN entry |
| 3 Empty / filled PIN | 27997:10957 / 27997:11008 | [Empty](../password-services-review/password-empty.png), [filled](../password-services-review/password-filled.png); secure PIN/confirmation, live rule indicators, explicit consent |
| 4 Empty / filled ID serial | 27997:10988 / 27997:10998 | [Empty](../password-services-review/serial-empty.png), [filled](../password-services-review/serial-filled.png) |
| 5 Instructional video | 27997:11891 | [Player](../password-services-review/instruction.png); original Figma poster and injectable sample MP4 |
| 6 Mock recording | 27997:11915 | [Mock preview](../password-services-review/recording.png); explicit demo confirmation and reset; no camera/microphone permissions or recording |
| 7 Submission receipt | 27997:11933 | [Submitted](../password-services-review/submitted.png); tracking and explicit mock notice |
| 8 Approved re-entry | 27997:11960 | [Approved](../password-services-review/approved.png); repository-supplied status and tracking |

All nodes are in the supplied Mobile file nYQNyZdSs98lwymCpt5Sag. The reference viewport is 375×812 with 24/40px safe areas. OS bars are reserved, not drawn. Android/iOS/web are the media plugin's supported app targets; no native device is connected for playback certification.

## 3. Technology Stack

Existing Flutter/flutter_bloc/Equatable/Result/ARB/flutter_svg composition. New avp_ui dependency: Flutter's official video_player 2.14.1, with native Android/iOS and web implementations. Public controller types are exported from avp_ui. No camera/KYC/payment SDK is added.

## 4. Development Environment and Versions

Existing SDK constraints are retained. The user's current absolute avp_ui path in pubspec.yaml is preserved. Package and app source updates are required together. Lockfiles record the resolved player implementation versions. Android release manifest now includes INTERNET for streaming; no broad iOS HTTP exception is needed for the HTTPS demo.

## 5. Third-Party Dependency Governance

video_player is flutter.dev-published, BSD-3-Clause and supplies the actual platform media engines. Building three engines in-house is unjustified. Chewie would duplicate the authored controls; media_kit introduces a larger engine stack. See the package guideline for platform requirements. The example video is a 10-second clip of Big Buck Bunny, (c) 2008 Blender Foundation / www.bigbuckbunny.org, CC BY 3.0 ([license](https://peach.blender.org/about/)). Runtime displays attribution and labels it as a demo, not official KYC instructions.

## 6. Project Structure and Modularization

```text
lib/features/password_services/
  password_services.dart
  domain/password_data.dart                   immutable summaries, payload and repository
  domain/password_usecases.dart               load/status/submit exception boundaries
  data/mock_password_repository.dart          catalog and in-memory status/receipt store
  presentation/cubit/second_password_cubit.dart state, gates, stale-response/submission guards
  presentation/second_password_screen.dart    composition and controllers
  presentation/password_sheets.dart          selection/status sheets
lib/core/validators/second_password_validator.dart
lib/core/router/card_features_navigation.dart allowlisted entry
avp_ui/lib/widgets/media/app_video_player.dart
avp_ui/example/lib/figma_name_mapper.dart      searchable package mapping and preview
```

Dashboard card summaries remain separate. The core navigation bridge owns the prototype mock status repository across route entries; it retains receipts only, never passwords/serials. The app-side Figma-name mapping is doc/shared-component-figma-mapping.md.

## 7. Layering Pattern

Screen -> Cubit -> LoadPasswordCatalog/CheckPasswordRequest/SubmitSecondPassword -> PasswordServicesRepository -> mock adapter. Domain files have no Flutter/avp_ui imports. The adapter must supply stable account IDs, eligibility, known birth/expiry PIN candidates, fees/balance, status and tracking. UI controllers are created/disposed in views, not state. Unexpected repository exceptions become coded UnexpectedFailure.

## 8. Service Flow and Request Lifecycle

```text
load -> selection(type + card + second password)
  -> status read -> pending/approved sheet OR password
password + equal confirmation + accepted terms -> serial
valid serial -> instruction -> explicitly confirmed mock recording
submit -> pending receipt OR editable recording with retry
re-entry -> fresh status read -> pending or approved sheet
```

This is a connected prototype, not the final bank ServiceFlow/resumption contract. Local drafts are route-local. Status reads happen before new-request eligibility/balance gates, so pending/approved re-entry remains possible for an already-configured card or an insufficient wallet. A None status only enters PIN setup if the card is eligible and the balance is adequate. The UI never approves its own request. Approved state comes from the repository; the preview injects an approved record. Default mock submission creates Pending and keeps it across route entries. No timed auto-approval is invented.

## 9. Security and Privacy

PINs are truly obscured by the underlying TextField; visibility toggles are local UI state. Autocorrection, suggestions and IME personalized learning are disabled. Sensitive state disables Equatable stringification; payload toString is redacted. PIN, confirmation and serial are cleared after successful mock submission. Runtime introduces no financial persistence, logging or analytics.

Phase 6 never opens a camera or microphone; it confirms a labeled static sample. The resulting kycReference is explicitly mock-kyc. A production adapter must reject mock evidence and receive genuine verified evidence through an agreed bank KYC contract before executing anything. Visual eligibility is not authorization.

## 10. Network and Authentication

Only the sample HTTPS MP4 is streamed. The bank repository has no invented endpoint or authentication. Replace load/status/submit through an injected PasswordServicesRepository after defining the OpenAPI contract and genuine KYC orchestration. Active validation is bank/user policy; cardId supplies request context and must not be mistaken for an authoritative user-level eligibility rule. Fee/balance display is a hint; server quote/authorization remains required.

## 11. Error Handling

Load rejects duplicate/blank IDs and negative monetary values. Err and thrown exceptions remain errors, never Success(empty). Empty catalogs have Retry. Status-read failure keeps the selection; submission failure keeps the entered data and exposes retry through the submission action. Raw exception messages and PINs are not displayed.

## 12. State Management and Validation

Statuses: initial/loading/ready/checking/submitting/failed/empty/submitted. Steps: selection/password/serial/instruction/recording. Outer builds track structural state; fields/rules/footer use limited Bloc rebuilds and controllers stay view-owned. Generation counters reject stale load/status/submit completions and completions after close. Checking/submitting lock edits and Back. Status is set before awaiting, preventing duplicate sends.

PIN rules: 4–6 Latin digits, no whole ascending/descending sequence (including wraparound), no repeated digit/block pattern, and no exact match in adapter-provided known-date candidates. This does not infer a birth date. A production bank validator must provide authoritative rules and date candidates. Persian/Arabic digits normalize before validation. Confirmation must match; edits clear consent. Errors appear on focus loss; indicators update immediately.

Serial prototype rule: 4–20 alphanumeric characters, exactly one Latin letter and at least one digit. It accepts the supplied 3R12345678 example. Receipt-code formats remain bank-defined and must not be generalized from this visual alone. Back retains fields; enabled submission also requires explicit mock-video confirmation.

An idempotency key identifies the submission intent. It is reused on unchanged retry. Changing password/serial creates a new key before submission; it is not reused for a different payload. Server enforcement is unimplemented.

## 13. Design System and Figma Audit

Reused: AppTopBar, AppInvoice, AppBottomSheetHeader; package AppSelect/AppTextField/AppCheckbox/AppButton, tokens and font. New AppVideoPlayer owns playback controls/original play SVGs. AppPasswordServiceColors owns instance colors. Existing defaults remain intact.

Compatible app extension: AppInvoice.borderRadius and zeroHeightDividers reproduce the authored invoice without altering existing defaults. Compatible package extensions: secure field properties; optional AppSelect.menuBuilder for the authored full-width sheet; optional disabled primary service appearance (Gray200/xs). Video square is343px/radius8; bottom track8px and Play16px; poster uses the original image/crop; camera notice is BlueGray100. Runtime videos preserve their full frame with letterboxing where aspect ratios differ.

App assets are original Figma exports in flat assets/images and registered in AppAssets. Instruction image1092×1560 uses the authored142.86% height/-11.62% top crop. Recording image472×398 uses cover in the square preview. Active/inactive check20px; PIN eye20px; serial info14px; camera info20px; mock Play20.903×22.803; success57.0045×59.9961. Selection and request-status sheets preserve their separate original375×812 scrim exports. Byte-identical option/section divider exports reuse cardFeaturesDivider/issuanceDivider. No screenshots become runtime assets. No temporary Figma URL appears in Dart.

Retained/corrected differences:
- The original modal SVG has unsupported foreignObject/displacement filters; its supported scrim plus native sigma2 backdrop blur render. The advanced authored texture is not exact.
- AppInvoice opts into compatible borderRadius=zero and zeroHeightDividers=true, matching the white square-corner/zero-height instance. Existing16px/.5px defaults and other consumers remain unchanged.
- The record page includes explicit mock disclosure/confirmation. It is a placeholder, as requested, not a video of the user. The sample player's attribution is additional truthful demo copy.
- The first-PIN option is visible with authored explanation but reports unsupported rather than entering Feature 1.
- Later Figma sheets describe mobile-bank credentials/SMS, while this task is second-password setup. The authored copy is preserved with an explicit mock-result notice; production wording requires product confirmation.
- The supplied password-length label is4–6 digits. This is implemented as a prototype rule, pending the bank's authoritative policy. Online-transaction threshold text is authored reference copy, not a verified current banking limit.
- Native controls are omitted from previews. Shared font metrics, card-number presentation and remaining pre-existing card/nav differences are not recertified.

## 14. Localization, Persian Support and Dates

All new copy is generated from fa/en/ar ARBs. Layout stays RTL in every locale. Identifiers stay strings; input normalization does not change copy values. Player timeline is physically LTR for time progression. Domain date candidates are normalized strings supplied by adapters, not converted Jalali domain dates. The package owns IRANYekanX fonts.

## 15. Routing and Guards

card-password, card-pin-second-set, card-pin-second-forgot and card-pin-second-change are allowlisted. Dashboard forwards selected BankCard.number for an exact normalized catalog match. Supplied host service/action callbacks still take precedence. The forgot-second-PIN route enables operation selection on the same screen. First-PIN IDs remain unhandled. System/top Back navigate to the previous step; exit from the selected first step asks for discard confirmation. Submission locks Back; receipt dismissal exits. The existing Navigator prototype is retained; production auth/security/platform guards are still unimplemented.

## 16. Testing and Visual Review

Focused unit/widget tests cover validators, consent, digit normalization, eligibility/balance, open/approved status, duplicate submission/edit lock, retry key preservation, stale responses, disposal, mock re-entry, every frame, secure fields, selectors, serial entry, mock confirmation/receipt, Back, route allowlisting and320px/1.3-scale fa/en/ar interactions. Package tests cover actual controller commands, seeking, completion/replay, initialization failure/retry, replacement/disposal and lifecycle pauses, plus compatible controls. Review captures precache both original images and reserve physical system-bar space even when the invoking field is inside SafeArea.

Regenerate:

```sh
flutter test --dart-define=UPDATE_PASSWORD_PREVIEWS=true test/password_services
```

Gallery PNGs are review artifacts, not golden acceptance tests. Actual MP4 decoding on native devices/browser and real bank requests are not verified by widget tests. Verification: full application suite196 passed; full avp_ui suite118 passed. After the final opt-in placeholder-direction change, all20 feature widget tests and26 package field/control/player tests passed again. The example mapper/galleries include a dedicated Video player search/preview test. Both app and package analyzers report no issues. Both git diff --check checks pass. All14 previews are generated from app code with production fonts; posters are precached and retained layers are raster-warmed before capture. New documentation links resolve; the guideline additions in both repositories are identical. No connected Android device is available, so native streaming/decoding remains unverified.

## 17. Development and Code Review

Review app and sibling package together. Check real obscureText/IME settings, immutable collections, raw-number matching, status branching, explicit mock evidence, error preservation, submission lock and retry identity. Do not interpret green rule icons/mock approval as real identity verification. Preserve unrelated local pubspec changes.

## 18. Environments, CI/CD and Release

No SDK, flavor, signing or CI migration. Both checkouts must ship together; the package dependency adds platform plugin implementations. Android release streaming now has INTERNET; iOS requires HTTPS; web host must support media/range/CORS. A source URL can be injected instead of the publicly hosted demo. Production KYC/terms/quotes/authentication remain external integration work.

## 19. AI Assistant

No assistant backend or conversational execution is added. Future assistant fallback should use the same bank service contract, with genuine KYC and server authorization.

## 20. Open Items and Dependencies

Bank OpenAPI/identity/fee/terms contracts; first-PIN flow designs; active-validation ownership/reuse policy; national-card serial versus receipt-code formats; known-date PIN policy; real capture location and evidence; real instruction video; final receipt/SMS copy; device/web playback and keyboard accessibility checks.

## 21. Change Log

2026-10-10: Implement Feature1's eight phases, reusable real video player, compatible controls, package name mapper/app mapping/guidelines, domain/Cubit/mock repository, routes, localizations and14 previews. Features2/3 and real bank execution remain outside the supplied designs.


## Shared forgot-password operation (2026-10-10)

Figma `27997:12254` is the empty operation selector, `27997:12269` its two-option sheet, and `27997:12324` the selected forgot-password state and fee. `SecondPasswordScreen(selectOperation: true)` uses the same screen/Cubit/forms/video/mock KYC/status sheets as setup. Dashboard `card-pin-second-forgot` forwards the selected card into this mode. Setup remains the default mode with the read-only Set second password operation.

`PasswordOperation` contains setSecondPassword, changePassword and forgotPassword. The recovery selector offers Change password and Forgot password, as authored. Forgot password follows the existing serial/video/mock KYC steps. Change password uses the current/new/confirmation form and submits directly from that step (see the change-password section below). The operation is required before Next and is passed to both status reads and `SetSecondPasswordRequest.operation`. Existing payload constructors and status calls default to setup. Repository adapters must accept the optional named operation on `status` and dispatch the submission using its operation.

Card adapters supply `canSetSecondPassword` for first-time setup and `canResetSecondPassword` for recovery/change (the demo defaults to true). Existing PIN ownership alone cannot prevent recovery. Card/kind changes clear operation selection; operation changes clear credentials, terms, recording confirmation, status/failure and the idempotency key. Busy state prevents operation changes. Mock status is scoped to card and operation; neither credentials nor video are retained. Approved/pending receipts remain readable before eligibility and wallet checks, as in setup.

The operation field begins at y434 and is 70px tall, with an 8px label gap, 44px input and 20px spacing. Its sheet begins at y552 in a 375×812 view with 24/40px system insets. Chevron/divider artwork is byte-identical to existing assets; the authored operation-sheet scrim is stored as password_operation_scrim.svg and combined with the shared native blur. These three selection states use the white Figma surface. The two “Operation type” labels reproduce the provided frames. Next is disabled until operation selection, even though the empty design depicts a blue button. The sheet design shows a partially obscured legacy fee while its operation is empty; the implementation consistently shows the shared invoice only after a valid operation selection.

Review [28 rendered states](../password-services-review/index.html), including operation-empty, operation-sheet and operation-forgot. Banking and recording remain mocks; the public demo video remains in use.


## Change-password branch and returning status (2026-10-10)

The shared operation selector now connects to a complete Change password branch. Card Services includes a Change password item (`card-pin-second-change`) for testing. It opens `SecondPasswordScreen(selectOperation: true)`; choose the card, second password and Change password. No separate screen/controller or package widget is introduced.

| Order | Figma node | Rendered state |
| --- | --- | --- |
| 1 | 27997:11595 | change-selection-empty |
| 2 | 27997:11607 | change-card-types |
| 3 | 27997:11666 | change-card-numbers |
| 4 | 27997:11722 | change-password-types |
| 5 | 27997:11777 | change-operation-empty |
| 6 | 27997:11791 | change-operation-sheet |
| 7 | 27997:11844 | change-selection-filled |
| 8 | 27997:11858 | change-password-empty |
| 9 | 27997:12547 | change-password-filled |
| 10 | 27997:11994 | change-submitted (bottom sheet) |
| 11 | 27997:12046 | change-status (full screen on return) |

The change selection omits the fee invoice and wallet gate, matching 27997:11844. Change uses card reset eligibility and the same request-status read before starting. The white form begins at y104; current PIN/new PIN/confirmation inputs start at y144/y228/y292, each44px tall, with the existing zero-height dashed divider after current PIN. All three are secure fields with independently controlled visibility, Latin numeric values, Persian/Arabic normalization, max6 digits, disabled keyboard suggestions/autocorrection/personalized learning. Current PIN needs4–6 digits; the new PIN also satisfies existing sequence/repetition/known-date rules. Current input changes clear terms and retry identity. The filled+accepted form labels its primary action Submit request. There is no serial or instructional/recording video stage for change in this supplied sequence.

`SetSecondPasswordRequest.currentPassword` is optional for other operations and required for change. Change sends empty serial and KYC-reference strings with its operation; production adapters must route this to their actual change-password endpoint. Both PINs remain ephemeral and redacted from diagnostics and are cleared after success. The mock checks current PIN format only: it does not compare against a bank PIN, send SMS or change credentials. It retains only the card/operation status and receipt. Retry/duplicate-send/disposal guards remain shared.

Newly submitted change requests show the authored success bottom sheet (57.0045×59.9961 badge; y476 badge in a375×812 viewport), localized change-success body and tracking code. Dismissal exits. A later status read for the selected change operation renders `PasswordStatusContent` in the existing screen, with no bottom sheet. Pending uses the authored registration/pending-SMS copy; approved uses change-success copy. It has a95.0099×99.9961 original badge at y124,40px gap to title,20px content gaps, subtle44px tracking row and footer Understood. Back/Understood exit to the parent. Selecting the operation on a returning route is still required; a selected Dashboard card is normalized and prefilled as before.

Figma retains several prototype inconsistencies: older card/password option-sheet backgrounds display setup/fee values; the implementation consistently keeps the current operation selection. The prompt's duplicated Persian “رمز” is corrected. The empty operation design shows an enabled button; actual Next requires operation selection. The submission sheet says change succeeded while the return frame contains pending identity/SMS copy; the mock stores pending and reproduces the respective presentation without claiming a real bank result. Native system bars are reserved rather than drawn. Explicit demo notices appear for mock results, so production-like preview fixtures suppress only their mock flag.

Static current-field eye/check/divider and sheet badge SVGs are byte-identical to existing artwork. The100px badge and change-sheet scrim are original downloaded assets (`password_status_success.svg`, `password_change_scrim.svg`); native blur handles the SVG filter unsupported by flutter_svg. Static geometry and effective callsites are covered in the11 new render tests, along with three320px/1.3scale locale tests and a true mock repository submit/reenter/exit test. Setup/forgot tests continue to cover their original longer path.
