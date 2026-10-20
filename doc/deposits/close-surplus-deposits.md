# Close surplus deposits

Route: `/deposits/close-surplus-deposits`; service ID: `deposit-close-extras`.
Cubit resolves the optional entry account against the fetched catalog, accepting
Persian/Arabic digits and number separators.

## Current owner-approved flow

The customer selects one retained primary. Every other eligible deposit is
automatically surplus; the customer does not classify each account individually.

| Catalog | Screen |
| --- | --- |
| More than one deposit | Primary dropdown and terms; submit after selection and consent |
| One deposit, or no deposits | Empty result and Back |

Figma file `nYQNyZdSs98lwymCpt5Sag`: `28060:13952` (unselected), `28060:14157`
(selected), `28060:14179` (empty). The earlier experimental review/candidate-list
UI is removed. No particular account number forces the empty state when the
customer still has multiple accounts.

Changing the primary clears consent and prepares a new request identity. Loading
disables edits; Back and discard confirmation remain available. Failure preserves
the choice for retry. Official terms currently show unavailable-content feedback.
The design describes transferring balances and associated items to the primary;
actual transfers require bank integration.

## Data and ownership

The screen directly creates `CloseSurplusDepositsCubit` in its Provider and calls
`fetchPrimaryDeposits`. GetIt holds the repository only. Plain Freezed State owns
catalog/submission status, selection, consent and effects.

`CloseRemainingDeposits` fetches the surplus review/token and builds the request
to close every reviewed account except the selected primary. This is an
application operation, not an extra UI page. Its flow-scoped pending payload
preserves the reviewed accounts and idempotency key after an uncertain response.

The mock starts with `10.1234567.1`, `.2` and `.3`. Selecting any one retains it
and closes the other two in that repository's in-memory simulation. Reopening
with the remaining single account shows the empty state. Restarting resets the
fixture. Tests supply a single-account catalog without adding debug widgets.

The mock rejects invalid/altered tokens, primary/candidate mismatches, duplicates,
already-closed candidates and key conflicts. Identical retries return the same
receipt. It changes no real account or balance; production ownership, eligibility,
atomic transfer/closure and durable idempotency must be enforced by the bank.

## Reuse and verification

Uses `CertificateSelect`, `AppCheckbox`, `AppButton`, `AppTopBar`,
`AppAssistantButton`, the exit dialog and original empty-state artwork.
Tests: `test/deposits/close_surplus_deposits_cubit_test.dart` and
`test/deposits/close_surplus_deposits_screen_test.dart`. Coverage includes catalog
count branching, entry resolution, consent/reset, retry identity, mock review
validation, receipt/exit behavior and compact layouts. Opt-in previews use
`CAPTURE_CERTIFICATE_PREVIEWS=1` and write
`build/previews/certificates/surplus-deposits-*.png`.
