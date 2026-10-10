# Password Services Development Document

**Date:** 2026-10-10  
**Status:** Feature 1 implemented with a mock repository and real sample-video playback. Bank password changes, KYC capture and SMS execution are unconnected.  
**Scope:** The section has three planned flows; only first-time second-password setup was specified and implemented in this change. First-PIN and forgotten-password flows remain separate future features.  
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

card-password and card-pin-second-set are allowlisted. Dashboard forwards selected BankCard.number for an exact normalized catalog match. Supplied host service/action callbacks still take precedence. First-PIN and forgotten-password IDs are not accidentally opened as setup. System/top Back navigate to the previous step; exit from the selected first step asks for discard confirmation. Submission locks Back; receipt dismissal exits. The existing Navigator prototype is retained; production auth/security/platform guards are still unimplemented.

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

Bank OpenAPI/identity/fee/terms contracts; first-PIN and forgotten-password flow designs; active-validation ownership/reuse policy; national-card serial versus receipt-code formats; known-date PIN policy; real capture location and evidence; real instruction video; final receipt/SMS copy; device/web playback and keyboard accessibility checks.

## 21. Change Log

2026-10-10: Implement Feature1's eight phases, reusable real video player, compatible controls, package name mapper/app mapping/guidelines, domain/Cubit/mock repository, routes, localizations and14 previews. Features2/3 and real bank execution remain outside the supplied designs.
