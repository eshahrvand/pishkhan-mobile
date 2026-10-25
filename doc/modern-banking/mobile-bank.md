# Modern banking — mobile bank

The requested services live under `lib/features/modern_banking/`, with shared
Domain entities and a `ModernBankingRepository`, a Data adapter and separate
presentation folders for the mobile-bank flow, password guide, transfer limits
and deactivation. The [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md)
governs implementation; older feature examples do not supersede it.

## Entry and ownership

- Existing service ID `modern-mobile` opens `/modern-banking/mobile` from the
  dashboard catalog/drawer through `ServiceRegistry`.
- The drawer's Modern Banking group lists the five implemented mobile-bank
  services: activation, password recovery, password-change guide, transfer limits
  and deactivation. Phone banking and internet banking are not shown in this
  drawer group. Drawer search uses the same localized service labels.
- The additional drawer service IDs are `modern-mobile-password-recovery`,
  `modern-mobile-password-guide`, `modern-mobile-transfer-limits` and
  `modern-mobile-deactivation`; ServiceRegistry dispatches them to the existing
  authenticated routes. The activation drawer label uses `modernActivate`.
- Central `AppRoutes` and `app_router.dart` also declare authenticated routes
  for `password-recovery`, `password-guide`, `transfer-limits` and `deactivation`.
  All five routes participate in the post-login return-location allowlist.
- Screens construct their Cubits directly in Provider.create. Only actual
  repositories are registered in GetIt. The mock repository is a lazy singleton
  so status and changed limits survive route re-entry during an app session.
- Domain/Data dependencies never pass through screen or Cubit constructors.
  The router selects destinations only. States are plain Freezed `.initial`
  factories, part of their Cubit libraries, with independent operation statuses.

## Activation and password recovery

Activation starts with a training-video poster and notices. Both operations
then use the same explicit flow: national-card serial, fees and consent, KYC
training, post-recording preview and submission receipt. The existing central
serial validator is reused. Editing and repeat submissions are disabled by UI
during submission, while Back remains available. Back within the flow preserves
inputs; leaving entered data requires confirmation.

On re-entry, a pending request displays its tracking code and the identity
verification timeline. An approved activation displays the read-only username
card and the four operation shortcuts. Activation and password-recovery records
are independent. Rejected activation permits a new request with an explanatory
notice. Request payloads retain the same idempotency key on retry; changing the
submitted payload creates a new key. Receipt actions navigate home using `go`.

The mock uses no camera, microphone, real identity evidence, wallet debit,
password issuance or SMS. The post-recording screen is an explicitly labelled
design preview. Starting KYC currently advances to that preview; Record again
returns to the instructional stage. A future KYC integration must replace this
transition and the prototype-evidence request contract with bank-approved proof.

No training video files or authoritative URLs were supplied. The app uses the
original Figma posters and the existing AppVideoPlayer unavailable state.
Repository catalog fields accept the future activation/identity video URLs;
the UI owns and disposes their optional playback controllers. No unrelated
sample video is substituted.

## Other services

- Password change is a four-page instructional carousel, with the original
  phone artwork exported from each Figma `mob` node. There are no password
  inputs or password-change requests. PageController belongs to UI; Cubit State
  stores the current page. Swipes and indicator taps update the selected dot.
- Transfer limits first show the repository's current internal/PAYA/SATNA
  limits. Edit exposes three explicit numeric inputs, their maximum values and
  consent. Each action validates only its own field; the submit flag combines
  stored validity. Rial-to-toman values are computed in Cubit. The request is
  bound to the catalog's deposit ID; no deposit selector absent from the supplied
  design is invented. The mock maximum is 2,000,000,000 rials per type and the
  prototype accepts positive integral amounts. Actual limits/policy are bank data.
- Deactivation displays the repository's username as a read-only field with no
  editing callback. The selected typed reason and consent enable submission.
  The mock currently offers the supplied suspected-compromise reason only.
- The actual legal terms were not supplied. The terms link displays this
  unavailability instead of invented banking terms.

## Figma references and deliberate corrections

File: `nYQNyZdSs98lwymCpt5Sag`.

| Surface | Nodes |
| --- | --- |
| Activation | `28084:11567`, `11605`, `11619`, `11633`, `11654`, `11688`, `12133` |
| Pending / approved activation | `28084:12179`, `28093:31974` |
| Recovery | `28084:11712`, `12040`, `12054`, `12075`, `12109`, `12161` |
| Password-change guide | `28084:11726`, `11774`, `11818`, `11861` |
| Transfer limits | `28084:11921`, `11980` |
| Deactivation | `28084:11936`, `11958` |

Static artwork is local and referenced with AppConstants.baseImage. Native status/navigation
bars are not drawn by the application. The existing AppInvoice, request footer,
service grid, top bar and assistant are reused. AppCreditCardMockup gains a
compatible `isCompact` option for the approved 104px card; its default remains
136px. No sibling avp_ui source or package dependencies are changed.

Corrections to inconsistent design samples:

- The fee rows (300,000 + 300,000 + 1,000,000) total 1,600,000 rials, rather than
  the design's 1,300,000. The total derives from repository fee items.
- 20,000,000 rials equals 2,000,000 tomans. Helper text follows this conversion,
  rather than the design's unrelated 200-million-toman example.
- The deactivation header names deactivation rather than the copied transfer
  limit title in Figma. The reason remains a selector as drawn.
- The guide indicator follows the actual selected page, as explicitly requested.
- Prototype evidence and receipt notices make the unavailable bank/KYC boundary
  visible; they are not production confirmations.

## Preview scenarios and verification

Default launch starts with inactive mobile banking. To preview other activation
statuses, restart with one of:

```sh
flutter run --dart-define=MODERN_BANK_SCENARIO=approved
flutter run --dart-define=MODERN_BANK_SCENARIO=pending
flutter run --dart-define=MODERN_BANK_SCENARIO=rejected
```

This is compile-time mock configuration, not a customer-facing debug selector.
All mock records reset when the process restarts. Bank persistence and status
refresh/approval/rejection will come from the future repository adapter.

Focused Cubit tests cover validation, fee arithmetic, request identity, retries,
pending re-entry, separate recovery status, limits and deactivation. Widget tests
cover all supplied stages, loading controls, read-only username, navigation from
approved operations and the guide's swipe/indicator behavior. Narrow English and
Arabic guide layouts are included. Optional captures use the existing ignored
`build/previews/certificates/modern_*.png` test output with
`CAPTURE_CERTIFICATE_PREVIEWS=1`; no preview images are stored in doc.

The focused feature and regression run passed 49 tests, including the shared
banking-channel card, dashboard service navigation, login Cubit, asset integrity,
DI and central routing. Static analysis of the feature, its tests and touched
integration files reports no issues. Device camera/KYC, banking APIs and actual
training-video playback remain outside this prototype verification.
