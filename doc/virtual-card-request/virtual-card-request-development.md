# Virtual Card Request Development

## 1. Purpose

Implement the supplied empty and completed request forms using shared UI and a replaceable repository. This prototype does not issue cards or debit a wallet.

## 2. Design scope

Figma file nYQNyZdSs98lwymCpt5Sag: empty `27997:10100`, filled `27997:10897`. [Rendered empty and filled forms](../virtual-card-request-review/index.html). No subsequent receipt screen or KYC sequence was supplied. After successful submission the flow returns directly to the main page without a dialog.

## 3. Stack

Existing Flutter, flutter_bloc Cubit, Equatable, Result/Failure, flutter_svg, public avp_ui components and generated fa/en/ar localization. No new dependencies.

## 4. Entry points

Dashboard Card Services and deposit quick actions use `card-virtual`, now opening `VirtualCardRequestScreen` and forwarding a selected deposit if available. `card-virtual-request` is an alias. Existing card lists remain reachable through Cards/category chips; `card-virtual-list` explicitly opens the Virtual category. Its Request virtual card footer opens the form. Supplied host callbacks continue to take priority.

## 5. Feature boundaries

The request is under `lib/features/virtual_card_request`, independent of card listing and physical card issuance. Public exports: screen, typed repository/catalog/deposit/quote/request/receipt and mock adapter. No private avp_ui import or new package widget is needed.

## 6. Structure

Domain data and use cases live under domain/, mock adapter under data/, Cubit under presentation/cubit/, and the route composition under presentation/. Controller lifecycle and navigation belong to the screen; request/quote/consent state belongs to Cubit.

## 7. Repository contract

`load()` returns selectable deposit IDs/numbers, indicative unit fee and count limit. `quote(depositId, count)` returns a quote ID, binding, unit fee, total and wallet balance. `submit(VirtualCardRequest)` uses that exact quote and an idempotency key. The app treats adapter quotes as display data, not payment authorization. A production endpoint must validate ownership, eligibility, quote freshness, limits, balance and consent atomically.

## 8. Sample fees and discrepancies

The empty Figma notice says41,250 per card. The completed four-card frame says300,000 per card and quotes1,300,000 total, rather than1,200,000. Mock data preserves both authored states. It explicitly provides the four-card1,300,000 quote; other sample quantities use300,000 per card. This is illustrative, not a tariff. No hidden100,000 fee or real charge is inferred. Production fees and the count cap must come from the adapter; mock maxCount is999.

## 9. Loading and validation

Loading, failed and empty catalogs have separate UI states with Retry. Load validation rejects blank/duplicate deposit IDs, blank numbers, negative indicative fees and invalid count caps. Exceptions map to UnexpectedFailure. Quote validation rejects blank tokens, wrong deposit/count bindings and negative money values.

## 10. Editing

Deposit selection is restricted to the loaded catalog. The count input normalizes Persian/Arabic digits, accepts digits and allows up to6 characters. State requires a positive integer within the adapter limit. Zero/out-of-range counts show localized errors. Selection/count edits clear the quote, accepted terms, previous failure and retry key.

## 11. Quoting

Valid edits trigger a quote. Generation guards reject old quote/load results and suppress completions after disposal. Edits remain possible while quoting; terms and submission wait for the current result. Failed quotes expose Retry and require fresh consent after recovery. No stale quote can authorize a changed selection.

## 12. Invoice

The initial per-card notice becomes the existing expandable AppInvoice when a quote is available. Expanded shows the quoted total, per-card fee, wallet balance and sufficient/insufficient status. Collapsing keeps total and wallet. `zeroHeightDividers: true` produces the authored174px expanded/130px collapsed sizes. White surface,16px corners and Gray500 labels are opt-in instance values.

## 13. Terms

The localized linked terms text calls an optional host callback. With no supplied official document it reports that terms await service integration. The checkbox can be toggled before selection; each selection/quote change clears it. Submission requires the current quote plus consent, and remains disabled during quoting/sending.

## 14. Submission

Submission requires a current valid quote, count, deposit, sufficient wallet and terms. It locks editing and Back before awaiting the repository and ignores duplicate sends. Failed submission keeps the same idempotency key for a retry; changing request data replaces it. Success invokes the optional typed callback with the receipt and returns to the first/main route, closing both the request and any intermediate card-list route. No confirmation dialog is shown. Execution remains mocked; no card is issued and no payment occurs.

## 15. Security

No actual bank endpoints, camera, permission prompts, credential storage or wallet debit are added. Runtime state remains in memory. Server-side authorization and authoritative fee/quote verification remain adapter responsibilities. The mock accepts only quotes it previously issued and supplies idempotent demo receipts.

## 16. Component reuse

AppTopBar, AppSelect, AppTextField, AppCheckbox and AppButton remain shared components. AppInvoice remains app-owned shared composition. Existing blueGray100 palette and typography/radius tokens implement notices. Exact info-circle artwork reuses password_camera_info.svg because it is byte-identical to the virtual-card Figma asset. This filename reuse does not couple business flows.

## 17. Asset fidelity

The parent export initially referenced base bars/print component artwork, while the rendered instances use angle-right-small/Virtual Card overrides. Context was read for the actual instance nodes `I27997:10898;13867:8754;13867:8738` and `I27997:10915;16662:54695`. Original downloaded assets are virtual_request_back.svg (24×24) and virtual_request_card.svg (16.2878×12.9544). The latter occupies the authored20px slot at8.33% left/16.67% top. No SVG paths are modified or screenshots used as implementation assets. Existing chevrons, dashed divider, money glyphs and invoice controls are reused.

## 18. Layout and localization

All locales are RTL-first. Numeric input values use LTR with physical right alignment. The body starts at y104 with16px side padding. At375px the prompt is40px, notice74px (y164), deposit selector70px (y258), count44px (y374), dashed divider y438, invoice174px (y458). The empty preview reserves24/40px native insets at375×814; filled uses375×812, matching the respective footer anchors. Content scrolls on narrow/large-text displays; native system bars are not drawn. Corrected spacing and localized separators can differ from mixed-digit prototype strings.

## 19. Verification

Six unit cases cover validation, quote ordering/binding, consent/wallet, retry identities and duplicate locks, empty/error/retry, initial deposit normalization, latest loads/disposal and mock idempotency. Eight widget cases cover both geometry snapshots, interactive selectors, Persian/Arabic count normalization, invoice expansion, poor wallet,320px/1.3scale fa/en/ar, service routing and successful return from the virtual-list footer to the main page without a dialog. All14 pass. Existing Cards, Dashboard, invoice and registered-asset suites pass30 regression checks. Full analyzer reports no issues.

## 20. Review artifacts

`doc/virtual-card-request-review/{empty,filled}.png` and index.html. Regenerate with `flutter test --dart-define=UPDATE_VIRTUAL_PREVIEWS=true test/virtual_card_request`. Real package fonts are loaded for captures; screenshots preserve system insets without rendering native bars.

## 21. Remaining integration

Authoritative deposit eligibility/limits, consistent bank tariff, quote expiry/repricing policy, official terms/version, production receipt/card-list refresh and any bank-required KYC remain undefined. A new quote must require renewed consent. The provided two-frame UI is complete with mock execution; it does not claim production banking behavior.
