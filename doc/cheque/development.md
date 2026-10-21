# Cheque: implemented flows and integration

Updated: 2026-10-19. This module implements cheque-book issuance, cancellation and
record clearance with repository-backed demo data. No real cheque status, wallet,
issuance or postal submission is changed.

The [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md) is authoritative.

## Navigation and module structure

| Service | ID | Route | Detailed contract |
| --- | --- | --- | --- |
| Issue cheque book | `cheque-issue` | `/cheque/book-issuance` | [Issuance](../features/cheque-book-issuance-en.md) |
| Cancel cheques | `cheque-cancel` | `/cheque/cancellation` | [Cancellation](cancellation.md) |
| Clear record | `cheque-clear` | `/cheque/clearance` | [Clearance](../cheque-clearance-feature-en.md) |

Dashboard and supported deposit actions use the central service registry.
Issuance/cancellation resolve an optional entry deposit after catalog fetch.
Central routes forward typed inputs and participate in authentication/return
validation; they do not construct Cubits or query repositories.

Entities/repositories/use cases are under `features/cheque/domain`; adapters are
under `data/repositories`. Presentation services are `book_issuance`,
`cancellation` and `clearance`. GetIt registers repositories, never Cubits.
Each screen creates its Cubit directly in a Provider and starts its catalog fetch.
Flow steps and their editing modals borrow that same instance with `.value`.

## Issuance: five scenarios, one flow

Four stages cover account/leaf count, registry checking, delivery and fee
confirmation. The mock registry query takes two seconds. Applicant type,
residences, eligibility and fees are adapter data; no test switch appears in UI.

| `CHEQUEBOOK_SCENARIO` | Behavior |
| --- | --- |
| `legal-verified` | Legal applicant; required recipient identity |
| `individual-verified` | Individual; delivery address; optional recipient/agent; default |
| `single-unverified` | One unregistered residence; blocking notice then home |
| `mixed-addresses` | Registered and invalid residences; invalid residence may be deleted |
| `multiple-unverified` | No registered residence; Next disabled; removing one leaves the single-address notice |

Example: `flutter run --dart-define=CHEQUEBOOK_SCENARIO=mixed-addresses`.
Fully restart when changing the compile-time scenario. Registry-residence
deletion and local delivery-address removal are separate operations. Editing a
local address never verifies it; the repository prevents deleting the last
registry residence.

Quotes bind the checked account, leaf count, residency token and delivery payload.
The mock checks expiry, wallet sufficiency, binding and idempotency. The official
registry browser link works on supported native hosts. Profile “My addresses”
and agent lookup retain their approved unavailable feedback.

## Cancellation

1. Choose one deposit and paper/digital type.
2. Fetch eligible cheques, search by number or Sayad ID, select one/several/all.
   Next first opens the selected-cheques review, following the supplied order.
   Its Back button advances to reasons if entries remain; outside/system
   dismissal stays at selection. The header icon also opens review without
   advancing the flow.
3. Choose individual reasons or explicitly apply one reason to all. Options are
   drafts until Select. Both review and reason stages support confirmed removal;
   removing the final reason-stage cheque returns to the selection list.
4. Read letter/post instructions, open the postal helper, accept terms and submit
   the confirmed snapshot. Letter and legal-content actions currently show the
   owner-approved unavailable message.

Search accepts Persian, Arabic and Latin digits and preserves selected entries
hidden by the query. Select All covers the fetched account/type list and is
hidden during search. Account/type changes clear dependent choices. The default
mock gives ten records; deposit `10.1234567.2` plus digital type gives an empty
list. Retrying unchanged submission preserves the snapshot and key.

## Record clearance

Every reason starts with deposit, cheque number and request reason. Deposit/block
and older-than-three-years reasons submit without postal documents. Original
cheque, partial non-payment certificate and notarized consent show the applicable
document instructions. Judicial letters also require a letter number.
A syntactically valid missing cheque shows its service error under that field.

Terms, notarized-consent conditions and sample documents remain unavailable by
owner decision. Valid mock numbers are listed in the detailed clearance contract.

## Shared postal-office helper

`presentation/shared/postal` owns `ChequePostalCubit`, plain Freezed State,
`ChequePostalSheet` and `ChequePostalResults`. Clearance and cancellation both
open `showChequePostalSheet`. Every opening creates a separate Provider-owned
postal Cubit; selected cheques, reasons and consent remain in the caller's Cubit.

The helper fetches provinces, narrows cities after province selection, retrieves
offices for the chosen city and prepares actual retrieved addresses for native
sharing. Province changes clear city/results; Back from results returns to
location selection. Sharing opens the system chooser and never sends on its own.
Unsupported hosts show availability feedback.

The existing `ChequeClearanceRepository` and use cases supply postal data to both
callers. Reuse of that contract avoids another fixture/API layer. A real adapter
can replace it without duplicating UI. Tehran/north-east returns two demo
addresses; Isfahan returns an empty result.

This helper finds post offices. Delivery-address editing and postal-code
validation belong to `features/address`, opened through
`ServiceRegistry.openAddressEditor`. Core `DeliveryAddress` is the common result
used by deposit certificates and cheque-book delivery. A local address is not a
registry verification or a persisted profile entry.

## Reuse and service boundaries

Public avp_ui fields/selects/search/checkboxes/toggle/stepper/buttons are reused,
with app headers, assistant, sheet frame, summaries and delivery sections.
Reason selection uses package AppSelectSheet through showAppSelectSheetContent with
its existing Cubit-owned draft and confirmation footer. Account/type and postal
province/city selects open the same package sheet through AppSelect’s package-owned default behavior,
without changing their field visuals. Original assets are bundled locally;
matching existing artwork is reused.

Cubit owns filtering, selection, drafts, request snapshots, stages and effect
intents. UI owns Flutter resources and executes modal, scroll, navigation and
platform effects. Cancellation stage changes publish a reveal intent so the
new stage starts at the top. Independent operations have separate statuses;
a request-ID check is used only for genuinely overlapping list requests.
Boundary exceptions become `Err` according to the existing Result contract.

Demo submissions check service-specific data and idempotency. Real adapters still
need bank authorization, eligibility, official documents/tariffs, atomic execution
and durable deduplication. Missing content is never replaced with a fabricated
legal document or real bank success.

## Verification

Tests: `test/cheque/cheque_book_*`, `cheque_clearance_*` and
`cheque_cancellation_*`, plus shared assets and router regressions.

```sh
flutter test test/cheque test/core/router/app_router_test.dart
flutter analyze
```

Screen tests support `CAPTURE_CERTIFICATE_PREVIEWS=1` and write ignored PNGs under
`build/previews/certificates/`. Detailed contracts list the exact Figma nodes.
Tests verify the application/demo boundary, not execution against a bank.
