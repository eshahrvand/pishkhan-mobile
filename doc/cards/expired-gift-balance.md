# Transfer expired gift card balance

Status: interactive two-step flow with an injectable repository. The default adapter records a demo request without transferring funds.

## Design and entry points

All references belong to the [Cards Figma design](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27997-10381).

| State | Node |
| --- | --- |
| Selection without account filter | `27997:10381` |
| Selected cards | `27997:10644` |
| Removable selected-card sheet | `27997:10746` |
| Destination empty | `27997:10666` |
| Destination and consent filled | `27997:10706` |
| Selection with account filter | `27997:10403` |
| Filter sheet, all accounts | `27997:10576` |
| Filter sheet, account selected | `27997:10610` |

The authenticated route is `/cards/expired-gift-balance` (`AppRoutes.expiredGiftBalance`). Service ID `card-expired-gift` now opens this workflow from the service catalog and the standalone Gift cards action. Explicit host callbacks retain precedence. The existing generic gift-balance action on dashboard cards is a separate service and retains its behavior.

## Selection and review

`ExpiredGiftBalanceCubit` owns the workflow, search, selected IDs, computed total, temporary/applied filter, destination, consent and submission. The filter button and each card's linked-deposit row are shown when the customer's catalog has at least two accounts. One-account catalogs use the no-filter layout. The default mock catalog has two accounts; a one-account repository fixture exercises the alternative.

Search normalizes Persian and Arabic digits and accepts grouped card numbers. Select all affects the visible result set only. Search and filters preserve selections outside that result set. The review sheet always lists the complete selection, with sequential numbering and removal actions. Removing cards updates the count and total in Cubit and resets consent.

Next opens the selected-card sheet. Its Back button closes the sheet and advances to destination selection when at least one card remains. Outside/back dismissal stays on selection. The header's list action also opens review; closing it on the destination step preserves that step. Removing the last card returns to selection and disables Next.

## Destination and submission

Destination shows the selected count and sum of those cards' actual balances. The sample Figma summary differs from the sum of its repeated sample rows; the implementation computes the total consistently rather than copying that conflicting constant.

Destination selection and accepted terms are required to submit. Going back retains selected cards and destination, but clears consent. The terms action accepts a host callback and otherwise reports the unavailable document. Pending transfers disable edits, duplicate submission and workflow back navigation. Failures are retryable; unchanged retries preserve the request's idempotency key. Completion displays the adapter receipt with an explicit demo marker when appropriate.

## Filter sheet

Opening the filter copies the applied account into a draft. Choosing an account changes only the draft. Apply commits it; dismissing cancels it. The All option removes the filter. Arbitrary account IDs are rejected. The account filter is independent of the transfer destination.

## Data and UI integration

The flow shares `CardServicesRepository`, validated `CardServiceCatalog` and typed receipts with [change linked card deposit](change-card-deposit.md). Gift requests contain selected card IDs, destination ID and an idempotency key. The mock adapter validates the selection and records an in-memory demo receipt. Real expiry, ownership, eligibility, available amounts, destination permissions, server idempotency and execution must be supplied by the bank adapter. Zero-balance cards cannot be selected.

The screen supplies a `BlocProvider` whose `create` constructs the Cubit and calls `load()`. The provider closes it on removal and retains it across ordinary rebuilds; changing the repository starts a fresh scope. UI reads status and step directly from State. Search results, selected records, totals and action eligibility are computed in the Cubit and emitted as immutable State fields; no custom getters are defined. The view owns navigation and completion effects. Selection, destination and the two substantial sheets are coherent UI sections; related card detail rows remain with selection and are reused by review. Search uses `avp_ui` `AppTextField` directly; selectors, checkboxes, toggles, buttons and progress use package components. The existing app sheet header and authored scrim are reused. The top bar's optional leading action slot is scoped to this screen and preserves previous callers' defaults.

Before implementing the flow, `avp_ui` `AppStepper` was fixed to keep the title dot adjacent to the title and the supporting copy on the physical right under RTL. The 42-pixel ring remains on the physical left, with the authored 24-pixel gap and 6-pixel text gap. Long labels wrap. This requires distributing the updated sibling package with the app.

All new copy is localized for Persian, English and Arabic, and inputs remain RTL. Native status/navigation bars are owned by the platform. Sheets reserve safe areas, constrain their height and scroll on small screens.

## Validation

Cubit tests cover account-count variants, normalized search, visible-set selection, draft filter cancellation/application, removal, totals, back behavior, consent, transfer gating and retry. Widget tests exercise the supplied states, both sheets, account variants, service navigation and 320-pixel phones with enlarged text in all three locales. A geometry regression verifies Stepper dot/title alignment and subtitle spacing.

Optional captures use `CAPTURE_CARD_SERVICE_PREVIEWS=1 flutter test test/cards/card_services/card_service_screens_test.dart` and write to ignored `build/previews/card-services/`. No images or visual review galleries are stored in `doc/`.

## Cubit/State coding convention

Follow [architecture Section 12](../architecture-smart-virtual-counter-v2-en.md#12-state-management-with-cubit) for new work and refactors. State is a plain Freezed data class with defaults and independent request statuses. Cubits accept an initial State, compute UI data and eligibility, and emit immutable snapshots through `copyWith`. UI reads those fields directly; no custom State/Cubit getters or UI-facing rules facade is used. Dependencies remain injectable and lifecycle/duplicate-request safeguards stay in place.
