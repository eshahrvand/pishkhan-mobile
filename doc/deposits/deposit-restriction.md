# Deposit blocking and unblocking

Routes: `/deposits/block` and `/deposits/unblock`. Service IDs: `deposit-block`
and `deposit-unblock`. Dashboard service entries open these flows; the deposit
list's Block action also opens blocking with that deposit number.

Figma file `nYQNyZdSs98lwymCpt5Sag`, nodes `28060:14021`, `28060:14130`,
`28060:14047` and `28060:14074` define the initial and filled forms.

## Behavior

- The service returns eligible deposits for the requested operation, supported
  request reasons, fee quote and wallet balance. The form does not infer banking
  eligibility from the generic deposit list.
- Select a deposit and reason, optionally enter a description, and accept terms.
  The description is optional, matching the supplied placeholder. Submission
  requires sufficient wallet balance. Changing the deposit resets consent.
- Selecting a blocked deposit displays its actual blocking reason, Jalali date
  and description. Switching deposits replaces that information with the selected
  record. New request text stays separate from the prior blocking description.
- Forms scroll independently of the footer. The filled unblock Figma frame has
  overlapping invoice/terms content; the implementation keeps terms and the submit
  button visible and lets the longer form scroll instead of reproducing that overlap.
- Catalog failures show Retry. Submission failures preserve inputs and allow
  retry with the same request identity. Editing payload fields creates a new
  request identity. Loading disables form controls; Back remains available.
- Back/assistant request exit confirmation after edits. Terms currently show the
  existing unavailable feedback. Completion uses an explicitly simulated receipt.

## Ownership and reuse

One `DepositRestrictionScreen` owns a directly created `DepositRestrictionCubit`,
with immutable operation input and a real initial catalog fetch. Cubit resolves
the repository through GetIt; no presentation class is registered. State is the
existing plain Freezed `.initial` / `part of` pattern, with independent catalog
and submission statuses. Cubit owns entry resolution, selection, wallet checks,
request construction, effects and raw exit-result interpretation. Listeners only
execute Flutter effects. Repository exceptions become `UnexpectedFailure` at
the existing application boundary.

Reuses `CertificateSelect`, `CertificateInput`, `AppInvoice`, `AppCheckbox`,
`AppButton`, `AppAgentCardDetailRow`, `AppTopBar`, `AppAssistantButton`,
`JalaliDateFormatter`, the exit dialog and local SVG assets. `DepositDivider`
gains an optional thickness while preserving its existing half-pixel default.
The dashed section divider is byte-identical to `issuance_divider.svg`; the
half-pixel blocking-details divider is the original Figma export.

## Mock integration

`MockDepositRestrictionsRepository` supplies session-only data. Deposits ending
in `.1` and `.3` start open; `.2` starts blocked with the design's example details.
The only demonstrated reason is Deposit Management. Fees are 1,300,000 rial and
the initial wallet balance is 2,000,000 rial, as in Figma. Successful simulation
changes that mock record's status and deducts the mock fee once. Restarting resets
the mock session; the generic dashboard/deposit-list repositories remain separate
fixtures. No real bank account or wallet changes.

The mock boundary binds quote, operation and eligible record; it rejects altered
or stale candidates, insufficient funds and idempotency-key conflicts. Repeating
an identical request returns the original receipt, including after a lost response.
A live integration must replace the repository and enforce ownership, authorized
block/unblock eligibility, quote validity and atomic status/fee/idempotency behavior
on the server. It must not allow release of restrictions the customer cannot lift.

## Verification

Tests: `test/deposits/deposit_restriction_cubit_test.dart` and
`test/deposits/deposit_restriction_screen_test.dart`, plus the existing deposit-list,
router and DI tests. They cover both operations, optional description, consent,
wallet sufficiency, previous blocking information, errors, loading, exit behavior,
central service entry and idempotent retry after a lost response. Small 320px
viewports and larger text are checked in fa/en/ar.

Set `CAPTURE_CERTIFICATE_PREVIEWS=1` when running the widget tests to save the four
state previews under `build/previews/certificates/deposit-restriction-*.png`.
