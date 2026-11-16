# Card blocking and unblocking

Reviewed: 2026-11-09.

Status: implemented with a stateful in-memory demo adapter. No live blocking,
unblocking or wallet API is configured. No actual bank card is changed or real
wallet debited. Completion explicitly uses the existing demo-result text.

## Design references

File: `nYQNyZdSs98lwymCpt5Sag`.

| Operation / state | Frame |
| --- | --- |
| Block, empty | `27997:10165` |
| Block, selected and consented | `27997:10286` |
| Block, final confirmation | `27997:10329` |
| Unblock, empty | `27997:10189` |
| Unblock, selected with previous block details | `27997:10214` |

Both services live under `lib/features/cards/presentation/card_restriction`.
`CardRestrictionOperation` selects the operation; it does not create parallel
form State or a generic field dispatcher. `/cards/block` and `/cards/unblock`
are registered in the central router and post-login destination whitelist.
`card-block` and `card-unblock` service IDs work from the dashboard catalog/menu;
the card-list Block action also supplies its selected card number. Existing host
callback overrides remain supported. The card-list action sheet retains its
existing Block option; Unblock is available through the service catalog.

## Ownership and operations

The screen directly creates `CardRestrictionCubit` in Provider.create and calls
`fetchCatalog`. GetIt registers the repository and both UseCases. DI supplies the
repository; Cubit resolves final UseCase fields. Domain imports neither Flutter
nor GetIt. State is one plain Freezed `.initial`, part of the Cubit library.

| Operation | Owner | Triggers |
| --- | --- | --- |
| Eligible card catalog, reasons and fee/wallet quote | `fetchCatalog` | Provider entry, catalog retry, explicit refresh after submission failure |
| Restriction submission | `submitRestriction` | Unblock primary action; confirmed block modal result |

`requestSubmission` decides whether final confirmation is required. For blocking,
it publishes a consumed typed command; UI displays the existing decision sheet
and forwards the raw nullable result. Cancel, system Back and outside dismissal
do not submit. For unblocking, the primary action delegates directly to the same
submission owner. Every request lifecycle, await and Result switch has one owner.

## Flow and State readers

| Step / event | Readers | Retention and next step |
| --- | --- | --- |
| Catalog | Screen reads status, cards and initial selection | Catalog failures allow retry; missing/ineligible entry number leaves selection empty |
| Selection | Form reads selected card, linked deposit/type and optional block details | Block lists active demo cards; Unblock lists blocked demo cards |
| Reason / description | Form reads explicit typed reason and optional description | Changing card/reason/description revokes consent and disables Submit; payload changes create a new request key |
| Consent | Footer reads consent, canSubmit, editability and operation status | Card, reason, sufficient wallet and consent are required; description is optional |
| Block confirmation | Effect listener opens the existing destructive decision sheet | Consumed before await; dismissal retains form and sends no request |
| Submission | Footer reads loading; form disables inputs; screen blocks both Back controls | Failure retains form, consent, quote and key for retry; refresh can retrieve a new quote |
| Completion | Screen renders demo receipt/reference in place of the form | Submit stays disabled; system/header Back goes home, so the completed form cannot be resubmitted |
| Exit | Cubit selects direct Back or discard confirmation | Cancel/dismiss retains all form data; authorized Back remains set until the route exits |
| Invoice expansion | Invoice reads `isInvoiceExpanded` | Cubit controls expansion; displayed amounts come from the catalog |

Request feedback uses independent entering-failure status listeners. Each failure
publishes status, Failure and prepared message together. Stored failure text is
retained across retries/success and never gates typed effects. The unavailable
terms action reports the existing localized unavailable message; no legal terms
or bank policy are fabricated.

## Demo safeguards and integration boundary

The singleton demo adapter keeps a ledger for these two services. Blocking moves
a card from the active selection to the blocked selection with UTC block time,
reason and description. Unblocking reverses that state. Their fee and balance
are demo catalog values (`1,300,000` and initial `2,000,000` rial), not production
bank policy. Initial blocked-card date is stored in UTC and rendered in Jalali.

Submission checks current card eligibility, allowed reason, fee/wallet revision
and sufficient demo funds. A stable idempotency key returns the same receipt on
a lost-response retry without another debit. Reusing a key with a changed payload
is rejected. A stale quote is rejected; explicit refresh obtains the current
catalog. UseCases convert unexpected dependency exceptions to the project's
existing UnexpectedFailure.

This ledger is separate from other prototype card/dashboard repositories. Their
summary cards do not automatically synchronize with it. A production integration
must supply the real eligible-card catalog, block-history semantics, reasons,
fees/authorization, status updates and server idempotency contract. No endpoint,
OTP requirement, card-number eligibility algorithm or actual bank policy was
inferred from the Figma examples. The unblock frame's illustrative long number
is represented by a normal 16-digit demo card; real numbers remain service data.

## UI and assets

The implementation reuses AppTopBar, AppSelect, CertificateInput, AppInvoice,
DepositRequestFooter, AppDecisionSheet and the root service-sheet presenter.
Package checkbox/button controls retain their approved enablement/loading APIs.
There is no extra assistant button because the supplied frames do not show one.
Forms scroll for compact viewports and keyboard insets; controls remain authored
explicitly. No design-system package changes or dependencies were added.

- `issuance_divider.svg` matches the supplied dashed divider byte for byte.
- `issuance_select_empty.svg` and `card_features_chevron.svg` match the empty and selected dropdown assets byte for byte; their slots are 20×20.
- `chequebook_cost.svg` and `dashboard_catalog_category_wallet.svg` match the supplied gray invoice icons byte for byte; both render at 20×20.
- `card_restriction_back.svg` is exported from the actual overridden vector in the supplied frame (the design-context asset incorrectly resolved to the base menu icon). Its 6×10 exported SVG (5.4991×9.4813 vector bounds) is centered in the top bar's 40×40 control.
- The existing invoice owns money-unit glyphs and the expandable chevron; the package owns checkbox/check artwork. Native OS bars remain platform UI.
- The confirmation uses a live modal backdrop instead of embedding the design's flattened backdrop image.

## Verification

Scoped behavioral tests cover selection, final confirmation/cancellation,
previous block details, retained retry data, repeated failures, effects after
errors, wallet eligibility, quote identity, ledger transitions, idempotency,
pending-request interaction gates, route context and compact keyboard layout.
Visual captures are generated under ignored `build/previews/card_restriction`.

```sh
flutter test --no-pub test/cards/card_restriction test/cards/presentation/flows/card_features/cubit/card_features_cubit_test.dart test/cards/presentation/flows/card_features/screens/card_list_screen_test.dart test/core/router/app_router_test.dart test/core/di/injection_container_test.dart test/dashboard/implemented_services_navigation_test.dart
```

The shared regression command above passed **60 tests**. After the final
consent/retry-identity and UI adjustments, the direct feature command passed
**19 tests**:

```sh
flutter test --no-pub test/cards/card_restriction
```

The last viewport/modal-only verification also passed all **6 UI tests**:

```sh
flutter test --no-pub test/cards/card_restriction/card_restriction_screen_test.dart
```

Relevant analysis of the new Domain/Data/Presentation, changed DI/router/mapper
and tests reported no issues. The incremental final check is:

```sh
flutter analyze --no-pub lib/features/cards/presentation/card_restriction test/cards/card_restriction
```

All five exported previews were inspected against their corresponding Figma
frames, including the exact modal top/bottom placement and corrected back asset.
No full-application test suite, live-bank or device acceptance run is claimed.

Duplication review: 0 repeated request blocks found, 0 unresolved. Independent
card/reason/description actions retain explicit emits; the eligibility predicate
is a pure calculation. Flow review: 1 redundant clear removed (cancelled exit
already has its command consumed). Consent and canSubmit resets have visible
footer consumers; failures/messages are retained. The [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md)
is authoritative.
